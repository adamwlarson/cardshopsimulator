# X1 — Soft far crest polish (SH7)

**Owner:** CSS Art  
**Status:** **PASS** — Soft far crest (SH7) closed  
**Date:** 2026-09-06  
**SoT:** `J2_ART_CUES_MVP.md`, `prop_graded_case_badge_01/IMPORT_NOTES.md`  
**Rule:** Same node `GradedCaseBadge` / same GLB path. Soft catalog otherwise **CLOSED** (do not reopen SH1–SH6/SH8). No economy verbs.

---

## Closeout

| Item | Result |
|------|--------|
| Soft far crest thin (SH7) | **PASS** |
| Eng marker | **No-op swap** — path/name unchanged |
| Parent pose | **Unchanged** `(0.0, 1.06, -0.452)` — no lid-clear Y bump |
| Slab case 2×1 @ 0.9 m | **Locked** — not rescaled |

J2 far stills (~8.2 m) collapsed the kite to a 3–4 px gray sliver on the glass lip. X1 grows a brass-outer / gunmetal-window diamond that pokes above the 1.12 m lid (world Y ≈ 1.48 m) and reads as a gold triangle vs the empty oak case at 8–12 m.

---

## What changed (mesh only)

| | J2 | X1 |
|--|----|----|
| Extents (W×D×H) | 0.520 × 0.024 × 0.260 m | **0.580 × 0.054 × 0.570 m** |
| Diamond kite | 0.156 × 0.260 m, dark outer | **~0.39 × 0.57 m**, bright brass outer |
| Tris / verts | 224 / 672 | **224 / 672** (same prims) |
| Materials | Mid gunmetal + muted brass | Dark gunmetal **(0.18)** + bright brass **(0.94, 0.74, 0.26)** |
| Pivot / path | back-center, `prop_graded_case_badge_01.glb` | **same** |

Soft bevel 1.8 mm. No cel/ink. Bars + diamond only — no readable IP / grader marks / text.

Rebuild:

```
python3 assets/props/shop/fixtures/prop_graded_case_badge_01/build_graded_case_badge.py
python3 tools/art/render_x1_far_crest_qa_shots.py
```

---

## QA stills

Studio PBR rasters of the GLB (same bar as J2) — not an in-engine viewport.

| Shot | Path | Read |
|------|------|------|
| Far ~10 m frontal | `docs/art/qa-shots/X1_graded_crest_far.png` | Gold diamond poke on slab (R) vs flat oak lid (L) |
| Approach ~3.6 m | `docs/art/qa-shots/X1_graded_crest_approach.png` | Kite + bars clear vs base |
| Interact ~1.9 m | `docs/art/qa-shots/X1_graded_crest_interact.png` | Nested brass / gunmetal / enamel |
| Detail | `docs/art/qa-shots/X1_graded_crest_detail.png` | Soft bevels, bars / diamond only |
| Far ~8.2 m (J2 camera) | `docs/art/qa-shots/X1_graded_crest_far_vs_base.png` | A/B vs `J2_graded_case_far.png` |

---

## Eng

- Instance stays `GradedCaseBadge` on `Fixtures/SlabDisplayCase`.
- Drop-in GLB swap. **No** visibility wire, **no** `cert_valid` / price bind, **no** `shop_floor.tscn` edit in this pack.
- Thin ACK only if a future path/name change lands — **not this PR**.

---

## Parked (not this PR)

- SH1–SH6 / SH8 Soft catalog reopen
- Economy / authenticity world labels
- Hero rescale of `prop_display_case_slab_01`
