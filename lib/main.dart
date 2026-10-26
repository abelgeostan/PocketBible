import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/constants/app_constants.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/reader/reader_screen.dart';
import 'presentation/screens/splash/splash_screen.dart';
import 'providers/bible_navigation_provider.dart';
import 'providers/bookmarks_provider.dart';
import 'providers/highlights_provider.dart';
import 'providers/notes_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/reader_settings_provider.dart';
import 'providers/search_provider.dart';
import 'providers/theme_provider.dart';

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

Future<void> _handleNotificationPayload(String payload) async {
  BuildContext? navContext = appNavigatorKey.currentContext;
  int retries = 0;
  while (navContext == null && retries < 30) {
    await Future.delayed(const Duration(milliseconds: 50));
    navContext = appNavigatorKey.currentContext;
    retries++;
  }

  if (navContext == null) return;

  final nav = navContext.read<BibleNavigationProvider>();
  await nav.ensureInitialized();

  if (payload.startsWith('verse:')) {
    final parts = payload.split(':');
    if (parts.length >= 4) {
      final bookCode = parts[1];
      final chapter = int.tryParse(parts[2]) ?? 1;
      final verse = int.tryParse(parts[3]) ?? 1;
      nav.navigateTo(bookCode, chapter, verse: verse);
    }
  }

  // If ReaderScreen is already active, close any open modal/dialog/sheet
  if (ReaderScreen.isActive) {
    appNavigatorKey.currentState?.popUntil(
      (route) => route.settings.name == '/reader' || route.isFirst,
    );
  } else if (!SplashScreen.isActive) {
    // If not already on ReaderScreen and not on SplashScreen, navigate to ReaderScreen
    appNavigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => const ReaderScreen(),
        settings: const RouteSettings(name: '/reader'),
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notification service & tap handlers
  await NotificationService.instance.initialize(
    onNotificationTap: (payload) {
      _handleNotificationPayload(payload);
    },
  );

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
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
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
      navigatorKey: appNavigatorKey,
      title: 'PocketBible',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      home: const SplashScreen(),
    );
  }
}
