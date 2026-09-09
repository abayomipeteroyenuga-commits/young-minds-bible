$ErrorActionPreference = "Stop"
Set-Location (Join-Path $PSScriptRoot "..")
flutter create . --platforms=android --org org.pastorabayomi --project-name young_minds_bible
python tool/fetch_full_bible.py
python tool/verify_full_bible.py
flutter pub get
flutter analyze
Write-Host "READY. Run: flutter run"
Write-Host "Play Store bundle later: flutter build appbundle --release"
