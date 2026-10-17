import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/bible_navigation_provider.dart';
import 'providers/bookmarks_provider.dart';
import 'providers/highlights_provider.dart';
import 'providers/notes_provider.dart';
import 'providers/reader_settings_provider.dart';
import 'providers/search_provider.dart';
import 'providers/theme_provider.dart';
import 'presentation/screens/home/home_screen.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'core/constants/app_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Pre-load saved theme mode for instant matching on startup
  ThemeMode initialTheme = ThemeMode.light;
  try {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(AppConstants.keyThemeMode);
    if (savedTheme == 'dark') {
      initialTheme = ThemeMode.dark;
    } else if (savedTheme == 'system') {
      initialTheme = ThemeMode.system;
    }
  } catch (e) {
    debugPrint('Error pre-loading theme: $e');
  }

  final isDark = initialTheme == ThemeMode.dark;

  // Set initial system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider(initialMode: initialTheme)),
        ChangeNotifierProvider(create: (_) => ReaderSettingsProvider()),
        ChangeNotifierProvider(create: (_) => BibleNavigationProvider()),
        ChangeNotifierProvider(create: (_) => BookmarksProvider()),
        ChangeNotifierProvider(create: (_) => HighlightsProvider()),
        ChangeNotifierProvider(create: (_) => NotesProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
      ],
      child: const PocketBibleApp(),
    ),
  );
}

class PocketBibleApp extends StatelessWidget {
  const PocketBibleApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'PocketBible',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      home: const HomeScreen(),
    );
  }
}
