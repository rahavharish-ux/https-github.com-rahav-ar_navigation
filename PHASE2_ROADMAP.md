# Phase 2 — Stage 4: Development Roadmap

Each milestone is independently mergeable, keeps all Phase 1 behaviour
working, and ends with the same gate Phase 1 used:

> **Milestone gate:** `flutter analyze` clean · `flutter test` all green
> (including all pre-existing tests) · debug **and** release APK build ·
> device checklist executed and results recorded · docs updated
> (`PROJECT_STATUS.md`, `KNOWN_LIMITATIONS.md`).

Claims ("works", "accurate", "real-time") are only written into docs after
the device checklist has measured them.

| # | Milestone | Depends on | Size |
|---|---|---|---|
| **M0** | Stabilize the base — **code complete; builds + device checks pending** | — | S |
| M1 | Sensor hub + trace record/replay | M0 | M |
| M2 | i18n (Tamil/English) + voice guidance | M0 | M |
| M3 | Pedestrian routing provider | M0 | M |
| M4 | Fused localization v1 (GNSS + PDR + route progress) | M1 | L |
| M5 | Native AR session + local-frame AR guidance | M1, M4 | L |
| M6 | ARCore Geospatial (VPS) integration | M5 | L |
| M7 | Edge inference runtime + object detection + hazards | M0 (M5 for AR frames) | L |
| M8 | Semantic road understanding (Tamil OCR, segmentation) + landmark resolver | M7, M4 | XL |
| M9 | Conversational agent (voice, tools, backend proxy) | M2, M3, M4 (M7 optional) | L |
| M10 | Geospatial environmental mapping | M7, M4 | M |
| M11 | Edge optimization, battery, field validation | all | M |

M2 and M3 can run in parallel with M1. M7 can start before M5 using the
CameraX frame source.

---

## M0 — Stabilize the base  ✅ code complete, provisionally accepted (2026-11-18)

> **Status.** Implemented, plus the M0 closure fixes (pause during
> reroute; reroute/resume using stale positions; camera finishing init
> in the background; capture interrupted by backgrounding). Code, tests
> and docs approved by the owner. Acceptance check:
>
> | Criterion | Result |
> |---|---|
> | Existing + new tests pass, 3 consecutive runs | ✅ **261/261** locally (3/3 runs) · ✅ **261 passed, 0 failed** in CI |
> | Format + analyzer clean on pinned SDK | ✅ CI: 0 files changed · "No issues found" (Flutter 3.38.4) |
> | Debug + release APK build | ✅ CI built `app-debug.apk` and `app-release.apk` (118.3 MB) |
> | Pushed to GitHub | ✅ `origin/claude/phase-2-technical-audit-2di7x1` @ `b6e0d7f` |
> | Device checklist | ⏳ **Not run** — `docs/field-tests/M0_DEVICE_CHECKLIST.md` (A1–A9, B1–B5, C1–C10) |
> | No Phase 1 behaviour change except fixed defects | ✅ All 224 original tests kept (2 rewritten to use the fake routing service); no feature or dependency added |
>
> CI run: https://github.com/rahavharish-ux/https-github.com-rahav-ar_navigation/actions/runs/44253276288. Coverage 75.1% (1554/2070; was 73.7% before M0).
> **M0 is not formally closed until the device checklist is run and
> recorded, and M1 does not start without the owner's approval.**
> Details: `PHASE2_AUDIT.md` §10.

**Objective.** Make the existing suite hermetic and green, fix the confirmed
navigation defects, pin the toolchain, and add CI — so every Phase 2 change
is measured against a trustworthy baseline.

**Files to modify**
- `lib/core/providers/route_provider.dart` — obtain `RoutingService` via a new `routingServiceProvider` (or `@visibleForTesting createService()`, matching `LocationNotifier`).
- `lib/features/navigation/providers/navigation_provider.dart` — same injection; `ref.mounted` check after `await` in `_recalculate()`; session generation counter so `stop()` during a reroute cannot resurrect a session; include `distanceToManeuver` in remaining distance.
- `lib/features/search/providers/search_provider.dart` — request generation guard.
- `lib/features/ar_navigation/camera_preview_screen.dart`, `lib/features/vision/vision_screen.dart` — app-lifecycle handling for the camera; extract the duplicated status widget to `lib/widgets/common/status_message.dart`.
- `lib/widgets/map/app_map_view.dart`, `lib/services/auth_service.dart`, `lib/services/geocoding_service.dart` — correct the inaccurate comments/messages (audit §6.7).
- `test/features/navigation/providers/navigation_provider_test.dart` — replace `HttpOverrides` + wall-clock wait with a fake routing service.
- New: `.github/workflows/ci.yml`, `.fvmrc`. (`.env.example` pointed at a missing `android/local.properties.example`; corrected to point at SETUP.md instead of adding the file, since Flutter generates `local.properties`.)
- `PROJECT_STATUS.md` — clear stale pending items.

**Dependencies.** None new. (CI uses GitHub Actions; FVM is optional tooling, not an app dependency.)

**Implementation steps**
1. Pin Flutter to the version the project was verified on (3.38.4) or decide to move to current stable — owner decision; if moving, run the `material.dart` import migration in a separate commit.
2. Introduce routing-service injection; rewrite the two failing tests to use a fake that throws `RoutingException` deterministically.
3. Write failing regression tests for audit §6.2–6.5, then fix each.
4. Camera lifecycle observer; shared status widget.
5. CI: `flutter pub get` (with `.env` created from `.env.example`), `flutter analyze`, `flutter test --coverage`, `flutter build apk --debug`.

**Unit tests**
- Recalculation failure → `offRoute` + error message, no wall-clock waits.
- Dispose during in-flight recalculation → no exception.
- `stop()` during in-flight recalculation → state stays idle.
- Remaining distance = distance to next maneuver + remaining steps.
- Search: older slow response does not overwrite newer results.

**Integration tests.** Existing `integration_test/app_test.dart` unchanged and passing on a device.

**Device testing.** `docs/field-tests/M0_DEVICE_CHECKLIST.md` (camera lifecycle and permissions, navigation stop/pause/restart during a reroute).

**Acceptance criteria**
- 224 existing tests + new regression tests all pass, 3 consecutive runs, in CI.
- Analyzer: zero errors/warnings on the pinned SDK.
- Debug and release APK build in CI (or locally if CI lacks the Android SDK — documented).
- No Phase 1 user-visible behaviour changes except the fixed defects.

---

## M1 — Sensor hub + trace record/replay

**Objective.** One timestamped sensor stream for the whole app and the ability to record real walks and replay them in tests.

**Files.** New `lib/sensors/**`, `android/.../sensors/SensorStreamer.kt`, `MainActivity.kt` (register channel), `lib/features/diagnostics/diagnostics_screen.dart` (record button, sample rates). Fixtures under `test/fixtures/traces/`.

**Dependencies.** None new (Kotlin `SensorManager`; JSON lines via `dart:convert`). Manifest: `HIGH_SAMPLING_RATE_SENSORS` only if >200 Hz is actually needed (default: not added).

**Steps.** Native streamer for rotation vector, game rotation vector, accel, gyro, step detector with `event.timestamp`; batch to `EventChannel`; restamp GNSS fixes with `elapsedRealtimeNanos`; recorder/player; diagnostics UI showing measured rates.

**Unit tests.** Sample decoding; batch splitting; monotonic ordering; recorder→player round trip byte-identical.

**Integration tests.** Player-driven `SensorHub` feeds existing `locationProvider` path in a widget test.

**Device testing.** Record 3 walks (≥10 min each, open sky / dense street / under tree cover) on ≥2 devices; record measured sample rates and battery delta.

**Acceptance.** Recorded traces replay deterministically in CI; measured rates documented per device; no change to Phase 1 screens.

---

## M2 — Localization (i18n) and voice guidance

**Objective.** Tamil + English UI and spoken turn-by-turn guidance.

**Files.** `pubspec.yaml` (`flutter_localizations`, `intl`, `flutter_tts`, `wakelock_plus`), `l10n.yaml`, `lib/l10n/app_en.arb`, `app_ta.arb`, migrate `AppStrings` usages screen by screen; new `lib/session/guidance_engine.dart`; navigation screen (voice toggle, wakelock); settings screen (language).

**Steps.** Generate localizations; move strings incrementally (one feature per commit); guidance engine emits cues at distance thresholds (e.g. 200 m / 50 m / at maneuver) computed from route progress; TTS with locale selection and fallback to English when no Tamil voice is installed (surfaced honestly); persist language and "onboarding seen".

**Unit tests.** Cue scheduling (no duplicate cues, correct thresholds); instruction text builders in both languages; locale fallback logic.

**Integration tests.** Widget tests render each screen in `ta` without overflow (Tamil strings are long); golden tests for key screens.

**Device testing.** Tamil TTS voice availability on test devices; audibility outdoors; screen stays on during navigation.

**Acceptance.** All Phase 1 screens localized; voice guidance on a real drive/walk with no missed or repeated cues on the test route; Tamil reviewed by a native speaker.

---

## M3 — Pedestrian routing provider

**Objective.** Real walking routes, ending the "Walking unsupported" state honestly.

**Files.** New `lib/routing/**`; `route_provider.dart` delegates to `RoutePlanner`; `travel_mode_provider.dart` unchanged API; `.env.example` (new key name if a hosted provider is chosen); `navigation_instruction.dart` (pedestrian maneuver phrasing).

**Dependencies.** None new in Dart (uses `http`). External: one foot-routing backend — owner chooses (see TECH_STACK §5).

**Provider (owner decision).** OpenRouteService `foot-walking` first. Its key would sit in `.env` (extractable from the APK and, unlike the Maps key, not restrictable to the app), so the M3 plan must either accept that with tight quotas or route requests through a small proxy — decide at M3 start. Google Routes `WALK` or a self-hosted engine can be added later as further `RoutingProvider`s.

**Steps.** Define `RoutingProvider`; wrap OSRM as driving provider; implement the OpenRouteService foot provider + parser; pedestrian thresholds in navigation (off-route 25 m, arrival 10–15 m — tune by field test); keep cycling "unsupported" unless the chosen backend supports it.

**Unit tests.** Parser fixtures (recorded responses); provider selection by mode; error mapping.

**Integration tests.** Route preview shows walking route from fixture; navigation screen runs a walking session from a replayed trace (M1).

**Device testing.** 5 fixed origin/destination pairs walked in the target city; compare against the posted route.

**Acceptance.** Walking routes returned from a real foot graph (verified by differing from driving on one-way streets/footpaths); field walks complete without false off-route triggers on ≥4/5 routes.

---

## M4 — Fused localization v1

**Objective.** A probabilistic pose estimate with uncertainty that bridges short GNSS gaps on foot, plus route progress.

**Files.** New `lib/localization/**`, `lib/spatial/geodesy/enu.dart`; `navigation_provider.dart` consumes `PoseEstimate` behind a feature flag; diagnostics shows raw vs fused.

**Dependencies.** None (pure Dart; small matrix code in-house, or `vector_math` which Flutter already depends on).

**Steps.** ENU conversion; step detection → stride model (fixed + optional calibration from GNSS); EKF predict (PDR) / update (GNSS, weighted by reported accuracy, with outlier gating); route projection (along-track, cross-track); degraded state when σ exceeds threshold or PDR-only exceeds time limit.

**Unit tests.** EKF consistency on synthetic straight/turning paths; gating rejects jumps; ENU round trip; route projection on corner cases.

**Integration tests.** Replay recorded traces with GNSS masked for 10/30/60 s; assert error bounds (set from the M1 data, not guessed).

**Device testing.** Field walks with surveyed checkpoints (e.g. 10 marked points) — report median/95th horizontal error for GNSS-only vs fused.

**Acceptance.** Fused error ≤ GNSS-only error in open sky (no regression) and measurably lower during masked gaps; feature flag on by default only if both hold. Documentation describes this as "GNSS + pedestrian dead reckoning", not "GPS-denied navigation".

---

## M5 — Native AR session + local-frame AR guidance

**Objective.** A real ARCore camera view with route guidance arrows, falling back to 2D.

**Files.** `android/.../ar/ArSessionManager.kt`, `ArRenderViewFactory.kt`; `MainActivity.kt`; `android/app/build.gradle.kts` (renderer dependency); new `lib/ar/**`; new `lib/features/ar_navigation/ar_navigation_screen.dart`; home AR button enabled **only** when `ArAvailability.supported` and a route exists; `lib/session/capability_manager.dart`.

**Dependencies.** Android renderer library (see TECH_STACK §4). ARCore already present.

**Steps.** PlatformView hosting ARCore session (camera permission flow reuses existing pattern); lifecycle (pause/resume); publish tracking state + pose at ~10 Hz; place chevrons along the next 50–150 m using EKF pose + heading to align the session frame with ENU; "approximate placement" badge; fall back to 2D navigation on tracking loss.

**Unit tests.** Route → local-anchor conversion; tier state machine transitions; message decoding.

**Integration tests.** Fake `ArSessionBridge` drives the AR screen through tracking/paused/stopped.

**Device testing.** ≥2 ARCore devices: frame time, thermal over 20 min, chevron alignment error vs actual street direction (degrees), behaviour on app background.

**Acceptance.** AR screen runs ≥20 min without crash on test devices; measured alignment error and frame rate documented; clean fallback on every tracking-loss reason. Docs say "AR guidance with approximate geo-alignment" — not "6DoF geo-anchored AR".

---

## M6 — ARCore Geospatial (VPS)

**Objective.** Earth-anchored AR content and a high-accuracy pose where VPS is available.

**Files.** `ArSessionManager.kt` (Geospatial mode, `checkVpsAvailabilityAsync`, Earth anchors), `lib/ar/models/ar_pose.dart` (EarthState), `LocalizationEngine` (Earth pose as measurement), `capability_manager.dart` (T3 tier), `android/local.properties` entry (documented in SETUP.md) + manifest meta-data for the ARCore API key.

**Dependencies.** ARCore Geospatial API (Google Cloud project with ARCore API enabled; key restricted to the app). No new Dart packages. Check the ARCore API's current pricing/quotas and present the expected cost to the owner before starting (decision 5 spirit: no new paid dependency without its cost).

**Steps.** VPS availability check at session start; localization UX ("point camera at buildings"); thresholds for accepting Earth pose (horizontal and yaw accuracy); terrain/WGS84 anchors for route chevrons; fused pose consumes Earth pose.

**Unit tests.** Acceptance thresholds; T2↔T3 transitions.

**Device testing.** VPS availability and time-to-localize at ≥10 locations in the target city; reported vs surveyed accuracy at checkpoints.

**Acceptance.** Measured availability map and accuracy table published; T3 used only when thresholds are met. "6DoF geo-anchored AR" may be claimed only for locations/conditions where it was measured.

---

## M7 — Edge inference runtime + object detection + hazards

**Objective.** Real-time on-device detection of road users/obstacles with advisory hazard cues.

**Files.** `android/.../perception/**`; `android/app/build.gradle.kts` (LiteRT); `proguard-rules.pro` (keep rules, verified by release build); `assets/models/` + `LICENSES-models.md`; new `lib/perception/**`; diagnostics "perception" view with boxes overlay; guidance engine hazard cues (off by default until validated).

**Dependencies.** LiteRT runtime (+ GPU delegate, Apache-2.0). A pretrained detector under Apache-2.0 or a similarly permissive licence — no AGPL weights or code unless the owner explicitly approves (decision 3); training/fine-tuning data must also permit commercial use.

**Steps.** InferenceEngine with delegate fallback; CameraX frame source (non-AR) and ARCore frame source (AR); detector + NMS + tracker; rate governor; `HazardRules` in Dart; benchmark mode writing JSON results.

**Unit tests.** NMS, tracker association, hazard rules with fixture detections (Dart and Kotlin).

**Integration tests.** Fake `PerceptionBridge` feeding the AR and 2D screens.

**Device testing.** Latency p50/p95, FPS, memory, 20-min thermal run on ≥2 devices; offline accuracy (mAP@0.5) on a labeled Tamil Nadu street image set with classes relevant to pedestrians.

**Acceptance.** Benchmarks recorded; hazard cue precision on the labeled set reported; cues enabled by default only if false-alarm rate is below an owner-approved threshold.

---

## M8 — Semantic road understanding + landmark resolver

**Objective.** Read Tamil/English signs, understand walkable surface, and identify nearby landmarks with stated confidence.

**Files.** `perception/` new models (OCR detector/recognizer, segmentation); `lib/spatial/landmark_resolver.dart`; `GeocodingService` (Nearby Search); vision screen moves from diagnostics to a first-class "Read sign" action.

**Dependencies.** Tamil-capable OCR model (benchmark candidates first); segmentation model; Places Nearby Search (existing key/billing).

**Steps.** Benchmark Tamil OCR candidates on a collected signboard set → pick; integrate; low-rate segmentation (2–5 Hz) for sidewalk/road/crosswalk; landmark resolver: frustum from pose → Places candidates → rank → (optional) OCR text match on signboards.

**Unit tests.** Frustum and ranking math; OCR post-processing (Tamil Unicode normalization).

**Device testing.** CER on signboards; mIoU on labeled frames; landmark precision/recall on annotated walks.

**Acceptance.** Metrics published; landmark results always displayed with confidence; "real-time landmark recognition" not claimed unless latency and precision targets agreed in advance are met.

---

## M9 — Conversational agent (Tamil + English voice)

**Objective.** A push-to-talk assistant that can search, route, and describe surroundings using app tools.

**Approach (owner decision).** Free and open-source first, provider-independent. Step 1 is a benchmark, not an integration: candidate open-weight models (on-device and self-hosted), each with its licence checked, scored on a bilingual Tamil/English tool-call eval set for accuracy, latency, size and memory. A deterministic intent fallback ships regardless. A paid hosted LLM is added only if the owner approves its presented cost, and then only via `supabase/functions/agent-proxy/`.

**Files.** New `lib/agent/**` including `llm/llm_provider.dart` and the first open-model provider; `pubspec.yaml` (`speech_to_text`); AndroidManifest (`RECORD_AUDIO`); assistant screen/sheet. Only if a hosted provider is approved: `supabase/functions/agent-proxy/` and a rate-limit migration.

**Dependencies.** `speech_to_text`, `flutter_tts` (M2); an open-weight model runtime chosen by the benchmark (LiteRT or llama.cpp, both permissively licensed); no paid API.

**Steps.** Proxy with auth check, per-user rate limit, server-held key and server-side model config; tool registry on device; conversation state; locale-aware STT/TTS; image tool behind an explicit user action; offline handling.

**Unit tests.** Tool schemas ↔ handlers; dispatcher with a fake agent client; safety rule: agent replies never trigger navigation actions without confirmation.

**Integration tests.** Proxy tested locally (`supabase functions serve`) with the LLM call mocked.

**Evaluation.** Bilingual utterance set (≥100, Tamil/English/code-mixed) with expected tool calls; report tool-selection accuracy and latency.

**Device testing.** STT accuracy outdoors; end-to-end latency; mobile-data usage.

**Acceptance.** Eval results documented; no API key in the APK (verified by inspecting the release APK); agent disabled gracefully when offline or not signed in.

---

## M10 — Geospatial environmental mapping

**Objective.** Persist and share geotagged observations; use them as a routing/hazard layer.

**Files.** `supabase/migrations/*_observations.sql` (PostGIS, RLS, aggregated view); `lib/spatial/observations/**`; `pubspec.yaml` (`drift`, `drift_flutter` or `sqflite`); map layer in `AppMapView` (additive param); settings: contribution opt-in.

**Steps.** Local store; sync worker; server aggregation (confirmations from distinct users, expiry); routing penalty hook in `RoutePlanner`.

**Tests.** DAO unit tests; RLS tests against local Supabase; sync conflict tests; privacy review checklist.

**Acceptance.** Observations sync and render; no personal data shared without opt-in; existing `saved_places` untouched.

---

## M11 — Edge optimization and field validation

**Objective.** Meet battery/thermal budgets and publish a validation report.

**Steps.** Quantization (int8/fp16) with accuracy parity checks; adaptive rates by tier and battery; profile with Android Studio/Perfetto; a full field-test campaign across devices and conditions.

**Acceptance.** Per-device battery %/hour for T1/T2/T3 sessions, latency tables, and accuracy tables published in `docs/field-tests/`; `KNOWN_LIMITATIONS.md` updated with measured limits.
