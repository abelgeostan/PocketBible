import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../providers/bible_navigation_provider.dart';
import '../../../providers/highlights_provider.dart';
import '../../widgets/toast_notification.dart';
import '../reader/reader_screen.dart';

class HighlightsScreen extends StatefulWidget {
  const HighlightsScreen({super.key});

  @override
  State<HighlightsScreen> createState() => _HighlightsScreenState();
}

class _HighlightsScreenState extends State<HighlightsScreen> {
  String? _selectedColor; // null means all colors

  @override
  Widget build(BuildContext context) {
    final highlights = context.watch<HighlightsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final accentColor = isDark ? AppColors.darkAccent : AppColors.lightAccent;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final mutedColor = isDark ? AppColors.darkMuted : AppColors.lightMuted;
    final lineColor = isDark ? AppColors.darkLine : AppColors.lightLine;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;

    final filteredList = highlights.highlights.where((h) {
      if (_selectedColor == null) return true;
      return h.color.toLowerCase() == _selectedColor!.toLowerCase();
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('${AppConstants.highlightsTitle} (${highlights.count})'),
      ),
      body: Column(
        children: [
          // Filter Chips by Color
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                _buildColorFilterChip('All', null, isDark, accentColor, lineColor, surfaceColor, textColor),
                const SizedBox(width: 8),
                _buildColorFilterChip('Yellow', 'yellow', isDark, accentColor, lineColor, surfaceColor, textColor),
                const SizedBox(width: 8),
                _buildColorFilterChip('Green', 'green', isDark, accentColor, lineColor, surfaceColor, textColor),
                const SizedBox(width: 8),
                _buildColorFilterChip('Blue', 'blue', isDark, accentColor, lineColor, surfaceColor, textColor),
                const SizedBox(width: 8),
                _buildColorFilterChip('Pink', 'pink', isDark, accentColor, lineColor, surfaceColor, textColor),
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: highlights.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.format_color_fill, size: 54, color: mutedColor.withOpacity(0.5)),
                            const SizedBox(height: 12),
                            Text(
                              'ഹൈലൈറ്റുകൾ ഇല്ല.',
                              style: TextStyle(fontSize: 16, color: mutedColor),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: filteredList.length,
                        separatorBuilder: (_, __) => Divider(height: 1, color: lineColor),
                        itemBuilder: (context, index) {
                          final item = filteredList[index];
                          final badgeColor = AppColors.getHighlightColor(item.color, isDark);

                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            leading: Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: badgeColor,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.black26),
                              ),
                            ),
                            title: Text(
                              item.reference,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: accentColor,
                              ),
                            ),
                            subtitle: item.text != null
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      item.text!,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 13, color: textColor, height: 1.5),
                                    ),
                                  )
                                : null,
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, size: 20),
                              color: mutedColor,
                              tooltip: 'Remove highlight',
                              onPressed: () {
                                highlights.removeHighlight(item.bookCode, item.chapter, item.verse);
                                ToastNotification.show(context, 'Highlight removed');
                              },
                            ),
                            onTap: () {
                              final nav = context.read<BibleNavigationProvider>();
                              nav.navigateTo(item.bookCode, item.chapter, verse: item.verse);
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const ReaderScreen()),
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorFilterChip(
    String label,
    String? colorKey,
    bool isDark,
    Color accentColor,
    Color lineColor,
    Color surfaceColor,
    Color textColor,
  ) {
    final isSelected = _selectedColor == colorKey;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedColor = colorKey),
      selectedColor: accentColor.withOpacity(0.15),
      backgroundColor: surfaceColor,
      side: BorderSide(color: isSelected ? accentColor : lineColor),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected ? accentColor : textColor,
      ),
    );
  }
}
