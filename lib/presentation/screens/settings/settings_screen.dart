import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../providers/notification_provider.dart';
import '../../../providers/reader_settings_provider.dart';
import '../../../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final settings = context.watch<ReaderSettingsProvider>();
    final notifProvider = context.watch<NotificationProvider>();

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

                  Divider(height: 1, color: lineColor),

                  // Auto Open Verse Selector
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'വാക്യ സെലക്ടർ ഓട്ടോമാറ്റിക് ആയി തുറക്കുക (Auto Open Verse Selector)',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textColor),
                    ),
                    subtitle: Text(
                      'Automatically open verse selector after book and chapter are selected',
                      style: TextStyle(fontSize: 12, color: mutedColor),
                    ),
                    activeColor: accentColor,
                    value: settings.autoOpenVerseSelector,
                    onChanged: (_) => settings.toggleAutoOpenVerseSelector(),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Section: Notifications
          _buildSectionTitle('അറിയിപ്പുകൾ (Notifications)', accentColor),
          Card(
            child: Column(
              children: [
                // Morning Notification
                SwitchListTile(
                  title: Text(
                    'പ്രഭാത വചനം (Morning Daily Verse)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  subtitle: Text(
                    'ദിവസേന രാവിലെ ഇന്നത്തെ വചനം അറിയിപ്പായി ലഭിക്കുക',
                    style: TextStyle(fontSize: 12, color: mutedColor),
                  ),
                  activeColor: accentColor,
                  value: notifProvider.morningEnabled,
                  onChanged: (val) => notifProvider.setMorningEnabled(val),
                ),

                if (notifProvider.morningEnabled) ...[
                  Divider(height: 1, color: lineColor),
                  ListTile(
                    leading: Icon(Icons.wb_sunny_outlined, color: accentColor, size: 20),
                    title: Text(
                      'അറിയിപ്പ് സമയം (Notification Time)',
                      style: TextStyle(fontSize: 14, color: textColor),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: surface2Color,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: lineColor),
                      ),
                      child: Text(
                        _formatTime(notifProvider.morningTime),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: accentColor,
                        ),
                      ),
                    ),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: notifProvider.morningTime,
                      );
                      if (picked != null) {
                        notifProvider.setMorningTime(picked);
                      }
                    },
                  ),
                ],

                Divider(height: 1, color: lineColor),

                // Evening Notification
                SwitchListTile(
                  title: Text(
                    'സായാഹ്ന സന്ദേശം (Evening Daily Bread)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  subtitle: Text(
                    'ദിവസേന വൈകുന്നേരം ദൈവവചനം വായിക്കാൻ ഓർമ്മപ്പെടുത്തൽ',
                    style: TextStyle(fontSize: 12, color: mutedColor),
                  ),
                  activeColor: accentColor,
                  value: notifProvider.eveningEnabled,
                  onChanged: (val) => notifProvider.setEveningEnabled(val),
                ),

                if (notifProvider.eveningEnabled) ...[
                  Divider(height: 1, color: lineColor),
                  ListTile(
                    leading: Icon(Icons.nights_stay_outlined, color: accentColor, size: 20),
                    title: Text(
                      'അറിയിപ്പ് സമയം (Notification Time)',
                      style: TextStyle(fontSize: 14, color: textColor),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: surface2Color,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: lineColor),
                      ),
                      child: Text(
                        _formatTime(notifProvider.eveningTime),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: accentColor,
                        ),
                      ),
                    ),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: notifProvider.eveningTime,
                      );
                      if (picked != null) {
                        notifProvider.setEveningTime(picked);
                      }
                    },
                  ),
                ],

              ],
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
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
