# char_cashier_01 — Import Notes (Optional Cashier / Clerk)

## Role
- **Optional cashier silhouette** — adult retail clerk behind counter
- Cashier — polo / apron, mid adult clerk
- Rest **A-pose**; looping clip **`idle_stand`** (in-place, ~2.00 s). Stylized-real Principled BSDF only — **no cel/ink**.

## File
- `char_cashier_01.glb` — binary glTF 2.0, +Y up, skinned biped
- Source: `char_cashier_01.blend` + `build_char_cashier_01.py` / `_npc_common.py`

## Scale & Pivot
- **Unit:** 1 unit = **1 meter**
- **Target height:** **1.72 m** (authored height=1.7200 m) — between C1 (1.74) / C2 (1.70)
- **Authored extents:** **0.8023 × 0.3171 × 1.7200 m** (W × D × H)
- **Pivot / origin:** **BOTTOM CENTER** — floor between feet (`min_z≈0`). Place on floor tile; no Z offset.
- Axis: glTF **+Y up**

## Armature
- Simple biped: `hips, spine, chest, head, upper_arm.L, lower_arm.L, upper_arm.R, lower_arm.R, thigh.L, shin.L, foot.L, thigh.R, shin.R, foot.R`
- Rigid part→bone weights (blockout skinning). Eng owns locomotion translation.

## Animation clips (exact names)
| Clip | Duration | Root motion | Notes |
|------|----------|-------------|-------|
| `idle_stand` | ~2.00 s loop | **In-place** (root stays at origin) | Soft weight shift, breathe, arms relaxed at sides |

## Materials
| Name | Role |
|------|------|
| Skin | Face / ears / hands |
| Hair | Hair mass |
| Cloth | Polo / upper shirt (muted teal accent) |
| Apron | Retail apron + blank name-tag plate |
| Shoe | Footwear |
| Cloth_Lower | Trousers |

## Outfit notes
- Muted teal polo (sole accent) + **warm canvas apron** (FOV polish) + blank name-tag plate (no text/SKU)
- Apron: higher bib, thicker body, pocket + waistband value break; straps wider for behind-desk / side read
- Name-tag: larger blank plate with dark charcoal rim (higher contrast) — **no text/SKU**
- Charcoal trousers, dark loafers, short dark hair
- Teal kept as polo only; apron carries cast distinctness vs C1 hoodie teal

## FOV polish pass (post PR #23 soft notes)
- Soft MidCenter held until this lands: apron/name-tag were subtler than polo in customer / behind-desk FOV
- Target reads: behind-desk cam ~(7.2, 1.6, -0.65) / −18° / FOV70 + approach / aisle-ish FOV
- Mesh front (apron / name-tag / face) aligned to Godot **−Z** so CashierSlot yaw 90 faces customers (−X)
- Principled BSDF only — **no cel/ink**

## Mesh budget
- Verts: 1364 · Tris: 2580 · Soft bevel ~2.5 mm — no cel/ink
- Soft LOD0 mannequin / stylized-real blockout (soft ≤~3k tris with skinning)

## Godot tips
1. Drop GLB into `res://chars/`; scale 1,1,1; origin on floor.
2. Use `AnimationPlayer` clip `idle_stand` for counter idle. Prefer in-place.
3. Face customer / aisle (−Z after +Y-up import; verify in scene).
4. Optional behind `prop_counter_01` / register; not wired into Eng by default.

## Godot 4.5.2 import verification
- Project: `/workspace/card-shop-simulator/godot-import-test/`
- QA shots (apron FOV polish): `NPC_cashier_apron_interact.png`, `NPC_cashier_apron_approach.png`
