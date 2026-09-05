class BibleVerse {
  const BibleVerse({required this.number, required this.text});
  final int number;
  final String text;

  factory BibleVerse.fromJson(Map<String, dynamic> json) => BibleVerse(
        number: (json['number'] ?? json['verse']) as int,
        text: (json['text'] ?? '') as String,
      );
}

class BibleChapter {
  const BibleChapter({required this.number, required this.verses});
  final int number;
  final List<BibleVerse> verses;

  factory BibleChapter.fromJson(Map<String, dynamic> json) => BibleChapter(
        number: (json['number'] ?? json['chapter']) as int,
        verses: ((json['verses'] ?? []) as List)
            .map((v) => BibleVerse.fromJson(Map<String, dynamic>.from(v as Map)))
            .toList(),
      );
}

class BibleBook {
  const BibleBook({required this.name, required this.chapters});
  final String name;
  final List<BibleChapter> chapters;

  factory BibleBook.fromJson(Map<String, dynamic> json) => BibleBook(
        name: (json['name'] ?? json['book'] ?? '') as String,
        chapters: ((json['chapters'] ?? []) as List)
            .map((c) => BibleChapter.fromJson(Map<String, dynamic>.from(c as Map)))
            .toList(),
      );
}

class BibleLibrary {
  const BibleLibrary({required this.translation, required this.translationName, required this.books});
  final String translation;
  final String translationName;
  final List<BibleBook> books;

  factory BibleLibrary.fromJson(Map<String, dynamic> json) => BibleLibrary(
        translation: (json['translation'] ?? 'KJV') as String,
        translationName: (json['translation_name'] ?? json['name'] ?? 'King James Version') as String,
        books: ((json['books'] ?? []) as List)
            .map((b) => BibleBook.fromJson(Map<String, dynamic>.from(b as Map)))
            .toList(),
      );
}

class VerseRef {
  const VerseRef(this.book, this.chapter, this.verse, this.text);
  final String book;
  final int chapter;
  final int verse;
  final String text;
  String get id => '$book|$chapter|$verse';
  String get reference => '$book $chapter:$verse';
}

class ReadingPosition {
  const ReadingPosition(this.book, this.chapter, {this.updatedAt});
  final String book;
  final int chapter;
  final DateTime? updatedAt;
  String get key => '$book|$chapter';
}
