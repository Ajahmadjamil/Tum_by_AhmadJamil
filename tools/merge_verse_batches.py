from pathlib import Path

d = Path(r"c:\Users\aj\StudioProjects\tum\.tmp_import_chunks")
# Remaining files after j00 (already uploaded). Groups of 3 keep payloads ~30KB.
remaining = [d / f"j{i:02d}_verses.sql" for i in range(1, 25)]
size = 3
for i in range(0, len(remaining), size):
    group = remaining[i : i + size]
    text = "\n".join(p.read_text(encoding="utf-8") for p in group)
    out = d / f"batch_{i // size:02d}.sql"
    out.write_text(text, encoding="utf-8")
    print(f"{out.name} files={[p.name for p in group]} bytes={out.stat().st_size}")
