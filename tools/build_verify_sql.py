import json
from pathlib import Path

rows = json.loads(
    Path(r"c:\Users\aj\StudioProjects\tum\.tmp_import_chunks\body_checksums.json").read_text(
        encoding="utf-8"
    )
)
vals = ",\n  ".join(
    f"('{r['slug']}', {r['chars']}, '{r['sha256']}')" for r in rows
)
sql = f"""with expected(slug, chars, sha256) as (
  values
  {vals}
)
select e.slug,
       e.chars as excel_chars,
       length(p.body) as db_chars,
       e.sha256 as excel_sha,
       encode(digest(p.body, 'sha256'), 'hex') as db_sha
from expected e
join public.poetry p on p.slug = e.slug
where e.chars is distinct from length(p.body)
   or e.sha256 is distinct from encode(digest(p.body, 'sha256'), 'hex')
order by p.sort_order;
"""
out = Path(r"c:\Users\aj\StudioProjects\tum\.tmp_import_chunks\verify_bodies.sql")
out.write_text(sql, encoding="utf-8")
print(f"wrote {out} bytes={out.stat().st_size}")
