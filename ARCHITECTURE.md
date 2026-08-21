# Architecture

## Overview

The project uses a lightweight, feature-first structure under `lib/`.
Folders were created up front to establish the intended shape of the app,
but only the files needed for the current foundation milestone exist today.
Empty folders are placeholders for work that hasn't started yet.

```
lib/
├── core/
│   ├── constants/   # App-wide constant values (strings, sizes, keys)
│   ├── config/      # Environment/build configuration
│   ├── theme/       # Material 3 theme (app_theme.dart) — implemented
│   ├── utils/       # Shared pure-Dart helpers
│   └── errors/      # Exception/failure types
│
├── models/          # Data models (plain Dart, no backend yet)
│
├── services/        # Service layer (networking, storage, platform APIs)
│
├── features/         # One folder per user-facing feature (feature-first)
│   ├── splash/
│   ├── onboarding/
│   ├── home/         # Placeholder home screen — implemented
│   ├── search/
│   ├── route_preview/
│   ├── navigation/
│   ├── ar_navigation/
│   ├── saved_places/
│   ├── history/
│   ├── profile/
│   └── settings/
│
├── widgets/          # Shared/reusable widgets used across features
│
└── main.dart          # App entry point, wires theme + initial screen
```

## Principles

- **Feature-first**: each screen/flow gets its own folder under `features/`
  so related UI, state, and logic stay together as the app grows.
- **Lightweight now, structured later**: folders exist to signal intended
  organization, but files are only added when there's real content —
  no placeholder classes or empty barrel files.
- **No premature dependencies**: `core/services`, `models`, and feature
  folders are intentionally empty until the corresponding capability
  (maps, routing, AR, GPS, backend, etc.) is deliberately introduced.
- **Material 3 first**: `core/theme/app_theme.dart` defines a single
  source of truth for light/dark themes, seeded from one brand color.

## Current implementation

| Path | Status |
|---|---|
| `lib/main.dart` | App entry point; wraps app in `ProviderScope`, boots to `SplashScreen` |
| `lib/core/theme/app_colors.dart` | Seed + semantic colors |
| `lib/core/theme/app_typography.dart` | Shared type scale |
| `lib/core/theme/app_spacing.dart` | Spacing scale |
| `lib/core/theme/app_radius.dart` | Corner-radius scale |
| `lib/core/theme/app_theme.dart` | Composes the above into light/dark `ThemeData`, Material 3 |
| `lib/core/constants/app_strings.dart` | Centralized user-facing copy |
| `lib/widgets/buttons/app_button.dart` | Shared primary/secondary button |
| `lib/widgets/common/loading_indicator.dart` | Shared loading spinner |
| `lib/features/splash/splash_screen.dart` | Branded splash, auto-advances to onboarding |
| `lib/features/onboarding/onboarding_screen.dart` + `onboarding_page_data.dart` | 3-page onboarding flow |
| `lib/features/home/home_screen.dart` | Home dashboard shell (map placeholder, search, quick actions, travel mode, AR entry point) |
| `lib/features/home/widgets/*.dart` | Home-specific composed widgets (feature-scoped, not in the global `widgets/` folder) |
| `lib/features/home/providers/travel_mode_provider.dart` | First real Riverpod state (`NotifierProvider`) |
| `lib/models/location_model.dart` | `AppLocation` — decouples the app from geolocator's `Position` |
| `lib/services/location_service.dart` | Thin, swappable wrapper over `package:geolocator` |
| `lib/core/utils/location_filter.dart` | Pure GPS noise filter (`shouldAcceptLocationUpdate`) |
| `lib/core/providers/location_provider.dart` | `LocationState` sealed hierarchy + `LocationNotifier` — real permission→stream flow. `LocationAvailable` carries both the raw fix and a Phase 8 `smoothedLocation`; the notifier also drives Phase 8's speed-adaptive GPS sampling (cancels/resubscribes the position stream when the speed bucket changes). Phase 12: both `LocationRequesting` and `LocationAvailable` gained `weakSignal`, driven by real rejected-fix streaks (not elapsed time — see the Phase 12 note below). `withWeakSignalFlagged` is the pulled-out pure state-transform (tested) |
| `lib/core/utils/heading_fusion.dart` | `fuseHeading`/`FusedHeading`/`HeadingSource` — pure, tested GPS-course-vs-compass fusion (Phase 12), reusing Phase 8's `SpeedBucket` as the decision threshold |
| `lib/core/utils/position_smoothing.dart` | `smoothLocation`/`smoothHeadingDegrees` — exponential moving average (raw fix → smoothed position/speed/heading) so the map marker and navigation math don't jitter within GPS accuracy noise; accuracy/timestamp always pass through unsmoothed |
| `lib/core/utils/speed_bucket.dart` | `SpeedBucket` (stationary/walking/driving) + `speedBucketFor` (hysteresis-based transition) + `distanceFilterMetersForSpeedBucket` — coarser GPS sampling at higher speed, tuned for battery |
| `lib/features/home/widgets/current_location_badge.dart` | Shows the live GPS fix on the home screen |
| `lib/features/diagnostics/diagnostics_screen.dart` | Developer/technical readout (not shown prominently to normal users): location (Phase 12: shows `weakSignal`), Phase 8 smoothing, (Phase 9) a Camera status section + "Preview camera" action, (Phase 10) an AR status section + "Check AR support" action, and (Phase 12) a "Fused heading" section showing the live `fuseHeading` result and which source it picked |
| `lib/core/map/app_map_controller.dart` | (Phase 11: rewritten for `google_maps_flutter`) Wraps `GoogleMapController`; exposes `moveTo`/`fitBounds`/`userMovedMap`, plus the programmatic-move-suppression workaround `google_maps_flutter` needs (see ARCHITECTURE.md's Phase 11 map/geocoding note) |
| `lib/core/map/location_latlng.dart` | Bridges `AppLocation` to the map layer's `LatLng` |
| `lib/widgets/map/app_map_view.dart` | (Phase 11: rewritten for `google_maps_flutter`) The *only* file outside this layer that imports `package:google_maps_flutter`. Current location is Google's own native `myLocationEnabled` blue dot, not a custom marker |
| `lib/features/home/providers/map_follow_provider.dart` | Follow-mode on/off state |
| `lib/features/home/widgets/recenter_button.dart` | Shown only when follow mode is off |
| `lib/models/place_model.dart` | `Place` — decouples the app from the geocoding provider's response shape. `fromGooglePlacesJson` (Phase 11) replaced `fromNominatimJson` |
| `lib/services/geocoding_service.dart` | (Phase 11: rewritten for Google Places API (New)) Swappable wrapper (injectable `http.Client` + API key), reads `GOOGLE_MAPS_API_KEY` via `flutter_dotenv` |
| `lib/core/utils/distance_format.dart` | Shared "350 m" / "12.4 km" formatter (search now, routing/ETA later) |
| `lib/core/map/place_latlng.dart` | Bridges `Place` to the map layer's `LatLng` |
| `lib/core/providers/destination_provider.dart` | Selected destination — cross-feature (search writes, home's map reads) |
| `lib/features/search/` | Search screen, its provider (`SearchState` sealed hierarchy + debounce), recent searches, result tiles |
| `lib/models/route_model.dart` | `AppRoute` — distance, duration, polyline (uses `LatLng` directly; see "Routing" below) |
| `lib/services/routing_service.dart` | Swappable wrapper over OSRM's public demo API — Driving only |
| `lib/core/utils/duration_format.dart` | Shared "8 min" / "1 h 12 min" ETA formatter |
| `lib/core/providers/route_provider.dart` | `RouteState` sealed hierarchy + `RouteNotifier` — cross-feature (route preview writes/reads, home's map will read the polyline) |
| `lib/core/providers/travel_mode_provider.dart` | Selected travel mode — moved here from `features/home/providers/` in Phase 6 once the route preview screen needed it too (see "Cross-feature state" below) |
| `lib/widgets/travel/travel_mode_selector.dart` | Moved from `features/home/widgets/` in Phase 6 for the same reason — shared by home and route preview |
| `lib/features/route_preview/route_preview_screen.dart` | Real route preview: map + polyline, distance/ETA, mode selector, "Start Navigation" (enabled once a route is ready — opens `NavigationScreen`) |
| `lib/models/navigation_instruction.dart` | `NavigationInstruction` — one real turn-by-turn maneuver parsed from an OSRM route step, plus `buildInstructionText()` (client-side instruction text; OSRM's free API returns structured maneuvers, not sentences) |
| `lib/core/utils/geo_math.dart` | Pure-Dart great-circle geometry: `haversineMeters`, `distanceToSegmentMeters`/`distanceToPolylineMeters` (off-route detection), `bearingDegrees`/`angleDifferenceDegrees` (wrong-direction detection, also feeds Phase 8) |
| `lib/features/navigation/providers/navigation_provider.dart` | `NavigationState` + `NavigationNotifier` — real turn-by-turn session driven by `locationProvider`'s live GPS stream: current maneuver, distance/ETA, off-route + wrong-direction detection with automatic OSRM recalculation, arrival detection |
| `lib/features/navigation/navigation_screen.dart` | Real navigation UI: live map (route/position/destination), current-instruction card, status banners (off-route/wrong-direction/recalculating/paused/arrived), pause/resume/stop |
| `lib/features/navigation/widgets/maneuver_icon.dart` | Maps an OSRM maneuver type/modifier to a directional icon |
| `lib/widgets/map/recenter_button.dart` | Moved from `features/home/widgets/` in Phase 7 once `NavigationScreen` needed it too — same "don't generalize before a second consumer exists" rule as travel mode (Phase 6) |
| `lib/services/camera_service.dart` | Thin, swappable wrapper over `package:camera` — same pattern as `LocationService`/`RoutingService` |
| `lib/core/utils/camera_selection.dart` | Pure logic pulled out of the provider for testability: `pickPreferredCamera` (back camera preferred) and `isPermissionDeniedCode` (cross-platform `CameraException` code matching) |
| `lib/core/providers/camera_provider.dart` | `CameraState` sealed hierarchy + `CameraNotifier` — real permission→init flow for the device camera, mirroring `location_provider.dart`'s shape |
| `lib/features/ar_navigation/camera_preview_screen.dart` | Real live camera feed, no AR overlays yet (Phase 10). First file in this feature folder |
| `lib/core/utils/ar_availability.dart` | `ArAvailability` enum + `parseArCoreAvailability` — pure, tested mapping from ARCore's real result codes, pulled out of the service for testability (same reason as `camera_selection.dart`) |
| `lib/services/ar_platform_service.dart` | `ArPlatformService` — thin wrapper over a native `MethodChannel` that talks to Google's real ARCore SDK directly (not a third-party Flutter AR plugin — see "Camera — decided (Phase 9)" sibling note below for why) |
| `lib/core/providers/ar_availability_provider.dart` | `ArAvailabilityState` sealed hierarchy + `ArAvailabilityNotifier` — real device AR-capability check, mirroring `location_provider.dart`'s shape |
| `android/.../MainActivity.kt` | (Phase 10) Hosts the `tn_ar_navigation/ar_platform` `MethodChannel` handler, calling Google's `ArCoreApk.checkAvailabilityAsync` directly with the transient-result polling Google's own docs specify |
| `lib/models/compass_reading.dart` | `CompassReading` — decouples the app from `flutter_compass`'s `CompassEvent`, same reason as `AppLocation`; used by both diagnostics and the map |
| `lib/services/compass_service.dart` | `CompassService` — thin wrapper over `package:flutter_compass`, injectable stream for testing |
| `lib/core/providers/compass_provider.dart` | `CompassState` sealed hierarchy + `CompassNotifier` — real magnetometer heading, mirroring `location_provider.dart`'s shape. `compassStateFromEvent` is the pulled-out pure mapping function (tested) |
| `lib/services/motion_sensor_service.dart` | `MotionSensorService` — thin wrapper over `package:sensors_plus`'s accelerometer/gyroscope streams, injectable for testing |
| `lib/core/providers/motion_sensor_provider.dart` | `MotionSensorState` sealed hierarchy + `MotionSensorNotifier` — real IMU streams, diagnostics-only (see "Compass + IMU — decided (Phase 11)" below for why). `mergeMotionSensorReading` is the pulled-out pure merge function (tested) |
| `lib/models/text_recognition_result.dart` | `TextRecognitionResult` — decouples the app from `google_mlkit_text_recognition`'s `RecognizedText` |
| `lib/models/scene_label.dart` | `SceneLabel` — decouples the app from `google_mlkit_image_labeling`'s `ImageLabel`; a generic scene label, explicitly not a landmark identity (see "Computer vision" below) |
| `lib/core/utils/vision_mapping.dart` | `textRecognitionResultFromRecognizedText`/`sceneLabelsFromImageLabels` — pure, tested mapping from ML Kit's raw types to this app's own models |
| `lib/services/vision_service.dart` | `VisionService` — thin wrapper over ML Kit's `TextRecognizer`/`ImageLabeler`, both fully on-device (no network/cloud key). `isVisionSupportedOnThisPlatform` guards every call (Android/iOS only — neither plugin ships web/desktop) |
| `lib/core/providers/vision_provider.dart` | `VisionState` sealed hierarchy + `VisionNotifier` — real on-device text recognition + scene labeling (Phase 13) run against a single captured camera frame, mirroring `camera_provider.dart`'s shape |
| `lib/features/vision/vision_screen.dart` | Real live camera feed (reusing `cameraProvider`) with "Scan text"/"Label scene" actions and honest result panels. Reachable only from the diagnostics screen, same pattern as `CameraPreviewScreen` |
| `lib/core/config/supabase_config.dart` | `SupabaseConfig` — real Supabase project URL/publishable key from `.env`, and `isConfigured` (guards both `main.dart`'s `Supabase.initialize` call and every `AuthService`/`SavedPlacesService` method) |
| `lib/models/app_user.dart` | `AppUser` — decouples the app from `supabase_flutter`'s `User` |
| `lib/services/auth_service.dart` | `AuthService` — thin wrapper over `GoTrueClient` (email/password sign-up/sign-in/sign-out, a real auth-change stream), one `AuthServiceException` |
| `lib/core/providers/auth_provider.dart` | `AppAuthState` sealed hierarchy + `AuthNotifier` — real Supabase auth, mirroring `location_provider.dart`'s shape |
| `lib/features/auth/auth_screen.dart` | Real sign-in/sign-up form (single screen, two modes) |
| `lib/features/auth/account_screen.dart` | Signed-in email + sign-out + saved places entry point |
| `lib/models/saved_place.dart` | `SavedPlace` — wraps `Place` (Phase 5) plus a row id/timestamp |
| `lib/services/saved_places_service.dart` | `SavedPlacesService` — thin wrapper over the real `saved_places` Postgres table; Row Level Security (`supabase/schema.sql`), not this class, is the real access boundary |
| `lib/core/providers/saved_places_provider.dart` | `SavedPlacesState` sealed hierarchy + notifier, mirroring `search_provider.dart`'s shape |
| `lib/features/saved_places/saved_places_screen.dart` | Real saved-places list with delete; reachable from `AccountScreen`, the home screen's "Saved" quick action, and route preview's "Save this place" |
| `supabase/schema.sql` | Real schema (table + RLS policies) for the project owner to run in the Supabase SQL Editor — this session has no direct database access |
| All other folders | Structure only, no files yet |

Note: Riverpod 3.x moved the old `StateProvider` behind
`package:riverpod/legacy.dart`. `travel_mode_provider.dart` and
`location_provider.dart` use the current, non-legacy
`Notifier`/`NotifierProvider` API instead.

`lib/core/providers/` holds cross-feature Riverpod state (state more than
one feature needs, like location or the selected travel mode);
`lib/features/<feature>/providers/` holds state scoped to a single
feature (like home's map-follow toggle). Travel mode moved from the
latter to the former in Phase 6, once the route preview screen needed it
too, not before — the same "don't generalize before a second consumer
exists" rule the map/geocoding layers already follow.

## Target architecture (full vision, built incrementally)

The folder layout above will fill in as each phase lands. This is the
intended shape once the roadmap in `PROJECT_STATUS.md` / `DEVELOPMENT.md`
completes — nothing below exists yet unless marked "implemented" in the
table above.

```
lib/
├── core/
│   ├── constants/ config/ theme/ utils/ errors/ permissions/
├── models/
│   ├── location_model.dart, route_model.dart, waypoint_model.dart,
│   │   navigation_instruction.dart, place_model.dart, user_model.dart
├── services/
│   ├── location_service.dart, routing_service.dart, map_service.dart,
│   │   geocoding_service.dart, compass_service.dart, sensor_service.dart,
│   │   navigation_service.dart, ar_service.dart, vision_service.dart,
│   │   backend_service.dart
├── features/  (splash, onboarding, authentication, home, search,
│               route_preview, navigation, ar_navigation, saved_places,
│               history, profile, settings)
├── widgets/   (map/, navigation/, buttons/, cards/, search/, common/)
└── main.dart
```

Each `services/*.dart` file is added only when its phase begins, and each
is designed behind a small interface so the concrete implementation can
be swapped later (see "Provider abstractions" in `DEVELOPMENT.md`):
`MapProvider`, `RoutingProvider`, `GeocodingProvider`,
`NavigationProvider`, `ARPlatformService`, `VisionService`.

## Next architectural decisions

- **State management:** Riverpod (`flutter_riverpod`) — chosen per
  project spec, not yet added; introduced at the start of Phase 2.
- **Navigation state — decided (Phase 7), supersedes the original sketch
  below:** `navigationProvider` (`NavigationState` + `NavigationNotifier`
  in `lib/features/navigation/providers/navigation_provider.dart`).
  Deliberately narrower than the original sketch: no
  `PREPARING_ROUTE`/`ROUTE_READY` phase, since `routeProvider` already
  owns that fetch for the route preview screen and `start()` only ever
  begins from an already-computed `AppRoute` — two providers modeling the
  same fetch would be redundant. Also omits heading, AR status, and
  permission status fields, since those belong to sensor fusion
  (Phase 11) and AR (Phase 10) and would be unpopulated/fake here. The
  status enum that did ship: `idle`, `navigating`, `approachingTurn`,
  `turning`, `offRoute`, `wrongDirection`, `recalculating`, `arrived`,
  `paused`. Off-route detection uses `distanceToPolylineMeters`
  (`core/utils/geo_math.dart`) against a 40 m threshold; wrong-direction
  detection compares real movement bearing to the bearing toward the next
  maneuver (120°, sustained over 2 consecutive GPS updates, to ignore
  GPS jitter and ordinary road curvature). Both trigger an automatic OSRM
  recalculation via the same `RoutingService` the route preview screen
  uses — no separate recalculation backend.
- **Live tracking — decided (Phase 8):** rather than a new provider,
  hardens the existing `locationProvider`/`LocationNotifier` in place, so
  every consumer (home map, route preview, navigation) benefits without
  each having to opt in separately. Two additions: (1) `smoothLocation`
  (`core/utils/position_smoothing.dart`) — an exponential moving average
  applied *after* `location_filter.dart`'s existing accept/reject check —
  exposed as `LocationAvailable.smoothedLocation` alongside the untouched
  raw fix, so map/navigation math reads the smoothed value while
  diagnostics/the GPS badge keep showing ground truth; (2) speed-adaptive
  sampling (`core/utils/speed_bucket.dart`) — `LocationNotifier` tracks a
  `SpeedBucket` (stationary/walking/driving, hysteresis-based to avoid
  flapping) and cancels/resubscribes `Geolocator`'s position stream with
  a wider `distanceFilter` at higher speed, trading fix density for
  battery. Wrong-direction detection (bearing comparison) already shipped
  in Phase 7 rather than here, since `NavigationNotifier` needed it
  immediately.
- Original sketch, superseded above (kept for history): a single
  Riverpod-managed state object (current location, heading, speed, GPS
  accuracy, destination, route, current waypoint, next maneuver, distance
  to maneuver, remaining distance, ETA, navigation status, off-route
  status, recalculation status, AR status, permission status) plus a
  state machine of `IDLE` → `PREPARING_ROUTE` → `ROUTE_READY` →
  `NAVIGATING` → `APPROACHING_TURN`/`TURNING` → `OFF_ROUTE` →
  `RECALCULATING` → `ARRIVED`, with `PAUSED`/`ERROR` as side states.
- **Camera — decided (Phase 9):** `package:camera`, wrapped by
  `CameraService` (real device call + controller init) and
  `cameraProvider`/`CameraNotifier` (`CameraState`: initial/requesting/
  available/unavailable/permission-denied/error), the same
  service-plus-notifier shape as `LocationService`/`locationProvider`.
  (Phase 10 update: `ArPlatformService` ended up *not* building on this
  `CameraController` — see the Phase 10 note below for why.) **Not**
  wired to the home screen's "AR Navigation" button —
  that stays disabled until Phase 10 actually has AR overlays behind it;
  the camera feed is reachable only from the diagnostics screen for now
  (`CameraPreviewScreen`), the same "prove it works via diagnostics
  before it's a first-class user-facing entry point" path Phase 3 used
  for GPS before Phase 4's map existed.
- **AR platform check — decided (Phase 10), scoped down from the original
  plan:** the Flutter/ARCore community plugin ecosystem was researched
  when this phase started and found unmaintained or unproven across the
  board — the plugin most tutorials reference hasn't shipped since late
  2022 and won't resolve against this project's Dart version at all;
  every remaining option is either ~2 years stale or (the one actively
  updated fork) a single day old with under 100 downloads. Given this
  machine has no Android device to verify AR rendering behavior against,
  adopting any of them for real AR content was judged too risky for the
  production path — see KNOWN_LIMITATIONS.md and PROJECT_STATUS.md's
  Phase 10 entry for the full comparison. Instead, this phase talks to
  Google's own ARCore SDK directly: `ArPlatformService`
  (`lib/services/ar_platform_service.dart`) calls a `MethodChannel`
  (`tn_ar_navigation/ar_platform`) whose only native handler lives in
  `MainActivity.kt` and calls `ArCoreApk.checkAvailabilityAsync` — a real
  device/software capability check (supported / needs a Play Store
  update / unsupported hardware / unknown), with no AR *rendering* yet.
  This is intentionally independent of `CameraService`/`CameraController`
  (Phase 9) — ARCore's own camera access happens inside its session once
  rendering exists, not through this app's `camera`-package controller —
  so Phase 9's abstraction and this one don't currently share code. A
  future AR-rendering pass (once a plugin proves itself, or a device is
  available to verify against) would sit on top of both.
- **Compass + IMU — decided (Phase 11):** `flutter_compass` (real
  device heading) and `sensors_plus` (real accelerometer/gyroscope),
  both verified maintained and resolvable before adopting (a real
  problem in this exact space — see the Phase 10 AR entry above). Two
  independent providers, not one combined "sensors" provider, since
  they have different real consumers and different honest
  "unavailable" semantics: `compassProvider`/`CompassNotifier`
  (`core/providers/compass_provider.dart`) feeds the map's heading beam
  and diagnostics, with a first-class `CompassUnavailable` state (some
  Android devices genuinely report no magnetometer);
  `motionSensorProvider`/`MotionSensorNotifier`
  (`core/providers/motion_sensor_provider.dart`) is diagnostics-only —
  `sensors_plus` exposes no "is this sensor present" check the way
  `flutter_compass` does, so rather than fake an unavailability signal
  from a timeout, it honestly stays "waiting for a reading" for
  whichever of accelerometer/gyroscope hasn't reported yet. No
  dead-reckoning/sensor-fusion consumer of the raw IMU data exists yet
  — Phase 12 (below) decided real GPS-course/compass heading fusion,
  not raw-IMU dead-reckoning, so accelerometer/gyroscope stay
  diagnostics-only for now. `AppMapView` originally gained an optional
  `headingDegrees`
  and a custom rotating directional-beam marker for this — **superseded
  later the same day** by the Phase 11 map/geocoding provider switch
  below: Google's native `myLocationEnabled` blue dot renders its own
  real heading cone at the platform level, making the custom beam
  redundant, so it was removed rather than left as unused code.
  `compassProvider` itself wasn't removed — it still feeds the
  diagnostics screen, independent of the map.
- **Hybrid localization — decided (Phase 12):** scoped down from "full
  sensor fusion" to two real, achievable pieces, after weighing a third
  option (full inertial dead-reckoning) and rejecting it — see
  PROJECT_STATUS.md's Phase 12 entry for why.
  1. **GPS-gap detection**: `LocationState.weakSignal` (on both
     `LocationRequesting` and `LocationAvailable`) is driven by a real
     signal — `LocationNotifier` counts *consecutive rejected* raw fixes
     (real candidates that fail `location_filter.dart`'s accuracy check)
     and flags weak signal after 3 in a row. Deliberately **not** driven
     by elapsed time since the last accepted fix: `LocationService`'s
     distance-filtered stream only emits on real movement past its
     filter (Phase 8), so silence alone can't distinguish "GPS signal is
     weak" from "device just hasn't moved" — a timeout-based detector
     would false-positive for a stationary user with perfectly good GPS.
     This is exactly the real ambiguity found testing Phase 11 on a real
     device indoors (KNOWN_LIMITATIONS.md): raw fixes kept arriving
     (verified via a temporary diagnostic log) at ~85-100m accuracy,
     correctly rejected — that observed pattern (real candidates,
     consistently rejected) is what `weakSignal` now detects for real.
     `withWeakSignalFlagged` applies the flag to whichever state variant
     is current without touching the real fix data already shown.
  2. **Heading fusion**: `fuseHeading` (`core/utils/heading_fusion.dart`)
     picks between the two real heading sources this app already had —
     GPS course-over-ground (Phase 3, smoothed in Phase 8) and
     magnetometer compass (Phase 11) — rather than average/blend them,
     since a real blend would need calibration this project has no way
     to validate here. Reuses Phase 8's `SpeedBucket` as the decision
     threshold instead of inventing a new one: GPS course is only
     reliable with real sustained movement, so it's preferred once
     `SpeedBucket.driving`; the compass is preferred otherwise (a
     stationary/slow GPS course is mostly noise), with each source used
     as a fallback if the preferred one isn't available. Surfaced live
     in `DiagnosticsScreen` (a "Fused heading" section showing the
     result and which source was picked) — the same "prove it via
     diagnostics before it's a first-class consumer" path every sensor
     phase in this project has used; no map/navigation consumer needed
     it yet.
  3. **Full inertial dead-reckoning — considered, not built.** Using the
     accelerometer/gyroscope to estimate device displacement during a
     real GPS gap (e.g. a tunnel) would add real value for a nav app,
     but double-integrating raw acceleration drifts fast without
     step-length/device calibration this project has no way to validate
     on this dev machine — shipping an uncalibrated position estimate
     as if it were real position would risk violating the project's "no
     faked functionality" rule the moment the estimate diverges from
     reality. Not ruled out permanently, just not attempted this phase;
     `motionSensorProvider`'s raw accelerometer/gyroscope streams
     (Phase 11) remain diagnostics-only.
- **Computer vision — decided (Phase 13), scoped down from the original
  ask:** the owner's original ask covered landmark/POI recognition,
  street-sign text recognition, and lane/road detection for AR overlay,
  all on-device. Researching what on-device ML Kit for Flutter actually
  offers (before writing any code, per the Phase 10 AR research
  discipline) found two of the three don't map onto a real on-device
  model: true landmark *identification* only exists in the cloud-only
  Google Cloud Vision Landmark Detection API — no on-device ML Kit module
  does this — and lane/road *segmentation* has no stock ML Kit model at
  all (its Object Detection & Tracking does generic bounding boxes, not
  lane lines). Presented both gaps to the owner, who chose to build what's
  real — `google_mlkit_text_recognition` (real street-sign OCR) and
  `google_mlkit_image_labeling` (generic scene labels — "temple," "tower,"
  "building" — as an honest, explicitly-not-landmark-ID substitute) — and
  defer the rest, same "scope down after research, don't fake the rest"
  pattern Phase 10 used for AR rendering. Both recognizers run against a
  **single captured frame**, not a continuous stream: `VisionScreen`
  reuses Phase 9's `cameraProvider` for the live preview, then
  `CameraController.takePicture()` + `VisionService` on demand — avoids
  the `CameraImage` YUV→`InputImage` rotation/format handling a live
  scanner would need, and keeps battery/perf cost bounded, the same
  "ask/run only when actually needed" discipline camera (Phase 9) and
  compass (Phase 11) established. A real, non-obvious version constraint
  surfaced while adopting: the latest `google_mlkit_text_recognition`/
  `google_mlkit_image_labeling` require Dart SDK ≥3.12.0, above this
  project's 3.10.3 — resolved by `flutter pub add` picking the highest
  versions that actually satisfy this project's SDK (0.16.0/0.15.0)
  rather than the pub.dev-listed latest. `VisionService` is independent of
  `ArPlatformService`/`CameraService` beyond reusing `cameraProvider` for
  the live feed — ML Kit's recognizers take a plain image file, not a
  camera session, so there's no deeper coupling to unwind later.
  **Real bug found and fixed via a live device (2026-08-21)**: both
  `VisionScreen` and Phase 9's `CameraPreviewScreen` called
  `ref.read(cameraProvider.notifier).start()` synchronously from
  `initState()` — Riverpod 3.x forbids mutating provider state during a
  widget life-cycle method, so this threw an "Unhandled Exception: Tried
  to modify a provider while the widget tree was building" inside the
  unawaited `Future`, silently freezing the screen at `CameraRequesting`
  forever (see PROJECT_STATUS.md's real-device verification entry for the
  full root-cause trace). Fixed by deferring both calls with
  `WidgetsBinding.instance.addPostFrameCallback`, Riverpod's own
  documented remedy — `CameraNotifier`/`CameraService` were untouched,
  since the bug was in the calling pattern, not the notifier. See
  KNOWN_LIMITATIONS.md for what's deferred and what's still unverified.
- **Backend/auth — decided (Phase 14), scoped to auth + saved places this
  round:** Supabase (`supabase_flutter`), verified maintained/resolvable
  before adopting (same diligence every prior package adoption used —
  no SDK-version surprise this time, unlike Phase 13's ML Kit packages).
  Email/password auth was chosen over magic link/OAuth after presenting
  the real tradeoff to the project owner: both alternatives are genuine
  options but need meaningfully more setup (email deliverability + deep
  linking, or a Google Cloud OAuth client + platform redirect config),
  the same category of cost Phase 11's Maps key introduced — email/
  password needed zero extra native platform config. A real, current-API
  correction was needed before shipping: `Supabase.initialize`'s
  `anonKey` parameter is deprecated in `supabase_flutter` 2.17 in favor
  of `publishableKey` (Supabase is mid-migration from "anon key" to
  "publishable key" terminology across its SDK *and* dashboard) — used
  `publishableKey` throughout, including the `.env` variable name, so
  nothing here points at stale terminology. `SupabaseConfig.isConfigured`
  guards two different things for two different reasons:
  `main.dart` never calls `Supabase.initialize` with a placeholder URL
  (which would throw and crash app *boot*, unlike `GeocodingService`'s
  lazy per-request key check), and `AuthService`/`SavedPlacesService`
  never touch `Supabase.instance` before it exists. History and
  preferences (also part of DEVELOPMENT.md's Phase 14 module map) were
  deliberately deferred to keep this phase reviewable — same incremental
  discipline every prior phase followed; see PROJECT_STATUS.md's Phase 14
  entry and KNOWN_LIMITATIONS.md for what's deferred. **Verified
  end-to-end on a real device against a real Supabase project
  (2026-08-21)**, which surfaced two real auth bugs (`signUp` checked
  `response.user` instead of `response.session`, and
  `RoutePreviewScreen` showed a false-positive "Place saved." without
  checking the real outcome) plus an unrelated real Navigator race in
  the search → route-preview flow, all fixed — see PROJECT_STATUS.md's
  real-device verification entry and KNOWN_LIMITATIONS.md for the full
  detail.
- **Navigation/routing-in-app package** (e.g. `go_router`) — once real
  multi-screen navigation exists (Phase 2 onward).
- **Map data strategy — decided (Phase 4), superseded (Phase 11):**
  `flutter_map` (OpenStreetMap-based). Rather than a separate
  `MapProvider` interface class, the concrete abstraction is two files:
  `AppMapController` (wraps the map package's controller —
  move/rotate/camera + a gesture-vs-programmatic move signal) and
  `AppMapView` (the one widget that imports the map package). Every
  other file — `HomeScreen` included — depends on those two types, not
  on the map package directly. This "lightweight, two-file abstraction
  instead of a full pluggable-provider interface" design mostly held up
  when Phase 11 actually swapped providers: `AppMapController`/
  `AppMapView` absorbed the real rewrite, and no feature screen needed
  to know Google Maps exists. The one real gap in the original
  prediction: `AppMapView.currentLocation`/`headingDegrees` (added
  same-day for the compass heading beam, see above) became dead
  parameters once Google's native location layer replaced that marker,
  so `HomeScreen`/`RoutePreviewScreen`/`NavigationScreen` each needed a
  small edit to stop passing them — "feature code untouched" held for
  the map *provider*, not for a marker feature built the same day the
  provider changed underneath it.
- **Follow mode** (Phase 4): `mapFollowProvider` (bool) — on by default,
  turned off by `AppMapController.userMovedMap` (any user gesture),
  turned back on by Locate Me or the Re-center button. This is the
  general "map follows the user, exit on manual pan, re-center button"
  behavior the project spec calls for; Phase 7/8 (turn-by-turn, live
  tracking) will reuse this rather than inventing a separate mechanism.
- **Geocoding — decided (Phase 5), superseded (Phase 11):** OpenStreetMap
  Nominatim's public search API via a direct `GeocodingService` (plain
  `http` calls), the same "one concrete swappable class, no abstract
  interface until a second implementation actually exists" pattern as
  the map layer.
- **Geocoding relevance tuning (2026-08-20, Nominatim-era, superseded
  same day):** `GeocodingService.search` briefly passed a `viewbox`
  covering Tamil Nadu's real published extent alongside `countrycodes`,
  to bias Nominatim's ranking toward in-state results without hard-
  excluding anything outside it. This was a ranking improvement only,
  not a data-coverage fix — real user feedback the same day was that
  Nominatim/OSM's actual point-of-interest density in Tamil Nadu (not
  just ranking) was the real problem, which no query tuning could close.
  That feedback is what triggered the Phase 11 provider switch below;
  the `locationBias` on the new Places API service is the direct
  successor to this `viewbox`.
- **Map & geocoding provider — decided (Phase 11), supersedes both
  entries above:** switched from the free OpenStreetMap stack
  (flutter_map tiles + Nominatim search) to Google Maps Platform
  (`google_maps_flutter` for the map, Places API (New) for search),
  in response to real user feedback that Nominatim's Tamil Nadu POI
  coverage was too sparse ("only districts and bus stands") for the
  destination-finding this app needs — a genuine data-completeness gap,
  not a bug in the old query code (see KNOWN_LIMITATIONS.md for the
  full comparison). Both replacements kept their predecessor's public
  interface: `AppMapController`/`AppMapView` (map) and `GeocodingService`
  returning `List<Place>` (search) are unchanged in shape, only their
  internals moved — no feature screen had to be rewritten for the
  search side (`SearchNotifier`/`SearchScreen` are untouched); the map
  side needed the small `AppMapView.currentLocation`/`headingDegrees`
  cleanup noted above. Real cost/setup implications this project hasn't
  carried before: Google Maps Platform requires a real, billing-enabled
  Google Cloud API key — there is no free public endpoint to fall back
  to the way Nominatim/OSRM's demo servers were. See SETUP.md for the
  real steps to obtain and configure one, and KNOWN_LIMITATIONS.md for
  what remains unverified without one.
- **Search → route preview** (Phase 6, supersedes the Phase 5 note below):
  selecting a search result still sets `selectedDestinationProvider` and
  shows a marker on the home map, but — now that real routing data
  exists — also opens `RoutePreviewScreen`, which calculates and shows a
  real route (Driving) from the current GPS fix to that destination. If
  no GPS fix exists yet, the app shows an honest snackbar instead of
  opening a screen with nothing to route from.
- **Routing — decided (Phase 6):** OSRM's public demo API
  (`router.project-osrm.org`) via a direct `RoutingService` (plain `http`
  calls, no new dependency — reuses the `http` package added in Phase 5),
  the same "one concrete swappable class, no abstract interface until a
  second implementation actually exists" pattern as the map and
  geocoding layers. Driving only — see KNOWN_LIMITATIONS.md for why
  Walking/Cycling aren't real on this backend. `AppRoute`
  (`models/route_model.dart`) is the one model that depends on `LatLng`
  directly rather than going through a `core/map/*_latlng.dart` bridge
  file, because a route's polyline has no purpose outside being drawn on
  a map (unlike `AppLocation`/`Place`, which are also used in non-map
  contexts like the diagnostics screen and search results).
- **Search → destination, not search → route preview (superseded by
  Phase 6 above)** (Phase 5): selecting a search result set
  `selectedDestinationProvider` and showed a marker on the real map, but
  did not open a Route Preview screen, since that needed real
  distance/duration/route geometry that didn't exist until Phase 6. Kept
  here for history; see the Phase 6 entry above for current behavior.
