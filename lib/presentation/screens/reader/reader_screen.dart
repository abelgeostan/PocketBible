import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
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
import 'widgets/chapter_navigation_bar.dart';
import 'widgets/reading_tools_bar.dart';
import 'widgets/verse_item_widget.dart';

class ReaderScreen extends StatefulWidget {
  const ReaderScreen({super.key});

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  final BibleRepository _bibleRepository = BibleRepository();
  final ScrollController _scrollController = ScrollController();

  List<BibleVerse> _verses = [];
  bool _isLoading = true;
  String _loadedKey = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadVerses();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadVerses() async {
    final nav = context.read<BibleNavigationProvider>();
    if (nav.currentBook == null) return;

    final key = '${nav.currentBook!.code}-${nav.currentChapter}';
    if (key == _loadedKey && _verses.isNotEmpty) return;

    setState(() => _isLoading = true);
    _loadedKey = key;

    final verses = await _bibleRepository.getChapterVerses(
      nav.currentBook!.code,
      nav.currentChapter,
    );

    if (mounted) {
      setState(() {
        _verses = verses;
        _isLoading = false;
      });

      // Record reading history & last read position
      nav.recordCurrentReading();

      // Auto-scroll to target verse if requested
      if (nav.targetVerse != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToVerse(nav.targetVerse!);
          nav.clearTargetVerse();
        });
      } else if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    }
  }

  void _scrollToVerse(int verseNumber) {
    final targetIndex = _verses.indexWhere((v) => v.verse == verseNumber);
    if (targetIndex >= 0 && _scrollController.hasClients) {
      final approxOffset = targetIndex * 65.0;
      _scrollController.animateTo(
        approxOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _copyFullChapter() {
    final nav = context.read<BibleNavigationProvider>();
    if (nav.currentBook == null || _verses.isEmpty) return;

    final versesText = _verses.map((v) => '${v.verse} ${v.text}').join('\n');
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

    // Detect if book or chapter changed in provider
    final currentKey = '${nav.currentBook?.code}-${nav.currentChapter}';
    if (currentKey != _loadedKey && !_isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadVerses());
    } else if (nav.targetVerse != null && !_isLoading && _verses.isNotEmpty) {
      final v = nav.targetVerse!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToVerse(v);
        nav.clearTargetVerse();
      });
    }

    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final accentColor = isDark ? AppColors.darkAccent : AppColors.lightAccent;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final mutedColor = isDark ? AppColors.darkMuted : AppColors.lightMuted;
    final lineColor = isDark ? AppColors.darkLine : AppColors.lightLine;

    final book = nav.currentBook;
    final chapter = nav.currentChapter;

    return PopScope(
      canPop: Navigator.canPop(context),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen(autoOpenLastRead: false)),
          );
        }
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
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          // Horizontal swipe navigation between chapters
          if (details.primaryVelocity != null) {
            if (details.primaryVelocity! < -300) {
              // Swipe left -> Next Chapter
              if (nav.hasNextChapter) {
                nav.goToNextChapter();
              }
            } else if (details.primaryVelocity! > 300) {
              // Swipe right -> Previous Chapter
              if (nav.hasPreviousChapter) {
                nav.goToPreviousChapter();
              }
            }
          }
        },
        child: Padding(
          padding: settings.readingPadding,
          child: Column(
            children: [
              // Sticky / Top Bible Navigation Selector
              const StickySelectorBar(navigateOnChapterSelect: false),
              const SizedBox(height: 12),

              // Reading Content
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView(
                        controller: _scrollController,
                        children: [
                          // Chapter Title Heading
                          Container(
                            padding: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              border: Border(bottom: BorderSide(color: lineColor)),
                            ),
                            child: Text(
                              '${book?.name ?? ""} $chapter',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: textColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Reading Tools Bar
                          ReadingToolsBar(
                            onCopyChapter: _copyFullChapter,
                          ),
                          const SizedBox(height: 16),

                          // Bible Text Card (matching .bible-text)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                            decoration: BoxDecoration(
                              color: surfaceColor,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: lineColor),
                              boxShadow: [
                                BoxShadow(
                                  color: isDark
                                      ? Colors.black26
                                      : const Color.fromRGBO(20, 30, 40, 0.06),
                                  blurRadius: 20,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _verses.map((verse) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: VerseItemWidget(
                                    verse: verse,
                                    isTargeted: nav.targetVerse == verse.verse,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Previous & Next Chapter Navigation Buttons
                          const ChapterNavigationBar(),

                          const SizedBox(height: 30),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}
