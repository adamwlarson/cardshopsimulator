# Playtest report — Formal F1 §10 #4/#6/#8 (+ #7 assert) @ `db944083` (PR #34)

**Scorer:** CSS QA (executor)  
**Date:** 2026-09-06 (~10:48 AM ET)  
**Build:** `adamwlarson/cardshopsimulator` tip **`db944083df19bcd1553382525240e86862111946`** (tree `/workspace/qa-playtest/f1-db944083/`)  
**Mode:** **Normal** (`data/balance/normal.tres`); Hard loan assert on `hard.tres`  
**Godot:** 4.5.2.stable.official.6ce3de25a (`/home/box/.local/bin/godot`)  
**Scope:** Formal F1 closeout — Spike staple (#4), rent fire-sale (#6), slab vs singles (#8), Titan hype assert-only (#7 / Option D path); §4.5 truth nack; soft Eng parked  
**Method:** Headless — foundation `tests/test_runner.gd` (`_test_sec10_4_spike_staple`, `_test_sec10_6_rent_firesale`, `_test_sec10_7_titan_hype`, `_test_sec10_8_slab_vs_singles`) + SceneTree harness `tests/qa_f1_beats_smoke.gd`  
**Design SoT:** `docs/design/next-eng-sot-pick-f-v1.md` § F1; ui-wireflows §5.1; systems §4.5 / §10; PR #34 tip

## Executive verdict

| Gate (pass bar) | Result |
|-----------------|--------|
| 1. #4 / #6 / #8 reachable on Normal without debug; `beat_started` / `beat_completed` | **PASS** |
| 2. #4 sell/refuse updates inventory / cash / Rep | **PASS** |
| 3. #6 three options reachable; Hard loan disabled/hidden; choosing one closes beat | **PASS** |
| 4. #8 case capacity blocks illegal slab; slab / singles / rotate choices | **PASS** |
| 5. #7 assert only (`sec10_7_titan_hype` + Option D path; HOT/Titan/no truth) — not re-implemented | **PASS** |
| 6. §4.5 clean on all opens (no `true_market` / `p_buy` / `cert_valid`) | **PASS** — 0 hits |
| 7. Soft Eng parked (non-blocking) | **PASS** (soft) |

| Supporting | Result |
|------------|--------|
| Tip SHA confirmed | **`db944083df19bcd1553382525240e86862111946`** |
| Foundation `test_runner` | **PASS** — `All foundation tests passed.` (EXIT 0) |
| Formal F1 smoke harness | **PASS** — **108 PASS / 0 FAIL**; `SOFT_COUNT=5` |
| S0–S2 (severity rubric) | **None found** for this tip |

**Overall: PASS**

F1 §10 required beat closeout clears the formal pass bar on Normal at tip `db944083`. Soft Eng notes remain parked and non-blocking. No Art scope.

**Clear for merge?** **YES**

## Pass-bar checklist

| # | Check | Observed | Verdict |
|---|-------|----------|---------|
| 1a | #4 Spike reachable day 3–5 FLOOR, no debug | day 3 `start_floor` → `sec10_4_spike_staple` started + `beat_started`; Spike scripted | **PASS** |
| 1b | #6 rent reachable day 7 PREP, no debug | `_start_day_beats(7)` → `sec10_6_rent_firesale` + `beat_started` | **PASS** |
| 1c | #8 showcase reachable day 11 PREP, no debug | `_start_day_beats(11)` → `sec10_8_slab_vs_singles` + `beat_started` | **PASS** |
| 2a | #4 sell updates inventory + cash | Bastion `AA-BASE-088`; stock −1; cash +500¢ list; `beat_completed` outcome `sold` via `_on_customer_resolved` | **PASS** |
| 2b | #4 refuse updates Rep, keeps stock/cash | stock unchanged; cash unchanged; Rep −1; `beat_completed` outcome `refused` | **PASS** |
| 3a | #6 three options live on Normal | Fire-sale / Cut accessories / Payday loan enabled + buttons live | **PASS** |
| 3b | #6 choosing any closes beat | fire_sale / cut_accessories / payday_loan each → `is_completed` + `beat_completed` | **PASS** |
| 3c | Hard loan disabled/hidden | `loan_enabled=false`; button `!visible && disabled`; `choose_rent_path(payday_loan)=false` | **PASS** |
| 4a | #8 capacity blocks illegal slab | stuffed case free&lt;2; `choose_showcase(slab)=false`; fail msg “needs 2 free slot-weights”; case API rejects | **PASS** |
| 4b | #8 slab / singles / rotate | all three buttons live; rotate closes beat; reversible same day; slab + singles still choosable | **PASS** |
| 5 | #7 assert only | day 8 Titan focus `AA-SKIE-047` / HOT / PriceEditor open / Cancel completes; no re-implement | **PASS** |
| 6 | §4.5 on opens | CustomerServe / rent / showcase / Titan PriceEditor + UI file scan **0** leaks | **PASS** |

## Key measured evidence

| Surface | Key numbers |
|---------|-------------|
| Tip | `db944083df19bcd1553382525240e86862111946` |
| Foundation | `All foundation tests passed.` / EXIT 0 — log `evidence/f1-db944083/foundation.log` |
| Smoke harness | **108 PASS / 0 FAIL / 5 SOFT** — `evidence/f1-db944083/f1_beats_smoke.json` |
| #4 sell | staple `AA-BASE-088`, list **500¢**, stock_delta **−1** |
| #4 refuse | rep_delta **−1** |
| #6 Hard | `loan_enabled=false` |
| #8 fail | `"The case needs 2 free slot-weights for the slab."` |
| #7 | sku `AA-SKIE-047`, beat `sec10_7_titan_hype`, HOT **true** |
| Truth scan | `truth_scan_leaks: []` |
| ShowcaseChoice | `offset_bottom = 520.0` in tscn (panel height 440 = 520−80 top) |

## Soft Eng nits (non-blocking)

1. **`_ensure_priceable_sku` Titan binder seed** — present in `demand_signals.gd`; parked from #33 / pick-f; non-blocking.  
2. **Showcase height 440→520 for rotate** — `ShowcaseChoice` `offset_bottom=520.0` present; observed Control height 440 (=520−80); parked soft polish.  
3. **Beat-local `_ensure_rent_inventory` / `_ensure_case_free_slot_weight`** — present in `beat_injection.gd`; parked soft.  
4. **Headless #4 via direct `_on_customer_resolved`** — present on BeatInjection; foundation + smoke resolve Spike sell/refuse through it; parked soft.

No S0–S2 findings. Soft park only.

## Design SoT alignment

- **pick-f F1:** #4 / #6 / #8 reachable Normal windows; #7 assert-only (Option D + Titan path); §4.5 clean; soft `_ensure_priceable_sku` stays parked.  
- **wireflows §5.1:** Spike CustomerServe Your list; rent PREP three-way (Hard loan hidden); showcase slab vs singles + rotate under case pressure.  
- **PR #34 tip `db94408`:** headless foundation close for #4/#8 via BeatInjection `_on_customer_resolved` / showcase complete-on-choose — exercised and green.

## Evidence paths

| Artifact | Path |
|----------|------|
| Report | `/workspace/card-shop-qa/playtest-f1-beats-db944083.md` |
| Docs QA copy | `/workspace/card-shop-qa/docs/qa/playtest-f1-beats-db944083.md` |
| Foundation log | `/workspace/card-shop-qa/evidence/f1-db944083/foundation.log` |
| Smoke log | `/workspace/card-shop-qa/evidence/f1-db944083/smoke.log` |
| Smoke JSON | `/workspace/card-shop-qa/evidence/f1-db944083/f1_beats_smoke.json` |
| Import log | `/workspace/card-shop-qa/evidence/f1-db944083/import.log` |
| Checkout | `/workspace/qa-playtest/f1-db944083` @ `db944083` |
| Harness | `/workspace/card-shop-qa/qa_f1_beats_smoke.gd` (also `tests/qa_f1_beats_smoke.gd` in checkout) |

## Repro

```bash
ROOT=/workspace/qa-playtest/f1-db944083
godot --headless --path "$ROOT" --import
godot --headless --path "$ROOT" --script res://tests/test_runner.gd
godot --headless --path "$ROOT" -s res://tests/qa_f1_beats_smoke.gd
```

Expect: `All foundation tests passed.` then `PASS_COUNT=108 FAIL_COUNT=0` / `All F1 beats smoke checks passed.`

## Notes

- Tip message: `fix: close #4/#8 beats in headless foundation tests` — Mark showcase complete on choose; resolve Spike sell/refuse through BeatInjection without CustomerSpawner in test runner.  
- No Art. Soft Eng park only; no FAIL repro.  
- Do not push / open PR / message agents (executor instruction).

## Merge

Merged to main as **PR #34** @ `865c36cc02eea2a2e1e56401c80838f97588cd1a` (2026-09-06).
