# prop_poster_frame_sm_01 — Import Notes (B02)

## File
- `prop_poster_frame_sm_01.glb` — binary glTF 2.0, +Y up
- Source: `prop_poster_frame_sm_01.blend` + `build_poster_frame_sm.py`

## Scale & Pivot
- **Unit:** 1 unit = **1 meter**
- **Authored extents:** **0.400 × 0.020 × 0.550 m** (W×D×H)
- **Pivot / origin:** **BACK-CENTER** (wall mount). Back face at Y=0; frame extends **−Y** into room.
- **Facing:** Print readable on **−Y**

## Materials
| Name | Role |
|------|------|
| Wood | Warm thin frame rails |
| Metal | Soft gunmetal wall mount plate |
| Paper | Matte print plane |
| Accent_Teal | Abstract teal shapes (no IP / no readable text) |
| Accent_Burgundy | Abstract burgundy block |

## Mesh budget
- Verts: 216 · Tris: 396 · Soft bevel ~2.5 mm — **no cel/ink outlines**
- Budget ≤800 tris ✓

## Godot tips
1. Place origin on wall surface. Scale 1,1,1.
2. Rotate in Y if wall faces a different axis.
3. Placeholder abstract only — swap Paper/accents later for shop-safe prints.
