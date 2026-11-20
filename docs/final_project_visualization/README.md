# TN AR NAV — Final Project Visualization (after Phase 2)

Concept visuals and documentation showing how **TN AR Navigation** ("AR
Navigation for Tamil Nadu") is intended to look and work once Phase 2 is
complete — and, on every image, exactly which parts exist today.

> **Read this first.** Phase 2 is at milestone **M0** (reliability) only.
> Live AR navigation, live object detection, Tamil OCR, landmark
> recognition, walking routes, voice and the AI assistant are **planned,
> not built**, and are marked as concepts wherever they appear. Maps and
> camera views are drawn illustrations; places, distances and times are
> sample values.

## Status legend (used in every image and document)

| Tag | Meaning |
|---|---|
| 🟢 Implemented · Phase 1 | In the code and tested |
| 🔵 Implemented · Phase 2 M0 | Reliability work: in code, 261 tests, CI green; device checks pending |
| 🟠 Phase 2 planned · concept | Approved roadmap item, not built (dashed amber outline in images) |
| ⚪ Not built / future | Placeholder in the app, or not on the roadmap |

## Contents

### `screens/` — individual screen concepts (3200–3920 px wide)
| File | Screen | Mostly |
|---|---|---|
| `01_home_dashboard.png` | Home dashboard | 🟢 (Walking M3, AR button M5, shortcuts not built) |
| `02_destination_search.png` | Destination search | 🟢 + 🔵 |
| `03_route_preview.png` | Route preview | 🟢 (driving); Walking M3 |
| `04_live_ar_navigation_concept.png` | Live AR navigation | 🟠 M5 concept — not implemented |
| `05_2d_map_navigation.png` | 2D map navigation | 🟢 + 🔵 |
| `06_scene_understanding.png` | Scene understanding — today vs concept | 🟢 (single photo) / 🟠 M7–M8 |
| `07_guidance_and_rerouting.png` | Guidance and rerouting | 🟢 + 🔵 |
| `08_saved_places.png` | Saved places and account | 🟢 |
| `09_permissions_and_fallback.png` | Permissions and fallback | 🟢 + 🔵; AR fallback 🟠 M5 |

### `showcase/`
- `10_final_app_showcase.png` — six-phone product presentation with status under each screen.

### `diagrams/`
- `user_journey_flowchart.png` — main journey plus five alternative paths; solid = implemented, dashed = planned.
- `system_architecture.png` — layers as built in `lib/` and `android/`, with planned Phase 2 modules dashed.

### `documentation/`
- `IMPLEMENTATION_STATUS.md` — feature inventory (46 items), status table, how each requested element was treated.
- `FEATURE_EXPLANATIONS.md` — for every feature: what it does, how to use it, how it works, technology, phase, benefit.
- `PHASE1_VS_PHASE2.md` — side-by-side comparison and the owner's Phase 2 decisions.
- `USER_JOURNEY.md` — journey walkthrough and a Mermaid flowchart that renders on GitHub.

### `source/` — how the images are made
HTML/CSS/SVG generators (`kit.py`, `screens.py`, `diagrams.py`) rendered by
the pre-installed Chromium through Playwright (`render.js`), then losslessly
optimised with Pillow. Regenerate with:

```bash
cd docs/final_project_visualization/source
python3 build.py            # all images
python3 build.py 04_live    # only matching images
```

No application source, assets or dependencies were changed to make these.
