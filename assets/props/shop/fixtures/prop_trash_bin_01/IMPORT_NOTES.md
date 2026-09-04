# prop_trash_bin_01 — Import Notes (B08)

## File
- `prop_trash_bin_01.glb` — binary glTF 2.0, +Y up
- Source: `prop_trash_bin_01.blend` + `build_trash_bin.py`

## Scale & Pivot
- **Unit:** 1 unit = **1 meter**
- **Authored extents:** **0.300 × 0.300 × 0.500 m**
- **Pivot / origin:** **BOTTOM-CENTER** footprint (floor). Z=0 on floor.
- Axis: glTF **+Y up**

## Materials
| Name | Role |
|------|------|
| Plastic_Dark | Soft dark plastic body |
| Metal_Rim | Soft gunmetal rim / lid / push panel |
| Liner | Inner lip |
| Metal_Foot | Base foot ring |

## Mesh budget
- Verts: 216 · Tris: 396 · Soft bevel ~2.5 mm — **no cel/ink outlines**
- Budget ≤400 tris ✓

## Godot tips
1. Place near counter side / door / backstock. Scale 1,1,1.

## Godot 4.5.2 import verification
- Project: `/workspace/card-shop-simulator/godot-import-test/`
- Result: **SUCCESS**. `.glb.import` + `.godot/imported/*.scn` generated.
- QA shots: `docs/art/qa-shots/LIGHT_DECOR_interact.png`, `LIGHT_DECOR_approach.png`
