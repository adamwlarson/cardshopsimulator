# prop_backstock_door_01 — Import Notes (A13)

## File
- `prop_backstock_door_01.glb` — binary glTF 2.0, +Y up
- Source: `prop_backstock_door_01.blend` + `build_backstock_door.py` (Blender 4.3 procedural blockout)

## Scale & Pivot
- **Unit:** 1 Blender/glTF unit = **1 meter**
- **§7.1 footprint:** Backstock door = **1×1 tiles**. Art/Eng assumption: **1 tile = 0.9 m** → footprint **0.9 m × 0.9 m**
- **Authored extents:** **0.9000 m W × 0.9000 m D × 2.0900 m H** (height in 2.0–2.1 m band)
- **Pivot / origin:** **BOTTOM-CENTER of footprint (floor)**. Place the node at the floor center of the 1×1 tile; no offset needed.
- **Hinge note:** Leaf hinge edge is authored on the **−X side of the door leaf** (within the alcove). For open/close animation, Eng should parent a hinge empty at the leaf hinge foot rather than rotating this root (root is footprint center, not hinge).
- Axis: glTF **+Y up** (Blender Z-up converted on export). Shop face / alcove mouth = **−Y in Blender** → **+Z in Godot** after +Y-up import.
- Grid lock: tile_size_m=0.9 ratified by Eng; no further hero rescale unless BalanceConfig changes.

## Design
Alcove staff / bins-access door filling the 1×1 tile:
- Dark metal floor plinth (full 0.9×0.9)
- Wood side walls forming a short niche
- Soft gunmetal frame (jambs + lintel + threshold) at rear of alcove
- Solid wood leaf with recessed panels, kick plate, handle, hinges
- Small metal sign plate on upper leaf (STAFF/BINS readability cue)

## Materials (PBR metallic-roughness)
| Name | Role | Notes |
|------|------|-------|
| Wood | Alcove walls, leaf, header | Warm oak body |
| Wood_Panel | Recessed leaf panels | Slightly lighter wood |
| Metal | Soft gunmetal frame / hardware / mouth trim | Not ink-black |
| Metal_Dark | Plinth / kick mass | Soft dark gunmetal |
| Sign_Plate | Upper leaf plate | Soft brushed metal |

## Mesh budget
- Soft bevel ~2.5 mm — **no cel/ink outlines**
- See `_build_stats.txt` for verts/tris (LOD0 blockout, ~1k tris)

## Godot usage tips
1. Drop GLB into `res://`; let Godot generate `.import`.
2. Instance as-is; root at floor center of the backstock tile. Scale 1,1,1.
3. Occupies **1×1** tile cell on the shop grid (bins access).
4. Face alcove mouth toward the sales floor (+Z in Godot after import).

## Style intent
Cozy-but-serious stylized-real staff door — wood body, soft gunmetal hardware, readable “bins access” silhouette. Distinct from customer front door (`prop_door_01` / A02) which has glass lite.

## Godot 4.5.2 import verification
- Project: `/workspace/card-shop-simulator/godot-import-test/`
- Result: **SUCCESS**. `prop_backstock_door_01.glb` imported; `.glb.import` + `.godot/imported/*.scn` generated.
- QA shots: `docs/art/qa-shots/A13_interact.png`, `A13_approach.png` (optional spot-check).
