# prop_binder_rack_01 — Import Notes

## File
- `prop_binder_rack_01.glb` — binary glTF 2.0, +Y up
- Source: `prop_binder_rack_01.blend` + `build_binder_rack.py` (Blender 4.3 procedural blockout)

## Scale & Pivot
- **Unit:** 1 Blender/glTF unit = **1 meter**
- **§7.1 footprint:** Binder rack = **1×1 tiles**. Art/Eng assumption: **1 tile = 0.9 m** → footprint **0.9 m × 0.9 m**
- **Authored extents:** **0.9000 m W × 0.9000 m D × 1.1237 m H** (browse height 1.0–1.2 m)
- **Pivot / origin:** **BOTTOM CENTER** (floor contact). Place the node at the floor point; no Z offset needed.
- Axis: glTF **+Y up** (Blender Z-up converted on export)
- Grid lock: tile_size_m=0.9 ratified by Eng; no further hero rescale unless BalanceConfig changes.

## Materials (PBR metallic-roughness)
| Name | Role | Notes |
|------|------|-------|
| Wood | Warm oak frame / shelves / posts | Posts, rails, shelves, header |
| Metal | Dark gunmetal plinth / trim | Plinth, shelf edges, kick |
| Binder_A/B/C/D | Matte binder stubs (navy/burgundy/forest/olive) | Browse affordance |
| Accent / Plastic | Optional accent / plastic detail | Per build slots |

Slots present: Metal,Wood,Accent,Binder_A,Binder_B,Binder_C,Binder_D,Plastic

## Mesh budget
- **Verts:** 744
- **Tris:** 1364 (LOD0 blockout — well under 5k; strong upright silhouette)
- Single mesh object `prop_binder_rack_01`

## Godot usage tips
1. Drop GLB into `res://`; let Godot generate `.import`.
2. Instance as-is; root at floor. Scale should be 1,1,1.
3. Occupies **1×1** tile cell on the shop grid.
4. Customer browse face is the open front (−Z in Godot after +Y-up glTF import); verify facing in scene.

## Style intent
Cozy-but-serious stylized-real singles/binder browse rack — warm oak frame, dark metal plinth/trim, matte binder stubs for density. Strong vertical silhouette for shop-camera gate (A07).

## Godot 4.5.2 import verification
- Project: `/workspace/card-shop-simulator/godot-import-test/`
- Result: **SUCCESS** (exit 0). `prop_binder_rack_01.glb` imported; `.glb.import` generated.
- QA shots: `A07_far.png`, `A07_approach.png`, `A07_interact.png`.
