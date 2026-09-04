# prop_shelf_01 — Import Notes (A09)

## File
- `prop_shelf_01.glb` — binary glTF 2.0, +Y up
- Source: `prop_shelf_01.blend` + `build_shelf.py`

## Scale & Pivot
- **Unit:** 1 unit = **1 meter**
- **§7.1 footprint:** Shelf = **1×2 tiles**. **1 tile = 0.9 m** → **0.9 m × 1.8 m**
- **Authored extents:** **0.900 m W × 1.800 m D × 2.000 m H** (locked in `_build_stats.txt`)
- **Pivot / origin:** **BOTTOM CENTER** (floor contact). No Z offset.
- **Facing:** Customer face is **−X** (short face); long axis **Y** runs along wall (sealed-wall section)

## Materials
| Name | Role |
|------|------|
| Wood | Warm oak uprights / shelves / back |
| Wood_Recess | Darker panel seams (value contrast, not ink) |
| Metal | Soft gunmetal plinth, lips, rails |
| Accent | Muted-teal under-lip strip (subtle emission) |

## Mesh budget
- Verts: 528 · Tris: 968 · Soft bevel ~2.5 mm — no cel/ink outlines
- 5 shelf tiers; can stock with A06 proxies

## Godot tips
1. Occupies **1×2** tile cells. Scale 1,1,1.
2. Rotate 90° in Y if shop layout wants long axis along a different wall.
3. Back panel (+X) intended against shop wall.
