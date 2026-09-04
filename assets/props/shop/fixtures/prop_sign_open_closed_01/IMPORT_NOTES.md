# prop_sign_open_closed_01 — Import Notes (A02)

## File
- `prop_sign_open_closed_01.glb` — binary glTF 2.0, +Y up
- Source: `prop_sign_open_closed_01.blend` + `build_sign_open_closed.py`

## Scale & Pivot
- **Unit:** 1 unit = **1 meter**
- **Authored extents:** **0.300 × 0.040 × 0.180 m**
- **Pivot / origin:** **MOUNT CENTER** (hang ring). Sign body hangs below; flip 180° Y to show CLOSED.
- **Faces:** **OPEN** readable on **−Y**; **CLOSED** (burgundy) on **+Y**

## Materials
| Name | Role |
|------|------|
| Plastic | Cream plaque body |
| OpenGlyph | Green OPEN field (subtle emission) |
| Plastic_Closed | Burgundy CLOSED field |
| ClosedGlyph | Light CLOSED bars |
| Metal | Soft gunmetal ring / edge trim |
| Cord | Hang cord |

## Mesh budget
- Soft bevel ~2 mm — **no cel/ink outlines**
- Block OPEN glyphs (O-P-E-N) for glance readability; not fine typography

## Godot tips
1. Parent to door glass / latch jamb. Scale 1,1,1.
2. Rotate 180° about local up to toggle CLOSED face toward customer.
3. Emission on OpenGlyph is mild — bump in Godot if shop lighting washes it out.
