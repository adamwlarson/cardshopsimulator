# Playtest report — C3 §10 #3 marketplace outing + #10 shady trunk @ `a25493bb` (PR #29)

**Scorer:** CSS QA (executor)  
**Date:** 2026-09-04 (~6:30 PM ET)  
**Build:** `adamwlarson/cardshopsimulator` tip **`a25493bb7e1424654373bb8fb97c0c94d18d2145`** (tree `/workspace/qa-playtest/c3-a25493bb/` shallow checkout of PR head)  
**Mode:** **Normal** (`data/balance/normal.tres`)  
**Godot:** 4.5.2.stable.official.6ce3de25a (`/home/box/.local/bin/godot`)  
**Scope:** Formal smoke — §10 #3 Drive/Courier/Skip; §10 #10 Buy/Report/Ignore + Report Rep; Drive Att 25 + FLOOR skip; Courier keeps FLOOR; §4.5 shady confirm truth nack  
**Method:** Headless — foundation `tests/test_runner.gd` (includes `_test_c3_beats_reachable_without_debug`, `_test_c3_drive_shortens_floor_courier_keeps`, `_test_c3_shady_confirm_has_no_truth`, `_test_c3_report_applies_rep`) + SceneTree harness `tests/qa_c3_beats_smoke.gd`  
**Design SoT:** pick-e / pick-c Option C3; PR #29 body; Soft Eng notes + Soft teal polo parked (non-blocking)

## Executive verdict

| Gate (pass bar) | Result |
|-----------------|--------|
| 1. §10 #3 Drive / Courier / Skip reachable on Normal day windows without debug | **PASS** |
| 2. §10 #10 Buy / Report / Ignore reachable; Report applies `BalanceConfig.shady_report_rep_gain` | **PASS** |
| 3. Drive shortens FLOOR (Att 25 + floor skip); Courier keeps FLOOR | **PASS** |
| 4. §4.5: shady confirm never leaks true condition / `cert_valid` (also `true_market` / `p_buy`) | **PASS** — 0 hits |
| 5. Soft Eng notes parked (non-blocking); Soft teal polo OOS | **PASS** (soft noted) |

| Supporting | Result |
|------------|--------|
| Tip SHA confirmed | **`a25493bb7e1424654373bb8fb97c0c94d18d2145`** |
| Foundation `test_runner` | **PASS** — `All foundation tests passed.` (four `_test_c3_*` included) |
| Formal C3 smoke harness | **PASS** — **119 PASS / 0 FAIL**; `SOFT_COUNT=3` |
| S0–S3 (severity rubric) | **None found** for this tip |

**Overall: PASS-with-notes**

C3 marketplace outing + shady trunk clears the formal pass bar on Normal at tip `a25493bb`. Soft Eng parkeds (Option D / HOLD / off-site 3D / meshes / docs) and Soft teal polo OOS are explicitly parked and non-blocking. Known HUD re-instantiate duplicate-connect noise remains a soft nit.

**Clear for merge?** **YES** (PASS-with-notes; soft only).

## Pass-bar checklist

| # | Check | Observed | Verdict |
|---|-------|----------|---------|
| 1a | Day 3 Drive / Courier / Skip | Beat `sec10_3_marketplace_outing` starts on Normal PREP day 3 via `_start_day_beats` (QA off); survives active C1 fog; choices `drive_out` / `courier` / `skip`; modal title **Off-site lot — leave the floor?**; all three buttons live | **PASS** |
| 1b | Day ~20 Buy / Report / Ignore | Beat `sec10_10_shady_trunk` starts Normal day 20 PREP after expand resolve; Night/PREP true; choices `buy` / `report` / `ignore`; modal **Trunk sale — too good?** | **PASS** |
| 2a | Report applies Rep | `shady_report_rep_gain` **5**; Rep **40 → 45**; no stock granted; lot removed; beat completed | **PASS** |
| 2b | Ignore dismisses | Ignore commits; Rep unchanged; lot removed; beat completed | **PASS** |
| 3a | Drive Att + FLOOR skip | Att **100 → 75** (−25); `pending_floor_skip_seconds` **34.0**; persists in save; `consume_floor_skip` returns 34.0; DayClock source contains `consume_floor_skip` + `DayPhase.FLOOR` | **PASS** |
| 3b | Courier keeps FLOOR | Fee **3500¢**; Att unchanged; skip stays **0**; opens BuyOpportunityDetail (`marketplace-outing-steal`); consume returns 0 | **PASS** |
| 4a | Shady confirm §4.5 | DTO has no truth fields; Low confidence; cue **Photo only — inspect strongly recommended**; confirm hides all CONDITION_GRADE_CUES + `cert_valid`; presenter/HUD summaries clean | **PASS** |
| 4b | UI truth scan | Scanned hud / presenter / main_menu (+ tscn) — **0** tokens | **PASS** |
| 5 | Soft parkeds | Soft Eng + Soft teal polo OOS only | **PASS** (soft) |

## Key measured evidence

| Surface | Key numbers |
|---------|-------------|
| BalanceConfig (Normal) | Att **25**; floor skip **34.0s**; courier fee **3500¢**; Report Rep **5** |
| Outing choices | `drive_out` / `courier` / `skip` |
| Shady choices | `buy` / `report` / `ignore`; Night/PREP **true** |
| Drive | Att 100→**75**; skip **34.0** consumed |
| Courier | fee **3500¢**; Att unchanged; skip **0**; focus `marketplace-outing-steal` |
| Report | Rep 40→**45** (+5); stock unchanged |
| Shady confirm | Low; cue inspect-strong; confirm text grade-free |
| Truth scan | `truth_scan_leaks: []` |
| Harness | 119 PASS / 0 FAIL / 3 SOFT |

## Design SoT alignment

- **Option C3 / pick-e:** Extends BeatInjection + BuyOpportunityDetail + §4.5 path (same pattern as #5/#7). No docs edits. Option D / HOLD polish parked.
- **§10 #3:** Drive / Courier / Skip reachable on Normal day 3 without debug; Drive spends Att + shortens FLOOR; Courier fee keeps FLOOR.
- **§10 #10:** Buy / Report / Ignore on Normal day 20–30 Night/PREP; Report applies `BalanceConfig.shady_report_rep_gain`; confirm never leaks true condition / `cert_valid`.
- **ui-wireflows §4.5:** Truth nacks clear on HUD / presenter / confirm.
- **Out of scope (tip):** Off-site 3D, combat, lip sync, Option D event→PriceEditor bridge, HOLD soft polish, new meshes, docs/, Soft teal polo — soft parked as expected.

## Soft Eng nits (non-blocking)

1. **Soft Eng notes** — Option D PriceEditor bridge / HOLD polish / off-site 3D / new meshes / docs/ remain parked — OOS for C3. (**S4**)
2. **Soft teal polo OOS** — parked; non-blocking. (**S4**)
3. **HUD re-instantiate duplicate Signal connect ERRORs** — observed in foundation/harness when HUD instantiated more than once; foundation still prints `All foundation tests passed.`; non-blocking prior nit. (**S4**)

## Findings (severity-ranked)

None at S0–S3 for this tip. Soft-only parkeds above.

## Evidence paths

| Artifact | Path |
|----------|------|
| Checkout | `/workspace/qa-playtest/c3-a25493bb` @ `a25493bb7e1424654373bb8fb97c0c94d18d2145` |
| Import log | `/workspace/card-shop-qa/evidence/c3-a25493bb/import.log` |
| Foundation log | `/workspace/card-shop-qa/evidence/c3-a25493bb/foundation.log` |
| Harness log | `/workspace/card-shop-qa/evidence/c3-a25493bb/qa_c3_smoke.log` |
| Harness JSON | `/workspace/card-shop-qa/evidence/c3-a25493bb/c3_beats_smoke.json` |
| Harness script | `/workspace/card-shop-qa/qa_c3_beats_smoke.gd` (also `tests/qa_c3_beats_smoke.gd` in checkout) |
| This report | `/workspace/card-shop-qa/playtest-c3-beats-a25493bb.md` |
| docs/qa copy | `/workspace/card-shop-qa/docs/qa/playtest-c3-beats-a25493bb.md` |

## Repro (PASS path)

```bash
ROOT=/workspace/qa-playtest/c3-a25493bb
# after Godot editor import completes
godot --headless --path "$ROOT" --script res://tests/test_runner.gd
godot --headless --path "$ROOT" --script res://tests/qa_c3_beats_smoke.gd
```
