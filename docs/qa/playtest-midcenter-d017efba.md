# Playtest — MidCenter AABB place formal (PR #31)

**Tip:** `d017efba` (`d017efba86e06a4334aca9681abf11c9199aba6c`)  
**Date:** 2026-09-04 (~6:49–6:52 PM ET)  
**PR:** [#31](https://github.com/adamwlarson/cardshopsimulator/pull/31) — *Place Soft MidCenter AABB polish (5.40 clear of BackRight)*  
**Checkout:** `/workspace/qa-playtest/midcenter-d017efba`  
**SoT:** `docs/art/MEDIUM_OVERHEAD_LIGHTS_MVP.md` (Soft MidCenter AABB polish)  
**Method:** Godot 4.5.2 headless import + foundation `tests/test_runner.gd`; formal `tests/qa_midcenter_place_smoke.gd`  
**Harness:** 106 PASS / 0 FAIL / 1 soft  

---

## Verdict: **PASS-with-notes**

| # | Pass bar | Result |
|---|----------|--------|
| 1 | MidCenter mesh `(5.40, 2.79, -4.95)` + Omni MidCenterFill `(5.40, 2.55, -4.95)` | **PASS** — placed + visible on Medium; Omni color `(1.0, 0.83, 0.66)`, energy **1.65**, range **7.0**, atten **1.2**, shadows off |
| 2 | BackRight untouched at `(6.75, 2.79, -4.95)` | **PASS** — mesh + Fill XZ/Y unchanged; still visible on Medium |
| 3 | dX MidCenter↔BackRight = **1.35 m**; MidCenter ≠ BackRight (distinct nodes) | **PASS** — `same_instance: false`; shared mid-row Z=−4.95 |
| 4 | Tier-gate: Small **5** / Medium **11** (5+6); extras hidden on Small | **PASS** — meshes/fills 5→11; all six Medium extras hidden pre-Sign |
| 5 | Fog nack | **PASS** — `has_fog_veil()==false`; no MediumVeilX/Z; env fog + volumetric off |
| 6 | Soft teal polo parked (OOS) | **Noted** — non-blocking |

**Foundation:** `All foundation tests passed.` (includes `_test_medium_overhead_lights` MidCenter 5.40 + dX 1.35 asserts)  
**Clear for merge?** **Yes** — soft teal polo parked only.

---

## Checklist (detail)

### 1 — MidCenter place
- [x] Mesh `(5.40, 2.79, -4.95)` on `Fixtures/OverheadLights/MidCenter`
- [x] OmniFill `(5.40, 2.55, -4.95)` on `MidCenterFill`
- [x] Omni recipe matches densify SoT (color / energy / range / atten / shadows off)
- [x] Visible only when tier=MEDIUM (hidden on Small)

### 2 — BackRight untouched
- [x] Mesh `(6.75, 2.79, -4.95)` — Small KEEP, unchanged
- [x] Fill `(6.75, 2.55, -4.95)` — unchanged
- [x] No rename / rescale / translate of Small nodes

### 3 — Separation
- [x] Distinct node instances (`MidCenter != BackRight`)
- [x] dX = **1.35 m** (was 0.45 m densify soft park)
- [x] Coplanar mid-row Z=−4.95

### 4 — Tier visibility
- [x] pre-Sign / new game: mesh count 5, fill count 5; Medium extras hidden
- [x] Sign lease → Medium: meshes 11, fills 11; MidCenter + other +5 extras visible
- [x] Remaining Medium extras SoT intact (FarFront/FarBack/DeepLeft/DeepCenter/DeepRight); Small KEEP SoT intact

### 5 — Fog nack
- [x] `ShopFloorExtent.has_fog_veil() == false`
- [x] No `MediumVeilX` / `MediumVeilZ`
- [x] `WorldEnvironment` fog_enabled / volumetric_fog_enabled false

### 6 — Soft teal polo
- [x] Parked OOS — soft note only; do not FAIL / do not recolor

---

## Soft notes (non-blocking)

1. **Soft teal polo** — OOS / parked; outside MidCenter AABB place scope. Do not FAIL.

---

## Evidence

| Artifact | Path |
|----------|------|
| Import log | `/workspace/card-shop-qa/evidence/midcenter-d017efba/import.log` |
| Foundation log | `/workspace/card-shop-qa/evidence/midcenter-d017efba/foundation.log` |
| Smoke log | `/workspace/card-shop-qa/evidence/midcenter-d017efba/smoke.log` |
| Smoke JSON | `/workspace/card-shop-qa/evidence/midcenter-d017efba/smoke.json` |
| Harness | `tests/qa_midcenter_place_smoke.gd` (+ copy `/workspace/card-shop-qa/qa_midcenter_place_smoke.gd`) |
| Checkout | `/workspace/qa-playtest/midcenter-d017efba` @ `d017efba86e06a4334aca9681abf11c9199aba6c` |

---

## Blockers

**None.**

---

## Clear for merge?

**Yes** — formal MidCenter AABB place smoke green on tip `d017efba`. Soft teal polo remains parked.
