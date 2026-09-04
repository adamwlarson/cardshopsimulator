# Playtest report — Deepen Attention (Research + Rearrange) @ `c77941eb` (PR #19 rebased tip)

**Scorer:** CSS QA (executor)  
**Date:** 2026-09-04 (~2:05 PM ET)  
**Build:** `adamwlarson/cardshopsimulator` tip **`c77941eb841e7e709e9b9a220859a62fee2ff430`** (tree `/workspace/qa-playtest/tip19b/` from GitHub tarball)  
**NOT tested:** `8cc80739` (prior tip; ignored for this verdict)  
**Mode:** **Normal** (`data/balance/normal.tres`) — Easy/Hard soft omission notes only  
**Godot:** 4.5.2.stable.official.6ce3de25a (`/workspace/godot452`)  
**Scope:** Formal playtest — Research ($50 + Att 15 / Specialist ~10) + Rearrange (Att 10) deepen Attention  
**Method:** Headless — foundation `tests/test_runner.gd` + SceneTree harness `tests/qa_attention_deepen_playtest.gd` (domain Research/Rearrange + HUD player path + truth scan + SoT checks)  
**Design SoT:** `docs/design/next-eng-sot-pick-v1.md` Option A; `docs/design/systems-design-v1.md` §4.5 / §6.2; `docs/design/ui-wireflows-v1.md` (truth nacks); `docs/qa/mvp-1.0-release-criteria.md` S0–S4

## Executive verdict

| Gate (pass bar) | Result |
|-----------------|--------|
| 1. Research: **$50 + Att 15** (Specialist ~**10**); narrows comps/σ; no condition/cert truth | **PASS** |
| 2. Rearrange: **Att 10**; illegal pathing rejected **without** Att debit on fail | **PASS** |
| 3. Att **0** disables Research/Rearrange; cashiers still sell | **PASS** |
| 4. Inspect★ Specialist **5→2** still intact | **PASS** |
| 5. Soft Eng nits non-blocking | **PASS** (noted; do not fail tip) |
| Nack truth leaks (`true_market` / exact `p_buy` / `cert_valid` in UI) | **PASS** — 0 hits |

| Supporting | Result |
|------------|--------|
| Tip SHA confirmed | **`c77941eb841e7e709e9b9a220859a62fee2ff430`** (tarball root) |
| Foundation `test_runner` | **PASS** — `All foundation tests passed.` |
| Formal harness | **PASS** — **216 PASS / 0 FAIL**; `SOFT_COUNT=10` |
| S0–S3 (severity rubric) | **None found** for this tip |

**Overall: PASS-with-notes**

Deepen Attention (Research + Rearrange) clears the formal pass bar on Normal at tip `c77941eb`. Soft Eng nits (Easy/Hard `.tres` omissions + thin wireflows Research/Rearrange verbs) are non-blocking S4.

## Pass-bar checklist

| # | Check | Observed | Verdict |
|---|-------|----------|---------|
| 1a | Research cash **$50** + Att **15** (Normal owner) | `research_cost_cents=5000`; `research_attention=15`; live `research_set(AA-SKIE)` cash 800000→795000, Att 100→85; HUD Research confirm same | **PASS** |
| 1b | Specialist Research **15→~10** | `research_attention_specialist=10`; `ShopState.research_attention_cost()` 15→10 on duty; live debit Att 10 + still $50; HUD label `Att 10` | **PASS** |
| 1c | Narrows comps / σ | Domain fog width 1500 → researched 826; live payload sample 750→412; snapshot `demand_band_sigma` **0.12→0.07**; `research_comp_narrow_factor=0.55` | **PASS** |
| 1d | No condition / cert truth from Research | Condition cue stays fog (`Photo only — inspect recommended`); `inspected=false`; rotation watch text clean; DTO/payload nack of `true_market`/`p_buy`/`cert_valid` | **PASS** |
| 2a | Rearrange Att **10** on legal move | `rearrange_attention=10`; `rearrange_fixture(binder_rack→(1,5))` ok, `attention_spent=10`, Att 100→90 | **PASS** |
| 2b | Illegal pathing rejected; **no** Att debit | `(7,1)` → `ok=false`, `reason=blocked_path`, `attention_spent=0`, Att stays 90; HUD confirm disabled on illegal tile; preview `blocked_path` | **PASS** |
| 3a | Att 0 disables Research/Rearrange | Domain: `insufficient_attention` for both; HUD OpenResearch/OpenRearrange **disabled** at Att 0 | **PASS** |
| 3b | Cashiers still sell at Att 0 | `CustomerQueue.sell_listed()` succeeds with fake inventory while Att=0 | **PASS** |
| 4 | Inspect★ Specialist **5→2** intact | `inspect_attention=5`, `inspect_attention_specialist=2`; `inspect_attention_cost()` 5→2 on duty, back to 5 off duty | **PASS** |
| 5 | Soft alone non-blocking | 10 soft nits (see below) | **N/A / noted** |
| Nack | UI truth leaks | Scanned `hud.gd`, `demand_signal_presenter.gd`, `main_menu.gd`, `gameplay_hud.tscn`, `hud.tscn`, `main_menu.tscn` — **0** tokens | **PASS** |

## Key measured evidence

| Surface | Key numbers |
|---------|-------------|
| Balance Normal | Research $50 / Att 15 / Specialist 10; σ 0.12→0.07; narrow 0.55; Rearrange Att 10; Inspect 5 / Specialist 2 |
| Research live | Att 100→85 (−15), cash −5000¢; Specialist Att −10; fog width 1500→826; sample 750→412 |
| Rearrange live | Legal (1,5) spent 10 → Att 90; illegal (7,1) spent 0 stays 90 |
| HUD path | Research → Skiefall → Att 85 / cash 795000; illegal rearrange no debit; legal 85→75; Att0 buttons disabled |
| Truth scan | `truth_scan_leaks: []` |

## Design SoT alignment

- **next-eng-sot-pick Option A:** Research **$50 + Att 15**, Specialist **15→~10**, Rearrange **Att 10**, Inspect **5→2**, Att 0 cashiers still sell — harness asserts present.
- **systems §6.2:** Research set: 15; Rearrange layout: 10; Specialist inspect 5→2; Research does not reveal grade; σ 0.12 / 0.07.
- **ui-wireflows:** Truth nacks (`true_market` / `cert_valid`) present; **Research/Rearrange verb detail thin** (soft — Option A / systems carry SoT; HUD implements costs).
- **mvp-1.0-release-criteria:** S0–S4 defined; truth_market gate clear for this tip.

## Soft Eng nits (non-blocking)

1. **`ui-wireflows-v1.md` has no Rearrange verb wireflow** — Option A / systems §6.2 carry SoT; intentional no docs/ edits on this tip. (**S4**)
2. **`ui-wireflows-v1.md` has no Research verb detail** — same; HUD implements `$50 · Att 15` labels. (**S4**)
3. **`easy.tres` / `hard.tres` omit `research_attention_specialist`** — script default 10; Normal sets 10. Prefer mirroring for diff clarity. (**S4**)
4. **`easy.tres` / `hard.tres` omit `rearrange_attention=10`** — script default OK. (**S4**)
5. **`easy.tres` / `hard.tres` omit `inspect_attention_specialist=2`** — script default OK. (**S4**)
6. **`easy.tres` / `hard.tres` omit `inspect_attention=5`** — script default OK (also noted on Inspect★ tip). (**S4**)

## Findings (severity-ranked)

### S0–S3
**None.**

### S4 / notes
Soft Eng nits above only.

## Evidence paths

| Artifact | Path |
|----------|------|
| Formal report | `/workspace/card-shop-qa/playtest-attention-deepen-c77941eb.md` |
| QA harness (tip tree) | `/workspace/qa-playtest/tip19b/tests/qa_attention_deepen_playtest.gd` |
| QA harness (card-shop-qa copy) | `/workspace/card-shop-qa/qa_attention_deepen_playtest.gd` |
| Harness log | `/workspace/card-shop-qa/evidence/attention-deepen-c77941eb/playtest-attention-deepen-c77941eb.log` |
| Harness JSON | `/workspace/card-shop-qa/evidence/attention-deepen-c77941eb/playtest-attention-deepen-c77941eb.json` |
| Harness stdout | `/workspace/card-shop-qa/evidence/attention-deepen-c77941eb/attention_qa_stdout.txt` |
| Foundation log | `/workspace/card-shop-qa/evidence/attention-deepen-c77941eb/foundation_test_runner.txt` |
| Godot import log | `/workspace/card-shop-qa/evidence/attention-deepen-c77941eb/godot_import.txt` |
| Tip tree | `/workspace/qa-playtest/tip19b/` (tarball `tip19b.tar.gz`) |
| Runners | `/workspace/qa-playtest/run_tip19b_foundation.sh`, `run_tip19b_attention_qa.sh` |

## Tip confirmation

- Fetched: `https://github.com/adamwlarson/cardshopsimulator/archive/c77941eb.tar.gz`
- Archive root: `cardshopsimulator-c77941eb841e7e709e9b9a220859a62fee2ff430/`
- Short tip used in report/evidence: **`c77941eb`**
- Prior `/workspace` work on **`8cc80739`** was not used for this verdict tip SHA (harness ideas reused only).
