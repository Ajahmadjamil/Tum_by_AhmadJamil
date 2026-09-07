import json
import re
from pathlib import Path

sql = Path(
    r"c:\Users\aj\StudioProjects\tum\supabase\migrations\20260907140000_import_tum_poetry.sql"
).read_text(encoding="utf-8")
start = sql.index("insert into public.poetry_verses")
block = sql[start:]
pattern = re.compile(
    r"\('([0-9a-f-]+)'::uuid, '([0-9a-f-]+)'::uuid, (\d+), \$u\$(.*?)\$u\$, (null|\$u\$(.*?)\$u\$)",
    re.S,
)
rows = []
for match in pattern.finditer(block):
    rows.append(
        {
            "id": match.group(1),
            "pid": match.group(2),
            "sort": int(match.group(3)),
            "m1": match.group(4),
            "m2": match.group(6),
        }
    )

out = Path(r"c:\Users\aj\StudioProjects\tum\.tmp_import_chunks")
size = 50
for i in range(0, len(rows), size):
    chunk = rows[i : i + size]
    payload = json.dumps(chunk, ensure_ascii=False, separators=(",", ":"))
    sql_text = f"""insert into public.poetry_verses (id, poetry_id, sort_order, misra_1, misra_2)
select
  (x->>'id')::uuid,
  (x->>'pid')::uuid,
  (x->>'sort')::int,
  x->>'m1',
  nullif(x->>'m2', '')
from jsonb_array_elements($verses${payload}$verses$::jsonb) x
on conflict (poetry_id, sort_order) do nothing;
"""
    n = i // size
    (out / f"j{n:02d}_verses.sql").write_text(sql_text, encoding="utf-8")

print(f"verses={len(rows)} chunks={(len(rows)+size-1)//size} first_bytes={(out/'j00_verses.sql').stat().st_size}")
