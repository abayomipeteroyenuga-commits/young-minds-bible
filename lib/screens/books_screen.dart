import 'package:flutter/material.dart';

import '../models/bible_models.dart';
import '../services/preferences_service.dart';
import 'chapter_screen.dart';

class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key, required this.library, required this.prefs});
  final BibleLibrary library;
  final PreferencesService prefs;

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  bool newTestament = false;

  @override
  Widget build(BuildContext context) {
    final splitIndex = widget.library.books.length < 39 ? widget.library.books.length : 39;
    final start = newTestament ? splitIndex : 0;
    final end = newTestament ? widget.library.books.length : splitIndex;
    final books = widget.library.books.sublist(start, end);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Read the Bible',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontWeight: FontWeight.w900),
                ),
              ),
              Chip(label: Text(widget.library.translation)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: false, label: Text('Old Testament')),
              ButtonSegment(value: true, label: Text('New Testament')),
            ],
            selected: {newTestament},
            onSelectionChanged: (value) {
              setState(() => newTestament = value.first);
            },
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
            itemCount: books.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final book = books[index];
              final globalBookIndex = start + index;
              return Card(
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  leading: CircleAvatar(child: Text('${globalBookIndex + 1}')),
                  title: Text(
                    book.name,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text('${book.chapters.length} chapters'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _chooseChapter(
                    context,
                    book,
                    globalBookIndex,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _chooseChapter(
    BuildContext context,
    BibleBook book,
    int globalBookIndex,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: .7,
          maxChildSize: .92,
          builder: (context, scrollController) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Text(
                    'Choose a chapter • ${book.name}',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 30),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                    ),
                    itemCount: book.chapters.length,
                    itemBuilder: (context, chapterIndex) {
                      return FilledButton.tonal(
                        onPressed: () {
                          Navigator.pop(sheetContext);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChapterScreen(
                                library: widget.library,
                                bookIndex: globalBookIndex,
                                chapterIndex: chapterIndex,
                                prefs: widget.prefs,
                              ),
                            ),
                          );
                        },
                        child: Text('${chapterIndex + 1}'),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
