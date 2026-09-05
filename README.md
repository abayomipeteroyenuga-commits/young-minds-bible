# Young Minds Bible — Combined Complete Edition

**Read • Understand • Grow**

Young Minds Bible is an offline-first Flutter Bible reader designed for young readers. The core reading experience has no required login and is designed so the finished Android app can read the Bible without internet.

## What is implemented

- Home dashboard and Verse of the Day
- Genesis-to-Revelation book/chapter reader architecture
- Old Testament / New Testament browsing
- Chapter selector and numbered verses
- Previous / next chapter navigation across book boundaries
- Offline full-text search and direct-reference search such as `John 3:16`
- Bookmarks
- Highlights
- Private device-local notes
- Continue reading
- Reading plans
- Adjustable text size and line spacing support
- Verse-number toggle
- Dark mode
- Verse sharing
- Onboarding
- Five-tab mobile navigation
- Local persistence via SharedPreferences
- Android package starter: `org.pastorabayomi.young_minds_bible`
- Play Store build workflow

## Full Bible: how offline reading works

The **complete KJV is embedded at build time**, not downloaded by readers.

On an internet-enabled development computer or GitHub Actions, `tool/fetch_full_bible.py` retrieves the public-domain KJV corpus and writes the complete local asset to `assets/data/kjv.json`. `tool/verify_full_bible.py` validates 66 books, 1,189 chapters and 31,000+ non-empty verses before the release is built.

The resulting APK/AAB packages that file inside the app. After a user installs the app, Genesis through Revelation, chapter navigation and search work offline.

The small `sample_bible.json` exists only as a development fallback if somebody opens the source before preparing the production asset.

## Easiest Android build

### Windows

```powershell
cd young_minds_bible
.\tool\prepare_project.ps1
flutter run
```

### macOS / Linux

```bash
cd young_minds_bible
./tool/prepare_project.sh
flutter run
```

## Automatic GitHub build

The ZIP includes `.github/workflows/build-android.yml`. Put the project in a GitHub repository and run the **Build Young Minds Bible Android** workflow. It creates/repairs the Android scaffold, embeds and verifies the full KJV, runs Flutter analysis, and produces both:

- `app-release.apk` — install/testing build
- `app-release.aab` — Google Play Store upload bundle

## Bible navigation seen by users

`Bible` → `Genesis` → `Chapter 1` → verses 1, 2, 3…

or

`Bible` → `John` → `Chapter 3` → verse 16…

Tapping a verse opens Bookmark, Highlight, Note and Share actions.

## Production checks

Before Play Store submission, add final launcher icons/screenshots, configure release signing, complete the Play Console Data Safety/content-rating/target-audience declarations, publish an accurate privacy policy, and test the release on multiple real Android devices.

## Why GitHub shows Dart
Flutter applications are primarily written in **Dart**, so GitHub normally labels this repository as Dart. Flutter is the app framework, not a separate GitHub programming-language label. The native Android host is included under `android/` with Kotlin and Gradle files, and GitHub Actions builds Android APK/AAB artifacts.
