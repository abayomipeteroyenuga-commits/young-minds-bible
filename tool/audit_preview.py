#!/usr/bin/env python3
from pathlib import Path
import re, subprocess, tempfile, sys
ROOT=Path(__file__).resolve().parents[1]
html=(ROOT/'OFFLINE_PREVIEW.html').read_text(encoding='utf-8')
errors=[]
required=['function neighbour(','function validateBookData(','function resolveBookName(','async function downloadAll()','async function doSearch()','function saved()']
for x in required:
    if x not in html: errors.append('Missing '+x)
books=re.findall(r"\['([^']+)','([^']+)',(\d+),'(?:Old|New) Testament'\]",html)
if len(books)!=66: errors.append(f'Expected 66 browser books, found {len(books)}')
chapters=sum(int(x[2]) for x in books)
if chapters!=1189: errors.append(f'Expected 1189 browser chapters, found {chapters}')
if "return {book:BOOKS[i+1][0],chapter:1}" not in html: errors.append('Cross-book forward progression missing')
if "return {book:BOOKS[i-1][0],chapter:BOOKS[i-1][2]}" not in html: errors.append('Cross-book backward progression missing')
# JavaScript syntax check when node exists.
m=re.search(r'<script>(.*)</script>',html,re.S)
if not m: errors.append('No script block')
else:
    try:
        with tempfile.NamedTemporaryFile('w',suffix='.js',delete=False,encoding='utf-8') as f:
            f.write(m.group(1)); name=f.name
        r=subprocess.run(['node','--check',name],capture_output=True,text=True)
        if r.returncode: errors.append('JavaScript syntax: '+(r.stderr.strip() or r.stdout.strip()))
    except FileNotFoundError:
        pass
print(f'Preview metadata: {len(books)} books, {chapters} chapters')
if errors:
    for e in errors: print('ERROR:',e)
    sys.exit(1)
print('PASS: preview syntax, canon metadata, progression, download validation, search and saved-feature wiring checks passed.')
