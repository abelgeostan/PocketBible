import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../data/models/bible_book.dart';
import '../../../../data/models/bible_verse.dart';
import '../../../../data/repositories/bible_repository.dart';
import 'verse_item_widget.dart';

class SavedChapterPosition {
  final String key;
  final double offset;
  final int visibleVerse;

  const SavedChapterPosition({
    required this.key,
    required this.offset,
    required this.visibleVerse,
  });
}

class ChapterContentView extends StatefulWidget {
  final BibleBook book;
  final int chapter;
  final bool isCurrent;
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
    this.isCurrent = false,
    required this.hasPrevious,
    required this.hasNext,
    required this.onPrevious,
    required this.onNext,
    this.targetVerse,
    this.verseJumpToken = 0,
    this.onVerseVisible,
  });

  static final Map<String, List<BibleVerse>> _versesCache = {};
  static SavedChapterPosition? _immediatePreviousPosition;
  static final Map<String, _ChapterContentViewState> _activeStates = {};

  static bool hasCached(String key) => _versesCache.containsKey(key);
  static List<BibleVerse>? getCached(String key) => _versesCache[key];
  static void setCached(String key, List<BibleVerse> verses) => _versesCache[key] = verses;

  static void onChapterChanged({
    required String oldBookCode,
    required int oldChapter,
    required String newBookCode,
    required int newChapter,
    required bool isAdjacentSwipe,
  }) {
    final oldKey = '$oldBookCode-$oldChapter';
    final newKey = '$newBookCode-$newChapter';

    if (!isAdjacentSwipe) {
      _immediatePreviousPosition = null;
      for (final state in _activeStates.values) {
        state.resetToTop();
      }
      return;
    }

    final isReturningToSaved = _immediatePreviousPosition != null &&
        _immediatePreviousPosition!.key == newKey;

    if (isReturningToSaved) {
      final saved = _immediatePreviousPosition!;
      final newState = _activeStates[newKey];
      if (newState != null && newState.mounted) {
        newState.restorePosition(saved.offset, saved.visibleVerse);
      }
    } else {
      final newState = _activeStates[newKey];
      if (newState != null && newState.mounted) {
        newState.resetToTop();
      }
      for (final entry in _activeStates.entries) {
        if (entry.key != newKey && entry.key != oldKey) {
          entry.value.resetToTop();
        }
      }
    }

    final oldState = _activeStates[oldKey];
    final oldOffset = oldState?.currentOffset ?? 0.0;
    final oldVerse = oldState?.currentVisibleVerse ?? 1;
    _immediatePreviousPosition = SavedChapterPosition(
      key: oldKey,
      offset: oldOffset,
      visibleVerse: oldVerse,
    );
  }

  @override
  State<ChapterContentView> createState() => _ChapterContentViewState();
}

class _ChapterContentViewState extends State<ChapterContentView> {
  final BibleRepository _bibleRepository = BibleRepository();
  late final ScrollController _scrollController;
  final Map<int, GlobalKey> _verseKeys = {};

  List<BibleVerse> _verses = [];
  bool _isLoading = true;
  int _lastJumpToken = -1;
  int? _highlightedVerse;
  Timer? _highlightTimer;
  int? _lastReportedVerse;
  bool _isProgrammaticScroll = false;
  double _currentOffset = 0.0;

  double get currentOffset => _currentOffset;
  int get currentVisibleVerse => _lastReportedVerse ?? 1;

  void restorePosition(double offset, int verse) {
    _currentOffset = offset;
    _lastReportedVerse = verse;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scrollController.hasClients) {
        if ((_scrollController.offset - offset).abs() > 1.0) {
          _scrollController.jumpTo(offset);
        }
      }
    });
  }

  void resetToTop() {
    _currentOffset = 0.0;
    _lastReportedVerse = 1;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scrollController.hasClients) {
        if (_scrollController.offset > 0.0) {
          _scrollController.jumpTo(0.0);
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _lastJumpToken = widget.verseJumpToken;
    final key = '${widget.book.code}-${widget.chapter}';
    ChapterContentView._activeStates[key] = this;

    final isSaved = ChapterContentView._immediatePreviousPosition != null &&
        ChapterContentView._immediatePreviousPosition!.key == key;
    final initialOffset = isSaved ? ChapterContentView._immediatePreviousPosition!.offset : 0.0;
    _currentOffset = initialOffset;
    if (isSaved) {
      _lastReportedVerse = ChapterContentView._immediatePreviousPosition!.visibleVerse;
    }

    _scrollController = ScrollController(initialScrollOffset: initialOffset);
    _scrollController.addListener(_onScroll);

    if (ChapterContentView._versesCache.containsKey(key)) {
      _verses = ChapterContentView._versesCache[key]!;
      _isLoading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _checkTargetVerse();
        if (widget.isCurrent) {
          _reportVisibleVerse();
        }
      });
    } else {
      _loadVerses();
    }
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      _currentOffset = _scrollController.offset;
    }
    if (_isProgrammaticScroll) return;
    if (widget.onVerseVisible == null || _verses.isEmpty) return;

    final visibleVerse = _determineVisibleVerse();
    if (visibleVerse != null && visibleVerse != _lastReportedVerse) {
      _lastReportedVerse = visibleVerse;
      widget.onVerseVisible!(visibleVerse);
    }
  }

  int? _determineVisibleVerse() {
    if (_scrollController.hasClients && _scrollController.offset <= 15) {
      return 1;
    }

    final listContext = context;
    final listRenderBox = listContext.findRenderObject() as RenderBox?;
    if (listRenderBox == null || !listRenderBox.hasSize) return _lastReportedVerse ?? 1;

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

    return visibleVerse ?? _lastReportedVerse ?? 1;
  }

  void _reportVisibleVerse() {
    if (widget.onVerseVisible == null || _verses.isEmpty) return;
    final verse = _determineVisibleVerse();
    if (verse != null && verse != _lastReportedVerse) {
      _lastReportedVerse = verse;
      widget.onVerseVisible!(verse);
    }
  }

  @override
  void didUpdateWidget(covariant ChapterContentView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.book.code != oldWidget.book.code || widget.chapter != oldWidget.chapter) {
      ChapterContentView._activeStates.remove('${oldWidget.book.code}-${oldWidget.chapter}');
      final key = '${widget.book.code}-${widget.chapter}';
      ChapterContentView._activeStates[key] = this;

      _lastJumpToken = widget.verseJumpToken;
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

    if (widget.isCurrent && !oldWidget.isCurrent) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _reportVisibleVerse();
      });
    }
  }

  @override
  void dispose() {
    final key = '${widget.book.code}-${widget.chapter}';
    if (ChapterContentView._activeStates[key] == this) {
      ChapterContentView._activeStates.remove(key);
    }
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
      if (widget.isCurrent) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _reportVisibleVerse();
        });
      }
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
