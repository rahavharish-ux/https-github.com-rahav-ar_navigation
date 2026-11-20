"""Phase 2 system visualizations: architecture + 8 workflows (status-tagged)."""
from kit2 import page2, legend2, nav_logo

STY = """
.col{position:absolute;display:flex;flex-direction:column;justify-content:center;gap:12px}
.st{position:absolute;font-size:12.5px;font-weight:800;letter-spacing:.14em;text-transform:uppercase;color:#5EE6F5;text-align:center}
.bx{border-radius:14px;padding:11px 13px;background:#0F1729;border:1.5px solid #2B3A57;box-shadow:0 8px 22px rgba(0,0,0,.35)}
.bx .t{font-size:15px;font-weight:700;color:#EEF2FA;line-height:1.25}
.bx .s{font-size:12px;color:#9AA6BF;margin-top:3px;line-height:1.35}
.bx .k{display:inline-block;font-size:9.5px;font-weight:800;letter-spacing:.08em;padding:2px 6px;border-radius:5px;margin-bottom:5px}
.k-impl{border-color:rgba(91,224,138,.6)} .k-impl .k{background:rgba(91,224,138,.15);color:#7BE6A5}
.k-m0{border-color:rgba(103,232,249,.65)} .k-m0 .k{background:rgba(103,232,249,.14);color:#8CEFFB}
.k-road{border:1.5px dashed rgba(252,211,77,.8);background:#14140F} .k-road .k{background:rgba(252,211,77,.14);color:#FCD34D}
.k-prop{border:1.5px dashed rgba(196,181,253,.85);background:#141127} .k-prop .k{background:rgba(196,181,253,.14);color:#D8CCFF}
.note{display:inline-flex;align-items:center;gap:8px;font-size:13px;color:#C9D3E6;background:rgba(255,255,255,.04);border:1px solid rgba(255,255,255,.08);
  padding:8px 13px;border-radius:999px;margin:0 8px 8px 0}
.band2{position:absolute;left:60px;right:60px;border-radius:20px;background:rgba(255,255,255,.025);border:1px solid rgba(255,255,255,.06);padding:14px 16px 14px 250px}
.band2 .bl{position:absolute;left:20px;top:14px;width:215px}
.band2 .bl .h{font-size:17px;font-weight:800;color:#EEF2FA}
.band2 .bl .p{font-size:12px;color:#8D99B2;margin-top:4px;line-height:1.4}
.cz{display:flex;flex-wrap:wrap;gap:8px}
.cp{border-radius:10px;padding:7px 11px;font-size:12.5px;font-weight:600;line-height:1.25;color:#DCE4F5}
.cp small{display:block;font-size:10.5px;font-weight:500;color:#8D99B2;font-family:'JetBrains Mono',monospace;margin-top:1px}
.cp.impl{background:#10231A;border:1px solid rgba(91,224,138,.5)}
.cp.m0{background:#0E2329;border:1px solid rgba(103,232,249,.55)}
.cp.road{background:#17160F;border:1px dashed rgba(252,211,77,.75)}
.cp.prop{background:#161229;border:1px dashed rgba(196,181,253,.8)}
"""

TAG = {"impl": "PHASE 1", "m0": "M0", "road": "ROADMAP", "prop": "PROPOSED"}

def header(title, sub):
    return (f'<div style="position:absolute;left:60px;top:36px;display:flex;gap:16px;align-items:center">'
            f'<div class="logo" style="width:52px;height:52px;border-radius:16px">{nav_logo(28)}</div>'
            f'<div><div style="font-family:\'Inter Display\',Inter;font-size:36px;font-weight:800;color:#F4F6FB">{title}</div>'
            f'<div style="font-size:15px;color:#9AA6BF;margin-top:4px">{sub}</div></div></div>')

def box(t, s, k, tg=None):
    return (f'<div class="bx k-{k}"><div class="k">{tg or TAG[k]}</div><div class="t">{t}</div>'
            + (f'<div class="s">{s}</div>' if s else "") + '</div>')

def pipeline(title, sub, stages, notes=(), W=2200, colH=470, top=150):
    n = len(stages)
    gap = 56
    cw = (W - 120 - gap * (n - 1)) / n
    out = [header(title, sub), legend2(W - 1010, 62)]
    arrows = [f'<svg style="position:absolute;left:0;top:0;width:{W}px;height:{top+colH+60}px;overflow:visible">'
              '<defs><marker id="m" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="8" markerHeight="8" orient="auto">'
              '<path d="M0 0L10 5L0 10z" fill="#5EE6F5"/></marker></defs>']
    for i, (st, boxes) in enumerate(stages):
        x = 60 + i * (cw + gap)
        out.append(f'<div class="st" style="left:{x}px;top:{top}px;width:{cw}px">{st}</div>')
        out.append(f'<div class="col" style="left:{x}px;top:{top + 34}px;width:{cw}px;height:{colH}px">'
                   + "".join(box(*b) for b in boxes) + '</div>')
        if i < n - 1:
            y = top + 34 + colH / 2
            arrows.append(f'<path d="M{x + cw + 8} {y} L{x + cw + gap - 8} {y}" stroke="#5EE6F5" stroke-width="2.6" marker-end="url(#m)"/>')
    arrows.append('</svg>')
    H = top + 34 + colH + 40 + (70 if notes else 0) + 60
    if notes:
        out.append(f'<div style="position:absolute;left:60px;right:60px;top:{top + 34 + colH + 30}px">'
                   + "".join(f'<span class="note">{n_}</span>' for n_ in notes) + '</div>')
    out.append(f'<div class="foot" style="left:60px;top:{H - 44}px;width:{W-120}px">Phase 2 target design from PHASE2_ARCHITECTURE.md and PHASE2_ROADMAP.md. '
               'Dashed boxes are not built; "proposed" items are not yet in the approved roadmap.</div>')
    return page2(f"<style>{STY}</style>" + "".join(arrows) + "".join(out), W, H)

# ---------------------------------------------------------------- 1. system
def system_architecture():
    W, H = 2200, 940
    bands = [
        ("Experience", "Flutter screens", [
            ("Intelligent home", "", "road"), ("AI assistant", "M9", "road"), ("AI discovery", "M9 · M8", "road"), ("Route planning", "M3", "road"),
            ("Live AR navigation", "M5 · M6", "road"), ("Scene understanding", "M7 · M8", "road"), ("Positioning", "M1 · M4", "road"),
            ("Voice ta/en", "M2 · M9", "road"), ("2D navigation · rerouting", "Phase 1 + M0", "m0"), ("Search · saved places · auth", "Phase 1", "impl"),
            ("Offline maps", "proposed", "prop"), ("Safety centre", "proposed", "prop")]),
        ("Orchestration", "Riverpod controllers", [
            ("NavigationSessionController", "tiers T0–T3 · fallback · M5", "road"), ("CapabilityManager", "AR / VPS / camera / model checks · M5", "road"),
            ("GuidanceEngine", "visual + spoken cues · M2", "road"), ("AgentOrchestrator", "tools · confirm-before-act · M9", "road"),
            ("NavigationNotifier", "session guard · reroute · M0", "m0")]),
        ("Intelligence", "pure Dart, testable", [
            ("LocalizationEngine", "EKF · PDR · map matching · M4", "road"), ("RoutePlanner", "rank by time · crossings · hazards · M3+", "road"),
            ("HazardRules · TrackStore", "M7", "road"), ("LandmarkResolver", "Places in camera view · M8", "road"),
            ("LlmProvider", "open model first · provider-independent · M9", "road"), ("SpeechIO", "STT / TTS ta-IN en-IN · M2/M9", "road"),
            ("ObservationRepository", "local-first · M10", "road"), ("Filters · smoothing · geo math", "Phase 1", "impl")]),
        ("Platform bridges", "channels + services", [
            ("SensorHub", "timestamped · trace replay · M1", "road"), ("ArSessionBridge", "pose · anchors · M5/M6", "road"),
            ("PerceptionBridge", "detections · M7", "road"), ("RoutingProvider", "ORS foot · OSRM driving · M3", "road"),
            ("Location · Places · Supabase · Maps", "Phase 1 services", "impl"), ("routingServiceProvider", "injectable · M0", "m0")]),
        ("Android native", "Kotlin", [
            ("SensorStreamer", "rotation vector · steps · M1", "road"), ("ArSessionManager + renderer", "ARCore · Geospatial · M5/M6", "road"),
            ("FrameSource + InferenceEngine", "LiteRT GPU · M7/M8", "road"), ("MainActivity", "ARCore availability · Phase 1", "impl")]),
        ("Services &amp; data", "network", [
            ("OpenRouteService", "foot-walking · M3", "road"), ("OSRM", "driving · Phase 1", "impl"), ("Google Places · Maps", "Phase 1", "impl"),
            ("ARCore Geospatial (VPS)", "cost to be presented · M6", "road"), ("Supabase", "auth · saved places · Phase 1", "impl"),
            ("PostGIS observations", "M10", "road"), ("Hosted LLM via proxy", "only after cost approval", "prop"), ("Offline tile source", "OSM-based · proposed", "prop")]),
    ]
    out = [header("Phase 2 System Architecture", "Complete target architecture — status per module"), legend2(W - 1010, 62)]
    y = 140
    for name, p, chips in bands:
        h = 84 if len(chips) <= 8 else 118
        out.append(f'<div class="band2" style="top:{y}px;min-height:{h}px"><div class="bl"><div class="h">{name}</div><div class="p">{p}</div></div>'
                   '<div class="cz">' + "".join(f'<div class="cp {k}">{t}<small>{s}</small></div>' for t, s, k in chips) + '</div></div>')
        y += h + 22
    out.append(f'<div class="foot" style="left:60px;top:{H-44}px;width:{W-120}px">Layering kept from Phase 1: screens → controllers → pure logic → bridges → native/services. '
               'Heavy pixels (camera, AR rendering, inference) stay native; only small typed messages reach Dart.</div>')
    return page2(f"<style>{STY}</style>" + "".join(out), W, H)

# ---------------------------------------------------------------- workflows
def ai_assistant():
    return pipeline("Multimodal AI Assistant Architecture", "Provider-independent, open model first, tools run on the device", [
        ("Input", [("Text", "Tamil, English, code-mixed", "road", "M9"), ("Voice", "push-to-talk · platform STT ta-IN / en-IN", "road", "M9"),
                   ("Camera frame", "only after an explicit tap", "road", "M9")]),
        ("Understand", [("Intent fallback", "rules for core commands; works with no model", "road", "M9"),
                        ("AgentOrchestrator", "conversation state · tool loop", "road", "M9"),
                        ("LlmProvider", "on-device open model → self-hosted → hosted via proxy (cost-gated)", "road", "M9")]),
        ("Tools on device", [("search_places", "existing Places search", "impl"), ("plan_route", "RoutePlanner · M3", "road", "M3"),
                             ("where_am_i", "fused pose · M4", "road", "M4"), ("whats_ahead · read_sign", "perception · M7/M8", "road", "M7 · M8"),
                             ("start_navigation", "only after user confirms", "road", "M9")]),
        ("Respond", [("Answer + action cards", "places, routes, buttons", "road", "M9"), ("Speech output", "TTS ta / en · English fallback", "road", "M2"),
                     ("Navigation stays deterministic", "the model never issues turn or safety instructions", "road", "RULE")]),
    ], notes=["Images stay on the device by default", "Offline: on-device model + intent fallback keep working",
              "No paid API without a presented cost", "Answers come from app tools, not model memory"])

def localization():
    return pipeline("Hybrid Localization", "GNSS + inertial + compass + camera fused into one pose with uncertainty", [
        ("Sensors", [("GNSS fixes", "geolocator · filtered", "impl"), ("Accelerometer · gyroscope", "today: Diagnostics only", "impl"),
                     ("Rotation-vector heading", "native · M1", "road", "M1"), ("Camera VIO", "ARCore tracking · M5", "road", "M5"),
                     ("VPS earth pose", "ARCore Geospatial · M6", "road", "M6")]),
        ("Acquisition", [("SensorHub", "one monotonic clock · batched channel", "road", "M1"), ("Trace record / replay", "real walks become tests", "road", "M1")]),
        ("Fusion", [("Step detection + stride (PDR)", "", "road", "M4"), ("EKF predict / update", "GNSS weighted by reported accuracy", "road", "M4"),
                    ("Outlier gating", "rejects jumps", "road", "M4"), ("VIO deltas · earth pose", "high-weight measurements", "road", "M5 · M6")]),
        ("Output", [("PoseEstimate", "position · heading · uncertainty · source", "road", "M4"), ("Route progress", "along-track / cross-track", "road", "M4"),
                    ("Capability tier T0–T3", "degrades visibly", "road", "M5")]),
        ("Consumers", [("Navigation engine", "today: smoothed GPS", "m0"), ("AR placement", "M5 / M6", "road", "M5 · M6"),
                       ("Assistant where_am_i", "M9", "road", "M9"), ("Positioning dashboard", "screen 07", "road", "M1 · M4")]),
    ], notes=["GNSS-only remains the fallback estimator", "Fused output used only after replayed traces show it is no worse than GNSS",
              "Called \"GNSS + pedestrian dead reckoning\" — not GPS-denied navigation"])

def scene():
    return pipeline("Real-Time Scene Understanding Pipeline", "On-device perception from camera frame to guidance", [
        ("Frames", [("ARCore CPU image", "during AR sessions · M5", "road", "M5"), ("CameraX frames", "when AR is off", "road", "M7"),
                    ("Single still photo", "ML Kit OCR + labels today", "impl")]),
        ("Pre-process", [("Resize · rotate · ROI", "", "road", "M7"), ("Rate governor", "≤ 10 Hz, drops frames when busy", "road", "M7")]),
        ("Models · LiteRT", [("Object detector", "Apache-2.0 COCO model · GPU delegate", "road", "M7"), ("Tamil + English OCR", "benchmarked candidates", "road", "M8"),
                             ("Road / footpath segmentation", "low rate", "road", "M8")]),
        ("Post-process", [("NMS + IoU tracker", "", "road", "M7"), ("HazardRules", "approaching / proximity", "road", "M7"),
                          ("LandmarkResolver", "Places in camera view + OCR match", "road", "M8")]),
        ("Outputs", [("AR markers", "", "road", "M5"), ("Spoken advisories", "advisory only", "road", "M2 · M7"),
                     ("Assistant scene summary", "", "road", "M9"), ("Observations", "opt-in · M10", "road", "M10")]),
    ], notes=["Frames never cross the Flutter channel — only detections do", "Never says \"safe to cross\"",
              "Landmarks always shown with confidence", "Cloud vision not planned (owner decision)"])

def navigation():
    return pipeline("AI-Powered Navigation Workflow", "From a spoken request to arrival", [
        ("Ask", [("Voice · text · camera", "Tamil or English", "road", "M9")]),
        ("Understand", [("Assistant", "intent + entities", "road", "M9")]),
        ("Discover", [("Places + landmarks", "Places search today · Nearby M8", "impl", "PHASE 1 + M8")]),
        ("Plan", [("RoutePlanner", "walking alternatives with reasons", "road", "M3")]),
        ("Guide", [("AR or 2D map", "AR M5/M6 · 2D today", "m0", "M0 + M5"), ("Spoken cues", "M2", "road", "M2")]),
        ("Monitor", [("Fused pose · hazards", "M4 · M7", "road", "M4 · M7"), ("Deviation detection", "today", "impl")]),
        ("Recover", [("Automatic reroute", "safe vs stop/pause · M0", "m0")]),
        ("Arrive", [("Arrival", "within 25 m today", "impl")]),
    ], W=2400, colH=300, notes=["Solid boxes work today", "Each stage degrades to the Phase 1 behaviour if its Phase 2 module is unavailable"])

def vio():
    return pipeline("Visual-Inertial Localization Workflow", "How AR content gets positioned, and what happens when it can't", [
        ("Inputs", [("Camera frames", "ARCore session", "road", "M5"), ("IMU", "accelerometer + gyroscope", "road", "M5"),
                    ("GNSS + compass", "existing sensors", "impl")]),
        ("Tracking", [("ARCore VIO", "feature tracking + IMU", "road", "M5"), ("Local 6DoF pose", "session frame", "road", "M5"),
                      ("Tracking lost?", "→ 2D map fallback", "road", "M5")]),
        ("Alignment", [("Session → local ENU", "using fused heading/position", "road", "M4 · M5"), ("Approximate mode", "labelled \"approximate\"", "road", "M5")]),
        ("Global fix", [("VPS available?", "checkVpsAvailability", "road", "M6"), ("Earth pose", "accepted only above set thresholds", "road", "M6")]),
        ("Rendering", [("Geospatial anchors", "route chevrons · destination", "road", "M6"), ("Native renderer", "ARCore + Filament/SceneView", "road", "M5")]),
    ], notes=["\"6DoF geo-anchored AR\" claimed only where measured", "VPS availability and accuracy surveyed in the target city first (M6)"])

def routes():
    return pipeline("Context-Aware Route Planning", "Pedestrian alternatives ranked with explainable criteria", [
        ("Request", [("Destination + mode", "", "impl"), ("Preferences", "fewer crossings · step-free", "road", "M3+")]),
        ("Providers", [("OpenRouteService foot", "first walking provider", "road", "M3"), ("OSRM driving", "existing", "impl"),
                       ("Google Routes WALK / self-hosted", "later, replaceable", "road", "LATER")]),
        ("Candidates", [("Alternative routes", "geometry + steps + road types", "road", "M3")]),
        ("Scoring", [("Time · distance", "", "road", "M3"), ("Major-road crossings · exposure", "from OSM road classes", "road", "M3+"),
                     ("Hazard layer", "confirmed observations", "road", "M10"), ("Mapped steps", "step-free option", "prop")]),
        ("Explain + choose", [("Route cards with reasons", "", "road", "M3"), ("Assistant explains", "", "road", "M9")]),
        ("Navigate", [("AR / 2D guidance", "", "m0", "M0 + M5")]),
    ], notes=["No live traffic, crime or lighting data — none is specified", "Accessibility depends on OpenStreetMap tagging"])

def voice():
    return pipeline("Tamil / English Voice Interaction", "Conversation and spoken guidance", [
        ("Speak", [("Push-to-talk", "hands-free controls", "road", "M9"), ("Language", "தமிழ் / English / mixed", "road", "M2")]),
        ("Recognise", [("Platform STT", "ta-IN / en-IN · no fee", "road", "M9"), ("Offline candidate", "whisper.cpp · to benchmark", "road", "M9 CANDIDATE")]),
        ("Interpret", [("Transcript", "code-mixed text", "road", "M9"), ("Intent fallback → assistant", "", "road", "M9")]),
        ("Act", [("Tool call", "search · route · where am I", "road", "M9"), ("Confirm", "before starting navigation", "road", "M9")]),
        ("Speak back", [("TTS", "Tamil voice if installed, else English", "road", "M2"), ("Guidance cues", "200 m · 50 m · at turn", "road", "M2")]),
    ], notes=["Tamil voice availability depends on the phone's speech engines", "Tamil UI reviewed by a native speaker"])

def journey():
    return pipeline("Complete User Journey", "From destination discovery to arrival, with fallbacks", [
        ("Open", [("Intelligent home", "", "road", "M2 · M9")]),
        ("Ask / search", [("Assistant or search", "voice, text, camera", "road", "M9"), ("Classic search", "today", "m0")]),
        ("Choose route", [("Walking alternatives", "", "road", "M3")]),
        ("Navigate", [("Live AR", "M5 / M6", "road", "M5 · M6"), ("2D map", "today · fallback", "m0")]),
        ("Understand", [("Scene + hazards", "", "road", "M7 · M8"), ("Positioning", "fused", "road", "M4")]),
        ("Recover", [("Reroute + voice", "", "m0", "M0 + M2")]),
        ("Arrive", [("Destination reached", "", "impl")]),
    ], W=2400, colH=300, notes=["No camera / heading / ARCore → 2D map (M5)", "GPS weak → fused estimate with growing uncertainty (M4)",
                                "No internet → offline areas (proposed)", "Emergency → safety centre (proposed)"])

PAGES = {
    "architecture/phase2_system_architecture.png": system_architecture,
    "architecture/ai_assistant_architecture.png": ai_assistant,
    "architecture/hybrid_localization.png": localization,
    "architecture/scene_understanding_pipeline.png": scene,
    "architecture/navigation_workflow.png": navigation,
    "architecture/visual_inertial_workflow.png": vio,
    "architecture/route_planning_workflow.png": routes,
    "architecture/voice_interaction_workflow.png": voice,
    "architecture/user_journey_flowchart.png": journey,
}
