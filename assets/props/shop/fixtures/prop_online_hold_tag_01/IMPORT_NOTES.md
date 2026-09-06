# prop_online_hold_tag_01 — Import Notes (J2)

## File
- `prop_online_hold_tag_01.glb` — binary glTF 2.0, +Y up
- Source: `build_online_hold_tag.py` (procedural Principled/PBR, 1u=1m)

## Scale & Pivot
- **Unit:** 1 unit = **1 meter**
- **Authored extents:** **0.080 × 0.022 × 0.052 m** (W × D × H; `prop_price_tag_01` class)
- **Pivot / origin:** **CLIP / MOUNT TOP-BACK**. Tag hangs below (**−Y**); face toward **+Z** (aisle when unrotated on a back-wall fixture).
- Soft bevel ~1.2 mm — **no cel/ink outlines**

## Materials (PBR metallic-roughness)
| Name | Role | Metallic | Roughness |
|------|------|----------|-----------|
| Metal | Soft gunmetal shelf clip | 0.75 | 0.42 |
| Plastic | Soft plastic card body | 0 | 0.38 |
| Paper | Matte face + diamond pip | 0 | 0.70 |
| Accent_Amber | Warm amber header — lock **(0.82, 0.52, 0.18)** | 0 | 0.48 |

Header is **Accent_Amber** (sell-icon lock), not `Accent_Teal`. Distinct from `prop_price_tag_01` / `prop_shelf_talker_01` at aisle distance. Placeholder bars + diamond only — **no readable SKU / IP / price text**.

## Mesh budget
- Verts: 432 · Tris: **144** (≤200) ✓

## Godot usage tips
1. Parent to shelf-edge lip or case-lip. Scale **1,1,1**.
2. Face the aisle: +Z in the GLB. On `prop_shelf_01` (customer face **−X**) use **Y = −90°**. On `prop_display_case_*` customer face **−Z** use **Y = 180°**.
3. Suggested shelf lip: local **(−0.452, 1.35, 0.12)** on `prop_shelf_01`. Suggested case lip: **(0.18, 0.72, −0.452)** on a display case.

## Eng marker hook (visibility only — no economy verbs)
- Instance as `OnlineHoldTag` (or keep imported mesh name `prop_online_hold_tag_01`).
- **ACK:** toggle `MeshInstance3D.visible` (or a `Marker3D` parent) when the occupying item `location.type == ONLINE_HOLD`.
- Hide when the slot is in-store (`CASE` / `SHELF` / `BINDER` / `BACKSTOCK`) or empty.
- Do **not** invent list/cancel HUD chrome or economy APIs for this cue.

## Godot 4.x import
- Drop GLB into `res://`; let Godot generate `.import`.
- Principled slots import as StandardMaterial3D metallic-roughness.
