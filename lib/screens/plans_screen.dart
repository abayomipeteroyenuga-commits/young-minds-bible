import 'package:flutter/material.dart';

import '../data/reading_plans.dart';
import '../models/bible_models.dart';
import '../services/preferences_service.dart';
import 'chapter_screen.dart';

class PlansScreen extends StatelessWidget {
  const PlansScreen({super.key, required this.library, required this.prefs});
  final BibleLibrary library;
  final PreferencesService prefs;

  Future<bool> _open(BuildContext context, String reference) async {
    final parts = reference.split(' ');
    if (parts.length < 2) return false;
    final chapter = int.tryParse(parts.removeLast()) ?? 1;
    final bookName = parts.join(' ');
    final bookIndex = library.books.indexWhere((b) => b.name == bookName);
    if (bookIndex < 0) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$bookName is not available in this Bible build.')));
      }
      return false;
    }
    final chapterIndex = library.books[bookIndex].chapters.indexWhere((c) => c.number == chapter);
    if (chapterIndex < 0) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$reference is not available in this Bible build.')));
      }
      return false;
    }

    final completed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ChapterScreen(
          library: library,
          bookIndex: bookIndex,
          chapterIndex: chapterIndex,
          prefs: prefs,
          completionReference: reference,
        ),
      ),
    );
    return completed == true;
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
              final rawDay = prefs.readingPlanProgress[plan.id] ?? 0;
              final day = rawDay.clamp(0, plan.days).toInt();
              final progress = plan.days == 0 ? 0.0 : day / plan.days;
              return Card(
                margin: const EdgeInsets.only(bottom: 14),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(plan.title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                      const SizedBox(height: 5),
                      Text(plan.subtitle),
                      const SizedBox(height: 14),
                      LinearProgressIndicator(value: progress),
                      const SizedBox(height: 10),
                      Text('$day of ${plan.days} days completed'),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: day >= plan.days
                              ? null
                              : () async {
                                  final completed = await _open(context, plan.readings[day]);
                                  if (completed) {
                                    await prefs.setPlanProgress(plan.id, day + 1);
                                  }
                                },
                          icon: Icon(day >= plan.days ? Icons.check : Icons.menu_book),
                          label: Text(day == 0 ? 'Start plan' : day >= plan.days ? 'Completed' : 'Continue • Day ${day + 1}'),
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
