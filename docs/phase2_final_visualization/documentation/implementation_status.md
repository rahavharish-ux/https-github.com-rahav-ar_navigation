# Implementation Status — Phase 2 Target Product

_Inventory of every capability shown in `screens/` and `architecture/`,
classified against the repository (branch `claude/phase-2-technical-audit-2di7x1`)
and the approved plan (`PHASE2_ROADMAP.md`, `PHASE2_ARCHITECTURE.md`)._

## The four tiers

| Tier | Meaning |
|---|---|
| 🟢 **Phase 1 — existing** | In the code today |
| 🔵 **Phase 2 M0 — completed** | Reliability work done: 261 tests, CI green; device checks pending |
| 🟠 **Phase 2 roadmap — remaining** | Approved milestones M1–M11; **not built** |
| 🟣 **Proposed final capability** | In the Phase 2 vision but **not yet in the approved roadmap**; needs owner approval and sometimes a data source or cost decision |

**Today:** Phase 1 plus milestone M0. M1 has not started (awaiting
approval). Every 🟠 and 🟣 item is a target, not a feature.

## 1. Multimodal AI assistant

| Capability | Tier | Milestone / note |
|---|---|---|
| Text conversation in Tamil, English and code-mixed | 🟠 | M9 |
| Voice input (platform speech recognition ta-IN / en-IN) | 🟠 | M9 |
| Camera input (describe scene, read sign) after an explicit tap | 🟠 | M9 (+ M7/M8 perception) |
| Provider-independent `LlmProvider`; open-weight model first | 🟠 | M9 — model chosen by a Tamil/English benchmark |
| Rule-based intent fallback (works with no model) | 🟠 | M9 |
| Tool use: `search_places` | 🟢 service exists, 🟠 as a tool | Places search is Phase 1 |
| Tool use: `plan_route`, `where_am_i`, `whats_ahead`, `read_sign`, `start_navigation` (confirm first) | 🟠 | M3, M4, M7/M8, M9 |
| Hosted LLM (e.g. Claude API) via proxy | 🟣 | Optional; only after its cost is presented and approved |
| Nearby place recommendations ("Nearby now") | 🟣 | Not in roadmap; would use Places search (billing) |

## 2. Advanced live AR navigation

| Capability | Tier | Milestone / note |
|---|---|---|
| ARCore availability check | 🟢 | Diagnostics only |
| Live camera AR view inside the app | 🟠 | M5 |
| Approximate guidance arrows (GPS + compass) | 🟠 | M5 — labelled "approximate" |
| World-anchored ground chevrons, 3D turn arrow, destination marker | 🟠 | M6 (ARCore Geospatial / VPS), only where VPS localizes |
| Landmark-based instructions ("after the temple tower") | 🟠 | M8 landmarks + M4 route progress |
| Hazard advisory in AR | 🟠 | M7 |
| AR ⇄ map switch, automatic 2D fallback | 🟠 | M5 |
| Instruction, distance, remaining time | 🔵 | Navigation engine with M0's corrected distance/ETA |
| Clock-time arrival ("Arrive 10:31") | 🟣 | Small addition, not in roadmap |

## 3. Hybrid localization and visual-inertial positioning

| Capability | Tier | Milestone / note |
|---|---|---|
| GPS fixes with accuracy filter, smoothing, weak-signal flag | 🟢 | |
| Accelerometer, gyroscope, compass streams | 🟢 | Diagnostics only |
| Timestamped sensor hub, rotation-vector heading, step detector | 🟠 | M1 |
| Trace recording / replay for tests | 🟠 | M1 |
| EKF fusion (GNSS + pedestrian dead reckoning) with uncertainty | 🟠 | M4 |
| Route progress / map matching | 🟠 | M4 |
| Visual-inertial odometry (ARCore) | 🟠 | M5 |
| VPS earth pose | 🟠 | M6 — cost and coverage to be checked first |
| Positioning dashboard (screen 07) | 🟠 | M1 + M4 (extends Diagnostics) |
| Numeric accuracy figures | — | **None claimed**; measured in field tests (M4, M11) |

## 4. Real-time scene understanding

| Capability | Tier | Milestone / note |
|---|---|---|
| OCR on one photo (Latin script), on-device | 🟢 | ML Kit, Diagnostics |
| Scene labels on one photo | 🟢 | ML Kit, Diagnostics |
| Capture interrupted by backgrounding handled | 🔵 | M0 |
| Live object detection + tracking (people, vehicles, two-wheelers) | 🟠 | M7 — Apache-2.0 or similarly permissive model |
| Hazard advisories | 🟠 | M7 — advisory only |
| Tamil + English sign reading | 🟠 | M8 |
| Landmark / building identification with confidence | 🟠 | M8 |
| Footpath / road / crossing segmentation | 🟠 | M8 |
| Scene summary by the assistant | 🟠 | M9 |
| Cloud vision | — | Not planned (owner decision) |

## 5. Pedestrian route planning

| Capability | Tier | Milestone / note |
|---|---|---|
| Driving route, distance, duration | 🟢 | OSRM |
| Injectable routing service | 🔵 | M0 |
| Walking routes (OpenRouteService) | 🟠 | M3 |
| Alternatives ranked by time, major-road crossings, main-road exposure | 🟠 | M3+ (architecture §4.6) |
| Hazard-aware ranking | 🟠 | M10 observation data |
| Step-free / accessible route | 🟣 | Depends on OpenStreetMap step tagging |
| Live traffic, crime or lighting data | — | No source specified; the UI says none is used |

## 6. Tamil and English voice navigation

| Capability | Tier | Milestone / note |
|---|---|---|
| Instruction text | 🟢 | Navigation engine |
| Spoken turn-by-turn (TTS ta-IN / en-IN) | 🟠 | M2 |
| Tamil user interface | 🟠 | M2 |
| Voice destination search, conversation | 🟠 | M9 |
| Hands-free controls, screen kept awake | 🟠 | M2 + M9 |
| Offline Tamil speech (whisper.cpp candidate) | 🟠 | M9 candidate; depends on device |

## 7. Route deviation and recovery

| Capability | Tier | Milestone / note |
|---|---|---|
| Off-route + wrong-direction detection | 🟢 | |
| Automatic reroute; safe against stop/pause/new session; newest position | 🔵 | M0 |
| Voice notification | 🟠 | M2 |
| Alternatives from where you are, with reasons | 🟠 | M3+ |
| Assistant explains the choice | 🟠 | M9 |

## 8. Offline and resilient navigation

| Capability | Tier | Milestone / note |
|---|---|---|
| GPS without internet | 🟢 | |
| On-device assistant works offline | 🟠 | M9 |
| Self-hosted routing backend | 🟠 | M3 long term (server, not on-phone) |
| Downloadable map regions | 🟣 | Needs an OSM-based tile source (Google tiles can't be stored offline) |
| Cached routes / places and sync on reconnect | 🟣 | Fits the M10 local-first store |
| Clear online/offline labelling | 🟣 | |

## 9. Safety and location intelligence

| Capability | Tier | Milestone / note |
|---|---|---|
| SOS via the phone's dialer (112) | 🟣 | **No emergency-service integration** exists or is implied |
| Live location sharing link | 🟣 | Needs a small backend and explicit consent |
| Emergency contacts on device | 🟣 | |
| Nearby hospitals / police / pharmacies | 🟣 | Uses existing Places search; hours only if Places provides them |
| Safety alerts from community observations | 🟠 | M10 data (UI proposed) |
| Live hazard advisories | 🟠 | M7 |

## 10. Platform and quality

| Capability | Tier |
|---|---|
| Search, saved places, auth, map, 2D navigation | 🟢 |
| 261 tests, CI with debug + release APK, Flutter 3.38.4 pin | 🔵 |
| Intelligent home, bottom navigation with AI orb, Phase 2 visual design | 🟣 design proposal (screens implemented per milestone) |

## Decisions needed before proposed items can be built

1. Add offline maps, safety centre, nearby recommendations and step-free
   routing to the roadmap (scope and order).
2. Choose an offline tile source and check its licence.
3. Location sharing: backend design and consent/privacy review.
4. Costs to present first: Places Nearby usage, ARCore Geospatial (M6),
   any hosted LLM (M9).
