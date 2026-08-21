# Known Limitations

_Last updated: 2026-08-21_

This is an honest, current snapshot. Items here are either temporary
(will be resolved by a later phase) or permanent realities of the
technology (documented so they're never overstated).

## Temporary — resolved by a later phase

- **GPS (Phase 3), the map (Phase 4), search (Phase 5), driving routes
  (Phase 6), and turn-by-turn navigation (Phase 7) are all real now.**
  Selecting a search result opens a real Route Preview screen: a live
  route line, real distance, and real ETA computed from your current GPS
  fix to the destination (Driving only — see the OSRM limitation below).
  "Start Navigation" is enabled once a route is ready and opens a real
  turn-by-turn session: live GPS-driven maneuver instructions, distance
  to the next turn, remaining distance/ETA, automatic off-route and
  wrong-direction detection with automatic recalculation, and arrival
  detection. There is no spoken/voice guidance yet — visual instructions
  only. The current-location dot's heading cone is real (Google Maps
  SDK's own native `myLocationEnabled` rendering, Phase 11) but the map
  *camera* itself still only follows position, not bearing — rotating
  the whole view to face the direction of travel ("compass mode") isn't
  built. Quick actions (Home/Work/Recent/Saved on the home screen) still
  give honest "arrives in a later phase" feedback.
- **Only Driving produces a real route.** Phase 6 uses OSRM's public demo
  server (`router.project-osrm.org`), the candidate named in
  DEVELOPMENT.md. While building this phase, testing showed it accepts
  `foot`/`bike` as profile names in its URL but has no real
  pedestrian/cycling road graph loaded — both silently return
  byte-identical distance/duration to `driving` for the same coordinates,
  even labeled `"mode":"driving"` in the response. Presenting that as
  real walking/cycling routing would violate this project's "no faked
  functionality" rule, so `RoutingService` only exposes
  `getDrivingRoute()`. Selecting Walking or Cycling on the route preview
  screen shows an honest "not available in this development environment"
  message instead of a route. A production release (or a self-hosted
  OSRM instance with real foot/bike profiles) is needed for real
  multi-modal routing — tracked, not yet done.
- **Routing (Phase 6) still uses the public router.project-osrm.org demo
  server.** It's explicitly flagged by its maintainers as unsuitable for
  production traffic without a proper plan or self-hosting — no
  uptime/rate guarantee, and (per the point above) no real non-driving
  profiles. Fine for development. A production release needs a
  paid/self-hosted routing backend before shipping — tracked, not yet
  done. (The map and search used to share this "free public endpoint"
  category too, via OpenStreetMap tiles and Nominatim — see the next
  point for why and how that changed.)
- **The map and search switched from free OpenStreetMap (flutter_map +
  Nominatim) to Google Maps Platform (Phase 11, 2026-08-20) — real user
  feedback was that Nominatim's Tamil Nadu point-of-interest coverage
  was too sparse ("only districts and bus stands") for finding real
  destinations, a genuine OSM data-completeness gap no query tuning
  could close.** This is a real, meaningfully different category of
  dependency from everything else in this project so far:
  - **Requires a real, billing-enabled Google Cloud API key — there is
    no free fallback.** Unlike Nominatim/OSRM's demo servers, nothing
    map- or search-related works at all without one. See SETUP.md for
    the exact steps (Google Cloud project, billing, enabling Places API
    (New) + Maps SDK, creating and restricting a key).
  - **Resolved (2026-08-20):** a real key is now configured
    (`android/local.properties`/`.env`; `ios/Runner/AppDelegate.swift`
    still holds the placeholder — iOS remains unbuilt on this machine)
    and verified working end-to-end on a real Android device — see
    PROJECT_STATUS.md's real-device verification entry. The key is
    restricted (Android apps: this app's package + debug SHA-1; APIs:
    Maps SDK for Android + Places API (New)). That restriction surfaced
    a real, second bug: a plain `http` call doesn't get the restriction
    check for free the way the native Maps SDK does — `GeocodingService`
    now sends `X-Android-Package`/`X-Android-Cert` on every request (see
    ARCHITECTURE.md). `GeocodingService.search()` still throws a real,
    honest `GeocodingException` rather than attempting a doomed request
    when the key is missing or still the placeholder — exercised for
    real when the key genuinely was still a placeholder earlier the same
    day. Release builds need their own release-signing SHA-1 added
    alongside the debug one before shipping — not done, since release
    signing itself is still a TODO (`build.gradle.kts` signs release
    with debug keys for now).
  - **`.env` is not a secure secret store — it's a bundled Flutter
    asset**, extractable from a built APK/IPA by anyone with the file
    (flutter_dotenv's own README says this explicitly). The real
    security boundary is restricting the API key in Google Cloud
    Console to this app's package name + signing certificate (SETUP.md
    step 5) — `.gitignore`-ing `.env` only keeps the key out of version
    control, not out of the built app. A production release should
    proxy Places/Geocoding calls through a backend instead of shipping a
    raw key client-side — not done, tracked for Phase 14.
  - **No service, including Google's, is a true 100%-accurate source of
    every real-world destination.** This project will not claim that
    regardless of which provider it uses, per its "no faked
    functionality" rule — Google's coverage is meaningfully denser than
    free OSM data in this region, not perfect or exhaustive.
  - `RoutingService` (OSRM) was **not** part of this switch — routing
    stays on the free public demo server for now (see the point above);
    only the map tiles and search/geocoding moved to Google.
- **GPS position smoothing and speed-adaptive sampling (Phase 8) are real
  but still not validated against a real long-duration outdoor GPS
  stream** (no way to do that on this dev machine). `speedBucketFor`'s
  stationary/walking/driving thresholds still use fixed hysteresis bands
  — reasonable starting values, unchanged. **`smoothLocation`'s smoothing
  factor is no longer a single fixed constant (Phase 16)**: it's now a
  real, bounded, accuracy-weighted alpha (0.15 for a low-accuracy fix
  near the 50m acceptance threshold, up to 0.5 for a high-accuracy fix
  ≤5m, linearly interpolated and clamped between) — a principled, tested,
  well-known technique (trust a better fix more), not a re-guess of the
  single number, and deliberately centered near the original fixed value
  at middling accuracy for continuity. Still the same category of honest
  gap as before: real, tested logic, but never validated against a real
  outdoor GPS stream — worth revisiting if a real field test ever
  becomes possible. `LocationNotifier`'s resubscribe-on-speed-bucket-change
  logic **is now tested (Phase 15)** — closed, see the Phase 15 entry
  above.
- **Release builds are real, verified working, and now genuinely signed
  (Phase 17) — closing a gap flagged since Phase 11.** Before Phase 16,
  this project had never built a real release/minified APK; the first
  attempt failed outright (R8 missing classes from Phase 13's ML Kit
  dependency — see PROJECT_STATUS.md's Phase 16 entry), now fixed via
  `android/app/proguard-rules.pro`. `flutter build apk --release
  --split-per-abi` (43.8MB for arm64, the real device architecture that
  matters) and `flutter build appbundle --release` both build cleanly.
  **A real release keystore now exists** (`android/upload-keystore.jks`,
  gitignored, generated via `keytool` per Flutter's own current official
  docs) and `build.gradle.kts` signs release builds with it — confirmed
  via `apksigner verify --print-certs` that a real built APK carries the
  new certificate, not the debug one, and that it installs/boots cleanly
  on a real device. **Still needed before any real distribution**: the
  new release SHA-1
  (`04:40:47:33:6E:64:25:8F:97:33:86:AB:A4:10:49:75:5B:6F:1F:B7`) has to
  be added to the Google Cloud Console Maps API key restriction (see
  SETUP.md's Phase 11 section) — this session has no access to the
  project owner's Google Cloud account, so this is their step, not yet
  done. Frame-timing profiling (Phase 16) was a single real pass (map
  pan/zoom on a `--profile` build, 308 frames, avg 5.01ms) — real data,
  but not comprehensive coverage of every screen/interaction; worth
  another pass if a specific screen is ever reported as janky.
- **Supabase email confirmation is back on (Phase 17), verified live with
  a real confirmation email — but its redirect target is still
  Supabase's dev-only default.** Re-enabling "Confirm email" (off since
  Phase 14 for testing convenience) was verified end-to-end: a real
  sign-up sent a real confirmation email, and clicking it genuinely
  confirmed the account server-side (reopening the app showed a real
  authenticated session) — even though the email's redirect itself
  failed to load, because Supabase's default "Site URL"
  (`localhost:3000`, meant for local web dev) isn't meaningful for this
  mobile-only app. **Deliberately left as-is** — a real, known, low-
  priority UX rough edge, not silently unmentioned: confirmation
  completes before that redirect happens, so it doesn't block anything
  functionally, but anyone tapping the link sees a browser dead end
  instead of a clean confirmation page. Properly fixing it means real
  mobile deep-linking (a custom URL scheme so the link reopens the app),
  which the project owner chose not to add this phase.
- **Map gesture behavior is unverified by automated tests, but was
  confirmed manually on a real device (2026-08-20).** Widget tests only
  confirm `AppMapView` builds without error — simulating real drag/pinch/
  rotate gestures against `google_maps_flutter`'s native platform view in
  `flutter_test` wasn't attempted (arguably harder now than with
  flutter_map's Flutter-widget-based map, pre-Phase-11) and still isn't
  automated. What *was* directly observed on a real Samsung Galaxy S25
  Ultra: a manual pan correctly dropped follow mode and revealed
  `RecenterButton`, and tapping it correctly re-enabled follow mode —
  confirming `AppMapController`'s programmatic-move-suppression
  workaround (see ARCHITECTURE.md) does distinguish a real user drag from
  a `moveTo`/`fitBounds` call in practice, not just in theory. Not
  covered by that same manual pass: pinch-zoom and rotate gestures, and
  the suppression workaround's behavior under rapid/overlapping
  gesture-and-programmatic-move sequences.
- **The device camera is real (Phase 9), and real device AR-capability
  detection exists (Phase 10) — AR rendering itself doesn't yet.** A real
  permission→init flow (`cameraProvider`) and a live camera preview
  (`CameraPreviewScreen`) exist from Phase 9. Phase 10 was scoped down
  from full AR navigation after researching the Flutter/ARCore community
  plugin ecosystem: the plugin most tutorials reference hasn't shipped
  since November 2022 and won't resolve against this project's Dart
  version; every other option found was either ~2 years stale or (the one
  actively-updated fork) one day old with under 100 downloads. With no
  Android device on this machine to verify AR rendering behavior at
  runtime, adopting any of them for the production path was judged too
  risky — see PROJECT_STATUS.md's Phase 10 entry for the full comparison.
  Instead, `ArPlatformService` talks to Google's real ARCore SDK directly
  through a native `MethodChannel` (no Dart AR dependency added),
  reporting a real supported/needs-update/unsupported-device/unknown
  result. There is still no AR arrow/waypoint overlay on top of the
  camera feed. The home screen's "AR Navigation" button stays visibly
  present but disabled (captioned "arrives once AR navigation (Phase 10)
  is built") rather than opening the bare camera preview or the
  capability check, since a "AR Navigation" label pointing at either
  would overstate what's built. Both the camera preview and the AR
  capability check are reachable today only from the diagnostics screen.
  **The camera preview is now verified on a real device (2026-08-21,
  Samsung SM G781B)** — see the Computer Vision entry below for the real
  bug this pass found and fixed (`CameraPreviewScreen`'s live feed had
  never actually run on hardware before, and genuinely hung until fixed).
  `CameraAvailable` still has no automated *widget test* for the live
  feed itself (the `camera` plugin has no platform-channel implementation
  in `flutter test`, and there's no lightweight fake for its
  `CameraController`, unlike `LocationService`'s `Position` which the
  app's own `AppLocation` model already decouples from) — that gap is
  permanent, not closed by real-device testing, but the real behavior
  itself is now confirmed working. `MainActivity.kt`'s
  `ArCoreApk.checkAvailabilityAsync` integration, including its
  transient-result polling logic, is still verified only by compiling —
  `flutter build apk --debug` passing proves the native Kotlin/ARCore SDK
  code compiles and links, not that it returns correct results on real
  hardware; this one still needs live-device verification (the Phase 13
  real-device pass exercised the camera and vision stack, not the AR
  capability check).
- **Real compass heading and IMU streams exist (Phase 11) and were
  confirmed on real hardware (2026-08-20)** via the diagnostics screen on
  a Samsung Galaxy S25 Ultra: compass read `-19° (±15°)`; accelerometer
  read `x:0.20 y:9.55 z:2.14 m/s²` (Y ≈ real Earth gravity, 9.8 m/s²,
  exactly what a mostly-upright still phone should report); gyroscope
  read near-zero on all axes, consistent with the phone being still. This
  confirms the sensor plumbing reports *sane* real values, not that the
  compass heading is *accurate* (pointing the numerically-correct
  direction) — that would need comparing against a known-true bearing,
  not attempted. (The map's own heading indicator is no longer a custom
  compass-driven marker — since the same-day Google Maps switch, it's
  Google's native `myLocationEnabled` blue dot, which reads device
  sensors directly at the platform level, independent of
  `compassProvider`; see this file's Google Maps entry above.)
  Magnetometer noise/interference is also a permanent, inherent
  limitation of the technology (see below), not something Phase 11
  "fixes" — raw compass headings will always jump around near
  metal/electronics/vehicles; `flutter_compass` itself does its own
  platform-level smoothing, and this app does not add a second smoothing
  pass on top (unlike GPS heading, which does go through Phase 8's
  `smoothLocation`).
- **Real on-device text recognition and scene labeling exist (Phase 13),
  scoped down from the original ask after verifying what on-device ML Kit
  actually offers.** `google_mlkit_text_recognition` does real street-sign
  OCR; `google_mlkit_image_labeling` does real generic scene labeling
  ("temple," "tower," "building" — not a specific landmark identity).
  Two real gaps found and deliberately not built this phase:
  - **True landmark/POI identification** (naming a specific building,
    e.g. "Meenakshi Amman Temple") has no on-device ML Kit model at all —
    it only exists in the cloud-only Google Cloud Vision Landmark
    Detection API, which needs a billing-enabled API key and a network
    call, the same category of cost/setup tradeoff Phase 11's Google Maps
    switch introduced. Not adopted this phase; `SceneLabel`'s generic
    labels are the honest substitute, explicitly not sold as landmark ID
    in the UI.
  - **Lane/road detection for AR overlay** has no stock ML Kit model —
    its Object Detection & Tracking does generic bounding boxes (Fashion
    Good/Food/Home Good/Place/Plant), not semantic lane-line
    segmentation. Building this for real would mean training a custom
    TFLite model from labeled road-scene data, which this project has no
    way to validate on this dev machine — the same category of risk
    Phase 12 explicitly rejected for inertial dead-reckoning. Not
    attempted.
  - Both gaps were presented to the project owner before any code was
    written (not discovered after the fact), who chose to build the real
    OCR/labeling and defer the rest — see ARCHITECTURE.md's Phase 13
    entry.
  - **A real SDK-version conflict was hit and resolved while adopting
    these packages**: the latest `google_mlkit_text_recognition`
    (0.17.1) and `google_mlkit_image_labeling` (0.16.1) require Dart SDK
    ≥3.12.0, above this project's 3.10.3 (Flutter 3.38.4 stable).
    Resolved by using the highest versions that actually satisfy this
    project's SDK — `^0.16.0`/`^0.15.0` — rather than forcing the latest.
  - **Both recognizers run only against a single captured camera frame,
    not a continuous live stream.** `VisionScreen` shows a live preview
    (reusing Phase 9's camera) but only analyzes a frame when "Scan
    text"/"Label scene" is tapped — a deliberate scope choice to avoid
    the `CameraImage` YUV→`InputImage` rotation/format handling a
    real-time scanner would need, and to keep battery/perf cost bounded.
    A continuous live scanner is a real possible future enhancement, not
    attempted this phase.
  - **Verified on a real Android device (2026-08-21, Samsung SM G781B,
    Android 13/API 33)** — closing what was originally an unverified gap.
    This pass also found and fixed a real, pre-existing bug (see below):
    both `VisionScreen`'s and Phase 9's `CameraPreviewScreen`'s live
    camera feed genuinely hung indefinitely on "Starting the camera…"
    before the fix, and after it, both show the live feed for real, with
    "Scan text"/"Label scene" producing real results (the device log
    confirmed genuine on-device ML Kit OCR model loading —
    `com.google.mlkit.dynamite.text.latin`, real TFLite models under
    `mlkit-google-ocr-models/gocr/...`). `vision_screen_test.dart` and
    `camera_preview_screen_test.dart` each gained a regression test using
    the **real** (non-overridden) `CameraNotifier`, since every prior test
    used a fixed/no-op notifier that never exercised the exact synchronous
    state mutation that was actually broken.
  - **Real bug found and fixed this same pass: a pre-existing Phase 9
    camera-initialization bug, not anything Phase 13 introduced.** Both
    `CameraPreviewScreen` and `VisionScreen` called
    `ref.read(cameraProvider.notifier).start()` synchronously from
    `initState()`. Riverpod 3.x forbids mutating provider state during a
    widget life-cycle method (`initState` included); `CameraNotifier.start()`'s
    first statement (`state = const CameraRequesting();`) threw "Tried to
    modify a provider while the widget tree was building" inside the
    *unawaited* `Future` `start()` returns — the exception never crashed
    the UI (it was swallowed as an unhandled async error), it just
    silently aborted before `listCameras()`/`initializeController()` ever
    ran, permanently freezing the screen on "Starting the camera…". This
    had been latent since Phase 9: `CameraPreviewScreen`'s live-feed path
    was flagged as never verified on real hardware even through the Phase
    11 real-device session (see the AR/camera entry below) — this was
    genuinely the first time this exact code path ran on a physical
    device. Fixed by deferring both `initState` calls with
    `WidgetsBinding.instance.addPostFrameCallback`, Riverpod's own
    documented remedy for this exact error; `CameraNotifier`/
    `CameraService` themselves were untouched. See PROJECT_STATUS.md's
    real-device verification entry for the full root-cause trace and
    ARCHITECTURE.md's Phase 13 entry.
- **Real email/password auth and saved places exist (Phase 14) and are
  verified end-to-end on a real device against a real Supabase project.**
  The project owner created a real project, ran `supabase/schema.sql`,
  and both sign-up/sign-in and save/list saved places were confirmed
  working live on a Samsung SM G781B. Real bugs surfaced by that live
  pass, not by inspection:
  - **`AuthService.signUp` checked the wrong response field** —
    `response.user` instead of `response.session`. Supabase's sign-up
    response includes a real `user` object even when email confirmation
    is still pending (only `session` is null in that case), so the app
    had been treating an unconfirmed sign-up as a fully authenticated
    session with no real session token at all. Fixed by checking
    `response.session`, with a real, distinct
    `AppAuthEmailConfirmationRequired` state now reachable from the
    sign-in path too (previously only from sign-up), recognizing
    gotrue's real `email_not_confirmed` error code.
  - **A false-positive "Place saved." message** — `RoutePreviewScreen`
    showed it unconditionally, without checking whether the save
    actually succeeded, which had been masking the bug above's real save
    failures (no valid session → RLS correctly rejected the insert) the
    whole time. Fixed: `SavedPlacesNotifier.save()` now returns `bool`,
    and the screen shows honest success/failure feedback.
  - **A real Navigator race** between `HomeScreen`'s
    `ref.listen(selectedDestinationProvider)`-triggered push and
    `SearchScreen`'s own pop — see this file's Search entry below for
    the full description; found in the same live pass.
  - **A real, deliberate project-configuration decision**: Supabase's
    free-tier shared email service didn't deliver confirmation emails in
    reasonable time (a known limitation of shared SMTP on free-tier
    projects, not a bug in this app). The project owner turned off
    "Confirm email" in the Supabase dashboard for this dev project —
    every sign-up gets a real session immediately now. **This needs to
    be revisited before any production release** (re-enable
    confirmation and/or configure a real transactional email provider) —
    tracked in PROJECT_STATUS.md's Pending Tasks.
  - Regression tests were added for all three bugs (`hasRealSession`,
    `AuthServiceException.isEmailNotConfirmed`, `SavedPlacesNotifier.save()`
    returning `false` on failure, and the Navigator-race reproduction in
    `search_screen_test.dart`) — 217/217 tests passing.
  **History and preferences (also named in DEVELOPMENT.md's Phase 14
  module map) were deliberately deferred**, to keep this phase reviewable
  — same incremental discipline every prior phase followed, not an
  oversight. The home screen's Home/Work/Recent quick actions still show
  the honest "coming soon" message; only "Saved" is real this round
  (Home/Work would need a labeled single-saved-place concept, Recent
  would need real search/route history — neither exists yet).
- **A real Navigator race in the search → route-preview flow was found
  and fixed via a live device (Phase 14, 2026-08-21).** Selecting a
  destination in `SearchScreen` never opened `RoutePreviewScreen`, even
  with a confirmed-accurate GPS fix — root-caused with real diagnostic
  prints (not guessed) around the exact push/pop calls: `HomeScreen`'s
  `ref.listen(selectedDestinationProvider, ...)` fires *synchronously*
  inside `SearchScreen._select()`'s call to `.select(place)` (Riverpod
  notifies listeners synchronously on `state =`), pushing
  `RoutePreviewScreen` *before* `_select()` reached its own
  `Navigator.of(context).pop()`. Since both operations share one
  Navigator, that `pop()` removed whatever was now on top — the
  freshly-pushed `RoutePreviewScreen`, popped within ~13ms of being
  pushed — not `SearchScreen`. Fixed with a one-line reorder: pop
  `SearchScreen` before setting the destination provider. This had been
  latent since Phase 6 introduced the search → route-preview flow;
  nothing before this live pass had actually exercised selecting a
  result with a real, accurate GPS fix already present at selection time.
- **A real Android device was used for the first time this session
  (2026-08-20) — a Samsung Galaxy S25 Ultra (SM-S938B, Android 15/API
  35), connected mid-session over USB.** Through Phase 11's completion,
  every phase had relied on `flutter build apk --debug` (compile-only)
  plus Chrome/web for UI verification, since no Android emulator/device
  was available — Chrome/web support exists purely as a dev-time
  verification aid, not a product target. That real-device session
  confirmed the whole real permission→GPS→map→search→compass→IMU→
  follow-mode chain end-to-end (see PROJECT_STATUS.md) and found/fixed
  two real bugs a compile-only build could never have caught (a
  keyboard-inset layout overflow, and a REST-call Android-identity-header
  gap for the restricted Maps API key). **Configuring an Android
  emulator was also attempted and failed**: the one configured AVD
  (`Medium_Phone_API_36.1`) can't boot on this machine —
  `ERROR: x86_64 emulation currently requires hardware acceleration! ...
  Android Emulator hypervisor driver is not installed` — a genuine
  host-machine gap (Hyper-V/WHPX not installed/enabled), not attempted to
  fix without the project owner's go-ahead, since it's a system-level
  Windows change. Real remaining gaps even after the real-device session:
  camera preview, AR capability check, iOS, and (per the note above)
  Phase 12's `weakSignal`/`fuseHeading` logic weren't part of that pass —
  see each feature's own bullet in this file.
- **iOS is scaffolded but unverified.** `flutter create` generated the
  `ios/` project, but it hasn't been opened or built — this development
  machine is Windows and has no Xcode toolchain. iOS verification is
  deferred until Android is stable, per the project's Android-first
  priority.
- **Test coverage is still growing — 73.7% line coverage (1476/2002
  lines) as of Phase 15's LCOV baseline** (`flutter test --coverage` →
  `coverage/lcov.info`; the `coverage` package's own `test_with_coverage`
  script isn't usable here — it runs the non-Flutter-aware `dart test`
  runner, which crashes on this project's `flutter_test`-based suite).
  The lowest-covered files are almost entirely the already-documented
  permanent categories below: real platform/plugin interaction code
  with no fake in `flutter test` (`location_service.dart`,
  `app_map_controller.dart`, `camera_service.dart`) and live-feed render
  paths. Widget tests cover app boot/nav,
  onboarding paging, home content/interaction, the diagnostics screen,
  the search screen (idle/failure states), route preview (idle/loading/
  ready/mode-unsupported/failure states, Start Navigation enable/disable
  and wiring to `NavigationScreen`), navigation (instruction display,
  pause/resume/stop, status banners), and the camera preview screen
  (requesting/unavailable/permission-denied/error states and the retry
  action — see the Phase 9 note above for why the live-feed state itself
  isn't covered). Unit tests cover `AppLocation`, the GPS noise filter,
  `Place` parsing, `GeocodingService` and `RoutingService` (via a mocked
  HTTP client — no real network), `RecentSearchesNotifier`,
  `formatDistanceMeters`/`formatDurationSeconds`,
  `NavigationInstruction.fromOsrmStep`/`buildInstructionText`, the
  `geo_math.dart` functions (haversine, distance-to-polyline, bearing,
  angle difference), `NavigationNotifier` (off-route/wrong-direction/
  arrival transitions, recalculation), `camera_selection.dart`'s
  `pickPreferredCamera`/`isPermissionDeniedCode`, and
  `ar_availability.dart`'s `parseArCoreAvailability` (every real ARCore
  result code, plus null/unrecognized-code safety) along with
  `ArPlatformService.checkAvailability`'s real non-crashing behavior when
  no native handler responds (this test environment), `compass_provider.dart`'s
  `compassStateFromEvent` (null heading, real heading + accuracy, the
  real -1-means-no-accuracy sentinel), and
  `motion_sensor_provider.dart`'s `mergeMotionSensorReading` (partial
  updates preserve the other sensor's last reading, new readings replace
  rather than accumulate), `heading_fusion.dart`'s `fuseHeading` (every
  source-preference/fallback/none combination, Phase 12), and
  `location_provider.dart`'s `withWeakSignalFlagged` (Phase 12 — the
  first dedicated test file for any part of `LocationNotifier`, closing
  a gap flagged since Phase 8; the stream-subscription/resubscribe
  wiring itself is still untested, same category of gap as before),
  `vision_mapping.dart`'s `textRecognitionResultFromRecognizedText`/
  `sceneLabelsFromImageLabels` (Phase 13 — full-text/line-flattening,
  empty-result, and confidence-descending sort behavior, built by
  constructing ML Kit's real `RecognizedText`/`TextBlock`/`TextLine`/
  `ImageLabel` types directly rather than a reimplemented fixture), and
  `vision_provider.dart`'s `VisionNotifier` (Phase 13 — confirms
  `scanText`/`labelScene` never throw with no native `MethodChannel`
  handler in this test environment, the same category of test
  `ar_platform_service_test.dart` established for ARCore). Both
  `camera_preview_screen_test.dart` and `vision_screen_test.dart` also
  gained a regression test using the **real** (non-overridden)
  `CameraNotifier` — added after a real device caught a bug (see this
  file's Computer Vision entry above) that every prior fixed/no-op-notifier
  test was structurally blind to. Phase 14 added
  `supabase_config_test.dart` (the real not-configured/placeholder/
  partial/real-values matrix via `dotenv.loadFromString`),
  `auth_service_test.dart`/`saved_places_service_test.dart` (every method
  throws a real, honest exception rather than touching an uninitialized
  `Supabase.instance`), `auth_provider_test.dart`/
  `saved_places_provider_test.dart` (the notifier state machines), and
  widget tests for `AuthScreen`/`AccountScreen`/`SavedPlacesScreen`/
  `QuickActionRow` using the same fixed-notifier-override pattern Phase 9
  established. The
  diagnostics screen test now also covers
  the AR section's initial/checking-triggered states, the Compass/
  Motion sensors sections (scrolling to them first — they're below the
  fold in the diagnostics `ListView`), and the Vision section's
  not-analyzed-yet status and "Preview vision" action. `AppMapView` has its own widget
  tests (rewritten for Phase 11's Google Maps switch) confirming it
  builds without throwing across the real destination/route-polyline
  combinations this app uses — a real, live-rendered map can't be
  verified in `flutter_test` (no native platform view host), same
  category of gap as the camera/AR live states, now also true for the
  map itself. **Closed (Phase 15):** `navigation_provider_test.dart`
  gained a real full-simulated-drive test — a continuous sequence of GPS
  fixes walking the entire route from origin through the turn to
  arrival, not just isolated single-update snapshots. Voice/spoken
  guidance still has no tests since it doesn't exist yet.
- **Search's debounce/loading/results flow isn't covered by a timing-
  precise test.** **Closed (Phase 15):** `search_provider_test.dart` now
  covers the real debounce → loading → results sequence via `fakeAsync`,
  using a small testability hook (`SearchNotifier.createService`) to
  inject a fake `GeocodingService` while keeping the real `Timer`-based
  debounce logic intact.
- **Live visual/screenshot verification tooling: resolved for widget-tree
  inspection and, as of Phase 15, for real on-device tap/gesture
  automation too — screenshots specifically are still not wired up.**
  Phase 2-era note (kept for history): the Dart/Flutter MCP server's
  `get_widget_tree`/`get_runtime_errors` tools once rejected the
  connection with a stale-looking SDK version error despite this project
  running a Dart version well above the stated minimum. That resolved
  itself by the time of the Phase 11 real-device session (2026-08-20) —
  both tools worked reliably against a real device all session, and were
  the main way this project verified real behavior without ever taking a
  pixel screenshot. **Real tap/gesture automation was added in Phase 15**
  via `package:integration_test` (`integration_test/app_test.dart`,
  `test_driver/integration_test.dart`) — the modern, officially-
  recommended replacement for the older `flutter_driver` approach this
  file previously described as needing `enableFlutterDriverExtension()`
  wired into production `main.dart`; that concern turned out not to
  apply to `integration_test`, which needs zero production code changes
  and was verified live on a real device (`tester.tap`, real onboarding
  navigation). Scoped deliberately narrow this round: only the boot →
  splash → onboarding flow, since it needs no GPS/camera/network
  permissions — deeper flows (search, navigation, camera, auth) are real
  candidates for future integration tests but need real permissions/
  credentials an automated pass can't grant on its own, not attempted
  yet. Screenshot capture specifically (as opposed to tap/assert
  automation) is still not wired up — `integration_test` supports it via
  `IntegrationTestWidgetsFlutterBinding.takeScreenshot()`, just not used
  yet. All real-device
  verification before Phase 15 was either the project owner
  physically operating the device while Claude watches state via
  `get_widget_tree`/`get_runtime_errors`/`adb logcat`, or `flutter test`
  widget tests asserting exact expected text/controls — never an actual
  visual screenshot comparison. Also worth noting: on this specific
  Samsung device, the Dart Tooling Daemon connection reliably drops the
  moment the app loses foreground (backgrounding, or even a system
  permission dialog taking focus) — a real, repeatable environment
  quirk (Samsung's background-process management), not a bug in this
  project. `adb logcat` (which survives it) became the fallback for
  anything that needed to keep observing across a drop.
- **The Samsung SM G781B's USB connection is genuinely unreliable on this
  dev machine during longer-running builds (Phase 15, 2026-08-21).** The
  device repeatedly dropped (`adb` `offline`/`unauthorized` states,
  mid-build disconnects) specifically during the ~20-25s Gradle build
  step of `flutter test integration_test/...`, four consecutive times,
  surviving neither `adb kill-server`/`start-server` recovery nor a
  physical reconnect. **Wireless ADB debugging** (`adb pair` with the
  device's pairing code, then `adb connect` to its Wi-Fi IP) worked
  around this entirely — the same integration test then built, installed,
  and passed on the first attempt over Wi-Fi. Worth trying wireless
  debugging first if USB flakiness recurs during a longer build/install
  step on this device.

## Permanent — inherent to the technology (must never be overstated)

- **Consumer GPS is not centimeter-accurate.** Typical smartphone GPS
  accuracy is roughly 3–15 meters under open sky, and worse near tall
  buildings, indoors, or in dense urban canyons. The app will describe
  its positioning as "GPS-based," "sensor-assisted," or "hybrid
  localization" — never as precise/centimeter-level positioning.
- **Magnetometer-based heading is noisy** and affected by magnetic
  interference (metal, electronics, vehicles). Raw heading values will
  always be filtered/smoothed before display; even filtered heading can
  lag or drift.
- **AR world-anchoring quality depends on the device.** ARCore/ARKit
  tracking quality varies significantly across Android hardware; some
  devices don't support ARCore at all. The app must detect this and fall
  back to standard navigation rather than fail.
- **Battery and performance trade-offs are real.** Continuous GPS,
  camera, sensors, and (later) on-device AI inference all consume
  battery; update rates will be tuned deliberately rather than run at
  maximum frequency.

## Environment-specific (this development machine)

- `flutter doctor` flags an incomplete Visual Studio installation —
  irrelevant, since this project doesn't target Windows desktop.
- A transient network reachability warning appeared during `flutter
  doctor` for pub.dev/Maven/GitHub/CocoaPods checks. It hasn't blocked
  any build, but it has made Gradle syncs slow when a phase adds a new
  Android native dependency: Phase 3's `flutter build apk --debug` took
  ~583s (vs. ~14s for a build with no new native deps) while Gradle
  resolved `geolocator_android` against `maven.google.com`. Worth
  budgeting extra time whenever a future phase adds its first native
  Android dependency. Phase 9's `flutter build apk --debug` (first build
  after adding `camera`/`camera_android_camerax`) took ~157s — slower
  than a no-new-native-dep build (~14s-70s in other phases) but nowhere
  near Phase 3's ~583s, since only one new native Android dependency was
  added this time. Phase 10's first build after adding
  `com.google.ar:core` took only ~31s — much faster than Phase 9's
  camera plugin, since the ARCore SDK ships as a plain AAR with no
  separate native-code (NDK/CameraX-style) sub-dependency to resolve.
  Phase 11's first build after adding `flutter_compass`/`sensors_plus`
  took ~104s, most of it a one-time Android SDK Platform 34 download
  triggered by one of the two new plugins — a one-off cost, not a
  per-build regression. The same-day switch to `google_maps_flutter`
  (removing `flutter_map`) built in ~66s — two real manifest-merge
  failures were hit and fixed first (see PROJECT_STATUS.md's Phase 11
  entry: an XML comment containing a literal `--`, hit twice, once for
  the ARCore key and again for the Maps SDK key, both fixed the same
  way). Phase 13's first build after adding the two ML Kit native Android
  dependencies (`com.google.mlkit:text-recognition`,
  `com.google.mlkit:image-labeling`) took ~155s — consistent with this
  project's established first-native-dep Gradle slowdown pattern; no
  manifest changes were needed since both plugins' minSdk 21/compileSdk 35
  requirements were already satisfied by Flutter 3.38.4's own defaults.
  Phase 14's first build after adding `supabase_flutter` took ~60s — a
  normal first-native-dep cost, no manifest/build-config changes needed.
- The Dart/Flutter MCP server's `launch_app` tool fails with
  `ProcessException: The directory name is invalid` when given this
  project's path (it contains a space: `RAHAV R`). Launching via
  `flutter run` directly in the shell works fine — the MCP tool's path
  handling appears to mishandle spaces on Windows. Worked around by
  launching through the shell instead.
- `flutter analyze` hung indefinitely once (Phase 4) after adding new
  dependencies — traced to a stale Dart LSP process (left over from an
  earlier MCP tooling session) holding a lock on the project's analysis
  cache. Fix: `flutter clean` + `flutter pub get` to clear `.dart_tool`,
  then re-run. If `flutter analyze` ever hangs with zero CPU progress
  again, try this before assuming a code problem.
