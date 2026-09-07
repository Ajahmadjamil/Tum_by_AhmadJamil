import hashlib
import json
from pathlib import Path

import openpyxl

XLSX = Path(r"c:\Users\aj\Videos\tum_by_ahmad_jamil.xlsx")
OUT = Path(r"c:\Users\aj\StudioProjects\tum\.tmp_import_chunks")
OUT.mkdir(exist_ok=True)
CHUNK = 5


def normalize_body(body: object) -> str:
    text = "" if body is None else str(body)
    return text.replace("\r\n", "\n").replace("\r", "\n").strip()


def main() -> None:
    wb = openpyxl.load_workbook(XLSX, data_only=True)
    ws = wb["Poetry"]
    rows = []
    index = 0
    for row in ws.iter_rows(min_row=2, values_only=True):
        _excel_id, title, body, category, _conf = row
        if not title and not body:
            continue
        index += 1
        body_text = normalize_body(body)
        rows.append(
            {
                "slug": f"tum-p{index:03d}",
                "sort": index,
                "title": str(title or "").strip(),
                "category": str(category or "").strip().lower(),
                "body": body_text,
                "chars": len(body_text),
                "sha256": hashlib.sha256(body_text.encode("utf-8")).hexdigest(),
            }
        )

    for old in OUT.glob("b*_bodies.sql"):
        old.unlink()

    for i in range(0, len(rows), CHUNK):
        chunk = [{"slug": r["slug"], "body": r["body"]} for r in rows[i : i + CHUNK]]
        payload = json.dumps(chunk, ensure_ascii=False, separators=(",", ":"))
        sql = (
            "update public.poetry as p\n"
            "set body = x.body\n"
            "from (\n"
            "  select x->>'slug' as slug, x->>'body' as body\n"
            f"  from jsonb_array_elements($bodies${payload}$bodies$::jsonb) x\n"
            ") as x\n"
            "where p.slug = x.slug;\n"
        )
        n = i // CHUNK
        path = OUT / f"b{n:02d}_bodies.sql"
        path.write_text(sql, encoding="utf-8")
        print(f"{path.name} slugs={[c['slug'] for c in chunk]} bytes={path.stat().st_size}")

    meta = [
        {k: r[k] for k in ("slug", "sort", "title", "category", "chars", "sha256")}
        for r in rows
    ]
    (OUT / "body_checksums.json").write_text(
        json.dumps(meta, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )
    print(f"total={len(rows)} chunks={(len(rows) + CHUNK - 1) // CHUNK}")


if __name__ == "__main__":
    main()
