import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../models/bible_models.dart';
import '../services/preferences_service.dart';

class ChapterScreen extends StatefulWidget {
  const ChapterScreen({
    super.key,
    required this.library,
    required this.bookIndex,
    required this.chapterIndex,
    required this.prefs,
  });

  final BibleLibrary library;
  final int bookIndex;
  final int chapterIndex;
  final PreferencesService prefs;

  @override
  State<ChapterScreen> createState() => _ChapterScreenState();
}

class _ChapterScreenState extends State<ChapterScreen> {
  late int bookIndex = widget.bookIndex;
  late int chapterIndex = widget.chapterIndex;

  BibleBook get book => widget.library.books[bookIndex];
  BibleChapter get chapter => book.chapters[chapterIndex];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.prefs.setReadingPosition(book.name, chapter.number);
    });
  }

  Future<void> _editNote(VerseRef ref) async {
    final controller =
        TextEditingController(text: widget.prefs.notes[ref.id] ?? '');
    final value = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Note • ${ref.reference}'),
        content: TextField(
          controller: controller,
          maxLines: 5,
          autofocus: true,
          decoration:
              const InputDecoration(hintText: 'Write what stood out to you…'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (value != null) await widget.prefs.setNote(ref.id, value);
  }

  void _move(int delta) {
    var nextBook = bookIndex;
    var nextChapter = chapterIndex + delta;

    if (nextChapter < 0) {
      if (nextBook == 0) return;
      nextBook--;
      nextChapter = widget.library.books[nextBook].chapters.length - 1;
    }
    if (nextChapter >= widget.library.books[nextBook].chapters.length) {
      if (nextBook >= widget.library.books.length - 1) return;
      nextBook++;
      nextChapter = 0;
    }

    setState(() {
      bookIndex = nextBook;
      chapterIndex = nextChapter;
    });
    widget.prefs.setReadingPosition(book.name, chapter.number);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${book.name} ${chapter.number}'),
        actions: [
          IconButton(
            tooltip: 'Text settings',
            icon: const Icon(Icons.text_fields),
            onPressed: _showTextSettings,
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: widget.prefs,
        builder: (context, _) {
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 120),
            itemCount: chapter.verses.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    '${book.name} • Chapter ${chapter.number}',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                );
              }

              final verse = chapter.verses[index - 1];
              final ref =
                  VerseRef(book.name, chapter.number, verse.number, verse.text);
              final highlighted = widget.prefs.highlights.contains(ref.id);

              return InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _showVerseActions(ref),
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  decoration: BoxDecoration(
                    color: highlighted
                        ? Theme.of(context).colorScheme.secondaryContainer
                        : null,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: widget.prefs.fontSize,
                        height: widget.prefs.lineHeight,
                      ),
                      children: [
                        if (widget.prefs.verseNumbers)
                          TextSpan(
                            text: '${verse.number}  ',
                            style: TextStyle(
                              fontSize: widget.prefs.fontSize * .65,
                              fontWeight: FontWeight.w800,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        TextSpan(text: verse.text),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _move(-1),
                  icon: const Icon(Icons.chevron_left),
                  label: const Text('Previous'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _move(1),
                  icon: const Icon(Icons.chevron_right),
                  label: const Text('Next'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTextSettings() {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => AnimatedBuilder(
        animation: widget.prefs,
        builder: (_, __) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Reading settings',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              Slider(
                value: widget.prefs.fontSize,
                min: 15,
                max: 30,
                divisions: 15,
                label: '${widget.prefs.fontSize.round()}',
                onChanged: widget.prefs.setFontSize,
              ),
              SwitchListTile(
                title: const Text('Show verse numbers'),
                value: widget.prefs.verseNumbers,
                onChanged: widget.prefs.setVerseNumbers,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showVerseActions(VerseRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: AnimatedBuilder(
          animation: widget.prefs,
          builder: (context, _) {
            final bookmarked = widget.prefs.bookmarks.contains(ref.id);
            final highlighted = widget.prefs.highlights.contains(ref.id);
            return Wrap(
              children: [
                ListTile(
                  title: Text(ref.reference),
                  subtitle: Text(
                    ref.text,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                ListTile(
                  leading:
                      Icon(bookmarked ? Icons.bookmark : Icons.bookmark_border),
                  title: const Text('Bookmark'),
                  onTap: () {
                    widget.prefs.toggleBookmark(ref.id);
                    Navigator.pop(sheetContext);
                  },
                ),
                ListTile(
                  leading: Icon(
                    highlighted ? Icons.highlight : Icons.highlight_outlined,
                  ),
                  title: const Text('Highlight'),
                  onTap: () {
                    widget.prefs.toggleHighlight(ref.id);
                    Navigator.pop(sheetContext);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.note_alt_outlined),
                  title: const Text('Add note'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _editNote(ref);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.share_outlined),
                  title: const Text('Share verse'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    Share.share('“${ref.text}” — ${ref.reference} (KJV)');
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
