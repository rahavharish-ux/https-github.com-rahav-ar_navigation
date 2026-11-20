"""Combines the Phase 2 visualization into one landscape-A4 PDF.

    python3 make_pdf.py   ->  ../TN_AR_Navigation_Phase2_Final_Product.pdf
"""
import os, subprocess, tempfile
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
OUT = os.path.join(ROOT, "TN_AR_Navigation_Phase2_Final_Product.pdf")
PDFJS = os.path.join(ROOT, "..", "final_project_visualization", "source", "pdf.js")

PAGES = [
    ("screens/12_complete_product_showcase.png", "Complete Phase 2 product", "Eight core experiences, each labelled with its status"),
    ("screens/01_home_dashboard.png", "01 · Intelligent home", "AI-first start screen"),
    ("screens/02_ai_assistant.png", "02 · Multimodal AI assistant", "Text, voice and camera — Tamil and English"),
    ("screens/03_ai_destination_discovery.png", "03 · AI destination discovery", "Natural-language search with explained suggestions"),
    ("screens/04_intelligent_route_planning.png", "04 · Intelligent route planning", "Pedestrian alternatives with honest reasons"),
    ("screens/05_advanced_ar_navigation.png", "05 · Advanced live AR navigation", "The Phase 2 centrepiece"),
    ("screens/06_scene_understanding.png", "06 · Environmental understanding", "Live on-device perception and scene summary"),
    ("screens/07_hybrid_localization.png", "07 · Hybrid localization", "Sensor fusion with qualitative confidence"),
    ("screens/08_voice_navigation.png", "08 · Voice navigation", "Tamil and English, hands-free"),
    ("screens/09_intelligent_rerouting.png", "09 · Intelligent rerouting", "Deviation, voice cue, alternatives"),
    ("screens/10_offline_navigation.png", "10 · Offline navigation", "Proposed capability"),
    ("screens/11_safety_assistance.png", "11 · Safety and emergency assistance", "Proposed capability"),
    ("architecture/phase2_system_architecture.png", "Phase 2 system architecture", "Every module with its status"),
    ("architecture/ai_assistant_architecture.png", "AI assistant architecture", ""),
    ("architecture/hybrid_localization.png", "Hybrid localization", ""),
    ("architecture/scene_understanding_pipeline.png", "Scene understanding pipeline", ""),
    ("architecture/navigation_workflow.png", "AI-powered navigation workflow", ""),
    ("architecture/visual_inertial_workflow.png", "Visual-inertial localization workflow", ""),
    ("architecture/route_planning_workflow.png", "Context-aware route planning", ""),
    ("architecture/voice_interaction_workflow.png", "Tamil / English voice interaction", ""),
    ("architecture/user_journey_flowchart.png", "Complete user journey", ""),
]

CSS = """
@page{size:A4 landscape;margin:0}
*{margin:0;padding:0;box-sizing:border-box}
body{font-family:Inter,FreeSans,sans-serif;background:#060A12;color:#E8ECF5}
.pg{width:297mm;height:210mm;position:relative;overflow:hidden;page-break-after:always;
  background:radial-gradient(900px 500px at 12% 10%,#0E2348 0%,rgba(14,35,72,0) 60%),#060A12;padding:9mm 11mm 8mm}
.pg:last-child{page-break-after:auto}
.hd{display:flex;align-items:baseline;gap:12px;height:12mm}
.hd .t{font-size:17pt;font-weight:700;color:#F4F6FB}
.hd .s{font-size:9.5pt;color:#9AA6BF}
.im{height:176mm;display:flex;align-items:center;justify-content:center}
.im img{max-width:100%;max-height:100%;border-radius:3mm}
.ft{position:absolute;left:11mm;right:11mm;bottom:5mm;display:flex;justify-content:space-between;font-size:7.5pt;color:#6B7891}
.cover{display:flex;flex-direction:column;justify-content:center;padding:0 22mm}
.bd{display:inline-block;font-size:7.5pt;font-weight:800;letter-spacing:.07em;text-transform:uppercase;padding:1.2mm 3mm;border-radius:99px;margin-right:2mm}
.toc{margin-top:7mm;columns:3;column-gap:10mm;font-size:9pt;color:#C9D3E6;line-height:1.7}
"""

def main():
    tmp = tempfile.mkdtemp(prefix="tnar_p2pdf_")
    total = len(PAGES) + 1
    toc = "".join(f"<div>{i + 2}. {t}</div>" for i, (_, t, _) in enumerate(PAGES))
    pages = [f"""<div class="pg cover">
<div style="font-size:11pt;font-weight:800;letter-spacing:.3em;color:#5EE6F5">PHASE 2 · TARGET PRODUCT</div>
<div style="font-size:30pt;font-weight:800;line-height:1.1;margin-top:5mm">AI-Powered Autonomous Outdoor Navigation System</div>
<div style="font-size:14pt;color:#B4C0D6;margin-top:3mm">using Multimodal Intelligence, Visual-Inertial Localization and Context-Aware Augmented Reality</div>
<div style="font-size:11pt;color:#8D99B2;margin-top:4mm">TN AR Navigation · Android · Flutter &amp; Dart · Tamil + English</div>
<div style="margin-top:7mm"><span class="bd" style="color:#5BE08A;border:1px solid rgba(91,224,138,.5)">Phase 1 · existing</span><span class="bd" style="color:#67E8F9;border:1px solid rgba(103,232,249,.5)">Phase 2 M0 · completed</span><span class="bd" style="color:#FCD34D;border:1px dashed rgba(252,211,77,.8)">Phase 2 roadmap · not built</span><span class="bd" style="color:#D8CCFF;border:1px dashed rgba(196,181,253,.8)">Proposed · not in roadmap yet</span></div>
<div style="font-size:9.5pt;color:#9AA6BF;margin-top:5mm;max-width:240mm;line-height:1.55">The intended product at the end of Phase 2. Today only Phase 1 and milestone M0 exist; everything tagged roadmap or proposed is not built. Camera and map imagery are illustrations; places, distances and times are sample values; no accuracy or performance figures are claimed.</div>
<div class="toc">{toc}</div>
<div class="ft"><span>TN AR Navigation · Phase 2 final-product visualization</span><span>1 / {total}</span></div></div>"""]
    for i, (rel, title, sub) in enumerate(PAGES):
        jpg = os.path.join(tmp, f"p{i:02d}.jpg")
        Image.open(os.path.join(ROOT, rel)).convert("RGB").save(jpg, quality=92, optimize=True, subsampling=0)
        pages.append(f"""<div class="pg"><div class="hd"><div class="t">{title}</div><div class="s">{sub}</div></div>
<div class="im"><img src="file://{jpg}"></div>
<div class="ft"><span>docs/phase2_final_visualization/{rel}</span><span>{i + 2} / {total}</span></div></div>""")
    html = os.path.join(tmp, "doc.html")
    open(html, "w", encoding="utf-8").write(f'<!doctype html><html><head><meta charset="utf-8"><style>{CSS}</style></head><body>{"".join(pages)}</body></html>')
    env = dict(os.environ)
    env.setdefault("NODE_PATH", subprocess.check_output(["npm", "root", "-g"], text=True).strip())
    subprocess.run(["node", PDFJS, html, OUT], check=True, env=env)
    print("wrote", OUT, os.path.getsize(OUT) // 1024, "KB")

if __name__ == "__main__":
    main()
