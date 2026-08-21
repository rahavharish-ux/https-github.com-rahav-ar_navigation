# Development Guide

## Principles

- **Incremental only.** One phase at a time; never break a previously
  working feature while adding a new one.
- **No faked functionality in the production path.** No fake GPS
  coordinates, fake routes, fake AR arrows, fake AI predictions shipped
  as if real. Development-only mocks (e.g. `MockLocationService`) are
  allowed but must live in a clearly separate location and never be
  wired into production builds.
- **No premature dependencies.** A package is added only when its phase
  begins, not in advance "just in case."
- **Business logic stays out of widgets.** UI widgets read state and
  call services; they don't own GPS math, routing logic, or AR
  calculations directly.

## Standard workflow for every feature

1. Explain what will be built.
2. Inspect the relevant existing files.
3. Implement the feature.
4. `dart format .`
5. `flutter analyze`
6. `flutter test`
7. Build/run the app.
8. Fix any errors.
9. Verify the feature actually works.
10. Report what changed, then move to the next phase.

## Phase roadmap

1. Project foundation — **complete**
2. UI/UX (design system + screen shells) — **complete**
3. Location/GPS — **complete**
4. Map — **complete**
5. Search — **complete**
6. Routing — **complete**
7. Turn-by-turn navigation — **complete**
8. Live tracking — **complete**
9. Camera — **complete**
10. AR navigation — **capability check complete; AR rendering deferred**
    (see KNOWN_LIMITATIONS.md — the Flutter/ARCore plugin ecosystem was
    found unmaintained/unproven; real device-support detection shipped
    instead, talking to Google's ARCore SDK directly)
11. Compass + IMU — **complete**
12. Hybrid localization — **complete** (scoped to GPS-gap detection +
    heading-source fusion — see PROJECT_STATUS.md; full inertial
    dead-reckoning was considered and deliberately not built, since a
    real position estimate during a GPS gap would drift without
    calibration this project has no way to validate)
13. Computer vision — **complete** (scoped to real on-device OCR
    (`google_mlkit_text_recognition`) + generic scene labeling
    (`google_mlkit_image_labeling`), run against a single captured camera
    frame; true landmark/POI identification and lane/road segmentation for
    AR overlay were researched and deliberately deferred — see
    KNOWN_LIMITATIONS.md — neither maps onto a real on-device ML Kit model)
14. Backend (Supabase) — **complete**: real email/password auth and
    saved places built, tested, and verified end-to-end on a real device
    against a real Supabase project; history/preferences deliberately
    deferred to keep the phase reviewable — see PROJECT_STATUS.md/
    KNOWN_LIMITATIONS.md for the three real bugs found and fixed during
    verification
15. Testing (expanded) — **complete**: closed three flagged unit/widget
    test gaps, added LCOV coverage reporting (73.7% baseline via
    `flutter test --coverage`), and added real on-device integration
    testing via `package:integration_test` — verified live on real
    hardware, see PROJECT_STATUS.md/KNOWN_LIMITATIONS.md for the real
    bugs found (a `pumpAndSettle()`/perpetual-animation gotcha, a real
    wall-clock wait needed for a plain `Timer`) and the real USB
    flakiness worked around via wireless ADB debugging
16. Optimization — **complete**: found and fixed a real release-build-
    breaking bug (missing R8/ProGuard rules for Phase 13's ML Kit
    dependency — release builds had been silently broken since Phase 13,
    since no phase before this had ever built a real release APK), cut
    real device-download size ~45% via `--split-per-abi`, verified real
    on-device frame-timing performance is good (avg 5.01ms/frame, 308
    real frames measured), and made one principled, tested, accuracy-
    weighted GPS-smoothing improvement — see PROJECT_STATUS.md/
    KNOWN_LIMITATIONS.md for full detail, including the real, separate
    release-signing gap this phase did not address
17. Production build — **complete**: closed the real, separate release-
    signing gap flagged since Phase 11/16 — generated a real upload
    keystore (following Flutter's current official docs), wired it into
    `build.gradle.kts` with a graceful debug-signing fallback so a
    fresh clone without the real keystore still builds, and verified
    with `apksigner verify --print-certs` that a real built release APK
    carries the new certificate and installs/boots on a real device.
    Also re-enabled Supabase email confirmation (off since Phase 14),
    verified live with a real confirmation email, and correctly
    diagnosed a false-alarm "signed in without confirming" report as a
    persisted pre-toggle session rather than a bypass — see
    PROJECT_STATUS.md/KNOWN_LIMITATIONS.md for the real SHA-1
    fingerprint (still needs adding to the Google Maps API key
    restriction — the project owner's own Google Cloud Console step)
    and the deliberately-left-alone `localhost:3000` confirmation-email
    redirect (cosmetic, not functionally blocking)

## Module map

| Module | Primary phase(s) |
|---|---|
| User & Authentication | 14 |
| Location Services | 3 |
| Map & Geographic Data | 4 |
| Search & Geocoding | 5 |
| Routing | 6 |
| Navigation Engine | 7–8 |
| Real-Time Tracking | 8 |
| AR Navigation | 9–10 |
| Sensor Fusion | 11–12 |
| Computer Vision | 13 |
| Backend | 14 |
| Settings & Personalization | 2, 14 |
| Analytics/Diagnostics | 15–16 |

## Planned architectural decisions

- **State management:** Riverpod (`flutter_riverpod`), added at the start
  of Phase 2.
- **Provider abstractions** (added when their phase begins, so the
  concrete implementation can be swapped later without touching UI code):
  - `MapProvider` — Phase 4
  - `RoutingProvider` — Phase 6
  - `GeocodingProvider` — Phase 5
  - `NavigationProvider` — Phase 7
  - `ARPlatformService` — Phase 10 (wraps ARCore now, ARKit later)
  - `VisionService` — Phase 13 (adopted: wraps ML Kit's `TextRecognizer`/
    `ImageLabeler`, both on-device; navigation still never depends on it
    succeeding — it's diagnostics-reachable only, same as
    `ArPlatformService`/`CameraService`)
- **Navigation state machine** (Phase 7+): `IDLE`, `PREPARING_ROUTE`,
  `ROUTE_READY`, `NAVIGATING`, `APPROACHING_TURN`, `TURNING`,
  `OFF_ROUTE`, `RECALCULATING`, `ARRIVED`, `PAUSED`, `ERROR` — replaces
  ad hoc boolean flags.

## Candidate packages by phase (not yet installed — evaluated when their phase starts)

| Phase | Capability | Candidate package(s) |
|---|---|---|
| 2 | State management | `flutter_riverpod` |
| 3 | GPS/location | `geolocator`, `permission_handler` |
| 4 | Map (swappable) | `flutter_map` + `latlong2` originally; replaced Phase 11 by `google_maps_flutter` (`latlong2` stays as the app's own canonical coordinate type) |
| 5 | Geocoding | Nominatim (`http`) originally; replaced Phase 11 by Google Places API (New), still via `http` |
| 6 | Routing | HTTP client against a routing API (e.g. OSRM/GraphHopper) (TBD) |
| 9 | Camera | `camera` |
| 10 | AR | Verified (Phase 10): every current Flutter/ARCore community plugin is unmaintained or unproven — none adopted. Real capability check talks to Google's ARCore SDK directly via a native `MethodChannel`, no Dart dependency added |
| 11 | Compass/IMU | Adopted (Phase 11): `flutter_compass` (0.8.1, real device heading) and `sensors_plus` (7.1.0, real accelerometer/gyroscope) — both verified maintained/resolvable before adopting |
| 13 | Computer vision | Adopted (Phase 13): `google_mlkit_text_recognition` and `google_mlkit_image_labeling` (both on-device, no cloud key) — verified actively maintained, but their latest pub.dev versions need Dart SDK ≥3.12.0 (above this project's 3.10.3), so `^0.16.0`/`^0.15.0` were pinned instead. True landmark ID (Cloud Vision-only) and lane/road segmentation (no stock ML Kit model) were evaluated and not adopted — see KNOWN_LIMITATIONS.md |
| 14 | Backend | Adopted (Phase 14): `supabase_flutter` (2.17.2) for real email/password auth + saved places (`flutter_dotenv` adopted early, Phase 11, for the Google Maps API key — reused for `SUPABASE_URL`/`SUPABASE_PUBLISHABLE_KEY`) |
| 14 | Connectivity | `connectivity_plus` |
| — | Local cache (settings, saved places offline cache) | `shared_preferences` or `hive` |

Before adopting any package: check it's actively maintained, compatible
with Flutter 3.38.4 / Dart 3.10.3, and prefer official documentation over
tutorials that may be out of date.

## Docs created as each phase needs them

`API.md`, `TESTING.md`, and `AR_TECHNICAL.md` are intentionally not
created yet — writing them now would mean documenting APIs, test
strategy, or AR mechanics that don't exist. They'll be created (not
faked) when Phase 6/14 (API.md), the test suite grows beyond a smoke test
(TESTING.md), and Phase 10 (AR_TECHNICAL.md) actually begin.
