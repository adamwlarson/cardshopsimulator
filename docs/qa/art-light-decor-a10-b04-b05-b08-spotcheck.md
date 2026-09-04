# Light décor spot-check — A10 stool + B04 shipper + B05 plant + B08 trash
**Scorer:** CSS QA  
**Date:** 2026-09-04  
**Evidence:** `docs/art/qa-shots/LIGHT_DECOR_approach.png`, `LIGHT_DECOR_interact.png`  
(also copied to `/workspace/card-shop-qa/evidence/`)  
**Props:**
| Art ID | Stem | Extents (W×D×H m) | Tris | Pivot | Godot import |
|--------|------|-------------------|------|-------|--------------|
| A10 | `prop_stool_01` | 0.400 × 0.400 × 0.450 | 308 | bottom-center | **SUCCESS** |
| B04 | `prop_shipper_stack_01` | 0.500 × 0.400 × 0.550 | 440 | bottom-center | **SUCCESS** |
| B05 | `prop_plant_01` | 0.300 × 0.300 × 0.450 | 528 | bottom-center | **SUCCESS** |
| B08 | `prop_trash_bin_01` | 0.300 × 0.300 × 0.500 | 396 | bottom-center | **SUCCESS** |

All four `.glb` present under `docs/art/props/`; Godot 4.5.2 import-test has matching `.glb.import` + `.godot/imported/*.scn`.

## Verdict: **PASS**

| Check | Result | Notes |
|-------|--------|-------|
| Silhouette | **PASS** | Four distinct masses L→R: tiered shipper stack, potted plant, four-leg stool, tall bin — readable at approach + interact |
| Contrast | **PASS w/ note** | Internal value splits clear (kraft/labels, ceramic/leaf, wood seat/gunmetal legs, plastic/rim). Warm cardboard + stool seat sit close to QA beige floor; shop floor is medium-gray tile per VISUAL_DIRECTION — not a décor fail |
| Affordance | **PASS** | Overflow shippers, greenery, seating stool, trash read immediately; stool is décor-only per IMPORT_NOTES (not MVP interact target) |
| Materials / no cel ink | **PASS** | Soft bevels (~2.2–2.5 mm); matte wood / kraft / ceramic / gunmetal / plastic; **no cel/ink outlines** — outline S3 stays closed |
| Footprint / pivot | **PASS** | Authored min_z=0; bottom-center pivots; shadows originate at bases in both shots; mesh budgets within IMPORT_NOTES caps |
| Camera package | **PASS w/ note** | Approach + interact present; **no far** shot (optional polish, same as A13) |

No S1/S2. No open S3 (cel ink).

## Shot observations
- **Interact:** Clean lineup; shipper labels, plant leaf mass, stool cross-brace, and bin lid/segmentation all hold at counter distance.
- **Approach:** Silhouettes remain distinct; lighting casts soft ground contact shadows confirming floor snaps.
- Relative scale coherent for light filler décor (stool ~seat height; plant/bin ~0.45–0.5 m; shipper stack tallest mass).

## Notes for Art / PM
- Clear for Art to place light décor on sales floor / counter ends / backstock overflow per IMPORT_NOTES tips.
- Optional polish (non-blocking): far (8–12 m) package under warmed shell lights; confirm kraft/wood albedo still separates on medium-gray commercial tile.
- B04 is a single combined mesh (not separate boxes) — Eng place as one décor unit.
- Matches cozy-serious filler bar in `art/VISUAL_DIRECTION_MVP.md` (stools / plants / trash / crates).
