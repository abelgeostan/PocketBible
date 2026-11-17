import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/database/bible_database.dart';
import '../constants/app_constants.dart';

class BackupResult {
  final bool success;
  final String? message;
  final String? filePath;
  final int bookmarks;
  final int highlights;
  final int notes;
  final int history;

  const BackupResult({
    required this.success,
    this.message,
    this.filePath,
    this.bookmarks = 0,
    this.highlights = 0,
    this.notes = 0,
    this.history = 0,
  });

  int get totalItems => bookmarks + highlights + notes;
}

class BackupService {
  BackupService._internal();
  static final BackupService instance = BackupService._internal();

  final BibleDatabase _db = BibleDatabase.instance;

  /// Exports all bookmarks, highlights, notes, and reading history to a JSON file
  /// and directly downloads / saves it to the device's Downloads directory.
  Future<BackupResult> exportUserData() async {
    try {
      final rawData = await _db.getAllUserData();

      final bookmarks = rawData['bookmarks'] as List? ?? [];
      final highlights = rawData['highlights'] as List? ?? [];
      final notes = rawData['notes'] as List? ?? [];
      final history = rawData['reading_history'] as List? ?? [];

      final now = DateTime.now();
      final backupPayload = {
        'app': AppConstants.appName,
        'app_version': AppConstants.appVersion,
        'export_timestamp': now.toIso8601String(),
        'data': {
          'bookmarks': bookmarks,
          'highlights': highlights,
          'notes': notes,
          'reading_history': history,
        },
      };

      final jsonContent = const JsonEncoder.withIndent('  ').convert(backupPayload);

      final dateStr = '${now.year}'
          '${now.month.toString().padLeft(2, '0')}'
          '${now.day.toString().padLeft(2, '0')}_'
          '${now.hour.toString().padLeft(2, '0')}'
          '${now.minute.toString().padLeft(2, '0')}';

      final fileName = 'pocketbible_backup_$dateStr.json';
      final fileBytes = Uint8List.fromList(utf8.encode(jsonContent));

      String? savedPath;

      // 1. First attempt: Direct save to Android standard Downloads directory
      if (Platform.isAndroid) {
        try {
          final downloadDir = Directory('/storage/emulated/0/Download');
          if (await downloadDir.exists()) {
            final targetFile = File('${downloadDir.path}/$fileName');
            await targetFile.writeAsString(jsonContent, flush: true);
            savedPath = targetFile.path;
          }
        } catch (e) {
          debugPrint('BackupService: Direct write to /storage/emulated/0/Download failed: $e');
        }
      }

      // 2. If direct write didn't succeed (scoped storage on newer Android, iOS, desktop):
      if (savedPath == null) {
        savedPath = await FilePicker.platform.saveFile(
          dialogTitle: 'Save PocketBible Backup',
          fileName: fileName,
          type: FileType.custom,
          allowedExtensions: ['json'],
          bytes: fileBytes,
        );
      }

      if (savedPath == null) {
        return const BackupResult(
          success: false,
          message: 'Download cancelled',
        );
      }

      return BackupResult(
        success: true,
        filePath: savedPath,
        bookmarks: bookmarks.length,
        highlights: highlights.length,
        notes: notes.length,
        history: history.length,
      );
    } catch (e) {
      debugPrint('BackupService: Export error: $e');
      return BackupResult(
        success: false,
        message: e.toString(),
      );
    }
  }

  /// Prompts user to pick a backup .json file and imports bookmarks, highlights, notes, and history
  Future<BackupResult?> importUserData() async {
    try {
      final pickerResult = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
        withData: true,
      );

      if (pickerResult == null || pickerResult.files.isEmpty) {
        return null; // User cancelled
      }

      final file = pickerResult.files.single;
      String jsonString;

      if (file.bytes != null && file.bytes!.isNotEmpty) {
        jsonString = utf8.decode(file.bytes!);
      } else if (file.path != null && file.path!.isNotEmpty) {
        jsonString = await File(file.path!).readAsString();
      } else {
        return const BackupResult(
          success: false,
          message: 'Could not read file data',
        );
      }

      dynamic decoded;
      try {
        decoded = json.decode(jsonString);
      } catch (e) {
        return const BackupResult(
          success: false,
          message: 'Invalid JSON file format',
        );
      }

      if (decoded is! Map) {
        return const BackupResult(
          success: false,
          message: 'Unsupported backup format',
        );
      }

      final dataMap = decoded['data'] is Map ? decoded['data'] as Map : decoded;
      final typedData = <String, dynamic>{
        'bookmarks': dataMap['bookmarks'],
        'highlights': dataMap['highlights'],
        'notes': dataMap['notes'],
        'reading_history': dataMap['reading_history'],
      };

      final counts = await _db.importBackupData(typedData);

      // If reading history was imported, sync latest entry to lastRead in preferences
      if ((counts['reading_history'] ?? 0) > 0) {
        try {
          final history = await _db.getReadingHistory(limit: 1);
          if (history.isNotEmpty) {
            final latest = history.first;
            final bCode = latest['book_code']?.toString() ?? '';
            final bName = latest['book_name']?.toString() ?? '';
            final chap = int.tryParse(latest['chapter']?.toString() ?? '') ?? 1;
            final ts = int.tryParse(latest['timestamp']?.toString() ?? '') ??
                DateTime.now().millisecondsSinceEpoch;
            if (bCode.isNotEmpty) {
              final prefs = await SharedPreferences.getInstance();
              final pos = {
                'book_code': bCode,
                'book_name': bName,
                'chapter': chap,
                'verse': 1,
                'timestamp': ts,
              };
              await prefs.setString(AppConstants.keyLastRead, json.encode(pos));
            }
          }
        } catch (e) {
          debugPrint('BackupService: Error syncing imported lastRead: $e');
        }
      }

      return BackupResult(
        success: true,
        filePath: file.name,
        bookmarks: counts['bookmarks'] ?? 0,
        highlights: counts['highlights'] ?? 0,
        notes: counts['notes'] ?? 0,
        history: counts['reading_history'] ?? 0,
      );
    } catch (e) {
      debugPrint('BackupService: Import error: $e');
      return BackupResult(
        success: false,
        message: e.toString(),
      );
    }
  }
}
