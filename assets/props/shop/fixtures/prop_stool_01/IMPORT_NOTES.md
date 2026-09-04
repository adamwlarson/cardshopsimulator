# prop_stool_01 — Import Notes (A10)

## File
- `prop_stool_01.glb` — binary glTF 2.0, +Y up
- Source: `prop_stool_01.blend` + `build_stool.py`

## Scale & Pivot
- **Unit:** 1 unit = **1 meter**
- **Authored extents:** **0.400 × 0.400 × 0.450 m**
- **Pivot / origin:** **BOTTOM-CENTER** footprint (floor). Z=0 on floor.
- Axis: glTF **+Y up**

## Materials
| Name | Role |
|------|------|
| Wood_Seat | Warm wood seat top |
| Metal | Soft gunmetal legs + braces |

## Mesh budget
- Verts: 168 · Tris: 308 · Soft bevel ~2.5 mm — **no cel/ink outlines**
- Budget ≤500 tris ✓

## Godot tips
1. Place on sales-floor / behind counter. Scale 1,1,1.
2. Light décor stool — not a seating interaction target for MVP.

## Godot 4.5.2 import verification
- Project: `/workspace/card-shop-simulator/godot-import-test/`
- Result: **SUCCESS**. `.glb.import` + `.godot/imported/*.scn` generated.
- QA shots: `docs/art/qa-shots/LIGHT_DECOR_interact.png`, `LIGHT_DECOR_approach.png`
