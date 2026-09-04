# Playtest report — Specialist staff (hire path + Attention discounts) @ `2e31966a` (PR #24)

**Scorer:** CSS QA (executor)  
**Date:** 2026-09-04 (~5:30 PM ET)  
**Build:** `adamwlarson/cardshopsimulator` tip **`2e31966a27e6b0764752ca0e8c09aeee837ec3d5`** (tree `/workspace/qa-playtest/tip24/` from GitHub tarball)  
**Mode:** **Normal** (`data/balance/normal.tres`) — Easy/Hard soft omission notes only  
**Godot:** 4.5.2.stable.official.6ce3de25a (`/workspace/godot452`)  
**Scope:** Formal smoke — Specialist hire/fire/cap + Research/Inspect★ Attention discounts + HUD cost match + save-load + truth nack  
**Method:** Headless — foundation `tests/test_runner.gd` (includes `_test_specialist_staff_path`) + SceneTree harness `tests/qa_specialist_staff_smoke.gd`  
**Design SoT (reference only; no docs/ delta on tip):** systems-design-v1.md §6 Staff; next-eng-sot-pick-v1.md Option A; ui-wireflows-v1.md (truth nacks)

## Executive verdict

| Gate (pass bar) | Result |
|-----------------|--------|
| 1. Owner Attention costs: Research **15**, Inspect **5** | **PASS** |
| 2. Specialist on-duty: Research **10**, Inspect **2** | **PASS** |
| 3. Hire / fire / staff cap work correctly | **PASS** |
| 4. Save-load preserves Specialist state | **PASS** |
| 5. HUD displayed costs match actual spend | **PASS** |
| 6. Soft StaffPanel parked — non-blocking | **PASS** (soft noted) |
| Nack truth leaks (`true_market` / `p_buy` / `cert_valid` in UI) | **PASS** — 0 hits |

| Supporting | Result |
|------------|--------|
| Tip SHA confirmed | **`2e31966a27e6b0764752ca0e8c09aeee837ec3d5`** (tarball root) |
| Foundation `test_runner` | **PASS** — `All foundation tests passed.` |
| Formal Specialist smoke | **PASS** — **79 PASS / 0 FAIL**; `SOFT_COUNT=7` |
| S0–S3 (severity rubric) | **None found** for this tip |

**Overall: PASS-with-notes**

Specialist staff path clears the formal pass bar on Normal at tip `2e31966a`. Soft Eng nits (Easy/Hard `.tres` omissions + StaffPanel polish / thin wireflows / no Specialist mesh) are explicitly parked and non-blocking.

## Pass-bar checklist

| # | Check | Observed | Verdict |
|---|-------|----------|---------|
| 1a | Owner Research Att **15** | `research_attention=15`; `ShopState.research_attention_cost()` = 15 with no Specialist; HUD OpenResearch `Att 15` | **PASS** |
| 1b | Owner Inspect Att **5** | `inspect_attention=5`; `inspect_attention_cost()` = 5; HUD Inspect★ `Att 5` | **PASS** |
| 2a | Specialist Research **10** | Hire → `research_attention_cost()` = 10; live `research_set(AA-SKIE)` `attention_spent=10`, Att 100→90; still $50 cash (−5000¢) | **PASS** |
| 2b | Specialist Inspect **2** | `inspect_attention_cost()` = 2; foundation HUD Inspect★ spends Att 2 (100→98) with label `Att 2` | **PASS** |
| 3a | Hire under Small cap | `hire_specialist()` ok; role `specialist`; wage **14000**; second hire / cashier blocked at cap 1 | **PASS** |
| 3b | Fire restores owner costs | `fire_staff(0)` → count 0; Research 15 / Inspect 5; HUD Fire restores `Att 15` / `Att 5` labels | **PASS** |
| 3c | Medium staff cap 3 | Expand → cap 3; cashier + Specialist + cashier; fourth hire blocked | **PASS** |
| 4 | Save-load Specialist | `capture_save` staff size 1; restore role/wage/costs (Research 10 / Inspect 2); no truth in save | **PASS** |
| 5 | HUD costs = spend | Labels Att 15/5 → after hire Att 10/2; Research confirm Att 10; live spend Att −10 + cash −5000 matches labels | **PASS** |
| 6 | Soft StaffPanel parked | Panel starts hidden; opens for hire/fire; functional OK; polish/mesh/wireflow soft (see nits) | **PASS** (soft) |
| Nack | UI truth leaks | Scanned `hud.gd`, `demand_signal_presenter.gd`, `main_menu.gd`, `gameplay_hud.tscn`, `hud.tscn`, `main_menu.tscn` — **0** tokens; HUD label asserts clean | **PASS** |

## Key measured evidence

| Surface | Key numbers |
|---------|-------------|
| Balance Normal | Research 15 / Specialist 10; Inspect 5 / Specialist 2; wage $140/day; Small cap 1 / Medium 3 |
| Domain live Research (Specialist) | Att 100→90 (−10); cash 800000→795000 (−5000¢); `attention_spent=10` |
| HUD Research path | Confirm label Att 10; Att 100→90; cash 800000→795000 |
| Hire / fire / cap | Small blocks #2; Medium roster 3 (2 cashier + 1 Specialist); fire restores owner costs |
| Save-load | `restored_role=specialist`, wage 14000, Research 10, Inspect 2 |
| Truth scan | `truth_scan_leaks: []` |

## Design SoT alignment

- **systems §6 Staff:** Specialist wage ~$140/day; Inspect 5→2; Research/inspect domain; cashiers still sell at Att 0 (unchanged; foundation coverage).
- **Option A:** Specialist on duty → Research 15→~10.
- **ui-wireflows:** Truth nacks clear; Staff hire wireflow remains thin (soft — systems/Option A carry SoT; HUD implements hire/fire).
- **Out of scope (tip):** Specialist GLB, Easy/Hard `.tres` overrides, docs/ edits — soft parked as expected.

## Soft Eng nits (non-blocking)

1. **`easy.tres` / `hard.tres` omit `research_attention_specialist`** — script default 10. Prefer mirroring for diff clarity. (**S4**)
2. **`easy.tres` / `hard.tres` omit `inspect_attention_specialist`** — script default 2. (**S4**)
3. **`easy.tres` / `hard.tres` omit `specialist_wage_cents`** — script default 14000. (**S4**)
4. **Soft StaffPanel parked** — functional hire/fire/cap + wage labels OK; no Specialist mesh (`visual_scene_path` empty; `StaffPresenter` cashier-only); thin ui-wireflows Staff hire detail. Pass bar marks non-blocking. (**S4**)

## Findings (severity-ranked)

### S0–S3
**None.**

### S4 (soft)
See Soft Eng nits above. Do not fail tip.

## Harness / evidence

| Artifact | Path |
|----------|------|
| Report | `/workspace/card-shop-qa/playtest-specialist-2e31966a.md` |
| Foundation log | `/workspace/card-shop-qa/evidence/specialist-2e31966a/foundation.log` |
| Import log | `/workspace/card-shop-qa/evidence/specialist-2e31966a/import.log` |
| Smoke log | `/workspace/card-shop-qa/evidence/specialist-2e31966a/smoke.log` |
| Smoke JSON | `/workspace/card-shop-qa/evidence/specialist-2e31966a/specialist_smoke.json` |
| Smoke harness (tip copy) | `/workspace/qa-playtest/tip24/tests/qa_specialist_staff_smoke.gd` |
| Smoke harness (QA copy) | `/workspace/card-shop-qa/qa_specialist_staff_smoke.gd` |
| Tip tree | `/workspace/qa-playtest/tip24/` (tarball `2e31966a…`) |

## Verdict line

**PASS-with-notes** @ tip `2e31966a27e6b0764752ca0e8c09aeee837ec3d5` — Specialist Attention discounts, hire/fire/cap, save-load, HUD cost match, and truth nack clear; StaffPanel soft polish parked.
