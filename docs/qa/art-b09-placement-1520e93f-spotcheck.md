# QA — B09+ heavier décor floor placement (PR #18)

**Scorer:** CSS QA  
**Date:** 2026-09-04 (America/New_York)  
**Tip:** `1520e93f` (`1520e93f8d4076103efa88d37b59a58bc46a026e`) — PR #18 merged main  
**Repo:** https://github.com/adamwlarson/cardshopsimulator  
**Engine:** Godot 4.5.2.stable (headless import + xvfb OpenGL llvmpipe)  
**Tree:** `/workspace/qa-playtest/tip18/` (codeload tarball; not a writable git clone)  
**Scope:** Light smoke — PlayTable / SlabDisplayCase / ShopWindow / BackOfficeGlimpse on `shop_floor.tscn` at Art coords; no float/sink; camera/FOV unchanged.

## Verdict: **PASS**

| # | Pass bar | Result | Evidence |
|---|----------|--------|----------|
| 1 | PlayTable / SlabDisplayCase / ShopWindow / BackOfficeGlimpse present at Art coords (B07 specifically `(4.5, 0, -7.05)`) | **PASS** | tscn nodes + runtime SceneTree; B07 exact Art coords, Z in −7.15…−6.95 |
| 2 | No float/sink; camera/FOV unchanged (aisle SoT `(4.5, 1.65, -1.8)` / `-28` / FOV 70; Day1 behind-desk `(7.2, 1.60, -0.65)` / `-18` / 70) | **PASS** | Floor props world AABB `min_y=0.000`; window wall-mount `min_y=0.970`. Runtime cam SoT exact |
| 3 | Foundation heavier_decor placement test if runnable | **PASS** | `tests/test_runner.gd` `_test_heavier_decor_placement()` ran as part of foundation suite; **All foundation tests passed** (exit 0) |

Local SceneTree harness: **43 PASS / 0 FAIL**.

## Observed positions (runtime = tscn)

Tile = 0.9 m. All four `scale=(1,1,1)`, basis det=1.

| Art ID | Node | Stem | Position (m) | Rot ° | Tiles (x,z) | World AABB | min_y |
|--------|------|------|--------------|-------|-------------|------------|-------|
| B09 | `PlayTable` | `prop_play_table_01` | `(2.7, 0.0, -4.5)` | `(0, 0, 0)` | `(3, -5)` | P `(1.8, 0, -5.4)` S `(1.8, 0.761, 1.8)` | **0.000** |
| B01 | `SlabDisplayCase` | `prop_display_case_slab_01` | `(7.2, 0.0, -4.05)` | `(0, 0, 0)` | `(8, -4.5)` | P `(6.3, 0, -4.5)` S `(1.8, 1.12, 0.9)` | **0.000** |
| B06 | `ShopWindow` | `prop_window_01` | `(0.0, 1.62, -2.25)` | `(0, 90, 0)` | left wall | P `(0, 0.97, -3.15)` S `(0.113, 1.3, 1.8)` | 0.970 (wall-mount) |
| B07 | `BackOfficeGlimpse` | `prop_back_office_glimpse_01` | `(4.5, 0.0, -7.05)` | `(0, 0, 0)` | alcove rear | P `(4.06, 0, -7.49)` S `(0.88, 1.52, 0.88)` | **0.000** |

Adjacency (runtime): B01 shares A04 X `7.2` and sits one 0.9 m tile behind `HighValueDisplayCase` `(7.2, 0, -3.15)`. B07 shares A13 X `4.5` and sits 0.3 m behind `BackstockDoor` `(4.5, 0, -6.75)`.

`shop_floor.tscn` node names match Art/Eng: `PlayTable`, `SlabDisplayCase`, `ShopWindow`, `BackOfficeGlimpse` under `Fixtures`; Camera is Day1 behind-desk.

## Camera SoT check

| Pose | Observed pos | Observed rot ° | FOV | Match |
|------|--------------|----------------|-----|-------|
| Day1 behind-desk (tscn + `_ready`) | `(7.2, 1.6, -0.65)` | `(-18.0, 0.0, 0.0)` | `70.0` | **PASS** |
| Aisle reset (`reset_to_aisle_home`) | `(4.5, 1.65, -1.8)` | `(-28.0, 0.0, 0.0)` | `70.0` | **PASS** |

Script constants in `scripts/shop/shop_camera.gd` unchanged: `AISLE_POSITION (4.5, 1.65, -1.8)`, `AISLE_ROTATION_DEGREES (-28, 0, 0)`, `BEHIND_COUNTER_POSITION (7.2, 1.6, -0.65)`, `HOME_FOV := 70.0`. Placement PR did not mutate camera.

## Foundation test

`_test_heavier_decor_placement()` is wired in `tests/test_runner.gd` `_initialize` (line 118). Headless run:

```
/workspace/godot452 --headless --path /workspace/qa-playtest/tip18 -s res://tests/test_runner.gd
→ All foundation tests passed.  (exit 0)
```

Log: `evidence/b09-placement-1520e93f/foundation.log`.

Godot import: 28 GLBs reimported SUCCESS including the four heavier-décor stems (`.glb.import` + `.godot/imported/*.scn`). Fixtures README lists **28** props.

## Shot observations (aisle cam)

- **Aisle** (`aisle_cam.png`, 1280×720): Play table 2×2 island left-rear, flush on floor; A04+B01 case run right; A13 doorway with B07 glimpse (desk + cool monitor) readable at alcove rear. Aisle open. HUD Day1 PREP `$8,000` / Att 100. No float/sink in frame.
- **Behind-desk** (`behind_desk.png`): Day1 home; register in foreground; B09 island left, companion slab behind A04; B07 through A13. ShopWindow is left-wall at cam depth `z≈-2.25` so mostly out of aisle/behind-desk −Z FOV — confirmed by transform + AABB, not a missing instance.
- Soft (non-blocking): B06 four-pane window needs yaw-left / look-left to read in frame (same class as entrance-plane fixtures).

No S1/S2. Camera/FOV/HUD framing unchanged vs PR #15/#12 SoT.

## Evidence paths

| Artifact | Path |
|----------|------|
| Report | `/workspace/card-shop-qa/art-b09-placement-1520e93f-spotcheck.md` |
| Aisle viewport | `/workspace/card-shop-qa/evidence/b09-placement-1520e93f/aisle_cam.png` |
| Aisle alias | `/workspace/card-shop-qa/evidence/smoke_1520e93f_aisle.png` |
| Behind-desk viewport | `/workspace/card-shop-qa/evidence/b09-placement-1520e93f/behind_desk.png` |
| SceneTree smoke log | `/workspace/card-shop-qa/evidence/b09-placement-1520e93f/smoke.log` |
| Smoke summary | `/workspace/card-shop-qa/evidence/b09-placement-1520e93f/summary.txt` |
| Foundation log | `/workspace/card-shop-qa/evidence/b09-placement-1520e93f/foundation.log` |
| Tip tree | `/workspace/qa-playtest/tip18/` |

## How reproduced

```bash
# tarball SHA 1520e93f8d4076103efa88d37b59a58bc46a026e → /workspace/qa-playtest/tip18
godot --headless --path /workspace/qa-playtest/tip18 --import
godot --headless --path /workspace/qa-playtest/tip18 -s res://tests/test_runner.gd
xvfb-run -a godot --path /workspace/qa-playtest/tip18 --script res://tests/qa_b09_placement_smoke.gd
```

## Clear for

Art/Eng: B09+ heavier décor placement on main `1520e93f` is QA-clear (**PASS**). B07 alcove-rear Art request `(4.5, 0, -7.05)` holds. No placement S1/S2.
