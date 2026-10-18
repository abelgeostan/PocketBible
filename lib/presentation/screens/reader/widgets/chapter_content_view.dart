import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../data/models/bible_book.dart';
import '../../../../data/models/bible_verse.dart';
import '../../../../data/repositories/bible_repository.dart';
import 'verse_item_widget.dart';

class ChapterContentView extends StatefulWidget {
  final BibleBook book;
  final int chapter;
  final bool hasPrevious;
  final bool hasNext;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final int? targetVerse;
  final int verseJumpToken;
  final ValueChanged<int>? onVerseVisible;

  const ChapterContentView({
    super.key,
    required this.book,
    required this.chapter,
    required this.hasPrevious,
    required this.hasNext,
    required this.onPrevious,
    required this.onNext,
    this.targetVerse,
    this.verseJumpToken = 0,
    this.onVerseVisible,
  });

  static final Map<String, List<BibleVerse>> _versesCache = {};

  static bool hasCached(String key) => _versesCache.containsKey(key);
  static List<BibleVerse>? getCached(String key) => _versesCache[key];
  static void setCached(String key, List<BibleVerse> verses) => _versesCache[key] = verses;

  @override
  State<ChapterContentView> createState() => _ChapterContentViewState();
}

class _ChapterContentViewState extends State<ChapterContentView> {
  final BibleRepository _bibleRepository = BibleRepository();
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _verseKeys = {};

  List<BibleVerse> _verses = [];
  bool _isLoading = true;
  int _lastJumpToken = -1;
  int? _highlightedVerse;
  Timer? _highlightTimer;
  int? _lastReportedVerse;
  bool _isProgrammaticScroll = false;

  @override
  void initState() {
    super.initState();
    _lastJumpToken = widget.verseJumpToken;
    _scrollController.addListener(_onScroll);
    final key = '${widget.book.code}-${widget.chapter}';
    if (ChapterContentView._versesCache.containsKey(key)) {
      _verses = ChapterContentView._versesCache[key]!;
      _isLoading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) => _checkTargetVerse());
    } else {
      _loadVerses();
    }
  }

  void _onScroll() {
    if (_isProgrammaticScroll) return;
    if (widget.onVerseVisible == null || _verses.isEmpty) return;

    if (_scrollController.hasClients && _scrollController.offset <= 15) {
      if (_lastReportedVerse != 1) {
        _lastReportedVerse = 1;
        widget.onVerseVisible!(1);
      }
      return;
    }

    final listContext = context;
    final listRenderBox = listContext.findRenderObject() as RenderBox?;
    if (listRenderBox == null || !listRenderBox.hasSize) return;

    final listTop = listRenderBox.localToGlobal(Offset.zero).dy;
    final referenceY = listTop + 15.0;

    int? visibleVerse;

    for (final v in _verses) {
      final key = _verseKeys[v.verse];
      final renderBox = key?.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null && renderBox.hasSize && renderBox.attached) {
        final verseTop = renderBox.localToGlobal(Offset.zero).dy;
        final verseBottom = verseTop + renderBox.size.height;

        if (verseTop <= referenceY && verseBottom > referenceY) {
          visibleVerse = v.verse;
          break;
        } else if (verseTop > referenceY) {
          visibleVerse ??= v.verse;
          break;
        }
      }
    }

    if (visibleVerse != null && visibleVerse != _lastReportedVerse) {
      _lastReportedVerse = visibleVerse;
      widget.onVerseVisible!(visibleVerse);
    }
  }

  @override
  void didUpdateWidget(covariant ChapterContentView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.book.code != oldWidget.book.code || widget.chapter != oldWidget.chapter) {
      _lastJumpToken = widget.verseJumpToken;
      final key = '${widget.book.code}-${widget.chapter}';
      if (ChapterContentView._versesCache.containsKey(key)) {
        setState(() {
          _verses = ChapterContentView._versesCache[key]!;
          _isLoading = false;
        });
        _checkTargetVerse();
      } else {
        _loadVerses();
      }
    } else if (widget.verseJumpToken != _lastJumpToken && widget.targetVerse != null) {
      _lastJumpToken = widget.verseJumpToken;
      _checkTargetVerse();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _highlightTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadVerses() async {
    setState(() => _isLoading = true);
    final verses = await _bibleRepository.getChapterVerses(widget.book.code, widget.chapter);
    ChapterContentView._versesCache['${widget.book.code}-${widget.chapter}'] = verses;

    if (mounted) {
      setState(() {
        _verses = verses;
        _isLoading = false;
      });
      _checkTargetVerse();
    }
  }

  void _checkTargetVerse() {
    if (widget.targetVerse != null && widget.targetVerse! > 1) {
      final target = widget.targetVerse!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToVerse(target);
        _startHighlightTimer(target);
      });
    } else if (widget.targetVerse == 1) {
      if (_scrollController.hasClients && _scrollController.offset > 15) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToVerse(1);
        });
      }
      _highlightTimer?.cancel();
      if (_highlightedVerse != null) {
        setState(() => _highlightedVerse = null);
      }
    } else {
      _highlightTimer?.cancel();
      if (_highlightedVerse != null) {
        setState(() => _highlightedVerse = null);
      }
    }
  }

  void _startHighlightTimer(int verseNumber) {
    _highlightTimer?.cancel();
    if (verseNumber <= 1) {
      if (_highlightedVerse != null) {
        setState(() => _highlightedVerse = null);
      }
      return;
    }

    setState(() => _highlightedVerse = verseNumber);
    _highlightTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _highlightedVerse = null);
      }
    });
  }

  void _scrollToVerse(int verseNumber) {
    if (!_scrollController.hasClients) return;

    _lastReportedVerse = verseNumber;
    _isProgrammaticScroll = true;

    void done() {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _isProgrammaticScroll = false;
        }
      });
    }

    if (verseNumber <= 1) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      ).then((_) => done());
      return;
    }

    final key = _verseKeys[verseNumber];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        alignment: 0.0,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      ).then((_) => done());
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final retryKey = _verseKeys[verseNumber];
        if (retryKey?.currentContext != null && _scrollController.hasClients) {
          Scrollable.ensureVisible(
            retryKey!.currentContext!,
            alignment: 0.0,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOutCubic,
          ).then((_) => done());
        } else {
          done();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final lineColor = isDark ? AppColors.darkLine : AppColors.lightLine;
    final accentColor = isDark ? AppColors.darkAccent : AppColors.lightAccent;

    return ListView(
      key: PageStorageKey('chapter_${widget.book.code}_${widget.chapter}'),
      controller: _scrollController,
      padding: EdgeInsets.zero,
      children: [
            // Chapter Content Widget (Bible Text Card - moves with swipe)
            if (_isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 60),
            child: Center(child: CircularProgressIndicator()),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: lineColor),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black26 : const Color.fromRGBO(20, 30, 40, 0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _verses.map((verse) {
                return Container(
                  key: _verseKeys.putIfAbsent(verse.verse, () => GlobalKey()),
                  padding: const EdgeInsets.only(bottom: 6),
                  child: VerseItemWidget(
                    verse: verse,
                    isTargeted: _highlightedVerse == verse.verse,
                  ),
                );
              }).toList(),
            ),
          ),

        const SizedBox(height: 20),

        // 3. Navigation Buttons
        Container(
          padding: const EdgeInsets.only(top: 24, bottom: 16),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: lineColor)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (widget.hasPrevious)
                InkWell(
                  onTap: widget.onPrevious,
                  borderRadius: BorderRadius.circular(9),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(color: lineColor),
                    ),
                    child: Text(
                      AppConstants.previousChapter,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: accentColor,
                      ),
                    ),
                  ),
                )
              else
                const SizedBox.shrink(),
              if (widget.hasNext)
                InkWell(
                  onTap: widget.onNext,
                  borderRadius: BorderRadius.circular(9),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(color: lineColor),
                    ),
                    child: Text(
                      AppConstants.nextChapter,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: accentColor,
                      ),
                    ),
                  ),
                )
              else
                const SizedBox.shrink(),
            ],
          ),
        ),

        const SizedBox(height: 30),
      ],
    );
  }
}
