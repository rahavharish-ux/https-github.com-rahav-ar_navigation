# Feature Inventory and Implementation Status

_TN AR NAV ("TN AR Navigation — AR Navigation for Tamil Nadu") · inventory taken
from branch `claude/phase-2-technical-audit-2di7x1` at commit `ed23479`
(2026-11-20) by reading `lib/`, `android/`, `test/`, `PHASE2_*.md`,
`PROJECT_STATUS.md` and `KNOWN_LIMITATIONS.md`._

## Status legend (same as in every image)

| Tag | Meaning |
|---|---|
| 🟢 **Implemented · Phase 1** | In the code, covered by tests, verified on a device during Phase 1 |
| 🔵 **Implemented · Phase 2 M0** | Phase 2 reliability work: in the code, 261 tests pass, CI green (debug + release APK). Device checklist still pending |
| 🟠 **Phase 2 planned · Mx** | In the approved Phase 2 roadmap (`PHASE2_ROADMAP.md`), **not built**. Mx = milestone |
| ⚪ **Not built / future** | A placeholder in the app, or not on any roadmap |

**Phase 2 progress today:** only milestone **M0 (Stabilize the base)** is
implemented. M1–M11 are planned and not started; M1 is waiting for the
owner's approval.

## Inventory

| # | Feature | Status | Where in the code | Shown in |
|---|---|---|---|---|
| 1 | Splash + 3-page onboarding | 🟢 (onboarding shows on every launch) | `features/splash`, `features/onboarding` | Journey |
| 2 | Brand: name, tagline, seed colour #0B5FFF, navigation-arrow mark, Material 3 light/dark | 🟢 | `core/constants/app_strings.dart`, `core/theme/*` | All |
| 3 | Live GPS position with accuracy filter, smoothing, speed-adaptive sampling | 🟢 | `core/providers/location_provider.dart`, `core/utils/location_filter.dart`, `position_smoothing.dart`, `speed_bucket.dart` | 01 |
| 4 | Weak-GPS-signal flag | 🟢 (state only; visible in Diagnostics) | `location_provider.dart` | Journey |
| 5 | Google map, follow mode, re-center, locate me | 🟢 | `core/map/app_map_controller.dart`, `widgets/map/app_map_view.dart` | 01, 03, 05, 07 |
| 6 | Destination search (Google Places, Tamil Nadu bias, debounce) | 🟢 | `services/geocoding_service.dart`, `features/search` | 02 |
| 7 | Stale search results can't overwrite newer ones | 🔵 M0 | `features/search/providers/search_provider.dart` | 02 |
| 8 | Recent searches (session only) | 🟢 | `search_provider.dart` (`RecentSearchesNotifier`) | 02 |
| 9 | Route preview: polyline, distance, duration | 🟢 driving only | `services/routing_service.dart`, `features/route_preview` | 03 |
| 10 | Walking routes (OpenRouteService) | 🟠 M3 | — | 01, 03 |
| 11 | Cycling routes | ⚪ unsupported (honest message) | `route_provider.dart` | 01, 03 |
| 12 | Turn-by-turn 2D navigation, arrival | 🟢 | `features/navigation` | 05 |
| 13 | Correct remaining distance and ETA | 🔵 M0 | `navigation_provider.dart` | 05 |
| 14 | Off-route and wrong-direction detection, automatic rerouting | 🟢 | `navigation_provider.dart` | 07 |
| 15 | Reroute respects Stop / Pause / new session; no parallel reroutes; uses newest GPS fix | 🔵 M0 | `navigation_provider.dart` | 07 |
| 16 | Pause / resume / stop navigation | 🟢 + 🔵 M0 (resume uses latest position) | `navigation_provider.dart` | 05 |
| 17 | Compass heading | 🟢 Diagnostics only | `compass_provider.dart` | 04 (as input) |
| 18 | Accelerometer / gyroscope | 🟢 Diagnostics only | `motion_sensor_provider.dart` | — |
| 19 | GPS-vs-compass heading choice | 🟢 Diagnostics only | `core/utils/heading_fusion.dart` | — |
| 20 | Camera preview | 🟢 Diagnostics only | `features/ar_navigation/camera_preview_screen.dart` | 09 |
| 21 | Camera lifecycle: release on background, reopen on resume, no leak after Stop | 🔵 M0 | `camera_provider.dart`, `core/utils/camera_lifecycle.dart`, `widgets/common/camera_lifecycle_binding.dart` | 06, 09 |
| 22 | Camera permission denied / camera unavailable states | 🟢 | `camera_provider.dart` | 09 |
| 23 | OCR text recognition (Latin script, single photo, on-device) | 🟢 Diagnostics only | `services/vision_service.dart`, `features/vision` | 06 |
| 24 | Scene labelling (single photo, on-device) | 🟢 Diagnostics only | `vision_service.dart` | 06 |
| 25 | Capture interrupted by backgrounding handled | 🔵 M0 | `core/utils/camera_capture.dart` | 06 |
| 26 | ARCore availability check | 🟢 Diagnostics only | `services/ar_platform_service.dart`, `MainActivity.kt` | 09 |
| 27 | Live AR navigation (camera + approximate guidance arrow, Map fallback) | 🟠 M5 | — | 04 |
| 28 | Geo-anchored AR (ARCore Geospatial / VPS) | 🟠 M6 | — | 04 (named, not drawn) |
| 29 | Automatic fallback to 2D map when AR can't run | 🟠 M5 | — | 09, Journey |
| 30 | Sensor hub + GPS/IMU trace recording and replay | 🟠 M1 | — | Architecture |
| 31 | Fused localization (GNSS + step-based dead reckoning, route progress) | 🟠 M4 | — | Journey |
| 32 | Live object detection + hazard advisories (LiteRT, Apache-2.0 model) | 🟠 M7 | — | 06 |
| 33 | Tamil + English sign reading, landmark recognition, walkable-surface segmentation | 🟠 M8 | — | 06 |
| 34 | Voice guidance (TTS), Tamil/English UI | 🟠 M2 | — | (not drawn) |
| 35 | Voice assistant (provider-independent, open model first) | 🟠 M9 | — | (not drawn) |
| 36 | Geospatial environmental mapping (observation store, PostGIS) | 🟠 M10 | — | Architecture |
| 37 | Email sign-in / sign-up (Supabase Auth) | 🟢 | `services/auth_service.dart`, `features/auth` | 08 |
| 38 | Saved places (Supabase, Row Level Security) | 🟢 | `services/saved_places_service.dart`, `features/saved_places`, `supabase/schema.sql` | 08 |
| 39 | Home / Work / Recent quick actions | ⚪ placeholder ("coming soon") | `features/home/widgets/quick_action_row.dart` | 01 |
| 40 | Nearby-places browsing | ⚪ not built, not planned | — | 02 (noted) |
| 41 | Clock-time arrival ("Arrive 10:31") | ⚪ not built (duration only) | — | 03 (noted) |
| 42 | Alternative routes / "Fastest" label | ⚪ design concept only | — | 03 |
| 43 | Cloud vision | ⚪ not planned (owner decision: on-device first) | — | 06 |
| 44 | Developer diagnostics screen | 🟢 | `features/diagnostics` | 01 (icon) |
| 45 | Injectable routing, regression tests, SDK pin, GitHub Actions CI | 🔵 M0 | `routing_service_provider.dart`, `test/`, `.fvmrc`, `.github/workflows/ci.yml` | Architecture |
| 46 | Dark "premium" visual direction used in these mockups | ⚪ design concept, not on the roadmap | — | All |

## Mapping of the requested screen elements

| Requested element | What the visualization shows |
|---|---|
| Voice navigation entry (Home) | **Omitted** — no voice support exists; M2 (guidance) and M9 (assistant) are planned |
| Recent destinations (Home) | Shown in Search (screen 02) where they really live; the Home "Recent" shortcut is a placeholder |
| Nearby places (Search) | **Not shown** as a feature; results show your distance to each place instead |
| Walking/driving modes | Driving real; Walking tagged M3; Cycling greyed out |
| Estimated arrival time | Shown as remaining **duration** (what the app computes), not a clock time |
| Live AR navigation | Entire screen tagged **Phase 2 concept · M5 — not implemented**; arrow drawn as an approximate, screen-space overlay; no world-anchored path, SLAM or 6DoF tracking depicted |
| Current heading (AR) | Compass heading exists today in Diagnostics only |
| OCR / image labelling | Shown exactly as implemented (single photo, Latin OCR, Diagnostics); live detection, Tamil OCR and landmarks shown separately as M7/M8 concepts |
| Heading unavailable / continue on 2D map | Detection exists (Diagnostics); the fallback sheet is tagged M5 |

## Verification snapshot (M0)

| Check | Result |
|---|---|
| `flutter analyze` (Flutter 3.38.4) | No issues found |
| `flutter test` | 261 passed, 0 failed (local ×3, CI) |
| Line coverage | 75.1 % (1554 / 2070) |
| CI run #1 on `b6e0d7f` / run #2 on `ed23479` | ✅ green, including `app-debug.apk` and `app-release.apk` |
| Device checklist (`docs/field-tests/M0_DEVICE_CHECKLIST.md`) | ⏳ not run yet |
