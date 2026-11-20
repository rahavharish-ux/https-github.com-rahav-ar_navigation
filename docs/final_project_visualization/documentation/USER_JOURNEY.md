# User Journey

Image: `../diagrams/user_journey_flowchart.png`. The Mermaid version below
renders on GitHub. Solid arrows are transitions the app performs today;
dashed arrows are planned (Phase 2 roadmap).

```mermaid
flowchart LR
    A[Open app] --> B[Splash + onboarding]
    B --> C[Home dashboard]
    C --> D[Search destination]
    D --> E[Select destination]
    E --> F[Preview route]
    F --> G[Start navigation]
    G --> H{AR available?<br/>planned M5}
    H -. yes · planned M5 .-> I[Camera-based AR guidance<br/>planned M5]
    H -- "no (today: always)" --> J[2D map navigation]
    I -. Map ⇄ AR view .- J
    I -.-> K[Real-time guidance]
    J --> K
    K --> L[Route deviation detection]
    L --> M[Rerouting]
    M --> K
    K --> N[Destination reached]

    subgraph Alternatives
      P1[Camera permission denied] --> P2[Message + Try again] -.-> P3[Continue on 2D map · M5]
      Q1[Camera unavailable] --> Q2[Honest no-camera message] -.-> Q3[2D map fallback · M5]
      R1[Heading unavailable] --> R2[Detected · Diagnostics] -.-> R3[AR offers 2D map · M5]
      S1[User taps Map in AR · M5] -.-> S2[Same session on map · M5] -.-> S3[Return to AR · M5]
      T1[GPS off / denied / weak] --> T2[Enable / Open Settings prompt] --> T3[Route needs a GPS fix] -.-> T4[Short gaps bridged by dead reckoning · M4]
    end
```

## Walkthrough

1. **Open app → splash → onboarding** 🟢 — a 2 s splash, then three
   onboarding pages (currently shown on every launch).
2. **Home dashboard** 🟢 — map, live position, search card. Location
   permission is requested only when you tap locate.
3. **Search → select** 🟢🔵 — Google Places results with your distance;
   results are never stale (M0). Selecting needs a GPS fix to continue to a
   route.
4. **Preview route** 🟢 — driving route, time and distance; walking arrives
   with M3.
5. **Start navigation** 🟢 — a turn-by-turn session starts.
6. **AR or map?** 🟠 — after M5, the app checks ARCore support, camera and
   heading, and offers camera-based guidance. **Today the answer is always
   "map"**: AR navigation is not built.
7. **Real-time guidance** 🟢🔵 — each GPS fix updates the next instruction
   and remaining distance/time (corrected in M0).
8. **Deviation → rerouting** 🟢🔵 — over 40 m off the route, or a sustained
   wrong direction, triggers a new route from your current position. M0
   guarantees the reroute respects Stop, Pause and new sessions.
9. **Destination reached** 🟢 — within 25 m: "You've arrived".

## Alternative paths

| Path | Today | After Phase 2 |
|---|---|---|
| Camera permission denied | Plain message + Try again | Plus "Continue on 2D map" from AR (M5) |
| Camera unavailable | Honest message; app keeps working | AR session falls back to 2D automatically (M5) |
| Heading unavailable | Detected; shown in Diagnostics | AR offers 2D map with the reason (M5) |
| User switches to 2D map | Not applicable (no AR yet) | Map ⇄ AR buttons, same session (M5) |
| GPS unavailable / inaccurate | Enable / Open Settings prompts; weak-signal flag; routes need a fix | Short gaps bridged by step-based dead reckoning with growing uncertainty (M4) |
