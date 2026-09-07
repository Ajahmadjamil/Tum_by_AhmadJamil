import json
import re
from pathlib import Path

sql = Path(r"c:\Users\aj\StudioProjects\tum\.tmp_import_chunks\01_poetry.sql").read_text(
    encoding="utf-8"
)
pattern = re.compile(
    r"\('([0-9a-f-]+)'::uuid, '[0-9a-f-]+'::uuid, '[0-9a-f-]+'::uuid, "
    r"\(select id from public.categories where slug = '([^']+)'\), "
    r"\$u\$(tum-p[0-9]+)\$u\$, \$u\$(.*?)\$u\$, (\d+), true, now\(\)",
    re.S,
)
rows = []
for match in pattern.finditer(sql):
    rows.append(
        {
            "id": match.group(1),
            "cat": match.group(2),
            "slug": match.group(3),
            "title": match.group(4),
            "sort": int(match.group(5)),
        }
    )
Path(r"c:\Users\aj\StudioProjects\tum\.tmp_poems.json").write_text(
    json.dumps(rows, ensure_ascii=False, separators=(",", ":")),
    encoding="utf-8",
)
print(f"rows={len(rows)} bytes={Path(r'c:\\Users\\aj\\StudioProjects\\tum\\.tmp_poems.json').stat().st_size}")
