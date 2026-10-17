class BibleBook {
  final int order;
  final String code;
  final String name;
  final String testament; // 'OT' or 'NT'
  final int totalChapters;
  final List<int> chapters;

  const BibleBook({
    required this.order,
    required this.code,
    required this.name,
    required this.testament,
    required this.totalChapters,
    required this.chapters,
  });

  bool get isOldTestament => testament == 'OT';
  bool get isNewTestament => testament == 'NT';

  factory BibleBook.fromJson(Map<String, dynamic> json) {
    return BibleBook(
      order: json['order'] as int? ?? (json['book_order'] as int? ?? 0),
      code: json['code'] as String,
      name: json['name'] as String,
      testament: json['testament'] as String,
      totalChapters: json['total_chapters'] as int,
      chapters: json['chapters'] != null
          ? List<int>.from(json['chapters'])
          : List<int>.generate(json['total_chapters'] as int, (i) => i + 1),
    );
  }

  Map<String, dynamic> toJson() => {
    'order': order,
    'code': code,
    'name': name,
    'testament': testament,
    'total_chapters': totalChapters,
    'chapters': chapters,
  };
}
