import json
import uuid
from collections import Counter

import openpyxl

XLSX = r"c:\Users\aj\Videos\tum_by_ahmad_jamil.xlsx"
OUT_SQL = r"c:\Users\aj\StudioProjects\tum\supabase\migrations\20260907140000_import_tum_poetry.sql"
OUT_META = r"c:\Users\aj\StudioProjects\tum\.tmp_import_meta.json"

POET = "485b52b3-678e-4b97-8b92-0151945acb81"
BOOK = "7a52aa3b-4d70-40b2-8848-a7655c3f1ece"
CAT = {
    "ghazal": "ghazal",
    "nazm": "nazm",
    "sher": "shair",
    "qata": "qataa",
    "tehreer": "tehreer",
}


def lines_of(body: object) -> list[str]:
    text = "" if body is None else str(body)
    text = text.replace("\r\n", "\n").replace("\r", "\n").strip()
    return [ln.strip() for ln in text.split("\n") if ln.strip()]


def verses_for(category: str, body: object) -> list[tuple[str, str | None]]:
    lines = lines_of(body)
    verses: list[tuple[str, str | None]] = []
    if category in ("ghazal", "qata", "sher"):
        for i in range(0, len(lines), 2):
            m1 = lines[i]
            m2 = lines[i + 1] if i + 1 < len(lines) else None
            verses.append((m1, m2))
    else:
        for ln in lines:
            verses.append((ln, None))
    return verses


def dollar(value: str | None) -> str:
    if value is None:
        return "null"
    tag = "u"
    while f"${tag}$" in value:
        tag += "x"
    return f"${tag}${value}${tag}$"


def main() -> None:
    wb = openpyxl.load_workbook(XLSX, data_only=True)
    ws = wb["Poetry"]
    poems = []
    for row in ws.iter_rows(min_row=2, values_only=True):
        excel_id, title, body, category, _conf = row
        if not title and not body:
            continue
        category = (category or "").strip().lower()
        if category not in CAT:
            raise SystemExit(f"unknown category {category} {excel_id}")
        title_text = str(title or "").strip()
        verses = verses_for(category, body)
        if not verses:
            raise SystemExit(f"no verses {excel_id}")
        poems.append(
            {
                "excel_id": str(excel_id),
                "title": title_text,
                "category": category,
                "slug_cat": CAT[category],
                "verses": verses,
                "poetry_id": str(uuid.uuid4()),
            }
        )

    parts = [
        "-- Import Tum by Ahmad Jamil from Excel, preserving worksheet order.",
        "insert into public.categories (slug, name_urdu, name_english, sort_order)",
        "values ('tehreer', 'تحریر', 'Tehreer', 5)",
        "on conflict (slug) do nothing;",
        "",
        "insert into public.poetry (",
        "  id, poet_id, book_id, category_id, slug, title_urdu, sort_order, is_published, published_at",
        ")",
        "values",
    ]

    value_rows = []
    for i, poem in enumerate(poems, start=1):
        slug = "tum-" + poem["excel_id"].lower()
        value_rows.append(
            "  ("
            + ", ".join(
                [
                    f"'{poem['poetry_id']}'::uuid",
                    f"'{POET}'::uuid",
                    f"'{BOOK}'::uuid",
                    f"(select id from public.categories where slug = '{poem['slug_cat']}')",
                    dollar(slug),
                    dollar(poem["title"]),
                    str(i),
                    "true",
                    "now()",
                ]
            )
            + ")"
        )
    parts.append(",\n".join(value_rows) + ";")
    parts.append("")
    parts.append(
        "insert into public.poetry_verses (id, poetry_id, sort_order, misra_1, misra_2)"
    )
    parts.append("values")

    verse_rows = []
    verse_count = 0
    for poem in poems:
        for index, (misra1, misra2) in enumerate(poem["verses"], start=1):
            verse_count += 1
            verse_rows.append(
                "  ("
                + ", ".join(
                    [
                        f"'{uuid.uuid4()}'::uuid",
                        f"'{poem['poetry_id']}'::uuid",
                        str(index),
                        dollar(misra1),
                        "null" if misra2 is None else dollar(misra2),
                    ]
                )
                + ")"
            )
    parts.append(",\n".join(verse_rows) + ";")

    sql = "\n".join(parts) + "\n"
    with open(OUT_SQL, "w", encoding="utf-8") as handle:
        handle.write(sql)

    meta = {
        "poems": len(poems),
        "verses": verse_count,
        "by_category": dict(Counter(p["slug_cat"] for p in poems)),
        "sql_bytes": len(sql.encode("utf-8")),
        "first_title": poems[0]["title"],
        "last_title": poems[-1]["title"],
    }
    with open(OUT_META, "w", encoding="utf-8") as handle:
        json.dump(meta, handle, ensure_ascii=False, indent=2)
    print(json.dumps(meta, ensure_ascii=False))


if __name__ == "__main__":
    main()
