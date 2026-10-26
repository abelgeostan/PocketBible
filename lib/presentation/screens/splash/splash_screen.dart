import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/notification_service.dart';
import '../../../providers/bible_navigation_provider.dart';
import '../../../providers/theme_provider.dart';
import '../reader/reader_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static bool isActive = false;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    SplashScreen.isActive = true;
    _startApp();
  }

  @override
  void dispose() {
    SplashScreen.isActive = false;
    super.dispose();
  }

  Future<void> _startApp() async {
    final nav = context.read<BibleNavigationProvider>();

    // Give a smooth display duration so the full branding is seen
    await Future.wait([
      nav.ensureInitialized(),
      Future.delayed(const Duration(milliseconds: 1100)),
    ]);

    // One-time automatic sample daily verse notification for verification
    SharedPreferences.getInstance().then((prefs) {
      if (!(prefs.getBool('sample_verse_sent_check_v1') ?? false)) {
        prefs.setBool('sample_verse_sent_check_v1', true);
        Future.delayed(const Duration(milliseconds: 2500), () {
          NotificationService.instance.sendTestNotification(isMorning: true);
        });
      }
    });

    // Check if cold start came from a notification
    final pendingPayload = NotificationService.instance.consumePendingPayload();
    if (pendingPayload != null) {
      if (pendingPayload.startsWith('verse:')) {
        final parts = pendingPayload.split(':');
        if (parts.length >= 4) {
          final bookCode = parts[1];
          final chapter = int.tryParse(parts[2]) ?? 1;
          final verse = int.tryParse(parts[3]) ?? 1;
          nav.navigateTo(bookCode, chapter, verse: verse);
        }
      }
    }

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        settings: const RouteSettings(name: '/reader'),
        pageBuilder: (context, animation, secondaryAnimation) => const ReaderScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 250),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final bgColor = isDark ? AppColors.darkBg : AppColors.lightBg;
    final screenWidth = MediaQuery.of(context).size.width;
    final logoWidth = (screenWidth * 0.82).clamp(280.0, 380.0);

    final logoAsset = isDark
        ? 'assets/icons/pocketbible_full_logo_dark.png'
        : 'assets/icons/pocketbible_full_logo.png';

    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Image.asset(
            logoAsset,
            width: logoWidth,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
