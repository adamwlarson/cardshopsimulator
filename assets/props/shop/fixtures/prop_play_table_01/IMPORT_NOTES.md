# prop_play_table_01 — Import Notes (B09)

## File
- `prop_play_table_01.glb` — binary glTF 2.0, +Y up
- Source: `prop_play_table_01.blend` + `build_play_table.py` (Blender 4.3 procedural blockout)

## Scale & Pivot
- **Unit:** 1 Blender/glTF unit = **1 meter**
- **§7.1 footprint:** Play table = **2×2 tiles** @ 0.9 m → **1.800 × 1.800 m**
- **Authored extents:** **1.800 m W × 1.800 m D × 0.761 m H** (sitting play height)
- **Pivot / origin:** **BOTTOM CENTER** (floor contact). Place node at floor; no Z offset.
- Axis: glTF **+Y up**
- Path-block: mass fills full 2×2 — Eng may treat as blocking tile

## Materials (PBR metallic-roughness)
| Name | Role | Metallic | Roughness |
|------|------|----------|-----------|
| Wood | Warm oak top / apron / legs | 0 | ~0.60 |
| Wood_Dark | Cup wells + stretcher | 0 | ~0.68 |
| Felt | Muted burgundy playmat inset | 0 | ~0.92 |
| Metal | Soft gunmetal rail / cup rims / feet | ~0.78 | ~0.42 |

## Mesh budget
- Verts: 552 · Tris: **1012** (≤2.5k) · Soft bevel ~2.5 mm — **no cel/ink outlines**

## Godot tips
1. Drop GLB into `res://`; scale 1,1,1; root at floor.
2. Occupies **2×2** tile cells; treat as path-blocking.
3. Pair stools (A10) around perimeter for event seating.

## Godot 4.5.2 import verification
- Project: `/workspace/card-shop-simulator/godot-import-test/`
- Result: **SUCCESS** (see import run)
