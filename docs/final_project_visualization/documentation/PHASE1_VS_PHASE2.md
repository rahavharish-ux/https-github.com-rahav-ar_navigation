# Phase 1 vs Phase 2

"Phase 1" is everything built before Phase 2 (the project's original
17-step roadmap). "Phase 2" is the approved plan in `PHASE2_ROADMAP.md`.
**Of Phase 2, only M0 is implemented**; every other row in the Phase 2
column is planned, not built.

| Area | Phase 1 (implemented) | Phase 2 — done (M0) | Phase 2 — planned (not built) |
|---|---|---|---|
| **Positioning** | GPS with accuracy filter, smoothing, speed-adaptive sampling, weak-signal flag | Navigation always uses the newest fix after a pause or reroute | Timestamped sensor hub + trace replay (M1); GNSS + step-based dead reckoning with uncertainty and route progress (M4) |
| **Heading** | Compass and IMU streams; GPS-vs-compass pick — Diagnostics only | — | Rotation-vector heading in fusion (M1/M4); compass used for AR guidance (M5) |
| **Routing** | Driving routes via OSRM public demo | Routing service injectable (tests, future providers) | Walking via OpenRouteService behind `RoutingProvider` (M3); pedestrian preferences and hazard-aware ranking later |
| **Navigation** | Turn-by-turn on the map, off-route + wrong-direction rerouting, pause/resume/stop, arrival | Correct remaining distance/ETA; reroute can't restart a stopped session, overwrite a new one, or undo a pause; no parallel reroutes | Voice guidance in Tamil and English (M2); capability tiers with automatic fallback (M5) |
| **AR** | ARCore availability check; plain camera preview (Diagnostics) | — | Camera-based guidance with approximate alignment (M5); geo-anchored arrows via ARCore Geospatial where measured to work (M6) |
| **Computer vision** | Single-photo Latin OCR and scene labels, on-device (Diagnostics) | Capture interrupted by backgrounding no longer crashes | Live object detection + hazard advisories (M7); Tamil OCR, landmark recognition, walkable-surface segmentation (M8) |
| **Camera** | Permission flow, unavailable/denied states | Released on background, reopened on resume; late-initialised camera released after Stop/dispose/background | Frames shared with ARCore during AR (M5/M7) |
| **Search** | Google Places, Tamil Nadu bias, debounce, recents (session) | Stale responses discarded | Places Nearby as landmark candidates (M8) |
| **Account & places** | Supabase email auth; saved places with Row Level Security | — | Geospatial observation store with PostGIS, opt-in sharing (M10) |
| **AI assistant** | — | — | Push-to-talk assistant, provider-independent, open model first, rule-based fallback for core commands (M9) |
| **Language** | English UI (strings centralised) | — | Tamil + English UI (M2) |
| **Edge AI** | ML Kit's bundled models | — | LiteRT runtime with GPU delegate, quantised models, per-device benchmarks (M7, M11) |
| **Quality** | 224 tests; manual device verification | 261 tests (2 flaky tests fixed, 37 added), 75.1 % coverage, Flutter pinned to 3.38.4, GitHub Actions CI with debug + release APK builds | Trace-replay regression tests (M1); field-test campaigns and battery/thermal budgets (M11) |

## Owner decisions that shape Phase 2

1. Flutter stays on 3.38.4.
2. Walking routes: OpenRouteService first; provider stays replaceable.
3. Detection models: Apache-2.0 or other permissive licences; no AGPL
   without approval.
4. Vision on-device first; cloud vision optional, not planned.
5. AI: free/open-source first, provider-independent; no paid API without
   presenting its cost.

## Claims policy (unchanged)

Until a milestone's device measurements exist, the project must not claim
SLAM, GPS-denied navigation, 6DoF geo-anchored AR, real-time landmark
recognition or detection accuracy figures. The visualization follows this:
the AR screen is labelled as a concept with **approximate** alignment.
