import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../providers/bible_navigation_provider.dart';
import '../../../widgets/book_picker_modal.dart';
import '../../../widgets/chapter_picker_modal.dart';
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

    final testamentLabel = nav.selectedTestament == 'OT'
        ? AppConstants.oldTestamentLabel
        : nav.selectedTestament == 'NT'
            ? AppConstants.newTestamentLabel
            : 'Testament';

    final bookLabel = nav.currentBook?.name ?? 'Select book';
    final chapterLabel = 'Chapter ${nav.currentChapter}';

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
          // Testament Selector
          Expanded(
            flex: 4,
            child: _buildSelectorButton(
              context,
              label: 'Testament',
              value: testamentLabel,
              onTap: () => _showTestamentPicker(context, nav),
              surface2Color: surface2Color,
              lineColor: lineColor,
              textColor: textColor,
              mutedColor: mutedColor,
            ),
          ),
          const SizedBox(width: 8),

          // Book Selector
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

          // Chapter Selector
          Expanded(
            flex: 4,
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
            padding: const EdgeInsets.symmetric(horizontal: 8),
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
                      fontSize: 12,
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

  Future<void> _showTestamentPicker(BuildContext context, BibleNavigationProvider nav) async {
    final chosen = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
        final accentColor = isDark ? AppColors.darkAccent : AppColors.lightAccent;

        return Container(
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'നിയമം തിരഞ്ഞെടുക്കുക',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('പഴയ നിയമം (Old Testament)'),
                trailing: nav.selectedTestament == 'OT'
                    ? Icon(Icons.check, color: accentColor)
                    : null,
                onTap: () => Navigator.pop(ctx, 'OT'),
              ),
              const Divider(height: 1),
              ListTile(
                title: const Text('പുതിയ നിയമം (New Testament)'),
                trailing: nav.selectedTestament == 'NT'
                    ? Icon(Icons.check, color: accentColor)
                    : null,
                onTap: () => Navigator.pop(ctx, 'NT'),
              ),
            ],
          ),
        );
      },
    );

    if (chosen != null && context.mounted) {
      nav.selectTestament(chosen);
      // Automatically open book selection with the chosen testament
      await _openBookAndChapterFlow(context, nav, initialTestament: chosen);
    }
  }

  Future<void> _openBookAndChapterFlow(
    BuildContext context,
    BibleNavigationProvider nav, {
    String? initialTestament,
  }) async {
    final selectedBook = await BookPickerModal.show(
      context,
      initialTestament: initialTestament ?? nav.selectedTestament,
    );

    if (selectedBook != null && context.mounted) {
      nav.selectBook(selectedBook.code);

      // Automatically go to chapter selection
      final initialChapter = (nav.currentBook?.code == selectedBook.code) ? nav.currentChapter : 1;
      final selectedChapter = await ChapterPickerModal.show(
        context,
        selectedBook,
        initialChapter,
      );

      if (selectedChapter != null && context.mounted) {
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
      nav.selectChapter(ch);
      if (navigateOnChapterSelect) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ReaderScreen()),
        );
      }
    }
  }
}
