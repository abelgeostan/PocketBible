import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../providers/bible_navigation_provider.dart';
import '../../../providers/bookmarks_provider.dart';
import '../../widgets/toast_notification.dart';
import '../reader/reader_screen.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bookmarks = context.watch<BookmarksProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final accentColor = isDark ? AppColors.darkAccent : AppColors.lightAccent;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final mutedColor = isDark ? AppColors.darkMuted : AppColors.lightMuted;
    final lineColor = isDark ? AppColors.darkLine : AppColors.lightLine;

    return Scaffold(
      appBar: AppBar(
        title: Text('${AppConstants.bookmarksTitle} (${bookmarks.count})'),
      ),
      body: bookmarks.isLoading
          ? const Center(child: CircularProgressIndicator())
          : bookmarks.bookmarks.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bookmark_border, size: 54, color: mutedColor.withValues(alpha: 0.5)),
                        const SizedBox(height: 12),
                        Text(
                          'No bookmarks yet.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: mutedColor),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'വായനയിൽ വചനത്തിന്മേൽ ടാപ്പ് ചെയ്ത് ബുക്ക്മാർക്ക് ചെയ്യാം.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: mutedColor),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  itemCount: bookmarks.bookmarks.length,
                  separatorBuilder: (_, __) => Divider(height: 1, color: lineColor),
                  itemBuilder: (context, index) {
                    final item = bookmarks.bookmarks[index];
                    return Dismissible(
                      key: Key('bm-${item.key}'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) {
                        bookmarks.removeBookmark(item.bookCode, item.chapter, item.verse);
                        ToastNotification.show(context, 'Bookmark removed');
                      },
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        title: Text(
                          item.reference,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: accentColor,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            item.text,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 13, color: textColor, height: 1.5),
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20),
                          color: mutedColor,
                          tooltip: 'Delete bookmark',
                          onPressed: () {
                            bookmarks.removeBookmark(item.bookCode, item.chapter, item.verse);
                            ToastNotification.show(context, 'Bookmark removed');
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
                      ),
                    );
                  },
                ),
    );
  }
}
