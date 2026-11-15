import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/backup_service.dart';
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

          const SizedBox(height: 24),

          // Section: Data Backup & Restore
          _buildSectionTitle('ഡാറ്റ ബാക്കപ്പും പുനഃസ്ഥാപനവും (Backup & Restore)', accentColor),
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
                              'ഡാറ്റ എക്സ്പോർട്ട് ചെയ്യുക',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Save your bookmarks, highlights, and notes to your device.',
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
                              'ഡാറ്റ ഇംപോർട്ട് ചെയ്യുക',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Restore bookmarks, highlights, and notes from a backup file.',
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
        content: Text('ബാക്കപ്പ് ഫയൽ തയ്യാറാക്കുന്നു... (Preparing backup...)'),
        duration: Duration(seconds: 1),
      ),
    );

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
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: lineColor),
          ),
          title: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.green.shade600, size: 26),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'ബാക്കപ്പ് ഡൗൺലോഡ് ചെയ്തു',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textColor),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ബാക്കപ്പ് ഫയൽ നിങ്ങളുടെ ഫോണിൽ വിജയകരമായി സേവ് ചെയ്തു (Backup downloaded successfully):',
                style: TextStyle(fontSize: 13, color: mutedColor, height: 1.4),
              ),
              if (result.filePath != null) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface2 : AppColors.lightSurface2,
                    borderRadius: BorderRadius.circular(8),
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
              ],
              const SizedBox(height: 14),
              _buildStatRow('🔖 ബുക്ക്‌മാർക്കുകൾ (Bookmarks)', result.bookmarks, textColor),
              const SizedBox(height: 6),
              _buildStatRow('🖍️ ഹൈലൈറ്റുകൾ (Highlights)', result.highlights, textColor),
              const SizedBox(height: 6),
              _buildStatRow('📝 കുറിപ്പുകൾ (Notes)', result.notes, textColor),
              if (result.history > 0) ...[
                const SizedBox(height: 6),
                _buildStatRow('🕒 വായനാ ചരിത്രം (History)', result.history, textColor),
              ],
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('ശരി (OK)'),
            ),
          ],
        ),
      );
    } else if (result.message != null && result.message != 'Download cancelled') {
      messenger.showSnackBar(
        SnackBar(
          content: Text('ഡൗൺലോഡ് പരാജയപ്പെട്ടു: ${result.message}'),
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
          title: const Text('ഇംപോർട്ട് പരാജയപ്പെട്ടു (Import Failed)'),
          content: Text(result.message ?? 'ബാക്കപ്പ് ഫയൽ വായിക്കാൻ കഴിഞ്ഞില്ല.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('ശരി (OK)'),
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
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: lineColor),
        ),
        title: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.green.shade600, size: 26),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'ഇംപോർട്ട് പൂർത്തിയായി',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textColor),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'നിങ്ങളുടെ വിവരങ്ങൾ വിജയകരമായി പുനഃസ്ഥാപിച്ചു (Backup successfully restored):',
              style: TextStyle(fontSize: 13, color: mutedColor),
            ),
            if (result.filePath != null) ...[
              const SizedBox(height: 8),
              Text(
                'File: ${result.filePath}',
                style: TextStyle(fontSize: 11.5, color: accentColor, fontWeight: FontWeight.w600),
              ),
            ],
            const SizedBox(height: 14),
            _buildStatRow('🔖 ബുക്ക്‌മാർക്കുകൾ (Bookmarks)', result.bookmarks, textColor),
            const SizedBox(height: 6),
            _buildStatRow('🖍️ ഹൈലൈറ്റുകൾ (Highlights)', result.highlights, textColor),
            const SizedBox(height: 6),
            _buildStatRow('📝 കുറിപ്പുകൾ (Notes)', result.notes, textColor),
            if (result.history > 0) ...[
              const SizedBox(height: 6),
              _buildStatRow('🕒 വായനാ ചരിത്രം (History)', result.history, textColor),
            ],
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ശരി (OK)'),
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
}
