import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../data/models/daily_verse.dart';
import '../../../../data/repositories/bible_repository.dart';
import '../../../../providers/bible_navigation_provider.dart';
import '../../../widgets/toast_notification.dart';
import '../../reader/reader_screen.dart';

class DailyVerseCard extends StatefulWidget {
  const DailyVerseCard({super.key});

  @override
  State<DailyVerseCard> createState() => _DailyVerseCardState();
}

class _DailyVerseCardState extends State<DailyVerseCard> {
  final BibleRepository _repository = BibleRepository();
  DailyVerse? _dailyVerse;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDailyVerse();
  }

  Future<void> _loadDailyVerse() async {
    final verse = await _repository.getTodayVerse();
    if (mounted) {
      setState(() {
        _dailyVerse = verse;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    if (_dailyVerse == null) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final lineColor = isDark ? AppColors.darkLine : AppColors.lightLine;
    final accentColor = isDark ? AppColors.darkAccent : AppColors.lightAccent;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final mutedColor = isDark ? AppColors.darkMuted : AppColors.lightMuted;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: lineColor),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : const Color.fromRGBO(20, 30, 40, 0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with Badge and Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.wb_sunny_rounded, size: 13, color: accentColor),
                    const SizedBox(width: 5),
                    Text(
                      AppConstants.dailyVerseKicker,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: accentColor,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    color: mutedColor,
                    tooltip: 'Copy verse',
                    padding: const EdgeInsets.all(6),
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(
                        text: '${_dailyVerse!.reference} — ${_dailyVerse!.text}',
                      ));
                      ToastNotification.show(context, 'Verse copied');
                    },
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    icon: const Icon(Icons.share_rounded, size: 18),
                    color: mutedColor,
                    tooltip: 'Share verse',
                    padding: const EdgeInsets.all(6),
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      Share.share(
                        '${_dailyVerse!.reference}\n${_dailyVerse!.text}\n\n${AppConstants.websiteUrl}',
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Reference Title
          Text(
            _dailyVerse!.reference,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),

          // Verse Content
          Container(
            padding: const EdgeInsets.only(left: 10),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: accentColor.withValues(alpha: 0.4),
                  width: 3,
                ),
              ),
            ),
            child: Text(
              _dailyVerse!.text,
              style: TextStyle(
                fontSize: 15,
                height: 1.8,
                color: textColor.withValues(alpha: 0.9),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Read Chapter Button
          InkWell(
            onTap: () {
              final nav = context.read<BibleNavigationProvider>();
              nav.navigateTo(
                _dailyVerse!.bookCode,
                _dailyVerse!.chapter,
                verse: _dailyVerse!.verse,
              );
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const ReaderScreen()),
              );
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Read chapter',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: accentColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 15,
                    color: accentColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
