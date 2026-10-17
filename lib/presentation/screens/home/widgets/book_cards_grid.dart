import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/bible_book.dart';
import '../../../../providers/bible_navigation_provider.dart';
import '../../reader/reader_screen.dart';

class BookCardsGrid extends StatelessWidget {
  final List<BibleBook> books;
  final String title;

  const BookCardsGrid({
    super.key,
    required this.books,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    if (books.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final lineColor = isDark ? AppColors.darkLine : AppColors.lightLine;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(bottom: 8, top: 20),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: lineColor)),
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // List of Book Cards
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: books.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            final book = books[index];
            return _BookCard(book: book);
          },
        ),
      ],
    );
  }
}

class _BookCard extends StatelessWidget {
  final BibleBook book;

  const _BookCard({required this.book});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final surface2Color = isDark ? AppColors.darkSurface2 : AppColors.lightSurface2;
    final lineColor = isDark ? AppColors.darkLine : AppColors.lightLine;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final mutedColor = isDark ? AppColors.darkMuted : AppColors.lightMuted;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: lineColor),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(20, 30, 40, 0.03),
            blurRadius: 15,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  book.name,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
              ),
              Text(
                '${book.totalChapters} Ch',
                style: TextStyle(
                  fontSize: 12,
                  color: mutedColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Wrap of Chapter pills (matching .chapter-grid a)
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: book.chapters.map((ch) {
              return InkWell(
                onTap: () {
                  final nav = context.read<BibleNavigationProvider>();
                  nav.navigateTo(book.code, ch);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ReaderScreen()),
                  );
                },
                borderRadius: BorderRadius.circular(7),
                child: Container(
                  width: 36,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: surface2Color,
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(color: lineColor),
                  ),
                  child: Text(
                    '$ch',
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: mutedColor,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
