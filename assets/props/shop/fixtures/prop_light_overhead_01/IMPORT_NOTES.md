# prop_light_overhead_01 — Import Notes (A11 lighting-amp)

## Pass
- **lighting-amp** — warmer practical ~3600K LED, richer emission so the shop reads alive (not blown-out white). Geometry / extents / pivot unchanged from prior ship.

## File
- `prop_light_overhead_01.glb` — binary glTF 2.0, +Y up
- Source: `prop_light_overhead_01.blend` + `build_light_overhead.py`

## Scale & Pivot
- **Unit:** 1 unit = **1 meter**
- **Authored extents:** **0.900 × 0.128 × 0.095 m** (L×W×H) — locked
- **Pivot / origin:** **MOUNT POINT — top center**. Fixture hangs below; place node at ceiling attachment.

## Emission (lighting-amp)
| Field | Value |
|-------|-------|
| Kelvin feel | **~3600K** practical warm |
| Emission RGB | **(1.0, 0.82, 0.62)** |
| Diffuser base | **(1.0, 0.84, 0.66)** |
| Emission strength | **9.0** (KHR_materials_emissive_strength) |
| Companion Omni (Godot) | Match RGB; energy ~1.6–1.8 (was ~1.35) for alive fill without white blow-out |

## Materials
| Name | Role | Notes |
|------|------|-------|
| Housing | Soft gunmetal body | Metallic ~0.80 |
| EndCap | End caps | Soft metal |
| LED_Diffuser | Warm emissive panel | Amped warm practical — Principled only, no cel/ink |

## Mesh budget
- Soft bevel ~2 mm — no cel/ink outlines
- Stylized-real Principled only; do not rescale heroes or change footprints

## Extra overhead instance (Eng note — optional this beat)
`shop_floor` / P0b currently instances **4×** `prop_light_overhead_01`:

| Node | Position (shell space, m) |
|------|---------------------------|
| Light1 | (2.8, 2.78, -2.2) |
| Light2 | (4.6, 2.78, -3.6) |
| Light3 | (6.4, 2.78, -2.2) |
| Light4 | (4.6, 2.78, -5.4) |

Optional **5th** additive instance for even aisle wrap (do **not** move the existing 4; do **not** rescale heroes):

- **Light5** at **(2.8, 2.78, -5.4)** — covers binder-rack / back-left aisle opposite Light4
- Pair OmniLight3D: `Color(1.0, 0.83, 0.66)` (~3600K), energy **~1.6**, range **7.0**, attenuation ~1.2
- Mesh extents/pivot unchanged this lighting-amp pass

## Wood albedo (notes only — do not mass-reexport heroes)
Under the richer 3600K key, oak reads a hair cool/flat. **Do not rebuild A03/A04/A09/etc this beat.** Suggested Godot material override / next authoring pass:

| Current oak (heroes) | Slightly richer (copy/notes) |
|----------------------|------------------------------|
| ~(0.46–0.48, 0.29–0.31, 0.16–0.17) | **(0.52, 0.34, 0.17)** — same value band, a bit more chroma/warmth |

See also `docs/art/props/WOOD_ALBEDO_RICHER_NOTES.md`.

## Godot 4.5.2 import verification
- Project: `/workspace/card-shop-simulator/godot-import-test/`
- Result: **SUCCESS**
- QA shot: `LIGHTING_amp_interact.png`
