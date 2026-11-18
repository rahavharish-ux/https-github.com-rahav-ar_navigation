# Phase 2 — Stage 1: Source Code Audit

_Audit date: 2026-11-18 · Branch: `claude/phase-2-technical-audit-2di7x1` · Base commit: `eb397c5`_

This is a read-only audit. **No application code was changed.** Everything
below was either observed by running a tool (marked **[observed]**) or
found by reading the code (marked **[inspection]**). Inspection findings are
not reproduced on a device and should be confirmed with a regression test
before being fixed.

"Phase 1" in this document means everything in the repository today
(the project's own 17-step roadmap, documented in `PROJECT_STATUS.md`).

---

## 1. Executive summary

The Phase 1 codebase is in **good structural health**: small (≈6.4k lines of
Dart under `lib/`), consistently layered (service → Riverpod `Notifier` →
screen), with sealed state classes, honest "unavailable" states, and 224
tests. It is a solid base to extend rather than rewrite.

It is, however, a **GPS + map navigation app with diagnostic-only sensors
and single-frame vision**. None of the eight Phase 2 targets exist yet in any
form beyond groundwork:

| Phase 2 target | What exists today |
|---|---|
| Visual-inertial localization / sensor fusion | GPS accept/reject filter + EMA smoothing; compass/IMU streams shown on the diagnostics screen only. No VIO, no EKF, no dead reckoning. |
| Object detection | None. ML Kit *image labeling* (whole-image tags) on one captured photo. |
| Landmark recognition / semantic road understanding | None. Latin-script OCR on one captured photo. |
| Spatial AR navigation | ARCore *availability check* only. No AR session, no rendering. Home "AR Navigation" button is disabled. |
| Multimodal conversational AI (Tamil + English voice) | None. No speech, no TTS, no localization; all UI strings are hard-coded English. |
| Intelligent pedestrian routing | None. Driving-only OSRM public demo; Walking/Cycling are honestly marked unsupported. |
| Geospatial environmental mapping | None. One Supabase table (`saved_places`). |
| On-device Edge AI | Only ML Kit's bundled models. No custom model runtime. |

**Toolchain results in this environment:**

| Check | Result |
|---|---|
| `flutter pub get` | ✅ resolves (Flutter 3.50.0 / Dart 3.14.0 — project was built on 3.38.4 / 3.10.3) |
| `flutter analyze` | ✅ 0 errors, 0 warnings; 43 `info` — all the same SDK-drift deprecation (`package:flutter/material.dart` deprecated after 3.47) **[observed]** |
| `flutter test` | ⚠️ **222 passed, 2 failed** (see §6.1) **[observed]** |
| Line coverage | 73.7% (1477/2004 lines) **[observed]** |
| `flutter build apk --debug` | ⛔ **not run** — the environment's network policy refuses `dl.google.com`, so the Android SDK cannot be installed here. No build result is claimed. |
| Integration test (`integration_test/app_test.dart`) | ⛔ not run — needs a device/emulator. |

**Recommended first milestone:** M0 "Stabilize the base" (see
`PHASE2_ROADMAP.md`): fix the two failing tests by making routing
injectable, fix the async-after-dispose defects in navigation, pin the
Flutter SDK, and add CI. It is small, low-risk, and every later milestone
depends on a trustworthy, hermetic test suite.

---

## 2. Environment and method

| Item | Value |
|---|---|
| Flutter used for audit | 3.50.0 stable (installed fresh into the session; not the project's pinned 3.38.4 — there is no pin file) |
| Android SDK | Not available (download host blocked by environment policy) |
| Device | None |
| `.env` | Created locally from `.env.example` (placeholders only, gitignored, not committed) because `pubspec.yaml` declares `.env` as an asset |
| Files changed by toolchain | `flutter pub get` on the newer SDK rewrote `pubspec.lock` (SDK-pinned transitive packages: `test_api`, `matcher`, `meta`, `vector_math`, `analyzer`, …) and injected an `analyzer: exclude:` block into `analysis_options.yaml`. **Both were reverted**; neither is part of this commit. |

Everything under `lib/`, `test/`, `integration_test/`, `android/`,
`supabase/`, and the six existing Markdown docs was read.

---

## 3. Dependency audit (`pubspec.yaml`)

| Package | Constraint | Used by | Status / risk for Phase 2 |
|---|---|---|---|
| `flutter_riverpod` | ^3.3.2 | All state | ✅ Current. Keep. Riverpod 3's `ref.mounted` should be used after every `await` (see §6.2). |
| `geolocator` | ^14.0.3 | `LocationService` | ✅ Foreground fused location. No foreground-service/background config. |
| `latlong2` | ^0.10.1 | App-wide coordinate type | ✅ Keep as the canonical `LatLng`. |
| `http` | ^1.6.0 | Geocoding, routing | ✅ Clients are injectable in services, **but not in the providers that construct them** (§6.1). |
| `camera` | ^0.12.0+2 | `CameraService` | ⚠️ Cannot share the camera with an ARCore session. Phase 2 perception during AR must take frames from ARCore instead (see Architecture §4). |
| `flutter_compass` | ^0.8.1 | `CompassService` | ⚠️ Stale upstream (noted in project docs). Only drives diagnostics. Phase 2 should read Android's rotation-vector sensor natively. |
| `sensors_plus` | ^7.1.0 | `MotionSensorService` | ✅ Fine for accelerometer/gyro at UI rates. Not designed for timestamp-accurate high-rate IMU logging (events carry no sensor timestamp in older APIs — verify on adoption). |
| `google_maps_flutter` | ^2.18.0 | `AppMapView` | ✅ Wrapped behind `AppMapController`/`AppMapView` — good abstraction. |
| `flutter_dotenv` | ^6.0.1 | Keys | ⚠️ `.env` is bundled into the APK as a plain asset — any key in it is extractable. Fine for the restricted Maps key and Supabase publishable key; **never** for an LLM/Cloud Vision key. |
| `google_mlkit_text_recognition` | ^0.16.0 | `VisionService` | ⚠️ **Latin script only** (`TextRecognizer()` default, `vision_service.dart:28`). ML Kit's on-device recognizer has no Tamil model, so Tamil road signs cannot be read today. |
| `google_mlkit_image_labeling` | ^0.15.0 | `VisionService` | ✅ Works; generic labels only, not detection boxes. |
| `supabase_flutter` | ^2.17.2 | Auth, saved places | ✅ RLS correctly enforced in `supabase/schema.sql`. |
| `meta` | ^1.17.0 | `@visibleForTesting` | ✅ |
| Native: `com.google.ar:core` | 1.54.0 | `MainActivity.kt` | ✅ Only `checkAvailabilityAsync` is used. |

Dev: `flutter_test`, `integration_test`, `flutter_lints ^6.0.0`, `fake_async`, `coverage` — all appropriate.

**Absent but needed for Phase 2** (justified in `PHASE2_TECH_STACK.md`):
an on-device ML runtime (LiteRT/TFLite), TTS, STT, localization
(`flutter_localizations`/`intl`), a local database for observations, a
wakelock, and an AR rendering stack.

---

## 4. Module-by-module audit (`lib/`)

Legend: **Real** = implemented and exercised by tests · **Diag-only** = real
but only reachable from the diagnostics screen · **Placeholder** = UI with
no behaviour behind it.

### 4.1 Location / GPS — **Real**
- `services/location_service.dart`: geolocator wrapper, `LocationAccuracy.high`, distance-filtered stream.
- `core/providers/location_provider.dart`: permission flow; accuracy gate (≤50 m) and min-movement filter (`location_filter.dart`); accuracy-weighted EMA smoothing (`position_smoothing.dart`, α 0.15–0.5); speed buckets with hysteresis that resubscribe the stream at 3/5/15 m filters (`speed_bucket.dart`); weak-signal flag after 3 consecutive rejected fixes.
- Gaps: no timestamps-based gap detection; no dead reckoning; EMA introduces lag proportional to speed (no velocity term); no foreground service, so tracking while the screen is off is not configured; no GNSS status (satellite count/CN0).

### 4.2 Compass / IMU / heading fusion — **Diag-only**
- `compass_provider.dart`, `motion_sensor_provider.dart`, `utils/heading_fusion.dart`.
- `fuseHeading` is an either/or switch (GPS course when driving, compass otherwise), not a filter.
- **Nothing outside `DiagnosticsScreen` consumes compass, IMU, or fused heading** **[inspection: grep]**. The doc comment at `widgets/map/app_map_view.dart:17` says `compassProvider` "still feed[s] navigation math" — that is inaccurate.

### 4.3 Map — **Real**
- `core/map/app_map_controller.dart` + `widgets/map/app_map_view.dart`: clean adapter over Google Maps with queued camera moves and user-gesture detection.
- Coverage of `AppMapController` is 7% (platform view can't be driven in unit tests).
- Map-follow/re-center wiring is duplicated across Home, Route Preview and Navigation screens.

### 4.4 Search / geocoding — **Real**
- `services/geocoding_service.dart`: Google Places API (New) Text Search, Tamil Nadu location bias, 10 s timeout.
- `search_provider.dart`: 400 ms debounce; session-only recent searches.
- Issues: (a) no stale-response guard — a slow earlier request can overwrite a newer one (`search_provider.dart:76-80`) **[inspection]**; (b) `X-Android-Cert` is hard-coded to the **debug** SHA-1 (`geocoding_service.dart:60`) — works only while the debug cert stays on the key's allow-list, and these headers are self-declared by the client, so they are not a security boundary.

### 4.5 Routing — **Real (driving only)**
- `services/routing_service.dart`: OSRM public demo server, `driving` profile, GeoJSON geometry + steps.
- The demo server is not licensed for production traffic and has no foot profile loaded (the project verified this).
- `RoutingService()` is constructed directly inside `RouteNotifier.build` (`route_provider.dart:52`) and `NavigationNotifier.build` (`navigation_provider.dart:166`) — not injectable, which is the root cause of §6.1.

### 4.6 Turn-by-turn navigation — **Real, with defects**
- `features/navigation/providers/navigation_provider.dart`: off-route (>40 m from polyline), wrong-direction (bearing >120° for 2 fixes), arrival (<25 m), automatic recalculation.
- Defects: see §6.2–6.4.
- Design limits: maneuver advancement requires passing within 25 m of each maneuver *point* (`:274`); there is no along-route progress / map-matching, so a skipped window (15 m distance filter + EMA lag) leaves the index stuck until a wrong-direction reroute fires. No voice guidance. No screen wakelock.

### 4.7 Camera — **Diag-only**
- `camera_provider.dart`, `features/ar_navigation/camera_preview_screen.dart`.
- No `WidgetsBindingObserver`/app-lifecycle handling: the `camera` plugin requires disposing the controller on `inactive` and re-initialising on `resumed`; without it the preview can fail after backgrounding **[inspection]**.

### 4.8 AR — **Capability check only**
- `services/ar_platform_service.dart` + `MainActivity.kt` MethodChannel → `ArCoreApk.checkAvailabilityAsync` with bounded transient polling. `<meta-data com.google.ar.core = optional>` is correct.
- No AR session, no pose, no anchors, no rendering. `CameraPreviewScreen` lives under `features/ar_navigation/` but is a plain camera preview.

### 4.9 Computer vision — **Diag-only, single frame**
- `vision_service.dart`, `vision_provider.dart`, `features/vision/vision_screen.dart`: `takePicture()` → ML Kit OCR (Latin) or image labeling.
- No streaming, no detection boxes, no tracking, no geotagging, Latin-only OCR.

### 4.10 Auth / saved places — **Real**
- Supabase email/password; RLS policies for select/insert/delete; no update policy (not needed today).
- Minor: error text at `auth_service.dart:97` names `SUPABASE_ANON_KEY`, but config reads `SUPABASE_PUBLISHABLE_KEY`.

### 4.11 UI shell — **Real, with placeholders**
- Splash → onboarding → home on **every launch** (no "seen onboarding" persistence) **[inspection]**.
- Placeholders: Home / Work / Recent quick actions (snackbar "coming soon"), AR Navigation button (disabled), Walking/Cycling modes (honest "unsupported" state).
- Strings are centralised in `core/constants/app_strings.dart` (good starting point for localization) but not localizable.
- Duplicated widgets: `_StatusMessage` (`camera_preview_screen.dart`) and `_CenteredMessage` (`vision_screen.dart`) are identical.

---

## 5. Android native configuration

| Item | Finding |
|---|---|
| Permissions | `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`, `INTERNET`, `CAMERA`. Missing for Phase 2: `RECORD_AUDIO` (voice), `FOREGROUND_SERVICE` + `FOREGROUND_SERVICE_LOCATION` and `POST_NOTIFICATIONS` (navigation with screen off), optionally `HIGH_SAMPLING_RATE_SENSORS` (>200 Hz IMU on Android 12+). |
| Features | `android.hardware.camera required=false` ✅. ARCore `optional` ✅. |
| SDK levels | `minSdk`/`targetSdk`/`compileSdk` from Flutter defaults (minSdk 24 per project docs). ARCore Geospatial and LiteRT GPU delegate are compatible. |
| Keys | Maps key injected from `android/local.properties` via `manifestPlaceholders` ✅ (not hardcoded). SETUP.md refers to `android/local.properties.example`, which **does not exist** in the repo. |
| Signing | Release keystore via gitignored `key.properties`, falls back to debug ✅. |
| R8 | `proguard-rules.pro` has real `-dontwarn` rules for ML Kit script recognizers ✅. Adding LiteRT/ARCore rendering libs will need new keep rules — verify with a release build each time. |
| Kotlin | Only `MainActivity.kt` (61 lines) — AR availability channel. |
| Fresh-clone build | `pubspec.yaml` declares `.env` as an asset and `.env` is gitignored, so `flutter build` on a fresh clone fails until `.env` is created **[inspection]**. SETUP.md documents the copy step, but CI will need it. |
| Gradle | AGP 8.11.1, Kotlin 2.2.20, Gradle 8.14, Java 17 target. `org.gradle.jvmargs=-Xmx8G` is heavy for CI runners. |
| iOS | Scaffolded only; `AppDelegate.swift` has a placeholder Maps key. Out of scope (Android primary). |

---

## 6. Defects found

### 6.1 Two failing tests — non-hermetic routing **[observed]**

```
test/features/navigation/providers/navigation_provider_test.dart:
  ✗ straying far from the polyline goes off-route and attempts a real recalculation
  ✗ sustained movement away from the next maneuver … triggers a real recalculation
Expected: NavigationStatus.offRoute   Actual: NavigationStatus.recalculating
```

- Root cause: `NavigationNotifier` hard-codes `RoutingService()`, so the test cannot inject a fake. It instead sets a global `HttpOverrides` with a 1 ms *connect* timeout and waits a **wall-clock 200 ms**, assuming the request fails within that window. In this environment the outbound request is routed through an egress proxy that refuses `router.project-osrm.org` but takes longer than 200 ms to do so. Reproduced 3/3 runs.
- These tests passed on the original Windows dev machine; they are **timing- and network-dependent**, not logically wrong.
- Fix (M0): add a `routingServiceProvider` (or `@visibleForTesting createService()` like `LocationNotifier`/`SearchNotifier` already use) and use a fake that fails deterministically.

### 6.2 Navigation state written after the provider is disposed **[observed]**
The same failing tests log: `Cannot use the Ref of NotifierProvider<NavigationNotifier…> after it has been disposed`, thrown from `_recalculate()` (`navigation_provider.dart:338-366`). The method writes `state` after `await _service.getDrivingRoute(...)` without checking `ref.mounted`. In the app this happens if the provider is disposed while a reroute request is in flight.

### 6.3 Stopping during a reroute can resurrect the session **[inspection]**
If the user taps **Stop** (`stop()`, `:213`) while `_recalculate()` is awaiting, the completion handler runs `state.copyWith(route: …, status: navigating)` on the freshly-reset idle state, producing an "active" session with `destination == null`. Needs a session token / generation counter checked after the `await`.

### 6.4 Remaining distance under-reports by the distance to the next maneuver **[inspection]**
`remainingDistance` (`:283`) sums `instructions.skip(index).distanceMeters`. OSRM step *i*'s distance runs from maneuver *i* to *i+1*, so the sum starts at the next maneuver and omits `distanceToManeuver`. ETA is derived from it, so it is also low.

### 6.5 Search stale-response race **[inspection]**
`_search` (`search_provider.dart:76`) has no request generation check; a slow response for an older query can overwrite results for the newer one.

### 6.6 Camera lifecycle not handled **[inspection]** — see §4.7.

### 6.7 Documentation drift **[inspection]**
- `app_map_view.dart:17` claims compass feeds navigation math (it doesn't).
- `PROJECT_STATUS.md` "Pending Tasks" still lists "First Git commit" and "Phase 14: Supabase" as pending; both are done.
- `geocoding_service.dart` comment says release signing "is still a TODO" — Phase 17 completed it.
- `auth_service.dart:97` names the old `SUPABASE_ANON_KEY`.

### 6.8 SDK drift **[observed]**
No Flutter version pin (`.fvmrc`/`flutter` in `environment:`). On the current stable SDK the analyzer emits 43 deprecation infos and `pub get` rewrites the lockfile. Pin the SDK before Phase 2 work starts so every milestone is measured on the same toolchain.

---

## 7. Test audit

| Area | Files | Notes |
|---|---|---|
| Pure utils | 11 | geo math, filters, smoothing, speed buckets, heading fusion, formatters, AR parsing, camera selection, vision mapping — strong. |
| Providers | 9 (+2 feature providers) | Use fake notifiers/streams; location provider uses `createService()` injection. |
| Services | 5 | Geocoding/routing use `MockClient` ✅; AR channel; auth/saved-places "not configured" paths. |
| Widgets / screens | 14 | Home, search, route preview, navigation, diagnostics, camera, vision, auth, saved places, onboarding, map view. |
| Integration | 1 | Boot → splash → onboarding only (needs device). |
| **Total** | **224 test cases** | 222 pass here, 2 fail (§6.1). |

Gaps that matter for Phase 2:
1. **No recorded-trace tests.** Every location test uses hand-written fixes; there is no replay of a real GPS/IMU session. Phase 2 fusion cannot be validated without this (see Roadmap M1).
2. Navigation edge cases untested: stop-during-reroute, disposal-during-reroute, remaining-distance correctness, maneuver-window skip.
3. No golden/visual tests; no performance (frame-time) tests.
4. `AppMapController` effectively untested (7%).
5. No CI — results depend on whoever runs them.

---

## 8. Implemented vs placeholder summary

| Feature | Status |
|---|---|
| GPS location, filtering, smoothing, weak-signal | ✅ Real |
| Google map, follow/re-center | ✅ Real |
| Places search | ✅ Real (needs paid key) |
| Driving route + preview | ✅ Real (demo server) |
| Turn-by-turn (visual) | ✅ Real, defects §6.2–6.4 |
| Walking / cycling routing | ⛔ Honestly unsupported |
| Compass / IMU / fused heading | 🔧 Diagnostics only |
| Camera preview | 🔧 Diagnostics only |
| OCR (Latin) / scene labels on one photo | 🔧 Diagnostics only |
| ARCore availability | 🔧 Diagnostics only |
| AR navigation | ⛔ Placeholder (disabled button) |
| Auth + saved places | ✅ Real |
| Home / Work / Recent shortcuts | ⛔ Placeholder |
| Voice, Tamil UI, AI agent, object detection, VIO, mapping | ⛔ Not started |

---

## 9. What this audit does not claim

- No Android build was performed in this session, so release-build health is taken from `PROJECT_STATUS.md` (Phase 16/17 entries), not re-verified.
- No device behaviour was observed. Inspection-only defects (§6.3–6.6) are hypotheses to confirm with tests.
- Library capability statements in the other Phase 2 documents describe what each library is documented to offer; each must be verified on the target device during its milestone before being presented as working.
