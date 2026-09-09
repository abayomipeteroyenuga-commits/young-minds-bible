import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService extends ChangeNotifier {
  SharedPreferences? _prefs;
  final Set<String> bookmarks = {};
  final Set<String> highlights = {};
  final Map<String, String> notes = {};
  final Map<String, int> readingPlanProgress = {};
  String? lastBook;
  int lastChapter = 1;
  double fontSize = 19;
  double lineHeight = 1.65;
  bool darkMode = false;
  bool verseNumbers = true;
  bool completedOnboarding = false;
  String accent = 'indigo';

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    bookmarks.addAll(_prefs!.getStringList('bookmarks') ?? const []);
    highlights.addAll(_prefs!.getStringList('highlights') ?? const []);
    notes.addAll(Map<String, String>.from(jsonDecode(_prefs!.getString('notes') ?? '{}')));
    readingPlanProgress.addAll((jsonDecode(_prefs!.getString('plan_progress') ?? '{}') as Map<String, dynamic>).map((k,v) => MapEntry(k, v as int)));
    lastBook = _prefs!.getString('last_book');
    lastChapter = _prefs!.getInt('last_chapter') ?? 1;
    fontSize = _prefs!.getDouble('font_size') ?? 19;
    lineHeight = _prefs!.getDouble('line_height') ?? 1.65;
    darkMode = _prefs!.getBool('dark_mode') ?? false;
    verseNumbers = _prefs!.getBool('verse_numbers') ?? true;
    completedOnboarding = _prefs!.getBool('onboarded') ?? false;
    accent = _prefs!.getString('accent') ?? 'indigo';
    notifyListeners();
  }

  Future<void> toggleBookmark(String id) async { bookmarks.contains(id) ? bookmarks.remove(id) : bookmarks.add(id); await _prefs?.setStringList('bookmarks', bookmarks.toList()); notifyListeners(); }
  Future<void> toggleHighlight(String id) async { highlights.contains(id) ? highlights.remove(id) : highlights.add(id); await _prefs?.setStringList('highlights', highlights.toList()); notifyListeners(); }
  Future<void> setNote(String id, String value) async { value.trim().isEmpty ? notes.remove(id) : notes[id] = value.trim(); await _prefs?.setString('notes', jsonEncode(notes)); notifyListeners(); }
  Future<void> setReadingPosition(String book, int chapter) async { lastBook=book; lastChapter=chapter; await _prefs?.setString('last_book', book); await _prefs?.setInt('last_chapter', chapter); notifyListeners(); }
  Future<void> setFontSize(double v) async { fontSize=v; await _prefs?.setDouble('font_size', v); notifyListeners(); }
  Future<void> setLineHeight(double v) async { lineHeight=v; await _prefs?.setDouble('line_height', v); notifyListeners(); }
  Future<void> setDarkMode(bool v) async { darkMode=v; await _prefs?.setBool('dark_mode', v); notifyListeners(); }
  Future<void> setVerseNumbers(bool v) async { verseNumbers=v; await _prefs?.setBool('verse_numbers', v); notifyListeners(); }
  Future<void> setOnboarded() async { completedOnboarding=true; await _prefs?.setBool('onboarded', true); notifyListeners(); }
  Future<void> setPlanProgress(String id, int day) async { readingPlanProgress[id]=day; await _prefs?.setString('plan_progress', jsonEncode(readingPlanProgress)); notifyListeners(); }
  Future<void> clearReadingData() async { bookmarks.clear(); highlights.clear(); notes.clear(); readingPlanProgress.clear(); lastBook=null; lastChapter=1; await _prefs?.remove('bookmarks'); await _prefs?.remove('highlights'); await _prefs?.remove('notes'); await _prefs?.remove('plan_progress'); await _prefs?.remove('last_book'); await _prefs?.remove('last_chapter'); notifyListeners(); }
}
