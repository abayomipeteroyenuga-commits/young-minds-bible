# Bible data source

Young Minds Bible is configured to bundle the **King James Version (KJV)** locally for offline reading.

Build-time source: Midvash `bible-data` KJV 1769 corpus. The source repository identifies this KJV edition as public domain and provides a 66-book Protestant canon in JSON/SQLite formats.

The app's `tool/fetch_full_bible.py` fetches and normalises the corpus **before compilation**. `tool/verify_full_bible.py` refuses a production build unless the local asset contains 66 books, 1,189 chapters, more than 31,000 non-empty verses, and valid verse text.

The finished APK/AAB contains the resulting `assets/data/kjv.json`; end users therefore do not need internet to read, search, bookmark, highlight, or make notes.
