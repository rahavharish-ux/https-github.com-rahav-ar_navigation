# Feature Explanations

How every feature shown in the visualization works. Each entry gives:
**what it does · how you use it · how it works · technology · phase · benefit.**
Status tags match `IMPLEMENTATION_STATUS.md`:
🟢 Phase 1 · 🔵 Phase 2 M0 · 🟠 Phase 2 planned (not built) · ⚪ not built.

---

## A. Finding where to go

### 1. Home dashboard 🟢
- **What:** the start screen: a full-screen map with your position, the
  brand header, a search card, shortcuts and the travel-mode selector.
- **Use:** open the app (after splash/onboarding) and tap the search card.
- **How:** `HomeScreen` watches `locationProvider` and
  `selectedDestinationProvider`; the map follows your smoothed position until
  you pan it.
- **Tech:** Flutter, Riverpod 3, `google_maps_flutter` (wrapped by
  `AppMapController` / `AppMapView`).
- **Phase:** 1. **Benefit:** one glance shows where you are and where to start.

### 2. Live GPS position and accuracy 🟢
- **What:** your position on the map and a badge with coordinates and
  reported accuracy (e.g. `13.03384, 80.26904 (±6m)`).
- **Use:** tap the locate button; permission is asked only then.
- **How:** fixes worse than 50 m are rejected; tiny movements that aren't
  more accurate are ignored; accepted fixes are smoothed with an
  accuracy-weighted moving average (α 0.15–0.5). The GPS distance filter
  adapts to speed (3 / 5 / 15 m for stationary / walking / driving, with
  hysteresis). Three rejected fixes in a row set a weak-signal flag.
- **Tech:** `geolocator` (high accuracy), pure-Dart filters in `core/utils`.
- **Phase:** 1. **Benefit:** a steady marker without jumps, and honest accuracy.

### 3. Destination search 🟢 + 🔵 M0
- **What:** search places, landmarks and addresses; see your distance to
  each; reuse recent searches.
- **Use:** type at least 2 characters; tap a result.
- **How:** input is debounced 400 ms, then Google Places API (New) Text
  Search runs with a Tamil Nadu location bias (up to 8 results, 10 s
  timeout). **M0:** every query gets a generation number; a slower, older
  response is discarded instead of replacing newer results or reappearing
  after you clear the field.
- **Tech:** `http`, Places API (New), Riverpod.
- **Phase:** 1 (search), Phase 2 M0 (stale-result guard).
- **Benefit:** fast, relevant local results that always match what you typed.

### 4. Route preview 🟢 (driving) · 🟠 M3 (walking)
- **What:** the route line, travel time and distance before you start, plus
  "Save this place" and "Start Navigation".
- **Use:** select a destination; switch travel mode; tap Start Navigation.
- **How:** OSRM returns route geometry and turn steps; the screen draws the
  polyline and fits both ends on screen. Walking/Cycling currently show an
  honest "not available" message because OSRM's public demo has no
  pedestrian road graph. **M3** adds OpenRouteService `foot-walking` behind
  a replaceable `RoutingProvider`.
- **Tech:** OSRM public demo server (development only), `http`.
- **Benefit:** know the effort before committing to the trip.

## B. Navigating

### 5. Turn-by-turn 2D map navigation 🟢 + 🔵 M0
- **What:** an instruction card ("120 m — Turn right onto Luz Church
  Road"), remaining time and distance, Pause/Resume/Stop, and arrival.
- **Use:** follow the card; Pause stops progress updates; Stop ends the trip.
- **How:** every GPS update recomputes the distance to the next maneuver;
  the instruction advances within 25 m of a maneuver; "approaching" starts
  at 150 m; arrival is within 25 m of the destination. **M0** fixed
  remaining distance (it now adds the distance still to reach the next
  turn — before, the whole final leg read 0 m) and made Resume recompute
  from the newest GPS fix.
- **Tech:** `NavigationNotifier` (Riverpod), pure geometry in `geo_math.dart`.
- **Phase:** 1, hardened in Phase 2 M0.
- **Benefit:** reliable guidance that works on every phone, with or without AR.

### 6. Route deviation detection and automatic rerouting 🟢 + 🔵 M0
- **What:** notices when you leave the route and fetches a new one.
- **Use:** nothing to do — "Recalculating your route…" appears, then new
  instructions.
- **How:** more than 40 m from the route line = off-route. Moving away from
  the next turn (bearing difference > 120°) on 2 consecutive movements of
  ≥ 8 m = wrong direction, which catches a U-turn on a road that is still
  near the line. Either triggers a new OSRM route from your position; a
  failure retries on the next GPS update.
- **M0 lifecycle guarantees (all regression-tested):**
  - a reroute that finishes after **Stop** cannot restart navigation;
  - a reroute from an old session cannot overwrite a **new** session;
  - finishing while **paused** adopts the new route but stays paused;
  - **resuming** before it finishes waits for it — no second, parallel reroute;
  - progress is measured from the **newest** GPS fix, not the request-time one;
  - nothing writes state after the screen's provider is disposed.
- **Benefit:** recovery from wrong turns without the app ever "un-stopping"
  or ignoring a pause.

### 7. Live AR navigation 🟠 M5 (concept — not implemented)
- **What (planned):** the camera view with a large guidance arrow, the next
  instruction, remaining time/distance, a destination marker at the screen
  edge, and a Map button.
- **Use (planned):** start navigation and tap AR Navigation (enabled only if
  ARCore is supported and a route exists).
- **How (planned):** a native ARCore view embedded in Flutter
  (`AndroidView`), with rendering kept in Kotlin; Dart sends only scene
  content. In M5 the arrow is placed from **GPS position + compass
  heading**, so it is labelled **"Approximate"** — it points the right way
  but is not locked to the street. Street-locked (geo-anchored) arrows need
  ARCore Geospatial (VPS) in **M6**, and only where measured to work.
- **What exists today:** the ARCore capability check and a plain camera
  preview, both on the Diagnostics screen. The Home "AR Navigation" button
  is disabled.
- **Tech (planned):** ARCore, a native Android renderer (SceneView /
  Filament, to be verified at M5).
- **Benefit:** see the turn in the real world instead of matching a map to
  the street.

### 8. 2D map fallback 🟢 (2D navigation) · 🟠 M5 (automatic fallback)
- **What:** navigation always works on the map; with AR, the map becomes
  the fallback whenever AR can't run.
- **How:** today all navigation is 2D. M5 adds a capability state machine
  (AR-geospatial → AR-approximate → map → degraded) that steps down
  visibly when tracking, camera, heading or ARCore is lost, plus Map ⇄ AR
  buttons.
- **Benefit:** nobody is left without guidance because of their phone model.

### 9. Pause and resume 🟢 + 🔵 M0
See features 5 and 6: pause freezes progress updates; resume recomputes from
the latest GPS fix, or shows "Recalculating" if a reroute is still running.

## C. Understanding the scene

### 10. Text recognition (OCR) 🟢 (Diagnostics)
- **What:** reads printed text, such as a street sign, from one captured photo.
- **Use:** Diagnostics → Preview vision → **Scan text**.
- **How:** the camera takes a still; Google ML Kit's on-device recognizer
  returns lines of text. **Latin script only** — ML Kit's on-device models
  have no Tamil recogniser, so the Tamil line of a bilingual sign is not read.
- **Tech:** `google_mlkit_text_recognition`. No network, no API key.
- **Benefit:** private, offline reading of English signage.

### 11. Scene labelling 🟢 (Diagnostics)
- **What:** generic labels with confidence for the whole photo.
- **How:** ML Kit image labeling. No positions, and no specific landmark names.
- **Tech:** `google_mlkit_image_labeling`.

### 12. Live object detection and hazard advisories 🟠 M7
- **Planned:** a LiteRT detector at ≤ 10 Hz on camera frames (from ARCore in
  AR mode), with tracking and rule-based advisories ("vehicle approaching").
  Licence rule: Apache-2.0 or similar permissive models only (no AGPL). The
  advisory is never a safety guarantee and never says "safe to cross".

### 13. Tamil + English sign reading, landmarks, walkable surface 🟠 M8
- **Planned:** on-device Tamil OCR (PaddleOCR-family vs Tesseract `tam`,
  benchmarked first); landmark recognition by ranking Google Places
  candidates inside the camera's field of view, always shown with
  confidence; low-rate road/sidewalk/crosswalk segmentation.
  Cloud vision is not planned.

### 14. Camera lifecycle and recovery 🔵 M0
- **What:** the camera behaves correctly when you leave and return to the app.
- **How:** any non-resumed lifecycle state releases an open camera, and
  `resumed` reopens it only if lifecycle released it. The permission dialog
  (which makes the app `inactive`) does not cancel a starting camera. A
  camera that finishes initialising after Stop, after disposal, or while
  the app is in the background is released instead of shown. A capture
  interrupted by backgrounding returns nothing instead of crashing.
- **Tech:** `WidgetsBindingObserver` via `CameraLifecycleBinding`, pure
  decision function `cameraLifecycleActionFor`.
- **Benefit:** no frozen previews, no camera held in the background, no
  crashes on interruption.

## D. Personal places

### 15. Account (email sign-in) 🟢
Supabase Auth with email confirmation; a dedicated "confirm your email"
state; works without a backend only in an honest "not configured" mode.

### 16. Saved places 🟢
- **What:** save destinations from Route Preview; list and delete them.
- **How:** Supabase Postgres table `saved_places` with Row Level Security
  for select, insert and delete — the server, not the app, enforces that
  each user sees only their own rows. "Place saved." appears only when the
  save really succeeded.
- **Benefit:** frequent destinations one tap away. Favourites are the same
  feature; Home/Work labels are not built.

## E. Errors and permissions 🟢 + 🔵 M0 + 🟠 M5

| Situation | Behaviour | Status |
|---|---|---|
| Location services off | Message + **Enable** shortcut | 🟢 |
| Location denied / denied forever | Message, + **Open Settings** when denied forever | 🟢 |
| No GPS fix for a route | "Get your location first to see a route to this place." | 🟢 |
| Weak GPS | Flag after 3 rejected fixes (shown in Diagnostics) | 🟢 |
| Camera permission denied | Plain message + **Try again** | 🟢 |
| No usable camera | Honest message; the rest of the app works | 🟢 |
| App backgrounded with camera open | Camera released and reopened | 🔵 |
| Heading / camera / ARCore unavailable during AR | "Continue with map navigation" sheet with the reason | 🟠 M5 |
| Short GPS gaps while walking | Step-based dead reckoning with growing uncertainty | 🟠 M4 |

## F. Branding and UI

- **Implemented 🟢:** app name *TN AR NAV*, title *TN AR Navigation*,
  tagline *AR Navigation for Tamil Nadu*, seed colour `#0B5FFF`, a
  navigation-arrow mark, Material 3 with light and dark themes following
  the system setting, central spacing/radius/typography tokens.
- **Design concept ⚪:** the premium dark direction, glass panels and the
  exact styling in these mockups. It is not in the Phase 2 roadmap; adopting
  it would be a separate, approved UI task.

## G. Reliability and testing 🔵 M0

- Routing injectable through `routingServiceProvider`; tests use a
  controllable `FakeRoutingService` instead of network timeouts.
- Every confirmed defect got a regression test written first and seen
  failing on the unfixed code.
- 261 tests, 75.1 % line coverage, Flutter pinned to 3.38.4 (`.fvmrc`).
- GitHub Actions CI: lockfile check, format, analyze, tests with coverage,
  debug and release APK builds — green on the latest commits.
- Device checklist ready in `docs/field-tests/M0_DEVICE_CHECKLIST.md`
  (not yet run).
