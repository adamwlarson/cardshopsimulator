# Heavy décor spot-check — B09 play table + B01 slab case + B06 window + B07 back-office
**Scorer:** CSS QA  
**Date:** 2026-09-04 (America/New_York)  
**Source tip:** branch `cursor/p1-heavier-decor-assets` @ `4295040` (props + IMPORT_NOTES; not yet on `main`)  
**Local mirror / shots:** `/workspace/card-shop-simulator/docs/art/qa-shots/` + `art/props/`  
**Evidence copy:** `/workspace/card-shop-qa/evidence/b09/`  
**Art SoT:** `docs/art/VISUAL_DIRECTION_MVP.md` (cozy-serious stylized-real; soft bevel + PBR; **no heavy cel/ink outlines**)

| Art ID | Stem | Claimed extents (W×D×H m) | GLB measured | Tris (notes / GLB) | Pivot | Godot import |
|--------|------|---------------------------|--------------|--------------------|-------|--------------|
| B09 | `prop_play_table_01` | 1.800 × 1.800 × 0.761 (2×2 @ 0.9) | **1.800 × 1.800 × 0.761** | **1012 / 1012** | bottom-center (minY=0, midXZ=0) | **SUCCESS** (`.glb.import` + `.godot/imported/*.scn`) |
| B01 | `prop_display_case_slab_01` | 1.800 × 0.900 × 1.120 (2×1) | **1.800 × 0.900 × 1.120** | **1760 / 1760** | bottom-center | **SUCCESS** |
| B06 | `prop_window_01` | 1.800 × 0.113 × 1.300 | **1.800 × 0.113 × 1.300** | **748 / 748** | back-center wall mount (back Z≈0; height centered) | **SUCCESS** |
| B07 | `prop_back_office_glimpse_01` | 0.880 × 0.880 × 1.520 (≤1×1) | **0.880 × 0.880 × 1.520** | **1056 / 1056** | bottom-center | **SUCCESS** |

PBR materials present on all four (Principled metallic-roughness names match IMPORT_NOTES). Authored claim **no cel/ink** holds in shots (soft edge response only).

## Verdict: **PASS**

| Asset | Result | Notes |
|-------|--------|-------|
| **B09** `prop_play_table_01` | **PASS** | Primary bar: play surface readable at interact + approach. Wood apron vs inset playmat contrast is clear; square 2×2 mass / sitting height reads correctly; floor contact shadow confirms bottom-center pivot. 1012 tris matches claim. |
| **B01** `prop_display_case_slab_01` | **PASS-with-notes** | Scale/pivot/glass+metal+wood cabinet coherent with cozy-serious retail; sits flush on floor. Slab/graded front trim + richer felt/risers are present in mesh/mats but **subtler under this QA interact light** than the A04 dark-shelf contrast — not a fail for companion case. |
| **B06** `prop_window_01` | **PASS** | Wall-mount correct: back-center, sill depth casts contact shadow, 2×2 wall span proportions, gunmetal outer + wood liner + 4 clear panes; no cel ink / broken normals. |
| **B07** `prop_back_office_glimpse_01` | **PASS** | Compact 1×1 glimpse scale; desk + pedestal + shelf clutter + cool screen silhouette readable; bottom-center floor snap; fits backstock doorway dressing brief. |

No S1/S2. No open S3 (cel ink). Outline S3 stays closed (consistent with light-décor / B02–B03 bars).

## Shot observations
- **B09 interact** (`B09_play_table_interact.png`): Eye-height aisle/interact (~2.6 m look). Inset playmat field is a continuous readable plane vs wood rail; corner cup wells / metal feet readable as small accents. Under bright QA env, authored burgundy felt albedo lifts toward warm coral — **relative** mat readability still strong.
- **B09 approach** (`B09_play_table_approach.png`): ~4.2 m. Silhouette remains a clear 2×2 play island; playmat vs frame separation holds (primary bar still met).
- **B01 interact** (`B01_slab_case_interact.png`): Glass upper + wood base + metal frame read retail-correct. Horizontal metal face division visible; interior liner/risers do not pop as hard as A04’s dark product plane in this capture package.
- **B06 interact** (`B06_window_interact.png`): Head-on wall mount; mullions + sill depth clear; glass alpha shows wall behind — day/night-ready blockout.
- **B07 interact** (`B07_back_office_interact.png`): High-angle compact office unit; monitor emissive cool, binders/box/paper/mug clutter distinct; footprint visually ≤1 tile.

## Soft notes (non-blocking)
1. **Capture lighting wash:** Heavy-décor QA shots use a bright neutral env; authored dark burgundy felt (B09/B01) and warm oak read lighter/coral-beige than IMPORT baseColor factors. Recommend one follow-up package under warmed shell lights (same bar as light-décor optional polish) before art lock.
2. **B01 distinctness vs A04:** Mesh/IMPORT advertise slab trim + richer felt + risers + plaque; interact still reads mostly as “taller glass case + wood base.” Optional: tighter interact FOV or slight interior fill so graded trim/risers are unmistakable at counter distance.
3. **B06 package:** Interact-only (no approach/far) — acceptable for wall décor, same light-P1 pattern as B02/B03.
4. **Landing path:** Props live under `assets/props/shop/fixtures/` on branch `cursor/p1-heavier-decor-assets`; local Art Lead mirror also has `docs/art/props/` + `art/props/`. Not on `main` tip as of this check — Eng should merge/path-align before floor placement.
5. **2.5 mm soft bevels** are claimed; at capture distance they read as clean hard-ish edges (expected) — not a cel-ink fail.

## Evidence paths
| File | Path |
|------|------|
| Report | `/workspace/card-shop-qa/art-b09-plus-spotcheck.md` |
| Shots | `/workspace/card-shop-qa/evidence/b09/B09_play_table_interact.png` |
| | `/workspace/card-shop-qa/evidence/b09/B09_play_table_approach.png` |
| | `/workspace/card-shop-qa/evidence/b09/B01_slab_case_interact.png` |
| | `/workspace/card-shop-qa/evidence/b09/B06_window_interact.png` |
| | `/workspace/card-shop-qa/evidence/b09/B07_back_office_interact.png` |
| Props (GLB + IMPORT_NOTES + `_build_stats`) | `/workspace/card-shop-qa/evidence/b09/props/{prop_play_table_01,prop_display_case_slab_01,prop_window_01,prop_back_office_glimpse_01}/` |

Clear for Art to place: B09 as 2×2 path-blocking event table; B01 as 2×1 companion to A04; B06 wall-mount like posters; B07 behind A13 backstock door as 1×1 glimpse.
