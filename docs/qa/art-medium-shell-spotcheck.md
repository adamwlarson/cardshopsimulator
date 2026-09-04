# Hero Medium shell art — spot-check (`prop_shop_shell_medium_01`)

**Scorer:** CSS QA  
**Date:** 2026-09-04 (ET)  
**Scope:** Art Lead hero Medium shell — replace Eng procedural stub; **not** fog-as-Medium.  
**Source tree:** local Art working copy `/workspace/card-shop-simulator/` (`docs/art/` + `art/` mirrors).  
**Package:** `prop_shop_shell_medium_01` (+ `SHELL_medium_*.png` qa-shots).  
**Evidence:** `/workspace/card-shop-qa/evidence/medium-shell/`  
**Related Eng smoke:** playtest Medium expand `72ffabf0` (stub 14×10 / no fog) — aisle PNG kept for language compare only.

### Shots reviewed
| Shot | Path |
|------|------|
| Approach (exterior entrance) | `evidence/medium-shell/shots/SHELL_medium_approach.png` |
| Interact (interior aisle) | `evidence/medium-shell/shots/SHELL_medium_interact.png` |
| Eng stub aisle (ref only) | `evidence/medium-shell/shots/eng_stub_medium-shell-aisle.png` |

### Pass bar (this gate)
1. Footprint **14×10 @ 0.9 m** — floor/walls extend to full Medium size  
2. Warm wood / cream materials (cozy-serious retail)  
3. **Fog NOT present** — nack fog-as-Medium  
4. Soft notes park unless blocker  

---

## Verdict: **PASS-with-notes**

| Gate | Result | Evidence |
|------|--------|----------|
| 1. Footprint 14×10 @ 0.9 m | **PASS** | `_build_stats` `footprint_tiles=14x10` `tile_m=0.9`; floor interior **12.60 × 9.00 m**; GLB AABB **12.84 × 2.87 × 9.25 m** (W×H×D, walls/trim beyond floor) |
| 2. Warm wood / cream materials | **PASS** | Exact Small palette: Wall cream `(0.78,0.74,0.68)`, Trim warm wood `(0.46,0.30,0.16)`, Ceiling warm white, Floor med gray tile; interact shot shows cream + wood base/crown |
| 3. Fog NOT present | **PASS** | No fog/veil/haze meshes, materials, or glTF keywords; clear studio PNGs; IMPORT_NOTES: “no fog” |
| 4. Soft vs blockers | **PASS** (soft only) | No blockers; soft notes parked below |

No S1/S2. Clear for Eng to wire GLB swap per IMPORT_NOTES (do **not** edit `shop_floor.tscn` from Art).

---

## Measured footprint

| Claim | Value |
|-------|-------|
| Tile lock | **0.9 m** |
| Grid | **14 × 10** tiles |
| Floor interior | **12.6 × 9.0 m** (= 14×0.9 × 10×0.9) |
| Wall height | **2.80 m** |
| GLB AABB (Y-up) | **W 12.840 × H 2.870 × D 9.250 m** |
| Pivot | Floor **southwest** corner at origin |
| vs Small | Small floor **9.0 × 7.2** (10×8); Medium correctly larger; same vert/tri budget language (480 / 880) |

Floor accessor spans X `0…12.6`, Z `−9…0` (glTF Y-up) — matches interior claim. Walls/trim extend AABB slightly beyond floor (expected).

---

## Materials (PBR) — cozy-serious retail

| Name | Role | baseColorFactor | Met / Rough | Visual |
|------|------|-----------------|-------------|--------|
| Floor | Med gray commercial tile | (0.42, 0.43, 0.45) | 0 / 0.55 | Gray slab in approach door peek |
| Wall | Cream / warm gray | (0.78, 0.74, 0.68) | 0 / 0.72 | Cream field dominant in both shots |
| Trim | Warm wood base/crown | (0.46, 0.30, 0.16) | 0 / 0.58 | Wood strips readable on interact + through door |
| TrimMetal | Soft gunmetal door frame | (0.48, 0.49, 0.51) | 0.78 / 0.40 | Door frame on approach |
| Ceiling | Soft warm white | (0.82, 0.80, 0.76) | 0 / 0.78 | Present in mesh; less framed in qa cams |

Identical material set to Small `prop_shop_shell_01` — intentional reuse (`build_shop_shell.py` “Exact Small palette”). Soft bevel ~3 mm; **no cel/ink outlines**.

Pixel warmth (interact wall/trim regions R−B ≈ **+6…+14**) reads cream/wood under studio key; approach facade is flatter (studio fill) but authored cream is correct.

---

## Fog check — **PASS (nack fog-as-Medium)**

- GLB JSON: **no** `fog` / `veil` / `haze` / `mist` / `volumetric` / `atmosphere`  
- Single mesh node `prop_shop_shell_medium_01` — floor, walls (door cutout), ceiling, wood trim, gunmetal frame only  
- IMPORT_NOTES: “no cel/ink outlines, **no fog**”  
- QA PNGs: crisp; no translucent gray planes or depth veil  
- Aligns with Eng Medium expand gate (`has_fog_veil() == false` @ `72ffabf0`)

---

## Visual score (qa-shots)

| Shot | Framing (from `render_qa_shots.py`) | Score notes |
|------|-------------------------------------|-------------|
| `SHELL_medium_approach` | Cam south of entrance `y≈−6.2`, lens 30 — exterior facade + door | Door cutout + gunmetal frame readable; cream wall; wood/floor glimpse through opening; **no fog** |
| `SHELL_medium_interact` | Just inside door looking toward back (`target y≈ FLOOR_D−0.4`), lens 42 — Medium depth aisle | Long cream wall + warm wood base/crown; soft interior fill; **no fog**; empty shell (props not in Art package) |

Studio Eevee renders (warm sun + ceiling areas) — blockout hero language, not in-engine playable aisle. Eng stub aisle PNG remains reference for fixture-filled Medium until swap lands.

---

## Import / package

| Check | Result |
|-------|--------|
| `IMPORT_NOTES.md` | Present — scale, pivot SW, Medium tile lock, Eng stub swap guidance |
| `_build_stats.txt` | Matches measured AABB / floor / tiles |
| Godot import | `godot-import-test/props/prop_shop_shell_medium_01.glb.import` + `.godot/imported/*.scn` present |
| Docs mirror | `docs/art/props/prop_shop_shell_medium_01/` + `docs/art/qa-shots/SHELL_medium_*.png` |
| Art working | `art/props/...` includes `.blend`, `build_shop_shell.py`, `render_qa_shots.py` |

---

## Soft notes (non-blocking)

1. **Approach framing is exterior-first** — full 14×10 volume is proven by GLB/build stats, not by a single top-down or corner-to-corner still. Optional Art follow-up: one high corner / plan-ish still for docs.  
2. **Studio lighting flattens cream** on approach (R−B only mildly positive vs Eng lit aisle). Authored Wall/Trim factors match Small; not a retint ask.  
3. **IMPORT_NOTES** omit an explicit `Result: SUCCESS` line (import artifacts exist). Wording polish only.  
4. **Empty shell in qa-shots** — intentional; Eng wires fixtures separately. Do not treat missing props as Art fail.  
5. **Publish** — package lives in local Art tree (`docs/art` + `art` mirrors). Push/PR when ready so Eng/QA clones match this evidence set.  
6. **Floor remains med gray tile** (not wood plank) — same as Small / Eng stub language; warm wood is trim (and fixtures), cream is walls.

---

## Blockers

**None.**

---

## Gate status

- Hero Medium shell art spot-check: **PASS-with-notes**  
- Fog-as-Medium: **NACKED / closed** for this asset  
- Clear for Eng GLB instance at Medium SW grid origin (scale 1,1,1) per IMPORT_NOTES  

**Report:** `/workspace/card-shop-qa/art-medium-shell-spotcheck.md`  
**Evidence root:** `/workspace/card-shop-qa/evidence/medium-shell/`
