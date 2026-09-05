import 'package:flutter/material.dart';

import '../models/bible_models.dart';
import '../services/preferences_service.dart';
import 'chapter_screen.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key, required this.library, required this.prefs});
  final BibleLibrary library;
  final PreferencesService prefs;

  List<VerseRef> _refs(Set<String> ids) {
    if (ids.isEmpty) return const <VerseRef>[];
    final remaining = ids.toSet();
    final found = <VerseRef>[];
    for (final book in library.books) {
      for (final chapter in book.chapters) {
        for (final verse in chapter.verses) {
          final ref = VerseRef(book.name, chapter.number, verse.number, verse.text);
          if (remaining.remove(ref.id)) found.add(ref);
          if (remaining.isEmpty) return found;
        }
      }
    }
    return found;
  }

  VerseRef? _refFromId(String id) {
    final parts = id.split('|');
    if (parts.length != 3) return null;
    final chapterNumber = int.tryParse(parts[1]);
    final verseNumber = int.tryParse(parts[2]);
    if (chapterNumber == null || verseNumber == null) return null;
    final bookIndex = library.books.indexWhere((b) => b.name == parts[0]);
    if (bookIndex < 0) return null;
    final book = library.books[bookIndex];
    final chapterIndex = book.chapters.indexWhere((c) => c.number == chapterNumber);
    if (chapterIndex < 0) return null;
    final chapter = book.chapters[chapterIndex];
    final verseIndex = chapter.verses.indexWhere((v) => v.number == verseNumber);
    if (verseIndex < 0) return null;
    final verse = chapter.verses[verseIndex];
    return VerseRef(book.name, chapter.number, verse.number, verse.text);
  }

  void _open(BuildContext context, VerseRef ref) {
    final bookIndex = library.books.indexWhere((b) => b.name == ref.book);
    if (bookIndex < 0) return;
    final chapterIndex = library.books[bookIndex].chapters.indexWhere((c) => c.number == ref.chapter);
    if (chapterIndex < 0) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChapterScreen(
          library: library,
          bookIndex: bookIndex,
          chapterIndex: chapterIndex,
          prefs: prefs,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: prefs,
      builder: (context, _) {
        final bookmarks = _refs(prefs.bookmarks);
        final highlights = _refs(prefs.highlights);
        return DefaultTabController(
          length: 3,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Saved', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
                ),
              ),
              const TabBar(tabs: [Tab(text: 'Bookmarks'), Tab(text: 'Highlights'), Tab(text: 'Notes')]),
              Expanded(
                child: TabBarView(
                  children: [
                    _list(context, bookmarks, 'No bookmarks yet.'),
                    _list(context, highlights, 'No highlights yet.'),
                    _notes(context),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _list(BuildContext context, List<VerseRef> refs, String empty) {
    if (refs.isEmpty) return Center(child: Text(empty));
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
      itemCount: refs.length,
      itemBuilder: (context, index) {
        final ref = refs[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            title: Text(ref.reference, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(ref.text, maxLines: 3, overflow: TextOverflow.ellipsis),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _open(context, ref),
          ),
        );
      },
    );
  }

  Widget _notes(BuildContext context) {
    if (prefs.notes.isEmpty) return const Center(child: Text('No notes yet.'));
    final entries = prefs.notes.entries.toList();
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        final ref = _refFromId(entry.key);
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            title: Text(ref?.reference ?? entry.key.replaceAll('|', ' '), style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(entry.value, maxLines: 4, overflow: TextOverflow.ellipsis),
            onTap: ref == null ? null : () => _open(context, ref),
            trailing: IconButton(
              tooltip: 'Delete note',
              icon: const Icon(Icons.delete_outline),
              onPressed: () => prefs.setNote(entry.key, ''),
            ),
          ),
        );
      },
    );
  }
}
