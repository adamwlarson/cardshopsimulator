# Playtest report — UI S2 @ `aafe7d34` (PR #5 merged to main)
**Scorer:** CSS QA  
**Date:** 2026-09-04 (ET)  
**Build:** `adamwlarson/cardshopsimulator` tip `aafe7d34` (extracted tree `…-aafe7d3`)  
**Mode:** **Normal** (`data/balance/normal.tres`)  
**Scope:** Domain/UI — BuyOpportunityList + §3.2a labels + warm-up A–F + MVP §10 #1/#2  
**Method:** Headless Godot 4.5.2 — foundation `tests/test_runner.gd` + updated `tests/qa_day_loop_playtest.gd` (warm-up A–F, list picker, §4.5 A/B, §3.2a, UI truth scan)

## Executive verdict

| Gate | Result |
|------|--------|
| Truth leak nack (`true_market` / exact `p_buy` / `cert_valid` in UI) | **PASS** — no S1 |
| §4.5 before-buy A1–A6 / before-price B1–B6 on DTOs + presenters | **PASS** |
| Warm-up A–F (orient → buy → price → floor → settle → day2) | **PASS** (automated) |
| §10 #1 Price Dustway ETB (`AA-DUST-ETB`) via HUD/price path | **PASS** |
| §10 #2 BuyOpportunityList Dustway + distributor MOQ (selectable) | **PASS** |
| §3.2a labels (Your list / You offer / Ask) | **PASS** |
| Foundation unit tests | **PASS** (`All foundation tests passed.`) |
| MVP §10 full beat set (#4/#6/#7/#8) | **PARTIAL** — still no Spike/hype/slab/rent UI hooks |

**Overall:** **PASS** for UI S2 exit (list picker + label rules + fairness). Day-loop shell is playable for Normal warm-up and §10 #1/#2 without truth leaks. Hold formal 3–5 player §10 arc until remaining beats land.

## Warm-up A–F (observed)

| Beat | Result | Evidence |
|------|--------|----------|
| A Orient | PASS | Cash `$8000.00` (800000¢), Day 1 PREP, seed `AA-DUST-ETB` qty=2 |
| B First buy signals | PASS | `open_buy_signals()` → Dustway marketplace lot + Skiefall distributor MOQ; A1–A6 on both; Ask-labeled rows |
| C Price set | PASS | PriceConfirmSignal on Dustway: noisy suggest `$46.69`, Competitive, Should Move, Shelf |
| D Floor | PASS | `start_floor` → FLOOR; attention spend works |
| E Settle | PASS | `start_settle` → SETTLE; cash still defined (no day-1 rent — weekly) |
| F Day 2 adapt | PASS | `advance_day` → day 2 PREP; open buy list still non-empty |

Sample opportunity rows:
```
Marketplace · Dustway Chronicles Explorer Box · AA-DUST-ETB ×2
Ask $48.00 · STEADY · Low confidence

Distributor · Skiefall Ascension Blaster · AA-SKIE-BLST ×8
Ask $144.00 · STEADY · High confidence
```

Sample buy presenter (no truth tokens):
```
Ask: $24.00 each · $48.00 total
Comp range: $44.83 – $51.57
Demand: STEADY · Confidence: Low
Condition: Photo only — inspect recommended
After buy: $7952.00 · Space: 1 needed / 40 free
```

Sample price presenter:
```
Suggested (noisy): $46.69
Vs suggestion: -$1.70 (-4%)
Position: Competitive · Demand: STEADY
Move feel: Should Move · Shelf
```

## MVP §10 #1 / #2

| Beat | Result | Evidence |
|------|--------|----------|
| #1 Price Dustway ETBs | **PASS** | Seed stock + HUD `PriceEditor` still targets `AA-DUST-ETB`; listed_price readable; §4.5 B1–B6 present |
| #2 Distributor MOQ + Dustway in list | **PASS** | Data `data/buy_opportunities.json` day 1–2: `dustway-marketplace-day-1` (`AA-DUST-ETB`) + `skiefall-distributor-moq-day-2` (`AA-SKIE-BLST` ×8, channel distributor, `beat_id=distributor_moq`). HUD `_open_buy_list` binds `DemandSignals.open_buy_signals()` — **no** hardcoded `AA-SKIE-ETB`. Player can select either row → `BuyOpportunityDetail`. |

## §3.2a labels

| Context | Expected | Observed |
|---------|----------|----------|
| Customer buying from shop | **Your list** | `DemandSignalPresenter.price_label(CUSTOMER_BUYING_FROM_SHOP)` = `Your list`; HUD customer serve uses that context + `listed_price_cents` (no `asking_price` misuse) |
| Buylist (customer selling to shop) | **You offer** | Presenter returns `You offer` (foundation `_test_ui_price_labels`); no full buylist customer HUD path yet (out of MVP wireflow §7) |
| Shop buying BuyOpportunity | **Ask** | `buy_summary` / `opportunity_row` use **Ask**; not “Your list” |

## Findings (severity-ranked)

### S1 — Critical / truth leak
**None.** UI sources (`hud.gd`, `demand_signal_presenter.gd`, `main_menu.gd`) contain no `true_market` / `p_buy` / `cert_valid`. Buy/Price DTOs have no truth-named properties. Presenter strings clean. `debug/qa_instrumentation=false` by default; foundation tests cover forced QA payloads separately.

### S2 — Major
**None for this slice.** Prior ff88fad S2 (hardcoded single `AA-SKIE-ETB` buy) is **resolved** by BuyOpportunityList + catalog JSON.

### S3 — Minor
1. **Price editor still single-SKU** (`hud.gd` `_open_price_editor` hardcodes `AA-DUST-ETB`). Fine for §10 #1, but players cannot price other stock from HUD yet.  
2. **Buylist “You offer” not exercised in live CustomerServe** — label API exists; no walk-in seller flow wired in HUD (known MVP-out per wireflows §7).  
3. **Remaining §10 beats #4/#6/#7/#8** still unreachable (Spike / rent fire-sale / hype / slab case) — same hold as prior tip for full formal playtest.

### S4 — Polish / note
4. Dustway day-1 buy opp is **marketplace** (not distributor); distributor MOQ is Skiefall Blaster — matches wireflows §5 beat table (`AA-SKIE-BLST` / ETB mix).  
5. Optional evidence board: `evidence/ui-s2-buy-list.png` (row copy from harness; not a live viewport grab).

## Commands re-run
```
cd /workspace/qa-playtest/tip5/adamwlarson-cardshopsimulator-aafe7d3
godot --headless --path . --import
godot --headless --path . --script res://tests/test_runner.gd
godot --headless --path . --script res://tests/qa_day_loop_playtest.gd
```
Harness log: `/workspace/card-shop-qa/evidence/playtest-aafe7d34.log`  
Harness source: `…/tests/qa_day_loop_playtest.gd` (98 PASS / 0 FAIL)

## Recommendation to PM
- **Clear** UI S2 exit: BuyOpportunityList + §3.2a + fairness/truth gates are green on Normal.  
- **Clear** warm-up A–F and §10 #1/#2 for Eng-Approve of this tip.  
- **Hold** 3–5 player full §10 formal until #4/#6/#7/#8 content hooks exist.  
- Optional next Eng: multi-SKU price picker; wire buylist seller path to **You offer** when that beat lands.
