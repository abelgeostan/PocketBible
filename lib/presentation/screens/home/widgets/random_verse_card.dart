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
        borderRadius: BorderRadius.circular(14),
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
          Text(
            AppConstants.randomVerseKicker,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: accentColor,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            AppConstants.randomVerseTitle,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Find an inspirational verse from anywhere in the Holy Bible.',
            style: TextStyle(
              fontSize: 14,
              color: mutedColor,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: surface2Color,
              foregroundColor: textColor,
              elevation: 0,
              side: BorderSide(color: lineColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            icon: const Text('🎲', style: TextStyle(fontSize: 16)),
            label: Text(
              'Random Verse',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            onPressed: () async {
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
          ),
        ],
      ),
    );
  }
}
