import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../providers/bible_navigation_provider.dart';
import '../../../widgets/book_picker_modal.dart';
import '../../../widgets/chapter_picker_modal.dart';
import '../../bookmarks/bookmarks_screen.dart';
import '../../history/history_screen.dart';
import '../../reader/reader_screen.dart';
import '../../search/search_screen.dart';

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final lineColor = isDark ? AppColors.darkLine : AppColors.lightLine;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final accentColor = isDark ? AppColors.darkAccent : AppColors.lightAccent;

    return Row(
      children: [
        // 1. All Books
        Expanded(
          child: _buildActionItem(
            context,
            icon: Icons.menu_book_rounded,
            label: 'Books',
            subLabel: 'പുസ്തകങ്ങൾ',
            surfaceColor: surfaceColor,
            lineColor: lineColor,
            textColor: textColor,
            accentColor: accentColor,
            isDark: isDark,
            onTap: () async {
              final nav = context.read<BibleNavigationProvider>();
              final book = await BookPickerModal.show(context);
              if (book != null && context.mounted) {
                final chapter = await ChapterPickerModal.show(
                  context,
                  book,
                  1,
                );
                if (chapter != null && context.mounted) {
                  nav.navigateTo(book.code, chapter);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ReaderScreen()),
                  );
                }
              }
            },
          ),
        ),
        const SizedBox(width: 8),

        // 2. Search
        Expanded(
          child: _buildActionItem(
            context,
            icon: Icons.search_rounded,
            label: 'Search',
            subLabel: 'തിരയുക',
            surfaceColor: surfaceColor,
            lineColor: lineColor,
            textColor: textColor,
            accentColor: accentColor,
            isDark: isDark,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
            },
          ),
        ),
        const SizedBox(width: 8),

        // 3. Bookmarks
        Expanded(
          child: _buildActionItem(
            context,
            icon: Icons.bookmark_border_rounded,
            label: 'Saved',
            subLabel: 'സൂചിക',
            surfaceColor: surfaceColor,
            lineColor: lineColor,
            textColor: textColor,
            accentColor: accentColor,
            isDark: isDark,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BookmarksScreen()),
              );
            },
          ),
        ),
        const SizedBox(width: 8),

        // 4. History
        Expanded(
          child: _buildActionItem(
            context,
            icon: Icons.history_rounded,
            label: 'History',
            subLabel: 'ചരിത്രം',
            surfaceColor: surfaceColor,
            lineColor: lineColor,
            textColor: textColor,
            accentColor: accentColor,
            isDark: isDark,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryScreen()),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String subLabel,
    required Color surfaceColor,
    required Color lineColor,
    required Color textColor,
    required Color accentColor,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: lineColor),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black26 : const Color.fromRGBO(20, 30, 40, 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: accentColor,
                size: 20,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              subLabel,
              style: TextStyle(
                fontSize: 10,
                color: textColor.withValues(alpha: 0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
