#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter is required: https://docs.flutter.dev/get-started/install" >&2
  exit 1
fi
flutter create . --platforms=android --org org.pastorabayomi --project-name young_minds_bible
python3 tool/fetch_full_bible.py
python3 tool/verify_full_bible.py
flutter pub get
flutter analyze
printf '\nREADY. Run: flutter run\nPlay Store bundle later: flutter build appbundle --release\n'
