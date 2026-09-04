# Fixture placement spot-check — main after PR #4
**Scorer:** CSS QA  
**Date:** 2026-09-04 (ET)  
**Repo tip:** `76d00d02` (merge PR #4) — scene blob `51e14e84` matches facing-fix tip `a012875`  
**Scene:** `scenes/shop/shop_floor.tscn` (sparse-fetched; no full clone)  
**Evidence:**
- `/workspace/card-shop-simulator/pr4-review/shop_fixture_layout.webp` (+ `.png`) — PR #4 cloud-agent artifact `bc-5aead57d…` / `afc33.webp` (SHA `801cf5f0…`, 40102 B)
- Scene text on main for facing rotations
- Reference asset shots (style only): `pr4-review/B02_posters_interact.png`, `B03_signage_interact.png`, `combo_shopcam.png`, `A13_approach.png`, `A02_A05_combo.png`

## Verdict: **PASS-with-notes**

| Check | Result | Notes |
|-------|--------|-------|
| Facing fix on main (posters / OpenClosedSign / PriceTag Y=0) | **PASS** | All five nodes `rotation_degrees = Vector3(0, 0, 0)`; positions unchanged |
| Fixtures inside shell | **PASS** | Layout shot + positions within ~10×8 shell; no exterior floaters |
| 0.9 m grid | **PASS** | Floor props on 0.9 multiples (e.g. 1.35/1.8/4.5/7.2/−3.6/−6.75/−7.2) |
| Posters face into room | **PASS** | Main scene Y=0; layout shot predates this fix (see notes) |
| Entrance / sign readable | **PASS** | Door + OpenClosedSign at front Z=0; Y=0 so OPEN reads street-side |
| Sealed-wall pegs toward aisle | **PASS** | SealedWall unrotated after agent correction; stocked face toward +Z aisle |
| Lights under ceiling | **PASS** | 4× overhead at Y=2.79 under shell ceiling |
| No cel/ink; cozy stylized-real | **PASS** | Layout + prior asset shots; soft bevels / wood-gunmetal, no outlines |
| Overlap / blocking facing | **PASS** | No hard overlap; sparse proxies intentional |

## Facing confirmation (main `shop_floor.tscn`)
- `PosterLarge` / `PosterMedium` / `PosterSmall` @ Z=-7.2 → **Y=0**
- `OpenClosedSign` @ (4.5, 1.62, 0) → **Y=0**
- `PriceTag` @ (1.8, 1.35, -6.3) → **Y=0**

## Soft notes
1. **Layout artifact timing:** `shop_fixture_layout.webp` was captured after sealed-wall/FOV correction but **before** the Art facing commit (`a012875`). Use scene text on main as source of truth for poster/sign/tag Y rotations; do not treat the webp as post-facing proof.
2. **Framing:** In-scene camera FOV 90 still crops some volume (not all four overheads equally prominent); layout remains readable.
3. **Sparse décor:** Empty case / light P1 only — heavier décor held; not a fail.
4. **cursor.com download:** Direct curl to the artifacts URL returned HTML (auth wall); bytes recovered from watched computer-use transcript (same SHA/size as listed artifact).

## Art follow-up
**None expected.** Facing corrections already merged; no new overlap/facing S1. Heavier décor remains deferred.

## Paths
- Doc: `/home/box/agent-data/projects/card-shop-simulator/docs/qa/art-fixture-placement-main-spotcheck.md`
- Shots: `/workspace/card-shop-simulator/pr4-review/` (`shop_fixture_layout.webp`/`.png`, reference asset PNGs, `shop_floor.tscn`)
- Workspace `docs/qa/` tree: **absent** — no mirror written
