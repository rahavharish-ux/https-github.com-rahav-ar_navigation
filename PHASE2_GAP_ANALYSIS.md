# Phase 2 — Stage 2: Gap Analysis

_Companion to `PHASE2_AUDIT.md`. Technology choices are justified in
`PHASE2_TECH_STACK.md`; risks in `PHASE2_RISKS.md`._

## 0. Owner decisions (2026-11-18)

1. **Flutter** stays on **3.38.4**; no SDK upgrade during M0.
2. **Walking routes:** **OpenRouteService** first, behind a replaceable
   `RoutingProvider` so Google Routes or another provider can follow.
3. **Detection models:** Apache-2.0 or other commercially permissive
   licences only; no AGPL unless explicitly approved.
4. **Vision:** on-device first (privacy, cost, offline); cloud vision stays
   optional and is not planned.
5. **AI:** free and open-source first, provider-independent design; no paid
   API dependency without presenting its cost first.

The table below reflects these decisions.

Difficulty scale: **L** low · **M** medium · **H** high · **VH** very high
(research-grade or heavily device-dependent).

## 1. Summary table

| # | Module | Current implementation | Missing functionality | Required Phase 2 upgrade | Recommended technology | Dependencies (on other modules) | Difficulty | Testing requirements |
|---|---|---|---|---|---|---|---|---|
| 1 | **Sensor acquisition** | Separate geolocator, flutter_compass, sensors_plus streams, each started ad hoc; no timestamps aligned; diagnostics-only for compass/IMU | Unified, timestamped sensor bus; rotation-vector orientation; step detection; GNSS status; session recording/replay | A single `SensorHub` emitting typed, monotonic-clock-stamped samples; record to file; replay in tests | Native Kotlin `SensorManager` (TYPE_ROTATION_VECTOR, TYPE_STEP_DETECTOR, accel/gyro with `event.timestamp`) over an `EventChannel`; geolocator for fixes; JSON-lines/CBOR log format | None (foundation) | M | Unit: sample ordering, clock alignment, recorder round-trip. Device: sample rates, battery at each rate. |
| 2 | **Localization / sensor fusion** | Accuracy gate + accuracy-weighted EMA; either/or heading choice | Probabilistic state estimate; GPS-gap bridging; uncertainty output; map-matching / route progress | 2D EKF (position, velocity, heading) fusing GPS + pedestrian dead reckoning (steps × stride × rotation-vector heading), with covariance; along-route projection; explicit "degraded" states | Pure-Dart EKF (no dependency); later fused with ARCore VIO pose deltas (row 3) | 1 | H | Unit: filter math against synthetic trajectories with known truth. Replay: recorded walks with GPS dropped artificially for 10/30/60 s → report drift (m) vs. time. Device: field walks with ground-truth checkpoints. |
| 3 | **Visual-inertial localization** | None (ARCore availability only) | Camera pose tracking; global (earth-referenced) pose | ARCore motion tracking (ARCore's own VIO) for relative 6DoF pose; ARCore **Geospatial API** (VPS) for earth-anchored pose where Street View coverage exists; fall back to row 2 otherwise | ARCore SDK (native, already a dependency) + Geospatial API (needs an API key with ARCore API enabled on Google Cloud); hosted in a native Android view | 1, 2, 7 | VH | Device-only for real behaviour. Unit: pose-message parsing, fallback ladder state machine. Field: VPS availability rate and horizontal/heading accuracy reported by ARCore at test sites in Chennai/other target cities. |
| 4 | **Visual perception / object detection** | ML Kit image labeling on one photo | Real-time bounding-box detection of pedestrians, vehicles, two-wheelers, auto-rickshaws, animals, obstacles; tracking; hazard scoring | Streaming detector at a bounded rate (e.g. 5–10 Hz) with tracker and hazard rules (proximity via box size/position, approaching via track growth) | LiteRT (TFLite) with GPU delegate; an **Apache-2.0** (or similarly permissive) COCO model (EfficientDet-Lite / SSD-MobileNet class) — **no AGPL** (decision 3); fine-tune for Indian road classes later on data we may license commercially. Inference in Kotlin on frames from ARCore (or CameraX when AR is off) | 1, 8 | H | Unit: post-processing (NMS, tracker, hazard rules) on fixture tensors. Offline: mAP on a held-out labeled set of Tamil Nadu street images. Device: latency p50/p95, FPS, thermal throttling over 20 min. |
| 5 | **Landmark recognition** | None (scene labels only) | Identifying specific named places in view | Geo-prior approach: candidate POIs from Places Nearby within the camera frustum (from pose) → rank by bearing/distance → on-device visual confirmation (e.g. OCR of signboard text) | Places API (already used) + pose (rows 2/3) + on-device OCR; cloud landmark detection **not planned** (decision 4) | 2, 3, 6 | H | Unit: frustum/bearing math. Field: precision/recall vs. manually labeled walks. Must never present a guess as an identification — show confidence. |
| 6 | **Semantic road understanding** | Latin OCR on one photo | Tamil sign OCR; sidewalk/road/crossing segmentation; traffic-light state | Tamil+English OCR; lightweight segmentation (road / sidewalk / crosswalk) at low rate; traffic-light colour classification for pedestrians | Tamil OCR (on-device, decision 4): PaddleOCR-family model (Apache-2.0) converted to LiteRT, or Tesseract `tam` (Apache-2.0), benchmark both; segmentation: DeepLabV3-MobileNet-class LiteRT model; verify licenses of any pretrained weights/datasets | 4, 8 | VH | Offline: CER on a Tamil signboard set; mIoU on labeled street frames. Device: latency. Safety: never instruct a crossing based on vision alone. |
| 7 | **AR rendering** | None | AR session view; world-anchored route arrows/path; labels; occlusion-safe UI | Native AR view embedded via `AndroidView`; render route polyline as ground-anchored chevrons; destination pin; hazard markers; graceful fallback to 2D map | ARCore + a maintained Android renderer (SceneView-for-Android / Filament) in Kotlin; Dart controls via MethodChannel/EventChannel | 3 (pose), 9 (route) | VH | Unit: route-to-anchor conversion (geodetic → local ENU). Device: visual check script per device, drift of anchors over 200 m walk, frame time ≤16.7 ms at 60 Hz target / ≤33 ms minimum. |
| 8 | **Edge inference runtime** | ML Kit only | Generic model runtime; model packaging; delegate selection; benchmarking | `InferenceEngine` abstraction (Kotlin) with model registry, GPU→CPU fallback, int8/fp16 models, per-model budget | LiteRT (`com.google.ai.edge.litert`) on Android; models in `assets/models/` or downloaded on demand | 1 | M–H | Unit: registry/fallback logic. Device benchmark harness: latency, memory, accuracy parity vs. float model. |
| 9 | **Pedestrian route planning** | Driving-only OSRM demo; walking honestly blocked | Foot routing; pedestrian preferences (avoid highways/stairs, prefer lit/shaded/footpaths); multi-criteria; offline | `RoutingProvider` interface with a foot-capable backend; pedestrian cost profile; route alternatives with explanations | **OpenRouteService `foot-walking`** first (decision 2; hosted API, free tier with key — verify current quotas). Behind `RoutingProvider` so Google Routes `WALK`, or self-hosted Valhalla/GraphHopper with custom costing, can replace or supplement it | 2 (progress), 11 (hazard layer) | M (hosted) → H (self-hosted + custom costing) | Unit: response parsing with recorded fixtures; provider fallback. Integration: golden routes for fixed O/D pairs. Field: walk the routes. |
| 10 | **Multimodal conversational AI agent** | None | Voice in/out (Tamil + English); intent handling; tool use over app capabilities; scene description | Push-to-talk STT → agent (LLM with tools: search place, plan route, where am I, what's ahead, describe scene) → TTS; strict separation of safety-critical guidance (deterministic) from conversational replies | Decision 5 — free/open-source first, provider-independent: STT via the platform recognizer (`speech_to_text`, no fee) with offline whisper.cpp (MIT) as a candidate; TTS via `flutter_tts` (platform engine); LLM behind an `LlmProvider` interface, first implementation an open-weight model run on-device or self-hosted (licence and Tamil quality to be benchmarked). Paid hosted LLMs (e.g. Claude API) only as an optional provider after their cost is presented, and only through a backend proxy | 2, 4, 5, 9, 12 | H | Unit: tool schemas, intent→tool dispatch with a fake LLM. Eval set: bilingual utterances with expected tool calls. Device: STT accuracy in street noise, end-to-end latency. Offline behaviour test. |
| 11 | **Geospatial environmental mapping** | `saved_places` table only | Persisting geotagged observations (hazards, signs, landmarks, sidewalk quality); aggregation; map layer | Local-first observation store with sync; server aggregation into tiles/cells; privacy controls (no images uploaded by default) | On-device SQLite (`drift`); Supabase Postgres + PostGIS (`geography` columns, spatial index); RLS per user + aggregated public view | 1, 2, 4, 6 | M–H | Unit: DAO, sync conflict rules. Integration: RLS tests against local Supabase. Privacy review. |
| 12 | **Orchestration / app shell** | Feature screens talk to providers directly; no global session concept | A navigation session coordinator; capability negotiation (AR/VPS/camera/model availability); localization; voice guidance; foreground service | `NavigationSessionController` owning mode (map / AR / audio-only), fallback ladder, guidance channel (visual + TTS); `flutter_localizations` with English + Tamil ARB | Riverpod (existing); `flutter_localizations` + `intl`; `wakelock_plus`; foreground service for location | All | M | Widget tests per mode; state-machine tests for fallback transitions; localization golden tests (Tamil glyph rendering). |
| 13 | **Quality infrastructure** | **M0 done:** 251 tests all passing, hermetic routing fake, SDK pinned (`.fvmrc` 3.38.4), CI workflow added (not yet run) | Trace replay (M1), device test protocol, first green CI run | Push branch so CI runs; `test/fixtures/traces/` in M1 | GitHub Actions; FVM (optional) | — | L | CI must be green before any Phase 2 feature merges. |

## 2. Existing modules: keep, extend, or replace

| Existing module | Decision | Why |
|---|---|---|
| `LocationService` / `locationProvider` | **Extend** | Becomes one input to the fusion engine; its filter/smoothing stay as the "GPS-only" estimator and as a fallback. |
| `position_smoothing.dart` (EMA) | **Keep as fallback**, superseded by EKF output when fusion is active | Removing it would regress Phase 1 behaviour. |
| `heading_fusion.dart` | **Replace consumer, keep function** | EKF heading supersedes it; keep for diagnostics comparison. |
| `CompassService` (`flutter_compass`) | **Supplement** with native rotation vector | Keep until the native source is verified on devices. |
| `MotionSensorService` (`sensors_plus`) | **Keep for diagnostics**; fusion uses native timestamped stream | sensors_plus is fine for UI; fusion needs sensor timestamps. |
| `RoutingService` (OSRM) | **Keep behind new `RoutingProvider` interface** as the driving provider | No reason to remove working driving routes. |
| `NavigationNotifier` | **Fix, then extend** with route-progress projection and guidance events | Core logic is sound; defects are local. |
| `CameraService` / `cameraProvider` | **Keep** for non-AR vision; AR mode uses ARCore's camera | The two cannot hold the camera simultaneously. |
| `VisionService` (ML Kit) | **Keep** for Latin OCR + labels; add new perception engine alongside | Additive. |
| `ArPlatformService` / `MainActivity.kt` | **Extend** into the native AR module | Channel name and availability logic reused. |
| `GeocodingService` | **Keep**; add Nearby Search for landmark candidates | Additive. |
| Supabase auth / saved places | **Keep**; add tables, never alter existing columns destructively | Phase 1 users' data must survive. |

## 3. Cross-cutting gaps

1. **Truth data.** No module can be called "working" in Phase 2 without measured accuracy against ground truth. Field data collection (traces + annotated images) is a first-class work item, not an afterthought.
2. **Localization (i18n).** Tamil support touches every screen, voice, OCR, and the agent. It should start early (M2) so every later screen is born localizable.
3. **Safety framing.** Pedestrian guidance near traffic is safety-relevant. Vision-derived hazards are advisory; the app must never instruct "cross now" from vision alone.
4. **Secrets.** Any new key (Geospatial, OpenRouteService, Cloud Vision, LLM) must either be a restricted client key in `local.properties`/`.env` or live server-side. LLM and Cloud Vision keys are **server-side only**.
5. **Battery/thermal.** Camera + AR + inference + GPS together is the most expensive workload a phone runs. Every milestone needs a power budget and a measured result.
