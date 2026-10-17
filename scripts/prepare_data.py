import os
import re
import json
import sqlite3
import urllib.request
from PIL import Image

BASE_DIR = r"c:\Users\abela\Documents\PocketBible"
SOURCE_POCKETBIBLE = r"c:\Users\abela\Downloads\pocketbible"

print("1. Extracting book metadata...")
with open(os.path.join(SOURCE_POCKETBIBLE, "books", "1CH-001.html"), "r", encoding="utf-8") as f:
    content = f.read()

m = re.search(r"window\.BIBLE_BOOKS=(\[.*?\]);", content)
if not m:
    raise Exception("BIBLE_BOOKS not found in 1CH-001.html")

raw_books = json.loads(m.group(1))

OT_CODES = set([
    'GEN','EXO','LEV','NUM','DEU','JOS','JDG','RUT','1SA','2SA','1KI','2KI',
    '1CH','2CH','EZR','NEH','EST','JOB','PSA','PRO','ECC','SNG','ISA','JER',
    'LAM','EZK','DAN','HOS','JOL','AMO','OBA','JON','MIC','NAM','HAB','ZEP',
    'HAG','ZEC','MAL'
])

books = []
for idx, b in enumerate(raw_books, start=1):
    testament = "OT" if b['code'] in OT_CODES else "NT"
    books.append({
        "order": idx,
        "code": b['code'],
        "name": b['name'],
        "testament": testament,
        "total_chapters": len(b['chapters']),
        "chapters": b['chapters']
    })

books_json_path = os.path.join(BASE_DIR, "assets", "data", "books.json")
with open(books_json_path, "w", encoding="utf-8") as f:
    json.dump(books, f, ensure_ascii=False, indent=2)
print(f"Saved {len(books)} books to {books_json_path}")

print("2. Copying today's verses and verse refs...")
today_src = os.path.join(SOURCE_POCKETBIBLE, "assets", "today-verse.json")
today_dst = os.path.join(BASE_DIR, "assets", "data", "today_verses.json")
with open(today_src, "r", encoding="utf-8") as f_in, open(today_dst, "w", encoding="utf-8") as f_out:
    data = json.load(f_in)
    json.dump(data, f_out, ensure_ascii=False, indent=2)
print(f"Saved {len(data)} daily verses to {today_dst}")

refs_src = os.path.join(SOURCE_POCKETBIBLE, "assets", "verse-refs.json")
refs_dst = os.path.join(BASE_DIR, "assets", "data", "verse_refs.json")
with open(refs_src, "r", encoding="utf-8") as f_in, open(refs_dst, "w", encoding="utf-8") as f_out:
    data = json.load(f_in)
    json.dump(data, f_out, ensure_ascii=False)
print(f"Saved {len(data)} verse refs to {refs_dst}")

print("3. Building SQLite Database pocketbible.db...")
db_path = os.path.join(BASE_DIR, "assets", "database", "pocketbible.db")
if os.path.exists(db_path):
    os.remove(db_path)

conn = sqlite3.connect(db_path)
cur = conn.cursor()

# Enable pragmas for speed and foreign keys
cur.execute("PRAGMA journal_mode = WAL")
cur.execute("PRAGMA synchronous = NORMAL")

cur.execute("""
CREATE TABLE books (
    id INTEGER PRIMARY KEY,
    book_order INTEGER UNIQUE,
    code TEXT UNIQUE,
    name TEXT,
    testament TEXT,
    total_chapters INTEGER
)
""")

cur.execute("""
CREATE TABLE verses (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    book_code TEXT,
    chapter INTEGER,
    verse INTEGER,
    text TEXT
)
""")

cur.execute("""
CREATE TABLE bookmarks (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    book_code TEXT,
    book_name TEXT,
    chapter INTEGER,
    verse INTEGER,
    text TEXT,
    created_at INTEGER
)
""")

cur.execute("""
CREATE TABLE highlights (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    book_code TEXT,
    chapter INTEGER,
    verse INTEGER,
    color TEXT,
    created_at INTEGER,
    UNIQUE(book_code, chapter, verse)
)
""")

cur.execute("""
CREATE TABLE notes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    book_code TEXT,
    chapter INTEGER,
    verse INTEGER,
    note_text TEXT,
    created_at INTEGER,
    updated_at INTEGER,
    UNIQUE(book_code, chapter, verse)
)
""")

cur.execute("""
CREATE TABLE reading_history (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    book_code TEXT,
    book_name TEXT,
    chapter INTEGER,
    timestamp INTEGER
)
""")

# Insert books
cur.executemany(
    "INSERT INTO books (book_order, code, name, testament, total_chapters) VALUES (?, ?, ?, ?, ?)",
    [(b['order'], b['code'], b['name'], b['testament'], b['total_chapters']) for b in books]
)

# Insert verses from search.json
search_src = os.path.join(SOURCE_POCKETBIBLE, "assets", "search.json")
with open(search_src, "r", encoding="utf-8") as f:
    verses_data = json.load(f)

cur.executemany(
    "INSERT INTO verses (book_code, chapter, verse, text) VALUES (?, ?, ?, ?)",
    [(v['c'], v['ch'], v['v'], v['t']) for v in verses_data]
)

# Create indices
cur.execute("CREATE INDEX idx_verses_book_ch ON verses(book_code, chapter)")
cur.execute("CREATE INDEX idx_verses_lookup ON verses(book_code, chapter, verse)")

# Create FTS5 virtual table for lightning-fast search
cur.execute("""
CREATE VIRTUAL TABLE verses_fts USING fts5(
    book_code,
    chapter UNINDEXED,
    verse UNINDEXED,
    text
)
""")

cur.execute("""
INSERT INTO verses_fts (book_code, chapter, verse, text)
SELECT book_code, chapter, verse, text FROM verses
""")

conn.commit()
vcount = cur.execute("SELECT COUNT(*) FROM verses").fetchone()[0]
print(f"Inserted {vcount} verses into pocketbible.db")
conn.close()

db_size_mb = os.path.getsize(db_path) / (1024 * 1024)
print(f"Database size: {db_size_mb:.2f} MB")

print("4. Downloading Malayalam Noto Sans fonts for offline use...")
font_dir = os.path.join(BASE_DIR, "assets", "fonts")
fonts = [
    ("NotoSansMalayalam-Regular.ttf", "https://raw.githubusercontent.com/googlefonts/noto-fonts/main/hinted/ttf/NotoSansMalayalam/NotoSansMalayalam-Regular.ttf"),
    ("NotoSansMalayalam-Bold.ttf", "https://raw.githubusercontent.com/googlefonts/noto-fonts/main/hinted/ttf/NotoSansMalayalam/NotoSansMalayalam-Bold.ttf")
]
for fname, url in fonts:
    fpath = os.path.join(font_dir, fname)
    if not os.path.exists(fpath):
        print(f"Downloading {fname}...")
        req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req) as resp, open(fpath, "wb") as out:
            out.write(resp.read())
        print(f"Saved {fname} ({os.path.getsize(fpath)} bytes)")

print("5. Generating app icons from PocketBible touch icon...")
touch_icon_path = os.path.join(SOURCE_POCKETBIBLE, "assets", "pocketbible-icon-touch.png")
touch_icon = Image.open(touch_icon_path).convert("RGBA")

# Save primary assets icons
touch_icon.save(os.path.join(BASE_DIR, "assets", "icons", "pocketbible-icon-touch.png"))

# Create 512x512 master app icon with the warm cream/surface background
master_icon = Image.new("RGBA", (512, 512), (243, 245, 247, 255))
# Center touch icon in master icon
# Resize touch icon maintaining aspect ratio
orig_w, orig_h = touch_icon.size
scale = min(380 / orig_w, 380 / orig_h)
new_w, new_h = int(orig_w * scale), int(orig_h * scale)
resized_touch = touch_icon.resize((new_w, new_h), Image.Resampling.LANCZOS)
paste_x = (512 - new_w) // 2
paste_y = (512 - new_h) // 2
master_icon.paste(resized_touch, (paste_x, paste_y), resized_touch)

master_icon_path = os.path.join(BASE_DIR, "assets", "icons", "app_icon.png")
master_icon.save(master_icon_path)
print(f"Created 512x512 master icon at {master_icon_path}")

print("All assets prepared successfully!")
