"""User-journey flowchart and system-architecture diagram (from the real code)."""
from kit import page, badge, legend, nav_logo

STYLE = """
.box{position:absolute;border-radius:16px;padding:12px 14px;background:#121A2A;border:1.5px solid #2E3B57;box-shadow:0 10px 26px rgba(0,0,0,.35)}
.box .n{font-size:11px;font-weight:800;letter-spacing:.1em;color:#6B7891}
.box .t{font-size:16px;font-weight:700;color:#EEF2FA;margin-top:3px;line-height:1.25}
.box .s{font-size:12px;color:#9AA6BF;margin-top:4px;line-height:1.35}
.k-impl{border-color:rgba(91,224,138,.55)} .k-impl .n{color:#5BE08A}
.k-m0{border-color:rgba(103,232,249,.6)} .k-m0 .n{color:#67E8F9}
.k-plan{border:1.5px dashed rgba(252,211,77,.85);background:#1A1A16} .k-plan .n{color:#FCD34D}
.k-trig{border-color:rgba(255,138,138,.6);background:#1E1418} .k-trig .n{color:#FF8A8A}
.sect{position:absolute;font-size:13px;font-weight:800;letter-spacing:.16em;text-transform:uppercase;color:#7FA6FF}
.alabel{position:absolute;font-size:11.5px;font-weight:700;color:#9AA6BF;background:#0B0F18;padding:2px 7px;border-radius:6px;white-space:nowrap}
.band{position:absolute;left:60px;right:60px;border-radius:22px;background:rgba(255,255,255,.025);border:1px solid rgba(255,255,255,.06);padding:16px 18px 16px 250px}
.band .bl{position:absolute;left:20px;top:16px;width:210px}
.band .bl .h{font-size:17px;font-weight:800;color:#EEF2FA}
.band .bl .p{font-size:12px;color:#8D99B2;margin-top:4px;line-height:1.4;font-family:'JetBrains Mono',monospace}
.chips{display:flex;flex-wrap:wrap;gap:8px}
.chip{border-radius:10px;padding:7px 11px;font-size:12.5px;font-weight:600;background:#162036;border:1px solid #2C3A58;color:#DCE4F5;line-height:1.25}
.chip small{display:block;font-size:10.5px;font-weight:500;color:#8D99B2;font-family:'JetBrains Mono',monospace;margin-top:1px}
.chip.m0{border-color:rgba(103,232,249,.6);background:#10222A}
.chip.plan{border:1px dashed rgba(252,211,77,.8);background:#1A1A14;color:#F5E2A8}
"""

KIND = {"impl": ("k-impl", "IMPLEMENTED"), "m0": ("k-m0", "IMPLEMENTED · M0"),
        "plan": ("k-plan", "PLANNED"), "trig": ("k-trig", "TRIGGER")}

def box(x, y, w, h, title, sub="", kind="impl", n=None):
    cls, default = KIND[kind]
    return (f'<div class="box {cls}" style="left:{x}px;top:{y}px;width:{w}px;height:{h}px">'
            f'<div class="n">{n or default}</div><div class="t">{title}</div>'
            + (f'<div class="s">{sub}</div>' if sub else "") + '</div>')

def arrows(paths, w, h):
    out = [f'<svg style="position:absolute;left:0;top:0;width:{w}px;height:{h}px;overflow:visible" viewBox="0 0 {w} {h}">',
           '<defs><marker id="ah" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse">'
           '<path d="M0 0L10 5L0 10z" fill="#7FA6FF"/></marker>'
           '<marker id="ahp" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse">'
           '<path d="M0 0L10 5L0 10z" fill="#FCD34D"/></marker></defs>']
    for pts, planned, both in paths:
        d = "M" + " L".join(f"{x} {y}" for x, y in pts)
        col, mk = ("#FCD34D", "ahp") if planned else ("#7FA6FF", "ah")
        dash = ' stroke-dasharray="7 6"' if planned else ""
        start = f' marker-start="url(#{mk})"' if both else ""
        out.append(f'<path d="{d}" fill="none" stroke="{col}" stroke-width="2.4"{dash} stroke-linejoin="round" marker-end="url(#{mk})"{start}/>')
    out.append('</svg>')
    return "".join(out)

def header(title, sub, w):
    return (f'<div style="position:absolute;left:60px;top:36px;display:flex;gap:16px;align-items:center">'
            f'<div class="logo" style="width:52px;height:52px;border-radius:16px">{nav_logo(28)}</div>'
            f'<div><div style="font-family:\'Inter Display\',Inter;font-size:36px;font-weight:800;color:#F4F6FB">{title}</div>'
            f'<div style="font-size:15px;color:#9AA6BF;margin-top:4px">{sub}</div></div></div>')

# ==========================================================================
def page_journey():
    W, H = 2200, 1480
    B = []
    bw, bh = 270, 104
    xs = [60, 375, 690, 1005, 1320, 1635]
    yA = 190
    main = [("Open app", "Android launcher", "impl", "1 · IMPLEMENTED"),
            ("Splash &amp; onboarding", "2 s splash; 3-page onboarding (currently shown on every launch)", "impl", "2 · IMPLEMENTED"),
            ("Home dashboard", "Map, live GPS position, search card", "impl", "3 · IMPLEMENTED"),
            ("Search destination", "Google Places, debounced; stale results dropped (M0)", "m0", "4 · IMPLEMENTED · M0"),
            ("Select destination", "Pin on map; needs a GPS fix to continue", "impl", "5 · IMPLEMENTED"),
            ("Preview route", "OSRM route, distance, time · driving (walking: M3)", "impl", "6 · IMPLEMENTED")]
    for x, (t, s, k, n) in zip(xs, main):
        B.append(box(x, yA, bw, bh, t, s, k, n))
    yB = 400
    B.append(box(1635, yB, bw, bh, "Start navigation", "Turn-by-turn session begins", "impl", "7 · IMPLEMENTED"))
    B.append(box(1320, yB, bw, bh, "AR available?", "ARCore + camera + heading. Today: always no — AR not built", "plan", "8 · DECISION · M5"))
    B.append(box(1005, yB - 90, bw, bh, "Camera-based AR guidance", "Approximate overlay (GPS + compass)", "plan", "9a · PLANNED · M5"))
    B.append(box(1005, yB + 90, bw, bh, "2D map navigation", "Instruction card, distance, ETA", "impl", "9b · IMPLEMENTED"))
    B.append(box(690, yB, bw, bh, "Real-time guidance", "Every GPS fix: progress, next turn, remaining distance/ETA", "m0", "10 · IMPLEMENTED · M0"))
    B.append(box(375, yB, bw, bh, "Route deviation detection", "&gt;40 m off route, or 2× wrong direction", "impl", "11 · IMPLEMENTED"))
    B.append(box(60, yB, bw, bh, "Rerouting", "New OSRM route; respects pause/stop (M0)", "m0", "12 · IMPLEMENTED · M0"))
    B.append(box(690, yB + 200, bw, bh, "Destination reached", "Within 25 m → \"You've arrived\"", "impl", "13 · IMPLEMENTED"))

    cy = lambda y: y + bh // 2
    P = []
    for i in range(5):
        P.append(([(xs[i] + bw, cy(yA)), (xs[i + 1] - 4, cy(yA))], False, False))
    P.append(([(1635 + bw // 2, yA + bh), (1635 + bw // 2, yB - 4)], False, False))
    P.append(([(1635, cy(yB)), (1320 + bw + 4, cy(yB))], False, False))
    P.append(([(1320, cy(yB)), (1300, cy(yB)), (1300, cy(yB - 90)), (1005 + bw + 4, cy(yB - 90))], True, False))
    P.append(([(1320, cy(yB)), (1300, cy(yB)), (1300, cy(yB + 90)), (1005 + bw + 4, cy(yB + 90))], False, False))
    P.append(([(1005 + bw // 2, yB - 90 + bh + 4), (1005 + bw // 2, yB + 90 - 4)], True, True))   # switch AR <-> 2D
    P.append(([(1005, cy(yB - 90)), (985, cy(yB - 90)), (985, cy(yB)), (690 + bw + 4, cy(yB))], True, False))
    P.append(([(1005, cy(yB + 90)), (985, cy(yB + 90)), (985, cy(yB)), (690 + bw + 4, cy(yB))], False, False))
    P.append(([(690, cy(yB)), (375 + bw + 4, cy(yB))], False, False))
    P.append(([(375, cy(yB)), (60 + bw + 4, cy(yB))], False, False))
    P.append(([(60 + bw // 2, yB), (60 + bw // 2, yB - 40), (690 + bw // 2 - 30, yB - 40), (690 + bw // 2 - 30, yB - 4)], False, False))
    P.append(([(690 + bw // 2, yB + bh), (690 + bw // 2, yB + 200 - 4)], False, False))
    labels = [('<div class="alabel" style="left:1140px;top:439px">Map ⇄ AR view (M5)</div>'),
              ('<div class="alabel" style="left:300px;top:349px">continue on the new route</div>'),
              ('<div class="alabel" style="left:1258px;top:392px">yes</div>'),
              ('<div class="alabel" style="left:1262px;top:472px">no</div>'),
              ('<div class="alabel" style="left:840px;top:548px">arrived</div>')]

    # ---- alternative paths ----
    yS = 760
    B.append(f'<div class="sect" style="left:60px;top:{yS}px">Alternative paths</div>')
    cw, ch = 380, 104
    cxs = [60, 480, 900, 1320, 1740]
    alt = [
        [("Camera permission denied", "From an AR / camera screen", "trig"),
         ("Clear message + Try again", "No crash, no raw error text", "impl"),
         ("Continue on 2D map", "AR session falls back with the reason shown", "plan")],
        [("Camera unavailable", "Device reports no usable camera", "trig"),
         ("Honest \"no camera\" message", "Rest of the app keeps working", "impl"),
         ("2D map navigation", "Automatic fallback from AR", "plan")],
        [("Heading unavailable", "No compass reading", "trig"),
         ("Detected (CompassUnavailable)", "Shown on Diagnostics today", "impl"),
         ("AR offers 2D map instead", "Fallback sheet with reason", "plan")],
        [("User switches to 2D map", "Taps Map in the AR view", "trig"),
         ("Same session continues on map", "Route and progress unchanged", "plan"),
         ("Return to AR view", "When AR is available again", "plan")],
        [("GPS unavailable or inaccurate", "Location off, denied, or weak signal", "trig"),
         ("Enable / Open Settings prompt", "Weak-signal flag after 3 rejected fixes", "impl"),
         ("Route needs a GPS fix", "\"Get your location first…\"", "impl")],
    ]
    names = {"trig": "TRIGGER", "impl": "IMPLEMENTED", "plan": "PLANNED · M5"}
    for cx, chain in zip(cxs, alt):
        for r, (t, s, k) in enumerate(chain):
            y = yS + 50 + r * 150
            n = names[k]
            if cx == 1740 and r == 0:
                n = "TRIGGER"
            B.append(box(cx, y, cw, ch, t, s, k, n))
            if r:
                P.append(([(cx + cw // 2, y - 46), (cx + cw // 2, y - 4)], k == "plan", False))
    # GPS column: planned M4 dead-reckoning note
    B.append(box(1740, yS + 50 + 3 * 150, cw, ch, "Short GPS gaps bridged", "Step-based dead reckoning with growing uncertainty", "plan", "PLANNED · M4"))
    P.append(([(1740 + cw // 2, yS + 50 + 2 * 150 + ch), (1740 + cw // 2, yS + 50 + 3 * 150 - 4)], True, False))

    body = (header("User Journey", "TN AR NAV · solid = implemented transition · dashed amber = planned (Phase 2 roadmap)", W) +
            legend(W - 960, 62) +
            arrows(P, W, H) + "".join(B) + "".join(labels) +
            f'<div class="foot" style="left:60px;top:{H-46}px;width:1300px">Derived from the app\'s screens and providers (lib/features, lib/core/providers) and PHASE2_ROADMAP.md. '
            'Box 8 and everything dashed do not exist in the app yet; today navigation always runs on the 2D map.</div>')
    return page(f"<style>{STYLE}</style>" + body, W, H)

# ==========================================================================
def chips(items):
    out = []
    for it in items:
        name, sub, kind = (it + ("impl",))[:3] if len(it) == 2 else it
        cls = {"impl": "", "m0": "m0", "plan": "plan"}[kind]
        out.append(f'<div class="chip {cls}">{name}<small>{sub}</small></div>')
    return '<div class="chips">' + "".join(out) + '</div>'

def page_architecture():
    W, H = 2200, 1130
    bands = [
        ("Presentation", "lib/features/**\nlib/widgets/**", [
            ("Splash · Onboarding", "features/splash, onboarding"), ("Home", "home_screen.dart"), ("Search", "search_screen.dart"),
            ("Route preview", "route_preview_screen.dart"), ("2D navigation", "navigation_screen.dart"), ("Saved places", "saved_places_screen.dart"),
            ("Auth · Account", "auth_screen, account_screen"), ("Camera preview", "camera_preview_screen.dart"), ("Computer vision", "vision_screen.dart"),
            ("Diagnostics", "diagnostics_screen.dart"), ("StatusMessage · CameraLifecycleBinding", "widgets/common · M0", "m0"),
            ("AR navigation screen", "M5", "plan"), ("Language & voice settings", "M2", "plan"), ("Assistant (voice)", "M9", "plan")]),
        ("State (Riverpod 3)", "lib/core/providers/**\nfeatures/*/providers", [
            ("locationProvider", "filter · smoothing · weak signal"), ("compassProvider", "flutter_compass"), ("motionSensorProvider", "accel · gyro"),
            ("cameraProvider", "lifecycle-aware · M0", "m0"), ("visionProvider", "OCR · labels"), ("arAvailabilityProvider", "ARCore check"),
            ("routeProvider", "route preview"), ("routingServiceProvider", "injectable · M0", "m0"), ("navigationProvider", "session generation · reroute guard · M0", "m0"),
            ("searchProvider", "debounce · stale-guard · M0", "m0"), ("authProvider", "Supabase session"), ("savedPlacesProvider", "list · save · remove"),
            ("destination · travelMode · mapFollow", "UI state"),
            ("NavigationSessionController · CapabilityManager", "tiers T0–T3 · M5", "plan"), ("GuidanceEngine", "voice cues · M2", "plan")]),
        ("Domain logic (pure Dart)", "lib/core/utils/**\nlib/models/**", [
            ("geo_math", "haversine · polyline distance · bearing"), ("location_filter · position_smoothing", "accuracy gate · EMA"),
            ("speed_bucket · heading_fusion", "adaptive GPS rate · GPS/compass pick"), ("camera_selection · ar_availability", "pure mappers"),
            ("camera_lifecycle · camera_capture", "M0", "m0"), ("vision_mapping", "ML Kit → app models"),
            ("Models", "AppLocation · Place · AppRoute · NavigationInstruction · SavedPlace …"),
            ("LocalizationEngine (EKF + PDR) · map matcher", "M4", "plan"), ("HazardRules · LandmarkResolver", "M7 · M8", "plan")]),
        ("Services &amp; bridges", "lib/services/**\nlib/core/map/**", [
            ("LocationService", "geolocator"), ("CompassService", "flutter_compass"), ("MotionSensorService", "sensors_plus"),
            ("CameraService", "camera"), ("VisionService", "google_mlkit_text_recognition · image_labeling"), ("GeocodingService", "http → Places API (New)"),
            ("RoutingService", "http → OSRM (driving)"), ("AuthService · SavedPlacesService", "supabase_flutter"),
            ("ArPlatformService", "MethodChannel"), ("AppMapController · AppMapView", "google_maps_flutter"),
            ("SensorHub · trace record/replay", "M1", "plan"), ("RoutingProvider · OpenRouteService foot", "M3", "plan"),
            ("ArSessionBridge", "M5 · M6", "plan"), ("PerceptionBridge", "M7", "plan"), ("LlmProvider (open model first)", "M9", "plan"),
            ("ObservationRepository", "M10", "plan")]),
        ("Android native", "android/app/src/main/kotlin", [
            ("MainActivity.kt", "ARCore availability channel"), ("Plugin natives", "CameraX · fused location · ML Kit · Maps SDK"),
            ("SensorStreamer.kt", "M1", "plan"), ("ArSessionManager · ArRenderView", "ARCore session + renderer · M5/M6", "plan"),
            ("InferenceEngine (LiteRT)", "detector · OCR · segmentation · M7/M8", "plan")]),
        ("External services", "network", [
            ("Google Maps SDK", "map tiles"), ("Places API (New)", "text search"), ("OSRM public demo", "driving routes — dev only"),
            ("Supabase", "Auth · Postgres saved_places · RLS"), ("Google Play Services for AR", "availability"),
            ("OpenRouteService", "foot-walking · M3", "plan"), ("ARCore Geospatial (VPS)", "M6 · cost to be presented", "plan"),
            ("PostGIS on Supabase", "observations · M10", "plan"), ("Hosted LLM via proxy", "optional · only after cost approval", "plan")]),
    ]
    y = 140
    parts = []
    heights = [124, 124, 124, 124, 80, 80]
    for (name, path, items), h in zip(bands, heights):
        parts.append(f'<div class="band" style="top:{y}px;height:{h}px"><div class="bl"><div class="h">{name}</div>'
                     f'<div class="p">{path.replace(chr(10), "<br>")}</div></div>{chips(items)}</div>')
        parts.append(f'<div style="position:absolute;left:140px;top:{y + h + 2}px;width:2px;height:20px;background:#3D7BFF"></div>'
                     f'<div style="position:absolute;left:135px;top:{y + h + 16}px;width:0;height:0;border-left:6px solid transparent;border-right:6px solid transparent;border-top:8px solid #3D7BFF"></div>')
        y += h + 28
    qa = ('<div class="band" style="top:' + str(y) + 'px;height:84px"><div class="bl"><div class="h">Quality</div><div class="p">test/** · .github/workflows</div></div>'
          + chips([("261 automated tests", "unit · widget · fakes for routing/camera · M0", "m0"),
                   ("GitHub Actions CI", "format · analyze · test · debug + release APK · M0", "m0"),
                   ("Flutter 3.38.4 pinned", ".fvmrc · M0", "m0"), ("Device checklist", "docs/field-tests · pending", "m0")]) + '</div>')
    body = (header("System Architecture", "As built in the repository (solid) and as planned in PHASE2_ARCHITECTURE.md (dashed amber) · arrows point from caller to dependency", W) +
            legend(W - 960, 62) +
            "".join(parts) + qa +
            f'<div class="foot" style="left:60px;top:{H-40}px;width:1800px">Chip subtitles name the real file, package or milestone. '
            'Layering rule kept from Phase 1: screens → providers → services; only AppMapView/AppMapController import google_maps_flutter.</div>')
    return page(f"<style>{STYLE}</style>" + body, W, H)

PAGES = {
    "diagrams/user_journey_flowchart.png": page_journey,
    "diagrams/system_architecture.png": page_architecture,
}
