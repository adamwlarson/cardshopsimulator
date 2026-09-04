# Playtest report — MVP §10 optional beats #3/#5/#9/#10 @ `cefe6bef` (PR #16 tip)
**Scorer:** CSS QA  
**Date:** 2026-09-04 (~12:45 PM ET)  
**Build:** `adamwlarson/cardshopsimulator` tip `cefe6befb325aefe7be5f07b5ca8feae7f213054` (tree `/workspace/qa-playtest/tip16/`)  
**Mode:** **Normal** (`data/balance/normal.tres`); Hard/Easy cross-checks where Design calls them out  
**Scope:** Formal optional MVP §10 #3 Marketplace outing · #5 Hire cashier · #9 Expand Medium · #10 Shady trunk + truth nack + soft Undercut ×0.90 + Day1 Prep seed + light warm-up A–F  
**Method:** Headless Godot 4.5.2 — foundation `tests/test_runner.gd` + formal `tests/qa_s10_optional_playtest.gd` (HUD live BeatDecision presses + domain APIs); xvfb viewport shot of #3 modal  
**Design SoT:** `docs/design/ui-wireflows-v1.md` §5.1 `sec10_3_marketplace_outing` / `sec10_5_hire_cashier` / `sec10_9_expand_medium` / `sec10_10_shady_trunk`; systems-design §10; `docs/qa/mvp-1.0-release-criteria.md` S0–S4 + truth-leak rules

## Executive verdict

| Gate | Result |
|------|--------|
| Truth leak nack (`true_market` / exact `p_buy` / `cert_valid` in UI) | **PASS** — no S1 |
| Foundation unit tests | **PASS** (`All foundation tests passed.`) |
| Formal optional harness | **PASS** — **467 PASS / 0 FAIL**; `HUD_LIVE=true` |
| Soft Undercut ×0.90 (if touched) | **PASS** — `UNDERCUT_FILL_FACTOR=0.90`; HUD uses `undercut_fill_cents` |
| Day1 Prep seed intact | **PASS** — cash `$8000.00` (800000¢); `AA-DUST-ETB` qty=2; PREP day 1 |
| Soft Eng nits alone | **Non-blocking** (S4 only) |

**Overall:** **PASS-with-notes** for formal optional MVP §10 #3/#5/#9/#10 on Normal at tip `cefe6bef`. No S0–S3. Soft Eng nits do not fail the tip.

## Executive table (per-beat)

| Beat | Reachable | Options exercised | Fairness / truth | Verdict |
|------|-----------|-------------------|------------------|---------|
| #3 `sec10_3_marketplace_outing` | Day 3 PREP natural + `_start_day_beats` / QA | **Drive out** / **Courier fee** / **Skip** | Low conf + Photo only; §4.5 Ask/Comp/Demand/Condition; no truth tokens | **PASS** |
| #5 `sec10_5_hire_cashier` | Day 5 PREP natural | **Hire Cashier** / **Keep solo** / **Hire cheap** | $80/day · Rel ~0.85; cheap confirm Reliability/theft warning; wages at SETTLE; Small cap blocks 2nd | **PASS** |
| #9 `sec10_9_expand_medium` | Day 18–25 PREP natural | **Sign lease** / **Wait for Rep** / **Stay Small** | Soft-fail gate text; Sign gated until cash≥$15k & Rep≥55; Medium rent next week; grid/staff/case upgrade | **PASS** |
| #10 `sec10_10_shady_trunk` | Day 20–30 PREP after expand resolves | **Buy** / **Report** / **Ignore** | Shady Low + inspect cue; Report +5 Rep / no stock; Buy keeps fog | **PASS** |

## Warm-up A–F + soft checks (observed)

| Check | Result | Evidence |
|-------|--------|----------|
| A Orient | PASS | Cash `$8000.00`, Day 1 PREP, seed Dustway ETB qty=2 |
| B First buy | PASS | open buy ≥1 |
| C Price set | PASS | priceable ≥1 |
| D Floor | PASS | `start_floor` |
| E Settle | PASS | `start_settle` |
| F Day 2 | PASS | day 2 PREP |
| Undercut ×0.90 | PASS | presenter + HUD (not ×0.92) |
| Truth UI scan | PASS | `hud.gd` / presenter / `main_menu.gd` — no forbidden tokens |

## §10 #3 — Marketplace outing

| Check | Result | Evidence |
|-------|--------|----------|
| Title | PASS | `Off-site lot — leave the floor?` |
| Design options | PASS | Drive out · Courier fee · Skip (HUD buttons match) |
| Inject lot | PASS | `marketplace-outing-steal` · channel marketplace · Low · Photo only · underpriced vs noisy mid |
| Drive out | PASS | Attention −25; `pending_floor_skip_seconds=34`; opens BuyOpportunityDetail; completes |
| Courier | PASS | cash −$35; no floor skip; detail focus; confirm_buy OK |
| Skip | PASS | dismisses opportunity; completes |
| Natural day 3 | PASS | auto-start on Normal day 3 PREP |
| Hard | PASS | no auto-start |
| Truth / §4.5 | PASS | Ask/Comp/Demand/Confidence/Condition/After buy; no truth leaks |

Sample HUD labels:
```
Drive out
Attention 25 · miss 1–2 FLOOR hours

Courier fee
Pay $35.00 · keep the FLOOR

Skip
Pass on the lot
```

## §10 #5 — Hire first cashier

| Check | Result | Evidence |
|-------|--------|----------|
| Title | PASS | `Counter’s getting slammed — hire help?` |
| Design options | PASS | Hire Cashier · Keep solo · Hire cheap |
| Hire Cashier | PASS | roster +1; wage 8000¢; Rel 0.85; no theft bias; wage at SETTLE; cap blocks 2nd |
| Hire cheap | PASS | HUD confirm Reliability warning; Rel ≤0.55; theft_bias; wage 4500¢ at SETTLE |
| Keep solo | PASS | no staff; no wage at SETTLE |
| Easy trainee | PASS | no auto-start; QA refuses when cap filled |
| Natural day 5 | PASS | auto-start |
| Truth | PASS | payload / labels clean |

## §10 #9 — Expand to Medium

| Check | Result | Evidence |
|-------|--------|----------|
| Title | PASS | `Landlord offered Medium unit — sign?` |
| Design options | PASS | Sign lease · Wait for Rep · Stay Small |
| Soft-fail gates | PASS | Sign disabled without cash/Rep; summary explains missing gate; Stay always on |
| Wait for Rep | PASS | stays Small; completes |
| Stay Small | PASS | tier Small; rent unchanged next week |
| Sign lease | PASS | HUD confirm old→new rent + staff cap; Medium tier; staff cap 3; grid 12×11; case +12; signed-day rent Small; day+rent Medium |
| Natural day 18 | PASS | auto-start |
| Hard | PASS | no auto-start; QA can open; cannot Sign at start cash |
| Truth | PASS | confirm body / payload clean |

## §10 #10 — Shady trunk

| Check | Result | Evidence |
|-------|--------|----------|
| Title | PASS | `Trunk sale — too good?` |
| Design options | PASS | Buy · Report · Ignore |
| Inject lot | PASS | `shady-trunk-lot` · shady · Low · inspect strongly recommended |
| Buy | PASS | opens BuyOpportunityDetail; lot remains with fog |
| Report | PASS | +5 Rep; no inventory delta; lot dismissed |
| Ignore | PASS | lot dismissed; completes |
| Serialization | PASS | blocked while expand pending; starts day 20 after Stay Small |
| Natural day 20 | PASS | after expand resolved in day advance |
| Hard | PASS | no auto-start |
| Truth / §4.5 | PASS | Ask + Low + Condition; no `cert_valid` in UI |

## Truth leak nack (S1)

| Surface | Result |
|---------|--------|
| `hud.gd` / `demand_signal_presenter.gd` / `main_menu.gd` | No `true_market` / `p_buy` / `cert_valid` |
| BeatDecision payloads (#3/#5/#9/#10) | Clean |
| BuyConfirmSignal properties | No truth-named fields |
| Presenter buy_summary (outing + shady) | Clean |
| QA instrumentation payloads | May contain truth when force-enabled (debug path; default off) — **not** UI |

## Findings (severity-ranked)

### S0 — Blocker
**None.**

### S1 — Critical / truth leak
**None.**

### S2 — Major
**None.**

### S3 — Minor
**None.**

### S4 — Soft Eng nits (non-blocking; do **not** fail tip)
1. **BeatDecision has no Escape/X close** — player must pick one of the three Design options (each beat includes a no-op: Skip / Keep solo / Stay Small / Ignore). Matches “warn, don’t soft-lock” spirit; optional polish only.
2. **`choose_beat_path` is first-pending-wins** (outing → hire → expand → shady). HUD disables Open floor until a choice is made, so a player cannot stack PREP decisions. Domain-only overlap is not a player path.
3. **DayClock elapsed float after Drive FLOOR** observed `≈34.0108` vs configured `34.0` after one process frame — skip was correctly queued then consumed (`pending→0`). Source wiring in `day_clock.gd` is correct; float epsilon only.

## Evidence paths

| Artifact | Path |
|----------|------|
| Formal report | `/workspace/card-shop-qa/playtest-s10-optional-cefe6bef.md` |
| Harness log | `/workspace/card-shop-qa/evidence/s10-optional-cefe6bef.log` |
| Structured results | `/workspace/card-shop-qa/evidence/s10-optional-cefe6bef.json` |
| Foundation log | `/workspace/card-shop-qa/evidence/s10-optional-cefe6bef-foundation.log` |
| #3 viewport shot | `/workspace/card-shop-qa/evidence/s10-optional-cefe6bef-beat3.png` |
| Capture log | `/workspace/card-shop-qa/evidence/s10-optional-cefe6bef-capture.log` |
| Harness source | `/workspace/qa-playtest/tip16/tests/qa_s10_optional_playtest.gd` (copy `/workspace/card-shop-qa/qa_s10_optional_playtest.gd`) |
| Tip tree | `/workspace/qa-playtest/tip16/` (tarball SHA `cefe6bef…`) |

## Commands re-run
```
cd /workspace/qa-playtest/tip16
godot --headless --path . --import
godot --headless --path . --script res://tests/test_runner.gd
godot --headless --path . --script res://tests/qa_s10_optional_playtest.gd
xvfb-run -a -s "-screen 0 1280x720x24" godot --path . --script res://tests/qa_s10_optional_capture.gd
```
Automated gates: **foundation PASS**; formal optional **467 PASS / 0 FAIL**; HUD live formal (not PARTIAL).

## Recommendation to PM
- **Clear** formal optional MVP §10 #3 / #5 / #9 / #10 on Normal at `cefe6bef` (PR #16 tip) — injectable, naturally reachable in day windows, Design option labels present, state mutations match SoT, fairness/truth gates green.
- Soft Eng nits (S4) only — **do not fail** tip for these alone.
- Optional polish: Escape/X on BeatDecision; DayClock epsilon if anyone asserts exact float equality.
