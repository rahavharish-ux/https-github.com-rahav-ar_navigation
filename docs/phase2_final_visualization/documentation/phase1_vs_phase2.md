# Phase 1 vs Phase 2 (target)

| Dimension | Phase 1 (built) | Phase 2 target (end of roadmap) |
|---|---|---|
| **Product character** | Conventional map navigator with diagnostics | AI-first, camera-centred pedestrian navigator |
| **Start screen** | Map, search card, travel modes, disabled AR button | Ask/speak/point bar, fused-position status, AR / nearby / offline / safety actions, AI orb |
| **Interaction** | Touch only, English only | Touch, voice, camera; Tamil, English and code-mixed |
| **Search** | Google Places text search, session recents | Natural-language discovery with explained suggestions and landmarks |
| **Routing** | Driving only (OSRM demo) | Walking alternatives (OpenRouteService) ranked by time and crossings; step-free option proposed |
| **Guidance** | 2D map, visual instructions | Live AR (approximate → geo-anchored where VPS works), 2D fallback, spoken cues |
| **Positioning** | Filtered + smoothed GPS | GNSS + step-based dead reckoning + visual-inertial + VPS, with honest confidence |
| **Vision** | One photo: Latin OCR, generic labels | Live detection, Tamil+English signs, landmarks, footpath, scene summary — on-device |
| **Rerouting** | Automatic (hardened in M0) | Plus voice, alternatives with reasons, assistant explanation |
| **Resilience** | Online required for maps/search/routes | Offline areas and sync (proposed) |
| **Safety** | — | SOS via phone dialer, location sharing, nearby facilities, community alerts (proposed) |
| **Edge AI** | ML Kit bundled models | LiteRT runtime, GPU delegate, quantised models, open LLM on device |
| **Data** | Supabase saved places | Plus local-first observation store and PostGIS map layer (M10) |
| **Visual design** | Material 3, brand blue, light/dark | Navy/charcoal, blue→cyan accents, glass panels, AI orb, AR-first layouts |
| **Quality** | 224 tests | 261 tests and CI today (M0); trace-replay tests and field validation planned |

## What stays the same

- Flutter/Dart, Riverpod, Android-first.
- Layering: screens → controllers → pure logic → services/bridges.
- The Phase 1 2D navigator remains the fallback for every Phase 2 mode.
- Owner decisions: Flutter 3.38.4, OpenRouteService first, permissive
  model licences, on-device vision, free/open-source AI first with no paid
  API before its cost is presented.

## What it takes

M1 sensors → M2 Tamil + voice → M3 walking → M4 fusion → M5 AR → M6 VPS →
M7 detection → M8 signs/landmarks → M9 assistant → M10 mapping → M11
optimisation and field validation, plus owner approval for the proposed
items (offline, safety, nearby recommendations, step-free routing).
