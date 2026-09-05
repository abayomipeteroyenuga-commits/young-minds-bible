import 'package:flutter/material.dart';

import '../models/bible_models.dart';
import '../services/preferences_service.dart';
import 'plans_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key, required this.library, required this.prefs});
  final BibleLibrary library;
  final PreferencesService prefs;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: prefs,
      builder: (context, _) => ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
        children: [
          Text('More', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.calendar_month_outlined),
                  title: const Text('Reading plans'),
                  subtitle: const Text('Short plans for faith, wisdom and courage'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PlansScreen(library: library, prefs: prefs))),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.dark_mode_outlined),
                  title: const Text('Dark mode'),
                  value: prefs.darkMode,
                  onChanged: prefs.setDarkMode,
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.format_list_numbered),
                  title: const Text('Verse numbers'),
                  value: prefs.verseNumbers,
                  onChanged: prefs.setVerseNumbers,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Reading size', style: TextStyle(fontWeight: FontWeight.bold)),
                  Slider(
                    value: prefs.fontSize,
                    min: 15,
                    max: 30,
                    divisions: 15,
                    label: '${prefs.fontSize.round()}',
                    onChanged: prefs.setFontSize,
                  ),
                  Text('Preview: God’s Word for growing minds.', style: TextStyle(fontSize: prefs.fontSize)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Card(
            child: ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('About Young Minds Bible'),
              subtitle: Text('Offline-first Bible reading • KJV edition\nRead • Understand • Grow'),
            ),
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: () => showDialog<void>(
              context: context,
              builder: (dialogContext) => AlertDialog(
                title: const Text('Clear saved reading data?'),
                content: const Text('This removes bookmarks, highlights, notes and reading-plan progress from this device.'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
                  FilledButton(
                    onPressed: () async {
                      await prefs.clearReadingData();
                      if (dialogContext.mounted) Navigator.pop(dialogContext);
                    },
                    child: const Text('Clear'),
                  ),
                ],
              ),
            ),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Clear my reading data'),
          ),
        ],
      ),
    );
  }
}
