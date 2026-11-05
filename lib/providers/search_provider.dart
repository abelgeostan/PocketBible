import 'dart:async';
import 'package:flutter/material.dart';
import '../data/models/bible_verse.dart';
import '../data/repositories/bible_repository.dart';

class SearchProvider extends ChangeNotifier {
  final BibleRepository _repository = BibleRepository();
  static const int pageSize = 50;
  Timer? _debounceTimer;

  String _query = '';
  String? _selectedTestament;
  String? _selectedBookCode;
  List<BibleVerse> _results = [];
  int _totalCount = 0;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasSearched = false;
  bool _hasMore = false;

  String get query => _query;
  String? get selectedTestament => _selectedTestament;
  String? get selectedBookCode => _selectedBookCode;
  List<BibleVerse> get results => _results;
  int get totalCount => _totalCount;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasSearched => _hasSearched;
  bool get hasMore => _hasMore;

  void onQueryChanged(String newQuery) {
    _query = newQuery;
    _debounceTimer?.cancel();

    if (_query.trim().length < 2) {
      _results = [];
      _totalCount = 0;
      _hasSearched = false;
      _isLoading = false;
      _isLoadingMore = false;
      _hasMore = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _isLoadingMore = false;
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
    _totalCount = 0;
    _hasSearched = false;
    _isLoading = false;
    _isLoadingMore = false;
    _hasMore = false;
    notifyListeners();
  }

  Future<void> _executeSearch() async {
    _isLoading = true;
    _isLoadingMore = false;
    _hasSearched = true;
    _results = [];
    _totalCount = 0;
    _hasMore = false;
    notifyListeners();

    try {
      final futures = await Future.wait([
        _repository.searchVerses(
          _query,
          testament: _selectedTestament,
          bookCode: _selectedBookCode,
          limit: pageSize,
          offset: 0,
        ),
        _repository.searchVersesCount(
          _query,
          testament: _selectedTestament,
          bookCode: _selectedBookCode,
        ),
      ]);

      _results = futures[0] as List<BibleVerse>;
      _totalCount = futures[1] as int;
      _hasMore = _results.length < _totalCount;
    } catch (_) {
      _results = [];
      _totalCount = 0;
      _hasMore = false;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (_isLoading || _isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final moreVerses = await _repository.searchVerses(
        _query,
        testament: _selectedTestament,
        bookCode: _selectedBookCode,
        limit: pageSize,
        offset: _results.length,
      );

      _results.addAll(moreVerses);
      _hasMore = moreVerses.length >= pageSize && _results.length < _totalCount;
    } catch (_) {
      // Keep existing results
    }

    _isLoadingMore = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
