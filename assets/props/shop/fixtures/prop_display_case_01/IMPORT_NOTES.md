# prop_display_case_01 — Import Notes

## File
- `prop_display_case_01.glb` — binary glTF 2.0, +Y up
- Source: `prop_display_case_01.blend` + `build_display_case.py` (Blender 4.3 procedural blockout)

## Scale & Pivot
- **Unit:** 1 Blender/glTF unit = **1 meter**
- **§7.1 footprint:** Showcase case = **2×1 tiles**. Art/Eng assumption: **1 tile = 0.9 m** → footprint **1.8 m × 0.9 m**
- **Authored extents:** **1.800 m W × 0.900 m D × 1.050 m H** (locked; de-toon pass did **not** rescale)
- **Pivot / origin:** **BOTTOM CENTER** (floor contact). Place the node at the floor point; no Z offset needed.
- Axis: glTF **+Y up** (Blender Z-up converted on export)
- Grid lock: tile_size_m=0.9 ratified by Eng; no further hero rescale unless BalanceConfig changes.

## Materials (PBR metallic-roughness)
| Name        | Role                         | Metallic | Roughness | Notes                          |
|-------------|------------------------------|----------|-----------|--------------------------------|
| Wood        | Warm oak cabinet body        | 0        | ~0.64     | Lower cabinet + deck           |
| Wood_Recess | Darker oak door groove       | 0        | ~0.72     | Value-contrast seam (no ink)   |
| Metal       | Soft brushed gunmetal trim   | ~0.85    | ~0.40     | Thinner frame; softened value  |
| Glass       | Clear case panes             | 0        | ~0.04     | Front/sides/back/top; alpha+transmission |
| Felt        | Burgundy interior liner      | 0        | ~0.92     | Display shelf surface          |

Godot 4: Glass may need a quick transparency pass after import; blockout reads as clear panes.

## Mesh budget
- **Verts:** 648
- **Tris:** 1188 (LOD0 + ~2.5 mm soft bevel — well under 5k)
- Single mesh object `prop_display_case_01` with 5 material slots

## Style / de-toon (2026-09-04)
- Soft bevels (~2.5 mm) for PBR edge response — **no** heavy black cel/toon outlines
- Near-black metal plinth/frame lightened to soft gunmetal; frame thickness reduced (~16 mm)
- Vertical door “ink” strip replaced with recessed wood value contrast
- Footprint unchanged at **1.8×0.9 m**

## Godot usage tips
1. Drop GLB into `res://`; let Godot generate `.import`.
2. Instance as-is; root at floor. Scale should be 1,1,1.
3. Occupies **2×1** tile cells on the shop grid.
4. Optional: enable transparency on Glass; cast shadows off on glass if needed.

## Godot 4.5.2 import verification
- Project: `/workspace/card-shop-simulator/godot-import-test/`
- Binary: `/workspace/godot452`
