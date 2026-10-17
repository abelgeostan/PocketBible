import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../data/repositories/bible_repository.dart';
import '../../../../providers/bible_navigation_provider.dart';
import '../../reader/reader_screen.dart';

class RandomVerseCard extends StatelessWidget {
  const RandomVerseCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final surface2Color = isDark ? AppColors.darkSurface2 : AppColors.lightSurface2;
    final lineColor = isDark ? AppColors.darkLine : AppColors.lightLine;
    final accentColor = isDark ? AppColors.darkAccent : AppColors.lightAccent;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final mutedColor = isDark ? AppColors.darkMuted : AppColors.lightMuted;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: lineColor),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : const Color.fromRGBO(20, 30, 40, 0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🎲', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 5),
                Text(
                  AppConstants.randomVerseKicker,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: accentColor,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            AppConstants.randomVerseTitle,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Find an inspirational verse chosen at random from Holy Scripture.',
            style: TextStyle(
              fontSize: 13,
              color: mutedColor,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          InkWell(
            onTap: () async {
              final repo = BibleRepository();
              final ref = await repo.getRandomVerseRef();
              if (ref != null && context.mounted) {
                final nav = context.read<BibleNavigationProvider>();
                nav.navigateTo(ref['c'] as String, ref['ch'] as int, verse: ref['v'] as int);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ReaderScreen()),
                );
              }
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: surface2Color,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: lineColor),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.casino_outlined, size: 18, color: accentColor),
                  const SizedBox(width: 8),
                  Text(
                    'Get Random Verse',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
