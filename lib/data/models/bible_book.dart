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

  String get englishName => englishNames[code] ?? code;

  static const Map<String, String> englishNames = {
    'GEN': 'Genesis',
    'EXO': 'Exodus',
    'LEV': 'Leviticus',
    'NUM': 'Numbers',
    'DEU': 'Deuteronomy',
    'JOS': 'Joshua',
    'JDG': 'Judges',
    'RUT': 'Ruth',
    '1SA': '1 Samuel',
    '2SA': '2 Samuel',
    '1KI': '1 Kings',
    '2KI': '2 Kings',
    '1CH': '1 Chronicles',
    '2CH': '2 Chronicles',
    'EZR': 'Ezra',
    'NEH': 'Nehemiah',
    'EST': 'Esther',
    'JOB': 'Job',
    'PSA': 'Psalms',
    'PRO': 'Proverbs',
    'ECC': 'Ecclesiastes',
    'SNG': 'Song of Solomon',
    'ISA': 'Isaiah',
    'JER': 'Jeremiah',
    'LAM': 'Lamentations',
    'EZK': 'Ezekiel',
    'DAN': 'Daniel',
    'HOS': 'Hosea',
    'JOL': 'Joel',
    'AMO': 'Amos',
    'OBA': 'Obadiah',
    'JON': 'Jonah',
    'MIC': 'Micah',
    'NAM': 'Nahum',
    'HAB': 'Habakkuk',
    'ZEP': 'Zephaniah',
    'HAG': 'Haggai',
    'ZEC': 'Zechariah',
    'MAL': 'Malachi',
    'MAT': 'Matthew',
    'MRK': 'Mark',
    'LUK': 'Luke',
    'JHN': 'John',
    'ACT': 'Acts',
    'ROM': 'Romans',
    '1CO': '1 Corinthians',
    '2CO': '2 Corinthians',
    'GAL': 'Galatians',
    'EPH': 'Ephesians',
    'PHP': 'Philippians',
    'COL': 'Colossians',
    '1TH': '1 Thessalonians',
    '2TH': '2 Thessalonians',
    '1TI': '1 Timothy',
    '2TI': '2 Timothy',
    'TIT': 'Titus',
    'PHM': 'Philemon',
    'HEB': 'Hebrews',
    'JAS': 'James',
    '1PE': '1 Peter',
    '2PE': '2 Peter',
    '1JN': '1 John',
    '2JN': '2 John',
    '3JN': '3 John',
    'JUD': 'Jude',
    'REV': 'Revelation',
  };

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
