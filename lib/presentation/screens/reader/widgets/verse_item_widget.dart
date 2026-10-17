import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/bible_verse.dart';
import '../../../../providers/bookmarks_provider.dart';
import '../../../../providers/highlights_provider.dart';
import '../../../../providers/notes_provider.dart';
import '../../../../providers/reader_settings_provider.dart';
import '../../../widgets/verse_actions_modal.dart';

class VerseItemWidget extends StatelessWidget {
  final BibleVerse verse;
  final bool isTargeted;

  const VerseItemWidget({
    super.key,
    required this.verse,
    this.isTargeted = false,
  });

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<ReaderSettingsProvider>();
    final bookmarks = context.watch<BookmarksProvider>();
    final highlights = context.watch<HighlightsProvider>();
    final notes = context.watch<NotesProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final isBookmarked = bookmarks.isBookmarked(verse.bookCode, verse.chapter, verse.verse);
    final highlightColorName = highlights.getHighlightColor(verse.bookCode, verse.chapter, verse.verse);
    final noteText = notes.getNoteText(verse.bookCode, verse.chapter, verse.verse);

    final accentColor = isDark ? AppColors.darkAccent : AppColors.lightAccent;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final mutedColor = isDark ? AppColors.darkMuted : AppColors.lightMuted;

    Color? backgroundColor;
    if (highlightColorName != null) {
      backgroundColor = AppColors.getHighlightColor(highlightColorName, isDark);
    } else if (isTargeted && verse.verse != 1) {
      backgroundColor = (isDark ? AppColors.darkAccent : AppColors.lightAccent).withValues(alpha: 0.18);
    }

    return InkWell(
      onTap: () {
        VerseActionsModal.show(
          context: context,
          verse: verse,
          isBookmarked: isBookmarked,
          currentHighlight: highlightColorName,
          currentNote: noteText,
          onToggleBookmark: () {
            bookmarks.toggleBookmark(
              bookCode: verse.bookCode,
              bookName: verse.bookName ?? verse.bookCode,
              chapter: verse.chapter,
              verse: verse.verse,
              text: verse.text,
            );
          },
          onSetHighlight: (color) {
            highlights.setHighlight(
              bookCode: verse.bookCode,
              bookName: verse.bookName,
              chapter: verse.chapter,
              verse: verse.verse,
              color: color,
              text: verse.text,
            );
          },
          onRemoveHighlight: () {
            highlights.removeHighlight(verse.bookCode, verse.chapter, verse.verse);
          },
          onSaveNote: (note) {
            notes.saveNote(
              bookCode: verse.bookCode,
              bookName: verse.bookName,
              chapter: verse.chapter,
              verse: verse.verse,
              verseText: verse.text,
              noteText: note,
            );
          },
          onDeleteNote: () {
            notes.deleteNote(verse.bookCode, verse.chapter, verse.verse);
          },
        );
      },
      borderRadius: BorderRadius.circular(6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                children: [
                  if (settings.showVerseNumbers)
                    WidgetSpan(
                      alignment: PlaceholderAlignment.top,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 6, top: 1),
                        child: Text(
                          '${verse.verse}',
                          style: TextStyle(
                            fontFamily: 'Arial',
                            fontSize: (settings.fontSize * 0.72).clamp(11.0, 16.0),
                            fontWeight: FontWeight.w700,
                            color: isBookmarked ? accentColor : (isDark ? AppColors.darkAccent2 : AppColors.lightAccent2),
                          ),
                        ),
                      ),
                    ),
                  TextSpan(
                    text: verse.text,
                    style: TextStyle(
                      fontFamily: 'Noto Sans Malayalam',
                      fontSize: settings.fontSize,
                      height: settings.lineSpacing,
                      color: textColor,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            // Optional Indicators for Bookmark & Notes
            if (isBookmarked || noteText != null) ...[
              const SizedBox(height: 3),
              Row(
                children: [
                  if (isBookmarked) ...[
                    Icon(Icons.bookmark, size: 14, color: accentColor),
                    const SizedBox(width: 4),
                  ],
                  if (noteText != null) ...[
                    Icon(Icons.note_alt, size: 14, color: mutedColor),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        noteText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          color: mutedColor,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
