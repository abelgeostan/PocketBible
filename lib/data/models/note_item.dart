class NoteItem {
  final int? id;
  final String bookCode;
  final String? bookName;
  final int chapter;
  final int verse;
  final String? verseText;
  final String noteText;
  final int createdAt;
  final int updatedAt;

  NoteItem({
    this.id,
    required this.bookCode,
    this.bookName,
    required this.chapter,
    required this.verse,
    this.verseText,
    required this.noteText,
    required this.createdAt,
    required this.updatedAt,
  });

  String get key => '$bookCode-$chapter-$verse';
  String get reference => '${bookName ?? bookCode} $chapter:$verse';

  factory NoteItem.fromMap(Map<String, dynamic> map) {
    return NoteItem(
      id: map['id'] as int?,
      bookCode: map['book_code'] as String,
      bookName: map['book_name'] as String?,
      chapter: map['chapter'] as int,
      verse: map['verse'] as int,
      verseText: map['verse_text'] as String?,
      noteText: map['note_text'] as String,
      createdAt: map['created_at'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      updatedAt: map['updated_at'] as int? ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'book_code': bookCode,
    'chapter': chapter,
    'verse': verse,
    'note_text': noteText,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}
