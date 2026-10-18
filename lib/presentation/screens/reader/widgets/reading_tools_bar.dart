import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../providers/bookmarks_provider.dart';
import '../../../../providers/reader_settings_provider.dart';
import '../../bookmarks/bookmarks_screen.dart';

class ReadingToolsBar extends StatelessWidget {
  final VoidCallback onCopyChapter;

  const ReadingToolsBar({
    super.key,
    required this.onCopyChapter,
  });

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<ReaderSettingsProvider>();
    final bookmarksCount = context.watch<BookmarksProvider>().count;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final surface2Color = isDark ? AppColors.darkSurface2 : AppColors.lightSurface2;
    final lineColor = isDark ? AppColors.darkLine : AppColors.lightLine;
    final accentColor = isDark ? AppColors.darkAccent : AppColors.lightAccent;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final mutedColor = isDark ? AppColors.darkMuted : AppColors.lightMuted;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Text Size Group
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Text',
                style: TextStyle(fontSize: 12, color: mutedColor, fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 6),
              _buildToolButton(
                label: 'A−',
                isActive: settings.fontSize < 18,
                onTap: () => settings.decreaseFontSize(),
                surfaceColor: surfaceColor,
                surface2Color: surface2Color,
                lineColor: lineColor,
                accentColor: accentColor,
                textColor: textColor,
              ),
              const SizedBox(width: 4),
              _buildToolButton(
                label: 'A',
                isActive: settings.fontSize == 18,
                onTap: () => settings.resetFontSize(),
                surfaceColor: surfaceColor,
                surface2Color: surface2Color,
                lineColor: lineColor,
                accentColor: accentColor,
                textColor: textColor,
              ),
              const SizedBox(width: 4),
              _buildToolButton(
                label: 'A+',
                isActive: settings.fontSize > 18,
                onTap: () => settings.increaseFontSize(),
                surfaceColor: surfaceColor,
                surface2Color: surface2Color,
                lineColor: lineColor,
                accentColor: accentColor,
                textColor: textColor,
              ),
            ],
          ),


          const SizedBox(width: 14),

          // Copy Chapter Button
          _buildToolButton(
            icon: Icons.copy_rounded,
            label: 'Copy chapter',
            isActive: false,
            onTap: onCopyChapter,
            surfaceColor: surfaceColor,
            surface2Color: surface2Color,
            lineColor: lineColor,
            accentColor: accentColor,
            textColor: textColor,
          ),

          const SizedBox(width: 6),

          // Bookmarks Button
          _buildToolButton(
            label: '🔖 $bookmarksCount',
            isActive: false,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BookmarksScreen()),
              );
            },
            surfaceColor: surfaceColor,
            surface2Color: surface2Color,
            lineColor: lineColor,
            accentColor: accentColor,
            textColor: textColor,
          ),
        ],
      ),
    );
  }

  Widget _buildToolButton({
    required String label,
    IconData? icon,
    required bool isActive,
    required VoidCallback onTap,
    required Color surfaceColor,
    required Color surface2Color,
    required Color lineColor,
    required Color accentColor,
    required Color textColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? surface2Color : surfaceColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? accentColor : lineColor,
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 13,
                color: isActive ? accentColor : textColor,
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? accentColor : textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
