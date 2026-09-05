#!/usr/bin/env python3
from pathlib import Path
import json, sys
p=Path(__file__).resolve().parents[1]/'assets'/'data'/'kjv.json'
try:
    data=json.loads(p.read_text(encoding='utf-8'))
except Exception as e:
    print('FAIL: kjv.json is missing or invalid:', e); sys.exit(1)
books=data.get('books',[])
chapters=sum(len(b.get('chapters',[])) for b in books)
verses=sum(len(c.get('verses',[])) for b in books for c in b.get('chapters',[]))
empty=[(b.get('name'),c.get('number'),v.get('number')) for b in books for c in b.get('chapters',[]) for v in c.get('verses',[]) if not str(v.get('text','')).strip()]
if len(books)!=66 or chapters!=1189 or verses<31000 or empty:
    print(f'FAIL: books={len(books)}, chapters={chapters}, verses={verses}, empty={len(empty)}'); sys.exit(1)
print(f'PASS: complete offline Bible present — {len(books)} books, {chapters} chapters, {verses} verses.')
