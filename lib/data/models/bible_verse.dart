class BibleVerse {
  final int id;
  final String bookCode;
  final String? bookName;
  final int chapter;
  final int verse;
  final String text;
  final bool isBookmarked;
  final String? highlightColor;
  final String? note;

  const BibleVerse({
    required this.id,
    required this.bookCode,
    this.bookName,
    required this.chapter,
    required this.verse,
    required this.text,
    this.isBookmarked = false,
    this.highlightColor,
    this.note,
  });

  String get reference => '${bookName ?? bookCode} $chapter:$verse';
  String get key => '$bookCode-$chapter-$verse';

  BibleVerse copyWith({
    int? id,
    String? bookCode,
    String? bookName,
    int? chapter,
    int? verse,
    String? text,
    bool? isBookmarked,
    String? highlightColor,
    bool clearHighlight = false,
    String? note,
    bool clearNote = false,
  }) {
    return BibleVerse(
      id: id ?? this.id,
      bookCode: bookCode ?? this.bookCode,
      bookName: bookName ?? this.bookName,
      chapter: chapter ?? this.chapter,
      verse: verse ?? this.verse,
      text: text ?? this.text,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      highlightColor: clearHighlight ? null : (highlightColor ?? this.highlightColor),
      note: clearNote ? null : (note ?? this.note),
    );
  }

  factory BibleVerse.fromMap(Map<String, dynamic> map, {String? bookName}) {
    return BibleVerse(
      id: map['id'] as int? ?? 0,
      bookCode: map['book_code'] as String? ?? (map['c'] as String? ?? ''),
      bookName: bookName ?? (map['book_name'] as String? ?? (map['b'] as String?)),
      chapter: map['chapter'] as int? ?? (map['ch'] as int? ?? 1),
      verse: map['verse'] as int? ?? (map['v'] as int? ?? 1),
      text: map['text'] as String? ?? (map['t'] as String? ?? ''),
      isBookmarked: map['is_bookmarked'] == 1,
      highlightColor: map['highlight_color'] as String?,
      note: map['note_text'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'book_code': bookCode,
    'chapter': chapter,
    'verse': verse,
    'text': text,
  };
}
