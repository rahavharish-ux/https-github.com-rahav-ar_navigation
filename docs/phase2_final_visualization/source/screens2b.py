"""Phase 2 final-product screens 06-12."""
from kit2 import (ic, phone, map_svg, street_svg, ROUTE, DEST, page2, badge2, legend2,
                  tag, tgt, orb, navbar, fade, FOOT2)
from screens2 import (single, double, home, assistant, route_plan, ar_nav, W3, H3)

# ==========================================================================
# 06 Real-time environmental understanding
# ==========================================================================
def det(x, y, w, h, label, col, lx=-2):
    return (f'<div style="position:absolute;left:{x}px;top:{y}px;width:{w}px;height:{h}px;border:2px solid {col};border-radius:7px;z-index:8;'
            f'box-shadow:0 0 12px {col}55,inset 0 0 12px {col}22"><div style="position:absolute;left:{lx}px;top:-21px;background:{col};color:#04121A;'
            f'font-size:10.5px;font-weight:800;padding:3px 6px;border-radius:6px 6px 6px 0;white-space:nowrap">{label}</div></div>')

def callout(x, y, icon, kind, text, col):
    return (f'<div class="g2" style="position:absolute;left:{x}px;top:{y}px;z-index:9;border-radius:12px;padding:6px 10px 6px 7px;display:flex;gap:7px;align-items:center;'
            f'border-color:{col}66"><div style="width:22px;height:22px;border-radius:7px;background:{col}2A;display:flex;align-items:center;justify-content:center">{ic(icon, 13, col)}</div>'
            f'<div style="line-height:1.15"><div style="font-size:9px;font-weight:800;letter-spacing:.08em;color:{col};text-transform:uppercase">{kind}</div>'
            f'<div style="font-size:11.5px;font-weight:600">{text}</div></div></div>')

def scene():
    path = ('<svg class="fill" viewBox="0 0 390 844" preserveAspectRatio="xMidYMid slice" style="z-index:4">'
            '<path d="M0 844 L44 844 L176 386 L168 386 L0 610Z" fill="#34D399" fill-opacity=".22" stroke="#34D399" stroke-opacity=".7" stroke-width="1.5" stroke-dasharray="5 5"/></svg>')
    head = ('<div style="position:absolute;top:44px;left:12px;right:12px;display:flex;justify-content:space-between;z-index:12">'
            '<div class="chip2 g2" style="height:32px"><span class="dot" style="background:#22D3EE;box-shadow:0 0 8px #22D3EE"></span>Live scene · on-device</div>'
            '<div class="chip2 chipw g2" style="height:32px">' + ic("layers", 15, "#D6DEEE") + 'Layers</div></div>')
    panel = ('<div class="g2" style="position:absolute;left:12px;right:12px;bottom:26px;border-radius:22px;padding:13px 14px;z-index:12">'
             '<div style="display:flex;gap:9px;align-items:center">' + orb(30, 15) +
             '<span style="font-size:12px;font-weight:800;letter-spacing:.08em;color:#8FE3F5;text-transform:uppercase">Scene summary</span></div>'
             '<div style="font-size:13px;line-height:1.45;margin-top:8px;color:#DCE4F5">You are on R.K. Mutt Road facing north. The tower ahead is '
             '<b>Kapaleeshwarar Temple</b>. The footpath on your left is clear; a two-wheeler is in the road.</div>'
             '<div style="display:flex;gap:8px;margin-top:10px;align-items:flex-start">'
             '<div class="bub-u" style="font-size:12.5px;padding:7px 11px;max-width:none;align-self:auto">What is this building?</div></div>'
             '<div class="bub-a" style="font-size:12.5px;padding:8px 11px;margin-top:6px;max-width:none">This appears to be a library <span style="color:#94A2BC">(medium confidence)</span>. Would you like directions?</div></div>')
    return (street_svg() + path +
            det(60, 592, 32, 74, "Pedestrian", "#22D3EE") + det(228, 596, 100, 84, "Car", "#22D3EE") +
            det(146, 466, 52, 44, "Auto-rickshaw", "#22D3EE") + det(204, 428, 28, 32, "Two-wheeler", "#22D3EE", lx=-84) +
            det(246, 428, 130, 70, "Signboard", "#C4B5FD") +
            callout(150, 252, "landmark", "Landmark", "Kapaleeshwarar Temple", "#FBBF24") +
            callout(10, 196, "book", "Building", "Likely a library", "#C4B5FD") +
            callout(250, 504, "text", "Sign read", "மயிலாப்பூர் | R.K. Mutt Rd", "#C4B5FD") +
            callout(6, 528, "walk", "Path", "Footpath · clear", "#34D399") +
            head + panel + tgt("ROADMAP · M7 + M8 — NOT BUILT", 86))

def page_scene():
    items = [
        ("impl", "Exists today", "Single-photo OCR and scene labels", "ML Kit on one captured photo (Diagnostics): Latin text and generic labels. No boxes, no tracking, no Tamil."),
        ("road", "Roadmap · M7", "Live detection: pedestrians, vehicles, two-wheelers", "LiteRT detector with tracking at a bounded rate; COCO-class model under a permissive licence, fine-tuned later for local classes such as auto-rickshaws."),
        ("road", "Roadmap · M8", "Signboards in Tamil and English", "On-device Tamil OCR (PaddleOCR-family vs Tesseract, benchmarked first)."),
        ("road", "Roadmap · M8", "Landmarks and buildings", "Places candidates inside the camera's view, ranked by bearing and distance, always shown with a confidence level."),
        ("road", "Roadmap · M8", "Path understanding", "Low-rate segmentation of road, footpath and crossing. Never used alone to say it is safe to cross."),
        ("road", "Roadmap · M9", "Scene summary and questions", "The assistant summarises the detections in plain language and answers follow-ups."),
    ]
    sub = "The camera understands what is around you — people, vehicles, signs, landmarks and the walkable path — and the assistant explains it in plain language."
    return single(scene(), "06", "Real-time environmental understanding", "Environmental Understanding", sub, items)

# ==========================================================================
# 07 Hybrid localization dashboard
# ==========================================================================
def sensor_row(icon, name, status, level, col="#5BE08A", tagtxt=None):
    bars = "".join(f'<span style="display:inline-block;width:5px;height:{6+i*3}px;border-radius:2px;margin-left:2px;'
                   f'background:{col if i < level else "rgba(255,255,255,.12)"}"></span>' for i in range(5))
    t = f'<span style="font-size:9px;font-weight:800;color:#FCD34D;margin-left:6px">{tagtxt}</span>' if tagtxt else ""
    return (f'<div style="display:flex;align-items:center;gap:11px;padding:6px 0;border-bottom:1px solid rgba(255,255,255,.05)">'
            f'<div style="width:32px;height:32px;border-radius:10px;background:rgba(34,211,238,.08);display:flex;align-items:center;justify-content:center">{ic(icon, 17, "#7FE6F7")}</div>'
            f'<div style="flex:1"><div style="font-size:13.5px;font-weight:600">{name}{t}</div><div style="font-size:11.5px;color:#94A2BC">{status}</div></div>'
            f'<div style="display:flex;align-items:flex-end;height:18px">{bars}</div></div>')

def localization():
    unc = ('<svg class="fill" viewBox="40 380 310 250" preserveAspectRatio="xMidYMid slice" style="z-index:3">'
           '<polyline points="120,620 120,590 121,560 120,530 120,505" fill="none" stroke="#7FE6F7" stroke-width="3" stroke-dasharray="1 6" stroke-linecap="round"/>'
           '<ellipse cx="120" cy="490" rx="15" ry="22" fill="#22D3EE" fill-opacity=".14" stroke="#22D3EE" stroke-opacity=".6" stroke-dasharray="3 3"/></svg>')
    gauge = ('<svg width="96" height="96" viewBox="0 0 100 100"><circle cx="50" cy="50" r="40" fill="none" stroke="rgba(255,255,255,.08)" stroke-width="9"/>'
             '<circle cx="50" cy="50" r="40" fill="none" stroke="url(#gg)" stroke-width="9" stroke-linecap="round" stroke-dasharray="210 252" transform="rotate(-90 50 50)"/>'
             '<defs><linearGradient id="gg"><stop offset="0" stop-color="#2F6BFF"/><stop offset="1" stop-color="#22D3EE"/></linearGradient></defs></svg>')
    spark = ('<svg width="100%" height="64" viewBox="0 0 300 64" preserveAspectRatio="none">'
             '<rect x="118" y="0" width="70" height="64" fill="rgba(251,191,36,.08)"/>'
             '<path d="M0 12 C40 10 80 14 110 16 C130 40 160 52 180 46 C200 20 240 12 300 12" fill="none" stroke="#FBBF24" stroke-width="2.4"/>'
             '<path d="M0 8 C60 8 110 9 130 14 C150 19 170 18 190 12 C230 8 270 8 300 8" fill="none" stroke="#22D3EE" stroke-width="2.8"/></svg>')
    return (
        '<div style="position:absolute;inset:0;background:radial-gradient(500px 360px at 50% 0%,#0F2449,#060A12 70%)"></div>'
        '<div style="position:absolute;top:42px;left:8px;right:12px;height:56px;display:flex;align-items:center;gap:8px;z-index:12">'
        f'<div class="iconbtn">{ic("back", 22, "#E8ECF5")}</div><div style="flex:1;font-size:18px;font-weight:700">Positioning</div>'
        '<div class="chip2" style="height:30px">' + ic("satellite", 14, "#A8F0FB") + 'Fused</div></div>'
        '<div style="position:absolute;top:104px;left:12px;right:12px;height:170px;border-radius:22px;overflow:hidden;box-shadow:inset 0 0 0 1px rgba(255,255,255,.08)">'
        + map_svg(dot=(120, 490), heading=0, labels=False, vb="40 380 310 250") + unc +
        '<div class="chip2 g2" style="position:absolute;left:10px;bottom:10px;height:28px;font-size:11px">GNSS + visual-inertial + steps</div>'
        '<div class="chip2 chipw g2" style="position:absolute;right:10px;top:10px;height:28px;font-size:11px">R.K. Mutt Road · on route</div></div>'
        '<div style="position:absolute;top:286px;left:12px;right:12px;display:flex;gap:10px">'
        '<div class="g2" style="flex:1;border-radius:20px;padding:12px;display:flex;gap:10px;align-items:center">'
        f'<div style="position:relative;width:96px;height:96px">{gauge}<div style="position:absolute;inset:0;display:flex;flex-direction:column;align-items:center;justify-content:center">'
        '<div style="font-size:15px;font-weight:800">High</div><div style="font-size:9.5px;color:#94A2BC">confidence</div></div></div>'
        '<div style="font-size:12px;line-height:1.5;color:#B4C0D6"><div><b style="color:#fff">Position</b> reliable</div><div><b style="color:#fff">Heading</b> NE 34°</div>'
        '<div><b style="color:#fff">Source</b> fused</div></div></div></div>'
        '<div class="g2" style="position:absolute;top:410px;left:12px;right:12px;border-radius:20px;padding:11px 13px">'
        '<div style="display:flex;justify-content:space-between;font-size:11px;font-weight:700;color:#94A2BC"><span>WHEN GPS WEAKENS</span>'
        '<span><span style="color:#FBBF24">━ GNSS</span>&nbsp;&nbsp;<span style="color:#22D3EE">━ Fused</span></span></div>'
        + spark + '<div style="font-size:10.5px;color:#7D8AA5">Illustrative: under trees or a flyover the fused estimate leans on steps and camera tracking.</div></div>'
        '<div class="g2" style="position:absolute;top:530px;left:12px;right:12px;bottom:26px;border-radius:20px;padding:4px 13px;overflow:hidden">'
        + sensor_row("satellite", "GNSS / GPS", "Signal: good", 4)
        + sensor_row("steps", "Accelerometer", "Steps detected", 5)
        + sensor_row("sync", "Gyroscope", "Rotation tracked", 5)
        + sensor_row("compass", "Compass", "Calibrated · NE 34°", 4)
        + sensor_row("eye", "Visual tracking", "ARCore tracking", 5)
        + sensor_row("landmark", "VPS (Geospatial)", "Not available on this street", 0, tagtxt="M6") + '</div>'
        + tgt("ROADMAP · M1 + M4 + M5/M6 — NOT BUILT", 96))

def page_localization():
    items = [
        ("impl", "Exists in Diagnostics", "GPS, compass, accelerometer, gyroscope", "Each sensor already streams and is shown on the Diagnostics screen; GPS has an accuracy filter and smoothing."),
        ("road", "Roadmap · M1", "One timestamped sensor stream", "A native sensor hub with rotation-vector heading and step detection, plus trace recording and replay for testing."),
        ("road", "Roadmap · M4", "Sensor fusion with confidence", "An EKF fusing GNSS with step-based dead reckoning, giving a position, heading and an uncertainty that grows when GPS weakens."),
        ("road", "Roadmap · M5", "Visual-inertial tracking", "ARCore's own visual-inertial odometry adds relative motion during AR sessions."),
        ("road", "Roadmap · M6", "VPS (Geospatial)", "An absolute camera-based fix where Street View coverage allows; shown as unavailable elsewhere."),
        ("prop", "No numbers claimed", "Qualitative confidence only", "Levels and the GPS-weakening chart are illustrations; real accuracy is measured in field tests (M4/M11)."),
    ]
    sub = "See how the app knows where you are: GPS, motion sensors, compass and camera tracking combined into one position with an honest confidence level."
    return single(localization(), "07", "Hybrid localization dashboard", "Hybrid Localization", sub, items)

# ==========================================================================
# 08 Tamil and English voice navigation
# ==========================================================================
def wave_rings(col="#22D3EE"):
    rings = "".join(f'<div style="position:absolute;inset:{-i*18}px;border-radius:50%;border:1.5px solid {col};opacity:{.45-i*.12}"></div>' for i in range(1, 4))
    bars = "".join(f'<span style="display:inline-block;width:5px;height:{h}px;border-radius:3px;background:#fff;margin:0 2.5px"></span>'
                   for h in (14, 26, 40, 30, 46, 24, 36, 18, 28))
    return (f'<div style="position:relative;width:150px;height:150px;margin:0 auto">{rings}'
            f'<div class="orb" style="position:absolute;inset:0;display:flex;align-items:center;justify-content:center">{bars}</div></div>')

def voice(tamil=True):
    if tamil:
        instr = '<span class="tamil">100 மீட்டரில் வலது பக்கம் திரும்பவும்</span>'
        status = '<span class="tamil">கேட்கிறது…</span>'
        said = '<span class="tamil">எனக்கு nearest petrol bunk காட்டு</span>'
        reply = '<span class="tamil">அருகில் 2 petrol bunk-கள் உள்ளன. முதலாவது 450 மீட்டரில்.</span>'
        langs = ('<div class="seg" style="width:210px;margin:0 auto"><div class="on tamil">தமிழ்</div><div>English</div></div>')
        ctrl = [("repeat", '<span class="tamil">மீண்டும்</span>'), ("volume", '<span class="tamil">ஒலி</span>'), ("stop", '<span class="tamil">நிறுத்து</span>')]
    else:
        instr = "In 100 metres, turn right after the temple tower"
        status = "Speaking…"
        said = "Take me to the nearest hospital"
        reply = "Government Hospital is 1.2 km away, about 15 minutes on foot. Shall I start?"
        langs = ('<div class="seg" style="width:210px;margin:0 auto"><div class="tamil">தமிழ்</div><div class="on">English</div></div>')
        ctrl = [("repeat", "Repeat"), ("volume", "Volume"), ("stop", "Stop")]
    ctrls = "".join(f'<div style="display:flex;flex-direction:column;align-items:center;gap:6px;font-size:12px;color:#C9D3E6">'
                    f'<div class="iconbtn g2" style="width:52px;height:52px;border-radius:18px">{ic(i, 21, "#E3E9F5")}</div>{l}</div>' for i, l in ctrl)
    return (
        '<div style="position:absolute;inset:0">' + map_svg(route=ROUTE, dot=(120, 520), dest=DEST, labels=False) + '</div>'
        '<div style="position:absolute;inset:0;background:rgba(6,10,18,.82);backdrop-filter:blur(3px)"></div>'
        '<div class="g2" style="position:absolute;left:12px;right:12px;top:46px;border-radius:20px;padding:12px 14px;z-index:12;display:flex;gap:12px;align-items:center">'
        f'<div class="aur" style="width:46px;height:46px;border-radius:14px;display:flex;align-items:center;justify-content:center">{ic("turnright", 26, "#fff", 2.5)}</div>'
        f'<div style="flex:1;font-size:15px;font-weight:600;line-height:1.35">{instr}</div>{ic("speaker", 20, "#8FE3F5")}</div>'
        f'<div style="position:absolute;top:146px;left:0;right:0">{langs}</div>'
        f'<div style="position:absolute;top:222px;left:0;right:0">{wave_rings()}</div>'
        f'<div style="position:absolute;top:410px;left:0;right:0;text-align:center;font-size:15px;font-weight:700;color:#8FE3F5">{status}</div>'
        '<div style="position:absolute;top:452px;left:18px;right:18px;display:flex;flex-direction:column;gap:10px">'
        f'<div class="bub-u" style="font-size:15px">{said}</div><div class="bub-a" style="font-size:14.5px">{reply}</div></div>'
        f'<div style="position:absolute;left:0;right:0;bottom:34px;display:flex;justify-content:center;gap:34px">{ctrls}</div>'
        + tgt("ROADMAP · M2 + M9 — NOT BUILT", 120))

def page_voice():
    items = [
        ("road", "Roadmap · M2", "Spoken turn-by-turn in Tamil and English", "Guidance cues at set distances through the phone's text-to-speech engine (ta-IN / en-IN), with English fallback if no Tamil voice is installed."),
        ("road", "Roadmap · M2", "Tamil user interface", "Every screen localised; Tamil text reviewed by a native speaker before release."),
        ("road", "Roadmap · M9", "Voice destination search and conversation", "Push-to-talk speech recognition (platform engine, no fee) feeding the assistant, including code-mixed requests."),
        ("road", "Roadmap · M2 + M9", "Hands-free controls", "Repeat, volume and stop by voice or large buttons; the screen stays awake during navigation."),
        ("impl", None, "Instruction text and distances", "The navigation engine already produces the instructions that the voice reads out."),
        ("prop", "Depends on device", "Offline Tamil speech", "Availability of offline Tamil recognition and voices varies by phone; whisper.cpp is the offline candidate."),
    ]
    sub = "Navigate hands-free in Tamil or English: ask by voice, hear every turn spoken, and answer in the language you speak — including Tamil-English mixes."
    return double([voice(True), voice(False)], [("road", "Tamil"), ("road", "English")], "08",
                  "Tamil and English voice navigation", "Voice Navigation · தமிழ் + English", sub, items)

# ==========================================================================
# 09 Intelligent rerouting
# ==========================================================================
def reroute():
    newr = [(190, 534), (190, 300), (232, 300), (232, 262)]
    over = ('<svg class="fill" viewBox="0 140 390 640" preserveAspectRatio="xMidYMid slice" style="z-index:3">'
            '<polyline points="120,560 150,549 190,534" fill="none" stroke="#FF6B6B" stroke-width="3.5" stroke-dasharray="4 6" stroke-linecap="round"/>'
            '<polyline points="190,534 255,510 255,300 232,300 232,262" fill="none" stroke="#A78BFA" stroke-width="4" stroke-dasharray="2 8" stroke-linecap="round" stroke-linejoin="round"/></svg>')
    note = ('<div class="g2" style="position:absolute;left:12px;right:12px;top:46px;border-radius:22px;padding:14px;z-index:12">'
            '<div style="display:flex;gap:12px;align-items:center">'
            '<div class="aur" style="width:46px;height:46px;border-radius:14px;display:flex;align-items:center;justify-content:center">' + ic("sync", 24, "#fff", 2.3) + '</div>'
            '<div style="flex:1"><div style="font-size:16px;font-weight:800">Route updated</div>'
            '<div style="font-size:12.5px;color:#B4C0D6;margin-top:2px">You turned onto Kutchery Road. New route is 1 min longer.</div></div></div>'
            '<div style="display:flex;gap:8px;margin-top:10px"><span class="chip2" style="height:28px">' + ic("speaker", 14, "#A8F0FB") + '"Rerouting. Turn left in 230 metres."</span></div></div>')
    sheet = ('<div style="position:absolute;left:0;right:0;bottom:0;height:300px;border-radius:28px 28px 0 0;background:#080C16;border-top:1px solid rgba(255,255,255,.07);padding:16px 14px 30px;z-index:12">'
             '<div style="display:flex;align-items:baseline;gap:10px"><span style="font-size:24px;font-weight:800">8 min</span><span style="color:#B4C0D6;font-weight:600">· 650 m</span>'
             '<span style="flex:1"></span><span style="font-size:12.5px;color:#8FE3F5;font-weight:600">Arrive 10:33</span></div>'
             '<div class="h2t" style="margin-top:12px;font-size:11px">Other ways from here</div>'
             '<div style="display:flex;flex-direction:column;gap:9px;margin-top:9px">'
             '<div style="border-radius:15px;padding:11px 12px;display:flex;gap:11px;align-items:center;box-shadow:inset 0 0 0 1.5px #3D7BFF;background:rgba(255,255,255,.04)">'
             '<div style="width:5px;height:34px;border-radius:3px;background:#3D7BFF"></div><div style="flex:1"><div style="font-size:14px;font-weight:700">Continue from here <span style="color:#7FE6F7;font-size:11.5px">· recommended</span></div>'
             '<div style="font-size:11.5px;color:#94A2BC">Shortest from your position · 1 major-road crossing</div></div><b>8 min</b></div>'
             '<div style="position:relative;border-radius:15px;padding:11px 12px;display:flex;gap:11px;align-items:center;background:rgba(255,255,255,.03)">'
             '<div style="width:5px;height:34px;border-radius:3px;background:#A78BFA"></div><div style="flex:1"><div style="font-size:14px;font-weight:700">Quieter streets</div>'
             '<div style="font-size:11.5px;color:#94A2BC">No major-road crossings</div></div><b>10 min</b>' + tag("road", "M3+", "right:10px;top:-8px") + '</div></div>'
             '<div style="display:flex;gap:9px;margin-top:12px"><div class="sbtn t" style="flex:1;height:44px">' + ic("ar", 16, "#E3E9F5") + 'AR view</div>'
             '<div class="sbtn" style="flex:1;height:44px;background:rgba(255,107,107,.16);color:#FF9A9A">' + ic("stop", 14, "#FF9A9A") + 'End</div></div></div>')
    return (map_svg(route=newr, old_route=[(120, 560), (120, 300), (190, 300)], traveled=[(120, 690), (120, 560)], dot=(190, 534), heading=10, dest=DEST, dot_scale=1.15, vb="0 140 390 640")
            + over + note + sheet + tgt("ROADMAP · M2 VOICE · M3 ALTERNATIVES", 196))

def page_reroute():
    items = [
        ("impl", None, "Deviation detection", "Over 40 m from the route, or moving away from the next turn on 2 consecutive real movements."),
        ("m0", None, "Reliable automatic rerouting", "A new route from your newest position; it never restarts a stopped session, overwrites a new one or undoes a pause."),
        ("road", "Roadmap · M2", "Voice notification", "\"Rerouting. Turn left in 230 metres.\" spoken in the chosen language."),
        ("road", "Roadmap · M3+", "Alternatives from where you are", "Pedestrian options ranked by time and major-road crossings, each with its reason."),
        ("road", "Roadmap · M9", "Ask why", "The assistant can explain the choice using the same ranking reasons."),
        ("prop", "Small addition", "Clock-time arrival", "\"Arrive 10:33\" — today the app shows remaining duration only."),
    ]
    sub = "Leave the route and the app notices, says so out loud, picks the best way from where you actually are and shows the alternatives with honest reasons."
    from screens2 import single as _s
    return _s(reroute(), "09", "Intelligent rerouting", "Intelligent Rerouting", sub, items)

# ==========================================================================
# 10 Offline navigation (proposed)
# ==========================================================================
def offline():
    def region(name, sub, ok=True):
        st = ('<span class="chip2" style="height:26px;font-size:11px;background:rgba(91,224,138,.1);color:#7BE6A5;border-color:rgba(91,224,138,.3)">Downloaded</span>'
              if ok else '<span class="chip2 chipw" style="height:26px;font-size:11px">Update</span>')
        return (f'<div style="display:flex;gap:12px;align-items:center;padding:11px 0;border-bottom:1px solid rgba(255,255,255,.05)">'
                f'<div style="width:62px;height:46px;border-radius:12px;overflow:hidden;position:relative;flex:none">{map_svg(dot=None, labels=False, vb="0 200 390 290")}</div>'
                f'<div style="flex:1"><div style="font-size:14px;font-weight:700">{name}</div><div style="font-size:11.5px;color:#94A2BC">{sub}</div></div>{st}</div>')
    def line(ok, text):
        icn, col = ("check", "#5BE08A") if ok else ("wifioff", "#FCA5A5")
        return f'<div style="display:flex;gap:9px;align-items:center;font-size:12.5px;padding:4px 0">{ic(icn, 16, col, 2.4)}<span>{text}</span></div>'
    return (
        '<div style="position:absolute;inset:0;background:#070B14"></div>'
        '<div style="position:absolute;top:42px;left:8px;right:12px;height:56px;display:flex;align-items:center;gap:8px;z-index:12">'
        f'<div class="iconbtn">{ic("back", 22, "#E8ECF5")}</div><div style="flex:1;font-size:18px;font-weight:700">Offline maps</div></div>'
        '<div style="position:absolute;top:102px;left:12px;right:12px;border-radius:18px;padding:12px 14px;display:flex;gap:11px;align-items:center;'
        'background:rgba(249,168,37,.12);border:1px solid rgba(249,168,37,.35)">' + ic("wifioff", 22, "#FCD34D") +
        '<div><div style="font-size:14px;font-weight:700;color:#FDE68A">You\'re offline</div><div style="font-size:12px;color:#E5D3A0">GPS active · your position still updates</div></div></div>'
        '<div class="g2" style="position:absolute;top:178px;left:12px;right:12px;border-radius:20px;padding:4px 14px">'
        + region("Chennai · Mylapore &amp; Santhome", "Map, places, saved routes · updated 2 days ago")
        + region("Madurai · Temple area", "Map and places · updated 3 weeks ago", False) +
        '<div style="display:flex;align-items:center;justify-content:center;gap:8px;height:46px;color:#7FE6F7;font-weight:700;font-size:13.5px">' + ic("download", 18, "#7FE6F7") + 'Download an area</div></div>'
        '<div class="g2" style="position:absolute;top:404px;left:12px;right:12px;border-radius:20px;padding:12px 14px">'
        '<div class="h2t" style="font-size:11px">Works offline</div>'
        + line(True, "Map of downloaded areas") + line(True, "GPS + sensor positioning") + line(True, "Saved places and cached routes")
        + line(True, "Turn-by-turn on a cached route") + line(True, "On-device assistant (basic)") +
        '<div class="h2t" style="font-size:11px;margin-top:8px">Needs a connection</div>'
        + line(False, "New routes and live place search") + line(False, "Hosted AI features, if enabled") + '</div>'
        '<div class="g2" style="position:absolute;top:706px;left:12px;right:12px;border-radius:18px;padding:11px 14px;display:flex;gap:10px;align-items:center">'
        + ic("sync", 19, "#8FE3F5") + '<div style="font-size:12.5px;line-height:1.35"><b>3 changes</b> will sync when you\'re back online</div></div>'
        + tgt("PROPOSED · NOT IN ROADMAP YET", 94))

def page_offline():
    items = [
        ("prop", None, "Downloadable map regions", "Not in the approved roadmap. Google Maps tiles cannot be stored for offline use under its terms, so offline maps would need an OpenStreetMap-based tile source."),
        ("prop", None, "Cached routes, places and sync", "Cache recent routes and saved places locally; queue changes and sync when online (fits the M10 local-first store)."),
        ("impl", None, "GPS positioning without internet", "GPS works without a data connection already; the app's filters run on the device."),
        ("road", "Roadmap · M9", "On-device assistant", "The planned open model on the device keeps basic answers available offline; hosted features clearly show as unavailable."),
        ("road", "Roadmap · M3 (server)", "Offline-capable routing backend", "A self-hosted routing engine is planned later; on-phone routing would be a further step."),
        ("prop", "Honest status", "Clear online/offline labelling", "Online-only features are listed separately instead of failing silently."),
    ]
    sub = "Keep navigating without mobile data: downloaded areas, GPS positioning and cached routes keep working, and the app is clear about what needs a connection."
    from screens2 import single as _s
    return _s(offline(), "10", "Offline navigation", "Offline & Resilient Navigation", sub, items)

# ==========================================================================
# 11 Safety and emergency assistance (proposed)
# ==========================================================================
def safety():
    def fac(icon, col, name, sub, dist):
        return (f'<div style="display:flex;gap:11px;align-items:center;padding:9px 0;border-bottom:1px solid rgba(255,255,255,.05)">'
                f'<div style="width:36px;height:36px;border-radius:11px;background:{col}22;display:flex;align-items:center;justify-content:center">{ic(icon, 18, col)}</div>'
                f'<div style="flex:1"><div style="font-size:13.5px;font-weight:700">{name}</div><div style="font-size:11.5px;color:#94A2BC">{sub}</div></div>'
                f'<b style="font-size:13px">{dist}</b><div class="iconbtn" style="width:34px;height:34px;margin-left:4px;background:rgba(255,255,255,.05)">{ic("recenter", 15, "#8FE3F5")}</div></div>')
    return (
        '<div style="position:absolute;inset:0;background:radial-gradient(420px 320px at 50% 18%,#2A0F1A,#070B14 70%)"></div>'
        '<div style="position:absolute;top:42px;left:8px;right:12px;height:56px;display:flex;align-items:center;gap:8px;z-index:12">'
        f'<div class="iconbtn">{ic("back", 22, "#E8ECF5")}</div><div style="flex:1;font-size:18px;font-weight:700">Safety</div>'
        f'{ic("settings", 20, "#9AA6BF")}</div>'
        '<div style="position:absolute;top:104px;left:0;right:0;text-align:center">'
        '<div style="width:132px;height:132px;margin:0 auto;border-radius:50%;padding:10px;background:rgba(255,77,94,.12);box-shadow:0 0 0 10px rgba(255,77,94,.06)">'
        '<div style="width:100%;height:100%;border-radius:50%;background:radial-gradient(circle at 35% 30%,#FF8A95,#E11D48 60%,#9F1239);display:flex;align-items:center;justify-content:center;'
        'font-size:30px;font-weight:900;letter-spacing:.06em;box-shadow:0 12px 30px rgba(225,29,72,.5)">SOS</div></div>'
        '<div style="font-size:13.5px;font-weight:700;margin-top:12px">Hold 3 s to call 112</div>'
        '<div style="font-size:11.5px;color:#94A2BC;margin-top:3px">Uses your phone\'s dialer — not connected to any emergency service</div></div>'
        '<div class="g2" style="position:absolute;top:338px;left:12px;right:12px;border-radius:18px;padding:11px 14px;display:flex;gap:11px;align-items:center">'
        + ic("share", 19, "#8FE3F5") + '<div style="flex:1"><div style="font-size:13.5px;font-weight:700">Share live location</div>'
        '<div style="font-size:11.5px;color:#94A2BC">Sends a link through your messaging app</div></div>'
        '<div style="width:44px;height:26px;border-radius:13px;background:#22B8EE;position:relative"><div style="position:absolute;right:3px;top:3px;width:20px;height:20px;border-radius:50%;background:#fff"></div></div></div>'
        '<div style="position:absolute;top:412px;left:12px;right:12px;display:flex;gap:10px;align-items:center">'
        '<span class="h2t" style="font-size:11px">Emergency contacts</span><span style="flex:1"></span>'
        '<span class="chip2 chipw" style="height:30px">' + ic("phone", 14, "#D6DEEE") + 'Amma</span><span class="chip2 chipw" style="height:30px">' + ic("phone", 14, "#D6DEEE") + 'Appa</span>'
        '<span class="chip2" style="height:30px;padding:0 9px">' + ic("cross", 14, "#A8F0FB") + '</span></div>'
        '<div class="g2" style="position:absolute;top:456px;left:12px;right:12px;border-radius:20px;padding:4px 14px">'
        + fac("hospital", "#FF8A8A", "Government Hospital", "Royapettah · open 24 hours", "1.2 km")
        + fac("police", "#7FB2FF", "Police station", "Mylapore", "600 m")
        + fac("cross", "#5BE08A", "Pharmacy", "Luz Church Road", "300 m") + '</div>'
        '<div style="position:absolute;top:664px;left:12px;right:12px;border-radius:18px;padding:11px 13px;display:flex;gap:10px;align-items:flex-start;'
        'background:rgba(249,168,37,.1);border:1px solid rgba(249,168,37,.3)">' + ic("warning", 19, "#FCD34D", 2.2) +
        '<div><div style="font-size:13px;font-weight:700;color:#FDE68A">Broken footpath reported ahead</div>'
        '<div style="font-size:11.5px;color:#E5D3A0">Community report · 2 people · consider the other side</div></div></div>'
        + navbar("home") + tgt("PROPOSED · NOT IN ROADMAP YET", 94))

def page_safety():
    items = [
        ("prop", None, "SOS through the phone's dialer", "Holding SOS opens a call to 112 using the device's own dialer. No emergency-service integration exists or is implied."),
        ("prop", None, "Share live location", "A link shared through the user's messaging app; needs a small backend for live updates and clear consent."),
        ("prop", None, "Emergency contacts", "Stored on the device; one-tap call or message."),
        ("prop", "Uses existing search", "Nearby hospitals, police, pharmacies", "Google Places search already in the app; opening hours shown only when Places provides them."),
        ("road", "Roadmap · M10 (data)", "Safety alerts from observations", "Confirmed community reports (e.g. a broken footpath) from the planned geospatial observation store."),
        ("road", "Roadmap · M7", "Live hazard advisories", "On-device detection during navigation; advisory, never a safety guarantee."),
    ]
    sub = "Help when it matters: one-hold SOS through your phone, live location sharing, emergency contacts, the nearest hospitals and police, and alerts about the route ahead."
    from screens2 import single as _s
    return _s(safety(), "11", "Safety and emergency assistance", "Safety & Emergency Assistance", sub, items)

# ==========================================================================
# 12 Complete product showcase
# ==========================================================================
def page_showcase():
    W, H = 2560, 1250
    shots = [(assistant(), "AI assistant", "road", "M9"),
             (route_plan(), "Pedestrian route planning", "road", "M3+"),
             (scene(), "Scene understanding", "road", "M7 · M8"),
             (ar_nav(False), "Advanced live AR", "road", "M5 · M6"),
             (localization(), "Hybrid localization", "road", "M1 · M4 · M6"),
             (voice(True), "Tamil + English voice", "road", "M2 · M9"),
             (reroute(), "Automatic rerouting", "m0", "Phase 1 + M0 · voice M2"),
             (safety(), "Offline & safety", "prop", "Proposed")]
    sc = [0.56, 0.56, 0.6, 0.72, 0.6, 0.56, 0.56, 0.56]
    gap = 26
    widths = [414 * s for s in sc]
    x = (W - sum(widths) - gap * 7) / 2
    out = []
    for (inner, cap, k, bt), s, w in zip(shots, sc, widths):
        hgt = 868 * s
        y = 320 + (868 * 0.72 - hgt) / 2
        out.append(phone(inner, x, y, s))
        out.append(f'<div style="position:absolute;left:{x - 20}px;top:{320 + 868*0.72 + 26}px;width:{w + 40}px;text-align:center">'
                   f'<div style="font-size:19px;font-weight:700;color:#EEF2FA">{cap}</div><div style="margin-top:8px">{badge2(k, bt)}</div></div>')
        x += w + gap
    glow = ('<div style="position:absolute;left:50%;top:440px;width:1900px;height:700px;margin-left:-950px;border-radius:50%;'
            'background:radial-gradient(closest-side,rgba(34,211,238,.20),rgba(47,107,255,.10) 50%,rgba(47,107,255,0));filter:blur(8px)"></div>')
    head = ('<div style="position:absolute;left:0;right:0;top:70px;text-align:center">'
            '<div style="font-size:15px;font-weight:800;letter-spacing:.3em;color:#5EE6F5">PHASE 2 · TARGET PRODUCT</div>'
            '<div style="font-family:\'Inter Display\',Inter;font-size:56px;font-weight:800;letter-spacing:-.01em;margin-top:16px;color:#F4F6FB;line-height:1.1">'
            'AI-Powered Autonomous Outdoor Navigation</div>'
            '<div style="font-size:23px;color:#B4C0D6;margin-top:14px">using Multimodal Intelligence, Visual-Inertial Localization and Context-Aware Augmented Reality</div>'
            '<div style="display:inline-flex;gap:12px;margin-top:26px;align-items:center;font-size:16px;color:#8D99B2">'
            '<span class="chip2" style="height:34px;font-size:14px">TN AR Navigation</span><span>Android · Flutter &amp; Dart · Tamil + English</span></div></div>')
    foot = (legend2(W / 2 - 520, H - 96) +
            f'<div class="foot" style="left:{W/2-760}px;top:{H-52}px;width:1520px;text-align:center">Target-product concept at the end of Phase 2. '
            'Only Phase 1 features and milestone M0 exist today; everything tagged roadmap or proposed is not built. Camera and map imagery are illustrations.</div>')
    return page2(glow + head + "".join(out) + foot, W, H)

PAGES = {
    "screens/06_scene_understanding.png": page_scene,
    "screens/07_hybrid_localization.png": page_localization,
    "screens/08_voice_navigation.png": page_voice,
    "screens/09_intelligent_rerouting.png": page_reroute,
    "screens/10_offline_navigation.png": page_offline,
    "screens/11_safety_assistance.png": page_safety,
    "screens/12_complete_product_showcase.png": page_showcase,
}
