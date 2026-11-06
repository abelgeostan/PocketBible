import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/bible_verse.dart';
import '../../../providers/bible_navigation_provider.dart';
import '../../../providers/search_provider.dart';
import '../reader/reader_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final search = context.watch<SearchProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final surface2Color = isDark ? AppColors.darkSurface2 : AppColors.lightSurface2;
    final lineColor = isDark ? AppColors.darkLine : AppColors.lightLine;
    final accentColor = isDark ? AppColors.darkAccent : AppColors.lightAccent;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final mutedColor = isDark ? AppColors.darkMuted : AppColors.lightMuted;

    return Scaffold(
      appBar: AppBar(
        title: const Text('വേദപുസ്തകത്തിൽ തിരയുക (Search)'),
      ),
      body: Column(
        children: [
          // Search Input Box
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _controller,
              autofocus: true,
              onChanged: search.onQueryChanged,
              decoration: InputDecoration(
                hintText: AppConstants.searchPlaceholder,
                prefixIcon: Icon(Icons.search, color: accentColor),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          _controller.clear();
                          search.clearSearch();
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'എല്ലാം (All)',
                  isSelected: search.selectedTestament == null,
                  onSelected: () => search.setTestamentFilter(null),
                  accentColor: accentColor,
                  lineColor: lineColor,
                  surfaceColor: surfaceColor,
                  textColor: textColor,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: AppConstants.oldTestamentLabel,
                  isSelected: search.selectedTestament == 'OT',
                  onSelected: () => search.setTestamentFilter('OT'),
                  accentColor: accentColor,
                  lineColor: lineColor,
                  surfaceColor: surfaceColor,
                  textColor: textColor,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: AppConstants.newTestamentLabel,
                  isSelected: search.selectedTestament == 'NT',
                  onSelected: () => search.setTestamentFilter('NT'),
                  accentColor: accentColor,
                  lineColor: lineColor,
                  surfaceColor: surfaceColor,
                  textColor: textColor,
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),

          // Results List
          Expanded(
            child: _buildResultsView(search, isDark, textColor, mutedColor, accentColor, surface2Color, lineColor),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
    required Color accentColor,
    required Color lineColor,
    required Color surfaceColor,
    required Color textColor,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      selectedColor: accentColor.withValues(alpha: 0.15),
      backgroundColor: surfaceColor,
      side: BorderSide(color: isSelected ? accentColor : lineColor),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected ? accentColor : textColor,
      ),
    );
  }

  Widget _buildResultsView(
    SearchProvider search,
    bool isDark,
    Color textColor,
    Color mutedColor,
    Color accentColor,
    Color surface2Color,
    Color lineColor,
  ) {
    if (search.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!search.hasSearched) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search, size: 52, color: mutedColor.withValues(alpha: 0.5)),
              const SizedBox(height: 16),
              Text(
                'തിരയാൻ മലയാളത്തിൽ വാക്ക് നൽകുക',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Type Malayalam words to search the Bible',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: mutedColor,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (search.results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off_rounded, size: 52, color: mutedColor.withValues(alpha: 0.5)),
              const SizedBox(height: 14),
              Text(
                'ഫലം കണ്ടെത്തിയില്ല',
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'No results found for "${search.query}"',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: mutedColor,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final showFooter = search.hasMore || (search.results.isNotEmpty && search.totalCount > SearchProvider.pageSize);
    final totalItems = search.results.length + (showFooter ? 1 : 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Summary header showing match counts
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: surface2Color.withValues(alpha: 0.4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                search.hasMore
                    ? '${search.results.length} of ${search.totalCount} results (${search.results.length} / ${search.totalCount} ഫലങ്ങൾ)'
                    : 'Total ${search.totalCount} results (ആകെ ${search.totalCount} ഫലങ്ങൾ)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: mutedColor,
                ),
              ),
              if (search.hasMore)
                Text(
                  '+${search.totalCount - search.results.length} more (ബാക്കി)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: accentColor,
                  ),
                ),
            ],
          ),
        ),
        Divider(height: 1, color: lineColor),

        // Verses list with Show More button at the bottom
        Expanded(
          child: ListView.separated(
            itemCount: totalItems,
            separatorBuilder: (_, __) => Divider(height: 1, color: lineColor),
            itemBuilder: (context, index) {
              if (index < search.results.length) {
                final verse = search.results[index];
                return _buildResultTile(context, verse, search.query, isDark, textColor, mutedColor, accentColor);
              }

              // Footer: Show More button or End of Results
              if (search.hasMore) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Center(
                    child: search.isLoadingMore
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: accentColor,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'കൂടുതൽ ഫലങ്ങൾ ലോഡ് ചെയ്യുന്നു... (Loading more...)',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: mutedColor,
                                ),
                              ),
                            ],
                          )
                        : OutlinedButton.icon(
                            onPressed: () => search.loadMore(),
                            icon: Icon(Icons.expand_more_rounded, size: 20, color: accentColor),
                            label: Text(
                              'കൂടുതൽ ഫലങ്ങൾ കാണുക (Show More)',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: accentColor,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              side: BorderSide(color: accentColor.withValues(alpha: 0.5)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                              backgroundColor: surface2Color,
                            ),
                          ),
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    'എല്ലാ ഫലങ്ങളും കാണിച്ചു • All ${search.totalCount} results shown',
                    style: TextStyle(
                      fontSize: 12,
                      color: mutedColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildResultTile(
    BuildContext context,
    BibleVerse verse,
    String query,
    bool isDark,
    Color textColor,
    Color mutedColor,
    Color accentColor,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      title: Text(
        '${verse.bookName ?? verse.bookCode} ${verse.chapter}:${verse.verse}',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: accentColor,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: _buildHighlightedText(verse.text, query, isDark, textColor),
      ),
      onTap: () {
        final nav = context.read<BibleNavigationProvider>();
        nav.navigateTo(verse.bookCode, verse.chapter, verse: verse.verse);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ReaderScreen()),
        );
      },
    );
  }

  Widget _buildHighlightedText(String text, String query, bool isDark, Color textColor) {
    final terms = query.toLowerCase().split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();
    if (terms.isEmpty) {
      return Text(
        text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 13, height: 1.5, color: textColor),
      );
    }

    final spans = <TextSpan>[];
    final pattern = RegExp('(${terms.map(RegExp.escape).join('|')})', caseSensitive: false);
    final matches = pattern.allMatches(text);

    int lastIndex = 0;
    for (final match in matches) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(text: text.substring(lastIndex, match.start)));
      }
      spans.add(
        TextSpan(
          text: text.substring(match.start, match.end),
          style: TextStyle(
            backgroundColor: isDark ? AppColors.searchHitDark : AppColors.searchHitLight,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.add(TextSpan(text: text.substring(lastIndex)));
    }

    return RichText(
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: TextStyle(
          fontSize: 13,
          height: 1.5,
          color: textColor,
          fontFamily: 'Noto Sans Malayalam',
        ),
        children: spans,
      ),
    );
  }
}
