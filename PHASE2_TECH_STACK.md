# Phase 2 — Technology Stack

Every addition below states **why** it is needed and **what was rejected**.
Nothing is added to `pubspec.yaml` or Gradle until its milestone starts, and
each candidate is re-checked for maintenance status, license, and
compatibility with the pinned Flutter SDK at that time (as Phase 1 did).
Version numbers are intentionally omitted; they are fixed when adopted.

## 1. Kept from Phase 1

Flutter/Dart · Riverpod 3 · geolocator · latlong2 · http · camera ·
sensors_plus · flutter_compass (until replaced) · google_maps_flutter ·
flutter_dotenv · ML Kit text recognition + image labeling · supabase_flutter ·
ARCore SDK (native). No Phase 1 dependency is removed.

## 2. Proposed additions

| Area | Choice | Milestone | Why | Alternatives considered |
|---|---|---|---|---|
| Toolchain pin | **Done (M0):** `.fvmrc` = Flutter 3.38.4, CI pinned to the same | M0 | Audit observed analyzer/lockfile drift between 3.38 and 3.50 | Upgrading now (owner chose to stay on 3.38.4) |
| CI | **Done (M0):** GitHub Actions — format, analyze, test + coverage, debug + release APK | M0 | Repo is on GitHub; no CI before M0 | — |
| Sensors | Native Kotlin `SensorManager` via `EventChannel` (no package) | M1 | Needs rotation vector, step detector and `event.timestamp`; `sensors_plus` doesn't expose all of these | Extending sensors_plus (fork maintenance) |
| i18n | `flutter_localizations` (SDK) + `intl` | M2 | Official Flutter path; Tamil (`ta`) locale | Hand-rolled maps |
| TTS | `flutter_tts` | M2 | Wraps Android TextToSpeech; ta-IN/en-IN voices depend on installed engine | Cloud TTS (network, cost) |
| Keep screen on | `wakelock_plus` | M2 | Navigation screen must not sleep | Native flag via channel |
| Foreground location | geolocator's Android foreground-notification config (verify) or a small native foreground service | M2/M4 | Tracking with screen off | `flutter_background_service` (heavier) |
| Foot routing (first) | **OpenRouteService `foot-walking`** (owner decision) behind `RoutingProvider` | M3 | Real pedestrian graph; free tier with key (verify quotas) | OSRM demo (no foot profile); Google Routes `WALK` (kept as a later provider) |
| Foot routing (long term) | Self-hosted **Valhalla** (MIT) or **GraphHopper** (Apache-2.0) on OSM southern-India extract | M3+ | Custom pedestrian costing (crossings, footpaths, hazard layer), no per-request cost, offline-capable server | Self-hosted OSRM foot profile (less flexible costing) |
| Fusion math | Pure Dart (+ `vector_math`, already transitive via Flutter) | M4 | Small 5-state EKF; avoids dependencies | `ml_linalg` etc. — unnecessary |
| AR runtime | ARCore (existing) incl. **Geospatial API** | M5/M6 | Google's VIO + VPS; already a dependency | Building VIO/SLAM in-house (research-grade, not justified) |
| AR rendering | Native Kotlin renderer inside `AndroidView`: **SceneView for Android** (ARCore + Filament) — verify maintenance at M5; fallback: raw ARCore + Filament | M5 | Flutter AR plugins were found unmaintained in Phase 1; native keeps rendering on the GL thread | `ar_flutter_plugin` & forks (stale, Dart 3 incompatible per Phase 1 research) |
| Inference runtime | **LiteRT** (TensorFlow Lite successor) Android library + GPU delegate, called from Kotlin | M7 | Frames stay native; GPU delegate; mature tooling for quantization | `tflite_flutter` in Dart (frames must cross channel); ONNX Runtime Mobile (viable alternative); MediaPipe Tasks (good for stock models, less flexible for custom) |
| Detector model | Apache-2.0 COCO detector (EfficientDet-Lite / SSD-MobileNet family) first; fine-tune later | M7 | Licence-clean (owner decision: permissive only) covering person/car/bus/truck/bicycle/motorcycle/traffic light | Ultralytics YOLO — **rejected** (AGPL-3.0) unless explicitly approved |
| Tamil OCR | Benchmark: PaddleOCR-family Tamil recognizer (Apache-2.0) converted to LiteRT vs Tesseract `tam` (Apache-2.0) — both on-device | M8 | ML Kit on-device OCR has no Tamil script | Google Cloud Vision OCR — not planned (owner decision: on-device first; cloud optional later) |
| Segmentation | DeepLabV3-MobileNet-class LiteRT model; check training-data license | M8 | Sidewalk/road/crosswalk at low rate | Heavier transformers (too slow) |
| Landmarks | Places API Nearby Search (existing billing) + pose-based ranking + on-device OCR confirmation | M8 | Uses data the app already pays for; no image leaves the device | Cloud Vision Landmark Detection — not planned |
| STT | `speech_to_text` (Android `SpeechRecognizer`, ta-IN/en-IN; no fee) | M9 | No extra model; on-device availability varies by device | whisper.cpp (MIT; offline candidate, Tamil quality and size to be benchmarked) |
| LLM | **Provider-independent `LlmProvider` interface; first implementation an open-weight model** (on-device via LiteRT/llama.cpp, or self-hosted), chosen by an M9 benchmark; plus a rule-based intent fallback | M9 | Owner decision: free/open-source first, no paid dependency without presented cost; works offline | Hosted APIs (e.g. Claude API with tool use) — possible later as one `LlmProvider`, via proxy, only after cost approval |
| Proxy runtime | Supabase Edge Functions (TypeScript) — only if a hosted LLM or a key-protecting routing proxy is approved | M3/M9 | Backend already Supabase; auth JWT available | Separate server |
| Local DB | `drift` (SQLite) | M10 | Typed queries, migrations, testable | `sqflite` (lower level), Isar/Hive (less suitable for spatial queries) |
| Spatial DB | PostGIS on Supabase | M10 | Spatial index, bbox queries | Plain lat/lng columns |

## 3. Explicitly not adopted

- **Custom SLAM/VIO implementation** — ARCore already provides production VIO; building one is a research project with no device-validation capacity.
- **Flutter AR plugins** (`ar_flutter_plugin`, `arcore_flutter_plugin`, forks) — rejected in Phase 1 for maintenance/compatibility reasons; nothing has been verified to change that.
- **NNAPI delegate** — deprecated on recent Android versions.
- **Client-side keys for any paid AI service** — never shipped in `.env` (bundled assets are extractable).
- **AGPL-licensed models or code** (e.g. Ultralytics YOLO) — unless explicitly approved.
- **Cloud vision** — not planned; may be reconsidered later as an optional feature.

## 4. Keys and configuration

| Secret / config | Where it lives |
|---|---|
| Google Maps/Places key (existing) | `android/local.properties` + `.env`, restricted to package + certs |
| ARCore API key (Geospatial) | `android/local.properties` → manifest placeholder; restricted |
| Foot-routing key (if hosted) | `.env` if the provider supports app restriction; otherwise proxy |
| Any hosted LLM key (only if approved) | Supabase Edge Function secret only |
| OpenRouteService key | Decide at M3: `.env` with tight quotas, or Edge Function secret behind a proxy |
| Supabase URL / publishable key (existing) | `.env` |

## 5. Owner decisions (recorded 2026-11-18)

1. Flutter: **stay on 3.38.4**; no SDK upgrade during M0. ✅ applied (`.fvmrc`, CI).
2. Walking routes: **OpenRouteService first**, routing provider kept replaceable (Google Routes or others later).
3. Detection models: **Apache-2.0 or other commercially permissive licences**; no AGPL unless explicitly approved.
4. Vision: **on-device first** for privacy, cost and offline use; cloud vision optional, for future consideration only.
5. AI budget: **free and open-source first**, provider-independent architecture; **no paid API dependency without presenting its cost first**.

Still open, to decide at the milestone that needs it:
- M3: whether the OpenRouteService key ships in `.env` (with quotas) or behind a proxy.
- M6: ARCore Geospatial API cost/quotas (present before starting).
- M9: which open-weight model (after the benchmark), and whether a hosted LLM is ever worth its cost.
