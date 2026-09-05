import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService extends ChangeNotifier {
  SharedPreferences? _prefs;
  final Set<String> bookmarks = <String>{};
  final Set<String> highlights = <String>{};
  final Map<String, String> notes = <String, String>{};
  final Map<String, int> readingPlanProgress = <String, int>{};

  String? lastBook;
  int lastChapter = 1;
  double fontSize = 19;
  double lineHeight = 1.65;
  bool darkMode = false;
  bool verseNumbers = true;
  bool completedOnboarding = false;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    bookmarks
      ..clear()
      ..addAll(_prefs!.getStringList('bookmarks') ?? const <String>[]);
    highlights
      ..clear()
      ..addAll(_prefs!.getStringList('highlights') ?? const <String>[]);

    notes
      ..clear()
      ..addAll(_decodeStringMap(_prefs!.getString('notes')));
    readingPlanProgress
      ..clear()
      ..addAll(_decodeIntMap(_prefs!.getString('plan_progress')));

    lastBook = _prefs!.getString('last_book');
    lastChapter = _prefs!.getInt('last_chapter') ?? 1;
    fontSize = (_prefs!.getDouble('font_size') ?? 19).clamp(15, 30).toDouble();
    lineHeight = (_prefs!.getDouble('line_height') ?? 1.65).clamp(1.2, 2.2).toDouble();
    darkMode = _prefs!.getBool('dark_mode') ?? false;
    verseNumbers = _prefs!.getBool('verse_numbers') ?? true;
    completedOnboarding = _prefs!.getBool('onboarded') ?? false;
    notifyListeners();
  }

  Map<String, String> _decodeStringMap(String? raw) {
    if (raw == null || raw.isEmpty) return <String, String>{};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return <String, String>{};
      return decoded.map((key, value) => MapEntry('$key', '$value'));
    } catch (_) {
      return <String, String>{};
    }
  }

  Map<String, int> _decodeIntMap(String? raw) {
    if (raw == null || raw.isEmpty) return <String, int>{};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return <String, int>{};
      return decoded.map((key, value) {
        final n = value is num ? value.toInt() : int.tryParse('$value') ?? 0;
        return MapEntry('$key', n < 0 ? 0 : n);
      });
    } catch (_) {
      return <String, int>{};
    }
  }

  Future<void> toggleBookmark(String id) async {
    bookmarks.contains(id) ? bookmarks.remove(id) : bookmarks.add(id);
    await _prefs?.setStringList('bookmarks', bookmarks.toList()..sort());
    notifyListeners();
  }

  Future<void> toggleHighlight(String id) async {
    highlights.contains(id) ? highlights.remove(id) : highlights.add(id);
    await _prefs?.setStringList('highlights', highlights.toList()..sort());
    notifyListeners();
  }

  Future<void> setNote(String id, String value) async {
    final trimmed = value.trim();
    trimmed.isEmpty ? notes.remove(id) : notes[id] = trimmed;
    await _prefs?.setString('notes', jsonEncode(notes));
    notifyListeners();
  }

  Future<void> setReadingPosition(String book, int chapter) async {
    if (lastBook == book && lastChapter == chapter) return;
    lastBook = book;
    lastChapter = chapter;
    await _prefs?.setString('last_book', book);
    await _prefs?.setInt('last_chapter', chapter);
    notifyListeners();
  }

  Future<void> setFontSize(double value) async {
    fontSize = value.clamp(15, 30).toDouble();
    await _prefs?.setDouble('font_size', fontSize);
    notifyListeners();
  }

  Future<void> setLineHeight(double value) async {
    lineHeight = value.clamp(1.2, 2.2).toDouble();
    await _prefs?.setDouble('line_height', lineHeight);
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    darkMode = value;
    await _prefs?.setBool('dark_mode', value);
    notifyListeners();
  }

  Future<void> setVerseNumbers(bool value) async {
    verseNumbers = value;
    await _prefs?.setBool('verse_numbers', value);
    notifyListeners();
  }

  Future<void> setOnboarded() async {
    completedOnboarding = true;
    await _prefs?.setBool('onboarded', true);
    notifyListeners();
  }

  Future<void> setPlanProgress(String id, int day) async {
    readingPlanProgress[id] = day < 0 ? 0 : day;
    await _prefs?.setString('plan_progress', jsonEncode(readingPlanProgress));
    notifyListeners();
  }

  Future<void> clearReadingData() async {
    bookmarks.clear();
    highlights.clear();
    notes.clear();
    readingPlanProgress.clear();
    lastBook = null;
    lastChapter = 1;
    await Future.wait([
      _prefs?.remove('bookmarks') ?? Future.value(false),
      _prefs?.remove('highlights') ?? Future.value(false),
      _prefs?.remove('notes') ?? Future.value(false),
      _prefs?.remove('plan_progress') ?? Future.value(false),
      _prefs?.remove('last_book') ?? Future.value(false),
      _prefs?.remove('last_chapter') ?? Future.value(false),
    ]);
    notifyListeners();
  }
}
