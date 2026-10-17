import 'dart:async';
import 'package:flutter/material.dart';
import '../data/models/bible_verse.dart';
import '../data/repositories/bible_repository.dart';

class SearchProvider extends ChangeNotifier {
  final BibleRepository _repository = BibleRepository();
  Timer? _debounceTimer;

  String _query = '';
  String? _selectedTestament;
  String? _selectedBookCode;
  List<BibleVerse> _results = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  String get query => _query;
  String? get selectedTestament => _selectedTestament;
  String? get selectedBookCode => _selectedBookCode;
  List<BibleVerse> get results => _results;
  bool get isLoading => _isLoading;
  bool get hasSearched => _hasSearched;

  void onQueryChanged(String newQuery) {
    _query = newQuery;
    _debounceTimer?.cancel();

    if (_query.trim().length < 2) {
      _results = [];
      _hasSearched = false;
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _executeSearch();
    });
  }

  void setTestamentFilter(String? testament) {
    _selectedTestament = testament;
    if (_query.trim().length >= 2) {
      _executeSearch();
    } else {
      notifyListeners();
    }
  }

  void setBookFilter(String? bookCode) {
    _selectedBookCode = bookCode;
    if (_query.trim().length >= 2) {
      _executeSearch();
    } else {
      notifyListeners();
    }
  }

  void clearSearch() {
    _query = '';
    _results = [];
    _hasSearched = false;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _executeSearch() async {
    _isLoading = true;
    _hasSearched = true;
    notifyListeners();

    try {
      _results = await _repository.searchVerses(
        _query,
        testament: _selectedTestament,
        bookCode: _selectedBookCode,
        limit: 100,
      );
    } catch (_) {
      _results = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
