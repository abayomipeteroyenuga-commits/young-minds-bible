import 'package:flutter/material.dart';

import 'models/bible_models.dart';
import 'screens/books_screen.dart';
import 'screens/home_screen.dart';
import 'screens/more_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/saved_screen.dart';
import 'screens/search_screen.dart';
import 'services/bible_service.dart';
import 'services/preferences_service.dart';
import 'widgets/app_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const YoungMindsBibleApp());
}

class YoungMindsBibleApp extends StatefulWidget {
  const YoungMindsBibleApp({super.key});

  @override
  State<YoungMindsBibleApp> createState() => _YoungMindsBibleAppState();
}

class _YoungMindsBibleAppState extends State<YoungMindsBibleApp> {
  final PreferencesService prefs = PreferencesService();
  late final Future<BibleLibrary> bible = BibleService().loadBible();
  bool ready = false;

  @override
  void initState() {
    super.initState();
    prefs.init().then((_) {
      if (mounted) setState(() => ready = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: prefs,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Young Minds Bible',
          themeMode: prefs.darkMode ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: const Color(0xFF4357A3),
            scaffoldBackgroundColor: const Color(0xFFF8F7F3),
            inputDecorationTheme: const InputDecorationTheme(filled: true),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorSchemeSeed: const Color(0xFF8195FF),
          ),
          home: !ready
              ? const Scaffold(body: Center(child: CircularProgressIndicator()))
              : FutureBuilder<BibleLibrary>(
                  future: bible,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Scaffold(
                        body: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              'Could not load offline Bible data.\n${snapshot.error}',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      );
                    }
                    if (!snapshot.hasData) {
                      return const Scaffold(
                        body: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (!prefs.completedOnboarding) {
                      return OnboardingScreen(
                        prefs: prefs,
                        onDone: () => setState(() {}),
                      );
                    }
                    return MainTabs(library: snapshot.data!, prefs: prefs);
                  },
                ),
        );
      },
    );
  }
}

class MainTabs extends StatefulWidget {
  const MainTabs({super.key, required this.library, required this.prefs});
  final BibleLibrary library;
  final PreferencesService prefs;

  @override
  State<MainTabs> createState() => _MainTabsState();
}

class _MainTabsState extends State<MainTabs> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final screens = <Widget>[
      HomeScreen(
        library: widget.library,
        prefs: widget.prefs,
        onReadBible: () => setState(() => index = 1),
        onSearch: () => setState(() => index = 2),
      ),
      BooksScreen(library: widget.library, prefs: widget.prefs),
      SearchScreen(library: widget.library, prefs: widget.prefs),
      SavedScreen(library: widget.library, prefs: widget.prefs),
      MoreScreen(library: widget.library, prefs: widget.prefs),
    ];

    return AppShell(
      index: index,
      onIndex: (value) => setState(() => index = value),
      child: IndexedStack(index: index, children: screens),
    );
  }
}
