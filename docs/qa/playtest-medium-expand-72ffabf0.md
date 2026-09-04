# Playtest report — Medium expand / pathing / save smoke @ `72ffabf0` (PR #21)

**Date:** 2026-09-04 (ET)  
**Tip SHA:** `72ffabf02d63b74366cec5657d6d5aaf22b62c91` (short `72ffabf0`)  
**PR:** [#21](https://github.com/adamwlarson/cardshopsimulator/pull/21) — *Option B: Medium Sign lease grows the shop floor 10×8 → 14×10*  
**Parents:** `661182e2` (feature tip) + `ea940fb6` (docs merge on main) — same code as **661182e2 + docs merge**  
**Repo extract:** `/workspace/qa-playtest/tip21c/` (GitHub tarball `72ffabf0`)  
**Method:** Godot 4.5.2 headless — foundation `tests/test_runner.gd` + formal `tests/qa_medium_expand_smoke.gd` under xvfb; aisle viewport PNG  
**Design SoT:** `docs/design/next-eng-sot-pick-v1.md` Option B; systems-design §7/§10 #9; `shop_floor_extent.gd` stub shell

---

## Verdict: **PASS-with-notes**

Formal expand/pathing/save smoke on Normal at tip `72ffabf0` clears the pass bar. Foundation suite green. Soft notes are the parked `usable_sq_ft` documentation (explicitly non-blocking) plus a Medium-vs-Small rearrange cell note.

| Gate | Result |
|------|--------|
| 1. Medium shell **14×10 @ 0.9 m** stub floor/walls — **NOT fog** | **PASS** |
| 2. Pathing refuse on illegal / blocked circulation after expand | **PASS** |
| 3. `staff_cap` / rent update correctly for Medium | **PASS** |
| 4. Save-load preserves expand state | **PASS** |
| 5. Soft `usable_sq_ft` comment parked — non-blocking | **PASS** (soft) |
| §10 #9 Sign / Wait / Stay options still present | **PASS** |

**Harness:** 96 PASS / 0 FAIL / 2 soft  
**Foundation:** `All foundation tests passed.` (includes `_test_expand_medium_beat` + `_test_medium_floor_growth`)

---

## Checklist (pass bar detail)

### 1 — Medium shell stub (not fog)
- [x] Consts: `MEDIUM_GRID_WIDTH/HEIGHT` = **14×10**; `ShopGrid.TILE_SIZE` = **0.9**
- [x] After Sign: grid/layout **14×10**, tile count **140**, walkable **129** (up from Small)
- [x] `ShopFloorExtent`: `MediumFloor` / ceiling / four walls / trim present
- [x] Floor mesh size ≈ **12.6 × 9.0 m** (14×0.9 × 10×0.9)
- [x] `extra_floor_tile_count() == 60` (140−80)
- [x] `has_fog_veil() == false` — no `MediumVeilX` / `MediumVeilZ`
- [x] Small Art `Architecture/ShopShell` GLB **hidden** on Medium
- [x] Aisle viewport PNG captured (gray floor / cream walls / wood trim language; no fog veil)

### 2 — Pathing refuse
- [x] Demote counter → `preview_expand_medium() == blocked_path`
- [x] `expand_to_medium(...)` **refuses**; tier stays Small; layout stays 10
- [x] After clean Sign: rearrange onto **entrance (4,0)** → `blocked_path` (layout + `rearrange_fixture`)
- [x] Note: Small’s choke `(7,1)` is **legal on Medium** (east counter approach at x=10 opens) — refuse still enforced via entrance seal / counter-unreachable expand
- [x] Circulation holds; NPC paths entrance→browse→desk and entrance→new tile `(12,8)`

### 3 — staff_cap / rent
- [x] `staff_cap()` **3** (`BalanceConfig.staff_cap_medium`)
- [x] Signed-day rent stays Small (**$1,200** / 120_000¢)
- [x] Next week / SETTLE posts Medium (**$2,400** / 240_000¢)
- [x] Lease confirm body shows old→new rent and staff caps
- [x] Medium case-slot bonus applied

### 4 — Save-load
- [x] `capture_save` / `restore_save` round-trip
- [x] Restores Medium tier, 14×10 grid/layout, staff_cap 3, lease day 18
- [x] Migrated binder at `(12,3)` preserved
- [x] Rent tier + case bonus + circulation + `floor_grid` width 14 restored

### 5 — usable_sq_ft (soft, parked)
- [x] `usable_sq_ft() ≈ 1220.625` (14×10×8.71875)
- [x] `shop_state.gd` comment documents Option B lock (~1,221 vs systems 1,200; SoT ~1,020 miscalc) — **non-blocking**

### §10 #9 beat options
- [x] Day 18 PREP starts `sec10_9_expand_medium`
- [x] Options: **Sign lease** / **Wait for Rep** / **Stay Small** (ids + labels)
- [x] Sign gated without cash/Rep; Wait when Rep low; Stay always on
- [x] Stay / Wait keep Small; Sign upgrades Medium

---

## Soft nits (non-blocking)

1. **`usable_sq_ft` parked** — tile math ~1,221 sq ft vs systems-design marketing 1,200; prior SoT ~1,020 called out as miscalc in `shop_state.gd`. Pass bar marks this soft.
2. **Medium rearrange choke shift** — foundation Small illegal cell `(7,1)` no longer blocks on Medium; entrance `(4,0)` (and expand-preview with no counter) are the refuse paths. Worth a one-line Eng note in rearrange QA so Small-only fixtures aren’t assumed.

---

## Evidence

| Artifact | Path |
|----------|------|
| Report | `/workspace/card-shop-qa/playtest-medium-expand-72ffabf0.md` |
| Harness script | `/workspace/card-shop-qa/qa_medium_expand_smoke.gd` (also `tip21c/tests/`) |
| Smoke JSON | `/workspace/card-shop-qa/evidence/medium-expand-72ffabf0/smoke.json` |
| Harness log | `/workspace/card-shop-qa/evidence/medium-expand-72ffabf0/harness.log` |
| Foundation log | `/workspace/card-shop-qa/evidence/medium-expand-72ffabf0/foundation.log` |
| Import log | `/workspace/card-shop-qa/evidence/medium-expand-72ffabf0/import.log` |
| Aisle PNG | `/workspace/card-shop-qa/evidence/medium-expand-72ffabf0/medium-shell-aisle.png` |

---

## Clear / hold

- **Clear** formal Medium expand/pathing/save smoke on Normal at `72ffabf0` (PR #21 rebased tip).
- Shell is code-driven floor/walls stub @ 14×10×0.9 m — **nack shipping fog as Medium**.
- Soft `usable_sq_ft` documentation only; does not block.
