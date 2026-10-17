import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/bible_book.dart';

class ChapterPickerModal extends StatelessWidget {
  final BibleBook book;
  final int currentChapter;
  final Function(int chapter) onChapterSelected;

  const ChapterPickerModal({
    super.key,
    required this.book,
    required this.currentChapter,
    required this.onChapterSelected,
  });

  static Future<int?> show(BuildContext context, BibleBook book, int currentChapter) {
    return showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ChapterPickerModal(
        book: book,
        currentChapter: currentChapter,
        onChapterSelected: (ch) => Navigator.pop(ctx, ch),
      ),
    );
  }

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
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, -5)),
        ],
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: lineColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    Text(
                      'അധ്യായം തിരഞ്ഞെടുക്കുക (${book.totalChapters} അധ്യായങ്ങൾ)',
                      style: TextStyle(fontSize: 12, color: mutedColor),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  color: mutedColor,
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Chapter Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.1,
              ),
              itemCount: book.totalChapters,
              itemBuilder: (context, index) {
                final chapterNum = index + 1;
                final isSelected = chapterNum == currentChapter;

                return InkWell(
                  onTap: () => onChapterSelected(chapterNum),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? accentColor : surface2Color,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? accentColor : lineColor,
                        width: 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$chapterNum',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? AppColors.darkText : AppColors.lightText),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
