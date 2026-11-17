import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/backup_service.dart';
import '../../../providers/bible_navigation_provider.dart';
import '../../../providers/bookmarks_provider.dart';
import '../../../providers/highlights_provider.dart';
import '../../../providers/notes_provider.dart';
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
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          // Section: Appearance
          _buildSectionTitle('Appearance', accentColor),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: lineColor),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildThemeOptionCard(
                          title: 'Light Mode',
                          isDarkTheme: false,
                          isSelected: themeProvider.themeMode == ThemeMode.light,
                          accentColor: accentColor,
                          lineColor: lineColor,
                          surface2Color: surface2Color,
                          textColor: textColor,
                          mutedColor: mutedColor,
                          onTap: () => themeProvider.setThemeMode(ThemeMode.light),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildThemeOptionCard(
                          title: 'Dark Mode',
                          isDarkTheme: true,
                          isSelected: themeProvider.themeMode == ThemeMode.dark,
                          accentColor: accentColor,
                          lineColor: lineColor,
                          surface2Color: surface2Color,
                          textColor: textColor,
                          mutedColor: mutedColor,
                          onTap: () => themeProvider.setThemeMode(ThemeMode.dark),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildSystemOptionTile(
                    isSelected: themeProvider.themeMode == ThemeMode.system,
                    accentColor: accentColor,
                    lineColor: lineColor,
                    surface2Color: surface2Color,
                    textColor: textColor,
                    mutedColor: mutedColor,
                    onTap: () => themeProvider.setThemeMode(ThemeMode.system),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Section: Typography & Reader Settings
          _buildSectionTitle('Reading & Typography', accentColor),
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
                        'Font Size',
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
                      'Keep Screen Awake',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textColor),
                    ),
                    subtitle: Text(
                      'Prevent screen from turning off while reading',
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
                      'Show Verse Numbers',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textColor),
                    ),
                    subtitle: Text(
                      'Display verse numbers in scripture text',
                      style: TextStyle(fontSize: 12, color: mutedColor),
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
                      'Auto Open Verse Selector',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textColor),
                    ),
                    subtitle: Text(
                      'Open verse picker automatically after chapter selection',
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
          _buildSectionTitle('Notifications', accentColor),
          Card(
            child: Column(
              children: [
                // Morning Notification
                SwitchListTile(
                  title: Text(
                    'Morning Daily Verse',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  subtitle: Text(
                    'Receive daily morning verse reminder',
                    style: TextStyle(fontSize: 12, color: mutedColor),
                  ),
                  activeThumbColor: accentColor,
                  value: notifProvider.morningEnabled,
                  onChanged: (val) => notifProvider.setMorningEnabled(val),
                ),

                if (notifProvider.morningEnabled) ...[
                  Divider(height: 1, color: lineColor),
                  ListTile(
                    leading: Icon(Icons.wb_sunny_outlined, color: accentColor, size: 20),
                    title: Text(
                      'Notification Time',
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
                    'Evening Daily Bread',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  subtitle: Text(
                    'Receive daily evening reading reminder',
                    style: TextStyle(fontSize: 12, color: mutedColor),
                  ),
                  activeThumbColor: accentColor,
                  value: notifProvider.eveningEnabled,
                  onChanged: (val) => notifProvider.setEveningEnabled(val),
                ),

                if (notifProvider.eveningEnabled) ...[
                  Divider(height: 1, color: lineColor),
                  ListTile(
                    leading: Icon(Icons.nights_stay_outlined, color: accentColor, size: 20),
                    title: Text(
                      'Notification Time',
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

          const SizedBox(height: 24),

          // Section: Data Backup & Restore
          _buildSectionTitle('Backup & Restore', accentColor),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: lineColor),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // 1. Export / Download Backup
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.file_download_rounded, color: accentColor, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Export Backup',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Save bookmarks, highlights, and notes to your device',
                              style: TextStyle(fontSize: 12, color: mutedColor, height: 1.3),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accentColor,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                minimumSize: const Size(0, 36),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              icon: const Icon(Icons.download_rounded, size: 17),
                              label: const Text(
                                'Export Backup',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                              onPressed: () => _handleExport(context),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Divider(height: 1, color: lineColor),
                  ),

                  // 2. Import / Restore Backup
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.file_upload_rounded, color: accentColor, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Import Backup',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Restore bookmarks, highlights, and notes from a backup file',
                              style: TextStyle(fontSize: 12, color: mutedColor, height: 1.3),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accentColor,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                minimumSize: const Size(0, 36),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              icon: const Icon(Icons.upload_rounded, size: 17),
                              label: const Text(
                                'Import Backup',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                              onPressed: () => _handleImport(context),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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

  Future<void> _handleExport(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Preparing backup file...'),
        duration: Duration(seconds: 1),
      ),
    );

    // Subtle 300ms pause so the preparation state is perceptible to the user
    await Future.delayed(const Duration(milliseconds: 300));

    final result = await BackupService.instance.exportUserData();
    if (!context.mounted) return;

    if (result.success) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
      final textColor = isDark ? AppColors.darkText : AppColors.lightText;
      final mutedColor = isDark ? AppColors.darkMuted : AppColors.lightMuted;
      final accentColor = isDark ? AppColors.darkAccent : AppColors.lightAccent;
      final lineColor = isDark ? AppColors.darkLine : AppColors.lightLine;

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: lineColor),
          ),
          contentPadding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _AnimatedTransferBadge(
                isDownload: true,
                accentColor: accentColor,
              ),
              const SizedBox(height: 16),
              Text(
                'Backup Downloaded',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'Backup file was successfully saved to your device:',
                style: TextStyle(fontSize: 12.5, color: mutedColor, height: 1.3),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              if (result.filePath != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface2 : AppColors.lightSurface2,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: lineColor),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.folder_outlined, size: 18, color: accentColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          result.filePath!,
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: textColor),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface2 : AppColors.lightSurface2,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: lineColor),
                ),
                child: Column(
                  children: [
                    _buildStatRow('🔖 Bookmarks', result.bookmarks, textColor),
                    const SizedBox(height: 6),
                    _buildStatRow('🖍️ Highlights', result.highlights, textColor),
                    const SizedBox(height: 6),
                    _buildStatRow('📝 Notes', result.notes, textColor),
                    if (result.history > 0) ...[
                      const SizedBox(height: 6),
                      _buildStatRow('🕒 Reading History', result.history, textColor),
                    ],
                  ],
                ),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  'Done',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      );
    } else if (result.message != null && result.message != 'Download cancelled') {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Export failed: ${result.message}'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  Future<void> _handleImport(BuildContext context) async {
    final result = await BackupService.instance.importUserData();
    if (result == null) return; // User cancelled

    if (!context.mounted) return;

    if (!result.success) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Import Failed'),
          content: Text(result.message ?? 'Could not read backup file.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    // Refresh all data providers immediately
    context.read<BookmarksProvider>().loadBookmarks();
    context.read<HighlightsProvider>().loadHighlights();
    context.read<NotesProvider>().loadNotes();
    context.read<BibleNavigationProvider>().reloadLastReadPosition();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final mutedColor = isDark ? AppColors.darkMuted : AppColors.lightMuted;
    final accentColor = isDark ? AppColors.darkAccent : AppColors.lightAccent;
    final lineColor = isDark ? AppColors.darkLine : AppColors.lightLine;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: lineColor),
        ),
        contentPadding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _AnimatedTransferBadge(
              isDownload: false,
              accentColor: accentColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Backup Restored',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'Your data was successfully restored to the app:',
              style: TextStyle(fontSize: 12.5, color: mutedColor, height: 1.3),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            if (result.filePath != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface2 : AppColors.lightSurface2,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: lineColor),
                ),
                child: Row(
                  children: [
                    Icon(Icons.insert_drive_file_outlined, size: 18, color: accentColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        result.filePath!,
                        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: textColor),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface2 : AppColors.lightSurface2,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: lineColor),
              ),
              child: Column(
                children: [
                  _buildStatRow('🔖 Bookmarks', result.bookmarks, textColor),
                  const SizedBox(height: 6),
                  _buildStatRow('🖍️ Highlights', result.highlights, textColor),
                  const SizedBox(height: 6),
                  _buildStatRow('📝 Notes', result.notes, textColor),
                  if (result.history > 0) ...[
                    const SizedBox(height: 6),
                    _buildStatRow('🕒 Reading History', result.history, textColor),
                  ],
                ],
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Done',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, int count, Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: textColor)),
        Text(
          '$count',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textColor),
        ),
      ],
    );
  }

  Widget _buildThemeOptionCard({
    required String title,
    required bool isDarkTheme,
    required bool isSelected,
    required Color accentColor,
    required Color lineColor,
    required Color surface2Color,
    required Color textColor,
    required Color mutedColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
          decoration: BoxDecoration(
            color: surface2Color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? accentColor : lineColor,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: _buildSelectionIndicator(isSelected, accentColor, mutedColor),
              ),
              const SizedBox(height: 6),
              _buildThemeMockup(isDarkTheme: isDarkTheme),
              const SizedBox(height: 14),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSystemOptionTile({
    required bool isSelected,
    required Color accentColor,
    required Color lineColor,
    required Color surface2Color,
    required Color textColor,
    required Color mutedColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: surface2Color,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? accentColor : lineColor,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.desktop_windows_outlined,
                size: 22,
                color: isSelected ? accentColor : textColor,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'System Default',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),
              _buildSelectionIndicator(isSelected, accentColor, mutedColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionIndicator(bool isSelected, Color accentColor, Color mutedColor) {
    if (isSelected) {
      return Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: accentColor,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check_rounded,
          size: 15,
          color: Colors.white,
        ),
      );
    }
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: mutedColor.withValues(alpha: 0.4),
          width: 2,
        ),
      ),
    );
  }

  Widget _buildThemeMockup({required bool isDarkTheme}) {
    final bgColor = isDarkTheme ? const Color(0xFF1E232A) : Colors.white;
    final barColor = isDarkTheme ? const Color(0xFF38434F) : const Color(0xFFDCE2EB);
    final itemColor = isDarkTheme ? const Color(0xFF2C3540) : const Color(0xFFE4E9F0);
    final borderColor = isDarkTheme ? const Color(0xFF2F3842) : const Color(0xFFDFE4E9);

    return Container(
      width: 90,
      height: 68,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkTheme ? 0.25 : 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 8,
            decoration: BoxDecoration(
              color: barColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: itemColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: itemColor,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(width: 6),
            ],
          ),
          const SizedBox(height: 7),
          Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: itemColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              Container(
                width: 32,
                height: 6,
                decoration: BoxDecoration(
                  color: itemColor,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AnimatedTransferBadge extends StatefulWidget {
  final bool isDownload; // true for download (export), false for upload (import)
  final Color accentColor;

  const _AnimatedTransferBadge({
    required this.isDownload,
    required this.accentColor,
  });

  @override
  State<_AnimatedTransferBadge> createState() => _AnimatedTransferBadgeState();
}

class _AnimatedTransferBadgeState extends State<_AnimatedTransferBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  late Animation<double> _arrowSlideAnimation;
  late Animation<double> _checkScaleAnimation;
  late Animation<double> _iconFadeOutAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    // Circular progress sweep from 0.0 -> 1.0
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.65, curve: Curves.easeInOutCubic),
      ),
    );

    // Arrow slide motion (slides down for download, up for upload)
    _arrowSlideAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: widget.isDownload ? 7.0 : -7.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: widget.isDownload ? 7.0 : -7.0, end: widget.isDownload ? -2.0 : 2.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: widget.isDownload ? -2.0 : 2.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 30,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.65),
      ),
    );

    // Fade out arrow when transitioning to checkmark
    _iconFadeOutAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.60, 0.72, curve: Curves.easeOut),
      ),
    );

    // Pop in checkmark with elastic bounce
    _checkScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.68, 1.0, curve: Curves.elasticOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final isCompleted = _controller.value >= 0.70;
        final progress = _progressAnimation.value;

        return SizedBox(
          width: 76,
          height: 76,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer Circular Progress Ring
              SizedBox(
                width: 72,
                height: 72,
                child: CircularProgressIndicator(
                  value: isCompleted ? 1.0 : progress,
                  strokeWidth: 3.5,
                  strokeCap: StrokeCap.round,
                  backgroundColor: widget.accentColor.withValues(alpha: 0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isCompleted ? Colors.green.shade600 : widget.accentColor,
                  ),
                ),
              ),

              // Inner Badge Circle
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? Colors.green.shade600
                      : widget.accentColor.withValues(alpha: 0.15),
                  boxShadow: isCompleted
                      ? [
                          BoxShadow(
                            color: Colors.green.withValues(alpha: 0.35),
                            blurRadius: 14,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Transfer Arrow Icon (animates & fades out)
                    if (_iconFadeOutAnimation.value > 0.0)
                      Opacity(
                        opacity: _iconFadeOutAnimation.value,
                        child: Transform.translate(
                          offset: Offset(0, _arrowSlideAnimation.value),
                          child: Icon(
                            widget.isDownload
                                ? Icons.file_download_rounded
                                : Icons.file_upload_rounded,
                            size: 30,
                            color: widget.accentColor,
                          ),
                        ),
                      ),

                    // Completed Checkmark Icon (pops in with elastic bounce)
                    if (_checkScaleAnimation.value > 0.0)
                      Transform.scale(
                        scale: _checkScaleAnimation.value,
                        child: const Icon(
                          Icons.check_rounded,
                          size: 34,
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
