# prop_sealed_wall_01 — Import Notes (A05)

## File
- `prop_sealed_wall_01.glb` — binary glTF 2.0, +Y up
- Source: `prop_sealed_wall_01.blend` + `build_sealed_wall.py`

## Scale & Pivot
- **Unit:** 1 unit = **1 meter**
- **Footprint (preferred lock):** **1.8 m W × 0.5 m D** ≈ **2 tiles × ~0.55 tile** (1 tile = 0.9 m). Documented as `2×0.55` in `_build_stats.txt`.
- **Authored extents:** **1.800 × 0.500 × 2.200 m** (locked)
- **Pivot / origin:** **BOTTOM CENTER** (floor contact). No Z offset.
- **Facing:** Customer face **−Y**; pegboard back **+Y** against shop wall; X runs along wall.

## Materials
| Name | Role |
|------|------|
| Wood | Warm oak uprights / shelves / crown |
| Wood_Recess | Peg-hole recesses (value contrast, not ink) |
| Metal | Soft gunmetal plinth, lips, slot rails, front rails |
| Pegboard | Soft gunmetal perforated back panel |
| Accent | Muted-teal mid-row lip strip (subtle emission) |
| Cardboard / PackFace / ExplorerBoxFace | Built-in stock proxies (boosters + **Explorer Box** placeholders) |

## Mesh budget
- Soft bevel ~2.5 mm — **no cel/ink outlines**
- 5 horizontal slot shelves; pegboard hole grid; stock proxies for silhouette density
- Can swap baked proxies for A06 `prop_proxy_booster_01` / `prop_proxy_etb_01` (**Explorer Box**) at runtime

## Godot tips
1. Occupies **2 × ~0.55** tile cells along a wall. Scale 1,1,1.
2. Place with back (+Y Blender / corresponding Godot axis after +Y-up) flush to wall.
3. Slot rails accept hanging pack proxies; lower two shelves sized for Explorer Box footprints.
