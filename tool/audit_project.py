from pathlib import Path
import json, re, sys
root=Path(__file__).resolve().parents[1]
errors=[]; warnings=[]
required=[
'pubspec.yaml','lib/main.dart','lib/models/bible_models.dart','lib/services/bible_service.dart','lib/services/preferences_service.dart',
'lib/screens/home_screen.dart','lib/screens/books_screen.dart','lib/screens/chapter_screen.dart','lib/screens/search_screen.dart','lib/screens/saved_screen.dart','lib/screens/more_screen.dart','lib/screens/plans_screen.dart',
'assets/data/book_metadata.json','assets/data/sample_bible.json','assets/data/kjv.json','PLAY_STORE_CHECKLIST.md','tool/verify_full_bible.py','.github/workflows/build-android.yml']
for f in required:
    if not (root/f).exists(): errors.append('Missing '+f)
meta=json.loads((root/'assets/data/book_metadata.json').read_text())
if len(meta)!=66: errors.append(f'Expected 66 metadata books, found {len(meta)}')
if sum(x['chapters'] for x in meta)!=1189: errors.append('Expected 1189 chapters in Protestant canon metadata')
try:
    kjv=json.loads((root/'assets/data/kjv.json').read_text())
    if len(kjv.get('books',[]))!=66: warnings.append('Full KJV corpus not embedded yet; run tool/fetch_full_bible.py before production build.')
except Exception as e: errors.append('Invalid kjv.json: '+str(e))
pub=(root/'pubspec.yaml').read_text()
for asset in ['assets/data/kjv.json','assets/data/book_metadata.json','assets/data/sample_bible.json']:
    if asset not in pub: errors.append('pubspec missing '+asset)
features=['toggleBookmark','toggleHighlight','setNote','setReadingPosition','setDarkMode','setPlanProgress']
prefs=(root/'lib/services/preferences_service.dart').read_text()
for f in features:
    if f not in prefs: errors.append('Missing feature '+f)
main=(root/'lib/main.dart').read_text()
for screen in ['HomeScreen','BooksScreen','SearchScreen','SavedScreen','MoreScreen']:
    if screen not in main: errors.append('Main tabs missing '+screen)
print('Young Minds Bible project audit')
print('Files:',sum(1 for p in root.rglob('*') if p.is_file()))
print('Books metadata:',len(meta),' Chapters:',sum(x['chapters'] for x in meta))
for w in warnings: print('WARNING:',w)
for e in errors: print('ERROR:',e)
if errors: sys.exit(1)
print('PASS: source structure and feature wiring checks passed.')
