import 'package:flutter/material.dart';

import '../data/reading_plans.dart';
import '../models/bible_models.dart';
import '../services/preferences_service.dart';
import 'chapter_screen.dart';

class PlansScreen extends StatelessWidget {
  const PlansScreen({super.key, required this.library, required this.prefs});
  final BibleLibrary library;
  final PreferencesService prefs;

  void _open(BuildContext context, String reference) {
    final parts = reference.split(' ');
    final chapter = int.tryParse(parts.removeLast()) ?? 1;
    final bookName = parts.join(' ');
    final bookIndex = library.books.indexWhere((b) => b.name == bookName);
    if (bookIndex < 0) return;
    final chapterIndex =
        library.books[bookIndex].chapters.indexWhere((c) => c.number == chapter);
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
    return Scaffold(
      appBar: AppBar(title: const Text('Reading Plans')),
      body: AnimatedBuilder(
        animation: prefs,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.all(18),
            children: readingPlans.map((plan) {
              final day = prefs.readingPlanProgress[plan.id] ?? 0;
              final progress = day / plan.days;
              return Card(
                margin: const EdgeInsets.only(bottom: 14),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.title,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 5),
                      Text(plan.subtitle),
                      const SizedBox(height: 14),
                      LinearProgressIndicator(value: progress.clamp(0, 1)),
                      const SizedBox(height: 10),
                      Text('$day of ${plan.days} days completed'),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: day >= plan.days
                            ? null
                            : () {
                                final next = day;
                                _open(context, plan.readings[next]);
                                prefs.setPlanProgress(plan.id, next + 1);
                              },
                        icon: const Icon(Icons.menu_book),
                        label: Text(
                          day == 0
                              ? 'Start plan'
                              : day >= plan.days
                                  ? 'Completed'
                                  : 'Continue • Day ${day + 1}',
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
