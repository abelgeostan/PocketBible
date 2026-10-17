class BookmarkItem {
  final int? id;
  final String bookCode;
  final String bookName;
  final int chapter;
  final int verse;
  final String text;
  final int createdAt;

  BookmarkItem({
    this.id,
    required this.bookCode,
    required this.bookName,
    required this.chapter,
    required this.verse,
    required this.text,
    required this.createdAt,
  });

  String get key => '$bookCode-$chapter-$verse';
  String get reference => '$bookName $chapter:$verse';

  factory BookmarkItem.fromMap(Map<String, dynamic> map) {
    return BookmarkItem(
      id: map['id'] as int?,
      bookCode: map['book_code'] as String,
      bookName: map['book_name'] as String,
      chapter: map['chapter'] as int,
      verse: map['verse'] as int,
      text: map['text'] as String,
      createdAt: map['created_at'] as int? ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'book_code': bookCode,
    'book_name': bookName,
    'chapter': chapter,
    'verse': verse,
    'text': text,
    'created_at': createdAt,
  };
}
