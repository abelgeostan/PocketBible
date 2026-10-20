import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import '../database/bible_database.dart';
import '../models/bible_book.dart';
import '../models/bible_verse.dart';
import '../models/daily_verse.dart';

class BibleRepository {
  final BibleDatabase _db = BibleDatabase.instance;
  List<BibleBook>? _cachedBooks;
  List<DailyVerse>? _cachedDailyVerses;
  List<Map<String, dynamic>>? _cachedVerseRefs;

  Future<List<BibleBook>> getBooks() async {
    if (_cachedBooks != null && _cachedBooks!.isNotEmpty) {
      return _cachedBooks!;
    }

    try {
      // 1. Try loading from bundled JSON (instant load)
      final jsonStr = await rootBundle.loadString('assets/data/books.json');
      final list = json.decode(jsonStr) as List;
      _cachedBooks = list.map((item) => BibleBook.fromJson(item)).toList();
      return _cachedBooks!;
    } catch (_) {
      // 2. Fallback to SQLite DB
      _cachedBooks = await _db.getBooks();
      return _cachedBooks!;
    }
  }

  Future<BibleBook?> getBookByCode(String code) async {
    final books = await getBooks();
    try {
      return books.firstWhere((b) => b.code == code);
    } catch (_) {
      return null;
    }
  }

  Future<List<BibleVerse>> getChapterVerses(String bookCode, int chapter) async {
    return await _db.getChapterVerses(bookCode, chapter);
  }

  Future<int> getVerseCount(String bookCode, int chapter) async {
    return await _db.getVerseCount(bookCode, chapter);
  }

  Future<List<BibleVerse>> searchVerses(
    String query, {
    String? testament,
    String? bookCode,
    int limit = 50,
  }) async {
    return await _db.searchVerses(
      query,
      testament: testament,
      bookCode: bookCode,
      limit: limit,
    );
  }

  /// Returns the daily verse for a given date following the day-of-year formula from PocketBible.in
  Future<DailyVerse?> getVerseForDate(DateTime date) async {
    if (_cachedDailyVerses == null) {
      try {
        final jsonStr = await rootBundle.loadString('assets/data/today_verses.json');
        final list = json.decode(jsonStr) as List;
        _cachedDailyVerses = list.map((item) => DailyVerse.fromJson(item)).toList();
      } catch (_) {
        return null;
      }
    }

    if (_cachedDailyVerses == null || _cachedDailyVerses!.isEmpty) return null;

    final startOfYear = DateTime(date.year, 1, 1);
    final dayNumber = date.difference(startOfYear).inDays + 1;
    final index = (dayNumber - 1) % _cachedDailyVerses!.length;
    return _cachedDailyVerses![index];
  }

  /// Returns today's verse following the exact day-of-year formula from PocketBible.in
  Future<DailyVerse?> getTodayVerse() => getVerseForDate(DateTime.now());

  /// Returns a random verse reference from the 31,098 verses of the Bible
  Future<Map<String, dynamic>?> getRandomVerseRef() async {
    if (_cachedVerseRefs == null) {
      try {
        final jsonStr = await rootBundle.loadString('assets/data/verse_refs.json');
        final list = json.decode(jsonStr) as List;
        _cachedVerseRefs = list.cast<Map<String, dynamic>>();
      } catch (_) {
        return null;
      }
    }

    if (_cachedVerseRefs == null || _cachedVerseRefs!.isEmpty) return null;
    final random = Random();
    return _cachedVerseRefs![random.nextInt(_cachedVerseRefs!.length)];
  }
}
