import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../providers/bible_navigation_provider.dart';
import '../../../../providers/reader_settings_provider.dart';
import '../../../widgets/book_picker_modal.dart';
import '../../../widgets/chapter_picker_modal.dart';
import '../../../widgets/verse_picker_modal.dart';
import '../../reader/reader_screen.dart';

class ExploreTestamentsCard extends StatelessWidget {
  const ExploreTestamentsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final lineColor = isDark ? AppColors.darkLine : AppColors.lightLine;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final mutedColor = isDark ? AppColors.darkMuted : AppColors.lightMuted;
    final accentColor = isDark ? AppColors.darkAccent : AppColors.lightAccent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.library_books_rounded, size: 18, color: accentColor),
            const SizedBox(width: 8),
            Text(
              'Explore Scriptures',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            const Spacer(),
            Text(
              '66 Books',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: mutedColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // Old Testament
            Expanded(
              child: _buildTestamentCard(
                context,
                title: 'പഴയ നിയമം',
                englishTitle: 'Old Testament',
                count: '39 Books',
                range: 'ഉല്പത്തി - മലാഖി',
                testamentKey: 'OT',
                surfaceColor: surfaceColor,
                lineColor: lineColor,
                textColor: textColor,
                mutedColor: mutedColor,
                accentColor: accentColor,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            // New Testament
            Expanded(
              child: _buildTestamentCard(
                context,
                title: 'പുതിയ നിയമം',
                englishTitle: 'New Testament',
                count: '27 Books',
                range: 'മത്തായി - വെളിപ്പാടു',
                testamentKey: 'NT',
                surfaceColor: surfaceColor,
                lineColor: lineColor,
                textColor: textColor,
                mutedColor: mutedColor,
                accentColor: accentColor,
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTestamentCard(
    BuildContext context, {
    required String title,
    required String englishTitle,
    required String count,
    required String range,
    required String testamentKey,
    required Color surfaceColor,
    required Color lineColor,
    required Color textColor,
    required Color mutedColor,
    required Color accentColor,
    required bool isDark,
  }) {
    return InkWell(
      onTap: () async {
        final nav = context.read<BibleNavigationProvider>();
        final book = await BookPickerModal.show(context, initialTestament: testamentKey);
        if (book != null && context.mounted) {
          final chapter = await ChapterPickerModal.show(
            context,
            book,
            1,
          );
          if (chapter != null && context.mounted) {
            final autoOpenVerse = context.read<ReaderSettingsProvider>().autoOpenVerseSelector;
            int? verse;
            if (autoOpenVerse) {
              verse = await VersePickerModal.show(
                context,
                book: book,
                chapter: chapter,
                currentVerse: 1,
              );
            }
            if (context.mounted) {
              nav.navigateTo(book.code, chapter, verse: verse);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ReaderScreen()),
              );
            }
          }
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: lineColor),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black26 : const Color.fromRGBO(20, 30, 40, 0.05),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    count,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: accentColor,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 13,
                  color: mutedColor,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              englishTitle,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: mutedColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              range,
              style: TextStyle(
                fontSize: 11,
                color: textColor.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
