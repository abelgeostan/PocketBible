class ReadingPosition {
  final String bookCode;
  final String bookName;
  final int chapter;
  final int verse;
  final int timestamp;

  ReadingPosition({
    required this.bookCode,
    required this.bookName,
    required this.chapter,
    required this.verse,
    required this.timestamp,
  });

  String get reference => '$bookName $chapter:$verse';

  factory ReadingPosition.fromJson(Map<String, dynamic> json) {
    return ReadingPosition(
      bookCode: json['book_code'] as String? ?? json['bookCode'] as String,
      bookName: json['book_name'] as String? ?? json['bookName'] as String,
      chapter: json['chapter'] as int,
      verse: json['verse'] as int? ?? 1,
      timestamp: json['timestamp'] as int? ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  Map<String, dynamic> toJson() => {
    'book_code': bookCode,
    'book_name': bookName,
    'chapter': chapter,
    'verse': verse,
    'timestamp': timestamp,
  };
}
