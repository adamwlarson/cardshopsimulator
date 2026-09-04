# prop_light_overhead_01 — Import Notes (A11)

## File
- `prop_light_overhead_01.glb` — binary glTF 2.0, +Y up
- Source: `prop_light_overhead_01.blend` + `build_light_overhead.py`

## Scale & Pivot
- **Unit:** 1 unit = **1 meter**
- **Authored extents:** **0.900 × 0.128 × 0.095 m** (L×W×H)
- **Pivot / origin:** **MOUNT POINT — top center**. Fixture hangs below; place node at ceiling attachment.
- Warm LED diffuser emission (~3600–3800K / 3500–4000K feel); may need Godot Emission energy tweak after import

## Materials
| Name | Role | Notes |
|------|------|-------|
| Housing | Soft gunmetal body | Metallic ~0.80 |
| EndCap | End caps | Soft metal |
| LED_Diffuser | Warm emissive panel | Base/Emission **(1.0, 0.87–0.88, 0.74)** · strength **5.0** (not cool cyan/blue) |

## Mesh budget
- Verts: 192 · Tris: 352 (under 400–800 target)
- Soft bevel ~2 mm — no cel/ink outlines
