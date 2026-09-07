import json
import re
from pathlib import Path

sql = Path(r"c:\Users\aj\StudioProjects\tum\.tmp_import_chunks\j16_verses.sql").read_text(encoding="utf-8")
m = re.search(r"\$verses\$(.*)\$verses\$", sql, re.S)
rows = json.loads(m.group(1))
wanted = {
    "e1a25003-4b02-4493-88c6-c6040ab1a8fd",
    "c877b81d-d383-40ef-9c53-14cd80222ada",
    "bca169bd-d2a7-4f96-a126-862b05baa36d",
    "bd1670c4-28ef-4205-9359-c963477c2da6",
}
updates = []
for r in rows:
    if r["id"] in wanted:
        m1 = r["m1"].replace("'", "''")
        m2 = "NULL" if r["m2"] is None else "'" + r["m2"].replace("'", "''") + "'"
        updates.append(
            f"update public.poetry_verses set misra_1 = '{m1}', misra_2 = {m2} where id = '{r['id']}';"
        )
        print("FIX", r["id"])
out = Path(r"c:\Users\aj\StudioProjects\tum\.tmp_import_chunks\_j16_fix.sql")
out.write_text("\n".join(updates), encoding="utf-8", newline="\n")
print("wrote", out, "updates", len(updates))
