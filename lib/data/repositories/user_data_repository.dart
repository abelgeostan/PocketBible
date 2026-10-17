import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../database/bible_database.dart';
import '../models/bookmark_item.dart';
import '../models/highlight_item.dart';
import '../models/note_item.dart';
import '../models/reading_position.dart';

class UserDataRepository {
  final BibleDatabase _db = BibleDatabase.instance;

  // --- Last Read Position ---

  Future<void> saveLastRead(ReadingPosition position) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyLastRead, json.encode(position.toJson()));
    await _db.recordReading(position.bookCode, position.bookName, position.chapter);
  }

  Future<ReadingPosition?> getLastRead() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(AppConstants.keyLastRead);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final map = json.decode(jsonStr) as Map<String, dynamic>;
        return ReadingPosition.fromJson(map);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  // --- Bookmarks ---

  Future<List<BookmarkItem>> getBookmarks() async {
    return await _db.getBookmarks();
  }

  Future<bool> addBookmark(BookmarkItem item) async {
    final id = await _db.addBookmark(item);
    return id > 0;
  }

  Future<bool> removeBookmark(String bookCode, int chapter, int verse) async {
    final count = await _db.removeBookmark(bookCode, chapter, verse);
    return count > 0;
  }

  Future<bool> isBookmarked(String bookCode, int chapter, int verse) async {
    return await _db.isBookmarked(bookCode, chapter, verse);
  }

  // --- Highlights ---

  Future<List<HighlightItem>> getHighlights() async {
    return await _db.getHighlights();
  }

  Future<bool> setHighlight(HighlightItem item) async {
    final id = await _db.setHighlight(item);
    return id > 0;
  }

  Future<bool> removeHighlight(String bookCode, int chapter, int verse) async {
    final count = await _db.removeHighlight(bookCode, chapter, verse);
    return count > 0;
  }

  // --- Notes ---

  Future<List<NoteItem>> getNotes() async {
    return await _db.getNotes();
  }

  Future<bool> saveNote(NoteItem note) async {
    final id = await _db.saveNote(note);
    return id > 0;
  }

  Future<bool> deleteNote(String bookCode, int chapter, int verse) async {
    final count = await _db.deleteNote(bookCode, chapter, verse);
    return count > 0;
  }

  // --- Reading History ---

  Future<List<Map<String, dynamic>>> getReadingHistory() async {
    return await _db.getReadingHistory();
  }

  Future<void> clearHistory() async {
    await _db.clearHistory();
  }
}
