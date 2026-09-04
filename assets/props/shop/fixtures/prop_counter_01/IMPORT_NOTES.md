# prop_counter_01 — Import Notes

## File
- `prop_counter_01.glb` — binary glTF 2.0, +Y up
- Source: `prop_counter_01.blend` + `build_counter.py` (Blender 4.3 procedural blockout)

## Scale & Pivot
- **Unit:** 1 Blender/glTF unit = **1 meter**
- **§7.1 footprint:** Counter = **2×1 tiles**. Art/Eng assumption: **1 tile = 0.9 m** → footprint **1.8 m × 0.9 m**
- **Authored extents:** **1.800 m W × 0.900 m D × 1.000 m H** (locked; de-toon pass did **not** rescale)
- **Pivot / origin:** **BOTTOM CENTER** (floor contact). Place the node at the floor point; no Z offset needed.
- Axis: glTF **+Y up** (Blender Z-up converted on export)
- Grid lock: tile_size_m=0.9 ratified by Eng; no further hero rescale unless BalanceConfig changes.

## Materials (PBR metallic-roughness)
| Name        | Role                              | Metallic | Roughness | Notes                                      |
|-------------|-----------------------------------|----------|-----------|--------------------------------------------|
| Wood        | Warm oak body / apron / shelf     | 0        | ~0.62     | Front/sides/back, apron, staff ledge       |
| Wood_Recess | Darker oak door/panel groove      | 0        | ~0.70     | Value-contrast seam (replaces ink line)    |
| Metal       | Soft brushed gunmetal kick/trim   | ~0.85    | ~0.42     | Softened from near-black (de-toon)         |
| CounterTop  | Dark matte laminate work surface  | 0        | ~0.58     | Softened value vs ink slab                 |
| Accent      | Muted-teal under-lip strip        | 0        | ~0.45     | Subtle emission (~0.35) for affordance     |

Godot 4: imported materials map to StandardMaterial3D / ORM. Accent emission may need a small Emission energy tweak after import.

## Mesh budget
- **Verts:** 480
- **Tris:** 880 (LOD0 blockout + ~3 mm soft bevel — well under 5k)
- Single mesh object `prop_counter_01` with 5 material slots

## Style / de-toon (2026-09-04)
- Soft bevels (~3 mm) for PBR edge response — **no** heavy black cel/toon outlines
- Near-black metal kick/seam replaced with soft gunmetal + wood recess value contrast
- Footprint unchanged at **1.8×0.9 m**

## Godot usage tips
1. Drop GLB into `res://`; let Godot generate `.import`.
2. Instance as-is; root at floor. Scale should be 1,1,1.
3. Occupies **2×1** tile cells on the shop grid.
4. Customer face is **−Z in Godot** after +Y-up glTF import (Blender −Y → glTF −Z typically); verify facing in scene.

## Godot 4.5.2 import verification
- Project: `/workspace/card-shop-simulator/godot-import-test/`
- Binary: `/workspace/godot452`
