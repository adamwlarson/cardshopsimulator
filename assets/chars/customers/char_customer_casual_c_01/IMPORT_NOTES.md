# char_customer_casual_c_01 — Import Notes (Customer NPC C3)

## Role
- **C3** — Optional third / spike lean
- Casual C — sweater / coat, shorter stockier
- Idle **A-pose**, static rest (no animation clip). Stylized-real Principled BSDF only — **no cel/ink**.

## File
- `char_customer_casual_c_01.glb` — binary glTF 2.0, +Y up
- Source: `char_customer_casual_c_01.blend` + `build_char_customer_casual_c_01.py` / `_npc_common.py`

## Scale & Pivot
- **Unit:** 1 unit = **1 meter**
- **Target height:** **1.66 m** (authored height=1.6600 m)
- **Authored extents:** **0.8833 × 0.3335 × 1.6600 m** (W × D × H)
- **Pivot / origin:** **BOTTOM CENTER** — floor between feet (`min_z≈0`). Place on floor tile; no Z offset.
- Axis: glTF **+Y up**

## Materials
| Name | Role |
|------|------|
| Skin | Face / ears / hands |
| Hair | Hair mass |
| Cloth | Upper (coat) — camel coat + muted burgundy sweater peek |
| Cloth_Lower | Pants / trousers |
| Shoe | Footwear |

| Cloth_Sweater | Muted burgundy turtleneck peek |

## Mesh budget
- Verts: 1108 · Tris: 2104 · Soft bevel ~2.5 mm — no cel/ink
- Soft LOD0 mannequin / stylized-real blockout (≤2500 tris)

## Godot tips
1. Drop GLB into `res://chars/`; scale 1,1,1; origin on floor.
2. Face aisle (−Z after +Y-up import; verify in scene).
3. Pair with overhead intent icons (`prop_icon_browse_01` / `_buy_01` / `_sell_01`).

## Godot 4.5.2 import verification
- Project: `/workspace/card-shop-simulator/godot-import-test/`
- QA shots: `NPC_customers_interact.png`, `NPC_customers_approach.png`
