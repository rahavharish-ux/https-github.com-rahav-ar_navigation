"""Combines all visualization images into one landscape-A4 PDF.

    python3 make_pdf.py
Writes ../TN_AR_NAV_Final_Project_Visualization.pdf
"""
import os, subprocess, tempfile
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
OUT = os.path.join(ROOT, "TN_AR_NAV_Final_Project_Visualization.pdf")

PAGES = [
    ("showcase/10_final_app_showcase.png", "Final application showcase", "Six key screens after Phase 2, each labelled with its implementation status"),
    ("screens/01_home_dashboard.png", "01 · Home dashboard", "Map-first start screen"),
    ("screens/02_destination_search.png", "02 · Destination search", "Google Places search with stale-result protection (M0)"),
    ("screens/03_route_preview.png", "03 · Route preview", "Route, travel time and distance before you go"),
    ("screens/04_live_ar_navigation_concept.png", "04 · Live AR navigation", "Phase 2 concept (M5) — not implemented; approximate alignment"),
    ("screens/05_2d_map_navigation.png", "05 · 2D map navigation", "Turn-by-turn navigation that works today, and the AR fallback"),
    ("screens/06_scene_understanding.png", "06 · Scene understanding", "What works today (single photo) vs the Phase 2 concept (M7/M8)"),
    ("screens/07_guidance_and_rerouting.png", "07 · Guidance and rerouting", "Leaving the route, then the recalculated route"),
    ("screens/08_saved_places.png", "08 · Saved places", "Saved destinations and account"),
    ("screens/09_permissions_and_fallback.png", "09 · Permissions and fallback", "Location, camera and AR-fallback states"),
    ("diagrams/user_journey_flowchart.png", "User journey", "Main path and alternative paths — solid implemented, dashed planned"),
    ("diagrams/system_architecture.png", "System architecture", "Layers as built in the code, planned Phase 2 modules dashed"),
]

CSS = """
@page{size:A4 landscape;margin:0}
*{margin:0;padding:0;box-sizing:border-box}
body{font-family:Inter,FreeSans,sans-serif;background:#070A10;color:#E8ECF5}
.pg{width:297mm;height:210mm;position:relative;overflow:hidden;page-break-after:always;
  background:radial-gradient(900px 500px at 15% 10%,#12203D 0%,rgba(18,32,61,0) 60%),#070A10;padding:9mm 11mm 8mm}
.pg:last-child{page-break-after:auto}
.hd{display:flex;align-items:baseline;gap:12px;height:12mm}
.hd .t{font-size:17pt;font-weight:700;color:#F4F6FB}
.hd .s{font-size:9.5pt;color:#9AA6BF}
.im{height:176mm;display:flex;align-items:center;justify-content:center}
.im img{max-width:100%;max-height:100%;border-radius:3mm;box-shadow:0 2mm 6mm rgba(0,0,0,.5)}
.ft{position:absolute;left:11mm;right:11mm;bottom:5mm;display:flex;justify-content:space-between;font-size:7.5pt;color:#6B7891}
.cover{display:flex;flex-direction:column;justify-content:center;padding:0 24mm}
.logo{width:22mm;height:22mm;border-radius:6mm;background:linear-gradient(145deg,#3D7BFF,#0B5FFF 60%,#0846C7);display:flex;align-items:center;justify-content:center}
.badge{display:inline-block;font-size:7.5pt;font-weight:800;letter-spacing:.07em;text-transform:uppercase;padding:1.2mm 3mm;border-radius:99px;margin-right:2mm}
.b1{color:#5BE08A;border:1px solid rgba(91,224,138,.5)} .b2{color:#67E8F9;border:1px solid rgba(103,232,249,.5)}
.b3{color:#FCD34D;border:1px dashed rgba(252,211,77,.8)} .b4{color:#B6C0D3;border:1px dashed rgba(168,179,199,.6)}
.toc{margin-top:8mm;columns:2;column-gap:14mm;font-size:9.5pt;color:#C9D3E6;line-height:1.75}
"""

def main():
    tmp = tempfile.mkdtemp(prefix="tnar_pdf_")
    pages = []
    total = len(PAGES) + 1
    toc = "".join(f"<div>{i + 2}. {t}</div>" for i, (_, t, _) in enumerate(PAGES))
    pages.append(f"""<div class="pg cover">
<div style="display:flex;align-items:center;gap:8mm">
<div class="logo"><svg width="58" height="58" viewBox="0 0 24 24"><path d="M12 2.5l7.2 17.3c.3.8-.5 1.5-1.2 1.1L12 17.6l-6 3.3c-.7.4-1.5-.3-1.2-1.1z" fill="#fff"/></svg></div>
<div><div style="font-size:38pt;font-weight:800;letter-spacing:.02em;line-height:1">TN AR NAV</div>
<div style="font-size:13pt;color:#9AA6BF;margin-top:2mm">AR Navigation for Tamil Nadu</div></div></div>
<div style="font-size:16pt;font-weight:600;margin-top:10mm;color:#EEF2FA">AI-Powered Human-Centric Outdoor Augmented Reality Navigation System</div>
<div style="font-size:12pt;color:#9AA6BF;margin-top:2mm">using Hybrid Localization and Real-Time Scene Understanding · Flutter &amp; Dart · Android-first</div>
<div style="font-size:12pt;font-weight:700;color:#7FA6FF;margin-top:9mm;letter-spacing:.14em;text-transform:uppercase">Final project visualization — after Phase 2</div>
<div style="margin-top:5mm"><span class="badge b1">Implemented · Phase 1</span><span class="badge b2">Implemented · Phase 2 M0</span><span class="badge b3">Phase 2 planned · concept</span><span class="badge b4">Not built / future</span></div>
<div style="font-size:9.5pt;color:#9AA6BF;margin-top:5mm;max-width:235mm;line-height:1.55">Phase 2 is at milestone M0 (reliability). Live AR navigation, live object detection, Tamil OCR, landmark recognition, walking routes, voice and the AI assistant are planned, not built, and are marked as concepts wherever they appear. Maps and camera views are drawn illustrations; places, distances and times are sample values.</div>
<div class="toc">{toc}</div>
<div class="ft"><span>TN AR NAV · Final project visualization</span><span>1 / {total}</span></div></div>""")
    for i, (rel, title, sub) in enumerate(PAGES):
        jpg = os.path.join(tmp, f"p{i:02d}.jpg")
        Image.open(os.path.join(ROOT, rel)).convert("RGB").save(jpg, quality=92, optimize=True, subsampling=0)
        pages.append(f"""<div class="pg"><div class="hd"><div class="t">{title}</div><div class="s">{sub}</div></div>
<div class="im"><img src="file://{jpg}"></div>
<div class="ft"><span>TN AR NAV · Final project visualization · docs/final_project_visualization/{rel}</span><span>{i + 2} / {total}</span></div></div>""")
    html = os.path.join(tmp, "doc.html")
    with open(html, "w", encoding="utf-8") as f:
        f.write(f'<!doctype html><html><head><meta charset="utf-8"><style>{CSS}</style></head><body>{"".join(pages)}</body></html>')
    env = dict(os.environ)
    env.setdefault("NODE_PATH", subprocess.check_output(["npm", "root", "-g"], text=True).strip())
    subprocess.run(["node", os.path.join(HERE, "pdf.js"), html, OUT], check=True, env=env)
    print("wrote", OUT, os.path.getsize(OUT) // 1024, "KB")

if __name__ == "__main__":
    main()
