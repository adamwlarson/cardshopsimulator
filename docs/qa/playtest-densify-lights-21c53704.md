# Playtest — Densify Medium overhead lights formal (PR #27)

**Tip:** `21c53704` (`21c5370412dea53b979cee153c5f73a15c6a5d03`)  
**Date:** 2026-09-04 (ET)  
**PR:** [#27](https://github.com/adamwlarson/cardshopsimulator/pull/27) — *Densify Medium overhead lights (tier-gated 5+6)*  
**Checkout:** `/workspace/qa-playtest/densify-21c53704`  
**SoT:** `docs/art/MEDIUM_OVERHEAD_LIGHTS_MVP.md`  
**Method:** Godot 4.5.2 headless import + foundation `tests/test_runner.gd`; formal `tests/qa_densify_lights_smoke.gd` under xvfb  
**Harness:** 667 PASS / 0 FAIL / 1 soft  

---

## Verdict: **PASS-with-notes**

| # | Pass bar | Result |
|---|----------|--------|
| 1 | Small 5 locked at SoT (FrontLeft/FrontRight/BackLeft/BackRight/BackLeftAisle) | **PASS** — positions + scale 1,1,1 + Omni fills unchanged |
| 2 | Medium +6 extras + Omni fills @ SoT when tier=MEDIUM | **PASS** — MidCenter / FarFront / FarBack / DeepLeft / DeepCenter / DeepRight; Omni color `(1.0, 0.83, 0.66)`, energy **1.65**, range **7.0**, atten **1.2**, shadows off |
| 3 | Tier-gate: Small/Stay Small/pre-Sign = 5; Sign→Medium = 11+11; Stay hides; save/load restores | **PASS** — mesh/fill counts 5→11→5→11 via `ShopFloorExtent` |
| 4 | MidCenter ≠ BackRight (distinct nodes; X 6.30 vs 6.75 @ Z=−4.95) | **PASS** — separate instances; do not merge |
| 5 | Fog nack — no volumetric fog / fog volumes | **PASS** — `has_fog_veil()==false`; env fog + volumetric off |
| 6 | Soft MidCenter X share parked (intentional densify AABB) | **Noted** — non-blocking |
| 7 | Camera aisle + behind-desk SoT + FOV 70; no #24 Specialist / #25 Medium shell regress | **PASS** — aisle `(4.5, 1.65, -1.8)`, behind-desk `(7.2, 1.6, -0.65)`, FOV 70; Specialist inspect 5→2; Medium shell visible / stub gone |

**Foundation:** `All foundation tests passed.` (includes `_test_medium_overhead_lights` densify asserts)  
**Clear for merge?** **Yes** — soft MidCenter parked only.

---

## Checklist (detail)

### 1 — Small 5 locked
- [x] FrontLeft `(2.25, 2.79, -2.25)` + Fill Y=2.55
- [x] FrontRight `(6.75, 2.79, -2.25)`
- [x] BackLeft `(2.25, 2.79, -4.95)`
- [x] BackRight `(6.75, 2.79, -4.95)`
- [x] BackLeftAisle `(2.8, 2.78, -5.4)`
- [x] All Small meshes/fills visible on Small + Medium; scale ONE

### 2 — Medium +6 + Omni recipe
| Node | Mesh | Omni |
|------|------|------|
| MidCenter | (6.30, 2.79, -4.95) | (6.30, 2.55, -4.95) |
| FarFront | (10.35, 2.79, -2.25) | same XZ, Y=2.55 |
| FarBack | (10.35, 2.79, -4.95) | same XZ, Y=2.55 |
| DeepLeft | (2.25, 2.79, -7.20) | same XZ, Y=2.55 |
| DeepCenter | (6.30, 2.79, -7.20) | same XZ, Y=2.55 |
| DeepRight | (10.35, 2.79, -7.20) | same XZ, Y=2.55 |

- [x] All 11 Omni: color / energy / range / atten / shadows off
- [x] Same `prop_light_overhead_01` GLB — no new overhead mesh

### 3 — Tier visibility
- [x] pre-Sign / new game: `visible_overhead_mesh_count()==5`, fills==5, extras hidden
- [x] Sign lease → Medium: meshes==11, fills==11, `is_medium_overhead_visible()==true`
- [x] Stay Small after Medium path: extras hide; Small 5 remain
- [x] save Medium → new game hide → restore_save → extras + shell return (11/11)

### 4 — MidCenter identity
- [x] Distinct node from BackRight (`same_instance: false`)
- [x] MidCenter X=6.30 vs BackRight X=6.75 @ Z=−4.95

### 5 — Fog nack
- [x] No `MediumVeilX` / `MediumVeilZ`
- [x] `WorldEnvironment.fog_enabled` / `volumetric_fog_enabled` false

### 7 — Camera + regress
- [x] `ShopCamera.HOME_FOV == 70`
- [x] Aisle + behind-counter homes match SoT consts
- [x] #25: Medium Art shell visible, Small hidden, stub gone on Medium
- [x] #24: Specialist wage $140, inspect Att 5→2, rearrange 10, survives expand, staff_cap 3

---

## Soft notes (non-blocking)

1. **Soft MidCenter X share** — MidCenter X=6.30 sits **0.45 m** from BackRight on Z=−4.95; mesh AABB overlap is intentional densify. **Parked — do NOT FAIL.** Optional Eng nudge of MidCenter only later; never move Small BackRight.

---

## Evidence

| Artifact | Path |
|----------|------|
| Import log | `/workspace/card-shop-qa/evidence/densify-21c53704/import.log` |
| Foundation log | `/workspace/card-shop-qa/evidence/densify-21c53704/foundation.log` |
| Smoke log | `/workspace/card-shop-qa/evidence/densify-21c53704/smoke.log` |
| Smoke JSON | `/workspace/card-shop-qa/evidence/densify-21c53704/smoke.json` |
| Optional aisle still | `/workspace/card-shop-qa/evidence/densify-21c53704/densify-medium-aisle.png` |
| Harness | `tests/qa_densify_lights_smoke.gd` (+ copy `/workspace/card-shop-qa/qa_densify_lights_smoke.gd`) |

---

## Blockers

**None.**

---

## Clear for merge?

**Yes** — formal densify placement smoke green on tip `21c53704`. Soft MidCenter X share remains parked.
