# prop_shelf_talker_01 — Import Notes (B03)

## File
- `prop_shelf_talker_01.glb` — binary glTF 2.0, +Y up
- Source: `prop_shelf_talker_01.blend` + `build_shelf_talker.py`

## Scale & Pivot
- **Unit:** 1 unit = **1 meter**
- **Authored extents:** **0.100 × 0.010 × 0.180 m**
- **Pivot / origin:** **HANG POINT TOP-CENTER**. Strip hangs below (−Z).

## Materials
| Name | Role |
|------|------|
| Metal | Soft gunmetal hang tab |
| Plastic | Soft plastic strip body |
| Paper | Matte face |
| Accent_Teal | Teal header band |

## Mesh budget
- Verts: 96 · Tris: 176 · Soft bevel ~1.2 mm — **no cel/ink outlines**
- Budget ≤200 tris ✓

## Godot tips
1. Hang from shelf front lip / peg. Scale 1,1,1.
2. Face −Y toward aisle.
