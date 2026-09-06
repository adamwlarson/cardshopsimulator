# L1 Art Large shop shell — spot-check (`prop_shop_shell_large_01`)

**Scorer:** CSS QA (Art executor)  
**Date:** 2026-09-06 (ET)  
**Tip / PR:** `91e2020ade57cdb9441a07a2ea15df519f465ca3` — PR #40 `cursor/large-shell-assets-7b73` (OPEN)  
**SoT:** `docs/art/LARGE_SHELL_MVP.md` (+ fixture `IMPORT_NOTES.md`, `_build_stats.txt`)  
**Scope:** Large shop shell hero GLB — 18×13 @ 0.9 m / ~2,040 sq ft. Soft far crest thin + Soft `_ensure_priceable_sku` **PARKED (OOS)**.  
**Checkout:** `/workspace/qa-playtest/l1-art-shell-91e2020a/` (detached HEAD @ tip)  
**Evidence crops:** `/workspace/card-shop-qa/evidence/l1-large-shell/`  
**Prior pattern:** Medium shell spot-check; J2 PBR still bar (studio rasters of GLB, not Godot viewport)

### Shots reviewed (`docs/art/qa-shots/`)
| Shot | SHA-256 prefix | Role |
|------|----------------|------|
| `SHELL_large_far.png` | `61ad5dd4a1237ebb` | Elevated 3/4 volume + label (18×13 / 16.2×11.7 / ~2040) |
| `SHELL_large_approach.png` | `de8778197af0973c` | South facade + 1.0×2.10 door |
| `SHELL_large_interact.png` | `17168c2acc106bb1` | Interior aisle cream + wood |
| `SHELL_medium_vs_large.png` | `c755a3f284049382` | Medium 14×10 (L) vs Large 18×13 (R), same SW pivot / palette |

**Note:** Stills are studio PBR rasters of the GLB (same bar as J2 / Medium shell) — scored against that bar, not in-engine FOV.

### Package
| Item | Path / value |
|------|----------------|
| Asset | `assets/props/shop/fixtures/prop_shop_shell_large_01/prop_shop_shell_large_01.glb` |
| Builder | `build_shop_shell.py --size=large` |
| IMPORT_NOTES | Present — scale, SW pivot, tile lock, Eng stub-swap one-liner |
| `_build_stats.txt` | `footprint_tiles=18x13` `tile_m=0.9` `floor_w/d=16.2/11.7` `wall_h=2.80` `fog=none` |
| Commit | `91e2020 art(L1): Large shop shell GLB (18×13 / ~2040 sq ft)` |

---

## Executive verdict

| # | Pass bar | Result | Evidence |
|---|----------|--------|----------|
| 1 | Footprint/scale larger than Medium; vs-shot clear size step (14×10 → 18×13) | **PASS** | `_build_stats` 18×13 @ 0.9 m; floor **16.2 × 11.7 m** (~2040 sq ft); GLB AABB **16.44 × 2.87 × 11.95 m**; vs-shot labels Medium 14×10 (L) vs Large 18×13 (R) — clear width/depth step |
| 2 | Silhouette / affordance at far / approach / interact | **PASS** | Far: readable shop cuboid volume; Approach: south door cutout + gunmetal frame; Interact: long cream aisle + warm wood base/crown |
| 3 | Materials = Medium warm retail palette; Principled-only; no cel/ink; no fog mesh | **PASS** | Exact Floor/Wall/Trim/TrimMetal/Ceiling factors match Medium; `pbrMetallicRoughness` only; no extensions; glTF keywords fog/cel/ink/unlit **absent**; `_build_stats fog=none` |
| 4 | Pivot/axes SoT (SW floor corner; extents 16.2×11.7) | **PASS** | Floor POSITION X `0…16.2`, Z `−11.7…0`, Y top `0`; walls/trim beyond (±0.12); door faces +Z (opening X 7.60…8.60); node identity transform (scale 1,1,1); ceiling ~2.80 |
| 5 | All 4 required shots present | **PASS** | All four SoT filenames under `docs/art/qa-shots/` |
| 6 | Soft far crest + Soft `_ensure_priceable_sku` | **PARKED** | OOS — do not FAIL |

### Verdict: **PASS**

**Blockers:** none.

**Clear for Eng stub-swap / Art merge?** **YES**

Eng consume (Art does not land): when `tier=LARGE`, hide Small/Medium shells; instance `prop_shop_shell_large_01.glb` as `Architecture/ShopShellLarge` at SW origin, scale `(1,1,1)`. Do **not** edit `shop_floor.tscn` from Art. Fog/scaffold interim Eng-only — must not ship as hero.

---

## Measured footprint

| Claim | Value |
|-------|-------|
| Tile lock | **0.9 m** |
| Grid | **18 × 13** tiles |
| Floor interior | **16.2 × 11.7 m** |
| Interior area | 189.54 m² ≈ **2,040 sq ft** (`sq_ft_eng_tiles=2040.1875`) |
| Wall / ceiling | **2.80 m** (AABB H ≈ 2.87 incl. slab/ceiling thickness) |
| Door | **1.0 × 2.10 m**, centered X **7.60…8.60** on front (+Z) |
| GLB AABB (Y-up) | **W 16.440 × H 2.870 × D 11.950 m** (`min (−0.12,−0.04,−11.82)` … `max (16.32,2.83,0.13)`) |
| Pivot | Floor **southwest** corner at origin; grow **+X / −Z** |
| vs Medium | Medium floor **12.6 × 9.0** (14×10); Large correctly larger on both axes |
| Mesh budget | 2772 verts / 924 tris; soft bevel 3 mm |

Floor accessor spans X `0…16.2`, Z `−11.7…0` — matches SoT interior claim. Walls/trim/ceiling extend AABB slightly beyond floor (expected, same Medium language).

---

## Materials (PBR) — cozy-serious retail (exact Medium)

| Name | Role | baseColorFactor | Met / Rough | Visual |
|------|------|-----------------|-------------|--------|
| Floor | Med gray commercial tile | (0.42, 0.43, 0.45) | 0 / 0.55 | Gray slab through door / interact floor |
| Wall | Cream / warm gray | (0.78, 0.74, 0.68) | 0 / 0.72 | Cream field dominant far / approach / interact |
| Trim | Warm wood base/crown | (0.46, 0.30, 0.16) | 0 / 0.58 | Wood strips on interact + door peek |
| TrimMetal | Soft gunmetal door frame | (0.48, 0.49, 0.51) | 0.78 / 0.40 | Door frame on approach |
| Ceiling | Soft warm white | (0.82, 0.80, 0.76) | 0 / 0.78 | Far roof plane; less framed on approach |

Generator string: `CSS shop-shell builder (glTF 2.0, Principled/PBR, --size flag)`. Soft bevel ~3 mm; **no cel/ink outlines**.

---

## Fog / cel check — **PASS**

- GLB JSON: **no** `fog` / `veil` / `haze` / `mist` / `volumetric` / `atmosphere` / `cel` / `toon` / `ink` / `outline` / `unlit` / `KHR_materials_unlit`
- Single mesh node `prop_shop_shell_large_01` — Floor, Wall, TrimMetal, Trim, Ceiling only
- IMPORT_NOTES + SoT: “no cel/ink … **no fog**”; `_build_stats fog=none`
- QA PNGs: crisp studio PBR; no translucent veil planes

---

## Visual score (qa-shots)

| Shot | Framing | Score notes |
|------|---------|-------------|
| `SHELL_large_far` | Elevated 3/4 of full volume | Shop cuboid readable; door as dark vertical cut; label locks 18×13 / 16.2×11.7 / ~2040; **thin roof/wall crest** visible → Soft far crest **PARKED** |
| `SHELL_large_approach` | South facade, door-centered | 1.0×2.10 opening + gunmetal frame readable; cream wall; wood/floor peek through opening; **no fog** |
| `SHELL_large_interact` | Interior corner aisle eye-level | Long cream walls + warm wood base/crown; med gray floor; empty shell (props OOS); depth reads Large |
| `SHELL_medium_vs_large` | Side-by-side same SW pivot | Clear size step Medium→Large on width + depth; same cream palette; doors face +Z; caption confirms 14×10 vs 18×13 |

Studio PBR stills — blockout hero language, not playable Eng aisle. Empty shell intentional.

---

## Soft notes (non-blocking / parked)

1. **Soft far crest thin** — **PARKED (OOS)**. Far still shows a thin bright roof/wall edge; affordance carried by approach/interact + measured extents. Do not FAIL.  
2. **Soft `_ensure_priceable_sku`** — **PARKED (OOS)**. Not this Art package. Do not FAIL.  
3. Vs-shot Medium roof reads darker than Large under studio fill (camera/lighting on ceiling plane); authored Ceiling factors identical — not a retint ask.  
4. Approach framing is exterior-first (same Soft pattern as Medium) — full 18×13 proven by GLB/build stats + far/vs shots.  
5. Large overhead densify / `shop_floor.tscn` wiring / economy verbs — SoT §7 parked; Eng stub-swap is the consume path.

---

## Blockers

**None.**

---

## Gate status

- L1 Art Large shell spot-check: **PASS**  
- Soft far crest thin: **PARKED**  
- Soft `_ensure_priceable_sku`: **PARKED**  
- Clear for Eng stub-swap / Art merge: **YES**

**Report:** `/workspace/card-shop-qa/art-l1-large-shell-91e2020a-spotcheck.md`  
**Docs mirror:** `/workspace/card-shop-qa/docs/qa/art-l1-large-shell-91e2020a-spotcheck.md`  
**Evidence root:** `/workspace/card-shop-qa/evidence/l1-large-shell/`

## Merge

Merged to main as **PR #40** @ `dd20a70141fcc847c7e137a2565b4f751c969641` (2026-09-06). Eng wire follows after #39 economy merge.
