import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../providers/bible_navigation_provider.dart';
import '../../../widgets/book_picker_modal.dart';
import '../../../widgets/chapter_picker_modal.dart';
import '../../../widgets/verse_picker_modal.dart';
import '../../reader/reader_screen.dart';

class StickySelectorBar extends StatelessWidget {
  final bool navigateOnChapterSelect;

  const StickySelectorBar({
    super.key,
    this.navigateOnChapterSelect = true,
  });

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<BibleNavigationProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final surface2Color = isDark ? AppColors.darkSurface2 : AppColors.lightSurface2;
    final lineColor = isDark ? AppColors.darkLine : AppColors.lightLine;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final mutedColor = isDark ? AppColors.darkMuted : AppColors.lightMuted;

    final bookLabel = nav.currentBook?.name ?? 'Select book';
    final chapterLabel = '${nav.currentChapter}';
    final verseLabel = '${nav.targetVerse ?? 1}';

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: lineColor),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black38 : const Color.fromRGBO(20, 30, 40, 0.08),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // 1. Book Selector
          Expanded(
            flex: 5,
            child: _buildSelectorButton(
              context,
              label: 'Book',
              value: bookLabel,
              onTap: () => _openBookAndChapterFlow(context, nav),
              surface2Color: surface2Color,
              lineColor: lineColor,
              textColor: textColor,
              mutedColor: mutedColor,
            ),
          ),
          const SizedBox(width: 8),

          // 2. Chapter Selector
          Expanded(
            flex: 3,
            child: _buildSelectorButton(
              context,
              label: 'Chapter',
              value: chapterLabel,
              onTap: () => _openChapterPicker(context, nav),
              surface2Color: surface2Color,
              lineColor: lineColor,
              textColor: textColor,
              mutedColor: mutedColor,
            ),
          ),
          const SizedBox(width: 8),

          // 3. Verse Selector
          Expanded(
            flex: 3,
            child: _buildSelectorButton(
              context,
              label: 'Verse',
              value: verseLabel,
              onTap: () => _openVersePicker(context, nav),
              surface2Color: surface2Color,
              lineColor: lineColor,
              textColor: textColor,
              mutedColor: mutedColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectorButton(
    BuildContext context, {
    required String label,
    required String value,
    required VoidCallback onTap,
    required Color surface2Color,
    required Color lineColor,
    required Color textColor,
    required Color mutedColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 3, bottom: 4),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: mutedColor,
              letterSpacing: 0.2,
            ),
          ),
        ),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(9),
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: surface2Color,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: lineColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ),
                Icon(Icons.keyboard_arrow_down, size: 16, color: mutedColor),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openBookAndChapterFlow(
    BuildContext context,
    BibleNavigationProvider nav,
  ) async {
    final selectedBook = await BookPickerModal.show(context);

    if (selectedBook != null && context.mounted) {
      nav.selectBook(selectedBook.code);

      // Automatically open chapter picker after book is selected
      final initialChapter = (nav.currentBook?.code == selectedBook.code) ? nav.currentChapter : 1;
      final selectedChapter = await ChapterPickerModal.show(
        context,
        selectedBook,
        initialChapter,
      );

      if (selectedChapter != null && context.mounted) {
        // Go straight to verse 1 without highlighting verse 1
        nav.selectChapter(selectedChapter);
        if (navigateOnChapterSelect) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ReaderScreen()),
          );
        }
      }
    }
  }

  Future<void> _openChapterPicker(
    BuildContext context,
    BibleNavigationProvider nav,
  ) async {
    if (nav.currentBook == null) return;
    final ch = await ChapterPickerModal.show(
      context,
      nav.currentBook!,
      nav.currentChapter,
    );
    if (ch != null && context.mounted) {
      // Go straight to verse 1 without highlighting verse 1
      nav.selectChapter(ch);
      if (navigateOnChapterSelect) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ReaderScreen()),
        );
      }
    }
  }

  Future<void> _openVersePicker(
    BuildContext context,
    BibleNavigationProvider nav,
  ) async {
    if (nav.currentBook == null) return;
    final selectedVerse = await VersePickerModal.show(
      context,
      book: nav.currentBook!,
      chapter: nav.currentChapter,
      currentVerse: nav.targetVerse ?? 1,
    );
    if (selectedVerse != null && context.mounted) {
      nav.selectVerse(selectedVerse);
      if (navigateOnChapterSelect) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ReaderScreen()),
        );
      }
    }
  }
}
