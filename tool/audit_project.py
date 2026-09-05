#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path
import argparse
import json
import py_compile
import re
import sys

ROOT = Path(__file__).resolve().parents[1]


def fail(message: str, errors: list[str]) -> None:
    errors.append(message)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument('--release', action='store_true', help='Require the complete embedded 66-book Bible corpus.')
    args = parser.parse_args()

    errors: list[str] = []
    warnings: list[str] = []
    required = [
        'pubspec.yaml',
        'lib/main.dart',
        'lib/services/bible_service.dart',
        'lib/services/preferences_service.dart',
        'lib/screens/home_screen.dart',
        'lib/screens/books_screen.dart',
        'lib/screens/chapter_screen.dart',
        'lib/screens/search_screen.dart',
        'lib/screens/saved_screen.dart',
        'lib/screens/plans_screen.dart',
        'lib/screens/more_screen.dart',
        'assets/data/sample_bible.json',
        'assets/data/book_metadata.json',
        'assets/data/kjv.json',
        'tool/fetch_full_bible.py',
        'tool/verify_full_bible.py',
        '.github/workflows/build-android.yml',
        'android/app/src/main/AndroidManifest.xml',
        'android/app/src/main/kotlin/org/pastorabayomi/young_minds_bible/MainActivity.kt',
        'test/reading_plans_test.dart',
        'test/bible_models_test.dart',
    ]
    for relative in required:
        if not (ROOT / relative).exists():
            fail(f'Missing {relative}', errors)

    try:
        metadata = json.loads((ROOT / 'assets/data/book_metadata.json').read_text(encoding='utf-8'))
        if len(metadata) != 66:
            fail(f'Expected 66 metadata books, found {len(metadata)}', errors)
        chapter_total = sum(int(item['chapters']) for item in metadata)
        if chapter_total != 1189:
            fail(f'Expected 1189 metadata chapters, found {chapter_total}', errors)
    except Exception as exc:
        fail(f'Invalid book metadata: {exc}', errors)
        metadata, chapter_total = [], 0

    try:
        sample = json.loads((ROOT / 'assets/data/sample_bible.json').read_text(encoding='utf-8'))
        if not sample.get('books'):
            fail('Development fallback Bible is empty', errors)
    except Exception as exc:
        fail(f'Invalid sample_bible.json: {exc}', errors)

    books = chapters = verses = empty = 0
    try:
        kjv = json.loads((ROOT / 'assets/data/kjv.json').read_text(encoding='utf-8'))
        corpus = kjv.get('books', [])
        books = len(corpus)
        chapters = sum(len(book.get('chapters', [])) for book in corpus)
        verses = sum(len(chapter.get('verses', [])) for book in corpus for chapter in book.get('chapters', []))
        empty = sum(
            1
            for book in corpus
            for chapter in book.get('chapters', [])
            for verse in chapter.get('verses', [])
            if not str(verse.get('text', '')).strip()
        )
        complete = books == 66 and chapters == 1189 and verses >= 31000 and empty == 0
        if args.release and not complete:
            fail(f'Release corpus incomplete: books={books}, chapters={chapters}, verses={verses}, empty={empty}', errors)
        elif not complete:
            warnings.append('Full KJV corpus is intentionally build-time generated; release CI must fetch and verify it before compilation.')
    except Exception as exc:
        fail(f'Invalid kjv.json: {exc}', errors)

    pubspec = (ROOT / 'pubspec.yaml').read_text(encoding='utf-8') if (ROOT / 'pubspec.yaml').exists() else ''
    for asset in ('assets/data/kjv.json', 'assets/data/book_metadata.json', 'assets/data/sample_bible.json'):
        if asset not in pubspec:
            fail(f'pubspec missing asset {asset}', errors)

    prefs = (ROOT / 'lib/services/preferences_service.dart').read_text(encoding='utf-8')
    for feature in ('toggleBookmark', 'toggleHighlight', 'setNote', 'setReadingPosition', 'setDarkMode', 'setPlanProgress', 'clearReadingData'):
        if feature not in prefs:
            fail(f'Missing preference feature {feature}', errors)

    main_dart = (ROOT / 'lib/main.dart').read_text(encoding='utf-8')
    for screen in ('HomeScreen', 'BooksScreen', 'SearchScreen', 'SavedScreen', 'MoreScreen'):
        if screen not in main_dart:
            fail(f'Main tabs missing {screen}', errors)

    plans = (ROOT / 'lib/data/reading_plans.dart').read_text(encoding='utf-8')
    if "prefs.setPlanProgress" in plans:
        warnings.append('Unexpected plan progress persistence found in static plan definitions.')
    plan_screen = (ROOT / 'lib/screens/plans_screen.dart').read_text(encoding='utf-8')
    if "completed = await _open" not in plan_screen or "if (completed)" not in plan_screen:
        fail('Reading-plan progression is not gated by explicit chapter completion', errors)

    chapter_screen = (ROOT / 'lib/screens/chapter_screen.dart').read_text(encoding='utf-8')
    for marker in ('Mark today’s reading complete', 'bookIndex == 0 && chapterIndex == 0', 'widget.library.books.length - 1'):
        if marker not in chapter_screen:
            fail(f'Chapter boundary/progression safeguard missing: {marker}', errors)

    workflow = (ROOT / '.github/workflows/build-android.yml').read_text(encoding='utf-8')
    for step in ('fetch_full_bible.py', 'verify_full_bible.py', 'flutter analyze', 'flutter test', 'flutter build apk --release', 'flutter build appbundle --release'):
        if step not in workflow:
            fail(f'CI workflow missing {step}', errors)

    main_activity = (ROOT / 'android/app/src/main/kotlin/org/pastorabayomi/young_minds_bible/MainActivity.kt').read_text(encoding='utf-8')
    if 'package org.pastorabayomi.young_minds_bible' not in main_activity:
        fail('Android package name does not match Flutter-generated application id', errors)

    # Catch accidental literal newlines inside normal single-quoted Dart strings, a prior source bug.
    for dart in ROOT.glob('lib/**/*.dart'):
        text = dart.read_text(encoding='utf-8')
        if re.search(r"'[^'\\\n]*\n[^']*'", text):
            # This heuristic can span code between strings, so only flag known dangerous Text('... newline ...') pattern.
            if re.search(r"Text\('[^'\\\n]*\n[^']*'\)", text):
                fail(f'Possible multiline single-quoted Dart string in {dart.relative_to(ROOT)}', errors)

    for py in ROOT.glob('tool/*.py'):
        try:
            py_compile.compile(str(py), doraise=True)
        except Exception as exc:
            fail(f'Python tool syntax error in {py.name}: {exc}', errors)

    print('Young Minds Bible comprehensive source audit')
    print(f'Files: {sum(1 for p in ROOT.rglob("*") if p.is_file())}')
    print(f'Canonical metadata: {len(metadata)} books, {chapter_total} chapters')
    print(f'Embedded KJV now: {books} books, {chapters} chapters, {verses} verses')
    for warning in warnings:
        print('WARNING:', warning)
    for error in errors:
        print('ERROR:', error)
    if errors:
        print(f'FAIL: {len(errors)} issue(s) found.')
        return 1
    print('PASS: source structure, persistence, navigation safeguards, progression wiring, package consistency, Python tools, and CI release gates passed.')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
