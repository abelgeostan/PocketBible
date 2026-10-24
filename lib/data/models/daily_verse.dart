class DailyVerse {
  final String bookCode;
  final String bookName;
  final int chapter;
  final int verse;
  final String text;
  final String? theme;
  final int? day;

  const DailyVerse({
    required this.bookCode,
    required this.bookName,
    required this.chapter,
    required this.verse,
    required this.text,
    this.theme,
    this.day,
  });

  String get reference => '$bookName $chapter:$verse';

  factory DailyVerse.fromJson(Map<String, dynamic> json) {
    return DailyVerse(
      bookCode: (json['c'] ?? json['usfm_book_id']) as String,
      bookName: (json['b'] ?? json['book']) as String,
      chapter: (json['ch'] ?? json['chapter']) as int,
      verse: (json['v'] ?? json['verse']) as int,
      text: (json['t'] ?? json['text_ml']) as String,
      theme: json['theme'] as String?,
      day: json['day'] as int?,
    );
  }
}

class ReadingPosition {
  final String bookCode;
  final String bookName;
  final int chapter;
  final int verse;
  final int timestamp;

  const ReadingPosition({
    required this.bookCode,
    required this.bookName,
    required this.chapter,
    this.verse = 1,
    required this.timestamp,
  });

  String get reference => '$bookName $chapter';

  factory ReadingPosition.fromJson(Map<String, dynamic> json) {
    return ReadingPosition(
      bookCode: json['code'] as String? ?? (json['book_code'] as String? ?? 'GEN'),
      bookName: json['book_name'] as String? ?? 'ഉല്പത്തിപുസ്തകം',
      chapter: json['chapter'] as int? ?? 1,
      verse: json['verse'] as int? ?? 1,
      timestamp: json['timestamp'] as int? ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  Map<String, dynamic> toJson() => {
    'code': bookCode,
    'book_name': bookName,
    'chapter': chapter,
    'verse': verse,
    'timestamp': timestamp,
  };
}
