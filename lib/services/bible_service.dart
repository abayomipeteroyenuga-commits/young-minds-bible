import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/bible_models.dart';

class BookMeta {
  const BookMeta({required this.name, required this.chapters, required this.testament});
  final String name;
  final int chapters;
  final String testament;
}

class BibleService {
  Future<BibleLibrary> loadBible() async {
    final raw = await rootBundle.loadString('assets/data/kjv.json');
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final lib = BibleLibrary.fromJson(_normalise(decoded));
    _validateCompleteBible(lib);
    return lib;
  }

  void _validateCompleteBible(BibleLibrary library) {
    if (library.books.length != 66) {
      throw StateError('Offline Bible is incomplete: expected 66 books, found ${library.books.length}.');
    }
    final chapters = library.books.fold<int>(0, (sum, book) => sum + book.chapters.length);
    final verses = library.books.fold<int>(
      0,
      (sum, book) => sum + book.chapters.fold<int>(0, (chapterSum, chapter) => chapterSum + chapter.verses.length),
    );
    if (chapters != 1189 || verses < 31000) {
      throw StateError('Offline Bible is incomplete: found $chapters chapters and $verses verses.');
    }
    for (final book in library.books) {
      for (final chapter in book.chapters) {
        for (final verse in chapter.verses) {
          if (verse.text.trim().isEmpty) {
            throw StateError('Offline Bible contains an empty verse at ${book.name} ${chapter.number}:${verse.number}.');
          }
        }
      }
    }
  }

  Future<List<BookMeta>> loadBookMetadata() async {
    final raw = await rootBundle.loadString('assets/data/book_metadata.json');
    final list = jsonDecode(raw) as List;
    return list.map((e) {
      final m = Map<String, dynamic>.from(e as Map);
      return BookMeta(name: m['name'] as String, chapters: m['chapters'] as int, testament: m['testament'] as String);
    }).toList();
  }

  Map<String, dynamic> _normalise(Map<String, dynamic> json) {
    if (json['books'] is! List) return json;
    final books = <Map<String, dynamic>>[];
    for (final item in json['books'] as List) {
      final b = Map<String, dynamic>.from(item as Map);
      final rawChapters = (b['chapters'] ?? []) as List;
      final chapters = <Map<String, dynamic>>[];
      for (var ci = 0; ci < rawChapters.length; ci++) {
        final c = Map<String, dynamic>.from(rawChapters[ci] as Map);
        final rawVerses = (c['verses'] ?? []) as List;
        final verses = <Map<String, dynamic>>[];
        for (var vi = 0; vi < rawVerses.length; vi++) {
          final v = Map<String, dynamic>.from(rawVerses[vi] as Map);
          verses.add({'number': v['number'] ?? v['verse'] ?? vi + 1, 'text': v['text'] ?? ''});
        }
        chapters.add({'number': c['number'] ?? c['chapter'] ?? ci + 1, 'verses': verses});
      }
      books.add({'name': b['name'] ?? b['book'] ?? b['title'] ?? '', 'chapters': chapters});
    }
    return {
      'translation': json['translation'] ?? json['version'] ?? 'KJV',
      'translation_name': json['translation_name'] ?? json['name'] ?? 'King James Version',
      'books': books,
    };
  }

  List<VerseRef> search(BibleLibrary library, String query, {int limit = 200}) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    final results = <VerseRef>[];
    final ref = RegExp(r'^(.+?)\s+(\d+)(?::(\d+))?$').firstMatch(query.trim());
    if (ref != null) {
      final name = ref.group(1)!.toLowerCase();
      final chapter = int.tryParse(ref.group(2)!);
      final verse = ref.group(3) == null ? null : int.tryParse(ref.group(3)!);
      for (final book in library.books.where((b) => b.name.toLowerCase() == name)) {
        for (final c in book.chapters.where((c) => c.number == chapter)) {
          for (final v in c.verses.where((v) => verse == null || v.number == verse)) {
            results.add(VerseRef(book.name, c.number, v.number, v.text));
          }
        }
      }
      if (results.isNotEmpty) return results;
    }
    for (final book in library.books) {
      for (final chapter in book.chapters) {
        for (final verse in chapter.verses) {
          if (verse.text.toLowerCase().contains(q)) {
            results.add(VerseRef(book.name, chapter.number, verse.number, verse.text));
            if (results.length >= limit) return results;
          }
        }
      }
    }
    return results;
  }

  List<VerseRef> allVerses(BibleLibrary library) => [
        for (final b in library.books)
          for (final c in b.chapters)
            for (final v in c.verses) VerseRef(b.name, c.number, v.number, v.text)
      ];
}
