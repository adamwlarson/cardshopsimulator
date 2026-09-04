# Playtest report — Price + Buylist @ `a7e5aab` (PR #6 merged to main)
**Scorer:** CSS QA  
**Date:** 2026-09-04 (ET)  
**Build:** `adamwlarson/cardshopsimulator` tip `a7e5aab58880c2bac924361670a1f8a03d976564` (extracted tree `…-a7e5aab58880c2bac924361670a1f8a03d976564`)  
**Mode:** **Normal** (`data/balance/normal.tres`)  
**Scope:** LIGHT regression — multi-SKU price editor + live buylist **You offer** HUD + warm-up A–F + truth nack + BuyOpportunityList §10 #1/#2  
**Method:** Headless Godot 4.5.2 — foundation `tests/test_runner.gd` + new `tests/qa_price_buylist_regress.gd`

## Executive verdict

| Gate | Result |
|------|--------|
| Truth leak nack (`true_market` / exact `p_buy` / `cert_valid` in UI) | **PASS** — no S1 |
| Foundation unit tests | **PASS** (`All foundation tests passed.`) |
| Warm-up A–F | **PASS** (automated) |
| Multi-SKU price editor (not hardcoded `AA-DUST-ETB` only) | **PASS** — `priceable_stock_signals()` + `PriceInventoryList`; ≥4 stocked SKUs selectable |
| Pricing §4.5 B / noisy suggest on selected SKUs | **PASS** |
| Buylist live seller HUD **You offer** (§3.2a) | **PASS** — `buylist_seller_summary` + `SELLING_TO_SHOP` + `accept_buylist` |
| §10 #1 Price Dustway ETB | **PASS** (still in priceable list + price path) |
| §10 #2 BuyOpportunityList Dustway + distributor MOQ | **PASS** (no regression) |
| MVP §10 full beat set (#4/#6/#7/#8) | **PARTIAL** — still no Spike/hype/slab/rent UI hooks (out of this light scope) |

**Overall:** **PASS** for PR #6 light regression (multi-SKU price + live You offer buylist + prior list fairness). Day-loop shell remains green on Normal warm-up and §10 #1/#2 without truth leaks.

## Warm-up A–F (observed)

| Beat | Result | Evidence |
|------|--------|----------|
| A Orient | PASS | Cash `$8000.00` (800000¢), Day 1 PREP, seed `AA-DUST-ETB` qty=2 |
| B First buy signals | PASS | Dustway marketplace + Skiefall distributor MOQ; A1–A6; Ask-labeled rows |
| C Price set | PASS | Multi-SKU list → select any stocked SKU; Dustway noisy suggest `$46.30`, Competitive, Should Move, Shelf |
| D Floor | PASS | `start_floor` → FLOOR; attention spend works |
| E Settle | PASS | `start_settle` → SETTLE; cash defined |
| F Day 2 adapt | PASS | day 2 PREP; buy list + multi-SKU priceable stock still available |

## Multi-SKU price editor (PR #6)

| Check | Result | Evidence |
|-------|--------|----------|
| HUD opens list not sole Dustway | **PASS** | `_open_price_list` → `DemandSignals.priceable_stock_signals()`; no hardcoded `&"AA-DUST-ETB"` in `hud.gd` |
| Select among stocked SKUs | **PASS** | Rows: `AA-SKIE-BLST` ×4, `AA-DUST-ETB` ×2, `ACC-SLV-60` ×4, `ACC-TOP-25` ×2 |
| Apply uses selected `sku_id` | **PASS** | `_apply_price` → `InventoryService.set_listed_price(_price_signal.sku_id, …)` |
| §4.5 B on non-Dustway select | **PASS** | B1–B6 + `Suggested (noisy):` on alt SKU; `refresh_price_signal` OK |
| Stock rows use **Your list** (not Ask / You offer) | **PASS** | `priceable_stock_row` |

Sample priceable rows:
```
Skiefall Ascension Blaster · AA-SKIE-BLST ×4
Your list $29.99 · Shelf

Dustway Chronicles Explorer Box · AA-DUST-ETB ×2
Your list $44.99 · Shelf
```

Sample price presenter (Dustway §10 #1):
```
Suggested (noisy): $46.30
Vs suggestion: -$1.31 (-3%)
Position: Competitive · Demand: STEADY
Move feel: Should Move · Shelf
```

## Buylist **You offer** (live seller HUD)

| Context | Expected | Observed |
|---------|----------|----------|
| Customer buying from shop | **Your list** | Presenter + HUD buyer path (`CUSTOMER_BUYING_FROM_SHOP` + `listed_price_cents`) |
| Buylist (customer selling to shop) | **You offer** | HUD `SELLING_TO_SHOP` → `DemandSignalPresenter.buylist_seller_summary`; Sell = "Buy at offer"; `accept_buylist` |
| Shop buying BuyOpportunity | **Ask** | `buy_summary` / opportunity rows still **Ask** |

Sample seller presenter:
```
Selling: Dustway Chronicles Explorer Box ×1
You offer: $24.74 each · $24.74 total
Comp range: $43.91 – $48.41
Demand: STEADY · Confidence: Medium
Condition: Mixed lot
```

Wiring: `customer_spawner` builds `buylist_signal`; `customer_queue.accept_buylist_offer`; foundation tests cover enqueue/accept + label helper.

## MVP §10 #1 / #2 (no regression)

| Beat | Result | Evidence |
|------|--------|----------|
| #1 Price Dustway ETBs | **PASS** | Still in priceable list; listed_price + §4.5 B1–B6 |
| #2 Distributor MOQ + Dustway in list | **PASS** | Same catalog rows; HUD still binds `open_buy_signals()` — no hardcoded `AA-SKIE-ETB` |

Sample opportunity rows:
```
Marketplace · Dustway Chronicles Explorer Box · AA-DUST-ETB ×2
Ask $48.00 · STEADY · Low confidence

Distributor · Skiefall Ascension Blaster · AA-SKIE-BLST ×8
Ask $144.00 · STEADY · High confidence
```

## Findings (severity-ranked)

### S1 — Critical / truth leak
**None.** UI sources (`hud.gd`, `demand_signal_presenter.gd`, `main_menu.gd`) contain no `true_market` / `p_buy` / `cert_valid`. Buy/Price/buylist presenter strings clean. DTOs have no truth-named properties in harness scan.

### S2 — Major
**None for this slice.** Prior aafe7d34 S3 (single-SKU price editor) and missing live You offer HUD path are **resolved** by PR #6.

### S3 — Minor
1. **Named staples / bulk** seeded but not all appear in `get_priceable_stock()` rows (harness saw 4 sealed/accessory SKUs). Acceptable if intentional filter; players can still multi-select among stocked sealed+ACC.
2. **Remaining §10 beats #4/#6/#7/#8** still unreachable (Spike / rent fire-sale / hype / slab) — hold formal 3–5 player §10.

### S4 — Polish / note
3. Price list stock rows correctly use **Your list**; seller path uses **You offer**; buy opps use **Ask** — §3.2a triad intact.
4. Prior UI S2 BuyOpportunityList behavior unchanged.

## Commands re-run
```
cd /workspace/qa-playtest/tip6/cardshopsimulator-a7e5aab58880c2bac924361670a1f8a03d976564
godot --headless --path . --import
godot --headless --path . --script res://tests/test_runner.gd
godot --headless --path . --script res://tests/qa_price_buylist_regress.gd
```
Harness log: `/workspace/card-shop-qa/evidence/playtest-a7e5aab.log`  
Harness source: `…/tests/qa_price_buylist_regress.gd` (**170 PASS / 0 FAIL**)  
Foundation: **All foundation tests passed.**

## Recommendation to PM
- **Clear** PR #6 light regression: multi-SKU price editor + live buylist **You offer** HUD + prior list/fairness gates green on Normal.
- **Clear** warm-up A–F and §10 #1/#2 for Eng-Approve of this tip.
- **Hold** full formal §10 until #4/#6/#7/#8 content hooks exist.
