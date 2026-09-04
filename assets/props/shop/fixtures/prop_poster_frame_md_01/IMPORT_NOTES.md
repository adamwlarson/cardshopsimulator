# prop_poster_frame_md_01 — Import Notes (B02)

## File
- `prop_poster_frame_md_01.glb` — binary glTF 2.0, +Y up
- Source: `prop_poster_frame_md_01.blend` + `build_poster_frame_md.py`

## Scale & Pivot
- **Unit:** 1 unit = **1 meter**
- **Authored extents:** **0.550 × 0.020 × 0.750 m** (W×D×H)
- **Pivot / origin:** **BACK-CENTER** (wall mount). Back face at Y=0; frame extends **−Y** into room.
- **Facing:** Print readable on **−Y**

## Materials
| Name | Role |
|------|------|
| Wood | Warm thin frame rails |
| Metal | Soft gunmetal wall mount plate |
| Paper | Matte print plane |
| Accent_Burgundy | Burgundy-forward abstract |
| Accent_Teal | Teal accent blocks |

## Mesh budget
- Verts: 240 · Tris: 440 · Soft bevel ~2.5 mm — **no cel/ink outlines**
- Budget ≤800 tris ✓

## Godot tips
1. Place origin on wall surface. Scale 1,1,1.
2. Pair with sm/lg for wall variety.
