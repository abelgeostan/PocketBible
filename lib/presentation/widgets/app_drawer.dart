import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/bookmarks_provider.dart';
import '../../providers/highlights_provider.dart';
import '../../providers/notes_provider.dart';
import '../../providers/theme_provider.dart';
import '../screens/bookmarks/bookmarks_screen.dart';
import '../screens/highlights/highlights_screen.dart';
import '../screens/history/history_screen.dart';
import '../screens/notes/notes_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/about/about_screen.dart';
import '../screens/home/home_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = context.watch<ThemeProvider>();
    final bookmarksCount = context.watch<BookmarksProvider>().count;
    final highlightsCount = context.watch<HighlightsProvider>().count;
    final notesCount = context.watch<NotesProvider>().count;

    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final surface2Color = isDark ? AppColors.darkSurface2 : AppColors.lightSurface2;
    final accentColor = isDark ? AppColors.darkAccent : AppColors.lightAccent;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final mutedColor = isDark ? AppColors.darkMuted : AppColors.lightMuted;
    final lineColor = isDark ? AppColors.darkLine : AppColors.lightLine;

    return Drawer(
      backgroundColor: surfaceColor,
      child: Column(
        children: [
          // Drawer Header
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20,
              left: 20,
              right: 20,
              bottom: 20,
            ),
            decoration: BoxDecoration(
              color: surface2Color,
              border: Border(bottom: BorderSide(color: lineColor)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          'assets/icons/pocketbible-icon-touch.png',
                          width: 44,
                          height: 34,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 10),
                        RichText(
                          text: TextSpan(
                            text: 'PocketBible',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: accentColor,
                              fontFamily: 'Noto Sans Malayalam',
                            ),
                            children: [
                              TextSpan(
                                text: '.in',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: mutedColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(
                        isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                        color: accentColor,
                      ),
                      tooltip: isDark ? 'Light mode' : 'Dark mode',
                      onPressed: () => themeProvider.toggleTheme(),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  AppConstants.appTagline,
                  style: TextStyle(
                    fontSize: 13,
                    color: mutedColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Drawer Navigation List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                // Reading Section
                _buildSectionHeader('Reading & Study', mutedColor),
                _buildDrawerItem(
                  context,
                  icon: Icons.auto_stories_outlined,
                  title: 'Holy Bible',
                  subtitle: 'All Books & Chapters',
                  textColor: textColor,
                  mutedColor: mutedColor,
                  accentColor: accentColor,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const HomeScreen(autoOpenLastRead: false)),
                      (route) => false,
                    );
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.search_outlined,
                  title: 'Search Scripture',
                  subtitle: 'Malayalam Scripture Search',
                  textColor: textColor,
                  mutedColor: mutedColor,
                  accentColor: accentColor,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SearchScreen()),
                    );
                  },
                ),

                const Divider(height: 16),

                // Library Section
                _buildSectionHeader('My Library', mutedColor),
                _buildDrawerItem(
                  context,
                  icon: Icons.bookmark_outline,
                  title: 'Bookmarks',
                  badgeCount: bookmarksCount,
                  textColor: textColor,
                  mutedColor: mutedColor,
                  accentColor: accentColor,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BookmarksScreen()),
                    );
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.format_color_fill_outlined,
                  title: 'Highlights',
                  badgeCount: highlightsCount,
                  textColor: textColor,
                  mutedColor: mutedColor,
                  accentColor: accentColor,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const HighlightsScreen()),
                    );
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.note_alt_outlined,
                  title: 'Notes',
                  badgeCount: notesCount,
                  textColor: textColor,
                  mutedColor: mutedColor,
                  accentColor: accentColor,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const NotesScreen()),
                    );
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.history_outlined,
                  title: 'Reading History',
                  textColor: textColor,
                  mutedColor: mutedColor,
                  accentColor: accentColor,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const HistoryScreen()),
                    );
                  },
                ),

                const Divider(height: 16),

                // App Settings & More
                _buildSectionHeader('Settings & More', mutedColor),
                _buildDrawerItem(
                  context,
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  subtitle: 'Theme, Font size, Display',
                  textColor: textColor,
                  mutedColor: mutedColor,
                  accentColor: accentColor,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.info_outline,
                  title: 'About PocketBible',
                  subtitle: 'License, Sources & Credits',
                  textColor: textColor,
                  mutedColor: mutedColor,
                  accentColor: accentColor,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AboutScreen()),
                    );
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.share_outlined,
                  title: 'Share App',
                  textColor: textColor,
                  mutedColor: mutedColor,
                  accentColor: accentColor,
                  onTap: () {
                    Navigator.pop(context);
                    Share.share(
                      'PocketBible — Malayalam Holy Bible (മലയാളം സത്യവേദപുസ്തകം 1910):\n${AppConstants.playStoreUrl}',
                      subject: 'PocketBible Malayalam Holy Bible App',
                    );
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.star_rate_outlined,
                  title: 'Rate on Play Store',
                  textColor: textColor,
                  mutedColor: mutedColor,
                  accentColor: accentColor,
                  onTap: () async {
                    Navigator.pop(context);
                    final url = Uri.parse(AppConstants.playStoreUrl);
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    }
                  },
                ),
              ],
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: lineColor)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '© The Free Bible Foundation',
                  style: TextStyle(fontSize: 11, color: mutedColor),
                ),
                Text(
                  'CC BY-SA 4.0',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: mutedColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    int? badgeCount,
    required Color textColor,
    required Color mutedColor,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: accentColor, size: 22),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: mutedColor),
            )
          : null,
      trailing: badgeCount != null && badgeCount > 0
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$badgeCount',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: accentColor,
                ),
              ),
            )
          : null,
      dense: true,
      onTap: onTap,
    );
  }
}
