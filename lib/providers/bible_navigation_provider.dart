import 'package:flutter/material.dart';
import '../data/models/bible_book.dart';
import '../data/models/reading_position.dart';
import '../data/repositories/bible_repository.dart';
import '../data/repositories/user_data_repository.dart';

class BibleNavigationProvider extends ChangeNotifier {
  final BibleRepository _bibleRepository = BibleRepository();
  final UserDataRepository _userDataRepository = UserDataRepository();

  List<BibleBook> _books = [];
  String? _selectedTestament; // 'OT', 'NT', or null
  BibleBook? _currentBook;
  int _currentChapter = 1;
  int? _targetVerse;
  ReadingPosition? _lastReadPosition;
  bool _isLoading = true;

  List<BibleBook> get books => _books;
  List<BibleBook> get oldTestamentBooks => _books.where((b) => b.isOldTestament).toList();
  List<BibleBook> get newTestamentBooks => _books.where((b) => b.isNewTestament).toList();
  List<BibleBook> get filteredBooks {
    if (_selectedTestament == 'OT') return oldTestamentBooks;
    if (_selectedTestament == 'NT') return newTestamentBooks;
    return _books;
  }

  String? get selectedTestament => _selectedTestament;
  BibleBook? get currentBook => _currentBook;
  int get currentChapter => _currentChapter;
  int? get targetVerse => _targetVerse;
  ReadingPosition? get lastReadPosition => _lastReadPosition;
  bool get isLoading => _isLoading;

  bool get hasPreviousChapter {
    if (_currentBook == null) return false;
    if (_currentChapter > 1) return true;
    final index = _books.indexOf(_currentBook!);
    return index > 0;
  }

  bool get hasNextChapter {
    if (_currentBook == null) return false;
    if (_currentChapter < _currentBook!.totalChapters) return true;
    final index = _books.indexOf(_currentBook!);
    return index < _books.length - 1;
  }

  BibleNavigationProvider() {
    init();
  }

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      _books = await _bibleRepository.getBooks();
      _lastReadPosition = await _userDataRepository.getLastRead();

      if (_lastReadPosition != null) {
        try {
          _currentBook = _books.firstWhere((b) => b.code == _lastReadPosition!.bookCode);
          _currentChapter = _lastReadPosition!.chapter;
          _selectedTestament = _currentBook?.testament;
        } catch (_) {
          _setDefaultBook();
        }
      } else {
        _setDefaultBook();
      }
    } catch (e) {
      debugPrint('Error initializing BibleNavigationProvider: $e');
      _setDefaultBook();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _setDefaultBook() {
    if (_books.isNotEmpty) {
      _currentBook = _books.first;
      _currentChapter = 1;
      _selectedTestament = 'OT';
    }
  }

  void selectTestament(String? testament) {
    _selectedTestament = testament;
    if (_currentBook != null && testament != null && _currentBook!.testament != testament) {
      // Pick first book of chosen testament
      final matching = _books.where((b) => b.testament == testament).toList();
      if (matching.isNotEmpty) {
        _currentBook = matching.first;
        _currentChapter = 1;
      }
    }
    notifyListeners();
  }

  void selectBook(String bookCode) {
    try {
      final book = _books.firstWhere((b) => b.code == bookCode);
      _currentBook = book;
      _selectedTestament = book.testament;
      _currentChapter = 1;
      _targetVerse = null;
      notifyListeners();
    } catch (_) {}
  }

  void selectChapter(int chapter, {int? verse}) {
    if (_currentBook == null) return;
    _currentChapter = chapter.clamp(1, _currentBook!.totalChapters);
    _targetVerse = verse;
    _saveCurrentPosition();
    notifyListeners();
  }

  void navigateTo(String bookCode, int chapter, {int? verse}) {
    try {
      final book = _books.firstWhere((b) => b.code == bookCode);
      _currentBook = book;
      _selectedTestament = book.testament;
      _currentChapter = chapter.clamp(1, book.totalChapters);
      _targetVerse = verse;
      _saveCurrentPosition();
      notifyListeners();
    } catch (_) {}
  }

  void clearTargetVerse() {
    _targetVerse = null;
  }

  void goToNextChapter() {
    if (!hasNextChapter || _currentBook == null) return;
    if (_currentChapter < _currentBook!.totalChapters) {
      selectChapter(_currentChapter + 1);
    } else {
      final currentIndex = _books.indexOf(_currentBook!);
      if (currentIndex < _books.length - 1) {
        final nextBook = _books[currentIndex + 1];
        _currentBook = nextBook;
        _selectedTestament = nextBook.testament;
        selectChapter(1);
      }
    }
  }

  void goToPreviousChapter() {
    if (!hasPreviousChapter || _currentBook == null) return;
    if (_currentChapter > 1) {
      selectChapter(_currentChapter - 1);
    } else {
      final currentIndex = _books.indexOf(_currentBook!);
      if (currentIndex > 0) {
        final prevBook = _books[currentIndex - 1];
        _currentBook = prevBook;
        _selectedTestament = prevBook.testament;
        selectChapter(prevBook.totalChapters);
      }
    }
  }

  void _saveCurrentPosition() {
    if (_currentBook == null) return;
    final pos = ReadingPosition(
      bookCode: _currentBook!.code,
      bookName: _currentBook!.name,
      chapter: _currentChapter,
      verse: _targetVerse ?? 1,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
    _lastReadPosition = pos;
    _userDataRepository.saveLastRead(pos);
  }
}
