import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/bible_book.dart';
import '../../data/repositories/bible_repository.dart';

class VersePickerModal extends StatefulWidget {
  final BibleBook book;
  final int chapter;
  final int? currentVerse;
  final Function(int verse) onVerseSelected;

  const VersePickerModal({
    super.key,
    required this.book,
    required this.chapter,
    this.currentVerse,
    required this.onVerseSelected,
  });

  static Future<int?> show(
    BuildContext context, {
    required BibleBook book,
    required int chapter,
    int? currentVerse,
  }) {
    return showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => VersePickerModal(
        book: book,
        chapter: chapter,
        currentVerse: currentVerse,
        onVerseSelected: (v) => Navigator.pop(ctx, v),
      ),
    );
  }

  @override
  State<VersePickerModal> createState() => _VersePickerModalState();
}

class _VersePickerModalState extends State<VersePickerModal> {
  int _totalVerses = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVerseCount();
  }

  Future<void> _loadVerseCount() async {
    final repo = BibleRepository();
    final count = await repo.getVerseCount(widget.book.code, widget.chapter);
    if (mounted) {
      setState(() {
        _totalVerses = count > 0 ? count : 30; // fallback if empty
        _isLoading = false;
      });
    }
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

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, -5)),
        ],
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: lineColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title & Close
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.book.name} ${widget.chapter}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    Text(
                      _isLoading
                          ? 'വാക്യം തിരഞ്ഞെടുക്കുക...'
                          : 'വാക്യം തിരഞ്ഞെടുക്കുക ($_totalVerses വാക്യങ്ങൾ)',
                      style: TextStyle(fontSize: 12, color: mutedColor),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  color: mutedColor,
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Verse Grid
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: accentColor,
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: _totalVerses,
                    itemBuilder: (context, index) {
                      final verseNum = index + 1;
                      final isSelected = verseNum == widget.currentVerse;

                      return InkWell(
                        onTap: () => widget.onVerseSelected(verseNum),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected ? accentColor : surface2Color,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected ? accentColor : lineColor,
                              width: 1,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '$verseNum',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? AppColors.darkText : AppColors.lightText),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
