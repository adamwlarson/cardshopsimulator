# Playtest report — C2 Hire vs owner bandwidth (Reliability, Att 0, §10 #5) @ `df7701e9` (PR #28)

**Scorer:** CSS QA (executor)  
**Date:** 2026-09-04 (~6:20 PM ET)  
**Build:** `adamwlarson/cardshopsimulator` tip **`df7701e915fcb375fd46590c1e6e602e6eb05967`** (tree `/workspace/qa-playtest/c2-df7701e9/` shallow checkout of PR head)  
**Mode:** **Normal** (`data/balance/normal.tres`)  
**Godot:** 4.5.2.stable.official.6ce3de25a (`/home/box/.local/bin/godot`)  
**Scope:** Formal smoke — §10 #5 Hire/Solo/Cheap(Unreliable); Reliability 10-day stress + soft-lock; Att 0 owner verbs; Specialist Inspect/Research 2/10 (#24 assert); §4.5 truth nack  
**Method:** Headless — foundation `tests/test_runner.gd` (includes `_test_c2_hire_beat_paths`, `_test_c2_unreliable_ten_day_stress`, `_test_c2_att_zero_owner_verbs`, `_test_c2_specialist_attention_assert`) + SceneTree harness `tests/qa_c2_hire_smoke.gd`  
**Design SoT:** pick-d / pick-c Option C2; PR #28 body; Soft Eng notes + Soft MidCenter parked (non-blocking)

## Executive verdict

| Gate (pass bar) | Result |
|-----------------|--------|
| 1. §10 #5 Day~5 beat: Hire / Solo / Cheap(Unreliable) reachable; Hire wage + staff_cap; Solo empty roster | **PASS** |
| 2. Reliability: Unreliable path ≥1 no-show OR shrink↑ in 10-day seeded stress; no soft-lock | **PASS** |
| 3. Att 0: owner verbs disabled (Research/Inspect/Negotiate/Pull); cashier still routine-sells (Sell enabled) | **PASS** |
| 4. Specialist on duty: Inspect/Research Att = 2 / 10 (assert #24 shipped) | **PASS** |
| 5. §4.5 clean: no `true_market` / `p_buy` / `cert_valid` in UI | **PASS** — 0 hits |
| 6. Soft Eng notes parked (non-blocking); Soft MidCenter parked (OOS) | **PASS** (soft noted) |

| Supporting | Result |
|------------|--------|
| Tip SHA confirmed | **`df7701e915fcb375fd46590c1e6e602e6eb05967`** |
| Foundation `test_runner` | **PASS** — `All foundation tests passed.` (four `_test_c2_*` included) |
| Formal C2 smoke harness | **PASS** — **167 PASS / 0 FAIL**; `SOFT_COUNT=3` |
| S0–S3 (severity rubric) | **None found** for this tip |

**Overall: PASS-with-notes**

C2 hire-vs-owner bandwidth clears the formal pass bar on Normal at tip `df7701e9`. Soft Eng parkeds (MidCenter polish / C3 / Option D / new roles / meshes / docs) and known HUD re-instantiate duplicate-connect noise are explicitly parked and non-blocking.

## Pass-bar checklist

| # | Check | Observed | Verdict |
|---|-------|----------|---------|
| 1a | Day~5 Hire / Solo / Unreliable options | Beat `sec10_5_hire_cashier` starts on Normal PREP day 5; choices `hire_cashier` / `keep_solo` / `hire_cheap`; cheap confirm body warns Reliability | **PASS** |
| 1b | Hire wage + staff_cap | Hire → roster 1 / Small cap 1; wage **8000¢** ($80); wage posts at SETTLE; cap filled | **PASS** |
| 1c | Solo empty roster | `keep_solo` → hired_count 0, owner-only, no wage at SETTLE | **PASS** |
| 1d | Unreliable hire | `hire_cheap` → theft_bias true; reliability **0.5** (≤0.55); wage 4500¢ | **PASS** |
| 2a | ≥1 no-show or shrink↑ | Seed **90407** (STAFF_ATTENDANCE_SEED): **noshows=2**, shrink↑ (loss **1100¢**, max_rate **0.007** > base) | **PASS** |
| 2b | No soft-lock | 10-day cheap run stays active; inventory min_units **56**; direct `apply_daily_shrink(1.0)` 100→**1** unit (`unit_count()>1` guard) | **PASS** |
| 3a | Owner verbs blocked at Att 0 | `can_inspect` / `can_negotiate` / `can_pull` false; Research `insufficient_attention`; queue negotiate/pull fail | **PASS** |
| 3b | Cashier routine sell | `sell_listed()` true; HUD Sell enabled; Negotiate/Pull/Research disabled at Att 0 | **PASS** |
| 4 | Specialist 2 / 10 | Domain Inspect **2** / Research **10**; HUD `Inspect★ · Att 2` / `Research · $50.00 · Att 10` | **PASS** |
| 5 | Truth nack UI | Scanned hud / presenter / main_menu (+ tscn) — **0** tokens; beat/QA payloads clean | **PASS** |
| 6 | Soft parkeds | MidCenter + Eng OOS soft notes only | **PASS** (soft) |

## Key measured evidence

| Surface | Key numbers |
|---------|-------------|
| Hire path | wage **8000¢**; staff_cap **1**; hired_count **1** |
| Unreliable hire | reliability **0.5**; theft_bias **true**; wage **4500¢** |
| 10-day stress seed 90407 | noshows **2**; shrink_loss **1100¢**; max_rate **0.007**; min_units **56** |
| Soft-lock direct | units 100→1 after rate 1.0; units_removed 99; never 0 |
| Att 0 | can_inspect/negotiate/pull **false**; sell_enabled **true** |
| Specialist | Inspect **2** / Research **10**; HUD labels match |
| Truth scan | `truth_scan_leaks: []` |
| Harness | 167 PASS / 0 FAIL / 3 SOFT |

## Design SoT alignment

- **Option C2 / pick-d:** Extends existing hire beat / staff / wage / Reliability path — no new roles, meshes, or HR.
- **§10 #5:** Hire / Solo / Cheap reachable; Hire posts wage + consumes staff_cap; Solo leaves roster empty.
- **Reliability:** Cheap path raises shrink vs base; seeded 10-day stress hits no-show + shrink↑ without soft-lock (`unit_count()>1` shrink guard).
- **Att 0 bandwidth:** Owner Research/Inspect/Negotiate/Pull gated; cashier still routine-sells.
- **#24 Specialist assert:** Inspect 2 / Research 10 when Specialist on duty (domain + HUD).
- **ui-wireflows §4.5:** Truth nacks clear on HUD / presenter.
- **Out of scope (tip):** C3 beats, Option D PriceEditor bridge, new staff roles, dialogue, full HR, new meshes, docs/ edits, Soft MidCenter lights/apron/icon/skinning/usable_sq_ft — soft parked as expected.

## Soft Eng nits (non-blocking)

1. **Soft MidCenter lights / apron / icon / skinning / usable_sq_ft** remain parked — OOS for C2. (**S4**)
2. **C3 beats / Option D PriceEditor bridge / new staff roles / dialogue / full HR / new meshes / docs/ edits** — PR OOS. (**S4**)
3. **HUD re-instantiate duplicate Signal connect ERRORs** — observed in foundation/harness when HUD instantiated more than once; foundation still prints `All foundation tests passed.`; non-blocking prior nit. (**S4**)

## Findings (severity-ranked)

### S0–S3
**None.**

### S4 (soft / parked)
See Soft Eng nits above.

## Evidence paths

| Artifact | Path |
|----------|------|
| Report | `/workspace/card-shop-qa/playtest-c2-hire-df7701e9.md` |
| Report (repo docs/qa) | `/workspace/qa-playtest/c2-df7701e9/docs/qa/playtest-c2-hire-df7701e9.md` (+ `/workspace/card-shop-qa/docs/qa/` copy) |
| Foundation log | `/workspace/card-shop-qa/evidence/c2-df7701e9/foundation.log` |
| Import log | `/workspace/card-shop-qa/evidence/c2-df7701e9/import.log` |
| C2 harness log | `/workspace/card-shop-qa/evidence/c2-df7701e9/qa_c2_smoke.log` |
| C2 harness JSON | `/workspace/card-shop-qa/evidence/c2-df7701e9/c2_hire_smoke.json` |
| Harness script | `/workspace/qa-playtest/c2-df7701e9/tests/qa_c2_hire_smoke.gd` (+ copy `/workspace/card-shop-qa/qa_c2_hire_smoke.gd`) |
| Checkout | `/workspace/qa-playtest/c2-df7701e9` @ `df7701e915fcb375fd46590c1e6e602e6eb05967` |

## Clear for merge?

**Yes** — PASS-with-notes. No S0–S3 blockers. Soft parkeds only.
