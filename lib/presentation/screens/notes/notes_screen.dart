import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../providers/bible_navigation_provider.dart';
import '../../../providers/notes_provider.dart';
import '../../widgets/toast_notification.dart';
import '../reader/reader_screen.dart';

class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notes = context.watch<NotesProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final accentColor = isDark ? AppColors.darkAccent : AppColors.lightAccent;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final mutedColor = isDark ? AppColors.darkMuted : AppColors.lightMuted;
    final lineColor = isDark ? AppColors.darkLine : AppColors.lightLine;
    final surface2Color = isDark ? AppColors.darkSurface2 : AppColors.lightSurface2;

    return Scaffold(
      appBar: AppBar(
        title: Text('${AppConstants.notesTitle} (${notes.count})'),
      ),
      body: notes.isLoading
          ? const Center(child: CircularProgressIndicator())
          : notes.notes.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.note_alt_outlined, size: 54, color: mutedColor.withValues(alpha: 0.5)),
                        const SizedBox(height: 12),
                        Text(
                          'No notes yet.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: mutedColor),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'വായനയിൽ വചനത്തിന്മേൽ ടാപ്പ് ചെയ്ത് കുറിപ്പുകൾ രേഖപ്പെടുത്താം.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: mutedColor),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  itemCount: notes.notes.length,
                  separatorBuilder: (_, __) => Divider(height: 1, color: lineColor),
                  itemBuilder: (context, index) {
                    final item = notes.notes[index];

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      title: Text(
                        item.reference,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: accentColor,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (item.verseText != null) ...[
                            const SizedBox(height: 3),
                            Text(
                              item.verseText!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 12, color: mutedColor, fontStyle: FontStyle.italic),
                            ),
                          ],
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: surface2Color,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item.noteText,
                              style: TextStyle(fontSize: 13, color: textColor, height: 1.4),
                            ),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20),
                        color: mutedColor,
                        tooltip: 'Delete note',
                        onPressed: () {
                          notes.deleteNote(item.bookCode, item.chapter, item.verse);
                          ToastNotification.show(context, 'കുറിപ്പ് നീക്കം ചെയ്തു');
                        },
                      ),
                      onTap: () {
                        final nav = context.read<BibleNavigationProvider>();
                        nav.navigateTo(item.bookCode, item.chapter, verse: item.verse);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ReaderScreen()),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
