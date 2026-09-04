# prop_plant_01 — Import Notes (B05)

## File
- `prop_plant_01.glb` — binary glTF 2.0, +Y up
- Source: `prop_plant_01.blend` + `build_plant.py`

## Scale & Pivot
- **Unit:** 1 unit = **1 meter**
- **Authored extents:** **0.300 × 0.300 × 0.450 m**
- **Pivot / origin:** **BOTTOM-CENTER** footprint (floor / counter). Z=0 at pot base.
- Axis: glTF **+Y up**

## Materials
| Name | Role |
|------|------|
| Ceramic / Ceramic_Rim | Soft ceramic pot |
| Soil | Pot fill |
| Stem | Central stem |
| Leaf / Leaf_Dark | Stylized-real leaf mass |

## Mesh budget
- Verts: 288 · Tris: 528 · Soft bevel ~2.2 mm — **no cel/ink outlines**
- Budget ≤600 tris ✓
- Style: cozy stylized-real greenery (not cartoon)

## Godot tips
1. Place on floor corner, counter end, or shelf. Scale 1,1,1.

## Godot 4.5.2 import verification
- Project: `/workspace/card-shop-simulator/godot-import-test/`
- Result: **SUCCESS**. `.glb.import` + `.godot/imported/*.scn` generated.
- QA shots: `docs/art/qa-shots/LIGHT_DECOR_interact.png`, `LIGHT_DECOR_approach.png`
