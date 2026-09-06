# Art V1 Security Camera — spot-check (`prop_security_camera_01`)

**Scorer:** CSS QA (Art executor)  
**Date:** 2026-09-06 (~6:45 PM ET)  
**Tip / PR:** `481c1c169104caf5255fe98fd5dde7337a396433` (short `481c1c16`) — PR #52 `cursor/v1-security-camera-460b` (OPEN)  
**Title:** Art V1: thin security camera prop (dual-track)  
**SoT:** `docs/art/V1_SECURITY_CAMERA_MVP.md` (+ fixture `IMPORT_NOTES.md`, `_build_stats.txt`)  
**Scope:** Thin Art dual-track hero GLB only. Soft catalog **CLOSED** (U1). Soft far crest (J2 badge) stays **Art later** — not this PR. Eng stub-swap / economy / `shop_floor.tscn` / GDScript **hold** (separate).  
**Checkout:** `/workspace/qa-playtest/art-v1-481c1c16/` (detached HEAD @ tip)  
**Evidence crops:** `/workspace/card-shop-qa/evidence/art-v1-481c1c16/`  
**Prior pattern:** L1 Large shell / J2 studio-PBR rasters of GLB (not Godot viewport)

### Shots reviewed (`docs/art/qa-shots/`)
| Shot | SHA-256 prefix | Role |
|------|----------------|------|
| `CAM_security_alone.png` | `2bd2f2d66a4dc7f6` | Mount pivot + look +Z (worm's-eye on tan plate) |
| `CAM_security_approach.png` | `37a2327e81ea7eda` | Ceiling Medium aisle approach ~2.7 m |
| `CAM_security_interact.png` | `78a5221d46ec22f5` | Ceiling Medium aisle interact ~1.4 m |
| `CAM_security_wall.png` | `daddb21ca5d41531` | Wall mount recipe Y=180° / X=−90° @ Y≈2.40 |

**Note:** Stills are studio PBR rasters of the GLB (same bar as J2 / Large shell) — scored against that bar, not in-engine FOV.

### Package
| Item | Path / value |
|------|----------------|
| Asset | `assets/props/shop/fixtures/prop_security_camera_01/prop_security_camera_01.glb` (37152 B) |
| Builder | `build_security_camera.py` |
| IMPORT_NOTES | Present — scale, MOUNT pivot, materials, Eng visibility-only tip |
| `_build_stats.txt` | `width=0.1240` `depth=0.1819` `height=0.1840` `verts=996` `tris=332` `materials=Metal,Plastic,Glass` `pivot=mount_attach` `hang=-Y` `look=+Z` |
| Render tool | `tools/art/render_security_camera_qa_shots.py` |
| Commit | `481c1c1 art(v1): subdivide camera QA stills so ceiling reads` |
| PR files | 11 Art-only paths (no `.gd`, no `shop_floor.tscn`, no economy/balance/events) |

---

## Executive verdict

| # | Pass bar | Result | Evidence |
|---|----------|--------|----------|
| 1 | Scale: body ~0.12 m dia (0.10–0.18); AABB ~0.124×0.182×0.184 m; tris ≤400 (claim 332) | **PASS** | Measured GLB AABB **0.124 × 0.184027 × 0.181922** (W×H×D) ≡ SoT **0.124 × 0.182 × 0.184** (W×D×H); Plastic barrel r=0.058 → dia **0.116 m** in class; **996 verts / 332 tris** |
| 2 | Pivot MOUNT (attach-plate top center, hang −Y, look +Z) | **PASS** | Node identity xform; `max_y=0.0`, `min_y=−0.184027` (plate top at origin); builder/SoT look ~32° down from +Z; alone still labeled mount pivot look +Z |
| 3 | Materials: Metal gunmetal / Plastic / Glass smoked — Principled PBR, soft bevels, no cel/ink, no logos/IP | **PASS** | Metal (0.46,0.47,0.50) met 0.80 rough 0.40; Plastic (0.16,0.17,0.19) met 0 rough 0.46; Glass smoked BLEND α0.38 + `KHR_materials_transmission` 0.62; no cel/toon/unlit; no logos in stills |
| 4 | Shots readable: alone / approach / interact / wall (Y=180°, X=−90°) | **PASS** | All four SoT filenames present; alone shows plate+hang+lens; approach/interact ceiling readable; wall still captioned recipe + downward look |
| 5 | Style: cozy-but-serious retail fixture, not toyish | **PASS** | Faceted low-poly gunmetal barrel + smoked lens; soft bevel language; serious retail CCTV read, not toy |
| 6 | Soft far crest NOT in scope | **PARKED** | PR does not touch `prop_graded_case_badge_01`; SoT/IMPORT park Soft far crest Art later |
| 7 | Soft catalog closed — no economy verbs | **PARKED / CLEAN** | Docs explicitly no buy/install/economy; PR file set Art-only; visibility ACK only |

### Verdict: **PASS**

**Blockers:** none.

**Clear for Eng stub-swap / Art merge?** **YES**

Eng consume (Art does not land): when cameras **owned**, instance `prop_security_camera_01.glb` as `SecurityCamera` at ceiling underside **Y ≈ 2.80** (Medium/Large) scale `(1,1,1)`; yaw so authored **+Z** covers the volume (into shop often **Y = 180°** → look **−Z**). Wall recipe: **Y = 180°** then **X = −90°** on a +Z-facing wall; origin on wall surface; suggested height **Y = 2.35–2.50**. Toggle visibility on owned — **no** economy verbs / Soft catalog / Soft far crest in this Art pack. Glass may need a Godot transparency pass after import (IMPORT_NOTES).

---

## Measured package (GLB @ tip)

| Claim | Value |
|-------|-------|
| Unit | **1u = 1 m** |
| Body / dome class | Plastic barrel dia **0.116 m** (SoT ~0.12; class 0.10–0.18) ✓ |
| Authored AABB (SoT W×D×H) | **0.124 × 0.182 × 0.184 m** |
| Measured AABB (X×Y×Z) | **0.124 × 0.184027 × 0.181922 m** |
| AABB min…max | `(−0.062, −0.184027, −0.040)` … `(0.062, 0.000, 0.141922)` |
| Pivot | **MOUNT** — attach-plate top center; `max_y = 0` |
| Hang / look | **−Y** / authored **+Z** (~32° down) |
| Mesh budget | **996 verts / 332 tris** (≤400) ✓ |
| Node | `prop_security_camera_01` identity transform (no baked T/R/S) |
| Extensions | `KHR_materials_transmission` on Glass only; no unlit/cel |

---

## Materials (PBR)

| Name | Role | baseColorFactor | Met / Rough | Notes |
|------|------|-----------------|-------------|-------|
| Metal | Gunmetal plate, stem, joint, rear cap, lens ring | (0.46, 0.47, 0.50, 1) | 0.80 / 0.40 | Soft retail gunmetal |
| Plastic | Charcoal barrel + status pip | (0.16, 0.17, 0.19, 1) | 0 / 0.46 | Matte charcoal housing |
| Glass | Smoked lens dome | (0.10, 0.13, 0.16, 0.38) | 0.04 / 0.10 | BLEND + transmission 0.62 |

Soft bevels on builder geometry; stills show faceted soft edges, no ink outlines, no brand marks / readable IP.

---

## Shot-by-shot notes

### `CAM_security_alone.png`
Worm's-eye under tan mount plate on navy studio. Octagonal gunmetal body + stem read clearly; smoked lens faces viewer/+Z with downward bias; attach plate flush to plate top — **MOUNT pivot demonstrated**. Label: `V1 prop_security_camera_01 alone mount pivot look +Z`. **PASS.**

### `CAM_security_approach.png`
Ceiling Medium aisle ~2.7 m — compact silhouette against white ceiling, still legible as CCTV fixture; mount flush to ceiling, hang −Y, lens toward viewer. Caption: `V1 security camera ceiling Medium aisle approach ~2.7 m`. Soft nit only: small on-frame at approach distance (expected for ~0.12 m prop) — still readable. **PASS.**

### `CAM_security_interact.png`
~1.4 m interact — mount plate underside, charcoal barrel, smoked lens + soft bevels all clear; no logos/cel. Caption: `V1 security camera ceiling Medium aisle interact ~1.4 m`. **PASS.**

### `CAM_security_wall.png`
Brown wall mount; plate on wall, body into room, lens angled down. Caption documents SoT recipe `Y=180 X=-90` @ `Y=2.40 optional`. Orientation matches wall Eng tip. **PASS.**

---

## Soft / parked (non-blocking)

| Item | Disposition |
|------|-------------|
| Soft far crest (`prop_graded_case_badge_01`) | **Art later** — not reopened; not in PR file set |
| Soft catalog / economy verbs / Camera unlock cash+Att | **CLOSED / Eng hold** — Art docs forbid inventing buy/install; Eng V1 smoke already separate (`0cbef7bc`) |
| Wiring `shop_floor.tscn` / GDScript | **Hold** — Art does not land |
| Glass Godot transparency pass | Soft Eng import note (IMPORT_NOTES) — not an Art blocker |
| Approach silhouette size | Soft visual — prop is intentionally ~0.12 m; still readable |

---

## PR scope hygiene

| Check | Result |
|-------|--------|
| Tip SHA | **`481c1c169104caf5255fe98fd5dde7337a396433`** confirmed (`git rev-parse` + `gh` head_sha) |
| PR #52 files | README + `prop_security_camera_01/*` + SoT + 4 shots + render tool — **Art-only** |
| No `.gd` / economy / events / balance / Soft seed | **Clean** |
| Soft far crest untouched | **Clean** |

---

## Blockers

**None.**

---

## Report paths

1. `/workspace/card-shop-qa/art-v1-camera-481c1c16-spotcheck.md`  
2. `/workspace/card-shop-qa/docs/qa/art-v1-camera-481c1c16-spotcheck.md`  
3. Evidence: `/workspace/card-shop-qa/evidence/art-v1-481c1c16/`
