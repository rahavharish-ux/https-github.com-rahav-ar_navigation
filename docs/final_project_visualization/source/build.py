"""Builds every visualization page and renders it to PNG.

    python3 build.py            # all pages
    python3 build.py home       # only pages whose output path contains "home"

Requires the pre-installed Playwright + Chromium (see render.js).
"""
import json, os, subprocess, sys, tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.dirname(HERE)  # docs/final_project_visualization
sys.path.insert(0, HERE)

import screens   # noqa: E402
import diagrams  # noqa: E402

pages = {**screens.PAGES, **diagrams.PAGES}
only = sys.argv[1:]
tmp = tempfile.mkdtemp(prefix="tnar_viz_")
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
subprocess.run(["node", os.path.join(HERE, "render.js"), manifest], check=True, env=env)

# Lossless re-encode: the canvas is opaque, so dropping the alpha channel and
# recompressing shrinks files ~40 % without changing a single pixel.
try:
    from PIL import Image
    for job in jobs:
        Image.open(job["png"]).convert("RGB").save(job["png"], optimize=True)
except ImportError:
    print("Pillow not installed: skipped PNG optimisation")
