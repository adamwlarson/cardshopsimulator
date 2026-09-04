# prop_icon_buy_01 — Import Notes (Overhead Intent)

## File
- `prop_icon_buy_01.glb` — binary glTF 2.0, +Y up
- Source: `prop_icon_buy_01.blend` + `build_icon_buy.py`

## Scale & Pivot
- **Unit:** 1 unit = **1 meter**
- **Authored extents:** **0.320 × 0.032 × 0.320 m** (W × D × H)
- **Pivot / origin:** **BOTTOM CENTER of disc** (hang point). Disc rises +Z (Blender) / +Y (Godot after +Y-up); face toward **−Y**.
- Eng parents ~+Y 0.4–0.5 above 1.7 m character (icon sits above hang point).

## Materials
| Name | Role |
|------|------|
| Metal | Soft gunmetal rim + clip |
| Plastic | Soft plastic disc body |
| Paper | Pack / card faces |
| Accent_Teal | Muted teal pack bands + card bar |

## Mesh budget
- Verts: 112 · Tris: 180 · Soft bevel ~1.2 mm — **no cel/ink outlines**
- Budget ≤200 tris ✓

## Godot tips
1. Hang above intent hotspot. Origin = bottom center hang point. Scale 1,1,1.
2. Billboard-friendly; keep face toward aisle cam / −Y shop axis.
3. Placeholder silhouette only — no readable text/IP.
4. Aisle read cam reference: (4.5, 1.65, −1.8) / −28° / fov 70.
