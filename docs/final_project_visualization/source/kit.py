"""Shared design kit for the TN AR NAV final-project visualization.

Pure-Python HTML/SVG generators. Rendered to PNG by render.js (Playwright).
Maps and camera views are drawn illustrations, not real map tiles or photos.
"""

# --------------------------------------------------------------------------
# Design tokens (dark direction, derived from the app's seed #0B5FFF)
# --------------------------------------------------------------------------
CSS = r"""
:root{
  --bg:#0B0E14; --surface:#121722; --surface2:#1A2130; --surface3:#232C3D;
  --outline:#2E3850; --text:#E8ECF5; --text2:#9AA6BF; --text3:#6B7891;
  --brand:#0B5FFF; --primary:#3D7BFF; --primaryLight:#8FB0FF;
  --success:#34C46A; --warning:#F9A825; --error:#FF6B6B; --cyan:#22D3EE;
}
*{box-sizing:border-box;margin:0;padding:0}
html,body{background:#05070B}
body{font-family:Inter,FreeSans,"DejaVu Sans",sans-serif;-webkit-font-smoothing:antialiased;color:var(--text)}
.tamil{font-family:FreeSans,Inter,sans-serif}
#canvas{position:relative;overflow:hidden;
  background:radial-gradient(1200px 700px at 18% 20%,#12203D 0%,rgba(18,32,61,0) 60%),
             radial-gradient(900px 600px at 90% 90%,#1A1430 0%,rgba(26,20,48,0) 60%),#070A10}
.grain{position:absolute;inset:0;background-image:radial-gradient(rgba(255,255,255,.025) 1px,transparent 1px);background-size:3px 3px;pointer-events:none}

/* ---------- phone ---------- */
.phone{position:absolute;width:414px;height:868px;border-radius:56px;background:linear-gradient(145deg,#2B3140,#0E1117 40%,#1B202B);
  padding:12px;box-shadow:0 0 0 1.5px #3A4253,0 40px 90px rgba(0,0,0,.65),0 8px 24px rgba(0,0,0,.4)}
.phone::before{content:"";position:absolute;right:-4px;top:190px;width:4px;height:70px;border-radius:0 3px 3px 0;background:#2A303C}
.phone::after{content:"";position:absolute;right:-4px;top:290px;width:4px;height:110px;border-radius:0 3px 3px 0;background:#2A303C}
.screen{position:relative;width:390px;height:844px;border-radius:44px;overflow:hidden;background:var(--bg);color:var(--text)}
.punch{position:absolute;top:13px;left:50%;margin-left:-6px;width:12px;height:12px;border-radius:50%;background:#000;box-shadow:0 0 0 2px #111;z-index:60}
.statusbar{position:absolute;top:0;left:0;right:0;height:38px;display:flex;align-items:center;justify-content:space-between;
  padding:4px 26px 0;font-size:13px;font-weight:600;z-index:55;color:#fff}
.statusbar .si{display:flex;gap:6px;align-items:center}
.gesture{position:absolute;bottom:9px;left:50%;margin-left:-60px;width:120px;height:4px;border-radius:2px;background:rgba(255,255,255,.6);z-index:60}
.fill{position:absolute;inset:0}
svg.fill{width:100%;height:100%;display:block}

/* ---------- app components ---------- */
.appbar{position:absolute;top:38px;left:0;right:0;height:56px;display:flex;align-items:center;gap:14px;padding:0 16px;z-index:20;background:var(--bg)}
.appbar .t{font-size:18px;font-weight:600;flex:1;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
.iconbtn{width:44px;height:44px;border-radius:22px;display:flex;align-items:center;justify-content:center}
.glass{background:rgba(18,23,34,.78);backdrop-filter:blur(14px);-webkit-backdrop-filter:blur(14px);border:1px solid rgba(255,255,255,.08)}
.card{background:var(--surface);border:1px solid rgba(255,255,255,.06);border-radius:24px}
.sheet{position:absolute;left:12px;right:12px;background:rgba(18,23,34,.94);border:1px solid rgba(255,255,255,.07);
  border-radius:28px;box-shadow:0 20px 50px rgba(0,0,0,.55);padding:18px;backdrop-filter:blur(16px)}
.btn{height:52px;border-radius:16px;display:flex;align-items:center;justify-content:center;gap:10px;font-size:15px;font-weight:600;letter-spacing:.02em}
.btn-primary{background:linear-gradient(180deg,#2C72FF,#0B5FFF);color:#fff;box-shadow:0 8px 22px rgba(11,95,255,.35)}
.btn-tonal{background:var(--surface3);color:var(--text)}
.btn-outline{border:1.5px solid var(--outline);color:var(--primaryLight)}
.btn-danger{background:rgba(255,107,107,.15);color:#FF8A8A}
.pill{display:inline-flex;align-items:center;gap:6px;height:30px;padding:0 12px;border-radius:999px;font-size:12px;font-weight:600}
.seg{display:flex;background:var(--surface2);border-radius:999px;padding:4px;gap:4px}
.seg > div:not(.ptag){flex:1;height:38px;border-radius:999px;display:flex;align-items:center;justify-content:center;gap:6px;font-size:13px;font-weight:600;color:var(--text2)}
.seg > .on{background:rgba(61,123,255,.22);color:#CFE0FF;box-shadow:inset 0 0 0 1px rgba(143,176,255,.35)}
.muted{color:var(--text2)} .small{font-size:12px}
.listrow{display:flex;align-items:center;gap:14px;padding:12px 18px}
.listrow .ic{width:40px;height:40px;border-radius:12px;background:var(--surface2);display:flex;align-items:center;justify-content:center;flex:none}
.listrow .tx{flex:1;min-width:0}
.listrow .t1{font-size:15px;font-weight:600;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
.listrow .t2{font-size:12.5px;color:var(--text2);margin-top:2px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
.secthead{display:flex;justify-content:space-between;align-items:center;padding:14px 18px 6px;font-size:12px;font-weight:700;letter-spacing:.08em;text-transform:uppercase;color:var(--text3)}
.snack{position:absolute;left:14px;right:14px;border-radius:14px;background:#E8ECF5;color:#111827;padding:14px 16px;font-size:13.5px;
  display:flex;align-items:center;gap:12px;box-shadow:0 12px 30px rgba(0,0,0,.5);z-index:30}
.snack b{color:#0B5FFF;font-size:13px;white-space:nowrap}

/* ---------- status marking ---------- */
.planned{outline:2px dashed #FBBF24;outline-offset:4px;border-radius:inherit}
.ptag{position:absolute;z-index:45;font-size:9.5px;font-weight:800;letter-spacing:.08em;color:#1A1300;background:#FBBF24;padding:3px 7px;border-radius:6px;white-space:nowrap;box-shadow:0 4px 10px rgba(0,0,0,.4)}
.ntag{background:#A8B3C7;color:#0B0E14}
.badge{display:inline-flex;align-items:center;gap:6px;font-size:10.5px;font-weight:800;letter-spacing:.07em;text-transform:uppercase;padding:4px 9px;border-radius:999px;white-space:nowrap}
.b-impl{background:rgba(52,196,106,.13);color:#5BE08A;border:1px solid rgba(91,224,138,.35)}
.b-m0{background:rgba(34,211,238,.12);color:#67E8F9;border:1px solid rgba(103,232,249,.35)}
.b-plan{background:rgba(251,191,36,.10);color:#FCD34D;border:1px dashed rgba(252,211,77,.7)}
.b-none{background:rgba(168,179,199,.10);color:#B6C0D3;border:1px dashed rgba(168,179,199,.55)}

/* ---------- annotation panel ---------- */
.panel{position:absolute}
.eyebrow{font-size:13px;font-weight:700;letter-spacing:.18em;text-transform:uppercase;color:#7FA6FF}
.ptitle{font-family:"Inter Display",Inter,sans-serif;font-size:44px;font-weight:700;letter-spacing:-.01em;margin-top:8px;color:#F4F6FB}
.psub{font-size:17px;line-height:1.5;color:var(--text2);margin-top:10px;max-width:900px}
.items{margin-top:26px;display:flex;flex-direction:column;gap:12px}
.item{display:grid;grid-template-columns:205px 1fr;gap:16px;align-items:start;padding:12px 16px;border-radius:14px;background:rgba(255,255,255,.03);border:1px solid rgba(255,255,255,.05)}
.item .h{font-size:15px;font-weight:600;color:#EEF2FA}
.item .d{font-size:13.5px;line-height:1.45;color:var(--text2);margin-top:3px}
.legend{position:absolute;display:flex;gap:10px;flex-wrap:wrap;align-items:center}
.foot{position:absolute;font-size:12.5px;color:var(--text3);line-height:1.5}
.brandmark{display:flex;align-items:center;gap:10px}
.logo{width:36px;height:36px;border-radius:11px;background:linear-gradient(145deg,#3D7BFF,#0B5FFF 60%,#0846C7);display:flex;align-items:center;justify-content:center;box-shadow:0 6px 16px rgba(11,95,255,.45)}
"""

# --------------------------------------------------------------------------
# Icons (hand-drawn, 24x24 viewBox, stroke-based unless noted)
# --------------------------------------------------------------------------
_P = {
  "search": '<circle cx="11" cy="11" r="6.5"/><path d="M16 16l4.5 4.5"/>',
  "back": '<path d="M15 5l-7 7 7 7"/>',
  "close": '<path d="M6 6l12 12M18 6L6 18"/>',
  "bookmark": '<path d="M7 3.5h10a1 1 0 0 1 1 1V21l-6-4-6 4V4.5a1 1 0 0 1 1-1z"/>',
  "home": '<path d="M4 11l8-7 8 7v9a1 1 0 0 1-1 1h-4v-6H9v6H5a1 1 0 0 1-1-1z"/>',
  "work": '<rect x="3.5" y="7.5" width="17" height="12" rx="2"/><path d="M9 7.5V5.5a1.5 1.5 0 0 1 1.5-1.5h3A1.5 1.5 0 0 1 15 5.5v2M3.5 12.5h17"/>',
  "history": '<path d="M4 12a8 8 0 1 0 2.4-5.7"/><path d="M4 4v4h4"/><path d="M12 8v4.5l3 2"/>',
  "car": '<path d="M5 16v-4l2-5h10l2 5v4"/><path d="M4 16h16v2.5H4z"/><circle cx="8" cy="13.5" r=".8"/><circle cx="16" cy="13.5" r=".8"/>',
  "walk": '<circle cx="13" cy="4.5" r="1.8"/><path d="M10 21l2.5-6.5L15 17v4M9 11l3-3 3 3 3 1M12 8l-1.5 6.5"/>',
  "bike": '<circle cx="6" cy="16" r="3.5"/><circle cx="18" cy="16" r="3.5"/><path d="M6 16l4-7h5l3 7M10 9l3 7h-7M14 6h2.5"/>',
  "gps": '<circle cx="12" cy="12" r="4"/><path d="M12 2.5v3M12 18.5v3M2.5 12h3M18.5 12h3"/><circle cx="12" cy="12" r="7.5"/>',
  "recenter": '<path d="M12 3l7 17-7-4-7 4z"/>',
  "account": '<circle cx="12" cy="12" r="9"/><circle cx="12" cy="10" r="3"/><path d="M6.5 18.2c1.4-2 3.3-3 5.5-3s4.1 1 5.5 3"/>',
  "bug": '<rect x="7.5" y="8" width="9" height="12" rx="4.5"/><path d="M9.5 8a2.5 2.5 0 0 1 5 0M3.5 13h4M16.5 13h4M5 7.5l3 2M19 7.5l-3 2M5 19l3-2M19 19l-3-2"/>',
  "turnright": '<path d="M7 21V12a4 4 0 0 1 4-4h8"/><path d="M15 4l4 4-4 4"/>',
  "turnleft": '<path d="M17 21V12a4 4 0 0 0-4-4H5"/><path d="M9 4L5 8l4 4"/>',
  "straight": '<path d="M12 21V4"/><path d="M7 9l5-5 5 5"/>',
  "pause": '<path d="M9 5v14M15 5v14"/>',
  "stop": '<rect x="6" y="6" width="12" height="12" rx="2"/>',
  "camera": '<path d="M4 8h3l1.5-2.5h7L17 8h3a1 1 0 0 1 1 1v9a1 1 0 0 1-1 1H4a1 1 0 0 1-1-1V9a1 1 0 0 1 1-1z"/><circle cx="12" cy="13" r="3.5"/>',
  "camoff": '<path d="M4 8h3l1.5-2.5h7L17 8h3a1 1 0 0 1 1 1v9a1 1 0 0 1-1 1H4a1 1 0 0 1-1-1V9a1 1 0 0 1 1-1z"/><path d="M3 3l18 18"/>',
  "text": '<rect x="3.5" y="4.5" width="17" height="15" rx="2.5"/><path d="M8 9h8M12 9v7"/>',
  "tag": '<path d="M3.5 12.5V4.5a1 1 0 0 1 1-1h8l8 8-9 9z"/><circle cx="8" cy="8" r="1.3"/>',
  "warning": '<path d="M12 3.5l9.5 16.5h-19z"/><path d="M12 10v4.5M12 17.2v.3"/>',
  "locoff": '<path d="M12 21s-6.5-6-6.5-11a6.5 6.5 0 0 1 10.8-4.9M18.4 8.6c.1.5.1.9.1 1.4 0 5-6.5 11-6.5 11"/><path d="M3 3l18 18"/>',
  "compass": '<circle cx="12" cy="12" r="9"/><path d="M15.5 8.5l-2 5-5 2 2-5z"/>',
  "map": '<path d="M9 4.5L3.5 6.5v13L9 17.5l6 2 5.5-2v-13L15 6.5z"/><path d="M9 4.5v13M15 6.5v13"/>',
  "ar": '<path d="M12 3l8 4.5v9L12 21l-8-4.5v-9z"/><path d="M4 7.5l8 4.5 8-4.5M12 12v9"/>',
  "route": '<circle cx="6" cy="18" r="2"/><circle cx="18" cy="6" r="2"/><path d="M8 18h7a3 3 0 0 0 0-6H9a3 3 0 0 1 0-6h7"/>',
  "clock": '<circle cx="12" cy="12" r="8.5"/><path d="M12 7.5V12l3 2"/>',
  "flag": '<path d="M5 21V4M5 4h11l-2 4 2 4H5"/>',
  "sync": '<path d="M19 8a7.5 7.5 0 0 0-13.5-1.5M5 16a7.5 7.5 0 0 0 13.5 1.5"/><path d="M19 3.5V8h-4.5M5 20.5V16h4.5"/>',
  "trash": '<path d="M5 7h14M10 7V4.5h4V7M7 7l1 13h8l1-13"/>',
  "chev": '<path d="M9 5l7 7-7 7"/>',
  "pin": '<path d="M12 21s-6.5-6-6.5-11a6.5 6.5 0 0 1 13 0c0 5-6.5 11-6.5 11z"/><circle cx="12" cy="10" r="2.3"/>',
  "mic": '<rect x="9" y="3.5" width="6" height="11" rx="3"/><path d="M5.5 11a6.5 6.5 0 0 0 13 0M12 17.5V21"/>',
  "landmark": '<path d="M12 3l3 4v4l2 2v8H7v-8l2-2V7z"/><path d="M10 21v-4h4v4"/>',
  "eye": '<path d="M2.5 12S6 5.5 12 5.5 21.5 12 21.5 12 18 18.5 12 18.5 2.5 12 2.5 12z"/><circle cx="12" cy="12" r="3"/>',
  "lock": '<rect x="5" y="10.5" width="14" height="10" rx="2"/><path d="M8 10.5V7.5a4 4 0 0 1 8 0v3"/>',
  "settings": '<circle cx="12" cy="12" r="3"/><path d="M12 2.5v3M12 18.5v3M2.5 12h3M18.5 12h3M5.3 5.3l2.1 2.1M16.6 16.6l2.1 2.1M5.3 18.7l2.1-2.1M16.6 7.4l2.1-2.1"/>',
  "check": '<path d="M5 12.5l4.5 4.5L19 7.5"/>',
  "layers": '<path d="M12 3.5l9 5-9 5-9-5z"/><path d="M3 13l9 5 9-5"/>',
}

def ic(name, size=22, color="currentColor", sw=2.0, fill="none"):
    return (f'<svg width="{size}" height="{size}" viewBox="0 0 24 24" fill="{fill}" stroke="{color}" '
            f'stroke-width="{sw}" stroke-linecap="round" stroke-linejoin="round">{_P[name]}</svg>')

def nav_logo(size=22, color="#fff"):
    # The app's own mark: Material `navigation_rounded`-style filled arrow.
    return (f'<svg width="{size}" height="{size}" viewBox="0 0 24 24"><path d="M12 2.5l7.2 17.3c.3.8-.5 1.5-1.2 1.1L12 17.6l-6 3.3c-.7.4-1.5-.3-1.2-1.1z" '
            f'fill="{color}"/></svg>')

# --------------------------------------------------------------------------
# Phone frame
# --------------------------------------------------------------------------
def statusbar(dark_icons=False):
    c = "#111" if dark_icons else "#fff"
    sig = (f'<svg width="16" height="12" viewBox="0 0 16 12"><rect x="0" y="8" width="3" height="4" rx="1" fill="{c}"/>'
           f'<rect x="4.3" y="5.5" width="3" height="6.5" rx="1" fill="{c}"/><rect x="8.6" y="3" width="3" height="9" rx="1" fill="{c}"/>'
           f'<rect x="12.9" y="0" width="3" height="12" rx="1" fill="{c}" opacity=".45"/></svg>')
    wifi = (f'<svg width="16" height="12" viewBox="0 0 24 18"><path d="M12 17l3.2-4a5 5 0 0 0-6.4 0z" fill="{c}"/>'
            f'<path d="M3 6.5a14 14 0 0 1 18 0M6.2 10.4a9 9 0 0 1 11.6 0" stroke="{c}" stroke-width="2.4" fill="none" stroke-linecap="round"/></svg>')
    bat = (f'<svg width="25" height="12" viewBox="0 0 25 12"><rect x=".5" y=".5" width="21" height="11" rx="3" stroke="{c}" fill="none" opacity=".6"/>'
           f'<rect x="2.3" y="2.3" width="15" height="7.4" rx="1.6" fill="{c}"/><rect x="22.6" y="4" width="1.8" height="4" rx=".9" fill="{c}" opacity=".6"/></svg>')
    return (f'<div class="statusbar" style="color:{c}"><span>10:24</span>'
            f'<span class="si">{sig}{wifi}{bat}</span></div>')

def phone(inner, x, y, scale=1.0, dark_icons=False, extra=""):
    t = f"transform:scale({scale});transform-origin:top left;" if scale != 1 else ""
    return (f'<div class="phone" style="left:{x}px;top:{y}px;{t}{extra}"><div class="screen">{inner}'
            f'{statusbar(dark_icons)}<div class="punch"></div><div class="gesture"></div></div></div>')

def ptag(text, style, cls=""):
    return f'<div class="ptag {cls}" style="{style}">{text}</div>'

BADGE = {
  "impl": ("b-impl", "Implemented · Phase 1"),
  "m0":   ("b-m0",   "Implemented · Phase 2 M0"),
  "plan": ("b-plan", "Phase 2 planned"),
  "none": ("b-none", "Not built"),
}

def badge(kind, text=None):
    cls, default = BADGE[kind]
    return f'<span class="badge {cls}">{text or default}</span>'

def legend(x, y):
    return (f'<div class="legend" style="left:{x}px;top:{y}px">'
            f'{badge("impl")}{badge("m0")}{badge("plan", "Phase 2 planned · concept")}{badge("none", "Not built / future")}</div>')

def panel(x, y, w, eyebrow, title, sub, items):
    rows = "".join(
        f'<div class="item"><div>{badge(k, bt)}</div><div><div class="h">{h}</div><div class="d">{d}</div></div></div>'
        for (k, bt, h, d) in items)
    return (f'<div class="panel" style="left:{x}px;top:{y}px;width:{w}px">'
            f'<div class="eyebrow">{eyebrow}</div><div class="ptitle">{title}</div>'
            f'<div class="psub">{sub}</div><div class="items">{rows}</div></div>')

FOOTNOTE = ("Design concept rendered from HTML/SVG. Maps and camera views are drawn illustrations "
            "(the app uses the Google Maps SDK and the live device camera); places, distances and times are sample values. "
            "Dashed amber outlines mark planned elements that do not exist in the app yet.")

def page(body, w, h):
    return (f'<!doctype html><html><head><meta charset="utf-8"><style>{CSS}</style></head>'
            f'<body><div id="canvas" style="width:{w}px;height:{h}px">{body}<div class="grain"></div></div></body></html>')

# --------------------------------------------------------------------------
# Illustrative map (Mylapore, Chennai — stylized, not real tiles)
# Coordinates in a 390x844 space.
# --------------------------------------------------------------------------
ROUTE = [(120, 690), (120, 300), (232, 300), (232, 262)]
DEST = (232, 258)

def _pts(p):
    return " ".join(f"{x},{y}" for x, y in p)

def map_svg(route=None, old_route=None, dot=(120, 560), heading=0, dest=None,
            labels=True, dot_scale=1.0, vb="0 0 390 844", traveled=None):
    minor_h = [70, 150, 220, 380, 450, 535, 640, 720, 790]
    minor_v = [40, 190, 255]
    parts = ['<rect width="390" height="844" fill="#0F1624"/>']
    # blocks texture
    for i, y in enumerate(range(0, 844, 70)):
        for j, x in enumerate(range(0, 350, 65)):
            if (i + j) % 3 == 0:
                parts.append(f'<rect x="{x+6}" y="{y+6}" width="53" height="58" rx="5" fill="#131C2D"/>')
    parts.append('<rect x="30" y="700" width="62" height="70" rx="8" fill="#10281D"/>')   # park
    parts.append('<rect x="262" y="560" width="46" height="60" rx="8" fill="#10281D"/>')
    parts.append('<rect x="192" y="214" width="54" height="40" rx="6" fill="#0D2B42" stroke="#174361"/>')  # temple tank
    # sea
    parts.append('<path d="M350 0 C341 210 358 430 345 610 C338 720 352 800 347 844 L390 844 L390 0Z" fill="#0A2036"/>')
    parts.append('<path d="M350 0 C341 210 358 430 345 610 C338 720 352 800 347 844" stroke="#2A3448" stroke-width="5" fill="none"/>')
    for y in minor_h:
        parts.append(f'<line x1="0" y1="{y}" x2="346" y2="{y}" stroke="#1B2437" stroke-width="5"/>')
    for x in minor_v:
        parts.append(f'<line x1="{x}" y1="0" x2="{x}" y2="844" stroke="#1B2437" stroke-width="5"/>')
    mains = [("M120 0 V844", "R. K. Mutt Road", 'transform="translate(112 836) rotate(-90)"'),
             ("M0 300 H346", "Luz Church Road", 'x="24" y="292"'),
             ("M0 612 L346 478", "Kutchery Road", 'transform="translate(150 560) rotate(-21)"'),
             ("M318 0 V844", "Santhome High Rd", 'transform="translate(311 760) rotate(-90)"'),
             ("M0 118 H346", "Royapettah High Rd", 'x="140" y="110"')]
    for d, _, _ in mains:
        parts.append(f'<path d="{d}" stroke="#2A3651" stroke-width="13" fill="none"/>')
        parts.append(f'<path d="{d}" stroke="#34425F" stroke-width="2" fill="none" opacity=".6"/>')
    if labels:
        for _, name, pos in mains:
            parts.append(f'<text {pos} font-size="9" font-weight="600" letter-spacing=".6" fill="#6B7891">{name}</text>')
        parts.append('<text x="196" y="208" font-size="8.5" fill="#5D7DA0" font-weight="600">Temple Tank</text>')
        parts.append('<text x="196" y="410" font-size="11" fill="#55627A" font-weight="700" letter-spacing="2">MYLAPORE</text>')
        parts.append('<text transform="translate(372 420) rotate(90)" font-size="9" fill="#3E6386" letter-spacing="2" font-weight="600">BAY OF BENGAL</text>')
    if old_route:
        parts.append(f'<polyline points="{_pts(old_route)}" fill="none" stroke="#5A6680" stroke-width="5" stroke-dasharray="2 9" stroke-linecap="round" stroke-linejoin="round" opacity=".9"/>')
    if route:
        parts.append(f'<polyline points="{_pts(route)}" fill="none" stroke="#0B5FFF" stroke-opacity=".35" stroke-width="15" stroke-linecap="round" stroke-linejoin="round"/>')
        parts.append(f'<polyline points="{_pts(route)}" fill="none" stroke="#4C8BFF" stroke-width="7" stroke-linecap="round" stroke-linejoin="round"/>')
        parts.append(f'<polyline points="{_pts(route)}" fill="none" stroke="#B7CEFF" stroke-width="1.5" stroke-dasharray="1 14" stroke-linecap="round" stroke-linejoin="round"/>')
    if traveled:
        parts.append(f'<polyline points="{_pts(traveled)}" fill="none" stroke="#8090AD" stroke-width="7" stroke-linecap="round" stroke-linejoin="round" opacity=".6"/>')
    if dest:
        x, y = dest
        parts.append(f'<g transform="translate({x} {y})"><ellipse cx="0" cy="2" rx="7" ry="2.5" fill="#000" opacity=".4"/>'
                     f'<path d="M0 0 C-4 -9 -13 -14 -13 -24 a13 13 0 0 1 26 0 C13 -14 4 -9 0 0Z" fill="#FF4D5E" stroke="#fff" stroke-width="2"/>'
                     f'<circle cx="0" cy="-24" r="4.6" fill="#fff"/></g>')
    if dot:
        x, y = dot
        s = dot_scale
        parts.append(f'<g transform="translate({x} {y}) scale({s})">'
                     f'<circle r="30" fill="#3D7BFF" opacity=".14"/>'
                     f'<g transform="rotate({heading})"><path d="M0 0 L-17 -44 A47 47 0 0 1 17 -44Z" fill="url(#cone)"/></g>'
                     f'<circle r="10" fill="#fff"/><circle r="7" fill="#3D7BFF"/></g>')
    defs = ('<defs><linearGradient id="cone" x1="0" y1="1" x2="0" y2="0">'
            '<stop offset="0" stop-color="#3D7BFF" stop-opacity=".55"/><stop offset="1" stop-color="#3D7BFF" stop-opacity="0"/></linearGradient></defs>')
    return (f'<svg class="fill" viewBox="{vb}" preserveAspectRatio="xMidYMid slice" xmlns="http://www.w3.org/2000/svg">'
            f'{defs}{"".join(parts)}</svg>')

# --------------------------------------------------------------------------
# Illustrated camera view: dusk street in Mylapore with a temple gopuram
# and a bilingual road sign. Not a photograph.
# --------------------------------------------------------------------------
def street_svg(dim=0.0, sign=True):
    p = []
    p.append('''<defs>
<linearGradient id="sky" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#16233D"/><stop offset=".55" stop-color="#5B4C70"/><stop offset="1" stop-color="#EE9D66"/></linearGradient>
<linearGradient id="road" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#6A5F66"/><stop offset="1" stop-color="#2C2A31"/></linearGradient>
<linearGradient id="walkL" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#6E625E"/><stop offset="1" stop-color="#433C3D"/></linearGradient>
<linearGradient id="bldL" x1="0" y1="0" x2="1" y2="0"><stop offset="0" stop-color="#2B2533"/><stop offset="1" stop-color="#4A3F4E"/></linearGradient>
<linearGradient id="bldR" x1="1" y1="0" x2="0" y2="0"><stop offset="0" stop-color="#2E2836"/><stop offset="1" stop-color="#55485A"/></linearGradient>
<linearGradient id="gop" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#C98652"/><stop offset="1" stop-color="#8A5638"/></linearGradient>
<radialGradient id="glow" cx=".5" cy=".46" r=".7"><stop offset="0" stop-color="#FFC48A" stop-opacity=".35"/><stop offset="1" stop-color="#FFC48A" stop-opacity="0"/></radialGradient>
<radialGradient id="vig" cx=".5" cy=".5" r=".75"><stop offset=".55" stop-color="#000" stop-opacity="0"/><stop offset="1" stop-color="#000" stop-opacity=".55"/></radialGradient>
<filter id="haze"><feGaussianBlur stdDeviation=".6"/></filter>
</defs>''')
    p.append('<rect width="390" height="844" fill="url(#sky)"/>')
    p.append('<rect width="390" height="844" fill="url(#glow)"/>')
    # distant skyline
    sky = [(150, 330, 18, 50), (168, 342, 14, 38), (205, 336, 16, 44), (221, 346, 12, 34), (232, 352, 20, 28)]
    for x, y, w, h in sky:
        p.append(f'<rect x="{x}" y="{y}" width="{w}" height="{h}" fill="#3B3346" opacity=".85"/>')
    # gopuram (temple tower), slightly hazy
    tiers = [(108, 392, 66), (112, 368, 58), (116, 344, 50), (120, 320, 42), (124, 298, 34), (128, 278, 26), (132, 262, 18)]
    g = ['<g filter="url(#haze)" opacity=".92">']
    for x, y, w in tiers:
        g.append(f'<path d="M{x} {y+24} L{x+w} {y+24} L{x+w-4} {y} L{x+4} {y}Z" fill="url(#gop)" stroke="#6E4330" stroke-width=".6"/>')
        for k in range(3, w - 3, 7):
            g.append(f'<rect x="{x+k}" y="{y+8}" width="3" height="7" fill="#5A3626" opacity=".7"/>')
    g.append('<path d="M131 262 Q141 246 151 262Z" fill="#B87A4A"/>')
    for k in range(5):
        g.append(f'<rect x="{134+k*3}" y="238" width="1.6" height="12" rx=".8" fill="#E6B66B"/>')
    g.append('</g>')
    p.extend(g)
    # buildings
    p.append('<path d="M0 70 L170 360 L170 392 L0 690Z" fill="url(#bldL)"/>')
    p.append('<path d="M390 120 L222 362 L222 392 L390 650Z" fill="url(#bldR)"/>')
    for r in range(9):
        for c in range(5):
            t0 = c / 5.0
            x = 6 + t0 * 150
            ytop = 90 + t0 * 270 + r * (52 - t0 * 46)
            hh = 22 - t0 * 18
            lit = (r * 7 + c * 3) % 5 in (0, 2)
            col = "#FFD08A" if lit else "#2A2430"
            if ytop < 680 - t0 * 300:
                p.append(f'<rect x="{x:.1f}" y="{ytop:.1f}" width="{14 - t0*10:.1f}" height="{hh:.1f}" fill="{col}" opacity="{0.9 if lit else 0.8}"/>')
    for r in range(8):
        for c in range(4):
            t0 = c / 4.0
            x = 384 - t0 * 150 - (12 - t0 * 9)
            ytop = 140 + t0 * 225 + r * (54 - t0 * 46)
            lit = (r * 5 + c * 2) % 4 == 1
            col = "#FFC97A" if lit else "#2C2633"
            if ytop < 640 - t0 * 260:
                p.append(f'<rect x="{x:.1f}" y="{ytop:.1f}" width="{12 - t0*9:.1f}" height="{20 - t0*16:.1f}" fill="{col}"/>')
    # shop awning glow (left)
    p.append('<path d="M0 560 L80 450 L80 470 L0 600Z" fill="#E8A44A" opacity=".55"/>')
    # sidewalks + road
    p.append('<path d="M0 844 L44 844 L176 386 L168 386 L0 610Z" fill="url(#walkL)"/>')
    p.append('<path d="M390 844 L346 844 L214 386 L222 386 L390 600Z" fill="url(#walkL)"/>')
    p.append('<path d="M44 844 L346 844 L214 386 L176 386Z" fill="url(#road)"/>')
    p.append('<path d="M44 844 L176 386" stroke="#C9C2B8" stroke-width="2" opacity=".55"/>')
    p.append('<path d="M346 844 L214 386" stroke="#C9C2B8" stroke-width="2" opacity=".55"/>')
    # centre dashes in perspective
    for i in range(9):
        t1 = i / 9.0
        t2 = (i + 0.45) / 9.0
        y1 = 844 - t1 ** 0.7 * 458
        y2 = 844 - t2 ** 0.7 * 458
        w1 = 7 * (1 - t1) + 0.8
        w2 = 7 * (1 - t2) + 0.8
        p.append(f'<path d="M{195-w1/2:.1f} {y1:.1f} L{195+w1/2:.1f} {y1:.1f} L{195+w2/2:.1f} {y2:.1f} L{195-w2/2:.1f} {y2:.1f}Z" fill="#F4EBD8" opacity=".75"/>')
    # trees left
    for cx, cy, r in [(48, 520, 34), (78, 492, 26), (24, 556, 28), (118, 430, 15), (132, 414, 11)]:
        p.append(f'<circle cx="{cx}" cy="{cy}" r="{r}" fill="#1F3329"/>')
    p.append('<rect x="50" y="540" width="5" height="70" fill="#2A221F"/>')
    # street light
    p.append('<path d="M286 640 L286 420 Q286 404 270 404 L254 404" stroke="#3A3A42" stroke-width="4" fill="none"/>')
    p.append('<ellipse cx="252" cy="407" rx="9" ry="3.5" fill="#FFE2A8"/>')
    p.append('<ellipse cx="252" cy="420" rx="40" ry="24" fill="#FFD49A" opacity=".12"/>')
    # vehicles
    # auto-rickshaw (mid distance, left lane)
    p.append('<g transform="translate(150 470)"><path d="M2 30 L4 8 Q6 0 18 0 L34 0 Q44 0 44 10 L44 30Z" fill="#1E1E1E"/>'
             '<path d="M4 9 Q6 1 18 1 L34 1 Q43 1 43 10 L43 12 L4 12Z" fill="#F2C230"/>'
             '<rect x="6" y="14" width="36" height="14" rx="2" fill="#2F7A46"/><rect x="11" y="16" width="10" height="7" fill="#9FD3F0" opacity=".7"/>'
             '<rect x="26" y="16" width="10" height="7" fill="#9FD3F0" opacity=".7"/><circle cx="9" cy="31" r="4" fill="#111"/><circle cx="38" cy="31" r="4" fill="#111"/>'
             '<rect x="19" y="24" width="10" height="3" fill="#FFE38A"/></g>')
    # motorcycle with rider (further, right lane)
    p.append('<g transform="translate(208 432)"><circle cx="4" cy="20" r="3.2" fill="#111"/><circle cx="16" cy="20" r="3.2" fill="#111"/>'
             '<path d="M3 17 L17 17 L14 12 L6 12Z" fill="#9B2C2C"/><rect x="7" y="2" width="6" height="11" rx="2.5" fill="#E0E3EA"/>'
             '<circle cx="10" cy="1" r="3" fill="#2B2B2B"/><rect x="8.5" y="18" width="3" height="2" fill="#FF5A5A"/></g>')
    # car (near, right lane)
    p.append('<g transform="translate(232 600)"><rect x="0" y="22" width="92" height="40" rx="10" fill="#C9CED8"/>'
             '<path d="M12 24 L22 2 L70 2 L82 24Z" fill="#AEB5C2"/><path d="M20 22 L27 7 L66 7 L74 22Z" fill="#33414F"/>'
             '<rect x="6" y="38" width="16" height="8" rx="3" fill="#FFE7B0"/><rect x="70" y="38" width="16" height="8" rx="3" fill="#FFE7B0"/>'
             '<rect x="32" y="44" width="28" height="8" rx="2" fill="#EAEDF2"/><rect x="2" y="58" width="16" height="12" rx="3" fill="#15161A"/>'
             '<rect x="74" y="58" width="16" height="12" rx="3" fill="#15161A"/></g>')
    # pedestrian (left sidewalk)
    p.append('<g transform="translate(66 600)"><circle cx="9" cy="5" r="5" fill="#3A2A22"/><path d="M3 12 Q9 8 15 12 L16 38 L2 38Z" fill="#B23A48"/>'
             '<rect x="3" y="38" width="5" height="22" fill="#2D2F3A"/><rect x="10" y="38" width="5" height="22" fill="#2D2F3A"/></g>')
    if sign:
        # bilingual Chennai-style road sign
        p.append('<rect x="318" y="470" width="4" height="200" fill="#4A4F5A"/>')
        p.append('<g transform="translate(250 432)"><rect width="122" height="62" rx="5" fill="#1747A6" stroke="#fff" stroke-width="2"/>'
                 '<text x="61" y="21" text-anchor="middle" font-size="12.5" fill="#fff" class="tamil" font-family="FreeSans">மயிலாப்பூர்</text>'
                 '<text x="61" y="40" text-anchor="middle" font-size="12" font-weight="700" fill="#fff" font-family="Inter" letter-spacing=".5">R.K. MUTT ROAD</text>'
                 '<text x="61" y="54" text-anchor="middle" font-size="8.5" fill="#DCE6FF" font-family="Inter" letter-spacing="1">CHENNAI · 600004</text></g>')
    p.append('<rect width="390" height="844" fill="url(#vig)"/>')
    if dim:
        p.append(f'<rect width="390" height="844" fill="#000" opacity="{dim}"/>')
    return ('<svg class="fill" viewBox="0 0 390 844" preserveAspectRatio="xMidYMid slice" xmlns="http://www.w3.org/2000/svg">'
            + "".join(p) + '</svg>')
