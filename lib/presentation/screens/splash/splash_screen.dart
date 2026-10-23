import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/notification_service.dart';
import '../../../providers/bible_navigation_provider.dart';
import '../../../providers/theme_provider.dart';
import '../reader/reader_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startApp();
  }

  Future<void> _startApp() async {
    final nav = context.read<BibleNavigationProvider>();
    await nav.ensureInitialized();

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
        pageBuilder: (context, animation, secondaryAnimation) => const ReaderScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 200),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final bgColor = isDark ? AppColors.darkBg : AppColors.lightBg;
    final accentColor = isDark ? AppColors.darkAccent : AppColors.lightAccent;
    final mutedColor = isDark ? AppColors.darkMuted : AppColors.lightMuted;

    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icons/pocketbible-icon-touch.png',
              width: 96,
              height: 96,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),
            RichText(
              text: TextSpan(
                text: 'PocketBible',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: accentColor,
                  fontFamily: 'Noto Sans Malayalam',
                  letterSpacing: -0.5,
                ),
                children: [
                  TextSpan(
                    text: '.in',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: mutedColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'സത്യവേദപുസ്തകം',
              style: TextStyle(
                fontSize: 14,
                color: mutedColor,
                fontFamily: 'Noto Sans Malayalam',
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
