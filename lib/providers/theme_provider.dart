import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeProvider({ThemeMode initialMode = ThemeMode.light}) : _themeMode = initialMode {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(AppConstants.keyThemeMode);
    ThemeMode loadedMode;
    if (saved == 'dark') {
      loadedMode = ThemeMode.dark;
    } else if (saved == 'system') {
      loadedMode = ThemeMode.system;
    } else {
      loadedMode = ThemeMode.light;
    }

    if (loadedMode != _themeMode) {
      _themeMode = loadedMode;
      _updateSystemOverlay();
      notifyListeners();
    }
  }

  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.dark) {
      await setThemeMode(ThemeMode.light);
    } else {
      await setThemeMode(ThemeMode.dark);
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    _updateSystemOverlay();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    if (mode == ThemeMode.dark) {
      await prefs.setString(AppConstants.keyThemeMode, 'dark');
    } else if (mode == ThemeMode.system) {
      await prefs.setString(AppConstants.keyThemeMode, 'system');
    } else {
      await prefs.setString(AppConstants.keyThemeMode, 'light');
    }
  }

  void _updateSystemOverlay() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: _themeMode == ThemeMode.dark ? Brightness.light : Brightness.dark,
      ),
    );
  }
}
