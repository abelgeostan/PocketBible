import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/bible_verse.dart';
import 'toast_notification.dart';

class VerseActionsModal extends StatelessWidget {
  final BuildContext parentContext;
  final BibleVerse verse;
  final bool isBookmarked;
  final String? currentHighlight;
  final String? currentNote;
  final VoidCallback onToggleBookmark;
  final Function(String color) onSetHighlight;
  final VoidCallback onRemoveHighlight;
  final Function(String note) onSaveNote;
  final VoidCallback onDeleteNote;

  const VerseActionsModal({
    super.key,
    required this.parentContext,
    required this.verse,
    required this.isBookmarked,
    this.currentHighlight,
    this.currentNote,
    required this.onToggleBookmark,
    required this.onSetHighlight,
    required this.onRemoveHighlight,
    required this.onSaveNote,
    required this.onDeleteNote,
  });

  static void show({
    required BuildContext context,
    required BibleVerse verse,
    required bool isBookmarked,
    String? currentHighlight,
    String? currentNote,
    required VoidCallback onToggleBookmark,
    required Function(String color) onSetHighlight,
    required VoidCallback onRemoveHighlight,
    required Function(String note) onSaveNote,
    required VoidCallback onDeleteNote,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => VerseActionsModal(
        parentContext: context,
        verse: verse,
        isBookmarked: isBookmarked,
        currentHighlight: currentHighlight,
        currentNote: currentNote,
        onToggleBookmark: onToggleBookmark,
        onSetHighlight: onSetHighlight,
        onRemoveHighlight: onRemoveHighlight,
        onSaveNote: onSaveNote,
        onDeleteNote: onDeleteNote,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final surface2Color = isDark ? AppColors.darkSurface2 : AppColors.lightSurface2;
    final lineColor = isDark ? AppColors.darkLine : AppColors.lightLine;
    final accentColor = isDark ? AppColors.darkAccent : AppColors.lightAccent;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final mutedColor = isDark ? AppColors.darkMuted : AppColors.lightMuted;

    final formattedVerse = '${verse.bookName ?? verse.bookCode} ${verse.chapter}:${verse.verse} — ${verse.text}';

    return Container(
      padding: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, -5)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: lineColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${verse.bookName ?? verse.bookCode} ${verse.chapter}:${verse.verse}',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: accentColor,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(context),
                  color: mutedColor,
                ),
              ],
            ),
          ),

          // Verse Text Preview
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: surface2Color,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: lineColor),
              ),
              child: Text(
                verse.text,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: textColor,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Highlight color strip
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  'Highlight:',
                  style: TextStyle(fontSize: 13, color: mutedColor, fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 12),
                _buildColorCircle(
                  color: AppColors.getHighlightColor('yellow', isDark),
                  isSelected: currentHighlight == 'yellow',
                  onTap: () {
                    onSetHighlight('yellow');
                    Navigator.pop(context);
                    ToastNotification.show(context, 'ഹൈലൈറ്റ് ചെയ്തു');
                  },
                ),
                const SizedBox(width: 8),
                _buildColorCircle(
                  color: AppColors.getHighlightColor('green', isDark),
                  isSelected: currentHighlight == 'green',
                  onTap: () {
                    onSetHighlight('green');
                    Navigator.pop(context);
                    ToastNotification.show(context, 'ഹൈലൈറ്റ് ചെയ്തു');
                  },
                ),
                const SizedBox(width: 8),
                _buildColorCircle(
                  color: AppColors.getHighlightColor('blue', isDark),
                  isSelected: currentHighlight == 'blue',
                  onTap: () {
                    onSetHighlight('blue');
                    Navigator.pop(context);
                    ToastNotification.show(context, 'ഹൈലൈറ്റ് ചെയ്തു');
                  },
                ),
                const SizedBox(width: 8),
                _buildColorCircle(
                  color: AppColors.getHighlightColor('pink', isDark),
                  isSelected: currentHighlight == 'pink',
                  onTap: () {
                    onSetHighlight('pink');
                    Navigator.pop(context);
                    ToastNotification.show(context, 'ഹൈലൈറ്റ് ചെയ്തു');
                  },
                ),
                if (currentHighlight != null) ...[
                  const Spacer(),
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red[400],
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                    icon: const Icon(Icons.clear, size: 16),
                    label: const Text('Clear', style: TextStyle(fontSize: 12)),
                    onPressed: () {
                      onRemoveHighlight();
                      Navigator.pop(context);
                      ToastNotification.show(context, 'ഹൈലൈറ്റ് നീക്കം ചെയ്തു');
                    },
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 8),

          // Primary Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(
                  context,
                  icon: isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  label: isBookmarked ? 'Bookmarked' : 'Bookmark',
                  isSelected: isBookmarked,
                  onTap: () {
                    onToggleBookmark();
                    Navigator.pop(context);
                    ToastNotification.show(
                      context,
                      isBookmarked ? 'ബുക്ക്മാർക്ക് നീക്കം ചെയ്തു' : 'ബുക്ക്മാർക്ക് ചെയ്തു',
                    );
                  },
                ),
                _buildActionButton(
                  context,
                  icon: Icons.copy,
                  label: 'Copy',
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: formattedVerse));
                    Navigator.pop(context);
                    ToastNotification.show(context, 'Verse copied');
                  },
                ),
                _buildActionButton(
                  context,
                  icon: Icons.share,
                  label: 'Share',
                  onTap: () {
                    Navigator.pop(context);
                    Share.share(
                      '$formattedVerse\n\n${AppConstants.shareAttribution}',
                      subject: '${verse.bookName} ${verse.chapter}:${verse.verse}',
                    );
                  },
                ),
                _buildActionButton(
                  context,
                  icon: currentNote != null ? Icons.note : Icons.note_add_outlined,
                  label: currentNote != null ? 'Edit Note' : 'Note',
                  isSelected: currentNote != null,
                  onTap: () {
                    Navigator.pop(context);
                    _showNoteDialog(parentContext);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorCircle({
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.black : Colors.black26,
            width: isSelected ? 2.5 : 1,
          ),
        ),
        child: isSelected ? const Icon(Icons.check, size: 18, color: Colors.black87) : null,
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    bool isSelected = false,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? AppColors.darkAccent : AppColors.lightAccent;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final color = isSelected ? accentColor : textColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNoteDialog(BuildContext hostContext) {
    final controller = TextEditingController(text: currentNote ?? '');
    showDialog(
      context: hostContext,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'കുറിപ്പ് എഴുതുക (${verse.bookName ?? verse.bookCode} ${verse.chapter}:${verse.verse})',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        content: TextField(
          controller: controller,
          maxLines: 5,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'നിങ്ങളുടെ കുറിപ്പുകൾ ഇവിടെ രേഖപ്പെടുത്തുക...',
          ),
        ),
        actions: [
          if (currentNote != null)
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () {
                Navigator.pop(dialogContext);
                onDeleteNote();
                if (hostContext.mounted) {
                  ToastNotification.show(hostContext, 'കുറിപ്പ് നീക്കം ചെയ്തു');
                }
              },
              child: const Text('Delete'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = controller.text.trim();
              Navigator.pop(dialogContext);
              if (text.isNotEmpty) {
                onSaveNote(text);
                if (hostContext.mounted) {
                  ToastNotification.show(hostContext, 'കുറിപ്പ് സൂക്ഷിച്ചു');
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
