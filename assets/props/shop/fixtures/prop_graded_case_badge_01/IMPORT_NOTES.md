# prop_graded_case_badge_01 — Import Notes (J2)

## File
- `prop_graded_case_badge_01.glb` — binary glTF 2.0, +Y up
- Source: `build_graded_case_badge.py` (procedural Principled/PBR, 1u=1m)

## Scale & Pivot
- **Unit:** 1 unit = **1 meter**
- **Authored extents:** **0.520 × 0.024 × 0.260 m** (W × D × H) — thin additive, does **not** change the slab-case 2×1 @ 0.9 m footprint
- Verts: 672 · Tris: **224** (modest; not a hero rewrite)
- **Pivot / origin:** **BACK-CENTER of the mount plate**. Body extends **−Z** (toward aisle when parented to the slab-case customer face).
- Soft bevel ~1.8 mm — **no cel/ink outlines**

## Why a badge (not a hero rescale)
`prop_display_case_slab_01` already has gunmetal trim / risers / brass plaque. Far aisle read (8–12 m) still collapses toward the base oak case. This crest sits on the **front glass header** and pokes above the 1.12 m lid so the graded path has a distinct silhouette without rescaling the 1.8×0.9 m fixture.

## Materials (PBR metallic-roughness)
| Name | Role | Metallic | Roughness |
|------|------|----------|-----------|
| Metal | Soft gunmetal studs | 0.78 | 0.40 |
| Metal_Slab | Gunmetal backer + diamond rim | 0.82 | 0.35 |
| Plaque | Soft brass plaque / diamond face | 0.52 | 0.34 |
| Felt | Muted burgundy enamel (slab-liner language) | 0 | 0.93 |
| Paper | Placeholder bars + inner pip | 0 | 0.72 |

No readable IP, grader logos, cert numbers, or text — bars / diamond only.

## Suggested parent (static)
Parent to `SlabDisplayCase` / `prop_display_case_slab_01` at local **`(0.0, 1.06, -0.452)`**, rotation **0**, scale **1,1,1**. Pivot sits on the −Z glass front; diamond crest clears the 1.12 m lid.

Do **not** rescale or move `prop_display_case_slab_01` (footprint / pivot locked).

## Eng marker hook (optional static — no economy verbs)
- Instance as `GradedCaseBadge` child of `Fixtures/SlabDisplayCase`.
- **ACK:** optional **static** mesh — no visibility toggle required. Graded path is the slab-case fixture itself; the badge is the far-read cue.
- Do **not** bind this node to `cert_valid`, price, or authenticity verbs.

## Godot 4.x import
- Drop GLB into `res://`; let Godot generate `.import`.
- Principled slots import as StandardMaterial3D metallic-roughness.
