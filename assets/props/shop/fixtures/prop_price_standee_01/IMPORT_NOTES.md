# prop_price_standee_01 — Import Notes (B03)

## File
- `prop_price_standee_01.glb` — binary glTF 2.0, +Y up
- Source: `prop_price_standee_01.blend` + `build_price_standee.py`

## Scale & Pivot
- **Unit:** 1 unit = **1 meter**
- **Authored extents:** **0.120 × 0.080 × 0.100 m**
- **Pivot / origin:** **BOTTOM-CENTER** footprint (case-top contact). Z=0 on surface.
- **Facing:** Card face toward **−Y**

## Materials
| Name | Role |
|------|------|
| Plastic | Soft plastic L-stand body / base |
| Paper | Matte insert |
| Accent_Burgundy | Burgundy header strip |

## Mesh budget
- Verts: 96 · Tris: 176 · Soft bevel ~1.2 mm — **no cel/ink outlines**
- Budget ≤200 tris ✓

## Godot tips
1. Place on display-case glass / counter top. Scale 1,1,1.
2. Non-readable placeholder only.
