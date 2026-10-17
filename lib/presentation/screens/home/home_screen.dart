import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/bible_navigation_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../widgets/app_drawer.dart';
import '../reader/reader_screen.dart';
import '../search/search_screen.dart';
import 'widgets/continue_reading_card.dart';
import 'widgets/daily_verse_card.dart';
import 'widgets/explore_testaments_card.dart';
import 'widgets/quick_actions_grid.dart';
import 'widgets/random_verse_card.dart';
import 'widgets/sticky_selector_bar.dart';

class HomeScreen extends StatefulWidget {
  final bool autoOpenLastRead;

  const HomeScreen({super.key, this.autoOpenLastRead = true});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static bool _hasAutoOpened = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAutoOpen());
  }

  void _checkAutoOpen() {
    if (widget.autoOpenLastRead && !_hasAutoOpened) {
      final nav = context.read<BibleNavigationProvider>();
      if (!nav.isLoading && nav.currentBook != null) {
        _hasAutoOpened = true;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ReaderScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<BibleNavigationProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    if (widget.autoOpenLastRead && !_hasAutoOpened && !nav.isLoading && nav.currentBook != null) {
      _hasAutoOpened = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ReaderScreen()),
          );
        }
      });
    }

    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final accentColor = isDark ? AppColors.darkAccent : AppColors.lightAccent;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final mutedColor = isDark ? AppColors.darkMuted : AppColors.lightMuted;
    final lineColor = isDark ? AppColors.darkLine : AppColors.lightLine;

    return Scaffold(
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
            // Already on home screen
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
            tooltip: 'Search Bible',
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
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isDark ? '☀ Light' : '☾ Dark',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: nav.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await nav.init();
              },
              color: accentColor,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                children: [
                  // Fast Navigation Sticky Selector
                  const StickySelectorBar(navigateOnChapterSelect: true),
                  const SizedBox(height: 14),

                  // Continue Reading Card
                  const ContinueReadingCard(),
                  const SizedBox(height: 14),

                  // Quick Study & Navigation Shortcuts
                  const QuickActionsGrid(),
                  const SizedBox(height: 14),

                  // Daily Verse
                  const DailyVerseCard(),
                  const SizedBox(height: 14),

                  // Random Verse Card
                  const RandomVerseCard(),
                  const SizedBox(height: 18),

                  // Compact Explore Testaments Section (replaces the long book scroll)
                  const ExploreTestamentsCard(),
                  const SizedBox(height: 28),

                  // Clean Footer
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: lineColor)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/icons/pocketbible-icon-touch.png',
                              width: 28,
                              height: 22,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'PocketBible.in',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: accentColor,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'മലയാളം സത്യവേദപുസ്തകം 1910 – സമകാലിക ലിപിയിൽ\n© 2015 The Free Bible Foundation · CC BY-SA 4.0\nPowered by Sansnet',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            height: 1.6,
                            color: mutedColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
