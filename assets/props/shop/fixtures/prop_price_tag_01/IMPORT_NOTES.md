# prop_price_tag_01 — Import Notes (B03)

## File
- `prop_price_tag_01.glb` — binary glTF 2.0, +Y up
- Source: `prop_price_tag_01.blend` + `build_price_tag.py`

## Scale & Pivot
- **Unit:** 1 unit = **1 meter**
- **Authored extents:** **0.080 × 0.020 × 0.050 m**
- **Pivot / origin:** **CLIP / MOUNT TOP-BACK**. Tag hangs below (−Z); face toward **−Y**.

## Materials
| Name | Role |
|------|------|
| Metal | Soft gunmetal shelf clip |
| Plastic | Soft plastic card body |
| Paper | Matte face |
| Accent_Teal | Muted teal header strip |

## Mesh budget
- Verts: 96 · Tris: 176 · Soft bevel ~1.2 mm — **no cel/ink outlines**
- Budget ≤200 tris ✓

## Godot tips
1. Parent to shelf-edge lip. Scale 1,1,1.
2. Placeholder bars only — no readable SKU/IP text.
