import json
from pathlib import Path

rows = json.loads(Path(r"c:\Users\aj\StudioProjects\tum\.tmp_poems.json").read_text(encoding="utf-8"))
out = Path(r"c:\Users\aj\StudioProjects\tum\.tmp_import_chunks")
size = 26
for i in range(0, len(rows), size):
    chunk = rows[i : i + size]
    payload = json.dumps(chunk, ensure_ascii=False, separators=(",", ":"))
    sql = f"""insert into public.poetry (
  id, poet_id, book_id, category_id, slug, title_urdu, sort_order, is_published, published_at
)
select
  (x->>'id')::uuid,
  '485b52b3-678e-4b97-8b92-0151945acb81'::uuid,
  '7a52aa3b-4d70-40b2-8848-a7655c3f1ece'::uuid,
  c.id,
  x->>'slug',
  x->>'title',
  (x->>'sort')::int,
  true,
  now()
from jsonb_array_elements($poems${payload}$poems$::jsonb) x
join public.categories c on c.slug = x->>'cat'
on conflict (slug) do nothing;
"""
    n = i // size
    (out / f"p{n:02d}_poems.sql").write_text(sql, encoding="utf-8")
print(f"chunks={(len(rows)+size-1)//size} chunk0_bytes={(out/'p00_poems.sql').stat().st_size}")
