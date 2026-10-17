import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../providers/bible_navigation_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../widgets/app_drawer.dart';
import '../search/search_screen.dart';
import 'widgets/book_cards_grid.dart';
import 'widgets/continue_reading_card.dart';
import 'widgets/daily_verse_card.dart';
import 'widgets/random_verse_card.dart';
import 'widgets/search_bar_card.dart';
import 'widgets/sticky_selector_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<BibleNavigationProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                children: [
                  // Fast Navigation Sticky Selector
                  const StickySelectorBar(navigateOnChapterSelect: true),
                  const SizedBox(height: 16),

                  // Search Bar Card
                  const SearchBarCard(),
                  const SizedBox(height: 16),

                  // Continue Reading Card
                  const ContinueReadingCard(),
                  const SizedBox(height: 16),

                  // Daily Verse
                  const DailyVerseCard(),
                  const SizedBox(height: 16),

                  // Random Verse Card
                  const RandomVerseCard(),
                  const SizedBox(height: 12),

                  // Old Testament Section
                  BookCardsGrid(
                    books: nav.oldTestamentBooks,
                    title: AppConstants.oldTestamentLabel,
                  ),

                  const SizedBox(height: 20),

                  // New Testament Section
                  BookCardsGrid(
                    books: nav.newTestamentBooks,
                    title: AppConstants.newTestamentLabel,
                  ),

                  const SizedBox(height: 40),

                  // Footer matching PocketBible.in
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
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
                              width: 32,
                              height: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'PocketBible.in',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: accentColor,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
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
