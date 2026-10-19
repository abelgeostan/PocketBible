import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/bible_book.dart';
import '../../../data/models/bible_verse.dart';
import '../../../data/repositories/bible_repository.dart';
import '../../../providers/bible_navigation_provider.dart';
import '../../../providers/reader_settings_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/toast_notification.dart';
import '../home/home_screen.dart';
import '../home/widgets/sticky_selector_bar.dart';
import '../search/search_screen.dart';
import 'widgets/chapter_content_view.dart';
import 'widgets/reading_tools_bar.dart';

class ChapterRef {
  final BibleBook book;
  final int chapter;
  const ChapterRef(this.book, this.chapter);
}

class ReaderScreen extends StatefulWidget {
  const ReaderScreen({super.key});

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  final BibleRepository _bibleRepository = BibleRepository();
  List<ChapterRef> _allChapters = [];
  PageController? _pageController;
  int _currentPageIndex = 0;
  bool _isExternalNavigation = false;

  @override
  void initState() {
    super.initState();
    final nav = context.read<BibleNavigationProvider>();
    if (nav.books.isNotEmpty) {
      _initChapters(nav);
    }
  }

  void _initChapters(BibleNavigationProvider nav) {
    _allChapters = _buildAllChapters(nav.books);
    _currentPageIndex = _indexOf(nav.currentBook?.code, nav.currentChapter);
    _pageController = PageController(initialPage: _currentPageIndex);
    _preloadAdjacent(_currentPageIndex);
  }

  List<ChapterRef> _buildAllChapters(List<BibleBook> books) {
    final list = <ChapterRef>[];
    for (final b in books) {
      for (int c = 1; c <= b.totalChapters; c++) {
        list.add(ChapterRef(b, c));
      }
    }
    return list;
  }

  int _indexOf(String? bookCode, int chapter) {
    if (bookCode == null || _allChapters.isEmpty) return 0;
    final idx = _allChapters.indexWhere((ref) => ref.book.code == bookCode && ref.chapter == chapter);
    return idx != -1 ? idx : 0;
  }

  void _preloadAdjacent(int index) {
    if (index > 0) {
      final prev = _allChapters[index - 1];
      final key = '${prev.book.code}-${prev.chapter}';
      if (!ChapterContentView.hasCached(key)) {
        _bibleRepository.getChapterVerses(prev.book.code, prev.chapter).then((verses) {
          ChapterContentView.setCached(key, verses);
        });
      }
    }
    if (index < _allChapters.length - 1) {
      final next = _allChapters[index + 1];
      final key = '${next.book.code}-${next.chapter}';
      if (!ChapterContentView.hasCached(key)) {
        _bibleRepository.getChapterVerses(next.book.code, next.chapter).then((verses) {
          ChapterContentView.setCached(key, verses);
        });
      }
    }
  }

  void _onPageChanged(int index) {
    if (_isExternalNavigation) {
      _isExternalNavigation = false;
      _currentPageIndex = index;
      _preloadAdjacent(index);
      return;
    }

    final oldIndex = _currentPageIndex;
    int restoredVerse = 1;
    if (oldIndex != index &&
        oldIndex >= 0 &&
        oldIndex < _allChapters.length &&
        index >= 0 &&
        index < _allChapters.length) {
      final oldRef = _allChapters[oldIndex];
      final newRef = _allChapters[index];
      final isAdjacent = (index - oldIndex).abs() == 1;
      restoredVerse = ChapterContentView.onChapterChanged(
        oldBookCode: oldRef.book.code,
        oldChapter: oldRef.chapter,
        newBookCode: newRef.book.code,
        newChapter: newRef.chapter,
        isAdjacentSwipe: isAdjacent,
      );
    }

    _currentPageIndex = index;
    _preloadAdjacent(index);

    if (index >= 0 && index < _allChapters.length) {
      final ref = _allChapters[index];
      final nav = context.read<BibleNavigationProvider>();
      if (ref.book.code != nav.currentBook?.code || ref.chapter != nav.currentChapter) {
        nav.navigateTo(ref.book.code, ref.chapter, verse: restoredVerse, incrementJumpToken: false);
      } else if (nav.targetVerse != restoredVerse) {
        nav.updateCurrentVerse(restoredVerse);
      }
    }
  }

  void _goToNextChapter() {
    if (_pageController != null && _pageController!.hasClients && _currentPageIndex < _allChapters.length - 1) {
      _pageController!.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _goToPreviousChapter() {
    if (_pageController != null && _pageController!.hasClients && _currentPageIndex > 0) {
      _pageController!.previousPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  Future<void> _copyFullChapter() async {
    final nav = context.read<BibleNavigationProvider>();
    if (nav.currentBook == null) return;

    final key = '${nav.currentBook!.code}-${nav.currentChapter}';
    List<BibleVerse>? verses = ChapterContentView.getCached(key);
    if (verses == null || verses.isEmpty) {
      verses = await _bibleRepository.getChapterVerses(nav.currentBook!.code, nav.currentChapter);
    }
    if (verses.isEmpty || !mounted) return;

    final versesText = verses.map((v) => '${v.verse} ${v.text}').join('\n');
    final fullText = '${nav.currentBook!.name} ${nav.currentChapter}\n\n$versesText';

    Clipboard.setData(ClipboardData(text: fullText));
    ToastNotification.show(context, 'Chapter copied');
  }

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<BibleNavigationProvider>();
    final settings = context.watch<ReaderSettingsProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    if (_allChapters.isEmpty && nav.books.isNotEmpty) {
      _initChapters(nav);
    }

    // Sync PageController when provider is changed externally (e.g. from StickySelectorBar or Verse selector)
    final targetIndex = _indexOf(nav.currentBook?.code, nav.currentChapter);
    if (targetIndex != _currentPageIndex) {
      final oldIndex = _currentPageIndex;
      _currentPageIndex = targetIndex;
      _isExternalNavigation = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (oldIndex >= 0 &&
            oldIndex < _allChapters.length &&
            targetIndex >= 0 &&
            targetIndex < _allChapters.length) {
          final oldRef = _allChapters[oldIndex];
          final newRef = _allChapters[targetIndex];
          ChapterContentView.onChapterChanged(
            oldBookCode: oldRef.book.code,
            oldChapter: oldRef.chapter,
            newBookCode: newRef.book.code,
            newChapter: newRef.chapter,
            isAdjacentSwipe: false,
          );
        }
        if (_pageController != null && _pageController!.hasClients) {
          if ((_pageController!.page?.round() ?? -1) != targetIndex) {
            _pageController!.jumpToPage(targetIndex);
            _preloadAdjacent(targetIndex);
          } else {
            _isExternalNavigation = false;
          }
        } else {
          _isExternalNavigation = false;
        }
      });
    }

    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final accentColor = isDark ? AppColors.darkAccent : AppColors.lightAccent;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final mutedColor = isDark ? AppColors.darkMuted : AppColors.lightMuted;
    final lineColor = isDark ? AppColors.darkLine : AppColors.lightLine;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        SystemNavigator.pop();
      },
      child: Scaffold(
        drawer: const AppDrawer(),
        appBar: AppBar(
          titleSpacing: 0,
          leading: Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu),
              color: accentColor,
              tooltip: 'Menu',
              onPressed: () => Scaffold.of(ctx).openDrawer(),
            ),
          ),
          title: InkWell(
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen(autoOpenLastRead: false)),
                (route) => false,
              );
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/icons/pocketbible-icon-touch.png',
                    width: 38,
                    height: 28,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 8),
                  RichText(
                    text: TextSpan(
                      text: 'PocketBible',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: accentColor,
                        fontFamily: 'Noto Sans Malayalam',
                      ),
                      children: [
                        TextSpan(
                          text: '.in',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: mutedColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              color: textColor,
              tooltip: 'Search',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SearchScreen()),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: InkWell(
                onTap: () => themeProvider.toggleTheme(),
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: lineColor),
                    borderRadius: BorderRadius.circular(999),
                    color: surfaceColor,
                  ),
                  child: Text(
                    isDark ? '☀ Light' : '☾ Dark',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: settings.readingPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Top Bible Navigation Selector (Stays stationary in position)
              const StickySelectorBar(navigateOnChapterSelect: false),
              const SizedBox(height: 12),

              // 2. Chapter Title Heading (Swipes smoothly in exact sync with chapter page swipe)
              SizedBox(
                height: 48,
                child: _allChapters.isEmpty
                    ? const SizedBox.shrink()
                    : AnimatedBuilder(
                        animation: _pageController ?? Listenable.merge([]),
                        builder: (context, _) {
                          double page = _currentPageIndex.toDouble();
                          if (!_isExternalNavigation &&
                              _pageController != null &&
                              _pageController!.hasClients &&
                              _pageController!.position.haveDimensions) {
                            page = _pageController!.page ?? _currentPageIndex.toDouble();
                          }
                          return LayoutBuilder(
                            builder: (context, constraints) {
                              final width = constraints.maxWidth;
                              final baseIndex = page.floor();
                              final fraction = page - baseIndex;

                              Widget buildHeading(int index) {
                                if (index < 0 || index >= _allChapters.length) {
                                  return const SizedBox.shrink();
                                }
                                final ref = _allChapters[index];
                                return Container(
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    border: Border(bottom: BorderSide(color: lineColor)),
                                  ),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      '${ref.book.name} ${ref.chapter}',
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      style: TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.w700,
                                        color: textColor,
                                      ),
                                    ),
                                  ),
                                );
                              }

                              return ClipRect(
                                child: Stack(
                                  children: [
                                    // Primary / left heading
                                    Positioned(
                                      left: -fraction * width,
                                      top: 0,
                                      bottom: 0,
                                      width: width,
                                      child: buildHeading(baseIndex),
                                    ),
                                    // Next / right heading during drag
                                    if (fraction > 0 && baseIndex + 1 < _allChapters.length)
                                      Positioned(
                                        left: (1.0 - fraction) * width,
                                        top: 0,
                                        bottom: 0,
                                        width: width,
                                        child: buildHeading(baseIndex + 1),
                                      ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
              const SizedBox(height: 12),

              // 3. Control Buttons / Reading Tools Bar (Sticky in middle, does not swipe)
              ReadingToolsBar(
                onCopyChapter: _copyFullChapter,
              ),
              const SizedBox(height: 16),

              // 4. Chapter Content Widget (Verses card slides horizontally with swipe)
              Expanded(
                child: _allChapters.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : PageView.builder(
                        controller: _pageController,
                        itemCount: _allChapters.length,
                        onPageChanged: _onPageChanged,
                        itemBuilder: (context, index) {
                          final ref = _allChapters[index];
                          final isCurrent = index == _currentPageIndex;
                          return ChapterContentView(
                            key: ValueKey('page_${ref.book.code}_${ref.chapter}'),
                            book: ref.book,
                            chapter: ref.chapter,
                            isCurrent: isCurrent,
                            hasPrevious: index > 0,
                            hasNext: index < _allChapters.length - 1,
                            onPrevious: _goToPreviousChapter,
                            onNext: _goToNextChapter,
                            targetVerse: isCurrent ? nav.targetVerse : null,
                            verseJumpToken: nav.verseJumpToken,
                            onVerseVisible: isCurrent
                                ? (verse) => nav.updateCurrentVerse(verse)
                                : null,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
