import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/bible_book.dart';
import '../../providers/bible_navigation_provider.dart';

class BookPickerModal extends StatefulWidget {
  final Function(BibleBook book) onBookSelected;
  final String? initialTestament;

  const BookPickerModal({
    super.key,
    required this.onBookSelected,
    this.initialTestament,
  });

  static Future<BibleBook?> show(BuildContext context, {String? initialTestament}) {
    return showModalBottomSheet<BibleBook>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BookPickerModal(
        initialTestament: initialTestament,
        onBookSelected: (book) => Navigator.pop(ctx, book),
      ),
    );
  }

  @override
  State<BookPickerModal> createState() => _BookPickerModalState();
}

class _BookPickerModalState extends State<BookPickerModal> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchFilter = '';

  @override
  void initState() {
    super.initState();
    int initialIndex = 0;
    if (widget.initialTestament == 'OT') {
      initialIndex = 1;
    } else if (widget.initialTestament == 'NT') {
      initialIndex = 2;
    }
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: initialIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<BibleNavigationProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final lineColor = isDark ? AppColors.darkLine : AppColors.lightLine;
    final accentColor = isDark ? AppColors.darkAccent : AppColors.lightAccent;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final mutedColor = isDark ? AppColors.darkMuted : AppColors.lightMuted;

    final allBooks = nav.books.where((b) {
      if (_searchFilter.isEmpty) return true;
      return b.name.toLowerCase().contains(_searchFilter.toLowerCase()) ||
          b.code.toLowerCase().contains(_searchFilter.toLowerCase());
    }).toList();

    final otBooks = allBooks.where((b) => b.isOldTestament).toList();
    final ntBooks = allBooks.where((b) => b.isNewTestament).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
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

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'പുസ്തകം തിരഞ്ഞെടുക്കുക',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  color: mutedColor,
                ),
              ],
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchFilter = val.trim()),
              decoration: InputDecoration(
                hintText: 'പുസ്തകം തിരയുക...',
                prefixIcon: Icon(Icons.search, color: mutedColor, size: 20),
                suffixIcon: _searchFilter.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchFilter = '');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
            ),
          ),

          // Tabs
          TabBar(
            controller: _tabController,
            indicatorColor: accentColor,
            labelColor: accentColor,
            unselectedLabelColor: mutedColor,
            labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            tabs: const [
              Tab(text: 'എല്ലാം (66)'),
              Tab(text: 'പഴയ നിയമം (39)'),
              Tab(text: 'പുതിയ നിയമം (27)'),
            ],
          ),

          const Divider(height: 1),

          // Tab views with books list
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBookList(allBooks, nav.currentBook?.code, isDark),
                _buildBookList(otBooks, nav.currentBook?.code, isDark),
                _buildBookList(ntBooks, nav.currentBook?.code, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookList(List<BibleBook> booksList, String? currentCode, bool isDark) {
    if (booksList.isEmpty) {
      return Center(
        child: Text(
          'പുസ്തകം കണ്ടെത്തിയില്ല',
          style: TextStyle(
            color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
            fontSize: 14,
          ),
        ),
      );
    }

    final accentColor = isDark ? AppColors.darkAccent : AppColors.lightAccent;
    final surface2Color = isDark ? AppColors.darkSurface2 : AppColors.lightSurface2;
    final lineColor = isDark ? AppColors.darkLine : AppColors.lightLine;

    return ListView.separated(
      itemCount: booksList.length,
      separatorBuilder: (_, __) => Divider(height: 1, color: lineColor.withOpacity(0.5)),
      itemBuilder: (context, index) {
        final book = booksList[index];
        final isSelected = book.code == currentCode;

        return ListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
          tileColor: isSelected ? surface2Color : null,
          title: Text(
            book.name,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? accentColor : (isDark ? AppColors.darkText : AppColors.lightText),
              fontSize: 15,
            ),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isSelected ? accentColor.withOpacity(0.15) : surface2Color,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: lineColor),
            ),
            child: Text(
              '${book.totalChapters} അധ്യായങ്ങൾ',
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? accentColor : (isDark ? AppColors.darkMuted : AppColors.lightMuted),
              ),
            ),
          ),
          onTap: () => widget.onBookSelected(book),
        );
      },
    );
  }
}
