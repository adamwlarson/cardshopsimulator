# Playtest report — V1 Camera unlock formal smoke @ `0cbef7bc` (PR #51)

**Scorer:** CSS QA (executor)  
**Date:** 2026-09-06 (~6:40 PM ET)  
**Build:** `adamwlarson/cardshopsimulator` tip **`0cbef7bcd6093861e27170723966cf8be124a2e2`** (tree `/workspace/qa-playtest/v1-0cbef7bc/`)  
**Mode:** **Normal** (`data/balance/normal.tres`)  
**Godot:** 4.5.2.stable.official.6ce3de25a (`/workspace/godot452` / `/home/box/.local/bin/godot`)  
**Scope:** Formal V1 Camera unlock smoke after Eng APPROVE-with-notes — buy/install $2,500 + Att 8; Theft shrink ×1.5 with cams vs ×3 without; O1 staff+wait-out+EventBanner without cams unchanged; §4.5 clean; Soft catalog closed; Soft active≡owned Soft OK MVP; Art optional placeholder OK; install refuse Att 0 / cash-short / already-owned / SETTLE  
**Method:** Headless — import `--editor --quit-after 120` + foundation `tests/test_runner.gd` (includes `_test_camera_unlock`) + SceneTree harness `tests/qa_v1_camera_smoke.gd`  
**Design SoT:** `docs/design/next-eng-sot-pick-v-v1.md` Adopted V1 GO  
**Priors:** O1 Theft `87f78d15`; U1 Soft hygiene #50  
**Art:** optional placeholder OK (no Art block). Soft Eng: `cameras_owned` ≡ `cameras_active` Soft OK MVP; Soft catalog closed.

## Executive verdict

| Gate (Designer bar) | Result |
|---------------------|--------|
| 1. Can buy/install cameras when cash/Att gates met ($2,500 + Att 8 Normal) | **PASS** |
| 2. During Theft ring, shrink lower with cams than without (rate / shrink_mult / loss_cents; ×1.5 vs ×3) | **PASS** |
| 3. Without cams, Theft wait-out / staff lever still work (O1 unchanged); EventBanner rumor still works | **PASS** |
| 4. §4.5 clean; Soft catalog untouched; Art optional placeholder OK | **PASS** |
| 5. Soft active≡owned Soft OK MVP | **PASS** (Soft OK) |
| 6. Install refuse: Att 0 / cash-short / already-owned / SETTLE | **PASS** |
| 7. Foundation EXIT:0; focused harness | **PASS** |

| Supporting | Result |
|------------|--------|
| Tip SHA confirmed | **`0cbef7bcd6093861e27170723966cf8be124a2e2`** (`Keep HUD FOV smoke from flagging the security-camera unlock.`) |
| Import `--editor --quit-after 120` | **PASS** — EXIT:0 |
| Foundation `test_runner` | **PASS** — `All foundation tests passed.` EXIT:0 (`_test_camera_unlock` exercised) |
| Formal V1 smoke harness | **PASS** — **231 PASS / 0 FAIL**; `SOFT_COUNT=7` |
| Soft Eng notes disposition | **Non-blocking** — Soft active≡owned Soft OK MVP; Soft catalog closed; Art placeholder OK |
| S0–S2 (severity rubric) | **None found** for this tip |

**Overall: PASS-with-notes**

V1 Camera unlock clears the formal pass bar on Normal at tip `0cbef7bc`. Soft active≡owned Soft OK MVP (`has_active_cameras()` returns `cameras_owned`) called out; Soft catalog closed; Art prop absent / placeholder OK. Instrumented shrink: no-cam rate **0.021** / mult **3.0** / loss **425¢** vs with-cam rate **0.0105** / mult **1.5** / loss **225¢** (same COGS **20225¢**).

**Clear for merge?** **YES** (PASS-with-notes; soft only).

## Pass-bar checklist

| # | Check | Observed | Verdict |
|---|-------|----------|---------|
| 1a | Balance scalars Normal | cash **250000¢** ($2,500); Att **8**; `camera_theft_shrink_mult` **1.5** | **PASS** |
| 1b | Install when gates met | `ok`; cash −250000; Att −8; owned+active; `cameras_installed` instrumented | **PASS** |
| 1c | HUD buy/install confirm | `%OpenCamerasButton` shows `$2,500.00` + `Att 8`; confirm opens; installs; shows `Cameras on`; disables | **PASS** |
| 2a | Shrink without cams | mult **3.0**; rate **0.021**; loss **425**; `cameras_active` false | **PASS** |
| 2b | Shrink with cams | mult **1.5**; rate **0.0105**; loss **225**; `cameras_active` true; same COGS **20225** | **PASS** |
| 2c | Cameras cut loss | 225 < 425; rate 0.0105 < 0.021; mult 1.5 < 3.0 | **PASS** |
| 3a | Staff lever without cams | unstaffed theft **0.021** → staffed **0.006**; mult stays ×3 | **PASS** |
| 3b | Wait-out without cams | remaining **3→2**; clear ends ring; shrink restores | **PASS** |
| 3c | EventBanner rumor | exact `"Rumor: extra loss on the floor — staff up or wait it out"`; no camera requirement | **PASS** |
| 4a | §4.5 UI scan | **0** whole-token `true_market` / `p_buy` / `cert_valid` leaks | **PASS** |
| 4b | Soft catalog untouched | `_ensure_priceable_sku` parked; no Soft reopen; no `camera unlock` in events.json | **PASS** |
| 4c | Art optional | camera prop **absent**; placeholder OK; no Art block | **PASS** (soft) |
| 5 | Soft active≡owned | `has_active_cameras()` → `cameras_owned`; result + save/restore keep owned≡active | **PASS** (Soft OK) |
| 6a | Att 0 refuse | `insufficient_attention`; not owned | **PASS** |
| 6b | Cash-short refuse | `insufficient_cash` | **PASS** |
| 6c | Already-owned refuse | `already_owned` | **PASS** |
| 6d | SETTLE refuse | `wrong_phase` | **PASS** |
| 7 | Foundation + harness | foundation EXIT:0; harness **231/0/7** | **PASS** |

## Key measured evidence

| Surface | Key numbers |
|---------|-------------|
| Constants | cash **$2,500** (250000¢); Att **8**; `camera_theft_shrink_mult` **1.5**; `THEFT_RING_SHRINK_MULT` **3.0** |
| Install | cash_spent **250000**; attention_spent **8**; `cameras_owned=true`; `cameras_active=true` |
| Theft no-cam | rate **0.021**; shrink_mult **3.0**; loss **425**; units **17**; COGS **20225** |
| Theft with-cam | rate **0.0105**; shrink_mult **1.5**; loss **225**; units **9**; COGS **20225** |
| Staff without cams | unstaffed **0.021** → staffed **0.006** |
| Banner | `Rumor: extra loss on the floor — staff up or wait it out` |
| Refuse reasons | `insufficient_attention` / `insufficient_cash` / `already_owned` / `wrong_phase` |
| Soft active≡owned | `ShopState.has_active_cameras()` returns `cameras_owned` |
| Truth scan | `truth_scan_leaks: []` |
| Harness | **231 PASS / 0 FAIL / 7 SOFT** |
| Foundation | `All foundation tests passed.` EXIT:0 |
| Import | EXIT:0 |

## Design SoT alignment

- **pick-v / Option V1:** Camera unlock; cash + Att install; reduces Theft-ring shrink while owned/active; EventBanner rumor still works without cams; §4.5 clean; Soft catalog closed; Art optional.
- **O1 unchanged without cams:** staff dampens base loss rate; wait-out still ticks 3-day window; thin EventBanner rumor.
- **Out of scope (honored):** Multi-cam, alarm, staff camera skill; Soft catalog reopen; Soft far crest Art later; mandatory Art prop.

## Soft Eng notes disposition (APPROVE-with-notes)

| Soft Eng note | Disposition |
|---------------|-------------|
| Soft active≡owned Soft OK MVP (`cameras_owned` ≡ `cameras_active`) | **Non-blocking / intentional.** `has_active_cameras()` returns `cameras_owned`; no separate active toggle this pack. Do **not** FAIL for missing independent active flag. No S0–S2. |
| Soft catalog closed | **Non-blocking / intentional.** U1 Soft hygiene stands; Soft far crest Art later parked; no Soft reopen on this tip. |
| Art optional placeholder OK | **Non-blocking.** Camera prop absent; HUD text unlock sufficient. No Art block. |

## Soft Eng nits (non-blocking / parked)

1. **Soft Eng active≡owned Soft OK MVP** — owned≡active intentional; do not FAIL. (**S4**)
2. **Soft catalog closed** — keep closed; Soft far crest Art later. (**S4**)
3. **Soft EventBanner-only Theft rumor Soft OK MVP** — O1 path unchanged without cams. (**S4**)
4. **Art optional placeholder** — prop absent OK. (**S4**)
5. **Out of scope** — multi-cam / alarm / staff camera skill. (**S4**)

## Findings (severity-ranked)

### S0–S2
**None.**

### Soft / notes
See Soft Eng nits above. No blockers.

## Blockers
**None.**

## Evidence paths

| Artifact | Path |
|----------|------|
| Report (root) | `/workspace/card-shop-qa/playtest-v1-camera-0cbef7bc.md` |
| Report (docs) | `/workspace/card-shop-qa/docs/qa/playtest-v1-camera-0cbef7bc.md` |
| Evidence dir | `/workspace/card-shop-qa/evidence/v1-0cbef7bc/` |
| Import log | `…/import.log` (EXIT:0) |
| Foundation log | `…/foundation.log` (EXIT:0) |
| Harness log | `…/qa_v1_smoke.log` |
| Harness JSON | `…/qa_v1_camera_smoke.json` |
| Checkout | `/workspace/qa-playtest/v1-0cbef7bc/` @ `0cbef7bcd6093861e27170723966cf8be124a2e2` |
| Harness script | `/workspace/card-shop-qa/qa_v1_camera_smoke.gd` (copied → `tests/qa_v1_camera_smoke.gd`) |

## Harness counts

- **PASS_COUNT=231**
- **FAIL_COUNT=0**
- **SOFT_COUNT=7**
- **TIP_SHA=0cbef7bcd6093861e27170723966cf8be124a2e2**
