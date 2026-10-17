import 'package:flutter/material.dart';
import '../data/models/bookmark_item.dart';
import '../data/repositories/user_data_repository.dart';

class BookmarksProvider extends ChangeNotifier {
  final UserDataRepository _repository = UserDataRepository();
  List<BookmarkItem> _bookmarks = [];
  bool _isLoading = false;

  List<BookmarkItem> get bookmarks => _bookmarks;
  int get count => _bookmarks.length;
  bool get isLoading => _isLoading;

  BookmarksProvider() {
    loadBookmarks();
  }

  Future<void> loadBookmarks() async {
    _isLoading = true;
    notifyListeners();
    _bookmarks = await _repository.getBookmarks();
    _isLoading = false;
    notifyListeners();
  }

  bool isBookmarked(String bookCode, int chapter, int verse) {
    return _bookmarks.any((b) => b.bookCode == bookCode && b.chapter == chapter && b.verse == verse);
  }

  Future<bool> toggleBookmark({
    required String bookCode,
    required String bookName,
    required int chapter,
    required int verse,
    required String text,
  }) async {
    final existingIndex = _bookmarks.indexWhere(
      (b) => b.bookCode == bookCode && b.chapter == chapter && b.verse == verse,
    );

    if (existingIndex >= 0) {
      await _repository.removeBookmark(bookCode, chapter, verse);
      _bookmarks.removeAt(existingIndex);
      notifyListeners();
      return false; // Removed
    } else {
      final item = BookmarkItem(
        bookCode: bookCode,
        bookName: bookName,
        chapter: chapter,
        verse: verse,
        text: text,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );
      await _repository.addBookmark(item);
      _bookmarks.insert(0, item);
      notifyListeners();
      return true; // Added
    }
  }

  Future<void> removeBookmark(String bookCode, int chapter, int verse) async {
    await _repository.removeBookmark(bookCode, chapter, verse);
    _bookmarks.removeWhere((b) => b.bookCode == bookCode && b.chapter == chapter && b.verse == verse);
    notifyListeners();
  }
}
