# Phase 2 — Risk Register

Likelihood / impact: **L**ow · **M**edium · **H**igh.

## 1. Technical risks

| # | Risk | L | I | Mitigation | Early signal |
|---|---|---|---|---|---|
| T1 | ARCore Geospatial (VPS) coverage or accuracy is poor at target locations (depends on Street View imagery) | M | H | Check VPS availability per location at runtime; T2/T1 fallback tiers; measure availability early in M6 at real sites before building UX around it | `checkVpsAvailabilityAsync` results in field survey |
| T2 | Camera ownership conflict between ARCore and the `camera` plugin | H if ignored | H | Architecture rule: one owner; perception reads ARCore CPU images in AR mode | Black preview / camera-in-use errors |
| T3 | PDR drift makes fused position worse than GNSS | M | M | Feature flag; GNSS-only remains default until replayed traces prove improvement; time-limit PDR-only mode | M4 replay error tables |
| T4 | Magnetic disturbance near vehicles/structures corrupts heading | H | M | Rotation-vector + GNSS course + VIO yaw in EKF; heading uncertainty shown; never rely on compass alone in AR | Heading σ spikes in traces |
| T5 | On-device detector too slow or hot on mid-range phones | M | H | Rate governor, int8 models, GPU delegate, ROI cropping; publish per-device benchmarks; disable perception tier on thermal warning | M7 p95 latency, thermal status API |
| T6 | No usable on-device Tamil OCR quality | M | M | Benchmark two candidates on a real signboard set before integrating; optional server OCR path behind consent | M8 CER results |
| T7 | Tamil STT/TTS unavailable or poor on some devices | M | M | Detect installed voices/recognizers; fall back to English with a message; text input fallback for the agent | M2/M9 device checks |
| T8 | Flutter `AndroidView` (hybrid composition) performance with an AR GL surface | M | M | Prototype first in M5 spike; consider texture layer composition modes; keep Flutter overlays minimal on AR screen | Frame time on AR screen vs native-only |
| T9 | Unmaintained native renderer library | M | M | Evaluate maintenance at M5; isolate behind `ArRenderView` so it can be swapped for raw Filament | Release cadence, open issues |
| T10 | Platform-channel overhead from high-rate sensor/pose traffic | M | L | Batch samples; ~10 Hz pose to Dart; keep per-frame work native | Channel message rate in profiler |
| T11 | Flutter SDK drift (observed: 43 deprecations, lockfile rewrite on 3.50) | L (after M0) | L | **Mitigated in M0:** pinned to 3.38.4 (`.fvmrc`, CI); upgrade only as its own deliberate change | Analyzer output |
| T12 | Non-hermetic tests (observed: 2 failures from network timing) | L (after M0) | M | **Fixed in M0** with `routingServiceProvider` + `FakeRoutingService`. Some widget tests still set a global `HttpOverrides` defensively; they pass and their routing/search providers are overridden | CI flakiness |
| T13 | R8/release-only breakage when native ML/AR libs are added (Phase 1 history) | M | M | Release build in every milestone gate (now in CI); keep rules documented | Release build failure |
| T14 | Open-weight LLMs too weak in Tamil, or too large/slow on mid-range phones | H | M | Benchmark before integrating (M9); rule-based intent fallback for core commands; self-hosted option; hosted API only with approved cost | M9 eval scores |
| T15 | OpenRouteService free-tier quota or availability limits | M | M | `RoutingProvider` fallback; cache recent routes; Google Routes or self-hosted engine as alternatives | 429/5xx rates in M3 field tests |
| T16 | M0 not yet verified by an Android build (environment lacked the SDK) | M | M | CI builds debug + release APKs; M1 blocked until green | First CI run |

## 2. Safety risks

| # | Risk | Mitigation |
|---|---|---|
| S1 | User trusts a vision hazard alert (or its absence) near traffic | Alerts labelled advisory; never "safe to cross"; missing detections are not a safety guarantee; disclaimer in onboarding |
| S2 | AR content misaligned → user walks wrong way or into a road | Show "approximate" mode in T2; route chevrons only on walkable side per route geometry; 2D map always available |
| S3 | Attention: user stares at phone while walking | Voice-first guidance; AR session auto-dims/pauses when walking fast without looking (heuristic, to evaluate); remind users to stay aware |
| S4 | LLM gives incorrect directions | LLM never originates navigation instructions; only calls tools whose outputs are deterministic; confirms before starting navigation |

## 3. Privacy and security risks

| # | Risk | Mitigation |
|---|---|---|
| P1 | Camera images leave the device | Default on-device only; any cloud call (agent image, cloud OCR) is user-initiated with visible indicator; documented in privacy policy |
| P2 | Location traces uploaded | Observations opt-in, coarse metadata only; no raw traces uploaded; trace recording is a developer/diagnostics feature, local only |
| P3 | Secrets in APK | Any paid-service key server-side only; release APK inspected for keys at each gate that adds one |
| P6 | OpenRouteService key in `.env` is extractable and cannot be restricted to the app | Tight quotas and monitoring, or a proxy — decided at M3 start |
| P4 | Proxy abuse (cost) | Supabase JWT required; per-user rate limits; server-side model and budget config |
| P5 | Self-declared Android key headers (`X-Android-Package/Cert`) are spoofable | Accept for restricted Places key with quotas, or move Places calls behind the proxy before public launch (already flagged in Phase 1 docs) |

## 4. Legal / licensing risks

| # | Risk | Mitigation |
|---|---|---|
| X1 | Model weights under AGPL-3.0 (e.g. Ultralytics YOLO) or datasets restricted to non-commercial research (common for driving datasets); "open" LLM weights under custom, non-OSI terms | **Owner decision: permissive licences only, no AGPL without approval.** `LICENSES-models.md` registry checked at every model adoption; prefer own-collected data |
| X2 | OSRM public demo server used beyond its usage policy | Move driving routing to a proper provider before public release |
| X3 | OSM data attribution (ODbL) for self-hosted routing | Attribution in app's about/licenses screen |
| X4 | Google Maps Platform terms (display of Places data, caching limits) | Don't persist Places content beyond what the terms allow; observation layer stores app-generated data only |

## 5. Delivery risks

| # | Risk | Mitigation |
|---|---|---|
| D1 | No device or ground truth available to validate claims | Field-test protocol from M1; checkpoints surveyed once and reused; claims gated on measurements |
| D2 | Scope (8 research-heavy targets) exceeds capacity | Milestones are independently valuable; M0–M4 deliver a better pedestrian navigator even if AR/AI milestones slip |
| D3 | Android SDK unavailable in some build environments (observed here: `dl.google.com` blocked) | CI runner with Android SDK; document build prerequisites |
| D4 | Cost growth (Places, Geospatial, routing, LLM) | Owner rule: no new paid dependency without a presented cost. Per-milestone cost estimate; quotas and alerts on every key |

## 6. Claims policy

Until the corresponding milestone's device measurements exist, project docs
and UI must not claim: SLAM, GPS-denied navigation, 6DoF geo-anchored AR,
real-time landmark recognition, or detection accuracy figures. Allowed
wording before then: "GNSS + pedestrian dead reckoning (experimental)",
"AR guidance (approximate alignment)", "advisory obstacle detection
(experimental)".
