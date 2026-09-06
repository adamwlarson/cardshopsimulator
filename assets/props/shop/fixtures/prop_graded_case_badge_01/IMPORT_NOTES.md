# prop_graded_case_badge_01 — Import Notes (J2 + X1)

## File
- `prop_graded_case_badge_01.glb` — binary glTF 2.0, +Y up
- Source: `build_graded_case_badge.py` (procedural Principled/PBR, 1u=1m)
- **X1 Soft far crest polish** — same node / same GLB path as J2 (Eng no-op swap)

## Scale & Pivot
- **Unit:** 1 unit = **1 meter**
- **Authored extents:** **0.580 × 0.054 × 0.570 m** (W × D × H) — additive, does **not** change the slab-case 2×1 @ 0.9 m footprint
- J2 was 0.520 × 0.024 × 0.260 m / 224 tris. X1 keeps the same primitive count; diamond is a fatter kite (~0.39 × 0.57 m) with a thicker header bar.
- Verts: 672 · Tris: **224** (modest; not a hero rewrite)
- **Pivot / origin:** **BACK-CENTER of the mount plate**. Body extends **−Z** (toward aisle when parented to the slab-case customer face).
- Soft bevel ~1.8 mm — **no cel/ink outlines**

## Why a badge (not a hero rescale)
`prop_display_case_slab_01` already has gunmetal trim / risers / brass plaque. J2 far aisle read (8–12 m) still collapsed toward the base oak case (SH7). X1 grows the crest above the 1.12 m lid and darkens the gunmetal / brightens the brass so the graded path has a distinct diamond silhouette without rescaling the 1.8×0.9 m fixture.

## Materials (PBR metallic-roughness)
| Name | Role | Metallic | Roughness |
|------|------|----------|-----------|
| Metal | Dark gunmetal studs | 0.84 | 0.36 |
| Metal_Slab | Dark gunmetal backer + diamond rim | 0.88 | 0.28 |
| Plaque | Bright brass plaque / diamond face | 0.58 | 0.26 |
| Felt | Muted burgundy enamel (slab-liner language) | 0 | 0.93 |
| Paper | Placeholder bars + inner pip | 0 | 0.70 |

No readable IP, grader logos, cert numbers, or text — bars / diamond only.

## Suggested parent (static)
Parent to `SlabDisplayCase` / `prop_display_case_slab_01` at local **`(0.0, 1.06, -0.452)`**, rotation **0**, scale **1,1,1**. Pivot sits on the −Z glass front; diamond crest clears the 1.12 m lid (world Y ≈ 1.48 m). **No parent Y bump** — thicker crest is in front of the lid (−Z), not through it.

Do **not** rescale or move `prop_display_case_slab_01` (footprint / pivot locked).

## Eng marker hook (optional static — no economy verbs)
- Instance as `GradedCaseBadge` child of `Fixtures/SlabDisplayCase`.
- **ACK:** optional **static** mesh — no visibility toggle required. Graded path is the slab-case fixture itself; the badge is the far-read cue.
- Mesh / import path **unchanged** (`prop_graded_case_badge_01.glb`) — drop-in swap, no marker rename.
- Do **not** bind this node to `cert_valid`, price, or authenticity verbs.

## Rebuild

```
python3 assets/props/shop/fixtures/prop_graded_case_badge_01/build_graded_case_badge.py
python3 tools/art/render_x1_far_crest_qa_shots.py
```

## Godot 4.x import
- Drop GLB into `res://`; let Godot generate `.import`.
- Principled slots import as StandardMaterial3D metallic-roughness.
