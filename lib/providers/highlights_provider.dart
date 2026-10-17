import 'package:flutter/material.dart';
import '../data/models/highlight_item.dart';
import '../data/repositories/user_data_repository.dart';

class HighlightsProvider extends ChangeNotifier {
  final UserDataRepository _repository = UserDataRepository();
  List<HighlightItem> _highlights = [];
  bool _isLoading = false;

  List<HighlightItem> get highlights => _highlights;
  int get count => _highlights.length;
  bool get isLoading => _isLoading;

  HighlightsProvider() {
    loadHighlights();
  }

  Future<void> loadHighlights() async {
    _isLoading = true;
    notifyListeners();
    _highlights = await _repository.getHighlights();
    _isLoading = false;
    notifyListeners();
  }

  String? getHighlightColor(String bookCode, int chapter, int verse) {
    try {
      final h = _highlights.firstWhere(
        (h) => h.bookCode == bookCode && h.chapter == chapter && h.verse == verse,
      );
      return h.color;
    } catch (_) {
      return null;
    }
  }

  Future<void> setHighlight({
    required String bookCode,
    String? bookName,
    required int chapter,
    required int verse,
    required String color,
    String? text,
  }) async {
    final item = HighlightItem(
      bookCode: bookCode,
      bookName: bookName,
      chapter: chapter,
      verse: verse,
      color: color,
      text: text,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    await _repository.setHighlight(item);
    _highlights.removeWhere(
      (h) => h.bookCode == bookCode && h.chapter == chapter && h.verse == verse,
    );
    _highlights.insert(0, item);
    notifyListeners();
  }

  Future<void> removeHighlight(String bookCode, int chapter, int verse) async {
    await _repository.removeHighlight(bookCode, chapter, verse);
    _highlights.removeWhere(
      (h) => h.bookCode == bookCode && h.chapter == chapter && h.verse == verse,
    );
    notifyListeners();
  }
}
