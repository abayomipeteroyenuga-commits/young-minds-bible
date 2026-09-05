import 'package:flutter/material.dart';

import '../models/bible_models.dart';
import '../services/preferences_service.dart';
import 'chapter_screen.dart';
import 'plans_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.library,
    required this.prefs,
    required this.onReadBible,
    required this.onSearch,
  });

  final BibleLibrary library;
  final PreferencesService prefs;
  final VoidCallback onReadBible;
  final VoidCallback onSearch;

  VerseRef _dailyVerse() {
    var verseCount = 0;
    for (final book in library.books) {
      for (final chapter in book.chapters) {
        verseCount += chapter.verses.length;
      }
    }
    if (verseCount == 0) {
      return const VerseRef('John', 3, 16, 'For God so loved the world...');
    }

    final now = DateTime.now();
    var target = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch ~/ 86400000;
    target %= verseCount;

    for (final book in library.books) {
      for (final chapter in book.chapters) {
        if (target < chapter.verses.length) {
          final verse = chapter.verses[target];
          return VerseRef(book.name, chapter.number, verse.number, verse.text);
        }
        target -= chapter.verses.length;
      }
    }
    final firstBook = library.books.first;
    final firstChapter = firstBook.chapters.first;
    final firstVerse = firstChapter.verses.first;
    return VerseRef(firstBook.name, firstChapter.number, firstVerse.number, firstVerse.text);
  }

  void _resume(BuildContext context) {
    if (prefs.lastBook == null) {
      onReadBible();
      return;
    }
    final bookIndex = library.books.indexWhere((b) => b.name == prefs.lastBook);
    if (bookIndex < 0) {
      onReadBible();
      return;
    }
    final chapterIndex = library.books[bookIndex].chapters
        .indexWhere((c) => c.number == prefs.lastChapter);
    if (chapterIndex < 0) {
      onReadBible();
      return;
    }
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
    final verse = _dailyVerse();
    return AnimatedBuilder(
      animation: prefs,
      builder: (context, _) => ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Young Minds Bible',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    Text(
                      'Read • Understand • Grow',
                      style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              const CircleAvatar(radius: 24, child: Icon(Icons.auto_stories)),
            ],
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primaryContainer,
                  Theme.of(context).colorScheme.secondaryContainer,
                ],
              ),
              borderRadius: BorderRadius.circular(26),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('VERSE OF THE DAY', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                const SizedBox(height: 12),
                Text('“${verse.text}”', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700, height: 1.35)),
                const SizedBox(height: 10),
                Text(verse.reference, style: TextStyle(fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.primary)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            style: FilledButton.styleFrom(padding: const EdgeInsets.all(17)),
            onPressed: () => _resume(context),
            icon: const Icon(Icons.play_arrow_rounded),
            label: Text(prefs.lastBook == null ? 'Start reading' : 'Continue • ${prefs.lastBook} ${prefs.lastChapter}'),
          ),
          const SizedBox(height: 20),
          Text('Explore', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.35,
            children: [
              _tile(context, Icons.menu_book, 'Read Bible', '66 books', onReadBible),
              _tile(context, Icons.search, 'Search', 'Find any verse', onSearch),
              _tile(context, Icons.calendar_month, 'Reading Plans', 'Build a habit', () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => PlansScreen(library: library, prefs: prefs)));
              }),
              _tile(context, Icons.offline_bolt, 'Offline', 'Read anywhere', () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bible reading and saved data work offline.')));
              }),
            ],
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Icon(Icons.wifi_off, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 14),
                  const Expanded(child: Text('Made for offline reading. The production Android build packages the complete Bible locally.')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, IconData icon, String title, String subtitle, VoidCallback tap) {
    return InkWell(
      onTap: tap,
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
