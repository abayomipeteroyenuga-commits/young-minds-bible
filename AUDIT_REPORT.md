# Young Minds Bible — Audit Report

Audit date: 2026-09-05

## Fixed in this build
- Browser Previous/Next now progresses across Bible book boundaries (e.g. Genesis 50 -> Exodus 1).
- Genesis 1 and Revelation 22 remain the only hard navigation endpoints.
- Offline book downloads are validated for expected chapter count, non-empty chapters and non-empty verse text before being cached.
- Interrupted full-Bible downloads are resumable; already valid cached books are retained.
- Browser full-text search yields periodically to reduce long UI freezes on slower devices.
- Common reference aliases such as Gen, Ps, Matt, Jn and Rev are supported in browser search.
- Browser Bookmarks, Highlights and Notes are clickable and reopen their chapter.
- Flutter Saved screen no longer scans every verse to resolve saved items; it resolves only the requested saved references.
- Flutter Search paints a loading state before a full-text scan.
- Existing reading-plan progression remains explicit: opening a chapter alone does not complete a day.

## Automated checks passed
- Canon metadata: 66 books, 1,189 chapters.
- Browser JavaScript syntax check (Node).
- Browser progression/download/search/saved wiring audit.
- Flutter source structure/persistence/navigation/package/CI audit.
- Python build/audit tool syntax checks.

## Release limitation of this workspace
`assets/data/kjv.json` is intentionally a placeholder in this source ZIP because the complete corpus could not be embedded from this restricted workspace. The included CI/build tooling fetches and verifies the full KJV corpus before Android APK/AAB compilation. A release build is blocked unless it verifies 66 books, 1,189 chapters and 31,000+ non-empty verses.
