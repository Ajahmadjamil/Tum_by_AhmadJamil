from pathlib import Path

src = Path(r"c:\Users\aj\StudioProjects\tum\supabase\migrations\20260907140000_import_tum_poetry.sql")
out_dir = Path(r"c:\Users\aj\StudioProjects\tum\.tmp_import_chunks")
out_dir.mkdir(exist_ok=True)
for old in out_dir.glob("*.sql"):
    old.unlink()

text = src.read_text(encoding="utf-8")


def split_statements(sql: str) -> list[str]:
    statements: list[str] = []
    buf: list[str] = []
    i = 0
    in_dollar = False
    tag = ""
    while i < len(sql):
        if not in_dollar and sql[i] == "$":
            j = sql.find("$", i + 1)
            if j != -1:
                tag = sql[i : j + 1]
                in_dollar = True
                buf.append(tag)
                i = j + 1
                continue
        if in_dollar:
            end = sql.find(tag, i)
            if end == -1:
                buf.append(sql[i:])
                break
            buf.append(sql[i:end] + tag)
            i = end + len(tag)
            in_dollar = False
            continue
        ch = sql[i]
        if ch == ";":
            statements.append("".join(buf).strip())
            buf = []
            i += 1
            continue
        buf.append(ch)
        i += 1
    tail = "".join(buf).strip()
    if tail:
        statements.append(tail)
    return [s for s in statements if s]


def split_value_rows(values_sql: str) -> list[str]:
    rows: list[str] = []
    i = 0
    n = len(values_sql)
    while i < n:
        while i < n and values_sql[i] in " \n\t,":
            i += 1
        if i >= n:
            break
        if values_sql[i] != "(":
            raise SystemExit(f"expected row at {i}: {values_sql[i:i+40]!r}")
        start = i
        depth = 0
        in_dollar = False
        tag = ""
        while i < n:
            if not in_dollar and values_sql[i] == "$":
                j = values_sql.find("$", i + 1)
                if j != -1:
                    tag = values_sql[i : j + 1]
                    in_dollar = True
                    i = j + 1
                    continue
            if in_dollar:
                end = values_sql.find(tag, i)
                if end == -1:
                    raise SystemExit("unterminated dollar quote")
                i = end + len(tag)
                in_dollar = False
                continue
            ch = values_sql[i]
            if ch == "(":
                depth += 1
            elif ch == ")":
                depth -= 1
                i += 1
                if depth == 0:
                    rows.append(values_sql[start:i].strip())
                    break
                continue
            i += 1
    return rows


parts = split_statements(text)
assert len(parts) == 3, len(parts)

(out_dir / "00_category.sql").write_text(parts[0] + ";\n", encoding="utf-8")
(out_dir / "01_poetry.sql").write_text(parts[1] + ";\n", encoding="utf-8")

header, values = parts[2].split("values", 1)
rows = split_value_rows(values)
chunk_size = 80
for i in range(0, len(rows), chunk_size):
    chunk = rows[i : i + chunk_size]
    n = i // chunk_size
    body = header.strip() + "\nvalues\n" + ",\n".join(chunk) + ";\n"
    (out_dir / f"v{n:02d}_verses.sql").write_text(body, encoding="utf-8")

print(f"poetry_chars={len(parts[1])} verse_rows={len(rows)} chunks={(len(rows) + chunk_size - 1) // chunk_size}")
