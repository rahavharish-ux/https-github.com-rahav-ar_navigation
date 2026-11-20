"""Screen mockups for the TN AR NAV final-project visualization.

Each *_inner() returns the HTML inside one phone screen (390x844). The
page builders at the bottom pair phones with an annotation panel that tags
every visible element as implemented / planned / not built.
"""
from kit import (ic, nav_logo, phone, ptag, panel, legend, page, badge,
                 map_svg, street_svg, ROUTE, DEST, FOOTNOTE)

W1, H1 = 1600, 1000      # single-phone canvas
W3, H3 = 1960, 1060      # multi-phone canvas

def topfade(h=210, a=.92):
    return (f'<div style="position:absolute;left:0;right:0;top:0;height:{h}px;z-index:5;'
            f'background:linear-gradient(180deg,rgba(11,14,20,{a}) 0%,rgba(11,14,20,{a*.6}) 45%,rgba(11,14,20,0) 100%)"></div>')

def botfade(h=320, a=.9):
    return (f'<div style="position:absolute;left:0;right:0;bottom:0;height:{h}px;z-index:5;'
            f'background:linear-gradient(0deg,rgba(11,14,20,{a}) 0%,rgba(11,14,20,0) 100%)"></div>')

def fab(icon, top, right=16, size=48, color="#E8ECF5"):
    return (f'<div class="iconbtn glass" style="position:absolute;top:{top}px;right:{right}px;width:{size}px;height:{size}px;'
            f'border-radius:{size//2}px;z-index:10;box-shadow:0 8px 20px rgba(0,0,0,.45)">{ic(icon,22,color)}</div>')

def instruction_card(top, dist, text, icon="turnright", sub=None):
    s = f'<div class="small" style="opacity:.8;margin-top:2px">{sub}</div>' if sub else ""
    return (f'<div style="position:absolute;left:12px;right:12px;top:{top}px;z-index:12;border-radius:22px;padding:16px 18px;'
            f'display:flex;gap:16px;align-items:center;background:linear-gradient(135deg,#2C72FF,#0B5FFF 70%);'
            f'box-shadow:0 14px 34px rgba(11,95,255,.45)">'
            f'<div style="width:56px;height:56px;border-radius:16px;background:rgba(255,255,255,.16);display:flex;align-items:center;justify-content:center">{ic(icon,34,"#fff",2.4)}</div>'
            f'<div style="flex:1;color:#fff"><div style="font-size:30px;font-weight:700;letter-spacing:-.01em;line-height:1">{dist}</div>'
            f'<div style="font-size:15.5px;font-weight:500;margin-top:6px;line-height:1.3">{text}</div>{s}</div></div>')

def nav_bottom(top, left_text, buttons_html, extra=""):
    return (f'<div class="sheet" style="top:{top}px;bottom:24px;z-index:12">'
            f'<div style="display:flex;align-items:center;justify-content:center;gap:10px;font-size:17px;font-weight:600">'
            f'{ic("route",20,"#8FB0FF")}{left_text}</div>{extra}'
            f'<div style="display:flex;gap:10px;margin-top:14px">{buttons_html}</div></div>')

# ==========================================================================
# 1. Home dashboard
# ==========================================================================
def home_inner(show_tags=True, snack=None):
    t = show_tags
    qa = []
    for icon, label, real in [("home", "Home", False), ("work", "Work", False), ("history", "Recent", False), ("bookmark", "Saved", True)]:
        op = "1" if real else ".55"
        qa.append(f'<div style="display:flex;flex-direction:column;align-items:center;gap:6px;width:68px;opacity:{op}">'
                  f'<div style="width:46px;height:46px;border-radius:23px;background:rgba(61,123,255,.16);display:flex;align-items:center;justify-content:center;'
                  f'box-shadow:inset 0 0 0 1px rgba(143,176,255,.25)">{ic(icon,21,"#A9C2FF")}</div>'
                  f'<div style="font-size:12px;font-weight:600;color:#C9D3E6">{label}</div></div>')
    sheet = (
        '<div class="sheet" style="top:470px;bottom:22px;z-index:12;padding:18px 16px">'
        '<div style="font-size:19px;font-weight:700;letter-spacing:-.01em">Where to, today?</div>'
        '<div style="margin-top:12px;height:54px;border-radius:16px;background:var(--surface2);display:flex;align-items:center;gap:12px;padding:0 16px;'
        'box-shadow:inset 0 0 0 1px rgba(255,255,255,.06)">' + ic("search", 21, "#8FB0FF") +
        '<span style="color:#8D99B2;font-size:15px">Where do you want to go?</span></div>'
        '<div style="position:relative;display:flex;justify-content:space-between;margin-top:16px;padding:0 4px">' + "".join(qa) +
        (ptag("NOT BUILT", "left:2px;top:-10px", "ntag") if t else "") + '</div>'
        '<div style="position:relative;margin-top:16px" class="seg">'
        f'<div class="on">{ic("car",17,"#CFE0FF")}Driving</div>'
        f'<div style="position:relative">{ic("walk",17,"#9AA6BF")}Walking</div>'
        f'<div style="opacity:.45">{ic("bike",17,"#9AA6BF")}Cycling</div>'
        + (ptag("M3", "left:150px;top:-9px") if t else "") + '</div>'
        '<div style="position:relative;margin-top:16px">'
        f'<div class="btn btn-primary {"planned" if t else ""}">{ic("ar",20,"#fff")}AR Navigation</div>'
        + (ptag("PLANNED · M5", "right:8px;top:-10px") if t else "") + '</div>'
        '</div>')
    header = (
        '<div style="position:absolute;top:46px;left:18px;right:12px;display:flex;align-items:center;z-index:12">'
        f'<div class="brandmark"><div class="logo">{nav_logo(20)}</div>'
        '<div><div style="font-size:18px;font-weight:800;letter-spacing:.04em">TN AR NAV</div>'
        '<div style="font-size:11px;color:#9AA6BF;margin-top:1px">AR Navigation for Tamil Nadu</div></div></div>'
        '<div style="flex:1"></div>'
        f'<div class="iconbtn glass" style="margin-right:8px">{ic("account",22,"#E8ECF5")}</div>'
        f'<div class="iconbtn glass">{ic("bug",21,"#E8ECF5")}</div></div>'
        '<div style="position:absolute;top:106px;left:0;right:0;display:flex;justify-content:center;z-index:12">'
        f'<div class="pill glass" style="color:#DCE4F5">{ic("gps",15,"#8FB0FF",2.2)}'
        '<span style="font-variant-numeric:tabular-nums">13.03384, 80.26904 (±6m)</span></div></div>')
    snack_html = ""
    if snack:
        snack_html = snack
    return (map_svg(dot=(120, 360), heading=18, labels=True) + topfade(190) +
            header + fab("recenter", 400, 76) + fab("gps", 400, 16) + sheet + snack_html)

def page_home():
    items = [
        ("impl", None, "Brand header, account and diagnostics", "TN AR NAV mark (navigation arrow on brand blue #0B5FFF), Supabase account entry and the developer diagnostics screen."),
        ("impl", None, "Live GPS position and accuracy", "geolocator stream, filtered (≤50 m accuracy) and smoothed; the badge shows raw coordinates and reported accuracy."),
        ("impl", None, "Google map, follow mode, re-center, locate me", "google_maps_flutter behind AppMapController; panning drops follow mode, the buttons restore it."),
        ("impl", None, "Destination search card and Saved shortcut", "Opens Places API (New) search; Saved opens the Supabase saved-places list (sign-in required)."),
        ("plan", "Planned · M3", "Walking routes", "OpenRouteService foot-walking behind a replaceable RoutingProvider. Today Walking/Cycling show an honest \"not available\" state."),
        ("plan", "Planned · M5", "AR Navigation entry", "Enabled only when ARCore is supported and a route exists. Today the button is disabled; only the ARCore capability check exists."),
        ("none", None, "Home / Work / Recent shortcuts, voice entry", "Placeholders that show \"coming soon\" today and are not on the Phase 2 roadmap. No voice button: voice guidance (M2) and the assistant (M9) are not built."),
    ]
    body = (phone(home_inner(), 90, 66) +
            panel(600, 64, 920, "Screen 01 · Home dashboard", "Home Dashboard",
                  "The map-first start screen. Everything except the shortcuts, walking mode and the AR button works in the app today.", items) +
            legend(600, 912) + f'<div class="foot" style="left:600px;top:950px;width:920px">{FOOTNOTE}</div>')
    return page(body, W1, H1)

# ==========================================================================
# 2. Destination search
# ==========================================================================
def search_inner():
    def row(icon, name, addr, dist, accent="#A9C2FF"):
        return (f'<div class="listrow"><div class="ic">{ic(icon,20,accent)}</div><div class="tx">'
                f'<div class="t1">{name}</div><div class="t2">{addr}</div></div>'
                f'<div style="font-size:13px;font-weight:600;color:#C9D3E6;font-variant-numeric:tabular-nums">{dist}</div></div>')
    results = (row("pin", "Arulmigu Kapaleeshwarar Temple", "Mylapore, Chennai, Tamil Nadu 600004", "1.1 km") +
               row("pin", "Kapaleeshwarar Temple Tank", "Mylapore, Chennai, Tamil Nadu", "1.0 km") +
               row("pin", "Kapaleeswarar Koil Street", "Mylapore, Chennai, Tamil Nadu", "1.2 km"))
    recents = (row("history", "Marina Beach", "Kamarajar Salai, Chennai", "2.9 km", "#9AA6BF") +
               row("history", "San Thome Cathedral Basilica", "Santhome High Rd, Chennai", "1.7 km", "#9AA6BF") +
               row("history", "Chennai Central Railway Station", "Park Town, Chennai", "8.6 km", "#9AA6BF"))
    return (
        '<div style="position:absolute;inset:0;background:var(--bg)"></div>'
        '<div style="position:absolute;top:44px;left:12px;right:12px;height:56px;border-radius:18px;background:var(--surface2);'
        'display:flex;align-items:center;gap:10px;padding:0 6px 0 4px;z-index:10;box-shadow:inset 0 0 0 1.5px rgba(61,123,255,.55)">'
        f'<div class="iconbtn">{ic("back",22,"#E8ECF5")}</div>'
        '<div style="flex:1;font-size:16px">Kapalee<span style="display:inline-block;width:2px;height:19px;background:#3D7BFF;vertical-align:-4px;margin-left:1px"></span></div>'
        f'<div class="iconbtn">{ic("close",20,"#9AA6BF")}</div></div>'
        '<div style="position:absolute;top:112px;left:0;right:0">'
        '<div class="secthead"><span>Results</span><span style="letter-spacing:0;text-transform:none;font-weight:600">Google Places</span></div>'
        + results +
        '<div style="height:1px;background:rgba(255,255,255,.06);margin:10px 18px"></div>'
        '<div class="secthead"><span>Recent</span><span style="color:#8FB0FF;letter-spacing:0;text-transform:none;font-weight:600">Clear all</span></div>'
        + recents +
        '<div style="margin:18px 18px 0;padding:14px 16px;border-radius:16px;background:rgba(255,255,255,.03);border:1px dashed rgba(168,179,199,.35);'
        'font-size:12.5px;color:#8D99B2;line-height:1.45">Tip: results are biased to Tamil Nadu. Distance is measured from your current GPS fix.</div>'
        '</div>')

def page_search():
    items = [
        ("impl", None, "Live destination search", "Places API (New) Text Search with a Tamil Nadu location bias; a 400 ms debounce avoids a request per keystroke."),
        ("m0", None, "No stale results", "Each query carries a generation number, so a slow, older response can never replace newer results or reappear after the field is cleared."),
        ("impl", None, "Distance from you", "Each result shows the straight-line distance from the current GPS fix."),
        ("impl", None, "Recent searches with Clear all", "Kept for the current session only; lost when the app restarts."),
        ("impl", None, "Select a destination", "Tapping a result selects it, fits it on the map and opens the route preview."),
        ("none", None, "Nearby-places browsing", "Not built and not on the roadmap. Landmark candidates from Places Nearby are planned only as input to landmark recognition (M8)."),
    ]
    body = (phone(search_inner(), 90, 66) +
            panel(600, 64, 920, "Screen 02 · Destination search", "Destination Search",
                  "Type a place, landmark or address. Results come from Google Places and are ranked by Google's relevance, with your distance to each.", items) +
            legend(600, 912) + f'<div class="foot" style="left:600px;top:950px;width:920px">{FOOTNOTE}</div>')
    return page(body, W1, H1)

# ==========================================================================
# 3. Route preview
# ==========================================================================
def route_inner(show_tags=True):
    t = show_tags
    return (
        '<div style="position:absolute;left:0;right:0;top:0;height:520px">' + map_svg(route=ROUTE, dot=(120, 690), heading=0, dest=DEST, vb="0 150 390 600") + '</div>'
        + topfade(130, .95) +
        '<div style="position:absolute;top:42px;left:8px;right:12px;display:flex;align-items:center;gap:6px;z-index:12">'
        f'<div class="iconbtn glass">{ic("back",22,"#E8ECF5")}</div>'
        '<div style="font-size:17px;font-weight:700;margin-left:6px">Arulmigu Kapaleeshwarar Temple</div></div>'
        '<div class="sheet" style="top:470px;bottom:22px;left:0;right:0;border-radius:30px 30px 0 0;z-index:12;padding:20px 18px">'
        '<div style="width:40px;height:4px;border-radius:2px;background:#3A4458;margin:-8px auto 12px"></div>'
        '<div style="display:flex;align-items:baseline;gap:10px">'
        '<div style="font-size:30px;font-weight:800;letter-spacing:-.02em">6 min</div>'
        '<div style="font-size:17px;color:#C9D3E6;font-weight:600">· 1.6 km</div>'
        '<div style="flex:1"></div><span class="pill" style="background:rgba(52,196,106,.12);color:#6BE39A;height:26px">Fastest</span></div>'
        '<div class="small muted" style="margin-top:4px">Mylapore, Chennai, Tamil Nadu 600004</div>'
        '<div style="position:relative;margin-top:14px" class="seg">'
        f'<div class="on">{ic("car",17,"#CFE0FF")}Driving</div>'
        f'<div>{ic("walk",17,"#9AA6BF")}Walking</div>'
        f'<div style="opacity:.45">{ic("bike",17,"#9AA6BF")}Cycling</div>'
        + (ptag("M3", "left:150px;top:-9px") if t else "") + '</div>'
        '<div style="display:flex;gap:10px;margin-top:14px">'
        f'<div class="btn btn-outline" style="flex:1">{ic("bookmark",19,"#8FB0FF")}Save this place</div></div>'
        f'<div class="btn btn-primary" style="margin-top:12px">{ic("recenter",19,"#fff")}Start Navigation</div>'
        '</div>')

def page_route():
    items = [
        ("impl", None, "Route on the map", "OSRM route geometry drawn as a polyline from your live GPS fix to the destination pin, framed to fit both."),
        ("impl", None, "Distance and travel time", "From the OSRM response (e.g. 6 min · 1.6 km). The app shows trip duration; a clock-time arrival is not built."),
        ("impl", None, "Driving mode", "Real road routing via OSRM's public demo server, driving only. A production backend is still needed before release."),
        ("plan", "Planned · M3", "Walking mode", "OpenRouteService foot-walking routes with pedestrian thresholds. Cycling stays unavailable unless the backend supports it."),
        ("impl", None, "Save this place", "Writes to the Supabase saved_places table; Row Level Security limits every row to its owner."),
        ("impl", None, "Start Navigation", "Enabled only once a real route exists; starts the turn-by-turn session (screens 05 and 07)."),
        ("none", "Design concept", "\"Fastest\" label and sheet styling", "Visual polish in this concept. The app shows a single route; alternative routes are not built."),
    ]
    body = (phone(route_inner(), 90, 66) +
            panel(600, 64, 920, "Screen 03 · Route preview", "Route Preview",
                  "Check the route, distance and time before you go. Driving works today; walking arrives with milestone M3.", items) +
            legend(600, 912) + f'<div class="foot" style="left:600px;top:950px;width:920px">{FOOTNOTE}</div>')
    return page(body, W1, H1)

# ==========================================================================
# 4. Live AR navigation (Phase 2 M5 concept)
# ==========================================================================
AR_ARROW = '''<svg width="230" height="230" viewBox="0 0 230 230" style="position:absolute;left:70px;top:246px;z-index:8;filter:drop-shadow(0 18px 24px rgba(0,0,0,.55)) drop-shadow(0 0 22px rgba(61,123,255,.55))">
<defs><linearGradient id="arw" x1="0" y1="1" x2="1" y2="0"><stop offset="0" stop-color="#7FB0FF"/><stop offset=".5" stop-color="#3D7BFF"/><stop offset="1" stop-color="#0B5FFF"/></linearGradient>
<linearGradient id="arw2" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#fff" stop-opacity=".55"/><stop offset="1" stop-color="#fff" stop-opacity="0"/></linearGradient></defs>
<path d="M70 210 L70 120 Q70 76 114 76 L150 76 L150 40 L214 100 L150 160 L150 124 L118 124 Q114 124 114 128 L114 210 Z" fill="url(#arw)" stroke="#CFE0FF" stroke-width="2.5" stroke-linejoin="round"/>
<path d="M78 200 L78 122 Q78 84 114 84 L152 84 L152 58" fill="none" stroke="url(#arw2)" stroke-width="5" stroke-linecap="round"/></svg>'''

def ar_inner(show_tags=True):
    t = show_tags
    hud_top = (
        '<div style="position:absolute;top:150px;left:12px;right:12px;display:flex;justify-content:space-between;z-index:12">'
        f'<div class="pill glass" style="color:#FCD34D">{ic("compass",15,"#FCD34D")}Approximate · GPS + compass</div>'
        f'<div class="pill glass" style="color:#E8ECF5;font-variant-numeric:tabular-nums">{ic("compass",15,"#8FB0FF")}NE 34°</div></div>')
    edge = ('<div style="position:absolute;right:0;top:520px;z-index:12;display:flex;align-items:center;gap:8px;padding:9px 12px 9px 14px;'
            'border-radius:16px 0 0 16px;background:rgba(255,77,94,.92);color:#fff;font-size:12.5px;font-weight:700;box-shadow:0 8px 22px rgba(0,0,0,.45)">'
            + ic("pin", 16, "#fff") + 'Temple · 650 m' + ic("chev", 14, "#fff", 2.6) + '</div>')
    label = ('<div style="position:absolute;left:62px;top:476px;z-index:9">'
             '<span class="pill glass" style="font-size:13px;color:#fff">Turn right in 120 m</span></div>')
    bottom = nav_bottom(684, '6 min · 650 m remaining',
                        f'<div class="btn btn-tonal" style="flex:1">{ic("map",19,"#E8ECF5")}Map</div>'
                        f'<div class="btn btn-tonal" style="flex:1">{ic("pause",19,"#E8ECF5")}Pause</div>'
                        f'<div class="btn btn-danger" style="flex:1">{ic("stop",17,"#FF8A8A")}Stop</div>')
    tag = ptag("PHASE 2 CONCEPT · M5 — NOT IMPLEMENTED", "left:50%;transform:translateX(-50%);top:214px") if t else ""
    return (street_svg() + instruction_card(46, "120 m", "Turn right onto Luz Church Road") + hud_top + AR_ARROW +
            label + edge + bottom + tag)

def page_ar():
    items = [
        ("plan", "Concept · M5", "Camera view with guidance overlay", "A native ARCore view embedded in Flutter shows the camera, with turn guidance drawn on top. Today the app has only a plain camera preview in Diagnostics."),
        ("plan", "Concept · M5", "Direction arrow — approximate", "Placed from GPS position plus compass heading, so it points the right way but is not locked to the street. Labelled \"Approximate\", as the roadmap requires."),
        ("impl", None, "Next-turn instruction and remaining distance/time", "Already computed by the navigation engine (screen 05); M0 corrected remaining distance and ETA."),
        ("impl", "Exists in Diagnostics", "Compass heading", "flutter_compass heading exists but is shown only on the Diagnostics screen; using it for guidance is part of M4/M5."),
        ("plan", "Concept · M5", "Destination edge marker and Map fallback", "Points toward the destination off-screen; Map switches to 2D navigation, which also takes over automatically if tracking is lost."),
        ("plan", "Later · M6", "Street-locked (geo-anchored) arrows", "Only with ARCore Geospatial (VPS) at locations where it is measured to work. Not shown here, and not claimed."),
    ]
    sub = ("The most important Phase 2 screen and the furthest from today's code: it does not exist yet. "
           "What is drawn is the M5 plan — guidance over the camera feed, honestly marked as approximate, with no world-anchored tracking.")
    body = (phone(ar_inner(), 90, 66) +
            panel(600, 64, 920, "Screen 04 · Live AR navigation — Phase 2 concept", "Live AR Navigation", sub, items) +
            legend(600, 912) + f'<div class="foot" style="left:600px;top:950px;width:920px">{FOOTNOTE}</div>')
    return page(body, W1, H1)

# ==========================================================================
# 5. 2D map navigation
# ==========================================================================
def nav2d_inner(show_tags=True):
    t = show_tags
    btns = (f'<div class="btn btn-tonal" style="flex:1">{ic("pause",19,"#E8ECF5")}Pause</div>'
            f'<div class="btn btn-danger" style="flex:1">{ic("stop",17,"#FF8A8A")}Stop</div>')
    ar_btn = ('<div style="position:absolute;right:16px;top:560px;z-index:12">'
              f'<div class="pill glass {"planned" if t else ""}" style="height:44px;padding:0 16px;font-size:13.5px;color:#E8ECF5">{ic("ar",18,"#8FB0FF")}AR view</div>'
              + (ptag("M5", "right:-6px;top:-12px") if t else "") + '</div>')
    return (map_svg(route=[(120, 520), (120, 300), (232, 300), (232, 262)], traveled=[(120, 690), (120, 520)],
                    dot=(120, 520), heading=0, dest=DEST, dot_scale=1.15) +
            instruction_card(46, "120 m", "Turn right onto Luz Church Road") +
            fab("recenter", 560, 326) + ar_btn +
            nav_bottom(684, '6 min · 650 m remaining', btns))

def page_nav2d():
    items = [
        ("impl", None, "Turn-by-turn on the map", "Driven by the same filtered, smoothed GPS stream as the home map; the instruction advances as you pass each maneuver."),
        ("impl", None, "Next instruction, distance, remaining time", "Instruction text is built from OSRM maneuvers (e.g. \"Turn right onto Luz Church Road\")."),
        ("m0", None, "Correct remaining distance and ETA", "Now includes the stretch still to travel to the next turn — before M0 the whole final leg showed 0 m."),
        ("impl", None, "Pause / Resume / Stop and arrival", "Arrival is detected within 25 m of the destination; Stop ends the session cleanly."),
        ("m0", None, "Pause and resume use the latest position", "Resume recomputes from the newest GPS fix, so the display is never stuck on the pre-pause position."),
        ("plan", "Planned · M5", "Return to AR view", "Switch back to the camera-based view when AR is available."),
    ]
    body = (phone(nav2d_inner(), 90, 66) +
            panel(600, 64, 920, "Screen 05 · 2D map navigation", "2D Map Navigation",
                  "Turn-by-turn on the map. This is the navigation that works today, and the fallback whenever AR is unavailable.", items) +
            legend(600, 912) + f'<div class="foot" style="left:600px;top:950px;width:920px">{FOOTNOTE}</div>')
    return page(body, W1, H1)

# ==========================================================================
# 6. Scene understanding — implemented (left) vs concept (right)
# ==========================================================================
def vision_impl_inner():
    res = "".join(f'<div style="display:flex;align-items:center;gap:10px;padding:7px 0;font-size:14.5px">{ic(i,17,"#8FB0FF")}<span>{tx}</span></div>'
                  for i, tx in [("text", "R.K. MUTT ROAD"), ("text", "CHENNAI · 600004")])
    return (
        '<div style="position:absolute;inset:0;background:var(--bg)"></div>'
        '<div class="appbar" style="justify-content:center">'
        f'<div class="iconbtn" style="position:absolute;left:8px">{ic("back",22,"#E8ECF5")}</div><div style="font-size:18px;font-weight:600">Computer Vision</div></div>'
        '<div style="position:absolute;top:96px;left:12px;right:12px;height:430px;border-radius:22px;overflow:hidden">'
        '<div style="position:absolute;inset:0;transform:scale(1.6);transform-origin:92% 59%">' + street_svg() + '</div>'
        '<div style="position:absolute;inset:0;box-shadow:inset 0 0 0 1px rgba(255,255,255,.08);border-radius:22px"></div>'
        f'<div class="pill glass" style="position:absolute;left:12px;top:12px;color:#fff">{ic("camera",15,"#fff")}Single frame captured</div></div>'
        '<div style="position:absolute;top:540px;left:12px;right:12px;display:flex;gap:10px">'
        f'<div class="btn btn-primary" style="flex:1">{ic("text",19,"#fff")}Scan text</div>'
        f'<div class="btn btn-tonal" style="flex:1">{ic("tag",19,"#E8ECF5")}Label scene</div></div>'
        '<div class="card" style="position:absolute;top:608px;left:12px;right:12px;bottom:26px;padding:14px 16px">'
        '<div class="small" style="font-weight:700;letter-spacing:.08em;color:#6B7891;text-transform:uppercase">Recognized text · on-device</div>'
        + res +
        '<div style="margin-top:8px;font-size:12px;color:#8D99B2;line-height:1.4">The Tamil line on the sign is not read — on-device ML Kit OCR covers Latin script only.</div>'
        '</div>')

def vision_concept_inner():
    def box(x, y, w, h, label, col="#22D3EE"):
        return (f'<div style="position:absolute;left:{x}px;top:{y}px;width:{w}px;height:{h}px;border:2px solid {col};border-radius:6px;z-index:9;'
                f'box-shadow:0 0 12px {col}66"><div style="position:absolute;left:-2px;top:-21px;background:{col};color:#04121A;font-size:10.5px;font-weight:800;'
                f'padding:3px 6px;border-radius:5px 5px 5px 0;white-space:nowrap">{label}</div></div>')
    return (
        street_svg() +
        box(60, 594, 34, 70, "person 0.92") + box(228, 596, 100, 84, "car 0.88") + box(204, 428, 26, 30, "motorcycle 0.81") +
        '<div style="position:absolute;left:246px;top:428px;width:130px;height:70px;border:2px solid #A78BFA;border-radius:8px;z-index:9;box-shadow:0 0 12px #A78BFA66"></div>'
        '<div class="glass" style="position:absolute;top:50px;left:12px;right:12px;border-radius:20px;padding:12px 14px;z-index:12;display:flex;gap:12px;align-items:center">'
        f'<div style="width:42px;height:42px;border-radius:12px;background:rgba(201,134,82,.22);display:flex;align-items:center;justify-content:center">{ic("landmark",22,"#F2B37A")}</div>'
        '<div style="flex:1"><div style="font-size:15px;font-weight:700">Kapaleeshwarar Temple</div>'
        '<div class="small muted">Landmark ahead · ~350 m · confidence: medium</div></div></div>'
        '<div class="glass" style="position:absolute;top:122px;left:12px;right:12px;border-radius:20px;padding:12px 14px;z-index:12">'
        f'<div style="display:flex;align-items:center;gap:8px;font-size:12px;font-weight:700;color:#C4B5FD;letter-spacing:.06em;text-transform:uppercase">{ic("text",15,"#C4B5FD")}Sign read · Tamil + English</div>'
        '<div style="margin-top:6px;font-size:16px"><span class="tamil">மயிலாப்பூர்</span> · R.K. Mutt Road</div></div>'
        '<div style="position:absolute;left:12px;right:12px;bottom:28px;border-radius:18px;padding:14px 16px;z-index:12;display:flex;gap:12px;align-items:center;'
        'background:rgba(249,168,37,.94);color:#1A1300;box-shadow:0 10px 26px rgba(0,0,0,.45)">'
        f'{ic("warning",24,"#1A1300",2.2)}<div><div style="font-size:15px;font-weight:800">Vehicle approaching on your right</div>'
        '<div style="font-size:12px;font-weight:600;opacity:.8">Advisory only — always check traffic yourself</div></div></div>'
        + ptag("PHASE 2 CONCEPT · M7 + M8", "left:50%;transform:translateX(-50%);top:206px"))

def page_vision():
    items = [
        ("impl", "Implemented · Diagnostics", "Scan text (OCR)", "Google ML Kit text recognition on one captured photo, fully on-device. Latin script only — Tamil is not supported by ML Kit's on-device models."),
        ("impl", "Implemented · Diagnostics", "Label scene", "ML Kit image labeling: generic labels with confidence (e.g. building, road) — not object positions, not landmark names."),
        ("m0", None, "Camera lifecycle", "Camera released when the app is backgrounded and reopened on return; a capture interrupted by backgrounding no longer crashes."),
        ("plan", "Planned · M7", "Live object detection and hazard advisories", "LiteRT detector (Apache-2.0 model, COCO classes such as person, car, motorcycle) at ≤10 Hz with tracking. Advisory only, never \"safe to cross\"."),
        ("plan", "Planned · M8", "Tamil + English sign reading, landmark ahead", "On-device Tamil OCR (PaddleOCR/Tesseract candidates). Landmarks via Places candidates in the camera's view, shown with confidence."),
        ("none", "Not planned", "Cloud vision", "Owner decision: on-device first; cloud vision may be reconsidered later as an option."),
    ]
    body = (phone(vision_impl_inner(), 70, 98) + phone(vision_concept_inner(), 520, 98) +
            '<div style="position:absolute;left:70px;top:36px;width:414px;text-align:center">' + badge("impl", "Today · single photo, on-device") + '</div>'
            '<div style="position:absolute;left:520px;top:36px;width:414px;text-align:center">' + badge("plan", "Phase 2 concept · live view") + '</div>' +
            panel(1010, 64, 880, "Screen 06 · Real-time scene understanding", "Scene Understanding",
                  "Left: what the app really does today (Diagnostics → Computer Vision). Right: the Phase 2 goal — continuous, on-device perception. Nothing on the right exists yet.", items) +
            legend(1010, 966) + f'<div class="foot" style="left:1010px;top:1002px;width:880px">{FOOTNOTE}</div>')
    return page(body, W3, H3)

# ==========================================================================
# 7. Rerouting — sequence of two real states
# ==========================================================================
OFF = [(120, 690), (120, 560), (150, 549), (190, 534)]
NEW = [(190, 534), (190, 300), (232, 300), (232, 262)]

def reroute_a():
    banner = ('<div style="position:absolute;left:12px;right:12px;top:46px;z-index:12;border-radius:22px;padding:16px 18px;display:flex;gap:14px;align-items:center;'
              'background:#2A2F45;box-shadow:0 14px 34px rgba(0,0,0,.45);border:1px solid rgba(143,176,255,.25)">'
              f'<div style="width:48px;height:48px;border-radius:14px;background:rgba(143,176,255,.16);display:flex;align-items:center;justify-content:center">{ic("sync",26,"#A9C2FF",2.2)}</div>'
              '<div><div style="font-size:17px;font-weight:700">Recalculating your route…</div>'
              '<div class="small muted" style="margin-top:3px">You left the route on Kutchery Road</div></div></div>')
    btns = (f'<div class="btn btn-tonal" style="flex:1">{ic("pause",19,"#E8ECF5")}Pause</div>'
            f'<div class="btn btn-danger" style="flex:1">{ic("stop",17,"#FF8A8A")}Stop</div>')
    return (map_svg(route=ROUTE, traveled=[(120, 690), (120, 560)], dot=(190, 534), heading=70, dest=DEST, dot_scale=1.1) +
            '<svg class="fill" viewBox="0 0 390 844" preserveAspectRatio="xMidYMid slice" style="z-index:3"><polyline points="120,560 150,549 190,534" fill="none" stroke="#FF6B6B" stroke-width="3.5" stroke-dasharray="4 6" stroke-linecap="round"/></svg>' +
            banner + nav_bottom(684, '6 min · 650 m remaining', btns))

def reroute_b():
    toast = ('<div style="position:absolute;left:50%;transform:translateX(-50%);top:176px;z-index:13">'
             f'<div class="pill" style="background:rgba(52,196,106,.16);color:#7BE6A5;border:1px solid rgba(91,224,138,.35);height:34px;font-size:13px">{ic("check",16,"#7BE6A5",2.4)}New route found</div></div>')
    btns = (f'<div class="btn btn-tonal" style="flex:1">{ic("pause",19,"#E8ECF5")}Pause</div>'
            f'<div class="btn btn-danger" style="flex:1">{ic("stop",17,"#FF8A8A")}Stop</div>')
    return (map_svg(route=NEW, old_route=[(120, 560), (120, 300), (190, 300)], dot=(190, 534), heading=0, dest=DEST, dot_scale=1.1) +
            instruction_card(46, "230 m", "Turn right onto Luz Church Road") + toast +
            nav_bottom(684, '7 min · 790 m remaining', btns))

def page_reroute():
    items = [
        ("impl", None, "Off-route detection", "More than 40 m from the route line on any GPS update counts as off-route."),
        ("impl", None, "Wrong-direction detection", "Moving away from the next turn for 2 consecutive real movements (≥8 m apart) triggers a reroute, even while still near the line."),
        ("impl", None, "Automatic rerouting with updated distance and time", "A new OSRM route from your current position replaces the old one; a failed attempt retries on the next GPS update."),
        ("m0", None, "Reroute respects Stop, Pause and new sessions", "A reroute finishing after Stop can't restart navigation or overwrite a new session; while paused it stays paused; resuming before it finishes waits for it instead of starting a second one."),
        ("m0", None, "Progress from the newest position", "When a reroute completes, progress is measured from the latest GPS fix, not the position at request time."),
        ("none", "Design concept", "\"New route found\" chip and old-route trail", "Visual polish in this concept; today the banner simply returns to the instruction card."),
    ]
    body = (phone(reroute_a(), 70, 98) + phone(reroute_b(), 520, 98) +
            '<div style="position:absolute;left:70px;top:36px;width:414px;text-align:center">' + badge("impl", "① You leave the route") + '</div>'
            '<div style="position:absolute;left:520px;top:36px;width:414px;text-align:center">' + badge("impl", "② Recalculated route") + '</div>'
            '<div style="position:absolute;left:487px;top:500px;z-index:3">' + ic("chev", 30, "#4C8BFF", 3) + '</div>' +
            panel(1010, 64, 880, "Screen 07 · Guidance and rerouting", "Navigation Guidance & Rerouting",
                  "Leave the route and the app notices, recalculates from where you are, and updates the remaining distance and time. Implemented for driving; Phase 2 M0 made it robust.", items) +
            legend(1010, 966) + f'<div class="foot" style="left:1010px;top:1002px;width:880px">{FOOTNOTE}</div>')
    return page(body, W3, H3)

# ==========================================================================
# 8. Saved places
# ==========================================================================
def saved_inner():
    def row(name, addr):
        return (f'<div class="listrow" style="padding:14px 18px"><div class="ic" style="background:rgba(61,123,255,.16)">{ic("bookmark",20,"#A9C2FF")}</div>'
                f'<div class="tx"><div class="t1">{name}</div><div class="t2">{addr}</div></div>'
                f'<div class="iconbtn" style="width:38px;height:38px">{ic("trash",19,"#8D99B2")}</div></div>')
    return (
        '<div style="position:absolute;inset:0;background:var(--bg)"></div>'
        '<div class="appbar" style="justify-content:center">'
        f'<div class="iconbtn" style="position:absolute;left:8px">{ic("back",22,"#E8ECF5")}</div><div style="font-size:18px;font-weight:600">Saved Places</div></div>'
        '<div style="position:absolute;top:104px;left:12px;right:12px" class="card">'
        + row("Arulmigu Kapaleeshwarar Temple", "Mylapore, Chennai 600004")
        + '<div style="height:1px;background:rgba(255,255,255,.05);margin:0 18px"></div>'
        + row("Marina Beach", "Kamarajar Salai, Chennai")
        + '<div style="height:1px;background:rgba(255,255,255,.05);margin:0 18px"></div>'
        + row("San Thome Cathedral Basilica", "Santhome High Rd, Chennai")
        + '<div style="height:1px;background:rgba(255,255,255,.05);margin:0 18px"></div>'
        + row("Chennai Central Railway Station", "Park Town, Chennai 600003")
        + '</div>'
        '<div style="position:absolute;top:470px;left:12px;right:12px;padding:16px 18px;border-radius:20px;background:rgba(255,255,255,.03);'
        'border:1px solid rgba(255,255,255,.06);display:flex;gap:12px;align-items:center">'
        f'{ic("lock",20,"#8FB0FF")}<div class="small muted" style="line-height:1.45">Saved to your account and synced. Only you can see your places.</div></div>'
        '<div class="snack" style="bottom:40px">' + ic("check", 18, "#1E8E3E", 2.6) + '<span style="flex:1">Place saved.</span></div>')

def account_inner():
    return (
        '<div style="position:absolute;inset:0;background:var(--bg)"></div>'
        '<div class="appbar" style="justify-content:center">'
        f'<div class="iconbtn" style="position:absolute;left:8px">{ic("back",22,"#E8ECF5")}</div><div style="font-size:18px;font-weight:600">Sign In</div></div>'
        '<div style="position:absolute;top:130px;left:24px;right:24px">'
        f'<div class="logo" style="width:64px;height:64px;border-radius:20px;margin:0 auto">{nav_logo(34)}</div>'
        '<div style="text-align:center;font-size:22px;font-weight:700;margin-top:18px">Keep your places</div>'
        '<div style="text-align:center;font-size:14px;color:#9AA6BF;margin-top:6px;line-height:1.45">Sign in to save destinations and see them on any device.</div>'
        '<div style="margin-top:28px;font-size:12px;font-weight:600;color:#9AA6BF">Email</div>'
        '<div style="margin-top:6px;height:54px;border-radius:14px;background:var(--surface2);display:flex;align-items:center;padding:0 16px;font-size:15px;box-shadow:inset 0 0 0 1.5px rgba(61,123,255,.55)">priya@example.com</div>'
        '<div style="margin-top:14px;font-size:12px;font-weight:600;color:#9AA6BF">Password</div>'
        '<div style="margin-top:6px;height:54px;border-radius:14px;background:var(--surface2);display:flex;align-items:center;padding:0 16px;font-size:18px;letter-spacing:4px;color:#C9D3E6">••••••••</div>'
        '<div class="btn btn-primary" style="margin-top:24px">Sign In</div>'
        '<div style="text-align:center;margin-top:16px;font-size:13.5px;color:#8FB0FF;font-weight:600">Don\'t have an account? Create one</div></div>')

def page_saved():
    items = [
        ("impl", None, "Saved places list", "Supabase Postgres table saved_places; Row Level Security restricts every select, insert and delete to the signed-in user."),
        ("impl", None, "Save from route preview, with real confirmation", "\"Place saved.\" appears only when the save actually succeeded (a bug fixed in Phase 1)."),
        ("impl", None, "Remove a place", "The trash icon deletes the row and reloads the list."),
        ("impl", None, "Email sign-in and sign-up", "Supabase Auth with email confirmation; the app shows a dedicated \"confirm your email\" state."),
        ("impl", None, "Recent searches", "Session-only list on the search screen (screen 02)."),
        ("none", None, "Home / Work, favourites, synced history", "Favourites are the same thing as Saved places; Home/Work labels and cross-device history are not built and not on the Phase 2 roadmap."),
    ]
    body = (phone(saved_inner(), 70, 98) + phone(account_inner(), 520, 98) +
            '<div style="position:absolute;left:70px;top:36px;width:414px;text-align:center">' + badge("impl", "Saved places") + '</div>'
            '<div style="position:absolute;left:520px;top:36px;width:414px;text-align:center">' + badge("impl", "Account (needed to save)") + '</div>' +
            panel(1010, 64, 880, "Screen 08 · Saved places and account", "Saved Places",
                  "Save destinations to your account and get back to them in one tap. Built on Supabase with per-user security.", items) +
            legend(1010, 966) + f'<div class="foot" style="left:1010px;top:1002px;width:880px">{FOOTNOTE}</div>')
    return page(body, W3, H3)

# ==========================================================================
# 9. Permissions and fallback
# ==========================================================================
def perm_location():
    snack = ('<div class="snack" style="bottom:400px;z-index:30">' + ic("locoff", 20, "#B42318", 2.2) +
             '<span style="flex:1;line-height:1.35">Location permission was denied. Enable it in Settings to continue.</span><b>Open Settings</b></div>')
    return home_inner(show_tags=False) + '<div style="position:absolute;inset:0;background:rgba(0,0,0,.25);z-index:20"></div>' + snack

def perm_camera():
    return (
        '<div style="position:absolute;inset:0;background:var(--bg)"></div>'
        '<div class="appbar" style="justify-content:center">'
        f'<div class="iconbtn" style="position:absolute;left:8px">{ic("back",22,"#E8ECF5")}</div><div style="font-size:18px;font-weight:600">Camera Preview</div></div>'
        '<div style="position:absolute;top:210px;left:28px;right:28px;text-align:center">'
        '<div style="width:96px;height:96px;border-radius:30px;margin:0 auto;background:rgba(255,107,107,.12);display:flex;align-items:center;justify-content:center">'
        + ic("camoff", 46, "#FF8A8A", 1.8) + '</div>'
        '<div style="font-size:20px;font-weight:700;margin-top:24px">Camera access needed</div>'
        '<div style="font-size:14.5px;color:#9AA6BF;margin-top:10px;line-height:1.5">Camera permission is needed for AR navigation. Enable it in system settings, then try again.</div>'
        '<div class="btn btn-primary" style="margin:28px 30px 0">Try again</div>'
        '<div style="margin-top:40px;padding:14px 16px;border-radius:16px;background:rgba(255,255,255,.03);border:1px solid rgba(255,255,255,.06);text-align:left;display:flex;gap:12px">'
        + ic("camoff", 20, "#9AA6BF") + '<div style="font-size:12.5px;color:#9AA6BF;line-height:1.45"><b style="color:#C9D3E6">No camera on this device?</b> '
        'The app says so plainly — the rest of the app doesn\'t need a camera.</div></div></div>')

def perm_fallback():
    def reason(icon, title, desc, col):
        return (f'<div style="display:flex;gap:12px;align-items:flex-start;padding:10px 0">'
                f'<div style="width:38px;height:38px;border-radius:12px;background:{col}22;display:flex;align-items:center;justify-content:center;flex:none">{ic(icon,19,col)}</div>'
                f'<div><div style="font-size:14.5px;font-weight:600">{title}</div><div style="font-size:12.5px;color:#9AA6BF;margin-top:2px;line-height:1.4">{desc}</div></div></div>')
    return (
        street_svg(dim=.55) +
        '<div class="sheet planned" style="top:300px;bottom:22px;z-index:12;padding:22px 20px">'
        '<div style="font-size:20px;font-weight:700">AR guidance isn\'t available</div>'
        '<div style="font-size:13.5px;color:#9AA6BF;margin-top:6px;line-height:1.45">You can keep navigating on the map. We\'ll offer AR again when it\'s ready.</div>'
        '<div style="margin-top:10px">'
        + reason("compass", "Heading unavailable", "No usable compass reading on this device.", "#FCD34D")
        + reason("camoff", "Camera unavailable or denied", "AR needs the rear camera.", "#FF8A8A")
        + reason("ar", "AR not supported", "ARCore isn't available or needs an update.", "#A9C2FF") +
        '</div><div class="btn btn-primary" style="margin-top:12px">' + ic("map", 19, "#fff") + 'Continue with map navigation</div></div>'
        + ptag("PLANNED · M5", "right:22px;top:288px"))

def page_perm():
    items = [
        ("impl", None, "Location off or denied", "Clear messages for services disabled, denied, and denied forever, with Enable / Open Settings shortcuts. Permission is asked only when needed."),
        ("impl", None, "Camera permission denied", "Plain message and Try again — no crash, no raw error text. Permission is asked only when a camera screen opens."),
        ("impl", None, "Camera unavailable", "Devices without a usable camera get an honest message; the rest of the app keeps working."),
        ("impl", "Implemented · state only", "Heading and AR availability detection", "Compass-unavailable state and the ARCore capability check exist, shown on the Diagnostics screen."),
        ("m0", None, "Camera recovery", "Camera released on backgrounding and reopened on return; the permission dialog no longer interrupts a camera start."),
        ("plan", "Planned · M5", "\"Continue with map navigation\" fallback", "When AR can't run (heading, camera, ARCore or tracking lost), the session drops to 2D navigation with the reason shown."),
    ]
    sc, pw, top = 0.82, 414 * 0.82, 150
    xs = [56, 56 + pw + 34, 56 + 2 * (pw + 34)]
    labels = [("impl", "Location permission"), ("impl", "Camera denied / unavailable"), ("plan", "AR fallback · M5 concept")]
    body = "".join(phone(inner, x, top, sc) for inner, x in zip([perm_location(), perm_camera(), perm_fallback()], xs))
    body += "".join(f'<div style="position:absolute;left:{x}px;top:{top-50}px;width:{pw}px;text-align:center">{badge(k, t)}</div>'
                    for x, (k, t) in zip(xs, labels))
    body += (panel(1195, 64, 715, "Screen 09 · Permissions and fallback", "Permissions & Fallback",
                   "Every failure has a clear, human message and a way forward. Left and middle work today; the AR fallback arrives with M5.", items) +
             legend(1195, 948) + f'<div class="foot" style="left:1195px;top:986px;width:715px;font-size:11.5px">{FOOTNOTE}</div>')
    return page(body, W3, H3)

# ==========================================================================
# 10. Showcase
# ==========================================================================
def page_showcase():
    W, H = 2200, 1240
    shots = [(home_inner(False), "Home dashboard", "impl", "Implemented"),
             (route_inner(False), "Route preview", "impl", "Implemented"),
             (ar_inner(False), "Live AR navigation", "plan", "Phase 2 concept · M5"),
             (nav2d_inner(False), "2D map navigation", "impl", "Implemented"),
             (vision_concept_inner(), "Scene understanding", "plan", "Phase 2 concept · M7/M8"),
             (reroute_b(), "Rerouting", "m0", "Implemented · hardened in M0")]
    sc = 0.70
    pw = 414 * sc
    gap = 46
    total = 6 * pw + 5 * gap
    x0 = (W - total) / 2
    phones = []
    for i, (inner, cap, kind, btxt) in enumerate(shots):
        x = x0 + i * (pw + gap)
        y = 330 + (0 if i in (2,) else 46 if i in (1, 3) else 92)
        phones.append(phone(inner, x, y, sc))
        phones.append(f'<div style="position:absolute;left:{x}px;top:{y + 868*sc + 22}px;width:{pw}px;text-align:center">'
                      f'<div style="font-size:19px;font-weight:700;color:#EEF2FA">{cap}</div><div style="margin-top:8px">{badge(kind, btxt)}</div></div>')
    glow = ('<div style="position:absolute;left:50%;top:640px;width:1500px;height:700px;margin-left:-750px;border-radius:50%;'
            'background:radial-gradient(closest-side,rgba(11,95,255,.28),rgba(11,95,255,0));filter:blur(10px)"></div>')
    head = (
        '<div style="position:absolute;left:0;right:0;top:70px;text-align:center">'
        f'<div style="display:inline-flex;align-items:center;gap:16px"><div class="logo" style="width:64px;height:64px;border-radius:20px">{nav_logo(36)}</div>'
        '<div style="text-align:left"><div style="font-family:\'Inter Display\',Inter;font-size:54px;font-weight:800;letter-spacing:.02em;line-height:1">TN AR NAV</div>'
        '<div style="font-size:18px;color:#9AA6BF;margin-top:6px">AR Navigation for Tamil Nadu</div></div></div>'
        '<div style="font-size:21px;color:#C9D3E6;margin-top:28px;font-weight:500">AI-Powered Human-Centric Outdoor Augmented Reality Navigation System</div>'
        '<div style="font-size:17px;color:#8D99B2;margin-top:6px">using Hybrid Localization and Real-Time Scene Understanding · Flutter &amp; Dart · Android-first</div></div>')
    foot = (legend(W / 2 - 430, H - 92) +
            f'<div class="foot" style="left:{W/2-700}px;top:{H-50}px;width:1400px;text-align:center">'
            'Final-project concept after Phase 2. Screens tagged "concept" are planned in the approved Phase 2 roadmap and are not implemented yet. '
            'Maps and camera views are illustrations.</div>')
    return page(glow + head + "".join(phones) + foot, W, H)

PAGES = {
    "screens/01_home_dashboard.png": page_home,
    "screens/02_destination_search.png": page_search,
    "screens/03_route_preview.png": page_route,
    "screens/04_live_ar_navigation_concept.png": page_ar,
    "screens/05_2d_map_navigation.png": page_nav2d,
    "screens/06_scene_understanding.png": page_vision,
    "screens/07_guidance_and_rerouting.png": page_reroute,
    "screens/08_saved_places.png": page_saved,
    "screens/09_permissions_and_fallback.png": page_perm,
    "showcase/10_final_app_showcase.png": page_showcase,
}
