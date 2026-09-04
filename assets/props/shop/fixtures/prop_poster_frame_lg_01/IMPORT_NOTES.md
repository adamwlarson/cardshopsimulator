# prop_poster_frame_lg_01 — Import Notes (B02)

## File
- `prop_poster_frame_lg_01.glb` — binary glTF 2.0, +Y up
- Source: `prop_poster_frame_lg_01.blend` + `build_poster_frame_lg.py`

## Scale & Pivot
- **Unit:** 1 unit = **1 meter**
- **Authored extents:** **0.700 × 0.025 × 0.950 m** (W×D×H)
- **Pivot / origin:** **BACK-CENTER** (wall mount). Back face at Y=0; frame extends **−Y** into room.
- **Facing:** Print readable on **−Y**

## Materials
| Name | Role |
|------|------|
| Metal | Soft gunmetal frame rails + mount |
| Paper | Matte print plane |
| Accent_Teal | Abstract teal shapes |
| Accent_Burgundy | Abstract burgundy sweeps |

## Mesh budget
- Verts: 240 · Tris: 440 · Soft bevel ~2.5 mm — **no cel/ink outlines**
- Budget ≤800 tris ✓

## Godot tips
1. Place origin on wall surface. Scale 1,1,1.
2. Hero wall piece — keep clear of door swing.
