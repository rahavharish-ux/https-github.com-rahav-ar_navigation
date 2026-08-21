# Project Status

_Last updated: 2026-08-21 (Phase 17)_

## Environment

| Tool | Version |
|---|---|
| Flutter | 3.38.4 (stable channel) |
| Dart | 3.10.3 |
| Android SDK | 36.1.0 (platform android-36, build-tools 36.1.0) |
| Java | OpenJDK 21 (bundled with Android Studio) |
| Target platforms | Android (primary), iOS (scaffolded, not yet verified), Web (dev-only, added for local UI verification) |

`flutter doctor` reports the Android toolchain and Windows desktop/Chrome/Edge
as fully configured. Visual Studio (Windows desktop C++ toolchain) is
incomplete, which is irrelevant to this project's Android-first target.
Web platform support (`web/`) was added during Phase 2 purely so the UI
could be visually verified in Chrome on this development machine (no
Android emulator/device is available here) — it is not a product target
and can be removed without affecting Android/iOS.

## Overall Status: Phase 17 (Production build) complete — the 17-phase roadmap is done. A real release-signing keystore was generated and wired in, verified with a real signed release build on-device; Supabase email confirmation was re-enabled and verified end-to-end with a real confirmation email. See KNOWN_LIMITATIONS.md for what real-world distribution still needs (Play Console listing, backend API-key proxying, iOS) before this app could actually ship

This project follows a 17-phase incremental roadmap (see below). No
feature-specific packages (maps, routing, AR, AI, GPS, camera, sensors,
Supabase) have been installed — those are added deliberately, one at a
time, as their phase begins.

## Phase Roadmap

| # | Phase | Status |
|---|---|---|
| 1 | Project foundation | **Complete** |
| 2 | UI/UX (design system, screen shells) | **Complete** |
| 3 | Location/GPS | **Complete** |
| 4 | Map | **Complete** |
| 5 | Search | **Complete** |
| 6 | Routing | **Complete** |
| 7 | Turn-by-turn navigation | **Complete** |
| 8 | Live tracking | **Complete** |
| 9 | Camera | **Complete** |
| 10 | AR navigation | **Capability check complete; rendering deferred** |
| 11 | Compass + IMU | **Complete** |
| 12 | Hybrid localization | **Complete** |
| 13 | Computer vision | **Complete** (scoped to real on-device OCR + scene labeling; landmark ID and lane detection deferred — see below) |
| 14 | Backend (Supabase) | **Complete** — auth + saved places built, tested, and verified end-to-end on real hardware against a real Supabase project; history/preferences deferred |
| 15 | Testing (expanded) | **Complete** — flagged gaps closed, LCOV coverage added, real on-device integration testing added and verified live |
| 16 | Optimization | **Complete** — release build fixed (was silently broken), APK size cut ~45%, real frame-timing verified good, accuracy-weighted GPS smoothing added |
| 17 | Production build | **Complete** — real release signing generated and verified; Supabase email confirmation re-enabled and verified end-to-end |

Each phase must end with: app runs, feature tested, analyzer clean,
Android build verified, docs updated — before the next phase starts.

## Completed Tasks

### Phase 1 — Foundation
- [x] Verified working directory and Flutter/Dart versions match requirements
- [x] Created `tn_ar_navigation` Flutter app (Android + iOS platforms)
- [x] Inspected generated `pubspec.yaml`, `android/`, `lib/`, `test/`,
      `analysis_options.yaml`, `.gitignore`
- [x] Created lightweight `lib/` architecture (core, models, services,
      features/*, widgets)
- [x] Set up Material 3 theme foundation (`lib/core/theme/app_theme.dart`)
      with light/dark variants
- [x] Built placeholder home screen ("TN AR NAV" / "AR Navigation for
      Tamil Nadu")
- [x] `flutter pub get`, `flutter analyze`, `flutter test` — all passed
- [x] `flutter build apk --debug` — passed, produced
      `build/app/outputs/flutter-apk/app-debug.apk`
- [x] Initialized Git repository
- [x] Verified Dart/Flutter MCP tools are exposed and functional
      (`list_devices`, `analyze_files` tested live)
- [x] Created `PROJECT_STATUS.md`, `ARCHITECTURE.md`, `SETUP.md`, `README.md`

### Foundation Cleanup milestone (2026-08-14)
- [x] Audited `lib/main.dart` — confirmed single root widget
      (`TnArNavigationApp`), no leftover template code (`MyApp`,
      `MyHomePage`, counter demo), no duplicate `MaterialApp`/`runApp`/`home`
- [x] Confirmed app title is "TN AR Navigation"
- [x] Confirmed `MaterialApp` has `theme` (light), `darkTheme` (dark),
      Material 3 enabled via `AppTheme`, and
      `debugShowCheckedModeBanner: false`
- [x] Audited `test/widget_test.dart` — confirmed clean smoke test only
      (renders `TnArNavigationApp`, checks "TN AR NAV" and
      "AR Navigation for Tamil Nadu" are visible); no leftover counter test
- [x] Ran `dart format .` (the current SDK replaces `flutter format` with
      `dart format`) — reformatted 2 files, whitespace only, no logic
      changes
- [x] `flutter analyze` — No issues found
- [x] `flutter test` — 1/1 passed
- [x] `flutter build apk --debug` — passed
- [x] Confirmed no unnecessary dependencies were added
      (`pubspec.yaml` still only has `flutter`, `cupertino_icons`,
      `flutter_test`, `flutter_lints`)

### Phase 2 — UI/UX (2026-08-14)
- [x] Added `flutter_riverpod` (3.3.2) — the project's only new runtime
      dependency this phase
- [x] Design system tokens: `AppColors`, `AppTypography`, `AppSpacing`,
      `AppRadius` under `lib/core/theme/`; `AppTheme` rewritten to compose
      them (light/dark, Material 3, consistent button/segmented-button
      shapes)
- [x] Centralized user-facing copy in `lib/core/constants/app_strings.dart`
      (a lightweight step toward future localization, not full l10n)
- [x] Shared reusable widgets: `AppButton` (primary/secondary),
      `LoadingIndicator`
- [x] Built `SplashScreen` (branded, auto-advances to onboarding after 2s)
- [x] Built `OnboardingScreen` (3-page swipeable flow with Skip/Next/Get
      Started, matching the required copy; explains GPS/camera/sensors
      without requesting any real permissions yet)
- [x] Rebuilt `HomeScreen` as a dashboard shell: header, full-bleed map
      placeholder (explicitly labeled, not a real map), locate-me button,
      destination search card, Home/Work/Recent/Saved quick actions,
      Driving/Walking/Cycling travel mode selector (real Riverpod state),
      disabled "AR Navigation" button labeled as a future phase
- [x] Every not-yet-real control (search, quick actions, locate-me, AR
      button) gives honest "arrives in a later phase" feedback instead of
      doing nothing or faking a result
- [x] Added `TravelModeNotifier`/`travelModeProvider` using Riverpod's
      current `NotifierProvider` API (the legacy `StateProvider` needed a
      `package:riverpod/legacy.dart` import in Riverpod 3.x — used the
      non-legacy replacement instead)
- [x] `dart format .`, `flutter analyze` (No issues found), `flutter test`
      (5/5 passed: app boot → splash → onboarding smoke test, onboarding
      page-advance tests, home screen content + interaction tests)
- [x] `flutter build apk --debug` — passed
- [x] Added `web/` platform (dev-only) and ran the app live in Chrome to
      visually confirm splash → onboarding → home renders with no compile
      errors or runtime exceptions in the console; full automated
      screenshot verification wasn't available this session (no browser
      automation connected; the MCP `get_widget_tree`/`get_runtime_errors`
      tools rejected the connection with an SDK version-check error even
      though Dart 3.10.3 exceeds the stated minimum — see Known
      Limitations)

### Phase 3 — Location/GPS (2026-08-14)
- [x] Added `geolocator` (14.0.3) — the only new dependency this phase
      (decided against also adding `permission_handler`: geolocator's own
      permission API already covers what's needed, avoiding a redundant
      dependency until a broader permission need — e.g. camera — arrives)
- [x] Added `ACCESS_FINE_LOCATION`/`ACCESS_COARSE_LOCATION` to the Android
      manifest, and `NSLocationWhenInUseUsageDescription` to iOS's
      `Info.plist` (when-in-use only — no background location requested,
      per the project's privacy-by-default rule)
- [x] `AppLocation` model (`lib/models/location_model.dart`) decouples the
      app from geolocator's `Position` type
- [x] `LocationService` (`lib/services/location_service.dart`) — thin,
      swappable wrapper over `package:geolocator`
- [x] `shouldAcceptLocationUpdate` (`lib/core/utils/location_filter.dart`)
      — a real noise filter: rejects fixes worse than 50m accuracy, and
      ignores sub-2m movements unless the new fix is more accurate than
      the one it would replace (prevents the future map marker from
      jumping on GPS noise, per the project's "filter noisy GPS readings"
      requirement)
- [x] `LocationState` sealed hierarchy + `LocationNotifier`
      (`lib/core/providers/location_provider.dart`): `Initial` →
      `Requesting` → (`ServiceDisabled` | `PermissionDenied` |
      `Available` | `Error`) — models the real permission→stream flow
      as a small state machine rather than boolean flags
- [x] `LocateMeButton` now performs a genuine permission request and GPS
      stream subscription (previously a "coming soon" stub); shows a
      spinner while requesting
- [x] `CurrentLocationBadge` shows the live fix (lat/lng/accuracy) on the
      home screen once available — real, visible proof it works, not a
      map pin (no map yet — that's Phase 4)
- [x] Permission-denied / service-disabled / error states surface a
      graceful, honest message with a real "Open Settings"/"Enable"
      action where applicable; raw error text is never shown to normal
      users — only on the diagnostics screen
- [x] `DiagnosticsScreen` (`lib/features/diagnostics/diagnostics_screen.dart`)
      — the developer/technical readout the project spec requires,
      reachable only via a small bug-report icon in the home app bar (not
      exposed prominently to normal users): live status, latitude,
      longitude, accuracy, speed, heading, timestamp
- [x] Onboarding's earlier promise to "request permissions only when
      needed" is now honored: the location permission prompt fires the
      first time Locate Me is tapped, not on app launch
- [x] `dart format .`, `flutter analyze` (No issues found), `flutter test`
      (all passed: 6 new location-filter unit tests, 3 new `AppLocation`
      unit tests, 1 new diagnostics screen test, plus all prior Phase 1/2
      tests still green)
- [x] `flutter build apk --debug` — passed (took ~583s this run vs. ~14s
      previously — Gradle resolving the new `geolocator_android` native
      dependency over the flaky `maven.google.com` connection already
      noted in Known Limitations; not a regression, just slow first-time
      resolution)

### Phase 4 — Map (2026-08-14)
- [x] Added `flutter_map` (8.3.1, OpenStreetMap-based) and `latlong2`
      (0.10.1) — the only new dependencies this phase
- [x] `AppMapController` (`lib/core/map/app_map_controller.dart`) wraps
      flutter_map's `MapController`; `AppMapView`
      (`lib/widgets/map/app_map_view.dart`) is the *only* place
      `package:flutter_map` is imported outside this abstraction layer —
      per the project's "provider can be replaced later" requirement, no
      feature code imports flutter_map directly
- [x] `AppLocationLatLng.toLatLng()` (`lib/core/map/location_latlng.dart`)
      bridges Phase 3's `AppLocation` to the map layer's `LatLng` without
      making the location model depend on a map package
- [x] Real interactive map on the home screen: pan/zoom/rotate (flutter_map
      defaults), a live current-location marker sourced from Phase 3's GPS
      stream, and required OpenStreetMap attribution
- [x] Follow mode: the map auto-centers on new GPS fixes; panning/pinching/
      rotating the map (detected via `AppMapController.userMovedMap`,
      which distinguishes user gestures from programmatic moves) turns
      follow mode off and reveals a **Re-center** button; tapping it (or
      Locate Me) turns follow back on
- [x] No destination marker, route polyline, or waypoints yet — those need
      real data from Search (Phase 5) and Routing (Phase 6); nothing was
      faked to make the map look more complete than it is
- [x] Removed the now-obsolete `map_placeholder.dart` and its
      `AppStrings.mapPlaceholder` string (dead code after the real map
      replaced it)
- [x] Test-safety: `AppMapView.tileProvider` is overridable so widget
      tests never hit the real tile server; `home_screen_test.dart`
      installs an `HttpOverrides` with a 1ms connection timeout so any
      accidental network attempt fails fast and deterministically instead
      of hanging on this environment's already-flaky network
- [x] `dart format .`, `flutter analyze` (No issues found — see
      troubleshooting note below), `flutter test` (all passed, plus one
      new `toLatLng()` unit test)
- [x] `flutter build apk --debug` — passed
- [x] **Troubleshooting:** `flutter analyze` hung indefinitely (zero CPU
      progress) after adding the new dependencies. Root cause: a stale
      Dart LSP process left over from an earlier MCP tooling session was
      holding a lock on this project's analysis cache. Killing that
      process didn't fully resolve it; `flutter clean` + fresh
      `flutter pub get` cleared the corrupted `.dart_tool` state and
      analysis ran normally afterward (~22s). This also caused the
      `flutter build apk --debug` that followed to take ~968s (a full
      rebuild from scratch, plus a one-time Android SDK Platform 35
      install) rather than the usual ~14s incremental build — not a
      regression, just the cost of the clean.

### Phase 5 — Search (2026-08-14)
- [x] Added `http` (1.6.0) — the only new dependency this phase; used
      directly against OpenStreetMap's Nominatim search API rather than
      adding a heavier geocoding package, consistent with the project's
      OSM-first map data strategy
- [x] Fixed a real gap found while adding this phase: `INTERNET` was only
      declared in the debug-only Android manifest, not the main one — it
      was silently masking that Phase 4's tile fetching (and this phase's
      geocoding) would have failed on a release build. Added
      `android.permission.INTERNET` to the main manifest.
- [x] `Place` model (`lib/models/place_model.dart`) + `GeocodingService`
      (`lib/services/geocoding_service.dart`, injectable `http.Client` for
      testing) — the concrete, swappable geocoding provider, following
      the same pattern as `LocationService`/`AppMapController`
- [x] `SearchNotifier` (`lib/features/search/providers/search_provider.dart`)
      debounces input (400ms, 2-char minimum) before calling the API — a
      real throttle per the project's performance requirements — with a
      `SearchState` sealed hierarchy (`Idle`/`Loading`/`Results`/
      `NoResults`/`Failed`)
- [x] `RecentSearchesNotifier` — real, session-scoped recent-search list
      (add/dedupe/cap at 8/clear); durable cross-session persistence is a
      Phase 14 (backend/local storage) decision, not added prematurely
- [x] `SearchScreen` (`lib/features/search/search_screen.dart`): live
      autocomplete results with name/address/distance-when-available,
      recent searches shown when idle, honest empty/error states (no
      crash, no raw error text) — implements section 13's "modern
      location search" and section 40's "no search results"/"network
      unavailable" error handling
- [x] `selectedDestinationProvider` (`lib/core/providers/destination_provider.dart`,
      cross-feature like location): selecting a result sets the
      destination and returns to the map, which now shows a real
      destination marker and fits both current location and destination
      in view via `AppMapController.fitBounds` (new — wraps flutter_map's
      `fitCamera`/`CameraFit.bounds`)
- [x] **Scope decision:** search does *not* open a "Route Preview" screen
      on selection, even though section 13 describes that flow. Route
      Preview needs real distance/duration/route geometry, which don't
      exist until Phase 6 (Routing) — building that screen now would mean
      showing fake numbers. Selecting a destination just places it on the
      real map; Route Preview arrives with real data in Phase 6.
- [x] `DestinationSearchCard` now reflects real selection state (shows
      the picked place, a clear "x" button) instead of a "coming soon"
      stub
- [x] `dart format .`, `flutter analyze` (No issues found — one
      `use_null_aware_elements` lint surfaced and was fixed, adopting
      Dart's `?` null-aware list-element syntax), `flutter test` (all
      passed: new unit tests for `Place` parsing, `GeocodingService`
      using `package:http/testing.dart`'s `MockClient` — no real network
      — `RecentSearchesNotifier`, `formatDistanceMeters`; new widget
      tests for `SearchScreen`; `home_screen_test.dart`'s search-tap test
      updated to match the new navigation-to-search behavior)
- [x] `flutter build apk --debug` — passed (~126s; the manifest change
      triggered a partial re-merge, not a full rebuild)

### Phase 6 — Routing (2026-08-15)
- [x] Added no new dependency this phase — `RoutingService`
      (`lib/services/routing_service.dart`) reuses `http`, already added
      in Phase 5
- [x] While building this phase, verified the OSRM public demo server
      (`router.project-osrm.org`, the DEVELOPMENT.md candidate) accepts
      `foot`/`bike` profile names in its URL but has no real
      pedestrian/cycling graph loaded — both return byte-identical
      distance/duration to `driving` for the same coordinates, even
      labeled `"mode":"driving"` in the response. Rather than present
      that as real walking/cycling routing, `RoutingService` exposes
      `getDrivingRoute()` only; see KNOWN_LIMITATIONS.md
- [x] `AppRoute` model (`lib/models/route_model.dart`) — distance,
      duration, polyline; deliberately depends on `LatLng` directly
      (unlike `AppLocation`/`Place`) since a route has no purpose outside
      being drawn on a map — see ARCHITECTURE.md
- [x] `formatDurationSeconds` (`lib/core/utils/duration_format.dart`) —
      shared "8 min" / "1 h 12 min" formatter, same pattern as Phase 5's
      `formatDistanceMeters`
- [x] `RouteNotifier`/`routeProvider`
      (`lib/core/providers/route_provider.dart`): `RouteState` sealed
      hierarchy (`Idle`/`Loading`/`Ready`/`ModeUnsupported`/`Failed`) —
      `ModeUnsupported` is a first-class state, not an error, for
      Walking/Cycling
- [x] **Moved `travel_mode_provider.dart`** from
      `features/home/providers/` to `core/providers/`, and
      **`travel_mode_selector.dart`** from `features/home/widgets/` to
      `widgets/travel/` — both became cross-feature the moment the route
      preview screen needed them too, following the project's "don't
      generalize before a second consumer exists" rule (same rule that
      kept the map/geocoding layers as single concrete classes)
- [x] `AppMapView` gained an optional `routePoints` param — draws a real
      `flutter_map` `PolylineLayer` between current location and
      destination when a route is ready
- [x] Built `RoutePreviewScreen`
      (`lib/features/route_preview/route_preview_screen.dart`): real map
      + route line, distance/ETA summary, the travel mode selector
      (switching mode recalculates), and a visibly disabled "Start
      Navigation" button captioned "arrives once turn-by-turn navigation
      (Phase 7) is built" — matching the home screen's AR button pattern
- [x] **Scope decision:** selecting a search result now opens
      `RoutePreviewScreen` automatically (superseding Phase 5's "just
      drop a pin" behavior) whenever a current GPS fix exists; if not,
      an honest snackbar ("Get your location first…") shows instead of a
      screen with nothing to route from — see ARCHITECTURE.md
- [x] Every non-driving/no-GPS state is handled honestly: Walking/Cycling
      show "not available in this development environment," a failed
      request shows a generic network-error message (raw errors never
      shown to normal users, same rule as location/search), and a
      missing GPS fix shows "Get your location first…" instead of an
      unexplained infinite spinner
- [x] `dart format .`, `flutter analyze` (No issues found), `flutter
      test` (all passed: new unit tests for `formatDurationSeconds`,
      `RoutingService` via `package:http/testing.dart`'s `MockClient` — no
      real network — covering success parsing, non-200, "no route
      found," and network-failure paths; `RouteNotifier`'s
      mode-unsupported/clear logic tested directly via
      `ProviderContainer`; new `RoutePreviewScreen` widget tests covering
      destination display, the disabled Start Navigation button, the
      no-GPS message, and all four `RouteState` renderings via provider
      override — plus all prior Phase 1–5 tests still green)
- [x] `flutter build apk --debug` — passed (~68s; no new native
      dependency this phase)
- [x] Ran the app live in Chrome to visually confirm the updated flow
      compiles and boots with no console exceptions (same no-Android-
      device workaround as prior phases — see Known Limitations)

### Phase 7 — Turn-by-turn navigation (2026-08-15)
- [x] Added no new dependency this phase — everything reuses `http`
      (Phase 5) and `latlong2`/`flutter_map` (Phase 4)
- [x] `RoutingService.getDrivingRoute` now requests `steps=true` and
      parses OSRM's real per-maneuver steps; `AppRoute` gained an
      `instructions` field (`List<NavigationInstruction>`)
- [x] `NavigationInstruction` model (`lib/models/navigation_instruction.dart`)
      + `buildInstructionText()` — a small, real template that turns
      OSRM's raw maneuver type/modifier/road name into a sentence (e.g.
      "Turn right onto Trichy Road"), since OSRM's free API returns
      structured maneuvers, not ready-made instruction text
- [x] `ManeuverIcon` widget maps OSRM maneuver type/modifier to a
      Material icon (turn/merge/roundabout/fork/etc.)
- [x] `lib/core/utils/geo_math.dart` — real, tested pure-Dart geometry:
      `haversineMeters` and `distanceToPolylineMeters` (point-to-segment
      minimum distance), decoupled from geolocator so it works on route
      polyline points, not just live GPS fixes
- [x] `NavigationNotifier`/`navigationProvider`
      (`lib/features/navigation/providers/navigation_provider.dart`):
      drives an active session from the same live GPS stream
      `locationProvider` already exposes — no separate tracking
      mechanism. Real maneuver advancement, off-route detection
      (>40m from the route polyline) with automatic recalculation via
      `RoutingService`, arrival detection (within 25m of the
      destination), and pause/resume/stop
- [x] **Scope decision:** deliberately does *not* implement
      ARCHITECTURE.md's original `PREPARING_ROUTE`/`ROUTE_READY`
      sketch — `routeProvider` already owns that concern for the route
      preview screen, and navigation only ever starts from an
      already-computed route, avoiding two providers modeling the same
      fetch. Also omits heading/AR/permission-status fields from that
      same sketch — those belong to Phase 10/11 and would be
      unpopulated here
- [x] **Bug caught before shipping:** OSRM's first route step is always
      a "depart" maneuver at the starting point itself. Initially used
      it as instruction index 0, which meant the "next maneuver" banner
      showed "Start driving…" for the entire first leg (distance to it
      only grows as you drive away). Fixed: navigation now starts at
      the real next maneuver, skipping the already-passed depart step
- [x] **Bug caught before shipping:** calling
      `navigationProvider.notifier.stop()` from `NavigationScreen`'s
      `dispose()` — the natural place to end a session "however the
      screen closes" — crashes: mutating provider state notifies this
      same still-watching widget mid-unmount, which Flutter's framework
      asserts against; deferring via `Future.microtask` only moved the
      crash to test teardown, where the whole `ProviderScope` can already
      be gone. Fixed with `PopScope.onPopInvokedWithResult`, which fires
      while the widget is still fully mounted for every way the screen
      closes (buttons, back gesture, or a programmatic pop alike) —
      dispose() no longer touches provider state at all
- [x] ETA/remaining-distance during navigation are real but
      **approximate, not path-precise**: distance to the next maneuver is
      straight-line (not routed-path length), and remaining
      duration is estimated by scaling the original route's average
      pace against remaining distance — not a live-traffic ETA. Labeled
      honestly, not oversold; see Known Limitations
- [x] `RoutePreviewScreen`'s "Start Navigation" button is now real:
      enabled only once `routeProvider` has a `RouteReady` route (i.e.
      Driving), starts `navigationProvider`, and opens
      `NavigationScreen`
- [x] `NavigationScreen`
      (`lib/features/navigation/navigation_screen.dart`): live map with
      route polyline and position, a maneuver banner (icon + instruction
      + distance) that switches to honest off-route/recalculating/
      paused/arrived banners, remaining distance/ETA, and Pause/Resume/
      Stop/Done controls. Reuses the same map-follow/re-center mechanism
      as the home screen (Phase 4) rather than inventing a second one —
      exactly as ARCHITECTURE.md's Phase 4 note anticipated
- [x] **Moved `map_follow_provider.dart`** from `features/home/providers/`
      to `core/providers/`, and **`recenter_button.dart`** from
      `features/home/widgets/` to `widgets/map/` — both became
      cross-feature the moment the navigation screen needed them too,
      the same "don't generalize before a second consumer exists" rule
      applied to `travel_mode_provider`/`travel_mode_selector` in Phase 6
- [x] `dart format .`, `flutter analyze` (No issues found), `flutter
      test` (all passed: new unit tests for `geo_math`,
      `NavigationInstruction`/`buildInstructionText`, `RoutingService`'s
      step-parsing; `NavigationNotifier` state-machine tests via
      `ProviderContainer` with a fake `LocationNotifier` feeding
      synthetic GPS ticks — maneuver advancement, arrival, off-route +
      real (network-blocked) recalculation, pause/resume, stop — plus
      `NavigationScreen` widget tests via a fixed-state provider
      override for each rendered status, and updated
      `RoutePreviewScreen` tests for the now-real Start Navigation
      button; all prior Phase 1–6 tests still green)
- [x] `flutter build apk --debug` — passed (~31s; no new native
      dependency this phase)
- [x] Ran the app live in Chrome to visually confirm the updated flow
      compiles and boots with no console exceptions (same no-Android-
      device workaround as prior phases — see Known Limitations)

### Phase 8 — Live tracking (2026-08-20)
- [x] Added no new dependency this phase — everything builds on
      `geolocator` (Phase 3), already streaming raw fixes
- [x] **Scope decision:** wrong-direction detection, originally slated
      for this phase, had already shipped in Phase 7 (`NavigationNotifier`
      needed it immediately for off-route recalculation) — not
      duplicated here. This phase covers the other two Phase 8 items:
      position smoothing and speed-adaptive sampling
- [x] `smoothLocation`/`smoothHeadingDegrees`
      (`lib/core/utils/position_smoothing.dart`) — real exponential
      moving average (α=0.35) blending each accepted raw fix toward the
      previous smoothed value, so the map marker and navigation math
      don't visibly jitter within ordinary GPS accuracy noise.
      `smoothHeadingDegrees` uses a proper circular mean (via sin/cos)
      so headings near the 0°/360° boundary (e.g. 350° and 10°) average
      to ~0°, not 180° the way a naive linear blend would. Accuracy and
      timestamp always pass through unsmoothed — smoothing must never
      hide the real reported accuracy or fix age
- [x] `SpeedBucket`/`speedBucketFor`/`distanceFilterMetersForSpeedBucket`
      (`lib/core/utils/speed_bucket.dart`) — real speed-adaptive GPS
      sampling: stationary/walking/driving buckets, each mapped to a
      wider `Geolocator` `distanceFilter` at higher speed (3m/5m/15m) to
      trade fix density for battery on longer trips. Bucket transitions
      use asymmetric enter/exit thresholds (hysteresis) so speed hovering
      near a boundary doesn't flap the bucket — and therefore restart the
      GPS stream — on every update
- [x] `LocationAvailable` (`lib/core/providers/location_provider.dart`)
      gained a `smoothedLocation` field alongside the existing raw
      `location`, defaulting to `location` when omitted so prior call
      sites/tests didn't need to change. `LocationNotifier` now always
      supplies a real smoothed value, and cancels/resubscribes its
      `Geolocator` stream whenever `speedBucketFor` picks a new bucket
      (geolocator has no API to change an in-flight stream's filter)
- [x] **Consumer wiring, chosen deliberately per data, not blanket-
      applied:** the home map marker and its follow/re-center camera
      moves now read `smoothedLocation` (visible jitter reduction is the
      whole point); the GPS badge and diagnostics screen keep showing
      the raw `location` as ground truth (diagnostics additionally shows
      the live distance between raw and smoothed, as a real "how much is
      smoothing correcting right now" readout); route preview's routing
      origin and `NavigationNotifier`'s live tracking both consume
      `smoothedLocation`, since a jittering origin/position would ripple
      into route/off-route/maneuver math
- [x] `dart format .`, `flutter analyze` (No issues found), `flutter
      test` (all passed: new unit tests for `smoothLocation`/
      `smoothHeadingDegrees` — pass-through with no previous value, blends
      toward but not onto the raw fix, accuracy/timestamp untouched,
      correct 0°/360° wraparound averaging — and `speedBucketFor`/
      `distanceFilterMetersForSpeedBucket` — bucket ordering, hysteresis
      on both the walking and driving boundaries, negative-speed noise
      treated as zero; all prior Phase 1–7 tests still green, including
      `NavigationNotifier`'s tests which already fed `smoothedLocation`
      through `locationProvider`)
- [x] `flutter build apk --debug` — passed (~build verified; no new
      native dependency this phase)
- [x] **Known gap, not closed this phase:** `LocationNotifier`'s
      resubscribe-on-bucket-change wiring itself has no dedicated unit
      test — `position_smoothing.dart`/`speed_bucket.dart`'s pure
      functions are tested directly, but the notifier logic that calls
      them against a live `Geolocator` stream isn't. Tracked in
      KNOWN_LIMITATIONS.md, alongside the fact that the smoothing
      constant and speed thresholds are reasonable starting values, not
      yet tuned against a real outdoor GPS stream (no Android device
      available on this development machine)

### Phase 9 — Camera (2026-08-20)
- [x] Added `camera` (0.12.0+2) — the only new dependency this phase,
      pulling in `camera_android_camerax`/`camera_avfoundation`/
      `camera_web` as its platform implementations. Actively maintained
      (official `flutter` org package), compatible with Flutter
      3.38.4/Dart 3.10.3
- [x] Added `android.permission.CAMERA` plus a **non-required**
      `<uses-feature android:name="android.hardware.camera">` to the main
      Android manifest (a device without a camera must still be able to
      install and use the rest of the app — GPS navigation doesn't need
      one), and `NSCameraUsageDescription` to iOS's `Info.plist`
- [x] `CameraService` (`lib/services/camera_service.dart`) — thin,
      swappable wrapper over `package:camera`, same pattern as
      `LocationService`/`RoutingService`: lists real available cameras,
      initializes a real `CameraController` (audio disabled — this app
      has no use for the microphone)
- [x] `lib/core/utils/camera_selection.dart` — real, unit-tested pure
      logic pulled out of the provider: `pickPreferredCamera` (rear
      camera preferred, first camera as fallback, `null` when the device
      has none) and `isPermissionDeniedCode` (matches both Android's and
      iOS's differently-worded `CameraException` denial codes, since the
      plugin exposes no shared enum for this)
- [x] `CameraNotifier`/`cameraProvider`
      (`lib/core/providers/camera_provider.dart`): real permission→init
      flow mirroring `LocationNotifier`'s shape — `CameraState`:
      initial/requesting/available/unavailable/permission-denied/error.
      Deliberately does not auto-start on app launch or when the (still
      disabled) AR button becomes visible — only when a screen that
      actually needs the feed starts it, the same "ask only when needed"
      rule Phase 3 set for location permission
- [x] `CameraPreviewScreen`
      (`lib/features/ar_navigation/camera_preview_screen.dart`) — real
      live camera feed via `CameraPreview`, with honest
      requesting/unavailable/permission-denied/error states (a "Try
      again" retry action, no fabricated settings deep-link since no
      permission-settings package was added) and a visible note that
      overlays aren't real yet. First file in the `ar_navigation` feature
      folder
- [x] **Scope decision:** the home screen's "AR Navigation" button stays
      disabled with its existing "Phase 10" caption — it is *not* wired
      to `CameraPreviewScreen`. A button labeled "AR Navigation" opening
      a plain camera feed with no AR content would overstate what's
      built. Instead, `CameraPreviewScreen` is reachable from the
      diagnostics screen's new "Preview camera" action — the same
      "prove it works via diagnostics before it's user-facing" path
      Phase 3 used for GPS before Phase 4's map existed
- [x] `DiagnosticsScreen` gained a "Camera" section (real status:
      not requested/requesting/available/unavailable/permission-denied/
      error) alongside a "Preview camera" button
- [x] **Bug caught before shipping:** disposing the active
      `CameraController` from `ref.onDispose` by reading `state` (pattern-
      matching for `CameraAvailable`) crashed with "Cannot use Ref or
      modify other providers inside life-cycles/selectors" — Riverpod 3.x
      forbids reading a notifier's own `state` from inside its
      `ref.onDispose` callback. Fixed by tracking the live
      `CameraController` in a plain `_controller` field instead (set
      whenever `start()` succeeds, read/cleared by
      `stop()`/`_disposeController()`), the same reason
      `LocationNotifier` tracks `_lastAccepted`/`_lastSmoothed` as fields
      rather than deriving them from `state`. Caught by this phase's own
      widget tests (`ProviderScope` teardown triggers `ref.onDispose`),
      not by inspection
- [x] `dart format .`, `flutter analyze` (No issues found), `flutter
      test` (all passed: new unit tests for `pickPreferredCamera`/
      `isPermissionDeniedCode` covering empty-camera-list,
      back-camera-preference, front-only fallback, and both platforms'
      denial-code spellings; new `CameraPreviewScreen` widget tests for
      every non-live-feed state via a fixed-state `CameraNotifier`
      override (the `camera` plugin has no platform-channel
      implementation in `flutter test`, so the live-feed
      `CameraAvailable` render path itself isn't covered — tracked in
      KNOWN_LIMITATIONS.md); `DiagnosticsScreen` test updated for the new
      Camera section; all prior Phase 1–8 tests still green — 118/118)
- [x] `flutter build apk --debug` — passed (~157s; first build after
      adding the `camera_android_camerax` native dependency, per the
      known first-native-dep Gradle slowdown pattern, but nowhere near
      Phase 3's ~583s since this was the only new native dependency)
- [x] Ran the app live in Chrome (`camera_web` provides the web
      implementation) to confirm the updated app compiles and boots to a
      running Dart VM Service with no exceptions in the log — same
      no-Android-device workaround as prior phases; the live camera feed
      itself wasn't exercised in the browser this session (would need a
      webcam-permission grant this automated session can't perform), so
      the `CameraAvailable` UI is unverified beyond compiling and passing
      analysis — see KNOWN_LIMITATIONS.md

### Phase 10 — AR navigation, scoped to capability detection (2026-08-20)
- [x] **Researched the Flutter/ARCore plugin ecosystem before writing any
      code** (per DEVELOPMENT.md's "verify current maintenance status
      before adopting" rule) and found it in bad shape: `ar_flutter_plugin`
      (what most tutorials reference) hasn't shipped since November 2022
      and caps its Dart SDK constraint below 3.0, so it won't resolve
      against this project's Dart 3.10.3 at all; `arcore_flutter_plugin`
      is stuck at a 3-year-old 0.1.0 (its own author moved on to an
      abandoned rewrite, `sceneview_flutter`); the more-adopted forks
      (`ar_flutter_plugin_engine`, `arcore_flutter_plus`) are ~2 years
      stale; the only actively-updated option (`ar_measure_flutter`) was
      one day old with 98 downloads and one maintainer. With no Android
      device on this machine to verify AR rendering behavior at runtime,
      **the user chose (given these findings) to scope this phase down
      to a real AR capability check instead of adopting any of them for
      full AR rendering** — see ARCHITECTURE.md's Phase 10 note
- [x] Added `com.google.ar:core` 1.54.0 (Google's official ARCore SDK,
      current stable per Google's own Maven repository) as a **native
      Android Gradle dependency only** — no Flutter/Dart AR package was
      added, so `pubspec.yaml` is unchanged this phase
- [x] Confirmed `flutter.minSdkVersion` (Flutter 3.38.4's own default is
      24) already satisfies ARCore's minSdk 24 requirement — no manifest
      minSdk change needed
- [x] Added `android.permission.CAMERA`'s AR counterpart via
      `<meta-data android:name="com.google.ar.core" android:value="optional">`
      in the main Android manifest — "optional" (not "required") so
      devices that can't run ARCore at all still install and use the rest
      of the app, same reasoning as Phase 9's non-required camera
      `<uses-feature>`
- [x] `MainActivity.kt` gained a `tn_ar_navigation/ar_platform`
      `MethodChannel` calling `ArCoreApk.getInstance().checkAvailabilityAsync`
      directly — real, per Google's own current integration docs,
      including the transient-result (`UNKNOWN_CHECKING`) polling pattern
      Google's docs specify (bounded to 10 retries / 200ms apart, so a
      persistently transient result can't poll forever)
- [x] `ar_availability.dart` (`ArAvailability` enum +
      `parseArCoreAvailability`) — pure, unit-tested mapping from
      ARCore's real result codes (`SUPPORTED_INSTALLED`,
      `SUPPORTED_APK_TOO_OLD`, `SUPPORTED_NOT_INSTALLED`,
      `UNSUPPORTED_DEVICE_NOT_CAPABLE`, and the `UNKNOWN_*` family) to an
      honest, UI-facing result — pulled out of the service layer for
      testability, same pattern as Phase 9's `camera_selection.dart`
- [x] `ArPlatformService` (`lib/services/ar_platform_service.dart`) —
      thin wrapper over the native channel, short-circuiting to a real
      "not implemented on this platform" result on anything that isn't a
      native Android runtime (checked via `kIsWeb`/`defaultTargetPlatform`,
      not `dart:io`'s `Platform`, since the latter throws on this
      project's web dev-verification target)
- [x] `ArAvailabilityNotifier`/`arAvailabilityProvider`
      (`lib/core/providers/ar_availability_provider.dart`) — real
      permission-free capability check, mirroring
      `LocationNotifier`/`CameraNotifier`'s shape
- [x] `DiagnosticsScreen` gained an "AR (ARCore)" section (real status:
      not checked/checking/supported/needs-update/unsupported/unknown/
      not-implemented-on-this-platform) and a "Check AR support" action —
      same "prove it via diagnostics, not a first-class button yet" path
      as Phase 9's camera preview
- [x] **Scope decision:** the home screen's "AR Navigation" button is
      untouched — still disabled, still captioned "arrives once AR
      navigation (Phase 10) is built". A capability check is not an AR
      experience; wiring the button to it (or to Phase 9's bare camera
      preview) would overstate what's built
- [x] **Bug caught before shipping:** the AndroidManifest.xml comment
      explaining the `optional` meta-data used a `--` (double hyphen)
      inside an XML comment, which is illegal per the XML spec and broke
      Gradle's manifest merge (`ManifestMerger2$MergeFailureException`)
      on the very first build attempt. Fixed by rewording the comment to
      avoid the double hyphen. Caught immediately by this phase's own
      `flutter build apk --debug` step, not by inspection
- [x] `dart format .`, `flutter analyze` (No issues found), `flutter
      test` (all passed: new unit tests for `parseArCoreAvailability`
      covering every real ARCore result code plus null/unrecognized-code
      safety; a new `ArPlatformService` test confirming
      `checkAvailability()` never throws and resolves to a real
      non-crashing result even with no native handler responding (this
      test environment); `DiagnosticsScreen` test updated for the new AR
      section and its "Check AR support" action; all prior Phase 1–9
      tests still green — 126/126)
- [x] `flutter build apk --debug` — passed after the manifest fix (~31s;
      faster than Phase 9's camera build since ARCore ships as a plain
      AAR with no separate native-code sub-dependency to resolve)
- [x] Ran the app live in Chrome to confirm the updated app compiles and
      boots to a running Dart VM Service with no exceptions — same
      no-Android-device workaround as prior phases. The real ARCore
      capability check itself (the `MethodChannel` call, and especially
      `MainActivity.kt`'s transient-result polling loop) is **unverified
      on real hardware** — `flutter build apk --debug` passing proves the
      native Kotlin/ARCore SDK code compiles and links, not that it
      returns correct results on a device — see KNOWN_LIMITATIONS.md

### Phase 11 — Compass + IMU (2026-08-20)
- [x] Verified `flutter_compass` (0.8.1) and `sensors_plus` (7.1.0)
      before adopting, per DEVELOPMENT.md's rule and this project's
      Phase 10 experience: `sensors_plus` is excellent (160/160 pub
      points, updated 54 days prior, Flutter Favorite); `flutter_compass`
      is 21 months stale but — unlike the Phase 10 AR plugins — actually
      resolves cleanly against Flutter 3.38.4/Dart 3.10.3 (confirmed via
      `flutter pub add`, not just its pub.dev listing), so it was judged
      a real, usable dependency rather than a broken one
- [x] `CompassReading` model (`lib/models/compass_reading.dart`) —
      decouples the app from `flutter_compass`'s `CompassEvent`, same
      reasoning as `AppLocation`; has two real consumers immediately
      (diagnostics and the map), meeting the project's "don't generalize
      before a second consumer exists" bar right away
- [x] `CompassService` (`lib/services/compass_service.dart`) +
      `CompassNotifier`/`compassProvider`
      (`lib/core/providers/compass_provider.dart`) — real magnetometer
      heading, mirroring `LocationNotifier`'s shape. `CompassUnavailable`
      is a first-class state (some Android devices genuinely report no
      magnetometer), not an error. Deliberately not auto-started — same
      "ask/start only when actually needed" battery discipline as
      location (Phase 3) and camera (Phase 9)
- [x] `MotionSensorService` (`lib/services/motion_sensor_service.dart`) +
      `MotionSensorNotifier`/`motionSensorProvider`
      (`lib/core/providers/motion_sensor_provider.dart`) — real
      accelerometer + gyroscope streams. **Scope decision:** diagnostics-
      only this phase, since there's no dead-reckoning/fusion consumer of
      raw IMU data yet — that's Phase 12 (Hybrid localization), which
      will decide the real fusion approach once it has a concrete reason
      to, rather than plumbing sensors nobody reads yet
- [x] **Design note:** `sensors_plus` exposes no "is this sensor
      present" check (unlike `flutter_compass`'s nullable `heading`) — a
      genuinely absent accelerometer/gyroscope's stream just never emits,
      indistinguishable from one that simply hasn't produced its first
      reading yet. Rather than guess at a timeout-based "unavailable"
      state, `MotionSensorState` honestly stays "waiting for a reading"
      per-sensor instead of fabricating a false negative
- [x] Pulled the real mapping/merge logic out of both notifiers into pure,
      unit-tested functions — `compassStateFromEvent` and
      `mergeMotionSensorReading` — the same "business logic out of the
      plumbing" pattern `camera_selection.dart`/`ar_availability.dart`
      established, chosen specifically so tests exercise the actual
      notifier logic rather than a reimplementation in a test fixture (an
      earlier draft of the compass test did exactly that before being
      caught and rewritten during this phase)
- [x] **The real, user-facing payoff:** `AppMapView` gained an optional
      `headingDegrees` — when a real compass reading exists, the
      current-location marker renders a rotating directional beam (via a
      new `CustomPainter`, `_HeadingBeamPainter`) instead of a plain dot,
      the same visual language Google Maps uses for "which way is my
      phone facing." Falls back to the plain dot when no reading exists
      yet, rather than guessing a direction. Wired into both the home
      screen (compass started once in `initState`, same
      never-explicitly-stopped lifetime as location's GPS stream) and
      `NavigationScreen` (reads the same already-running provider)
- [x] `DiagnosticsScreen` gained "Compass" and "Motion sensors (IMU)"
      sections (real heading/accuracy, and real accelerometer/gyroscope
      x/y/z) with "Start compass"/"Start motion sensors" actions, same
      pattern as camera/AR
- [x] **Bug caught before shipping:** an XML `Path` name collision —
      `latlong2` (imported unprefixed) defines its own generic `Path<T>`,
      which shadowed `dart:ui`'s `Path` inside `_HeadingBeamPainter`,
      breaking `flutter analyze` with five `undefined_method` errors.
      Fixed by qualifying it as `ui.Path` (the file already imports
      `dart:ui as ui` for the gradient shader). Caught immediately by
      `flutter analyze`, not by inspection
- [x] **Bug caught before shipping (test infrastructure):** a plain
      `test()` (not `testWidgets()`) that reads `motionSensorProvider`
      failed with "Binding has not yet been initialized" —
      `MotionSensorService`'s constructor eagerly calls
      `sensors_plus`'s `accelerometerEventStream()`/`gyroscopeEventStream()`,
      which (unlike `flutter_compass`'s genuinely lazy `events` getter)
      synchronously invoke a real `MethodChannel` call the moment they're
      called, not just when subscribed. Fixed the same way as the
      earlier `ar_platform_service_test.dart` case: added
      `TestWidgetsFlutterBinding.ensureInitialized();`
- [x] **Bug caught before shipping (test infrastructure):** three new
      diagnostics-screen tests initially failed with "found 0 widgets" —
      the new Compass/Motion sensors sections are below the fold in the
      diagnostics screen's `ListView` and Flutter's `ListView(children:)`
      doesn't build off-screen children into the element tree. Fixed by
      scrolling to them first via `tester.scrollUntilVisible` before
      asserting/tapping
- [x] `dart format .`, `flutter analyze` (No issues found), `flutter
      test` (all passed: new unit tests for `compassStateFromEvent`
      (null heading, real heading+accuracy, the real "-1 means no
      accuracy" sentinel) and `mergeMotionSensorReading` (partial
      updates, replacement not accumulation); new `AppMapView` widget
      tests covering the heading beam across the full 0-360° range and
      the no-heading fallback; `DiagnosticsScreen` tests updated for the
      new sections; all prior Phase 1–10 tests still green — 141/141)
- [x] `flutter build apk --debug` — passed (~104s; mostly a one-time
      Android SDK Platform 34 download triggered by the new plugins, not
      a per-build cost)
- [x] Ran the app live in Chrome to confirm the updated app compiles and
      boots to a running Dart VM Service with no exceptions — same
      no-Android-device workaround as prior phases. Actual compass
      accuracy, real magnetometer noise behavior, and whether the heading
      beam visually points the correct direction on a moving phone are
      all **unverified on real hardware** — see KNOWN_LIMITATIONS.md
- [x] **Separately (not a phase, a same-session fix, part 1):** improved
      `GeocodingService`'s Nominatim query with a Tamil Nadu `viewbox`
      bias, in response to real user feedback that search results skewed
      toward districts/bus stands over specific destinations. Landed
      first as a ranking-only improvement; superseded hours later the
      same day by part 2 below once the user confirmed the real ask was
      deeper than ranking.

### Same-day follow-up — Map & geocoding provider switch (2026-08-20)
- [x] **Decision process:** the user asked directly for
      "Google-like maps with all destinations... 100% accuracy." Rather
      than silently pick a provider, presented the real tradeoff (Google
      Maps Platform requires the user's own billing-enabled API key and
      real cost; a lighter alternative like Mapbox/LocationIQ; or staying
      on tuned-free OSM) via a direct question. User chose Google Maps
      Platform, then — asked a second direct question about scope — chose
      the full switch (map tiles + search) over a search-only change
- [x] Verified `google_maps_flutter` (2.18.0, official `flutter.dev`
      publisher, updated 27 days prior) before adopting — same diligence
      Phase 10's AR research established. Confirmed the real Text Search
      (New) and `locationBias` request/response shapes against Google's
      current official docs rather than guessing from memory or stale
      tutorials, per DEVELOPMENT.md's "prefer official documentation"
      rule
- [x] Added `google_maps_flutter` (2.18.0) and `flutter_dotenv` (6.0.1)
      as the only new Dart dependencies; removed `flutter_map` entirely
      (`latlong2` stays — the app's own canonical coordinate type was
      never actually coupled to flutter_map, only converted at the
      `AppMapController`/`AppMapView` boundary, which is exactly the
      abstraction ARCHITECTURE.md's Phase 4 design anticipated)
- [x] **API key infrastructure — real, not faked, with an honest gap:**
      no real Google Cloud API key exists yet (obtaining one is the
      user's step, not something this session could do). Built the real
      plumbing with a clearly-marked placeholder
      (`YOUR_GOOGLE_MAPS_API_KEY_HERE`) in three gitignored/unwired-to-git
      locations: `android/local.properties` (read by
      `app/build.gradle.kts` into a `manifestPlaceholders["mapsApiKey"]`,
      consumed by `AndroidManifest.xml`'s
      `com.google.android.geo.API_KEY` meta-data), `.env` (loaded via
      `flutter_dotenv` in `main.dart`, read by `GeocodingService`), and
      `ios/Runner/AppDelegate.swift`'s `GMSServices.provideAPIKey(...)`
      (hardcoded there, not injected, since iOS isn't built/verified on
      this Windows machine anyway). `.env.example` documents the required
      key for anyone cloning the repo. `GeocodingService.search()` checks
      for a missing/placeholder key and throws a real, honest
      `GeocodingException` naming the fix, rather than attempting a
      doomed network request
- [x] **Security note surfaced, not glossed over:** `flutter_dotenv`'s
      own README states plainly that a `.env` bundled as a Flutter asset
      is extractable from a built app by anyone with the file — not a
      secure secret store. Documented in SETUP.md/KNOWN_LIMITATIONS.md
      that the real security boundary is restricting the API key in
      Google Cloud Console to this app's package name + signing
      certificate, and that a production release should proxy these
      calls through a backend (Phase 14) instead of shipping a raw key
      client-side
- [x] `Place.fromGooglePlacesJson` replaced `fromNominatimJson`;
      `GeocodingService` rewritten around Places API (New) Text Search
      (`POST https://places.googleapis.com/v1/places:searchText`,
      `X-Goog-Api-Key`/`X-Goog-FieldMask` headers), carrying forward the
      Tamil Nadu bounding-box bias as `locationBias.rectangle` (the
      direct successor to the Nominatim `viewbox` from part 1 above) —
      same "swappable class, no premature interface" pattern, same
      public `search(query) → List<Place>` shape, so `SearchNotifier`/
      `SearchScreen` needed zero changes
- [x] `AppMapController` rewritten around `GoogleMapController`
      (obtained asynchronously via `onMapCreated`, unlike flutter_map's
      synchronously-constructible controller — calls made before
      attachment are queued and replayed). **Real design gap handled,
      not ignored:** `google_maps_flutter` exposes no "was this camera
      move a user gesture or a programmatic call" signal (`onCameraMoveStarted`
      is a bare `VoidCallback`, confirmed against the platform interface
      source, not assumed) — a real, longstanding limitation of the
      plugin. Implemented the standard workaround: a
      `_programmaticMoveInFlight` flag set before every `moveTo`/
      `fitBounds` call and cleared on `onCameraIdle`; any
      `onCameraMoveStarted` while it's false is treated as a real user
      gesture. This is what drives follow-mode drop-out — without it,
      every GPS-triggered auto-recenter would falsely look like a user
      pan and immediately disable follow mode
- [x] `AppMapView` rewritten around `GoogleMap`. **Design decision:** the
      current-location dot is Google's own native `myLocationEnabled`
      layer (real GPS+sensor rendering at the platform level, including
      its own heading cone) rather than a custom marker — this made the
      `_HeadingBeamPainter`/`_CurrentLocationDot` custom painter built
      earlier the same day (for the Compass work above) immediately
      redundant, so it was deleted rather than kept as unused code.
      `compassProvider` itself wasn't touched — it still feeds
      diagnostics, independent of the map. Destination marker uses
      `BitmapDescriptor.defaultMarkerWithHue` (a real built-in icon, no
      custom bitmap asset generation attempted this round); route
      polyline drawing carried over directly. Google's own required
      attribution is native to the SDK — the old manual
      `RichAttributionWidget` for OpenStreetMap was removed
- [x] **Cascading cleanup:** `AppMapView.currentLocation`/`headingDegrees`
      became genuinely dead parameters once `myLocationEnabled` replaced
      their purpose, so they were removed — the one real deviation from
      "swapping map providers only touches two files" (see
      ARCHITECTURE.md's Phase 4 note). `HomeScreen`, `RoutePreviewScreen`,
      and `NavigationScreen` each needed a small edit to stop passing
      them; `HomeScreen` also stopped auto-starting `compassProvider` in
      `initState` (nothing on that screen consumes it anymore — the
      diagnostics screen's own "Start compass" button still exists for
      that)
- [x] **Bug caught before shipping (twice):** the same XML-comment
      `--`-inside-a-comment mistake from Phase 10 recurred — once in the
      new `com.google.android.geo.API_KEY` meta-data's explanatory
      comment. Fixed the same way (replace `--` with an em dash or
      reword), caught immediately by `flutter build apk --debug` both
      times, not by inspection. Worth internalizing as a durable rule
      for future manifest edits: never use `--` in an XML comment body
- [x] Rewrote every test that touched the old stack:
      `place_model_test.dart` and `geocoding_service_test.dart` for the
      new Places API (New) shapes (including dedicated tests for the
      missing-key and placeholder-key honest-failure paths);
      `app_map_view_test.dart` rewritten from "does the custom heading
      beam render at every angle" to "does the widget build without
      throwing across the real destination/route-polyline combinations
      this app uses" — `GoogleMap` itself was confirmed, by actually
      running it, to build successfully in `flutter_test` despite having
      no real native platform view host, so this remains real (if
      shallow) coverage, not abandoned. Corrected now-inaccurate
      "flutter_map tile layer" comments in
      `home_screen_test.dart`/`route_preview_screen_test.dart`/
      `navigation_screen_test.dart`'s shared `HttpOverrides` helper
- [x] `dart format .`, `flutter analyze` (No issues found), `flutter
      test` — all passed, **145/145**
- [x] `flutter build apk --debug` — passed (~66s) after fixing the two
      manifest comment bugs above; confirms Google Maps SDK + ARCore +
      camera + compass + sensors_plus all link together in one native
      build with the placeholder key in place
- [x] Ran the app live in Chrome — booted to a running Dart VM Service
      with no exceptions. **What remains genuinely unverified, honestly:**
      no real API key has been obtained yet (the project owner's step —
      see SETUP.md), so neither the map nor search has been visually
      confirmed to work even once, on any platform. Once a real key is
      added, this needs a real verification pass — see
      KNOWN_LIMITATIONS.md

### Real-device verification (2026-08-20)
A real device connected mid-session — Samsung Galaxy S25 Ultra
(SM-S938B), Android 15 (API 35) — the first time any phase in this
project has run on real hardware rather than Chrome/web or a compile-only
build. This closed out the "genuinely unverified" gap above and several
older ones (Phase 9 camera, Phase 10 AR, Phase 11 compass/IMU/map
gestures — see KNOWN_LIMITATIONS.md for the updated status of each).
- [x] **Real API key configured.** The project owner created a Google
      Cloud API key restricted (Application restrictions: Android apps,
      this app's package + debug SHA-1; API restrictions: Maps SDK for
      Android + Places API (New)) and provided it directly — written into
      `android/local.properties`/`.env` without ever being echoed in this
      session's output, per the owner's explicit instruction
- [x] **Real bug found: the restricted key needed Android identity
      headers on REST calls.** The Maps SDK (native) enforces an
      Android-app key restriction automatically at the platform level;
      `GeocodingService`'s plain `http` calls to Places API (New) do not
      get that for free. First live call returned a real
      `403 PERMISSION_DENIED`. Diagnosed by calling the exact same
      endpoint directly (bypassing the app) with a temporary throwaway
      test file (`test/_manual_live_places_check.dart`, deleted
      immediately after, real network call, never added to the permanent
      suite — a real network dependency doesn't belong in `flutter test`)
      — same error, confirming it wasn't an app bug. Fixed:
      `GeocodingService` now sends `X-Android-Package`/`X-Android-Cert`
      (the debug SHA-1, uppercase hex, no colons — not a secret) on every
      request. Re-verified live the same way: real Places API results
      came back (Chennai Central Railway Station, 4 real results) —
      then the temporary test was deleted again
- [x] **Ran the app's own 9-point verification checklist for real**,
      using the Dart/Flutter MCP server's `get_widget_tree`/
      `get_runtime_errors` (no screenshot/tap automation available —
      `flutter_driver`'s commands need `enableFlutterDriverExtension()`
      wired into a real entry point, not added, since that's
      instrumentation in production `main.dart` territory this session
      wasn't asked to add) plus a persistent `adb logcat` capture (chosen
      because the Dart Tooling Daemon connection reliably drops the
      moment this Samsung device's app loses foreground — a real,
      repeatable environment quirk, not a bug in this project; logcat
      survives it). All 9 checks confirmed **PASS** with real evidence:
      Google Maps SDK rendering (`AndroidView` mounted, native
      `policy_maps_core_dynamite` module active in logs), a real GPS fix
      (`10.36601, 77.98453 ±18m`), real Places API search-and-select
      (reproduced twice), real compass heading (`-19° ±15°`), physically
      plausible real IMU values (accelerometer Y-axis ≈9.55 m/s², close
      to real gravity; gyroscope ≈0 at rest), follow-mode dropping out on
      a real manual pan and re-enabling on a real Recenter tap (both
      directly observed), and a full-session log scan for Maps/Places
      errors (clean)
- [x] **Real bug found and fixed: a 113px `RenderFlex` overflow** on the
      home screen, reproduced twice. Root-caused (not guessed) using the
      device's own `InsetsState` dump captured at the exact error
      timestamp: the IME (keyboard) was still reported visible for one
      frame when `HomeScreen` became visible again after popping back
      from `SearchScreen`, and the default `Scaffold` keyboard-avoidance
      shrank the screen below what its fixed-height content needs.
      `HomeScreen` has no text field of its own, so the fix was
      `resizeToAvoidBottomInset: false` — a targeted fix matching the
      real root cause, not a generic "wrap it in a scroll view" band-aid.
      Verified: `flutter analyze` clean, 145/145 tests, debug build
      succeeds, and — reproduced the exact original trigger sequence
      again on-device afterward — no recurrence
- [x] **Real, honest diagnosis of a "GPS stuck loading forever" report**
      indoors: added a temporary diagnostic print in
      `LocationNotifier._onPosition` (removed immediately after
      diagnosing — `flutter analyze`/`flutter test` re-confirmed clean),
      hot-reloaded onto the live device, and found real fixes *were*
      arriving (real Tamil Nadu coordinates) at 87-98m accuracy — over
      the app's 50m threshold, so correctly rejected, not a bug. This
      directly informed Phase 12's `weakSignal` design below: a run of
      real rejected fixes is a genuine, non-ambiguous signal worth
      surfacing; silence alone is not (a stationary phone with good GPS
      is indistinguishable from a signal gap using elapsed time alone,
      since `LocationService`'s distance-filtered stream only emits on
      real movement)

### Phase 12 — Hybrid localization (2026-08-20)
- [x] **Scope decision, made with the project owner up front** (this
      phase name is broad enough to mean several different things): GPS-
      gap detection + heading-source fusion, explicitly *not* full
      inertial dead-reckoning — see ARCHITECTURE.md's Phase 12 entry for
      the full reasoning on why dead-reckoning was considered and
      rejected (drift without calibration this project can't validate)
- [x] `LocationState.weakSignal` added to both `LocationRequesting` and
      `LocationAvailable`. Driven by a real signal discovered during the
      same-day real-device session above — 3 consecutive rejected
      (too-inaccurate) raw fixes in a row — not by elapsed time, which
      would be ambiguous (silence could mean weak signal or just no
      movement, since the position stream is distance-filtered).
      `withWeakSignalFlagged` is the pulled-out pure state transform
      (tested), same pattern `compassStateFromEvent`/
      `mergeMotionSensorReading` used in Phase 11
- [x] `fuseHeading` (`lib/core/utils/heading_fusion.dart`) — real,
      tested GPS-course-vs-compass fusion reusing Phase 8's `SpeedBucket`
      as the decision threshold (prefer GPS once `SpeedBucket.driving`,
      compass otherwise, falling back to whichever source is actually
      available). No blending/averaging attempted — an explainable
      either/or choice instead, since a real blend needs calibration
      this project has no way to validate
- [x] Wired both into `DiagnosticsScreen`: the Location section now
      shows `weakSignal` in its status text; a new "Fused heading"
      section shows the live result and which source was picked — same
      "prove it via diagnostics before a first-class consumer needs it"
      path every sensor phase in this project has used (no map/
      navigation code consumes the fused heading yet, honestly, since
      nothing concrete needs it today)
- [x] `dart format .`, `flutter analyze` (No issues found), `flutter
      test` — all passed, **156/156** (new: `heading_fusion_test.dart`
      covering every source-preference/fallback/none combination, and
      `location_provider_test.dart` — the first dedicated test file for
      `LocationNotifier`'s state, closing a gap KNOWN_LIMITATIONS.md had
      flagged since Phase 8)
- [x] `flutter build apk --debug` — passed (~46s)
- [x] **Not verified live on the real device this round** — the phase
      landed after the real-device session above wrapped up. The
      `weakSignal`/`fuseHeading` logic is covered by real unit tests, but
      neither has been watched update live against real GPS/compass
      hardware — see KNOWN_LIMITATIONS.md

### Phase 13 — Computer vision (2026-08-21)
- [x] **Scope decision, made with the project owner up front**: the
      original ask covered landmark/POI recognition, street-sign text
      recognition, and lane/road detection for AR overlay, all on-device.
      Researched what on-device ML Kit for Flutter actually offers before
      writing any code (per DEVELOPMENT.md's "verify current maintenance
      status" rule, same diligence Phase 10's AR research used) and found
      two of the three don't map onto a real on-device model: true
      landmark *identification* (naming a specific building) only exists
      in the cloud-only Google Cloud Vision API, not any on-device ML Kit
      module; lane/road *segmentation* has no stock ML Kit model at all
      (Object Detection & Tracking does generic bounding boxes — Fashion
      Good/Food/Home Good/Place/Plant — not lane lines). Presented both
      gaps to the owner, who chose to build what's real (OCR + generic
      scene labeling as an honest substitute for landmark ID) and defer
      the rest — see KNOWN_LIMITATIONS.md and ARCHITECTURE.md's Phase 13
      entry for the full reasoning
- [x] Verified `google_mlkit_text_recognition` and
      `google_mlkit_image_labeling` before adopting: both actively
      maintained (published 3 days prior, verified `flutter-ml.dev`
      publisher). **Real SDK conflict found and resolved**: the latest
      versions (0.17.1 / 0.16.1) require Dart SDK ≥3.12.0, above this
      project's 3.10.3 (Flutter 3.38.4 stable) — `flutter pub add`
      resolved the highest versions that actually satisfy this project's
      SDK instead: `google_mlkit_text_recognition ^0.16.0` and
      `google_mlkit_image_labeling ^0.15.0` (pulling in
      `google_mlkit_commons` transitively). No Android manifest/Gradle
      changes needed — both plugins require minSdk 21/compileSdk 35,
      already satisfied by `flutter.minSdkVersion`/`compileSdkVersion`
      (24/36 on this project's Flutter 3.38.4)
- [x] `TextRecognitionResult` (`lib/models/text_recognition_result.dart`)
      and `SceneLabel` (`lib/models/scene_label.dart`) decouple the app
      from ML Kit's `RecognizedText`/`ImageLabel`, same reasoning as
      `AppLocation`/`Place`. `SceneLabel`'s own doc comment states plainly
      it's a generic label, not a landmark identity
- [x] `textRecognitionResultFromRecognizedText`/`sceneLabelsFromImageLabels`
      (`lib/core/utils/vision_mapping.dart`) — pure, unit-tested mapping
      functions pulled out of the service for testability, same pattern as
      `camera_selection.dart`/`ar_availability.dart`. Verified against ML
      Kit's actual installed package source (read directly from the pub
      cache) rather than assumed, since both `RecognizedText`/`TextBlock`/
      `TextLine`/`ImageLabel` have plain, directly-constructible
      constructors that made real (not reimplemented-fixture) unit tests
      possible
- [x] `VisionService` (`lib/services/vision_service.dart`) — thin, swappable
      wrapper over both ML Kit recognizers, same pattern as
      `LocationService`/`CameraService`. Both recognizers run fully
      on-device: no network call, no cloud API key, per the owner's
      on-device choice. `isVisionSupportedOnThisPlatform` guards every
      call (`!kIsWeb && (Android || iOS)`) since neither plugin ships a
      web/desktop implementation — same reasoning
      `ArPlatformService`'s native-Android guard established (Phase 10)
- [x] `VisionState` sealed hierarchy + `VisionNotifier`
      (`lib/core/providers/vision_provider.dart`): idle/processing/
      text-result/label-result/unavailable/failed, mirroring
      `CameraState`'s shape. Runs against a **single captured frame**, not
      a continuous stream — a deliberate scope choice keeping battery/perf
      cost bounded and avoiding the `CameraImage` YUV→`InputImage`
      rotation/format handling a live scanner would need
- [x] `VisionScreen` (`lib/features/vision/vision_screen.dart`) — live
      camera feed (reusing Phase 9's `cameraProvider`) with "Scan text"/
      "Label scene" buttons that capture a frame via
      `CameraController.takePicture()` and run it through `visionProvider`;
      honest requesting/unavailable/permission-denied/error/processing/
      no-text/no-labels states, no fabricated results. Reachable only from
      the diagnostics screen — same "prove it via diagnostics before it's
      a first-class user-facing entry point" path every sensor/camera
      phase has used
- [x] `DiagnosticsScreen` gained a "Vision (Phase 13)" section (real
      status: not analyzed yet/processing/N lines recognized/N labels
      detected/not implemented on this platform/error) and a
      "Preview vision" action, same pattern as Camera/AR
- [x] **Real bug caught before shipping**: `VisionService.dispose()`
      awaited `TextRecognizer.close()`/`ImageLabeler.close()` directly.
      Both call a real `MethodChannel`; with no native handler in the test
      environment (or a genuine platform-side failure on a real device),
      `close()` throws `MissingPluginException` as an **unhandled async
      error during teardown** — caught by `vision_provider_test.dart`
      ("This test failed after it had already completed"), not by
      inspection. Fixed by wrapping each `close()` call in its own
      try/catch: nothing meaningful to do about a release failure at
      teardown time, the exact reasoning `CameraNotifier._disposeController`
      already documents for the same category of problem
- [x] `dart format .`, `flutter analyze` (No issues found), `flutter
      test` — all passed, **172/172** (new: `vision_mapping_test.dart`
      covering full-text/line-flattening/empty-result mapping and
      confidence-descending label sorting; `vision_provider_test.dart`
      confirming `scanText`/`labelScene` never throw with no native
      handler in this test environment; `vision_screen_test.dart` covering
      every non-live-feed camera state, same category of gap as
      `camera_preview_screen_test.dart` — the live `CameraAvailable` +
      real-recognition-result render path isn't covered, see
      KNOWN_LIMITATIONS.md; `diagnostics_screen_test.dart` updated for the
      new Vision section)
- [x] `flutter build apk --debug` — passed (~155s; first build after
      adding the two new ML Kit native Android dependencies, consistent
      with this project's established first-native-dep Gradle slowdown
      pattern)
- [x] Ran the app live in Chrome — booted to a running Dart VM Service,
      `main()` started, no exceptions logged.

### Real-device verification + a real pre-existing bug found and fixed (2026-08-21)
A second real device connected mid-session — Samsung SM G781B (Android 13,
API 33) — closing the "not verified live" gap the Phase 13 entry above
originally left open.
- [x] Opened `VisionScreen` via diagnostics → "Preview vision": the screen
      hung indefinitely on "Starting the camera…", never reaching the live
      feed. Camera permission was already `granted=true` at the OS level
      (confirmed via `adb shell dumpsys package`), ruling out a stuck
      permission dialog
- [x] **Isolated the bug before touching any code**, per the debugging
      request: tried Phase 9's existing `CameraPreviewScreen` ("Preview
      camera") independently — it hung identically. Since `VisionScreen`
      and `CameraPreviewScreen` share the exact same `cameraProvider`/
      `CameraNotifier`/`CameraService` code path with no Vision-specific
      camera logic, this proved the bug was pre-existing in the shared
      camera stack, not anything Phase 13 introduced
- [x] Force-stopped the app and relaunched it fully fresh (undebugged, via
      `adb shell monkey`) with a clean `adb logcat` capture, to rule out
      stale in-memory provider state and catch the real, first-ever
      failure. **Root cause found in the crash log**: an "Unhandled
      Exception: Tried to modify a provider while the widget tree was
      building" thrown from `CameraNotifier.start()` (`camera_provider.dart:73`,
      the `state = const CameraRequesting();` line), called synchronously
      from `_CameraPreviewScreenState.initState()`
      (`camera_preview_screen.dart:27`). Riverpod 3.x forbids mutating
      provider state during a widget life-cycle method; the exception is
      thrown inside the *unawaited* `Future` `start()` returns, so it
      never crashes the UI visibly — it just aborts before
      `listCameras()`/`initializeController()` ever run, permanently
      freezing the state at `CameraRequesting`
- [x] **Confirmed this is a pre-existing Phase 9 gap, not a Phase 13
      regression**: grepped every `initState` in `lib/` for a direct
      `ref.read(...).` call — only `CameraPreviewScreen` and `VisionScreen`
      (which copied the same pattern) do this synchronously; every other
      screen either doesn't call a notifier from `initState` or does so
      inside a later async callback (e.g. `home_screen.dart`/
      `navigation_screen.dart`'s map-gesture `.listen()`), which is safe.
      This also explains why it was never caught before: KNOWN_LIMITATIONS.md
      already flagged `CameraPreviewScreen`'s live-feed path as never
      verified on real hardware, even through the Phase 11 real-device
      session — this was the first time this exact code path ever ran on
      a physical device
- [x] **Fixed with the smallest appropriate change** — deferred both
      `initState` calls with `WidgetsBinding.instance.addPostFrameCallback`
      (a `mounted` check guards against the callback firing after an
      instant pop), exactly Riverpod's own documented fix for this error.
      `CameraNotifier`/`CameraService` themselves were untouched — the bug
      was in the calling pattern, not the notifier's logic
- [x] Added a regression test to both `camera_preview_screen_test.dart`
      and `vision_screen_test.dart` using the **real** (non-overridden)
      `CameraNotifier` — the existing tests all use a fixed/no-op notifier
      that never exercises the real synchronous `state = CameraRequesting()`
      mutation, which is exactly why they never caught this
- [x] `dart format .`, `flutter analyze` (No issues found), `flutter
      test` — all passed, **174/174** (2 new regression tests)
- [x] `flutter build apk --debug` — passed (~40s); reinstalled on the
      device and **verified for real**: "Preview camera" now shows the
      live feed; "Preview vision" now shows the live feed, and both "Scan
      text" and "Label scene" were exercised for real — the device log
      confirmed genuine on-device ML Kit OCR model loading
      (`com.google.mlkit.dynamite.text.latin`, real TFLite models under
      `mlkit-google-ocr-models/gocr/...`), with results shown in the app.
      No crash signature anywhere in the post-fix log
- [x] Phase 13's OCR and scene-labeling features are now genuinely
      verified end-to-end on real hardware, closing the gap the original
      Phase 13 entry left open — see KNOWN_LIMITATIONS.md for the updated
      status

### Phase 14 — Backend/Supabase (2026-08-21, in progress)
- [x] **Scope decision, made with the project owner up front**: the phase
      covers auth, saved places, history, and preferences per
      DEVELOPMENT.md's module map. Built auth (the foundation everything
      else needs, since Row Level Security requires a real signed-in
      user) and saved places (the most concretely promised feature — the
      home screen's "Saved" quick action has said "arrives in a later
      phase" since Phase 2) this round; history and preferences
      deliberately deferred to keep this phase reviewable, same
      incremental discipline as every prior phase — see Pending Tasks
- [x] **Auth method — decided with the project owner**: email/password.
      Magic link and Google OAuth were both real options (verified via
      `supabase_flutter`'s own docs) but need meaningfully more setup
      (email deliverability + deep-linking, or a Google Cloud OAuth
      client + platform-specific redirect config) — the same category of
      tradeoff Phase 11's Google Maps key introduced. Email/password
      needed zero extra native platform config
- [x] Verified `supabase_flutter` before adopting (per DEVELOPMENT.md's
      rule): 2.17.2, published 6 days prior, verified `supabase.io`
      publisher, resolves cleanly against this project's Dart 3.10.3 —
      unlike Phase 13's ML Kit packages, no SDK-version conflict this
      time
- [x] **Real, current-API correction caught by `flutter analyze` before
      shipping**: `Supabase.initialize`'s `anonKey` parameter is
      deprecated in `supabase_flutter` 2.17 in favor of `publishableKey`
      — Supabase is mid-migration from "anon key" to "publishable key"
      terminology across its SDK *and* dashboard (confirmed via a real
      web search of Supabase's own migration docs, not assumed). Used
      `publishableKey` throughout, including the `.env` variable name
      (`SUPABASE_PUBLISHABLE_KEY`, not `SUPABASE_ANON_KEY`) and the setup
      instructions, so nothing here points at stale terminology
- [x] **API key infrastructure — real, not faked, with an honest gap**:
      no real Supabase project exists yet (creating one is the project
      owner's step — see SETUP.md). `.env`/`.env.example` hold a clearly-
      marked placeholder (`YOUR_SUPABASE_URL_HERE`/
      `YOUR_SUPABASE_PUBLISHABLE_KEY_HERE`). `SupabaseConfig.isConfigured`
      (`lib/core/config/supabase_config.dart`) checks for real, non-
      placeholder values; `main.dart` only calls `Supabase.initialize`
      when configured (calling it with a placeholder URL would throw and
      crash app boot — a real, meaningfully different failure mode from
      `GeocodingService`'s lazy per-request check, since
      `Supabase.initialize` parses/validates the URL eagerly)
- [x] `AppUser` (`lib/models/app_user.dart`) decouples the app from
      `supabase_flutter`'s `User`. `AuthService`
      (`lib/services/auth_service.dart`) wraps `GoTrueClient` —
      email/password sign-up/sign-in/sign-out, a real `userChanges`
      stream (empty when not configured, so nothing ever touches
      `Supabase.instance` before it exists), one custom
      `AuthServiceException` callers catch (same "one exception type"
      pattern `GeocodingService`/`RoutingService` use)
- [x] `AppAuthState` sealed hierarchy + `AuthNotifier`
      (`lib/core/providers/auth_provider.dart`) — named `AppAuthState`,
      not `AuthState`, since `supabase_flutter` already exports its own
      `AuthState` type and the collision would be real, not just a style
      preference. Mirrors `LocationNotifier`/`CameraNotifier`'s shape:
      `AppAuthNotConfigured`/`AppAuthUnauthenticated`/`AppAuthenticating`/
      `AppAuthEmailConfirmationRequired`/`AppAuthenticated`/`AppAuthError`.
      `AppAuthEmailConfirmationRequired` is a first-class state (a
      successful sign-up with no session yet, because Supabase's default
      settings require confirming via email) — not shoved into the error
      state, same "real non-error states are first-class" rule
      `CameraUnavailable`/`RouteState.modeUnsupported` already established
- [x] `AuthScreen` (`lib/features/auth/auth_screen.dart`) — one screen
      toggling between sign-in/sign-up (they share every field), honest
      not-configured/authenticating/error states, generic error copy (raw
      Supabase error text is never shown to normal users, same rule as
      location/search/route/navigation). `AccountScreen`
      (`lib/features/auth/account_screen.dart`) — signed-in email, a
      real "Sign Out" action, and an entry point to saved places
- [x] `SavedPlace` (`lib/models/saved_place.dart`) wraps the existing
      `Place` (Phase 5) plus the row's id/timestamp, rather than
      duplicating name/address/lat/lng fields. `SavedPlacesService`
      (`lib/services/saved_places_service.dart`) wraps the real
      `saved_places` Postgres table (list/save/remove) — Row Level
      Security (`supabase/schema.sql`) is the real access-control
      boundary, so this class never sends a `user_id` filter itself, the
      table's own `default auth.uid()` and RLS policies do that
      server-side. `SavedPlacesState` sealed hierarchy + notifier mirror
      `SearchState`'s shape
- [x] `SavedPlacesScreen` (`lib/features/saved_places/saved_places_screen.dart`)
      — real list with a delete action, honest empty/loading/failed
      states. Wired into three real entry points: the home screen's
      "Saved" quick action (routes to sign-in first if signed out, the
      real list if signed in — Home/Work/Recent stay honest "coming soon"
      this round, see below), `AccountScreen`, and a new "Save this
      place" button on `RoutePreviewScreen` (routes to sign-in if signed
      out, saves + a confirmation snackbar if signed in)
- [x] `supabase/schema.sql` — the real schema (table + RLS policies) for
      the project owner to run in the Supabase SQL Editor once their
      project exists; this session has no direct database access, so
      applying it is a manual step, the same category as the Google Maps
      Console clicks Phase 11 needed
- [x] `dart format .`, `flutter analyze` (No issues found), `flutter
      test` — all passed, **212/212** (new: `supabase_config_test.dart`
      covering the real not-configured/placeholder/partially-configured/
      real-values matrix via `dotenv.loadFromString`;
      `auth_service_test.dart`/`saved_places_service_test.dart`
      confirming every method throws a real, honest exception rather than
      touching an uninitialized `Supabase.instance`;
      `auth_provider_test.dart`/`saved_places_provider_test.dart` for the
      notifier state machine; widget tests for `AuthScreen`/
      `AccountScreen`/`SavedPlacesScreen`/`QuickActionRow` using the same
      fixed-notifier-override pattern established in Phase 9)
- [x] `flutter build apk --debug` — passed (~60s; first build with
      `supabase_flutter`'s native Android dependencies)

### Real-device verification + three real bugs found and fixed (2026-08-21)
The project owner created a real Supabase project
(`juxbishaqnymsdrxitwu.supabase.co`), ran `supabase/schema.sql` in the SQL
Editor, and provided the real Project URL + Publishable key. Verified the
schema landed for real before touching a device: a temporary throwaway
script (`_manual_verify_supabase_schema.dart`, real network call, deleted
immediately after — same pattern Phase 11 used to verify the Maps key)
first confirmed the table was missing (schema not yet run), then confirmed
it existed with RLS correctly blocking anonymous access (0 rows, no
error) once the owner ran it. The same Samsung SM G781B then reconnected
(after a real USB "offline"/"unauthorized" hiccup, fixed with `adb
kill-server`/`start-server` and re-accepting the debugging prompt) for a
full live verification pass.
- [x] **Real bug #1 — a Navigator race, found via `flutter run` + a
      temporary diagnostic print trail (not guessed).** Selecting a
      destination in `SearchScreen` never opened `RoutePreviewScreen`,
      even with a confirmed-accurate GPS fix. Root-caused by adding
      real diagnostic prints around the exact push/pop calls and watching
      the actual sequence on-device: `HomeScreen`'s
      `ref.listen(selectedDestinationProvider, ...)` fires *synchronously*
      inside `SearchScreen._select()`'s call to `.select(place)` (Riverpod
      notifies listeners synchronously on `state =`), pushing
      `RoutePreviewScreen` *before* `_select()` reaches its own
      `Navigator.of(context).pop()` call. Since both operations share one
      Navigator, that `pop()` removed whatever was now on top — the
      freshly-pushed `RoutePreviewScreen` — not `SearchScreen`. Confirmed
      in the log: `push() call returned` → `about to pop` → `pop() call
      returned` → `RoutePreviewScreen route completed/popped`, all within
      ~13ms. Fixed with a one-line reorder in `search_screen.dart`: pop
      `SearchScreen` *before* setting the destination, so any resulting
      push lands on a Navigator whose top is already back to Home — no
      change needed to `HomeScreen`'s listener itself. Added a regression
      test (`search_screen_test.dart`) reproducing the exact race pattern
      in isolation (a fixed `SearchNotifier` + a `HomeScreen`-shaped
      listener widget), since the bug could not have been caught by any
      existing test
- [x] **Real bug #2 — `AuthService.signUp` checked the wrong response
      field.** After signing up, the app showed "signed in" (email
      displayed on `AccountScreen`), but a fresh sign-in with the same
      credentials later failed with a real, honest "Email not confirmed"
      — revealing the original "success" had never been a real session.
      Root cause: `signUp` checked `response.user` to decide between
      `AppAuthenticated`/`AppAuthEmailConfirmationRequired`, but
      Supabase's sign-up response includes a real `user` object even when
      email confirmation is still pending — only `response.session` is
      actually null in that case. The app had been treating an
      unconfirmed account as a real authenticated session with no session
      token at all, which is *also* almost certainly why bug #3 below
      happened invisibly. Fixed by checking `response.session` instead,
      pulled into a small pure function (`hasRealSession`) for
      testability, plus a real, distinct `AppAuthEmailConfirmationRequired`
      state on the *sign-in* path too (previously only reachable from
      sign-up) — `AuthService` now recognizes gotrue's real
      `email_not_confirmed` error code rather than showing a generic
      "couldn't sign in" message for a case with an honest, actionable
      explanation
- [x] **Real bug #3 — a false-positive success message, found because bug
      #2 made it reproducible.** `RoutePreviewScreen`'s "Save this place"
      showed "Place saved." unconditionally, without checking whether the
      save actually succeeded — a real violation of this project's "no
      faked functionality" rule. It had been masking bug #2's real save
      failures (no valid session → RLS rejects the insert) the whole
      time. Fixed by changing `SavedPlacesNotifier.save()` to return
      `bool`, and `RoutePreviewScreen._saveThisPlace()` to await and show
      honest success/failure feedback
- [x] **A real, deliberate project-configuration decision, made with the
      project owner**: Supabase's free-tier shared email service didn't
      deliver the confirmation email in a reasonable time (a known,
      real deliverability limitation of shared SMTP on free-tier
      projects, not a bug in this app). Rather than keep fighting email
      deliverability while building, the owner turned off "Confirm
      email" in the Supabase dashboard for this dev project — every
      sign-up gets a real session immediately now. This needs to be
      revisited before any production release (turning confirmation back
      on, and/or configuring a real transactional email provider) — see
      KNOWN_LIMITATIONS.md
- [x] **Full real-device verification, confirmed working end-to-end**:
      sign-up, sign-in (including the honest "email not confirmed" path
      before the setting was changed), "Save this place" from route
      preview with a real honest success confirmation, and the saved
      place appearing in the real `SavedPlacesScreen` list — all
      confirmed directly by the project owner operating the device
- [x] Added regression tests for all three bugs: the Navigator-race test
      above, `hasRealSession`/`AuthServiceException.isEmailNotConfirmed`
      unit tests, and a `SavedPlacesNotifier.save()` test confirming it
      now returns `false` on failure. `dart format .`, `flutter analyze`
      (No issues found), `flutter test` — all passed, **217/217**
- [x] `flutter build apk --debug` — passed after every fix; each was
      verified live on the device before moving to the next, not assumed
      fixed from the diff alone

### Phase 15 — Testing, expanded (2026-08-21)
- [x] **Scope decision, made with the project owner up front**: three
      real, genuinely different directions were on the table (closing
      already-flagged unit/widget gaps, adding coverage reporting, and
      adding real on-device integration testing). The owner chose all
      three rather than picking one
- [x] **Closed three specific gaps already named in KNOWN_LIMITATIONS.md**:
      - `search_provider_test.dart` (new) — timing-precise coverage of
        the real debounce → loading → results sequence via `fakeAsync`,
        previously only covered by a non-timing-precise idle/failure
        widget test. Needed a small testability hook
        (`SearchNotifier.createService`, `@visibleForTesting`) so a test
        could inject a fake `GeocodingService` while keeping the real
        `Timer`-based debounce logic intact — the same "override just the
        service, keep the real state machine" pattern already used
        throughout this project's fixed-notifier tests, just for a
        service dependency instead of a whole notifier this time
      - `navigation_provider_test.dart` gained a full simulated-drive
        test — a continuous sequence of GPS fixes walking the entire
        route from origin through the turn to arrival, rather than only
        isolated single-update snapshots
      - `location_provider_test.dart` gained a real resubscribe-on-speed-
        bucket-change test (`LocationNotifier.createService`, same
        pattern), confirming the stream cancel/resubscribe wiring
        actually fires with a wider `distanceFilter` — previously only
        the pure `speedBucketFor`/`distanceFilterMetersForSpeedBucket`
        functions were tested, not the notifier wiring that calls them
      - **Three real test-authoring bugs were caught and fixed while
        building these** (not app bugs): the search test's fake service
        needed a real fake-clock-controlled delay, or `fakeAsync.elapse()`
        resolved the debounce timer *and* the search Future in the same
        pass, making the intermediate `SearchLoading` state
        unobservable; the resubscribe test's driving-speed fixture
        needed a much higher raw speed than the driving threshold itself,
        because Phase 8's real exponential smoothing (α=0.35) blends a
        raw speed toward the previous smoothed value before the
        speed-bucket decision reads it; the full-drive test's assumed
        "approaching" distance (~22m) was actually inside the real
        arrival/turning threshold (25m) — closer to the maneuver than
        intended, so the code correctly advanced past it, which is real,
        correct behavior the test's own premise had gotten wrong
      - `dart format .`, `flutter analyze` (No issues found), `flutter
        test` — all passed, **222/222** (5 new)
- [x] **Added LCOV coverage reporting**: `coverage` package (dev
      dependency) + `flutter test --coverage` (the project's own built-in
      Flutter test runner, not the `coverage` package's
      `test_with_coverage` script — see the "real gap caught" note below)
      produces `coverage/lcov.info`. **Current baseline: 73.7% line
      coverage (1476/2002 lines)**. Lowest-covered files are almost all
      already-documented, permanent categories: real platform/plugin
      interaction code with no fake in `flutter test` (`location_service.dart`
      9%, `app_map_controller.dart` 7%, `camera_service.dart` 40%), and
      live-feed render paths already flagged in KNOWN_LIMITATIONS.md
      (`vision_screen.dart` 36%). `genhtml` (lcov's HTML report tool)
      isn't installed on this machine — `coverage/lcov.info` itself is
      the artifact (consumable directly by CI services or editor
      extensions like VS Code's Coverage Gutters); not attempted to
      install a system tool without the project owner's go-ahead
- [x] **Real gap caught before it wasted more time**: `dart run
      coverage:test_with_coverage` (the `coverage` package's own
      documented automated workflow) crashed with a native VM stack
      unwind — it runs the plain `dart test` runner, which isn't
      Flutter-aware and can't handle this project's `flutter_test`-based
      widget tests or plugin dependencies. The correct tool for a Flutter
      project is Flutter's own built-in `flutter test --coverage`, which
      worked immediately once used instead
- [x] **Added real on-device integration testing** via `package:integration_test`
      (Flutter SDK package) — `integration_test/app_test.dart` runs the
      real, unmodified `app.main()` entry point with real platform
      bindings on a real device, not `flutter_test`'s fake environment.
      **Correction to this phase's own original scoping**: the concern
      that this would need `enableFlutterDriverExtension()` wired into
      production `main.dart` (from KNOWN_LIMITATIONS.md, based on the
      older `flutter_driver` package) turned out not to apply —
      `integration_test` is the modern, officially-recommended
      replacement specifically because it needs zero production code
      changes; confirmed by reading the package's own README before
      writing any code. Added `test_driver/integration_test.dart` too,
      for `flutter drive`/CI compatibility
- [x] **Scoped the first integration test to the boot → splash →
      onboarding flow only** — deliberately nothing requiring GPS,
      camera, or network permissions/credentials, so it runs standalone
      on any connected device without extra setup. Deeper flows (search,
      navigation, camera, auth) are real candidates for future
      integration tests but need real permissions/credentials this
      automated pass can't grant on its own — not attempted this round
- [x] **Two real bugs found and fixed by actually running this on a
      physical device** (not by inspection — the same discipline every
      real-device session in this project has used):
      - `pumpAndSettle()` right after `app.main()` never returns while
        `SplashScreen`'s `LoadingIndicator` (an indeterminate
        `CircularProgressIndicator`) is showing — a perpetual animation
        that never "settles." Fixed with discrete `pump()` calls instead,
        only using `pumpAndSettle()` once safely on the onboarding
        `PageView`, which has no perpetual animation.
      - The real splash `Timer` (2s, not an animation) doesn't schedule
        a frame while waiting, so `pumpAndSettle()` alone returned well
        before it fired — unlike a normal widget test, there's no fake
        clock in a real on-device integration test to fast-forward
        through it. Fixed with a genuine `Future.delayed` wall-clock wait.
- [x] **Real, persistent USB flakiness on this dev machine, worked
      around live**: the connected Samsung SM G781B repeatedly dropped
      specifically during the ~20-25s Gradle build step (four consecutive
      failures — `adb` `offline`/`unauthorized` states, mid-build
      disconnects), even after `adb kill-server`/`start-server` recovery
      and a physical reconnect. Switched to **wireless ADB debugging**
      (`adb pair`, then `adb connect` to the device's Wi-Fi IP) at the
      project owner's choice, which avoided the USB connection entirely
      — the integration test then built, installed, and passed
      end-to-end on the first attempt over Wi-Fi
- [x] `flutter test integration_test/app_test.dart -d <device>` —
      **passed live on real hardware**: real app boot, real 2-second
      splash delay, real onboarding page navigation via real `tester.tap`
      gestures, all confirmed working end-to-end
- [x] `flutter analyze` clean across all new/changed files throughout
      this phase

### Phase 16 — Optimization (2026-08-21)
- [x] **Scope decision, made with the project owner up front**: three
      real directions were on the table (release build analysis/
      shrinking, real DevTools/frame-timing profiling, GPS/sensor
      update-rate tuning). The owner chose all three; for the third, I
      flagged a real risk up front (no long-duration outdoor field test
      available on this dev machine to validate new constants) and the
      owner chose to proceed anyway — scoped to one principled, tested,
      low-risk improvement rather than speculative re-tuning, see below
- [x] **Real, release-build-breaking bug found and fixed**: `flutter
      build apk --release --analyze-size` (the very first real release
      build attempted in this project's history — every prior phase only
      ever built debug APKs) failed outright with R8 reporting missing
      classes from Phase 13's `google_mlkit_text_recognition` dependency
      (`ChineseTextRecognizerOptions`, `DevanagariTextRecognizerOptions`,
      `JapaneseTextRecognizerOptions`, `KoreanTextRecognizerOptions` —
      referenced in the plugin's own Kotlin glue code's `when` branch,
      even though this app only ever uses `TextRecognitionScript.latin`).
      This had been silently broken since Phase 13 and nothing before
      Phase 16 would have caught it, since minification/shrinking turns
      out to already be **on by default** for release builds via
      Flutter's own current tooling — this project just never built a
      real release APK to notice. Fixed by creating
      `android/app/proguard-rules.pro` with the real `-dontwarn` rules
      R8 itself generated (`missing_rules.txt`), read directly rather
      than guessed, and wiring it into `build.gradle.kts`'s release
      `proguardFiles`
- [x] **Real APK size measured and cut ~45% for the device that matters**:
      the default `flutter build apk --release` bundles native libraries
      for all three ABIs (arm64-v8a, armeabi-v7a, x86_64) into one 80MB
      universal APK. `flutter build apk --release --split-per-abi`
      produces per-ABI APKs instead — 43.8MB for arm64-v8a (the
      connected Samsung SM G781B's real architecture, and what the
      overwhelming majority of real Android phones use today) vs. the
      80MB universal build. Also verified `flutter build appbundle
      --release` (the actual format Play Store expects, which delivers
      similarly-sized per-device splits automatically) builds cleanly
      with the same proguard fix
- [x] **Verified the shrunk release build actually works, not just
      compiles** — installed the real arm64 split APK on the connected
      device: real boot with no crash (confirmed via a real
      `adb logcat` capture, pid-scoped), the real Google Map rendered,
      and — after the project owner pointed out the route wasn't
      showing, correctly diagnosed as the same "no GPS fix yet in a
      fresh app session" behavior from Phase 14, not a shrinking
      regression — the full search → route preview flow (including the
      Phase 14 Navigator-race fix) worked correctly once a real GPS fix
      existed
- [x] **Real on-device frame-timing performance measured**, not assumed:
      a temporary `WidgetsBinding.instance.addTimingsCallback` logger
      (removed immediately after, same "temporary diagnostic, verify,
      remove" pattern this project has used throughout) captured real
      build/raster durations while the project owner panned and zoomed
      the live map on a `--profile` build (the correct mode for real
      performance data — not debug, which has JIT/assertion overhead,
      and not release, which strips DevTools instrumentation). Result
      over 308 real frames: **average 5.01ms/frame** (well under the
      16.67ms 60fps budget), only **2.6% of frames (8/308)** exceeded
      it. The single worst outlier (96ms raster) is attributable to the
      native Google Maps SDK's own platform-view rendering during a
      gesture, not to unnecessary Flutter widget rebuilds in this app's
      own code. **Real, honest "no significant jank found" result — no
      code changes were warranted from this pass**, which is itself a
      legitimate outcome of profiling, not a null result to hide
- [x] **One principled, tested GPS-smoothing improvement**: Phase 8's
      `smoothLocation` (`position_smoothing.dart`) used a single fixed
      exponential-smoothing alpha (0.35) regardless of how accurate the
      new fix actually was. Replaced with a real, bounded, accuracy-
      weighted alpha (`_effectiveAlpha`): a low-accuracy fix (near the
      50m threshold `location_filter.dart` still accepts) is trusted
      less (alpha 0.15, leans more on the previous smoothed value), a
      high-accuracy fix (≤5m) is trusted more (alpha 0.5, tracks more
      closely) — linearly interpolated and clamped between, a real,
      well-known technique (accuracy-weighted exponential smoothing),
      not an arbitrary re-guess of the single constant. Deliberately
      still centered near the original fixed value at middling accuracy
      for continuity. **Still not validated against a real long-
      duration outdoor GPS stream** (no way to do that on this dev
      machine, the same honest gap the original fixed alpha always
      had) — tracked in KNOWN_LIMITATIONS.md, not overstated as "tuned"
- [x] `dart format .`, `flutter analyze` (No issues found), `flutter
      test` — all passed, **224/224** (2 new tests for the accuracy-
      weighted smoothing behavior — existing `smoothLocation` tests used
      range assertions already compatible with a variable alpha, so
      none needed changing)
- [x] Left the connected device in a clean state afterward (uninstalled
      the profile/release test builds, reinstalled a normal debug build)

### Phase 17 — Production build (2026-08-21)
- [x] **Scope decision, made with the project owner up front**: this
      phase's name was, for once, concrete rather than vague — the
      repeatedly-flagged "release signing is still a TODO" gap (first
      noted Phase 11, repeated Phase 14/16) was the obvious real target.
      Two genuinely consequential, hard-to-reverse decisions needed the
      owner's explicit go-ahead before touching anything: generating a
      real release keystore (losing it means never being able to update
      the app under that identity again on a real store), and
      re-enabling Supabase email confirmation (a real UX/deliverability
      tradeoff, not just a config flip). Owner said yes to both
- [x] **Real release keystore generated**, following the official
      Flutter docs' exact current steps (fetched and read live, not
      recalled from memory, per DEVELOPMENT.md's rule): `keytool
      -genkeypair` (RSA 2048, 10000-day validity, alias `upload`) at
      `android/upload-keystore.jks`, migrated to the modern PKCS12
      format per keytool's own recommendation (the intermediate `.jks.old`
      backup was deleted — a real duplicate of sensitive key material,
      not worth keeping around). A strong random password
      (`openssl rand`) was generated rather than choosing something
      memorable/weak
- [x] `android/key.properties` created with the real credentials,
      confirmed already covered by `android/.gitignore`'s existing
      `key.properties`/`**/*.jks` rules (the Flutter template's own
      defaults — no gitignore changes needed)
- [x] `android/app/build.gradle.kts` wired up per the official pattern:
      a real `signingConfigs.create("release")` reading
      `key.properties`, with a **graceful-degradation fallback to debug
      signing** if `key.properties`/the keystore it points to don't
      exist — same resilience pattern `mapsApiKey`'s `local.properties`
      fallback already established, so a fresh clone without the real
      keystore still builds
- [x] **Verified with a real signed build, not just a successful
      compile**: `flutter build apk --release --split-per-abi
      --target-platform=android-arm64` (after a `flutter clean` — the
      officially documented step after a signing-config change, and a
      real transient Gradle-cache/Windows file-locking error was hit and
      resolved by simply retrying, unrelated to the signing change
      itself). Confirmed via `apksigner verify --print-certs` that the
      built APK is genuinely signed with the new certificate (`CN=TN AR
      Navigation...`), not the debug one. Installed and booted cleanly
      on the connected real device (confirmed via a real, pid-scoped
      `adb logcat` capture — no crash)
- [x] **Real SHA-1 extracted for the Google Maps API key restriction**:
      `04:40:47:33:6E:64:25:8F:97:33:86:AB:A4:10:49:75:5B:6F:1F:B7`.
      Adding this to the Google Cloud Console key restriction (alongside
      the existing debug SHA-1) is the project owner's step — this
      session has no access to their Google Cloud account; documented in
      SETUP.md
- [x] **Supabase email confirmation re-enabled and verified end-to-end,
      live** — a real sign-up with a genuinely new email produced a real
      confirmation email; clicking it redirected to Supabase's default
      "Site URL" (`localhost:3000`, meant for local web dev — a real,
      separate rough edge for a mobile-only app, see below) which failed
      to load, but the confirmation itself completed server-side before
      that redirect: reopening the app showed a real authenticated
      session. Confirmed this was a genuinely fresh confirmation, not
      persisted state, after first catching a real false alarm — an
      earlier "signed in" report turned out to be a session persisted
      from *before* confirmation was re-enabled (this session's repeated
      `adb install -r` calls preserve app data across reinstalls),
      resolved by signing out and testing with a truly new email
- [x] **Real, deliberate scope boundary**: Supabase's default Site URL
      (the confirmation email's redirect target) was left as-is rather
      than reconfigured — it's cosmetic only (confirmation completes
      before the redirect happens), and fixing it properly means real
      mobile deep-linking (a custom URL scheme so the link reopens the
      app instead of a browser dead end), which the project owner chose
      not to add this phase. Documented as a known, low-priority UX
      rough edge, not silently left unmentioned
- [x] Device left in a clean state afterward (uninstalled every test
      build, reinstalled a normal debug build)
- [x] `dart format .`, `flutter analyze` (No issues found — the Kotlin
      Gradle config change doesn't affect Dart analysis, re-run anyway
      for a clean final check), `flutter test` — all passed, **224/224**
      (no Dart test changes this phase; the real work was Android/Gradle
      config plus a Supabase dashboard setting)

## Pending Tasks (by upcoming phase)

- [ ] Post-Phase-17: add the release SHA-1
      (`04:40:47:33:6E:64:25:8F:97:33:86:AB:A4:10:49:75:5B:6F:1F:B7`)
      to the Google Cloud Console Maps API key restriction — the project
      owner's step, needs their Google Cloud account access
- [ ] Post-Phase-17: real production distribution still needs more than
      signing — a Play Console listing (screenshots, privacy policy,
      data-safety form), the `.env`-shipped Maps API key proxied through
      a real backend instead of bundled client-side (flagged since Phase
      11), and iOS build verification (still only scaffolded, never
      built — no Xcode on this Windows dev machine). None of these were
      in scope for "production build" as this project's 17-phase roadmap
      defined it (making a real, correctly-signed, working build) — see
      KNOWN_LIMITATIONS.md
- [ ] Phase 16 follow-up: if a real long-duration outdoor GPS field test
      ever becomes possible, validate (or retune) the new accuracy-
      weighted smoothing alpha range against it — not attempted this
      round, see this phase's entry above
- [ ] Phase 15 follow-up: integration-test deeper flows (search, route
      preview, navigation, auth, saved places) once there's a real way to
      grant the permissions/credentials they need in an automated
      on-device run — not attempted this round, see this phase's entry
      above
- [ ] Phase 15 follow-up: if `genhtml`/lcov tooling is ever installed on
      this machine, generate an HTML coverage report from
      `coverage/lcov.info` — not attempted this round without the
      project owner's go-ahead to install a system tool
- [ ] Phase 14 follow-up: before any production release, revisit turning
      "Confirm email" back on in the Supabase dashboard (or configure a
      real transactional email provider) — it was turned off for this
      dev project only because the free-tier shared email service wasn't
      delivering confirmation emails in reasonable time; see this phase's
      real-device verification entry
- [ ] Phase 14 follow-up: history (search/route history) and preferences
      tables — deliberately deferred this round to keep the phase
      reviewable; Home/Work quick actions (a labeled single saved place
      each) also still show the honest "coming soon" message rather than
      being folded into the generic saved-places table built this round
- [ ] Phase 10 follow-up: real AR rendering (world-anchored directional
      overlay) once a Flutter ARCore plugin proves itself maintained, or
      a device becomes available to verify hand-written native rendering
      against — not attempted this round; see this phase's entry above
- [ ] Phase 13 follow-up: true landmark/POI identification (would need the
      cloud-only Google Cloud Vision Landmark Detection API — a real
      cost/network tradeoff the owner hasn't opted into) and lane/road
      segmentation for AR overlay (would need a custom-trained TFLite
      model with real road-scene data — no way to validate on this dev
      machine); both deliberately deferred, not attempted this round —
      see this phase's entry above and KNOWN_LIMITATIONS.md
- [ ] Phase 14: Supabase (`supabase_flutter`), `.env` configuration
      (`flutter_dotenv`), auth, saved places / history / preferences tables
- [ ] iOS build verification on macOS/Xcode (scaffolded, untested on this
      Windows machine)
- [ ] First Git commit (repository initialized, files staged; commit not
      yet created — pending explicit request)

See `DEVELOPMENT.md` for the full module list and development workflow,
and `ARCHITECTURE.md` for the target architecture and provider interfaces.

## Known Limitations

See `KNOWN_LIMITATIONS.md` for the full, current list.

## MCP Tooling Summary

| Capability | Tool(s) | Status |
|---|---|---|
| Project inspection | `list_devices`, `analyze_files` | Verified working |
| Dart analysis | `analyze_files`, `dart_fix`, `dart_format` | Available |
| Flutter analysis | `analyze_files`, `run_tests` | Available |
| pub.dev search | `pub_dev_search`, `pub` | Available (not exercised — no packages needed yet) |
| Hot reload | `hot_reload`, `hot_restart` | Available; requires a running app (not launched yet) |
| Runtime errors | `get_runtime_errors`, `get_app_logs` | Available; requires a running app |
| Widget inspection | `get_widget_tree`, `get_selected_widget`, `set_widget_selection_mode` | Available; requires a running app |
| Screenshots | *(no dedicated screenshot tool identified; widget/runtime tools above cover live inspection)* | N/A |
| App interaction | `launch_app`, `stop_app`, `list_running_apps`, `flutter_driver` | Available |
