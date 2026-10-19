import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/bible_book.dart';
import '../models/bible_verse.dart';
import '../models/bookmark_item.dart';
import '../models/highlight_item.dart';
import '../models/note_item.dart';

class BibleDatabase {
  static final BibleDatabase instance = BibleDatabase._init();
  static Database? _database;
  static Future<Database>? _initFuture;

  BibleDatabase._init();

  Future<Database> get database async {
    if (_database != null && _database!.isOpen) return _database!;
    _initFuture ??= _initDB('pocketbible.db');
    try {
      _database = await _initFuture!;
      return _database!;
    } catch (e) {
      _initFuture = null;
      rethrow;
    }
  }

  Future<Database> _initDB(String fileName) async {
    Directory documentsDirectory;
    try {
      documentsDirectory = await getApplicationDocumentsDirectory();
    } catch (_) {
      documentsDirectory = Directory.current;
    }

    final path = join(documentsDirectory.path, fileName);
    final file = File(path);
    final exists = await file.exists();
    final isValidSize = exists && (await file.length()) > 1024 * 1024;

    if (!isValidSize) {
      // Copy pre-built database from asset to disk safely using a temporary file
      try {
        await Directory(dirname(path)).create(recursive: true);
        ByteData data = await rootBundle.load('assets/database/pocketbible.db');
        List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        final tmpPath = '$path.tmp';
        final tmpFile = File(tmpPath);
        await tmpFile.writeAsBytes(bytes, flush: true);
        if (await file.exists()) {
          await file.delete();
        }
        await tmpFile.rename(path);
      } catch (e) {
        debugPrint('Error copying assets database: $e');
        // Fallback: create empty DB if asset copy fails
      }
    } else {
      // Check if existing database needs upgrade to version 3 (complete scripture text)
      try {
        final existingDb = await openDatabase(path);
        final pragmaRes = await existingDb.rawQuery('PRAGMA user_version;');
        final currentVersion = pragmaRes.isNotEmpty ? (pragmaRes.first.values.first as int? ?? 0) : 0;

        if (currentVersion < 3) {
          debugPrint('Upgrading database from version $currentVersion to 3 (restoring full scripture verses)...');
          // Backup user tables
          final bookmarks = await existingDb.query('bookmarks');
          final highlights = await existingDb.query('highlights');
          final notes = await existingDb.query('notes');
          final history = await existingDb.query('reading_history');
          await existingDb.close();

          // Copy fresh complete database from assets
          ByteData data = await rootBundle.load('assets/database/pocketbible.db');
          List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
          final tmpPath = '$path.tmp';
          final tmpFile = File(tmpPath);
          await tmpFile.writeAsBytes(bytes, flush: true);
          if (await file.exists()) {
            await file.delete();
          }
          await tmpFile.rename(path);

          // Restore user data into new database
          final upgradedDb = await openDatabase(path);
          final batch = upgradedDb.batch();
          for (final b in bookmarks) {
            batch.insert('bookmarks', b, conflictAlgorithm: ConflictAlgorithm.replace);
          }
          for (final h in highlights) {
            batch.insert('highlights', h, conflictAlgorithm: ConflictAlgorithm.replace);
          }
          for (final n in notes) {
            batch.insert('notes', n, conflictAlgorithm: ConflictAlgorithm.replace);
          }
          for (final r in history) {
            batch.insert('reading_history', r, conflictAlgorithm: ConflictAlgorithm.replace);
          }
          batch.execute('PRAGMA user_version = 3;');
          await batch.commit(noResult: true);
          await upgradedDb.close();
          debugPrint('Database successfully upgraded to version 3 with user data preserved.');
        } else {
          await existingDb.close();
        }
      } catch (e) {
        debugPrint('Error upgrading existing database to version 3: $e');
      }
    }

    final db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await _createTables(db);
      },
      onOpen: (db) async {
        await _ensureUserTables(db);
        await _applyScriptureCorrections(db);
      },
    );

    return db;
  }

  Future<void> _applyScriptureCorrections(Database db) async {
    try {
      final pragmaRes = await db.rawQuery('PRAGMA user_version;');
      final userVersion = pragmaRes.isNotEmpty ? (pragmaRes.first.values.first as int? ?? 0) : 0;
      if (userVersion >= 2) return;

      final batch = db.batch();

      // 1. Titus 1:1 - remove test prefix
      batch.rawUpdate('''
        UPDATE verses 
        SET text = REPLACE(text, 'Testing ag live sync ', '') 
        WHERE book_code = 'TIT' AND chapter = 1 AND verse = 1 AND text LIKE 'Testing ag live sync%';
      ''');

      // 2. Genesis 5:5 - remove trailing image tag
      batch.rawUpdate('''
        UPDATE verses 
        SET text = 'ആദാമിന്റെ ആയുഷ്കാലം ആകെ തൊള്ളായിരത്തി മുപ്പതു സംവത്സരമായിരുന്നു; പിന്നെ അവൻ മരിച്ചു.' 
        WHERE book_code = 'GEN' AND chapter = 5 AND verse = 5 AND text LIKE '%alt=%';
      ''');

      // 3. Exodus 25:9 - remove trailing image tag
      batch.rawUpdate('''
        UPDATE verses 
        SET text = 'തിരുനിവാസവും അതിന്റെ ഉപകരണങ്ങളും ഞാൻ കാണിക്കുന്ന മാതൃകപ്രകാരമൊക്കെയും തന്നേ ഉണ്ടാക്കേണം.' 
        WHERE book_code = 'EXO' AND chapter = 25 AND verse = 9 AND text LIKE '%alt=%';
      ''');

      // 4. Joshua 13:7 - remove trailing image tag
      batch.rawUpdate('''
        UPDATE verses 
        SET text = 'ആകയാൽ ഈ ദേശം ഒമ്പതു ഗോത്രങ്ങൾക്കും മനശ്ശെയുടെ പാതിഗോത്രത്തിന്നും അവകാശമായി വിഭാഗിക്ക.' 
        WHERE book_code = 'JOS' AND chapter = 13 AND verse = 7 AND text LIKE '%alt=%';
      ''');

      // 5. Ephesians 6:13 - remove trailing image tag
      batch.rawUpdate('''
        UPDATE verses 
        SET text = 'അതുകൊണ്ടു നിങ്ങൾ ദുർദ്ദിവസത്തിൽ എതിർപ്പാനും സകലവും സമാപിച്ചിട്ടു ഉറെച്ചു നില്പാനും കഴിയേണ്ടതിന്നു ദൈവത്തിന്റെ സർവ്വായുധവർഗ്ഗം എടുത്തുകൊൾവിൻ.' 
        WHERE book_code = 'EPH' AND chapter = 6 AND verse = 13 AND text LIKE '%alt=%';
      ''');

      // 6. Luke 17:37 - remove USFM footnote markers
      batch.rawUpdate('''
        UPDATE verses 
        SET text = 'അവർ അവനോടു: കർത്താവേ, എവിടെ എന്നു ചോദിച്ചതിന്നു: ശവം ഉള്ളേടത്തു കഴുക്കൾ കൂടും എന്നു അവൻ പറഞ്ഞു.' 
        WHERE book_code = 'LUK' AND chapter = 17 AND verse = 37 AND text LIKE '%+w%';
      ''');

      // 7. Mark - remove leading '* ' from bulleted verses
      batch.rawUpdate('''
        UPDATE verses 
        SET text = SUBSTR(text, 3) 
        WHERE book_code = 'MRK' AND text LIKE '* %';
      ''');

      batch.execute('PRAGMA user_version = 2;');
      await batch.commit(noResult: true);
    } catch (e) {
      debugPrint('Error applying scripture corrections: \$e');
    }
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS books (
        id INTEGER PRIMARY KEY,
        book_order INTEGER UNIQUE,
        code TEXT UNIQUE,
        name TEXT,
        testament TEXT,
        total_chapters INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS verses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        book_code TEXT,
        chapter INTEGER,
        verse INTEGER,
        text TEXT
      )
    ''');

    await _ensureUserTables(db);
  }

  Future<void> _ensureUserTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS bookmarks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        book_code TEXT,
        book_name TEXT,
        chapter INTEGER,
        verse INTEGER,
        text TEXT,
        created_at INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS highlights (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        book_code TEXT,
        chapter INTEGER,
        verse INTEGER,
        color TEXT,
        created_at INTEGER,
        UNIQUE(book_code, chapter, verse)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        book_code TEXT,
        chapter INTEGER,
        verse INTEGER,
        note_text TEXT,
        created_at INTEGER,
        updated_at INTEGER,
        UNIQUE(book_code, chapter, verse)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS reading_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        book_code TEXT,
        book_name TEXT,
        chapter INTEGER,
        timestamp INTEGER
      )
    ''');
  }

  // --- Book Queries ---

  Future<List<BibleBook>> getBooks() async {
    final db = await database;
    final maps = await db.query('books', orderBy: 'book_order ASC');
    return maps.map((m) => BibleBook.fromJson(m)).toList();
  }

  Future<BibleBook?> getBookByCode(String code) async {
    final db = await database;
    final maps = await db.query(
      'books',
      where: 'code = ?',
      whereArgs: [code],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return BibleBook.fromJson(maps.first);
    }
    return null;
  }

  // --- Chapter Verses with Bookmark & Highlight status ---

  Future<List<BibleVerse>> getChapterVerses(String bookCode, int chapter) async {
    final db = await database;
    final book = await getBookByCode(bookCode);
    final bookName = book?.name ?? bookCode;

    final query = '''
      SELECT 
        v.id,
        v.book_code,
        v.chapter,
        v.verse,
        v.text,
        CASE WHEN b.id IS NOT NULL THEN 1 ELSE 0 END AS is_bookmarked,
        h.color AS highlight_color,
        n.note_text AS note_text
      FROM verses v
      LEFT JOIN bookmarks b ON b.book_code = v.book_code AND b.chapter = v.chapter AND b.verse = v.verse
      LEFT JOIN highlights h ON h.book_code = v.book_code AND h.chapter = v.chapter AND h.verse = v.verse
      LEFT JOIN notes n ON n.book_code = v.book_code AND n.chapter = v.chapter AND n.verse = v.verse
      WHERE v.book_code = ? AND v.chapter = ?
      ORDER BY v.verse ASC
    ''';

    final result = await db.rawQuery(query, [bookCode, chapter]);
    return result.map((m) => BibleVerse.fromMap(m, bookName: bookName)).toList();
  }

  Future<int> getVerseCount(String bookCode, int chapter) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM verses WHERE book_code = ? AND chapter = ?',
      [bookCode, chapter],
    );
    if (result.isNotEmpty) {
      return (result.first['count'] as int?) ?? 0;
    }
    return 0;
  }

  // --- Fast Search ---

  Future<List<BibleVerse>> searchVerses(
    String queryText, {
    String? testament,
    String? bookCode,
    int limit = 50,
  }) async {
    final db = await database;
    final cleanQuery = queryText.trim();
    if (cleanQuery.isEmpty) return [];

    final terms = cleanQuery.split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();
    if (terms.isEmpty) return [];

    // Build conditions for each search term
    final whereClauses = <String>[];
    final whereArgs = <dynamic>[];

    for (final term in terms) {
      whereClauses.add('v.text LIKE ?');
      whereArgs.add('%$term%');
    }

    if (bookCode != null && bookCode.isNotEmpty) {
      whereClauses.add('v.book_code = ?');
      whereArgs.add(bookCode);
    } else if (testament != null && testament.isNotEmpty) {
      whereClauses.add('bk.testament = ?');
      whereArgs.add(testament);
    }

    final sql = '''
      SELECT 
        v.id,
        v.book_code,
        bk.name AS book_name,
        v.chapter,
        v.verse,
        v.text
      FROM verses v
      JOIN books bk ON bk.code = v.book_code
      WHERE ${whereClauses.join(' AND ')}
      ORDER BY bk.book_order ASC, v.chapter ASC, v.verse ASC
      LIMIT ?
    ''';
    whereArgs.add(limit);

    final results = await db.rawQuery(sql, whereArgs);
    return results.map((m) => BibleVerse.fromMap(m)).toList();
  }

  // --- Bookmark CRUD ---

  Future<int> addBookmark(BookmarkItem item) async {
    final db = await database;
    return await db.insert('bookmarks', item.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> removeBookmark(String bookCode, int chapter, int verse) async {
    final db = await database;
    return await db.delete(
      'bookmarks',
      where: 'book_code = ? AND chapter = ? AND verse = ?',
      whereArgs: [bookCode, chapter, verse],
    );
  }

  Future<bool> isBookmarked(String bookCode, int chapter, int verse) async {
    final db = await database;
    final result = await db.query(
      'bookmarks',
      where: 'book_code = ? AND chapter = ? AND verse = ?',
      whereArgs: [bookCode, chapter, verse],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  Future<List<BookmarkItem>> getBookmarks() async {
    final db = await database;
    final results = await db.query('bookmarks', orderBy: 'created_at DESC');
    return results.map((m) => BookmarkItem.fromMap(m)).toList();
  }

  // --- Highlight CRUD ---

  Future<int> setHighlight(HighlightItem item) async {
    final db = await database;
    return await db.insert('highlights', item.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> removeHighlight(String bookCode, int chapter, int verse) async {
    final db = await database;
    return await db.delete(
      'highlights',
      where: 'book_code = ? AND chapter = ? AND verse = ?',
      whereArgs: [bookCode, chapter, verse],
    );
  }

  Future<List<HighlightItem>> getHighlights() async {
    final db = await database;
    final sql = '''
      SELECT 
        h.id,
        h.book_code,
        bk.name AS book_name,
        h.chapter,
        h.verse,
        h.color,
        v.text,
        h.created_at
      FROM highlights h
      JOIN books bk ON bk.code = h.book_code
      JOIN verses v ON v.book_code = h.book_code AND v.chapter = h.chapter AND v.verse = h.verse
      ORDER BY h.created_at DESC
    ''';
    final results = await db.rawQuery(sql);
    return results.map((m) => HighlightItem.fromMap(m)).toList();
  }

  // --- Note CRUD ---

  Future<int> saveNote(NoteItem note) async {
    final db = await database;
    return await db.insert('notes', note.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> deleteNote(String bookCode, int chapter, int verse) async {
    final db = await database;
    return await db.delete(
      'notes',
      where: 'book_code = ? AND chapter = ? AND verse = ?',
      whereArgs: [bookCode, chapter, verse],
    );
  }

  Future<List<NoteItem>> getNotes() async {
    final db = await database;
    final sql = '''
      SELECT 
        n.id,
        n.book_code,
        bk.name AS book_name,
        n.chapter,
        n.verse,
        v.text AS verse_text,
        n.note_text,
        n.created_at,
        n.updated_at
      FROM notes n
      JOIN books bk ON bk.code = n.book_code
      JOIN verses v ON v.book_code = n.book_code AND v.chapter = n.chapter AND v.verse = n.verse
      ORDER BY n.updated_at DESC
    ''';
    final results = await db.rawQuery(sql);
    return results.map((m) => NoteItem.fromMap(m)).toList();
  }

  // --- Reading History ---

  Future<void> recordReading(String bookCode, String bookName, int chapter) async {
    final db = await database;
    // Remove if already in recent to prevent duplicates
    await db.delete(
      'reading_history',
      where: 'book_code = ? AND chapter = ?',
      whereArgs: [bookCode, chapter],
    );

    await db.insert('reading_history', {
      'book_code': bookCode,
      'book_name': bookName,
      'chapter': chapter,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<List<Map<String, dynamic>>> getReadingHistory({int limit = 30}) async {
    final db = await database;
    return await db.query(
      'reading_history',
      orderBy: 'timestamp DESC',
      limit: limit,
    );
  }

  Future<void> clearHistory() async {
    final db = await database;
    await db.delete('reading_history');
  }
}
