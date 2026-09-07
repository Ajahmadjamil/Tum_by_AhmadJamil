import json
from pathlib import Path

p = Path(r"c:\Users\aj\StudioProjects\tum\.tmp_import_chunks")
names = [
    "j16_verses.sql",
    "j17_verses.sql",
    "j18_verses.sql",
    "j19_verses.sql",
    "j20_verses.sql",
    "j21_verses.sql",
    "j22_verses.sql",
    "j23_verses.sql",
    "j24_verses.sql",
]
for name in names:
    q = (p / name).read_text(encoding="utf-8")
    out = p / f"_{name.replace('.sql', '_payload.json')}"
    out.write_text(json.dumps({"query": q}, ensure_ascii=False), encoding="utf-8", newline="\n")
    print(f"{name} sql={len(q)} json={out.stat().st_size}")
