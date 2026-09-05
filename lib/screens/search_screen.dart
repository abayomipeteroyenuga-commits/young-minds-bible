import 'package:flutter/material.dart';

import '../models/bible_models.dart';
import '../services/bible_service.dart';
import '../services/preferences_service.dart';
import 'chapter_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, required this.library, required this.prefs});
  final BibleLibrary library;
  final PreferencesService prefs;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController controller = TextEditingController();
  List<VerseRef> results = [];
  bool searched = false;

  void run(String query) {
    setState(() {
      results = BibleService().search(widget.library, query);
      searched = true;
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Search',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                textInputAction: TextInputAction.search,
                onSubmitted: run,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Try “love” or “John 3:16”',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: () => run(controller.text),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: results.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Text(
                      searched
                          ? 'No verses found. Try another word or reference.'
                          : 'Search every offline verse — no internet required.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
                  itemCount: results.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final result = results[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      title: Text(
                        result.reference,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      subtitle: Text(
                        result.text,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => _openResult(context, result),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _openResult(BuildContext context, VerseRef result) {
    final bookIndex =
        widget.library.books.indexWhere((b) => b.name == result.book);
    if (bookIndex < 0) return;
    final chapterIndex = widget.library.books[bookIndex].chapters
        .indexWhere((c) => c.number == result.chapter);
    if (chapterIndex < 0) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChapterScreen(
          library: widget.library,
          bookIndex: bookIndex,
          chapterIndex: chapterIndex,
          prefs: widget.prefs,
        ),
      ),
    );
  }
}
