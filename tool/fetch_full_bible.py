#!/usr/bin/env python3
"""Prepare the complete public-domain KJV Bible asset for Young Minds Bible.

This is a BUILD-TIME tool. It downloads the Bible onto the developer/CI machine,
normalises it to the app schema and writes assets/data/kjv.json. The resulting
APK/AAB contains the Bible locally, so readers do not need internet.
"""
from __future__ import annotations

from pathlib import Path
import json
import sys
import urllib.request

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "assets" / "data" / "kjv.json"
BASE = "https://raw.githubusercontent.com/midvash/bible-data/main/versions/en/kjv"
WHOLE = f"{BASE}/kjv.json"

OSIS = [
    "Gen","Exod","Lev","Num","Deut","Josh","Judg","Ruth","1Sam","2Sam",
    "1Kgs","2Kgs","1Chr","2Chr","Ezra","Neh","Esth","Job","Ps","Prov",
    "Eccl","Song","Isa","Jer","Lam","Ezek","Dan","Hos","Joel","Amos",
    "Obad","Jonah","Mic","Nah","Hab","Zeph","Hag","Zech","Mal","Matt",
    "Mark","Luke","John","Acts","Rom","1Cor","2Cor","Gal","Eph","Phil",
    "Col","1Thess","2Thess","1Tim","2Tim","Titus","Phlm","Heb","Jas",
    "1Pet","2Pet","1John","2John","3John","Jude","Rev"
]


def fetch_json(url: str):
    req = urllib.request.Request(url, headers={"User-Agent": "YoungMindsBibleBuilder/1.0"})
    with urllib.request.urlopen(req, timeout=180) as response:
        return json.loads(response.read().decode("utf-8"))


def normalise_book(raw: dict) -> dict:
    name = raw.get("englishName") or raw.get("name") or raw.get("book") or ""
    chapters = []
    for ci, c in enumerate(raw.get("chapters", []), start=1):
        verses = []
        for vi, v in enumerate(c.get("verses", []), start=1):
            verses.append({
                "number": int(v.get("number") or v.get("verse") or vi),
                "text": str(v.get("text") or "").strip(),
            })
        chapters.append({"number": int(c.get("chapter") or c.get("number") or ci), "verses": verses})
    return {"name": name, "chapters": chapters}


def validate(obj: dict) -> tuple[int, int]:
    books = obj.get("books", [])
    if len(books) != 66:
        raise ValueError(f"Expected 66 books, found {len(books)}")
    chapters = sum(len(b.get("chapters", [])) for b in books)
    verses = sum(len(c.get("verses", [])) for b in books for c in b.get("chapters", []))
    if chapters != 1189:
        raise ValueError(f"Expected 1189 chapters, found {chapters}")
    if verses < 31000:
        raise ValueError(f"Expected more than 31,000 verses, found {verses}")
    for b in books:
        if not b.get("name"):
            raise ValueError("A Bible book has no name")
        for c in b.get("chapters", []):
            for v in c.get("verses", []):
                if not str(v.get("text", "")).strip():
                    raise ValueError(f"Empty verse in {b['name']} {c.get('number')}:{v.get('number')}")
    return chapters, verses


def from_whole() -> dict:
    raw = fetch_json(WHOLE)
    books = [normalise_book(b) for b in raw.get("books", [])]
    return {"translation": "KJV", "translation_name": "King James Version", "books": books}


def from_books() -> dict:
    books = []
    for index, code in enumerate(OSIS, start=1):
        print(f"[{index:02d}/66] {code}")
        books.append(normalise_book(fetch_json(f"{BASE}/books/{code}.json")))
    return {"translation": "KJV", "translation_name": "King James Version", "books": books}


def main() -> int:
    print("Preparing complete offline KJV Bible asset…")
    try:
        bible = from_whole()
    except Exception as exc:
        print(f"Whole-Bible download failed ({exc}); trying per-book fallback…")
        bible = from_books()
    chapters, verses = validate(bible)
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps(bible, ensure_ascii=False, separators=(",", ":")), encoding="utf-8")
    size = OUT.stat().st_size / 1024 / 1024
    print(f"READY: {len(bible['books'])} books, {chapters} chapters, {verses} verses, {size:.2f} MB")
    print(f"Embedded asset: {OUT}")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        raise
