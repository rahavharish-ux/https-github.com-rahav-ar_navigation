# Visual Design Explanation — Phase 2

## Direction

A premium, futuristic but practical navigation product: dark surfaces so
the camera view and map carry the colour, one electric-blue → cyan accent
for "intelligence and guidance", and glass panels that keep the outdoor
scene visible behind the UI. Deliberately different from the Phase 1
visualization (Material blue, flat cards) so Phase 2 reads as a new product.

## Tokens

| Token | Value | Use |
|---|---|---|
| Background | `#060A12` navy-black with navy/teal radial glows | Canvas, screen base |
| Surface | `rgba(14,20,34,.74)` + 18 px blur, 1 px white 8 % border | Glass panels over camera/map |
| Accent gradient | `#2F6BFF → #22D3EE` | AI orb, primary buttons, turn icons, chevrons |
| Cyan text | `#A8F0FB` / `#5EE6F5` | Chips, live status |
| Text | `#E8ECF5` primary, `#94A2BC` secondary | |
| Warning | `#F9A825` | Hazards, offline banner |
| Danger | `#E11D48` → `#FF8A8A` | SOS, end navigation |
| Brand | `#0B5FFF` logo tile (existing app brand) | Header mark |
| Type | Inter / Inter Display; FreeSans for Tamil | |
| Radius | 12–16 (controls), 20–24 (cards), 28–30 (sheets) | |

## Signature components

- **AI orb** — a glowing gradient sphere in the centre of the bottom
  navigation and in AR/assistant screens: one consistent way to ask the
  assistant from anywhere.
- **Ask bar** — gradient-outlined input with camera and mic buttons.
- **Ground chevrons + 3D turn arrow** — perspective-scaled, cyan→blue with a
  soft glow; the turn arrow has an extruded back face for depth.
- **Detection labels** — colour by kind: cyan objects, violet signs and
  buildings, amber landmarks, green walkable path.
- **Status chips** — "Geo-anchored · VPS localized", "Fused position · high
  confidence": short, qualitative, never a fabricated number.

## Outdoor practicality

- Large type for the next instruction (27–30 px distance, 14–16 px text).
- Strong contrast panels (dark glass, light text) readable over bright scenes.
- Few simultaneous overlays in AR: instruction, path, one landmark, one
  hazard, bottom controls.
- Hands-free voice controls with 52 px targets.

## Honesty layer (on every image)

Four tag colours — green existing, cyan M0, amber roadmap, violet
proposed — appear on the phone (small corner tags and a dashed banner) and
in the side panel. Footnotes state that camera and map imagery are
illustrations and that no accuracy or performance figures are claimed.

## How the images were made

No image-generation model was available, so every screen is a
high-fidelity HTML/CSS/SVG mockup rendered to PNG by Chromium (Playwright):
`source/kit2.py` (design system, building on the earlier visualization's
phone frame, icons, illustrative Mylapore map and street scene),
`screens2.py`, `screens2b.py`, `diagrams2.py`, `build.py`. Tamil strings
were test-rendered and avoid glyph combinations the available font
shapes incorrectly.
