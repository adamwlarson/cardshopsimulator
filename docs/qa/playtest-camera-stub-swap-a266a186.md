# Playtest report — V1 Camera Art stub-swap formal smoke @ `a266a186` (PR #53)

**Scorer:** CSS QA (executor)  
**Date:** 2026-09-06 (~6:51 PM ET)  
**Build:** `adamwlarson/cardshopsimulator` tip **`a266a1868c6d0c2f26612bbc483b37d3dd77393c`** (tree `/workspace/qa-playtest/v1-wire-a266a186/`)  
**Mode:** **Normal** (`data/balance/normal.tres`)  
**Godot:** 4.5.2.stable.official.6ce3de25a (`/workspace/godot452`)  
**Scope:** Formal V1 Camera Art stub-swap after Eng APPROVE + Art dual-clear — unowned hides props; owned shows Medium ceiling cams (entrance + aisle); Art GLB `prop_security_camera_01` (not Marker3D); SoT MOUNT / yaw 180° / scale (1,1,1); Large extra at `(10.40, 2.80, −8.40)` hidden Small/Medium, shows Large when owned; install cash/Att + already-owned refuse unchanged from #51; Theft shrink math unchanged; §4.5 clean; Soft catalog CLOSED; Soft far crest Art later; no new economy verbs  
**Method:** Headless — import `--editor --quit-after 120` + foundation `tests/test_runner.gd` (includes `_test_security_camera_prop_stub_swap`) + SceneTree harness `tests/qa_v1_camera_stub_swap_smoke.gd`  
**Art SoT:** `docs/art/V1_SECURITY_CAMERA_MVP.md`  
**Priors:** V1 Camera unlock #51 `0cbef7bc`; Art pack PR #52 `481c1c16` merged into this tip  
**Branch:** `cursor/v1-camera-prop-stub-swap-f99e` · PR https://github.com/adamwlarson/cardshopsimulator/pull/53

## Executive verdict

| Gate (Designer bar) | Result |
|---------------------|--------|
| 1. Unowned → SecurityCamera props hidden; owned → Medium ceiling cams visible (entrance + aisle) | **PASS** |
| 2. Props are Art GLB `prop_security_camera_01` (not Marker3D); scale/pivot/yaw match Art SoT (MOUNT, yaw 180°) | **PASS** |
| 3. Large extra `SecurityCameraLarge` at `(10.40, 2.80, −8.40)` hidden on Small/Medium; shows on Large when owned | **PASS** |
| 4. Install cash/Att gates + already-owned refuse unchanged from #51; Theft shrink math unchanged | **PASS** |
| 5. §4.5 clean; Soft catalog untouched; Soft far crest later | **PASS** |
| 6. Foundation EXIT:0; foundation `_test_security_camera_prop_stub_swap` and/or focused harness | **PASS** |

| Supporting | Result |
|------------|--------|
| Tip SHA confirmed | **`a266a1868c6d0c2f26612bbc483b37d3dd77393c`** (`Sync camera props after install in the foundation check.`) |
| Import `--editor --quit-after 120` | **PASS** — EXIT:0 |
| Foundation `test_runner` | **PASS** — `All foundation tests passed.` EXIT:0 (`_test_security_camera_prop_stub_swap` + `_test_camera_unlock` exercised) |
| Formal stub-swap harness | **PASS** — **127 PASS / 0 FAIL**; `SOFT_COUNT=6` |
| Soft notes disposition | **Non-blocking** — Soft catalog CLOSED; Soft far crest Art later; Soft active≡owned Soft OK MVP; no new economy verbs |
| S0–S2 (severity rubric) | **None found** for this tip |

**Overall: PASS-with-notes**

V1 Camera Art stub-swap clears the formal pass bar on Normal at tip `a266a186`. Medium entrance `(6.30, 2.80, −1.80)` + aisle `(4.50, 2.80, −4.20)` show when owned; Large extra `(10.40, 2.80, −8.40)` gates on Large+owned. Props instance Art GLB (not Marker3D) at yaw 180° / scale 1. Install $2,500 + Att 8 / already-owned refuse and Theft shrink (no-cam ×3 / 0.021 / 425¢ vs with-cam ×1.5 / 0.0105 / 225¢; COGS 20225¢) unchanged from #51.

**Clear for merge?** **YES** (PASS-with-notes; soft only).

## Pass-bar checklist

| # | Check | Observed | Verdict |
|---|-------|----------|---------|
| 1a | Unowned hides props | visible count **0**; `owned_cameras_visible=false`; nodes exist but `visible=false` | **PASS** |
| 1b | Owned shows Medium cams | entrance + aisle visible; count **2** on Small | **PASS** |
| 1c | New game hides again | ownership cleared; visible count **0** | **PASS** |
| 2a | Art GLB not Marker3D | `scene_file_path` contains `prop_security_camera_01`; `is Marker3D` false (entrance/aisle/large) | **PASS** |
| 2b | SoT places | entrance `(6.3, 2.8, -1.8)`; aisle `(4.5, 2.8, -4.2)`; large `(10.4, 2.8, -8.4)` | **PASS** |
| 2c | Yaw / scale / Y | rotation `(0, 180, 0)`; scale `(1,1,1)`; hang Y=2.80 | **PASS** |
| 2d | ShopCamera/FOV untouched | behind-counter position + HOME_FOV unchanged | **PASS** |
| 3a | Small owned | Large extra hidden; count **2** | **PASS** |
| 3b | Medium owned | Large extra hidden; count **2** | **PASS** |
| 3c | Large owned | Large extra visible at SoT; count **3** | **PASS** |
| 3d | Large unowned | Large extra hidden; count **0** | **PASS** |
| 4a | Install cash/Att | cash −250000; Att −8; owned+active | **PASS** |
| 4b | Refuse Att 0 / cash-short / already-owned | `insufficient_attention` / `insufficient_cash` / `already_owned` | **PASS** |
| 4c | Theft shrink unchanged | no-cam rate **0.021** / mult **3.0** / loss **425**; with-cam **0.0105** / **1.5** / **225**; COGS **20225** | **PASS** |
| 5a | §4.5 UI+rig scan | **0** whole-token `true_market` / `p_buy` / `cert_valid` leaks | **PASS** |
| 5b | Soft catalog untouched | `_ensure_priceable_sku` parked; no Soft reopen; no `camera unlock` in events.json | **PASS** |
| 5c | Soft far crest later | rig has no `prop_graded_case_badge_01` polish | **PASS** (soft) |
| 6a | No new economy verbs | rig has no `install_cameras` / `can_install_cameras`; consumes `has_cameras` / bus only | **PASS** |
| 6b | Foundation + harness | foundation EXIT:0; harness **127/0/6** | **PASS** |

## Key measured evidence

| Surface | Key numbers |
|---------|-------------|
| Tip | `a266a1868c6d0c2f26612bbc483b37d3dd77393c` |
| SoT mounts | entrance `(6.30, 2.80, −1.80)`; aisle `(4.50, 2.80, −4.20)`; Large `(10.40, 2.80, −8.40)`; yaw **180°** |
| Visibility | unowned **0**; Small/Medium owned **2**; Large owned **3**; Large unowned **0** |
| Install | cash **$2,500** (250000¢); Att **8**; refuse `insufficient_attention` / `insufficient_cash` / `already_owned` |
| Theft no-cam | rate **0.021**; shrink_mult **3.0**; loss **425**; COGS **20225** |
| Theft with-cam | rate **0.0105**; shrink_mult **1.5**; loss **225**; COGS **20225** |
| Truth scan | `truth_scan_leaks: []` |
| Harness | **127 PASS / 0 FAIL / 6 SOFT** |
| Foundation | `All foundation tests passed.` EXIT:0 |
| Import | EXIT:0 |

## Soft notes (non-blocking)

1. Soft catalog CLOSED — U1; no Soft reopen this stub-swap  
2. Soft far crest (J2 badge) Art later — not this PR  
3. Soft active≡owned Soft OK MVP stands from #51 (`has_active_cameras` → `cameras_owned`)  
4. No new economy verbs — presenter consumes `ShopState.has_cameras()` / `EventBus.cameras_changed` only  
5. Soft Eng APPROVE + Art dual-clear prior — formal smoke only  
6. Out of scope honored: Soft catalog reopen, Soft far-crest polish, multi-cam/alarm/staff camera skill  

## Evidence paths

| Artifact | Path |
|----------|------|
| Import log | `/workspace/card-shop-qa/evidence/v1-wire-a266a186/import.log` |
| Foundation log | `/workspace/card-shop-qa/evidence/v1-wire-a266a186/foundation.log` |
| Harness log | `/workspace/card-shop-qa/evidence/v1-wire-a266a186/qa_v1_stub_swap_smoke.log` |
| Harness JSON | `/workspace/card-shop-qa/evidence/v1-wire-a266a186/qa_v1_camera_stub_swap_smoke.json` |
| Report (root) | `/workspace/card-shop-qa/playtest-camera-stub-swap-a266a186.md` |
| Report (docs/qa) | `/workspace/card-shop-qa/docs/qa/playtest-camera-stub-swap-a266a186.md` |
| Checkout | `/workspace/qa-playtest/v1-wire-a266a186/` |
| Harness script | `tests/qa_v1_camera_stub_swap_smoke.gd` (local to checkout; not committed) |

## Blockers

**None.** Clear for merge (PASS-with-notes; soft only).
