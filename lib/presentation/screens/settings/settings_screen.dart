import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../providers/bookmarks_provider.dart';
import '../../../providers/highlights_provider.dart';
import '../../../providers/notes_provider.dart';
import '../../../providers/reader_settings_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../widgets/toast_notification.dart';
import '../about/about_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final settings = context.watch<ReaderSettingsProvider>();
    final bookmarks = context.watch<BookmarksProvider>();
    final highlights = context.watch<HighlightsProvider>();
    final notes = context.watch<NotesProvider>();

    final isDark = themeProvider.isDarkMode;
    final surface2Color = isDark ? AppColors.darkSurface2 : AppColors.lightSurface2;
    final lineColor = isDark ? AppColors.darkLine : AppColors.lightLine;
    final accentColor = isDark ? AppColors.darkAccent : AppColors.lightAccent;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final mutedColor = isDark ? AppColors.darkMuted : AppColors.lightMuted;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ക്രമീകരണങ്ങൾ (Settings)'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          // Section: Appearance
          _buildSectionTitle('തീം (Appearance)', accentColor),
          Card(
            child: Column(
              children: [
                RadioListTile<ThemeMode>(
                  value: ThemeMode.light,
                  groupValue: themeProvider.themeMode,
                  activeColor: accentColor,
                  title: const Text('Light Mode (വെളിച്ചം)'),
                  subtitle: const Text('Clean white surface and warm bronze accents'),
                  onChanged: (mode) => themeProvider.setThemeMode(mode!),
                ),
                Divider(height: 1, color: lineColor),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.dark,
                  groupValue: themeProvider.themeMode,
                  activeColor: accentColor,
                  title: const Text('Dark Mode (ഇരുണ്ടത്)'),
                  subtitle: const Text('Deep slate background with golden amber accents'),
                  onChanged: (mode) => themeProvider.setThemeMode(mode!),
                ),
                Divider(height: 1, color: lineColor),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.system,
                  groupValue: themeProvider.themeMode,
                  activeColor: accentColor,
                  title: const Text('System Default (സിസ്റ്റം)'),
                  subtitle: const Text('Matches your phone device setting'),
                  onChanged: (mode) => themeProvider.setThemeMode(mode!),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Section: Typography & Reader Settings
          _buildSectionTitle('വായനാരീതിയും ഫോണ്ടും (Reading & Typography)', accentColor),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'ഫോണ്ട് വലിപ്പം (Font Size)',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      Text(
                        '${settings.fontSize.toInt()} px',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: accentColor,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: settings.fontSize,
                    min: AppConstants.minFontSize,
                    max: AppConstants.maxFontSize,
                    divisions: 6,
                    activeColor: accentColor,
                    onChanged: (val) => settings.setFontSize(val),
                  ),

                  // Live Preview Box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: surface2Color,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: lineColor),
                    ),
                    child: Text(
                      'ആദിയിൽ ദൈവം ആകാശവും ഭൂമിയും സൃഷ്ടിച്ചു. (ഉല്പത്തിപുസ്തകം 1:1)',
                      style: TextStyle(
                        fontFamily: 'Noto Sans Malayalam',
                        fontSize: settings.fontSize,
                        height: settings.lineSpacing,
                        color: textColor,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  Divider(height: 1, color: lineColor),
                  const SizedBox(height: 14),

                  // Keep Screen Awake
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'സ്ക്രീൻ ഓൺ ആക്കി വെക്കുക (Keep Screen Awake)',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textColor),
                    ),
                    subtitle: Text(
                      'Prevent phone screen from turning off while reading',
                      style: TextStyle(fontSize: 12, color: mutedColor),
                    ),
                    activeColor: accentColor,
                    value: settings.keepAwake,
                    onChanged: (_) => settings.toggleKeepAwake(),
                  ),

                  Divider(height: 1, color: lineColor),

                  // Show Verse Numbers
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'വാക്യ നമ്പറുകൾ കാണിക്കുക (Show Verse Numbers)',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textColor),
                    ),
                    activeColor: accentColor,
                    value: settings.showVerseNumbers,
                    onChanged: (_) => settings.toggleShowVerseNumbers(),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Section: Library Stats
          _buildSectionTitle('എന്റെ ശേഖരം (My Library)', accentColor),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.bookmark_outline, color: accentColor),
                  title: const Text('ബുക്ക്മാർക്കുകൾ (Bookmarks)'),
                  trailing: Text(
                    '${bookmarks.count}',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: accentColor),
                  ),
                ),
                Divider(height: 1, color: lineColor),
                ListTile(
                  leading: Icon(Icons.format_color_fill_outlined, color: accentColor),
                  title: const Text('ഹൈലൈറ്റുകൾ (Highlights)'),
                  trailing: Text(
                    '${highlights.count}',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: accentColor),
                  ),
                ),
                Divider(height: 1, color: lineColor),
                ListTile(
                  leading: Icon(Icons.note_alt_outlined, color: accentColor),
                  title: const Text('കുറിപ്പുകൾ (Notes)'),
                  trailing: Text(
                    '${notes.count}',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: accentColor),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Section: Play Store & About
          _buildSectionTitle('വിവരങ്ങളും പിന്തുണയും (About & Play Store)', accentColor),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.info_outline, color: accentColor),
                  title: const Text('PocketBible-നെക്കുറിച്ച് (About)'),
                  subtitle: const Text('സത്യവേദപുസ്തകം 1910, FBF 2015, Sansnet'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AboutScreen()),
                    );
                  },
                ),
                Divider(height: 1, color: lineColor),
                ListTile(
                  leading: Icon(Icons.star_rate_outlined, color: accentColor),
                  title: const Text('Play Store-ൽ റേറ്റ് ചെയ്യുക (Rate App)'),
                  trailing: const Icon(Icons.open_in_new, size: 18),
                  onTap: () async {
                    final url = Uri.parse(AppConstants.playStoreUrl);
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    } else {
                      if (context.mounted) {
                        ToastNotification.show(context, 'Opening Play Store...');
                      }
                    }
                  },
                ),
                Divider(height: 1, color: lineColor),
                ListTile(
                  leading: Icon(Icons.share_outlined, color: accentColor),
                  title: const Text('സുഹൃത്തുക്കൾക്ക് പങ്കിടുക (Share App)'),
                  onTap: () {
                    Share.share(
                      'PocketBible — മലയാളം സത്യവേദപുസ്തകം 1910 മൊബൈൽ ആപ്പ് ഡൗൺലോഡ് ചെയ്യുക:\n${AppConstants.playStoreUrl}',
                      subject: 'PocketBible Malayalam Holy Bible App',
                    );
                  },
                ),
                Divider(height: 1, color: lineColor),
                ListTile(
                  leading: Icon(Icons.privacy_tip_outlined, color: accentColor),
                  title: const Text('Privacy Policy (സ്വകാര്യതാ നയം)'),
                  trailing: const Icon(Icons.open_in_new, size: 18),
                  onTap: () async {
                    final url = Uri.parse(AppConstants.privacyPolicyUrl);
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    }
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
