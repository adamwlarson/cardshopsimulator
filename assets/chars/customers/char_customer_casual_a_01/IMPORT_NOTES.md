# char_customer_casual_a_01 — Import Notes (Customer NPC C1)

## Role
- **C1** — Adult browse/buy
- Casual A — jeans / hoodie, taller lean
- Rest **A-pose**; looping clips **`walk`** + **`browse_idle`** (in-place). Stylized-real Principled BSDF only — **no cel/ink**.

## File
- `char_customer_casual_a_01.glb` — binary glTF 2.0, +Y up, skinned biped
- Source: `char_customer_casual_a_01.blend` + `build_char_customer_casual_a_01.py` / `_npc_common.py`

## Scale & Pivot
- **Unit:** 1 unit = **1 meter**
- **Target height:** **1.74 m** (authored height=1.7400 m)
- **Authored extents:** **0.7817 × 0.3382 × 1.7400 m** (W × D × H)
- **Pivot / origin:** **BOTTOM CENTER** — floor between feet (`min_z≈0`). Place on floor tile; no Z offset. **Unchanged** from static MVP.
- Axis: glTF **+Y up**

## Armature
- Simple biped: `hips, spine, chest, head, upper_arm.L, lower_arm.L, upper_arm.R, lower_arm.R, thigh.L, shin.L, foot.L, thigh.R, shin.R, foot.R`
- Rigid part→bone weights (blockout skinning). Eng owns locomotion translation.

## Animation clips (exact names)
| Clip | Duration | Root motion | Notes |
|------|----------|-------------|-------|
| `walk` | ~1.20 s loop | **In-place** (root stays at origin) | Subtle arm swing, hip sway, foot steps |
| `browse_idle` | ~2.27 s loop | **In-place** (no travel) | Weight shift, head look, one-arm case gesture (~1.1–1.3 m) |

## Materials
| Name | Role |
|------|------|
| Skin | Face / ears / hands |
| Hair | Hair mass |
| Cloth | Upper |
| Cloth_Lower | Pants / trousers |
| Shoe | Footwear |

## Mesh budget
- Verts: 1182 · Tris: 2252 · Soft bevel ~2.5 mm — no cel/ink
- Soft LOD0 mannequin / stylized-real blockout (soft ≤~3k tris with skinning)

## Godot tips
1. Drop GLB into `res://chars/`; scale 1,1,1; origin on floor.
2. Use `AnimationPlayer` clips `walk` / `browse_idle`. Prefer in-place; pathing owns translation.
3. Face aisle (−Z after +Y-up import; verify in scene).
4. Pair with overhead intent icons (`prop_icon_browse_01` / `_buy_01` / `_sell_01`).

## Godot 4.5.2 import verification
- Project: `/workspace/card-shop-simulator/godot-import-test/`
- QA shots: `NPC_anim_walk_interact.png`, `NPC_anim_browse_interact.png`
