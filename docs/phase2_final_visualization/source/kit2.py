"""Phase 2 design system for the final-product visualization.

Builds on the verified primitives in ../../final_project_visualization/source/kit.py
(phone frame, icons, illustrative map and street scene) and adds the Phase 2
look: navy/charcoal, electric blue -> cyan accents, subtle glass, an AI orb.
"""
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                "..", "..", "final_project_visualization", "source"))
import kit  # noqa: E402
from kit import ic, nav_logo, phone, map_svg, street_svg, ROUTE, DEST  # noqa: F401,E402

kit._P.update({
    "spark": '<path d="M12 3l1.8 5.2L19 10l-5.2 1.8L12 17l-1.8-5.2L5 10l5.2-1.8z"/><path d="M19 15.5l.8 2.2 2.2.8-2.2.8-.8 2.2-.8-2.2-2.2-.8 2.2-.8z"/>',
    "shield": '<path d="M12 3l7.5 3v5.5c0 4.6-3.2 8.3-7.5 9.5-4.3-1.2-7.5-4.9-7.5-9.5V6z"/>',
    "phone": '<path d="M5 4h4l1.5 4.5-2.3 1.4a11 11 0 0 0 5.9 5.9l1.4-2.3L20 15v4a1 1 0 0 1-1 1A16 16 0 0 1 4 5a1 1 0 0 1 1-1z"/>',
    "share": '<circle cx="18" cy="5.5" r="2.5"/><circle cx="6" cy="12" r="2.5"/><circle cx="18" cy="18.5" r="2.5"/><path d="M8.2 10.8l7.6-4M8.2 13.2l7.6 4"/>',
    "download": '<path d="M12 4v11M7.5 10.5L12 15l4.5-4.5M5 19.5h14"/>',
    "wifioff": '<path d="M3 3l18 18M8.5 13a5 5 0 0 1 4-1.4M5 9.5a10 10 0 0 1 4-2.2M19 9.5a10 10 0 0 0-5.5-2.4M12 18.5h.01"/>',
    "satellite": '<path d="M13 7l4 4-6 6-4-4z"/><path d="M15 5l2-2 4 4-2 2M5 15l-2 2 4 4 2-2M16.5 13.5a3 3 0 0 1-3 3"/>',
    "access": '<circle cx="12" cy="4.5" r="1.8"/><path d="M6 8h12M12 8v6l-3.5 6.5M12 14l3.5 6.5"/>',
    "speaker": '<path d="M4 9.5h3.5L12 5.5v13l-4.5-4H4z"/><path d="M15.5 9a4 4 0 0 1 0 6M18 6.5a7.5 7.5 0 0 1 0 11"/>',
    "hospital": '<rect x="4" y="4" width="16" height="16" rx="3"/><path d="M12 8v8M8 12h8"/>',
    "police": '<path d="M12 3l7 3v5c0 4.5-3 8-7 10-4-2-7-5.5-7-10V6z"/><path d="M12 8.5l1.1 2.3 2.4.3-1.8 1.6.5 2.4L12 14l-2.2 1.1.5-2.4-1.8-1.6 2.4-.3z"/>',
    "fuel": '<rect x="4.5" y="4" width="9" height="16" rx="1.5"/><path d="M4.5 10h9M13.5 8l3.5 3v6.5a1.5 1.5 0 0 0 3 0V9l-2.5-2.5"/>',
    "book": '<path d="M4 5.5A1.5 1.5 0 0 1 5.5 4H11v16H5.5A1.5 1.5 0 0 1 4 18.5zM20 5.5A1.5 1.5 0 0 0 18.5 4H13v16h5.5a1.5 1.5 0 0 0 1.5-1.5z"/>',
    "tree": '<circle cx="12" cy="9" r="5.5"/><path d="M12 14.5V21M9 21h6"/>',
    "steps": '<path d="M3 20h5v-4h5v-4h5V8h3"/>',
    "repeat": '<path d="M17 3l3 3-3 3"/><path d="M4 11V9a3 3 0 0 1 3-3h13M7 21l-3-3 3-3"/><path d="M20 13v2a3 3 0 0 1-3 3H4"/>',
    "volume": '<path d="M4 9.5h3.5L12 5.5v13l-4.5-4H4z"/><path d="M16 9a4 4 0 0 1 0 6"/>',
    "send": '<path d="M4 12l16-8-6 16-2.5-6.5z"/>',
    "cross": '<path d="M12 5v14M5 12h14"/>',
    "people": '<circle cx="9" cy="8" r="3"/><circle cx="17" cy="9" r="2.4"/><path d="M3.5 19c.6-3 2.8-4.8 5.5-4.8s4.9 1.8 5.5 4.8M15 14.5c2.6 0 4.6 1.5 5.2 4"/>',
    "wave": '<path d="M3 12h2M7 8v8M11 5v14M15 8v8M19 10.5v3M21 12h0"/>',
})

CSS2 = r"""
#canvas{background:radial-gradient(1100px 650px at 12% 12%,#0E2348 0%,rgba(14,35,72,0) 62%),
  radial-gradient(900px 600px at 92% 92%,#06283A 0%,rgba(6,40,58,0) 60%),#060A12 !important}
:root{--cyan:#22D3EE;--elec:#2F6BFF}
.aur{background:linear-gradient(135deg,#2F6BFF 0%,#22D3EE 100%)}
.aurtext{background:linear-gradient(135deg,#7FB2FF,#5EEAF5);-webkit-background-clip:text;color:transparent}
.g2{background:rgba(14,20,34,.74);border:1px solid rgba(255,255,255,.08);backdrop-filter:blur(18px);-webkit-backdrop-filter:blur(18px);
  box-shadow:0 14px 34px rgba(0,0,0,.45),inset 0 1px 0 rgba(255,255,255,.05)}
.g2l{background:rgba(255,255,255,.04);border:1px solid rgba(255,255,255,.07)}
.navbar{position:absolute;left:0;right:0;bottom:0;height:86px;padding:8px 14px 22px;display:flex;align-items:center;justify-content:space-around;
  background:rgba(8,12,22,.92);border-top:1px solid rgba(255,255,255,.07);z-index:40;backdrop-filter:blur(18px)}
.navbar .it{display:flex;flex-direction:column;align-items:center;gap:4px;font-size:10.5px;font-weight:600;color:#7D8AA5;width:62px}
.navbar .on{color:#BFE9FF}
.orb{border-radius:50%;display:flex;align-items:center;justify-content:center;
  background:radial-gradient(circle at 30% 25%,#9BE8FF 0%,#22D3EE 22%,#2F6BFF 62%,#1A3FBF 100%);
  box-shadow:0 0 0 4px rgba(34,211,238,.12),0 10px 28px rgba(34,211,238,.45)}
.chip2{display:inline-flex;align-items:center;gap:6px;height:32px;padding:0 12px;border-radius:999px;font-size:12.5px;font-weight:600;
  background:rgba(34,211,238,.09);color:#A8F0FB;border:1px solid rgba(34,211,238,.22);white-space:nowrap}
.chipw{background:rgba(255,255,255,.05);color:#D6DEEE;border:1px solid rgba(255,255,255,.1)}
.h2t{font-size:13px;font-weight:700;letter-spacing:.09em;text-transform:uppercase;color:#6F7E9C}
.bub-u{align-self:flex-end;max-width:78%;padding:11px 14px;border-radius:18px 18px 4px 18px;font-size:14.5px;line-height:1.4;
  background:linear-gradient(135deg,#2F6BFF,#2A8BEF);color:#fff}
.bub-a{align-self:flex-start;max-width:90%;padding:12px 14px;border-radius:18px 18px 18px 4px;font-size:14.5px;line-height:1.45;
  background:rgba(255,255,255,.06);border:1px solid rgba(255,255,255,.08);color:#E8ECF5}
.tool{display:inline-flex;align-items:center;gap:5px;font-family:'JetBrains Mono',monospace;font-size:10.5px;color:#7FA0C8;
  background:rgba(127,160,200,.08);border:1px solid rgba(127,160,200,.18);padding:2px 7px;border-radius:6px;margin:6px 6px 0 0}
.sbtn{height:40px;border-radius:12px;display:inline-flex;align-items:center;justify-content:center;gap:7px;padding:0 14px;font-size:13px;font-weight:700}
.sbtn.p{background:linear-gradient(135deg,#2F6BFF,#22B8EE);color:#fff;box-shadow:0 6px 18px rgba(34,160,238,.35)}
.sbtn.t{background:rgba(255,255,255,.07);color:#E3E9F5;border:1px solid rgba(255,255,255,.08)}
.dot{width:8px;height:8px;border-radius:50%;display:inline-block}
.tag2{position:absolute;z-index:46;font-size:9px;font-weight:800;letter-spacing:.07em;padding:3px 6px;border-radius:6px;white-space:nowrap;box-shadow:0 3px 10px rgba(0,0,0,.4)}
.t-road{background:#FBBF24;color:#1A1300}
.t-prop{background:#C4B5FD;color:#1B1035}
.t-impl{background:#5BE08A;color:#05210F}
.t-m0{background:#67E8F9;color:#032A30}
.item{grid-template-columns:250px 1fr !important}
.b-prop{background:rgba(196,181,253,.10);color:#D8CCFF;border:1px dashed rgba(196,181,253,.7)}
.tgt{position:absolute;z-index:47;left:50%;transform:translateX(-50%);font-size:9.5px;font-weight:800;letter-spacing:.08em;padding:4px 9px;border-radius:7px;
  background:rgba(8,12,22,.85);color:#FCD34D;border:1px dashed rgba(252,211,77,.75);white-space:nowrap}
"""

TIERS = {
    "impl": ("b-impl", "Phase 1 · existing"),
    "m0": ("b-m0", "Phase 2 M0 · completed"),
    "road": ("b-plan", "Phase 2 roadmap · not built"),
    "prop": ("b-prop", "Proposed · not in roadmap yet"),
}

def badge2(kind, text=None):
    cls, default = TIERS[kind]
    return f'<span class="badge {cls}">{text or default}</span>'

def tag(kind, text, style):
    return f'<div class="tag2 t-{kind}" style="{style}">{text}</div>'

def legend2(x, y):
    return (f'<div class="legend" style="left:{x}px;top:{y}px">'
            + "".join(badge2(k) for k in ("impl", "m0", "road", "prop")) + '</div>')

def panel2(x, y, w, eyebrow, title, sub, items):
    rows = "".join(
        f'<div class="item"><div>{badge2(k, bt)}</div><div><div class="h">{h}</div><div class="d">{d}</div></div></div>'
        for (k, bt, h, d) in items)
    return (f'<div class="panel" style="left:{x}px;top:{y}px;width:{w}px">'
            f'<div class="eyebrow" style="color:#5EE6F5">{eyebrow}</div><div class="ptitle">{title}</div>'
            f'<div class="psub">{sub}</div><div class="items">{rows}</div></div>')

FOOT2 = ("Phase 2 target-product concept rendered from HTML/SVG. Camera and map imagery are illustrations; places, distances and times are "
         "sample values. No accuracy, latency or model-performance figures are claimed. Tags show what exists, what is on the approved "
         "roadmap, and what is proposed.")

def page2(body, w, h):
    return kit.page(f"<style>{CSS2}</style>" + body, w, h)

def orb(size=56, icon=24):
    return f'<div class="orb" style="width:{size}px;height:{size}px">{ic("spark", icon, "#fff", 2)}</div>'

def navbar(active="home"):
    items = [("home", "home", "Home"), ("search", "discover", "Discover"), None, ("ar", "ar", "AR"), ("bookmark", "saved", "Saved")]
    out = []
    for it in items:
        if it is None:
            out.append(f'<div style="margin-top:-30px">{orb(62, 27)}</div>')
            continue
        icon, key, label = it
        on = "on" if key == active else ""
        col = "#BFE9FF" if on else "#7D8AA5"
        out.append(f'<div class="it {on}">{ic(icon, 22, col)}<span>{label}</span></div>')
    return '<div class="navbar">' + "".join(out) + '</div>'

def fade(top=True, h=200, a=.9):
    d = "180deg" if top else "0deg"
    pos = "top:0" if top else "bottom:0"
    return (f'<div style="position:absolute;left:0;right:0;{pos};height:{h}px;z-index:5;'
            f'background:linear-gradient({d},rgba(6,10,18,{a}) 0%,rgba(6,10,18,{a*.55}) 50%,rgba(6,10,18,0) 100%)"></div>')

def tgt(text, top):
    return f'<div class="tgt" style="top:{top}px">{text}</div>'
