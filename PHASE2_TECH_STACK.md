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
| Toolchain pin | `.fvmrc` (FVM) or SDK version in `SETUP.md` + CI | M0 | Audit observed analyzer/lockfile drift between 3.38 and 3.50 | — |
| CI | GitHub Actions | M0 | Repo is on GitHub; no CI today | — |
| Sensors | Native Kotlin `SensorManager` via `EventChannel` (no package) | M1 | Needs rotation vector, step detector and `event.timestamp`; `sensors_plus` doesn't expose all of these | Extending sensors_plus (fork maintenance) |
| i18n | `flutter_localizations` (SDK) + `intl` | M2 | Official Flutter path; Tamil (`ta`) locale | Hand-rolled maps |
| TTS | `flutter_tts` | M2 | Wraps Android TextToSpeech; ta-IN/en-IN voices depend on installed engine | Cloud TTS (network, cost) |
| Keep screen on | `wakelock_plus` | M2 | Navigation screen must not sleep | Native flag via channel |
| Foreground location | geolocator's Android foreground-notification config (verify) or a small native foreground service | M2/M4 | Tracking with screen off | `flutter_background_service` (heavier) |
| Foot routing (short term) | OpenRouteService `foot-walking` **or** Google Routes API `WALK` | M3 | Fast to integrate; real pedestrian graph | OSRM demo (no foot profile) |
| Foot routing (long term) | Self-hosted **Valhalla** (MIT) or **GraphHopper** (Apache-2.0) on OSM southern-India extract | M3+ | Custom pedestrian costing (crossings, footpaths, hazard layer), no per-request cost, offline-capable server | Self-hosted OSRM foot profile (less flexible costing) |
| Fusion math | Pure Dart (+ `vector_math`, already transitive via Flutter) | M4 | Small 5-state EKF; avoids dependencies | `ml_linalg` etc. — unnecessary |
| AR runtime | ARCore (existing) incl. **Geospatial API** | M5/M6 | Google's VIO + VPS; already a dependency | Building VIO/SLAM in-house (research-grade, not justified) |
| AR rendering | Native Kotlin renderer inside `AndroidView`: **SceneView for Android** (ARCore + Filament) — verify maintenance at M5; fallback: raw ARCore + Filament | M5 | Flutter AR plugins were found unmaintained in Phase 1; native keeps rendering on the GL thread | `ar_flutter_plugin` & forks (stale, Dart 3 incompatible per Phase 1 research) |
| Inference runtime | **LiteRT** (TensorFlow Lite successor) Android library + GPU delegate, called from Kotlin | M7 | Frames stay native; GPU delegate; mature tooling for quantization | `tflite_flutter` in Dart (frames must cross channel); ONNX Runtime Mobile (viable alternative); MediaPipe Tasks (good for stock models, less flexible for custom) |
| Detector model | Apache-2.0 COCO detector (EfficientDet-Lite / SSD-MobileNet family) first; fine-tune later | M7 | License-clean starting point covering person/car/bus/truck/bicycle/motorcycle/traffic light | Ultralytics YOLO (strong, but **AGPL-3.0** — requires license decision) |
| Tamil OCR | Benchmark: PaddleOCR-family Tamil recognizer (Apache-2.0) converted to LiteRT vs Tesseract `tam` | M8 | ML Kit on-device OCR has no Tamil script | Google Cloud Vision OCR (supports Tamil, but cloud/cost — optional server path) |
| Segmentation | DeepLabV3-MobileNet-class LiteRT model; check training-data license | M8 | Sidewalk/road/crosswalk at low rate | Heavier transformers (too slow) |
| Landmarks | Places API Nearby Search (existing billing) + pose-based ranking | M8 | Uses data the app already pays for | Cloud Vision Landmark Detection (optional, via proxy) |
| STT | `speech_to_text` (Android `SpeechRecognizer`, ta-IN/en-IN) | M9 | No extra model; on-device availability varies by device | whisper.cpp (offline, heavy, quality for Tamil to be benchmarked) |
| LLM | **Claude Messages API with tool use**, via Supabase Edge Function proxy; model configured server-side (default `claude-opus-5-5`) | M9 | Strong tool use + image input; key stays server-side | On-device small LLM (latency/quality for Tamil unproven; revisit in M11) |
| Proxy runtime | Supabase Edge Functions (TypeScript, official Anthropic TS SDK) | M9 | Backend already Supabase; auth JWT available | Separate server |
| Local DB | `drift` (SQLite) | M10 | Typed queries, migrations, testable | `sqflite` (lower level), Isar/Hive (less suitable for spatial queries) |
| Spatial DB | PostGIS on Supabase | M10 | Spatial index, bbox queries | Plain lat/lng columns |

## 3. Explicitly not adopted

- **Custom SLAM/VIO implementation** — ARCore already provides production VIO; building one is a research project with no device-validation capacity.
- **Flutter AR plugins** (`ar_flutter_plugin`, `arcore_flutter_plugin`, forks) — rejected in Phase 1 for maintenance/compatibility reasons; nothing has been verified to change that.
- **NNAPI delegate** — deprecated on recent Android versions.
- **Client-side LLM or Cloud Vision keys** — never shipped in `.env` (bundled assets are extractable).

## 4. Keys and configuration

| Secret / config | Where it lives |
|---|---|
| Google Maps/Places key (existing) | `android/local.properties` + `.env`, restricted to package + certs |
| ARCore API key (Geospatial) | `android/local.properties` → manifest placeholder; restricted |
| Foot-routing key (if hosted) | `.env` if the provider supports app restriction; otherwise proxy |
| Anthropic API key | Supabase Edge Function secret only |
| Cloud Vision key (optional) | Edge Function secret only |
| Supabase URL / publishable key (existing) | `.env` |

## 5. Owner decisions needed

1. Flutter SDK: stay on 3.38.4 or move to current stable (M0).
2. Short-term foot routing provider: OpenRouteService vs Google Routes API (cost vs data quality; both need a key) (M3).
3. Detector licensing: Apache-2.0 models only, or accept AGPL-3.0 YOLO weights (affects distribution) (M7).
4. Whether any cloud vision use is acceptable (privacy/cost) (M8).
5. LLM budget and data-handling policy for the agent proxy (M9).
