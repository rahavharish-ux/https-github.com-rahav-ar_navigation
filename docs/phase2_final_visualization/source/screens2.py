"""Phase 2 final-product screens (target concept, status-tagged)."""
from kit2 import (ic, nav_logo, phone, map_svg, street_svg, ROUTE, DEST, page2, panel2, legend2,
                  badge2, tag, tgt, orb, navbar, fade, FOOT2)

W1, H1 = 1600, 1000
W3, H3 = 1960, 1060

def single(inner, n, eyebrow, title, sub, items):
    return page2(phone(inner, 90, 66) + panel2(600, 64, 920, f"Screen {n} · {eyebrow}", title, sub, items) +
                 legend2(600, 912) + f'<div class="foot" style="left:600px;top:950px;width:920px">{FOOT2}</div>', W1, H1)

def double(inners, labels, n, eyebrow, title, sub, items):
    body = ""
    for (inner, x), (k, t) in zip(zip(inners, (70, 520)), labels):
        body += phone(inner, x, 98)
        body += f'<div style="position:absolute;left:{x}px;top:36px;width:414px;text-align:center">{badge2(k, t)}</div>'
    body += (panel2(1010, 64, 880, f"Screen {n} · {eyebrow}", title, sub, items) +
             legend2(1010, 966) + f'<div class="foot" style="left:1010px;top:1002px;width:880px">{FOOT2}</div>')
    return page2(body, W3, H3)

# ==========================================================================
# 01 Intelligent home dashboard
# ==========================================================================
def home():
    tiles = ""
    for icon, label, kind, t in [("ar", "AR Navigate", "road", "M5"), ("pin", "Nearby", "prop", "PROPOSED"),
                                 ("download", "Offline maps", "prop", "PROPOSED"), ("shield", "Safety", "prop", "PROPOSED")]:
        tiles += (f'<div style="position:relative;flex:1;height:78px;border-radius:18px;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:7px" class="g2l">'
                  f'{ic(icon, 23, "#8FE3F5")}<span style="font-size:11.5px;font-weight:600;color:#D6DEEE">{label}</span>'
                  f'{tag(kind, t, "right:4px;top:-7px;font-size:8px;padding:2px 5px")}</div>')
    near = ""
    for icon, name, dist in [("hospital", "Hospital", "1.2 km"), ("fuel", "Petrol bunk", "450 m"), ("book", "Library", "900 m"), ("landmark", "Temple", "350 m")]:
        near += (f'<div class="g2l" style="flex:none;width:104px;border-radius:16px;padding:11px 12px">'
                 f'<div style="width:34px;height:34px;border-radius:11px;background:rgba(34,211,238,.1);display:flex;align-items:center;justify-content:center">{ic(icon, 18, "#7FE6F7")}</div>'
                 f'<div style="font-size:13px;font-weight:600;margin-top:8px">{name}</div><div style="font-size:11.5px;color:#8D99B2">{dist}</div></div>')
    sheet = (
        '<div style="position:absolute;left:0;right:0;top:332px;bottom:0;border-radius:30px 30px 0 0;padding:16px 16px 0;z-index:12;'
        'background:linear-gradient(180deg,rgba(10,15,27,.97),#080C16);border-top:1px solid rgba(255,255,255,.07)">'
        # AI ask bar
        '<div style="position:relative;padding:1.5px;border-radius:20px" class="aur">'
        '<div style="height:56px;border-radius:19px;background:#0B1120;display:flex;align-items:center;gap:11px;padding:0 8px 0 14px">'
        + ic("spark", 21, "#5EEAF5") + '<span style="flex:1;font-size:14.5px;color:#A5B2CC">Ask or say where to go…</span>'
        '<div class="iconbtn" style="width:40px;height:40px;background:rgba(255,255,255,.06)">' + ic("camera", 19, "#D6DEEE") + '</div>'
        '<div class="iconbtn aur" style="width:40px;height:40px">' + ic("mic", 19, "#fff") + '</div></div>'
        + tag("road", "M9 · M2", "right:10px;top:-9px") + '</div>'
        '<div style="display:flex;gap:8px;margin-top:11px;overflow:hidden">'
        '<span class="chip2">Nearest hospital</span><span class="chip2 chipw">Where am I?</span><span class="chip2 chipw">Read this sign</span></div>'
        f'<div style="display:flex;gap:9px;margin-top:16px">{tiles}</div>'
        '<div style="display:flex;justify-content:space-between;align-items:center;margin-top:18px"><span class="h2t">Nearby now</span>'
        '<span style="font-size:12px;color:#7FE6F7;font-weight:600">See all</span></div>'
        f'<div style="display:flex;gap:9px;margin-top:9px;overflow:hidden">{near}</div>'
        '<div style="display:flex;gap:8px;margin-top:14px;align-items:center">' + ic("bookmark", 16, "#8D99B2") +
        '<span class="chip2 chipw" style="height:30px">Kapaleeshwarar Temple</span><span class="chip2 chipw" style="height:30px">Marina Beach</span></div>'
        '</div>')
    header = (
        '<div style="position:absolute;top:44px;left:16px;right:14px;display:flex;align-items:center;z-index:12">'
        f'<div class="logo" style="width:32px;height:32px;border-radius:10px">{nav_logo(18)}</div>'
        '<div style="margin-left:10px;font-size:16px;font-weight:800;letter-spacing:.03em">TN AR Navigation</div><div style="flex:1"></div>'
        '<div class="chip2 chipw g2" style="height:32px;margin-right:8px"><b style="color:#fff">EN</b><span style="color:#5A6680">|</span><span class="tamil">தமிழ்</span></div>'
        f'<div class="iconbtn g2" style="width:38px;height:38px">{ic("account", 20, "#E8ECF5")}</div></div>'
        '<div style="position:absolute;top:96px;left:18px;z-index:12">'
        '<div style="font-size:25px;font-weight:800;letter-spacing:-.01em">Vanakkam, Priya</div>'
        '<div style="display:flex;align-items:center;gap:8px;margin-top:6px;font-size:13px;color:#B4C0D6">'
        '<span class="dot" style="background:#5BE08A;box-shadow:0 0 8px #5BE08A"></span>Mylapore, Chennai</div></div>'
        '<div style="position:absolute;top:262px;left:16px;z-index:12;position:absolute">'
        '<div class="chip2 g2" style="height:34px">' + ic("satellite", 15, "#5EEAF5") + 'Fused position · high confidence</div>'
        + tag("road", "M4", "right:-14px;top:-9px") + '</div>')
    return (map_svg(dot=(150, 300), heading=30, vb="0 60 390 600") + fade(True, 300, .97) + header + sheet + navbar("home"))

def page_home():
    items = [
        ("road", "Roadmap · M9 + M2", "AI ask bar with voice and camera", "Type, speak or point the camera. Goes to the provider-independent assistant (screen 02); open model first."),
        ("road", "Roadmap · M2", "Tamil / English switch", "Whole UI localised; the greeting and examples follow the chosen language."),
        ("road", "Roadmap · M4", "Fused-position indicator", "Shows the qualitative confidence of the GNSS + sensor estimate (screen 07). No accuracy number is claimed."),
        ("impl", None, "Live map, search and saved places", "Google map, Places search and Supabase saved places already exist; restyled here."),
        ("road", "Roadmap · M5", "AR Navigate shortcut", "Opens camera-based navigation (screen 05) when ARCore is supported."),
        ("prop", None, "Nearby now, Offline maps, Safety", "In the Phase 2 vision but not yet in the approved roadmap. Nearby results would use Places search (billing)."),
    ]
    sub = "An AI-first start screen: ask, speak or point the camera, with one-tap access to AR, nearby places, offline maps and safety."
    return single(home(), "01", "Intelligent home dashboard", "Intelligent Home", sub, items)

# ==========================================================================
# 02 Multimodal AI assistant
# ==========================================================================
def assistant():
    chat = (
        '<div style="position:absolute;top:128px;left:14px;right:14px;bottom:182px;display:flex;flex-direction:column;gap:11px;overflow:hidden">'
        '<div class="bub-u">Take me to the nearest hospital</div>'
        '<div class="bub-a">I found a nearby hospital. The estimated journey is <b>1.2 km</b>.'
        '<div class="g2l" style="margin-top:10px;border-radius:14px;padding:11px;display:flex;gap:11px;align-items:center">'
        '<div style="width:38px;height:38px;border-radius:11px;background:rgba(255,107,107,.14);display:flex;align-items:center;justify-content:center">' + ic("hospital", 20, "#FF8A8A") + '</div>'
        '<div style="flex:1"><div style="font-weight:700;font-size:14px">Government Hospital</div><div style="font-size:12px;color:#94A2BC">Royapettah · 1.2 km · ~15 min walk</div></div></div>'
        '<div style="display:flex;gap:8px;margin-top:10px"><div class="sbtn p">' + ic("ar", 16, "#fff") + 'Start in AR</div><div class="sbtn t">' + ic("map", 16, "#E3E9F5") + 'Map</div></div>'
        '<div><span class="tool">⚙ search_places</span><span class="tool">⚙ plan_route</span></div></div>'
        '<div class="bub-u tamil" style="font-size:15px">எனக்கு nearest petrol bunk காட்டு</div>'
        '<div class="bub-a"><span class="tamil" style="font-size:15px">அருகில் 2 petrol bunk-கள் உள்ளன:</span>'
        '<div style="margin-top:8px;display:flex;flex-direction:column;gap:7px">'
        '<div style="display:flex;gap:9px;align-items:center">' + ic("fuel", 17, "#7FE6F7") + '<span style="flex:1">Luz Church Road</span><b style="font-size:13px">450 m</b></div>'
        '<div style="display:flex;gap:9px;align-items:center">' + ic("fuel", 17, "#7FE6F7") + '<span style="flex:1">Kutchery Road</span><b style="font-size:13px">800 m</b></div></div></div>'
        '</div>')
    head = (
        '<div style="position:absolute;top:42px;left:8px;right:12px;height:60px;display:flex;align-items:center;gap:10px;z-index:12">'
        f'<div class="iconbtn">{ic("back", 22, "#E8ECF5")}</div>{orb(40, 19)}'
        '<div style="flex:1"><div style="font-size:16.5px;font-weight:700">Navigation Assistant</div>'
        '<div style="font-size:11.5px;color:#8D99B2">Tamil + English</div></div>'
        '<div class="chip2 chipw" style="height:30px"><span>EN</span><span style="color:#5A6680">|</span><b class="tamil" style="color:#fff">தமிழ்</b></div></div>')
    bottom = (
        '<div style="position:absolute;left:0;right:0;bottom:0;height:182px;padding:12px 14px 30px;z-index:12;'
        'background:linear-gradient(180deg,rgba(6,10,18,0),#060A12 22%)">'
        '<div style="display:flex;gap:8px;overflow:hidden"><span class="chip2">What\'s ahead?</span><span class="chip2 chipw">Where am I?</span><span class="chip2 chipw">Read this sign</span></div>'
        '<div style="display:flex;gap:10px;align-items:center;margin-top:12px">'
        f'<div class="iconbtn g2" style="width:50px;height:50px;border-radius:16px">{ic("camera", 22, "#D6DEEE")}</div>'
        '<div class="g2" style="flex:1;height:52px;border-radius:18px;display:flex;align-items:center;padding:0 14px;font-size:14px;color:#8D99B2">Ask in Tamil or English…</div>'
        f'<div class="iconbtn aur" style="width:52px;height:52px;border-radius:18px;box-shadow:0 8px 20px rgba(34,190,238,.4)">{ic("mic", 23, "#fff")}</div></div>'
        '<div style="text-align:center;font-size:10.5px;color:#66748F;margin-top:10px">Navigation actions always ask before starting · advisory answers</div></div>')
    return ('<div style="position:absolute;inset:0;background:radial-gradient(500px 400px at 50% 0%,#10244A,#060A12 70%)"></div>' +
            head + chat + bottom + tgt("ROADMAP · M9 ASSISTANT — NOT BUILT", 102))

def page_assistant():
    items = [
        ("road", "Roadmap · M9", "Conversational assistant", "Provider-independent LlmProvider; first an open-weight model on-device or self-hosted (benchmarked for Tamil). A paid hosted model only after its cost is approved."),
        ("road", "Roadmap · M9", "Tool use over app capabilities", "The model calls app tools (search_places, plan_route, where_am_i, whats_ahead, read_sign); results come from real services, not the model's memory."),
        ("road", "Roadmap · M2 + M9", "Tamil, English and code-mixed input", "\"எனக்கு nearest petrol bunk காட்டு\" is answered in Tamil. Recognition uses the phone's speech engine (ta-IN / en-IN)."),
        ("road", "Roadmap · M9", "Camera input", "Describe-scene / read-sign tools run only after an explicit tap; images stay on the device by default."),
        ("impl", "Phase 1 service reused", "Place search and distances", "The hospital and petrol-bunk results reuse the existing Google Places search."),
        ("road", "Safety rule", "Confirm before acting", "The assistant never starts navigation or gives safety instructions on its own; turn-by-turn stays deterministic."),
    ]
    sub = "Ask by text, voice or camera, in Tamil or English. The assistant understands the request, calls the app's own tools and answers with places you can navigate to."
    return single(assistant(), "02", "Multimodal AI assistant", "AI Navigation Assistant", sub, items)

# ==========================================================================
# 03 AI destination discovery
# ==========================================================================
def discovery():
    def res(icon, name, why, dist):
        return (f'<div class="listrow" style="padding:11px 16px"><div class="ic" style="background:rgba(34,211,238,.09)">{ic(icon, 20, "#7FE6F7")}</div>'
                f'<div class="tx"><div class="t1">{name}</div><div class="t2">{why}</div></div>'
                f'<div style="font-size:13px;font-weight:700;color:#D6DEEE">{dist}</div></div>')
    lm = ""
    for name, dist in [("Kapaleeshwarar Temple", "350 m"), ("San Thome Basilica", "1.7 km"), ("Temple Tank", "300 m")]:
        lm += (f'<div class="g2l" style="flex:none;width:150px;border-radius:16px;overflow:hidden">'
               f'<div style="height:70px;position:relative;overflow:hidden"><div style="position:absolute;inset:-40px -10px;transform:scale(.9)">{street_svg(sign=False)}</div></div>'
               f'<div style="padding:8px 10px"><div style="font-size:12.5px;font-weight:700;white-space:nowrap;overflow:hidden;text-overflow:ellipsis">{name}</div>'
               f'<div style="font-size:11px;color:#8D99B2">{dist}</div></div></div>')
    return (
        '<div style="position:absolute;inset:0;background:#070B14"></div>'
        '<div style="position:absolute;top:44px;left:12px;right:12px;padding:1.5px;border-radius:19px;z-index:12" class="aur">'
        '<div style="height:54px;border-radius:18px;background:#0B1120;display:flex;align-items:center;gap:10px;padding:0 12px">'
        + ic("spark", 20, "#5EEAF5") + '<span style="flex:1;font-size:14.5px">quiet place to sit near the beach<span style="display:inline-block;width:2px;height:17px;background:#22D3EE;vertical-align:-3px;margin-left:1px"></span></span>'
        + ic("mic", 20, "#9AA6BF") + '</div></div>'
        '<div class="g2" style="position:absolute;top:112px;left:12px;right:12px;border-radius:18px;padding:12px 14px">'
        '<div class="h2t" style="font-size:11px">Understood as</div>'
        '<div style="display:flex;flex-wrap:wrap;gap:7px;margin-top:8px">'
        f'<span class="chip2" style="height:28px">{ic("tree", 14, "#A8F0FB")}Park or open space</span><span class="chip2" style="height:28px">Quiet</span>'
        f'<span class="chip2" style="height:28px">{ic("pin", 14, "#A8F0FB")}Near Marina Beach</span><span class="chip2" style="height:28px">{ic("walk", 14, "#A8F0FB")}Walking</span></div></div>'
        '<div style="position:absolute;top:222px;left:0;right:0">'
        '<div class="secthead"><span>Suggested</span><span style="letter-spacing:0;text-transform:none;color:#7FE6F7;font-weight:600">Why these?</span></div>'
        + res("tree", "Nageswara Rao Park", "Matches: park · walkable · 1.4 km", "1.4 km")
        + res("pin", "Santhome Beach", "Matches: near the beach · walkable", "1.8 km")
        + res("pin", "Marina Beach promenade", "Matches: beach · seating", "2.9 km") +
        '<div class="secthead" style="margin-top:4px"><span>Landmarks nearby</span></div>'
        f'<div style="display:flex;gap:9px;padding:0 16px;overflow:hidden">{lm}</div>'
        '<div class="secthead" style="margin-top:8px"><span>Recent</span></div>'
        '<div style="display:flex;gap:8px;padding:0 16px;flex-wrap:wrap">'
        f'<span class="chip2 chipw">{ic("history", 14, "#B4C0D6")}nearest hospital</span><span class="chip2 chipw">{ic("history", 14, "#B4C0D6")}Kapaleeshwarar Temple</span></div></div>'
        + navbar("discover") + tgt("ROADMAP · M9 + M8 — NOT BUILT", 102))

def page_discovery():
    items = [
        ("road", "Roadmap · M9", "Natural-language search", "The assistant turns \"quiet place to sit near the beach\" into a structured query (type, area, travel mode) and shows how it understood it."),
        ("road", "Roadmap · M9", "Explained suggestions", "Each result says which parts of the request it matches — no invented reviews or crowd levels."),
        ("road", "Roadmap · M8", "Landmarks nearby", "Places Nearby candidates, as planned for landmark recognition; thumbnails here are illustrations."),
        ("impl", None, "Place search and recent searches", "Google Places Text Search and session-only recents exist today."),
        ("m0", None, "No stale results", "A slow, older response can never replace newer results."),
        ("prop", None, "Persistent search history", "Recents survive restarts and sync across devices — not in the roadmap yet."),
    ]
    sub = "Describe what you want instead of typing an exact name. The app shows how it understood you and why each place is suggested."
    return single(discovery(), "03", "AI destination discovery", "AI Destination Discovery", sub, items)

# ==========================================================================
# 04 Intelligent pedestrian route planning
# ==========================================================================
R_FAST = [(120, 690), (120, 300), (232, 300), (232, 262)]
R_SAFE = [(120, 690), (120, 640), (190, 640), (190, 300), (232, 300), (232, 262)]
R_ACC = [(120, 690), (120, 450), (255, 450), (255, 262), (240, 260)]

def routes_svg():
    def pl(pts, col, w=6, dash=""):
        p = " ".join(f"{x},{y}" for x, y in pts)
        return (f'<polyline points="{p}" fill="none" stroke="{col}" stroke-opacity=".25" stroke-width="{w+8}" stroke-linecap="round" stroke-linejoin="round"/>'
                f'<polyline points="{p}" fill="none" stroke="{col}" stroke-width="{w}" stroke-linecap="round" stroke-linejoin="round"{dash}/>')
    return ('<svg class="fill" viewBox="0 118 390 430" preserveAspectRatio="xMidYMid slice" style="z-index:3">'
            + pl(R_ACC, "#A78BFA", 5, ' stroke-dasharray="2 9"') + pl(R_SAFE, "#22D3EE", 5) + pl(R_FAST, "#3D7BFF", 7) + '</svg>')

def route_plan():
    def card(col, name, mins, dist, why, sel=False, t=None, tk="road"):
        b = "box-shadow:inset 0 0 0 1.5px " + col + ";background:rgba(255,255,255,.05)" if sel else "background:rgba(255,255,255,.03)"
        tg = tag(tk, t, "right:10px;top:-8px") if t else ""
        return (f'<div style="position:relative;border-radius:16px;padding:11px 13px;display:flex;gap:12px;align-items:center;{b};border:1px solid rgba(255,255,255,.06)">'
                f'<div style="width:6px;align-self:stretch;border-radius:3px;background:{col}"></div>'
                f'<div style="flex:1"><div style="display:flex;align-items:baseline;gap:8px"><span style="font-size:15px;font-weight:700">{name}</span></div>'
                f'<div style="font-size:12px;color:#94A2BC;margin-top:2px">{why}</div></div>'
                f'<div style="text-align:right"><div style="font-size:18px;font-weight:800">{mins}</div><div style="font-size:11.5px;color:#94A2BC">{dist}</div></div>{tg}</div>')
    return (
        '<div style="position:absolute;left:0;right:0;top:0;height:430px">' + map_svg(dot=(120, 690), dest=DEST, vb="0 118 390 430") + routes_svg() + '</div>'
        + fade(True, 120, .95) +
        '<div style="position:absolute;top:44px;left:8px;right:12px;display:flex;align-items:center;gap:8px;z-index:12">'
        f'<div class="iconbtn g2">{ic("back", 22, "#E8ECF5")}</div><div><div style="font-size:16px;font-weight:700">To Kapaleeshwarar Temple</div>'
        f'<div style="font-size:11.5px;color:#9AA6BF;display:flex;align-items:center;gap:5px">{ic("walk", 13, "#9AA6BF")}Walking · 3 options</div></div></div>'
        '<div style="position:absolute;left:0;right:0;top:400px;bottom:0;border-radius:28px 28px 0 0;background:#080C16;border-top:1px solid rgba(255,255,255,.07);padding:16px 14px 30px;z-index:12">'
        '<div style="display:flex;flex-direction:column;gap:10px">'
        + card("#3D7BFF", "Fastest", "14 min", "1.1 km", "Via R.K. Mutt Road · 2 major-road crossings", True)
        + card("#22D3EE", "Safer · fewer crossings", "16 min", "1.2 km", "1 major-road crossing · quieter streets", t="M3+")
        + card("#A78BFA", "Step-free", "17 min", "1.3 km", "Avoids steps mapped in OpenStreetMap", t="PROPOSED", tk="prop") +
        '</div>'
        '<div style="margin-top:10px;font-size:11px;color:#7D8AA5;line-height:1.4;display:flex;gap:7px">' + ic("eye", 14, "#7D8AA5") +
        '<span>Based on road types from OpenStreetMap. No live traffic, crime or lighting data is used.</span></div>'
        '<div style="display:flex;gap:10px;margin-top:12px"><div class="sbtn t" style="flex:1;height:50px;border-radius:15px">' + ic("map", 18, "#E3E9F5") + 'Start on map</div>'
        '<div class="sbtn p" style="flex:1.3;height:50px;border-radius:15px">' + ic("ar", 18, "#fff") + 'Start in AR</div></div>'
        '</div>' + tgt("ROADMAP · M3 WALKING — NOT BUILT", 120))

def page_route():
    items = [
        ("road", "Roadmap · M3", "Walking routes", "OpenRouteService foot-walking behind a replaceable RoutingProvider; driving keeps using OSRM."),
        ("road", "Roadmap · M3+", "Route comparison with reasons", "Alternatives ranked by time, major-road crossings and main-road exposure, computed from the route's road types."),
        ("road", "Roadmap · M10 (data)", "Hazard-aware ranking", "Later, confirmed community observations (e.g. a blocked footpath) can penalise a route."),
        ("prop", None, "Step-free option", "Avoids steps tagged in OpenStreetMap; only as good as local tagging, so it is marked as a proposal."),
        ("impl", None, "Distance, duration, start on map", "Route polyline, distance and duration already work for driving."),
        ("prop", "Not used", "Live traffic, crime or lighting data", "No source is specified, so the screen says plainly that none is used."),
    ]
    sub = "Choose between pedestrian routes with honest reasons: the fastest, the one with fewer major-road crossings, and a step-free option where map data allows."
    return single(route_plan(), "04", "Intelligent route planning", "Intelligent Route Planning", sub, items)

# ==========================================================================
# 05 Advanced live AR navigation (centrepiece)
# ==========================================================================
def chevrons():
    out = ['<svg class="fill" viewBox="0 0 390 844" preserveAspectRatio="xMidYMid slice" style="z-index:6">',
           '<defs><linearGradient id="chv" x1="0" y1="1" x2="0" y2="0"><stop offset="0" stop-color="#22D3EE"/><stop offset="1" stop-color="#2F6BFF"/></linearGradient>'
           '<filter id="gl" x="-50%" y="-50%" width="200%" height="200%"><feGaussianBlur stdDeviation="3" result="b"/><feMerge><feMergeNode in="b"/><feMergeNode in="SourceGraphic"/></feMerge></filter></defs>']
    for i in range(7):
        t = i / 7.0
        y = 812 - (1 - (1 - t) ** 1.5) * 330
        s = (y - 384) / (844 - 384)          # perspective scale 0..1
        cx = 195 - 62 * s                    # left lane, converging on the vanishing point
        w = 120 * s + 10
        h = w * 0.34
        sw = max(2.2, 12 * s)
        op = 0.95 - t * 0.45
        out.append(f'<polyline points="{cx-w/2:.1f},{y+h/2:.1f} {cx:.1f},{y-h/2:.1f} {cx+w/2:.1f},{y+h/2:.1f}" fill="none" stroke="url(#chv)" '
                   f'stroke-width="{sw:.1f}" stroke-linecap="round" stroke-linejoin="round" opacity="{op:.2f}" filter="url(#gl)"/>')
    out.append('</svg>')
    return "".join(out)

TURN3D = '''<svg width="150" height="120" viewBox="0 0 150 120" style="position:absolute;left:176px;top:368px;z-index:7;filter:drop-shadow(0 10px 14px rgba(0,0,0,.55)) drop-shadow(0 0 14px rgba(34,211,238,.6))">
<defs><linearGradient id="t3a" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#7DF0FF"/><stop offset="1" stop-color="#2F6BFF"/></linearGradient>
<linearGradient id="t3b" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#1D4FD8"/><stop offset="1" stop-color="#0B2E8C"/></linearGradient></defs>
<path d="M18 104 L18 64 Q18 44 38 44 L92 44 L92 22 L138 58 L92 94 L92 72 L46 72 L46 104Z" fill="url(#t3b)" transform="translate(4 8)"/>
<path d="M18 104 L18 64 Q18 44 38 44 L92 44 L92 22 L138 58 L92 94 L92 72 L46 72 L46 104Z" fill="url(#t3a)" stroke="#DFFAFF" stroke-width="1.6" stroke-linejoin="round"/></svg>'''

def ar_nav(show_tag=True):
    landmark = ('<div style="position:absolute;left:150px;top:214px;z-index:9;display:flex;flex-direction:column;align-items:flex-start">'
                '<div class="g2" style="border-radius:14px;padding:7px 11px;display:flex;gap:8px;align-items:center">'
                '<div style="width:26px;height:26px;border-radius:8px;background:rgba(255,77,94,.9);display:flex;align-items:center;justify-content:center">' + ic("pin", 15, "#fff") + '</div>'
                '<div><div style="font-size:12.5px;font-weight:700">Kapaleeshwarar Temple</div><div style="font-size:10.5px;color:#9FB0CC">Destination · 450 m</div></div></div>'
                '</div>')
    top = ('<div class="g2" style="position:absolute;left:12px;right:12px;top:44px;border-radius:22px;padding:13px 15px;z-index:12;display:flex;gap:13px;align-items:center">'
           '<div class="aur" style="width:54px;height:54px;border-radius:16px;display:flex;align-items:center;justify-content:center">' + ic("turnright", 32, "#fff", 2.5) + '</div>'
           '<div style="flex:1"><div style="font-size:27px;font-weight:800;line-height:1">80 m</div>'
           '<div style="font-size:14.5px;font-weight:600;margin-top:5px">Turn right after the temple tower</div>'
           '<div style="font-size:11.5px;color:#9FB0CC;margin-top:2px">then 370 m to the main entrance</div></div></div>')
    chips = ('<div style="position:absolute;top:140px;left:12px;right:12px;display:flex;justify-content:space-between;z-index:12">'
             '<div class="chip2 g2" style="height:30px;font-size:11.5px">' + ic("satellite", 14, "#5EEAF5") + 'Geo-anchored · VPS localized</div>'
             '<div class="chip2 chipw g2" style="height:30px;font-size:11.5px">' + ic("compass", 14, "#B4C0D6") + 'N 12°</div></div>')
    hazard = ('<div style="position:absolute;right:12px;top:470px;z-index:12;display:flex;gap:7px;align-items:center;padding:8px 11px;border-radius:13px;'
              'background:rgba(249,168,37,.93);color:#1A1300;font-size:11.5px;font-weight:800;box-shadow:0 8px 18px rgba(0,0,0,.4)">'
              + ic("warning", 15, "#1A1300", 2.3) + 'Two-wheeler ahead</div>')
    mini = ('<div style="position:absolute;left:14px;bottom:182px;width:92px;height:92px;border-radius:24px;overflow:hidden;z-index:12;'
            'box-shadow:0 0 0 2px rgba(255,255,255,.18),0 10px 22px rgba(0,0,0,.5)">'
            + map_svg(route=[(120, 520), (120, 300), (232, 300)], dot=(120, 520), labels=False, vb="40 380 170 170") + '</div>')
    bottom = ('<div class="g2" style="position:absolute;left:12px;right:12px;bottom:26px;border-radius:24px;padding:13px 14px;z-index:12">'
              '<div style="display:flex;align-items:center;gap:10px">'
              '<div style="flex:1"><div style="font-size:21px;font-weight:800">6 min <span style="font-size:15px;color:#B4C0D6;font-weight:600">· 450 m</span></div>'
              '<div style="font-size:12px;color:#8FE3F5;margin-top:2px">Arrive 10:31 · walking</div></div>'
              + orb(46, 21) + '</div>'
              '<div style="display:flex;gap:9px;margin-top:11px">'
              '<div class="sbtn t" style="flex:1;height:44px">' + ic("map", 17, "#E3E9F5") + 'Map</div>'
              '<div class="sbtn t" style="flex:1;height:44px">' + ic("volume", 17, "#E3E9F5") + 'Voice</div>'
              '<div class="sbtn" style="flex:1;height:44px;background:rgba(255,107,107,.16);color:#FF9A9A">' + ic("stop", 15, "#FF9A9A") + 'End</div></div></div>')
    t = tgt("TARGET · M5 + M6 (GEO-ANCHORED) — NOT BUILT", 176) if show_tag else ""
    return street_svg(sign=False) + chevrons() + TURN3D + landmark + top + chips + hazard + mini + bottom + t

def page_ar():
    items = [
        ("road", "Roadmap · M5", "Live camera AR view", "Native ARCore session embedded in Flutter; rendering stays native, Dart sends only the route and markers."),
        ("road", "Roadmap · M6", "Ground chevrons and 3D turn arrow, anchored to the street", "World-anchored with ARCore Geospatial (VPS) only where it localizes; elsewhere M5 shows an approximate overlay and says so."),
        ("road", "Roadmap · M8 + M4", "Landmark-based guidance", "\"Turn right after the temple tower\": the landmark comes from Places candidates in the camera's view, with confidence."),
        ("road", "Roadmap · M7", "Hazard advisory", "On-device detection flags road users; advisory only, never \"safe to cross\"."),
        ("m0", "M0 + Phase 1", "Instruction, distance, remaining time", "The existing navigation engine with M0's corrected distance and ETA; the clock-time arrival is a small addition."),
        ("road", "Roadmap · M5 · M9", "Map switch, voice, AI orb", "Map/AR switching with automatic 2D fallback; spoken cues (M2); one tap to ask the assistant (M9)."),
    ]
    sub = ("The centrepiece of Phase 2: the route painted onto the real street, a 3D turn arrow, the destination and a landmark-based instruction. "
           "None of this exists in the app today — it is the M5/M6 target.")
    return single(ar_nav(), "05", "Advanced live AR navigation", "Advanced Live AR Navigation", sub, items)

PAGES = {
    "screens/01_home_dashboard.png": page_home,
    "screens/02_ai_assistant.png": page_assistant,
    "screens/03_ai_destination_discovery.png": page_discovery,
    "screens/04_intelligent_route_planning.png": page_route,
    "screens/05_advanced_ar_navigation.png": page_ar,
}
