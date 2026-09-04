# prop_window_01 — Import Notes (B06)

## File
- `prop_window_01.glb` — binary glTF 2.0, +Y up
- Source: `prop_window_01.blend` + `build_window.py`

## Scale & Pivot
- **Unit:** 1 unit = **1 meter**
- **Authored extents:** **1.800 × 0.113 × 1.300 m** (W×D×H) — fits **2-tile** wall span
- **Pivot / origin:** **BACK-CENTER** (wall mount). Back face at **Y=0**; glass/sill extend **−Y** into room (same convention as poster frames).
- Place origin on wall surface; scale 1,1,1.

## Materials
| Name | Role |
|------|------|
| Metal | Soft gunmetal outer frame + mullions |
| Wood | Warm inner liner + interior sill |
| Glass | Cooler clear panes (day/night readable; no animated shader) |

## Mesh budget
- Verts: 408 · Tris: **748** (≤800) · Soft bevel ~2.5 mm — **no cel/ink outlines**

## Godot tips
1. Mount on shop wall like posters; facing −Y (Blender) → typically −Z after glTF.
2. Glass may need transparency pass after import.

## Godot 4.5.2 import verification
- Project: `/workspace/card-shop-simulator/godot-import-test/`
- Result: **SUCCESS**
