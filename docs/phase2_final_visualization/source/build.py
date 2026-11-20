"""Builds the Phase 2 final-product visualization images.

    python3 build.py              # everything
    python3 build.py 05_advanced  # only matching outputs
Uses the renderer from ../../final_project_visualization/source/render.js.
"""
import json, os, subprocess, sys, tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.dirname(HERE)
RENDER = os.path.join(OUT, "..", "final_project_visualization", "source", "render.js")
sys.path.insert(0, HERE)

import screens2  # noqa: E402
pages = dict(screens2.PAGES)
try:
    import screens2b  # noqa: E402
    pages.update(screens2b.PAGES)
except ImportError:
    pass
try:
    import diagrams2  # noqa: E402
    pages.update(diagrams2.PAGES)
except ImportError:
    pass

only = sys.argv[1:]
tmp = tempfile.mkdtemp(prefix="tnar_p2_")
jobs = []
for rel, fn in pages.items():
    if only and not any(o in rel for o in only):
        continue
    html = os.path.join(tmp, rel.replace("/", "__") + ".html")
    with open(html, "w", encoding="utf-8") as f:
        f.write(fn())
    png = os.path.join(OUT, rel)
    os.makedirs(os.path.dirname(png), exist_ok=True)
    jobs.append({"html": html, "png": png, "scale": 2})
manifest = os.path.join(tmp, "manifest.json")
json.dump(jobs, open(manifest, "w"))
env = dict(os.environ)
env.setdefault("NODE_PATH", subprocess.check_output(["npm", "root", "-g"], text=True).strip())
subprocess.run(["node", RENDER, manifest], check=True, env=env)

from PIL import Image  # noqa: E402  lossless re-encode (opaque canvas)
for job in jobs:
    Image.open(job["png"]).convert("RGB").save(job["png"], optimize=True)
