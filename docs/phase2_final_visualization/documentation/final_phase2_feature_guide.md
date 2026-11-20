# Final Phase 2 Feature Guide

How the finished Phase 2 product is intended to work, screen by screen.
Status per feature is in `implementation_status.md`; legend:
🟢 Phase 1 · 🔵 M0 done · 🟠 roadmap (not built) · 🟣 proposed (not in roadmap).

---

## 01 · Intelligent home (`screens/01_home_dashboard.png`)
- **What:** an AI-first start screen with a live map, the fused position,
  an "Ask or say where to go…" bar, suggestion chips, quick actions (AR,
  Nearby, Offline maps, Safety), nearby places and saved places.
- **Interaction:** tap the bar to type, the mic to speak, the camera to ask
  about what you see; tap the centre AI orb from anywhere.
- **How it works:** the bar opens the assistant (M9); the position chip
  reflects the fused estimate's confidence (M4); map, search and saved
  places are the existing Phase 1 features.
- **Status:** 🟢 map/search/saved · 🟠 assistant, voice, Tamil, fused chip, AR · 🟣 nearby, offline, safety.

## 02 · Multimodal AI assistant (`02_ai_assistant.png`)
- **What:** a conversation that turns requests into navigation.
  "Take me to the nearest hospital" → a hospital card (1.2 km) with
  **Start in AR / Map**. "எனக்கு nearest petrol bunk காட்டு" → an answer in
  Tamil listing two petrol bunks.
- **How it works:** speech → text (phone's recogniser, ta-IN / en-IN) →
  `AgentOrchestrator` → `LlmProvider` (open-weight model on the device or
  self-hosted first) → **tool calls** into the app (`search_places`,
  `plan_route`, `where_am_i`, `whats_ahead`, `read_sign`) → answer + cards
  → optional speech. The small `⚙ search_places` chips show which tools ran.
- **Safety rules:** navigation starts only after you confirm; turn and
  safety instructions always come from the deterministic navigation
  engine, never from the model; camera images stay on the device unless
  you choose otherwise.
- **Status:** 🟠 M9 (+ M2). Hosted models 🟣, only after cost approval.

## 03 · AI destination discovery (`03_ai_destination_discovery.png`)
- **What:** describe what you want ("quiet place to sit near the beach");
  the app shows how it understood you (park · quiet · near Marina Beach ·
  walking), then suggestions with the reasons they match, nearby
  landmarks and recent searches.
- **How:** the assistant converts the sentence into a structured search;
  results come from Places; landmarks from Places Nearby (M8).
- **Honesty:** reasons only repeat what was matched — no invented reviews
  or crowd levels.

## 04 · Intelligent route planning (`04_intelligent_route_planning.png`)
- **What:** three walking options: **Fastest** (14 min · 2 major-road
  crossings), **Safer · fewer crossings** (16 min · 1 crossing), and
  **Step-free** (17 min · avoids mapped steps).
- **How:** OpenRouteService foot-walking (M3) returns alternatives; the
  RoutePlanner scores them by time, major-road crossings and main-road
  exposure from OpenStreetMap road classes (M3+), later penalising
  confirmed hazards (M10).
- **Honesty:** "safer" means fewer major-road crossings, nothing more. The
  screen states that no live traffic, crime or lighting data is used.
  Step-free depends on OSM tagging (🟣).

## 05 · Advanced live AR navigation (`05_advanced_ar_navigation.png`) — centrepiece
- **What:** the camera view of a real street with glowing chevrons painted
  along the lane, a 3D turn arrow at the junction, the destination pinned
  above the temple tower, a landmark-based instruction ("Turn right after
  the temple tower"), a hazard advisory, heading, a mini-map, remaining
  time and arrival, and Map / Voice / End controls with the AI orb.
- **How:** an ARCore session in a native Android view (M5). Where ARCore
  Geospatial (VPS) localizes, content is **geo-anchored** to the street (M6);
  elsewhere M5 shows an approximate, clearly labelled overlay placed from
  the fused position and heading. Tracking loss drops to the 2D map.
- **Status:** 🟠 M5/M6/M7/M8; instruction and ETA logic 🔵 exist today.

## 06 · Environmental understanding (`06_scene_understanding.png`)
- **What:** live labels on the camera view (pedestrian, car, auto-rickshaw,
  two-wheeler, signboard, landmark, building, clear footpath), the sign read
  in Tamil and English, and a plain-language scene summary. "What is this
  building?" → "This appears to be a library (medium confidence)."
- **How:** frames from ARCore/CameraX → LiteRT models on the phone:
  detector (M7), Tamil+English OCR and footpath segmentation (M8) →
  tracker, hazard rules, landmark resolver → assistant summary (M9).
- **Today:** only single-photo Latin OCR and generic labels (🟢).

## 07 · Hybrid localization (`07_hybrid_localization.png`)
- **What:** where you are and how sure the app is: a map with the
  uncertainty area, a qualitative confidence ring, the sensor list (GNSS,
  accelerometer, gyroscope, compass, visual tracking, VPS) and an
  illustrative chart of the fused estimate staying steady while GPS
  weakens.
- **How:** SensorHub (M1) → EKF fusing GNSS with step-based dead reckoning
  (M4) → plus ARCore visual-inertial motion (M5) and VPS fixes (M6).
- **Honesty:** no accuracy numbers are shown or claimed.

## 08 · Voice navigation in Tamil and English (`08_voice_navigation.png`)
- **What:** listening and speaking states side by side: the spoken
  instruction ("100 மீட்டரில் வலது பக்கம் திரும்பவும்" / "In 100 metres,
  turn right after the temple tower"), the recognised request, the reply,
  a language switch and hands-free controls (மீண்டும் / ஒலி / நிறுத்து).
- **How:** platform speech recognition and text-to-speech (M2, M9);
  English fallback when no Tamil voice is installed.

## 09 · Intelligent rerouting (`09_intelligent_rerouting.png`)
- **What:** "Route updated — you turned onto Kutchery Road", the spoken
  cue, the new time and arrival, and alternatives from your position with
  reasons.
- **How:** deviation detection and safe automatic rerouting exist today
  (🟢/🔵); voice (M2), ranked alternatives (M3+) and explanations (M9) are added.

## 10 · Offline navigation (`10_offline_navigation.png`) 🟣
- **What:** downloaded areas, an offline banner (GPS still works), a clear
  list of what works offline and what needs a connection, and pending sync.
- **Note:** requires an OpenStreetMap-based tile source, because Google
  Maps tiles may not be stored for offline use.

## 11 · Safety and emergency assistance (`11_safety_assistance.png`) 🟣
- **What:** a hold-to-call SOS that uses the phone's own dialer (112) —
  explicitly **not connected to any emergency service** — live location
  sharing through the user's messaging app, emergency contacts, nearby
  hospitals/police/pharmacies, and a community-reported route alert (M10 data).

## 12 · Product showcase (`12_complete_product_showcase.png`)
Eight phones — assistant, route planning, scene understanding, AR (centre),
localization, voice, rerouting, safety — each labelled with its status.

## System visualizations (`architecture/`)
| File | Shows |
|---|---|
| `phase2_system_architecture.png` | Six layers, every module tagged |
| `ai_assistant_architecture.png` | Input → understand → on-device tools → respond |
| `hybrid_localization.png` | Sensors → hub → EKF fusion → pose → consumers |
| `scene_understanding_pipeline.png` | Frames → pre-process → LiteRT models → post-process → outputs |
| `navigation_workflow.png` | Ask → understand → discover → plan → guide → monitor → recover → arrive |
| `visual_inertial_workflow.png` | ARCore VIO, alignment, VPS, anchoring, fallbacks |
| `route_planning_workflow.png` | Providers, candidates, explainable scoring |
| `voice_interaction_workflow.png` | Speak → recognise → interpret → act → speak back |
| `user_journey_flowchart.png` | Discovery to arrival with fallbacks |
