import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../core/constants/app_constants.dart';

class ReaderSettingsProvider extends ChangeNotifier {
  double _fontSize = AppConstants.defaultFontSize;
  String _readingWidth = AppConstants.defaultReadingWidth; // 'narrow', 'normal', 'wide'
  bool _keepAwake = false;
  bool _showVerseNumbers = true;
  bool _autoOpenVerseSelector = false;
  double _lineSpacing = AppConstants.defaultLineSpacing;

  double get fontSize => _fontSize;
  String get readingWidth => _readingWidth;
  bool get keepAwake => _keepAwake;
  bool get showVerseNumbers => _showVerseNumbers;
  bool get autoOpenVerseSelector => _autoOpenVerseSelector;
  double get lineSpacing => _lineSpacing;

  EdgeInsets get readingPadding => const EdgeInsets.symmetric(horizontal: 12, vertical: 12);

  ReaderSettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _fontSize = prefs.getDouble(AppConstants.keyFontSize) ?? AppConstants.defaultFontSize;
    _readingWidth = prefs.getString(AppConstants.keyReadingWidth) ?? AppConstants.defaultReadingWidth;
    _keepAwake = prefs.getBool(AppConstants.keyKeepAwake) ?? false;
    _showVerseNumbers = prefs.getBool(AppConstants.keyShowVerseNumbers) ?? true;
    _autoOpenVerseSelector = prefs.getBool(AppConstants.keyAutoOpenVerseSelector) ?? false;
    _lineSpacing = prefs.getDouble(AppConstants.keyLineSpacing) ?? AppConstants.defaultLineSpacing;

    if (_keepAwake) {
      try {
        await WakelockPlus.enable();
      } catch (_) {}
    }
    notifyListeners();
  }

  Future<void> setFontSize(double size) async {
    _fontSize = size.clamp(AppConstants.minFontSize, AppConstants.maxFontSize);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(AppConstants.keyFontSize, _fontSize);
  }

  Future<void> increaseFontSize() async {
    await setFontSize(_fontSize + 2.0);
  }

  Future<void> decreaseFontSize() async {
    await setFontSize(_fontSize - 2.0);
  }

  Future<void> resetFontSize() async {
    await setFontSize(AppConstants.defaultFontSize);
  }

  Future<void> setReadingWidth(String width) async {
    _readingWidth = width;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyReadingWidth, width);
  }

  Future<void> setLineSpacing(double spacing) async {
    _lineSpacing = spacing;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(AppConstants.keyLineSpacing, spacing);
  }

  Future<void> toggleKeepAwake() async {
    _keepAwake = !_keepAwake;
    notifyListeners();
    try {
      if (_keepAwake) {
        await WakelockPlus.enable();
      } else {
        await WakelockPlus.disable();
      }
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyKeepAwake, _keepAwake);
  }

  Future<void> toggleShowVerseNumbers() async {
    _showVerseNumbers = !_showVerseNumbers;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyShowVerseNumbers, _showVerseNumbers);
  }

  Future<void> toggleAutoOpenVerseSelector() async {
    _autoOpenVerseSelector = !_autoOpenVerseSelector;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyAutoOpenVerseSelector, _autoOpenVerseSelector);
  }
}
