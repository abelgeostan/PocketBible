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
  static const double _itemHeight = 52.0;
  static const double _headerHeight = 36.0;

  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _searchFilter = '';
  bool _isProgrammaticScrolling = false;

  int _currentOtCount = 39;
  int _currentNtCount = 27;

  @override
  void initState() {
    super.initState();
    final initialIndex = (widget.initialTestament == 'NT') ? 1 : 0;
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: initialIndex,
    );

    _scrollController.addListener(_onScroll);

    if (initialIndex == 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_scrollController.hasClients) return;
        final targetOffset = _getNtOffset();
        final maxScroll = _scrollController.position.maxScrollExtent;
        _scrollController.jumpTo(targetOffset.clamp(0.0, maxScroll));
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  double _getNtOffset() {
    if (_currentOtCount == 0) return 0.0;
    return _headerHeight + (_currentOtCount * _itemHeight);
  }

  void _scrollToSection(int index) {
    if (!_scrollController.hasClients) return;
    _isProgrammaticScrolling = true;

    final targetOffset = index == 0 ? 0.0 : _getNtOffset();
    final maxScroll = _scrollController.position.maxScrollExtent;
    final clampedOffset = targetOffset.clamp(0.0, maxScroll);

    _scrollController
        .animateTo(
      clampedOffset,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOut,
    )
        .then((_) {
      Future.delayed(const Duration(milliseconds: 80), () {
        if (mounted) {
          _isProgrammaticScrolling = false;
        }
      });
    });
  }

  void _onScroll() {
    if (_isProgrammaticScrolling) return;
    if (!_scrollController.hasClients) return;

    final ntOffset = _getNtOffset();
    final isAtOrNearBottom =
        _scrollController.position.pixels >= (_scrollController.position.maxScrollExtent - 20);

    final int targetIndex;
    if (_currentOtCount == 0) {
      targetIndex = 1;
    } else if (_currentNtCount == 0) {
      targetIndex = 0;
    } else if (isAtOrNearBottom || _scrollController.offset >= (ntOffset - 40)) {
      targetIndex = 1;
    } else {
      targetIndex = 0;
    }

    if (_tabController.index != targetIndex && !_tabController.indexIsChanging) {
      _tabController.animateTo(targetIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<BibleNavigationProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final surface2Color = isDark ? AppColors.darkSurface2 : AppColors.lightSurface2;
    final lineColor = isDark ? AppColors.darkLine : AppColors.lightLine;
    final accentColor = isDark ? AppColors.darkAccent : AppColors.lightAccent;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final mutedColor = isDark ? AppColors.darkMuted : AppColors.lightMuted;

    final allBooks = nav.books.where((b) {
      if (_searchFilter.isEmpty) return true;
      final query = _searchFilter.toLowerCase();
      return b.name.toLowerCase().contains(query) ||
          b.code.toLowerCase().contains(query) ||
          b.englishName.toLowerCase().contains(query);
    }).toList();

    final otBooks = allBooks.where((b) => b.isOldTestament).toList();
    final ntBooks = allBooks.where((b) => b.isNewTestament).toList();

    _currentOtCount = otBooks.length;
    _currentNtCount = ntBooks.length;

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

          // 2 Tabs: Old and New Testament with underline + light shade
          TabBar(
            controller: _tabController,
            onTap: (index) => _scrollToSection(index),
            indicator: BoxDecoration(
              color: accentColor.withValues(alpha: isDark ? 0.14 : 0.08),
              border: Border(
                bottom: BorderSide(
                  color: accentColor,
                  width: 2.5,
                ),
              ),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: accentColor,
            unselectedLabelColor: mutedColor,
            labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            tabs: [
              Tab(text: 'പഴയ നിയമം (${otBooks.length})'),
              Tab(text: 'പുതിയ നിയമം (${ntBooks.length})'),
            ],
          ),

          Divider(height: 1, color: lineColor),

          // Single scrollable list containing Old and New Testament books
          Expanded(
            child: allBooks.isEmpty
                ? Center(
                    child: Text(
                      'പുസ്തകം കണ്ടെത്തിയില്ല',
                      style: TextStyle(
                        color: mutedColor,
                        fontSize: 14,
                      ),
                    ),
                  )
                : NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      if (notification is UserScrollNotification) {
                        _isProgrammaticScrolling = false;
                      }
                      return false;
                    },
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: (otBooks.isNotEmpty ? otBooks.length + 1 : 0) +
                          (ntBooks.isNotEmpty ? ntBooks.length + 1 : 0),
                      itemBuilder: (context, index) {
                        // OT section
                        if (otBooks.isNotEmpty) {
                          if (index == 0) {
                            return _buildSectionHeader(
                              'പഴയ നിയമം (${otBooks.length} പുസ്തകങ്ങൾ)',
                              surface2Color,
                              accentColor,
                              lineColor,
                            );
                          }
                          if (index <= otBooks.length) {
                            final book = otBooks[index - 1];
                            return _buildBookTile(
                              book: book,
                              isSelected: book.code == nav.currentBook?.code,
                              surface2Color: surface2Color,
                              accentColor: accentColor,
                              textColor: textColor,
                              mutedColor: mutedColor,
                              lineColor: lineColor,
                            );
                          }
                        }

                        // NT section
                        final ntOffsetIndex = otBooks.isNotEmpty ? index - (otBooks.length + 1) : index;
                        if (ntOffsetIndex == 0) {
                          return _buildSectionHeader(
                            'പുതിയ നിയമം (${ntBooks.length} പുസ്തകങ്ങൾ)',
                            surface2Color,
                            accentColor,
                            lineColor,
                          );
                        }

                        final book = ntBooks[ntOffsetIndex - 1];
                        return _buildBookTile(
                          book: book,
                          isSelected: book.code == nav.currentBook?.code,
                          surface2Color: surface2Color,
                          accentColor: accentColor,
                          textColor: textColor,
                          mutedColor: mutedColor,
                          lineColor: lineColor,
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color bgColor, Color textColor, Color lineColor) {
    return Container(
      height: _headerHeight,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          bottom: BorderSide(color: lineColor),
        ),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: textColor,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildBookTile({
    required BibleBook book,
    required bool isSelected,
    required Color surface2Color,
    required Color accentColor,
    required Color textColor,
    required Color mutedColor,
    required Color lineColor,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 51,
          child: ListTile(
            dense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
            tileColor: isSelected ? surface2Color : null,
            title: Text(
              book.name,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? accentColor : textColor,
                fontSize: 15,
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isSelected ? accentColor.withValues(alpha: 0.15) : surface2Color,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: lineColor),
              ),
              child: Text(
                book.englishName,
                style: TextStyle(
                  fontSize: 11,
                  color: isSelected ? accentColor : mutedColor,
                ),
              ),
            ),
            onTap: () => widget.onBookSelected(book),
          ),
        ),
        Divider(height: 1, color: lineColor.withValues(alpha: 0.5)),
      ],
    );
  }
}
