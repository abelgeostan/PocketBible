class HighlightItem {
  final int? id;
  final String bookCode;
  final String? bookName;
  final int chapter;
  final int verse;
  final String color; // yellow, green, blue, pink
  final String? text;
  final int createdAt;

  HighlightItem({
    this.id,
    required this.bookCode,
    this.bookName,
    required this.chapter,
    required this.verse,
    required this.color,
    this.text,
    required this.createdAt,
  });

  String get key => '$bookCode-$chapter-$verse';
  String get reference => '${bookName ?? bookCode} $chapter:$verse';

  factory HighlightItem.fromMap(Map<String, dynamic> map) {
    return HighlightItem(
      id: map['id'] as int?,
      bookCode: map['book_code'] as String,
      bookName: map['book_name'] as String?,
      chapter: map['chapter'] as int,
      verse: map['verse'] as int,
      color: map['color'] as String? ?? 'yellow',
      text: map['text'] as String?,
      createdAt: map['created_at'] as int? ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'book_code': bookCode,
    'chapter': chapter,
    'verse': verse,
    'color': color,
    'created_at': createdAt,
  };
}
