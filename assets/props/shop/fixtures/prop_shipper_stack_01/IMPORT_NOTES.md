# prop_shipper_stack_01 — Import Notes (B04)

## File
- `prop_shipper_stack_01.glb` — binary glTF 2.0, +Y up
- Source: `prop_shipper_stack_01.blend` + `build_shipper_stack.py`

## Scale & Pivot
- **Unit:** 1 unit = **1 meter**
- **Authored extents:** **0.500 × 0.400 × 0.550 m** (3-box stack overall)
- **Pivot / origin:** **BOTTOM-CENTER** footprint (floor). Z=0 on floor.
- Axis: glTF **+Y up**

## Materials
| Name | Role |
|------|------|
| Cardboard_Kraft | Bottom shipper body |
| Cardboard_Light | Mid box |
| Cardboard_Dark | Top box |
| Tape | Kraft packing tape |
| Shipping_Label | Matte label patches |

## Mesh budget
- Verts: 240 · Tris: 440 · Soft bevel ~2.5 mm — **no cel/ink outlines**
- Budget ≤800 tris ✓

## Godot tips
1. Place against wall / near backstock as overflow décor. Scale 1,1,1.
2. Single combined mesh (not separate boxes).

## Godot 4.5.2 import verification
- Project: `/workspace/card-shop-simulator/godot-import-test/`
- Result: **SUCCESS**. `.glb.import` + `.godot/imported/*.scn` generated.
- QA shots: `docs/art/qa-shots/LIGHT_DECOR_interact.png`, `LIGHT_DECOR_approach.png`
