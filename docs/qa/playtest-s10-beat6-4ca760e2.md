# Playtest report — MVP §10 beat #6 rent/fire-sale @ `4ca760e2` (PR #9 → main)
**Scorer:** CSS QA  
**Date:** 2026-09-04 (~2:27 AM ET)  
**Build:** `adamwlarson/cardshopsimulator` tip `4ca760e2` (tree `/workspace/qa-playtest/tip9/`)  
**Mode:** **Normal** (`data/balance/normal.tres`); Hard loan-hide cross-check (`hard.tres`)  
**Scope:** Formal §10 #6 First rent due + soft shelf (day ~7) + Undercut ×0.90 vs −8% Competitive boundary + Hard loan hide + rent-at-SETTLE + truth nack + light smoke #4/#7/#8 / warm-up / buy list  
**Method:** Headless Godot 4.5.2 — foundation `tests/test_runner.gd` + new `tests/qa_s10_beat6_playtest.gd`  
**Design SoT:** `docs/design/ui-wireflows-v1.md` §5.1 `sec10_6_rent_firesale` (sha256 `7896ec37a3e90ff4b485dac2a74d8cd87be7783062c5288adc1394153e05da86`); systems-design §4.5 / §10; difficulty-curves (Hard `loan_shark_enabled=false`)

## Executive verdict

| Gate | Result |
|------|--------|
| Truth leak nack (`true_market` / exact `p_buy` / `cert_valid` in UI) | **PASS** — no S1 |
| Foundation unit tests | **PASS** (`All foundation tests passed.`) |
| Warm-up A–F + BuyOpportunityList #1/#2 + You offer | **PASS** |
| §10 #6 rent/fire-sale reachable (Normal day 7 PREP) | **PASS** — natural + QA / `_start_day_beats` |
| Undercut fill = ×0.90 (exact −8% → Competitive) | **PASS** — HUD `* 0.90`; ×0.90→undercut; boundary→competitive |
| Hard loan shark hidden | **PASS** — payload `loan_enabled=false`; `take_payday_loan` fails |
| Rent still at SETTLE | **PASS** — dismiss/loan do not auto-pay; ledger rent on SETTLE only |
| Light smoke #4 / #7 / #8 | **PASS** |

**Overall:** **PASS** for formal MVP §10 beat #6 (rent/fire-sale) on Normal at tip `4ca760e2`.

## Executive table

| Check | Reachable / behavior | Fairness / truth | Verdict |
|-------|----------------------|------------------|---------|
| #6 `sec10_6_rent_firesale` | Day 7 PREP (Normal `first_rent_due_day=7`); modal “Rent due today — shelf is soft”; fire-sale / cut accessories / payday loan / dismiss | No truth tokens in payload or PriceEditor path | **PASS** |
| Undercut ×0.90 | HUD fills `suggested_price_cents * 0.90`; focus mode `&"undercut"` | ×0.90 δ≈−10.0% → **Undercut**; exact −8% → **Competitive** (SoT `<−8%`) | **PASS** |
| Hard loan | Hard beat starts; `loan_enabled=false`; HUD `rent_loan_button.visible` gated | N/A | **PASS** |
| Rent SETTLE | Dismiss leaves cash unchanged through FLOOR; SETTLE charges `rent_small_weekly_cents` (120000¢) | HUD “Due at SETTLE” / “Rent still due at SETTLE” | **PASS** |

## Warm-up A–F + light regression (observed)

| Beat | Result | Evidence |
|------|--------|----------|
| A Orient | PASS | Cash `$8000.00` (800000¢), Day 1 PREP, seed `AA-DUST-ETB` qty=2 |
| B First buy signals | PASS | Dustway marketplace + distributor MOQ; Ask rows; A1–A6 |
| C Price set | PASS | Multi-SKU priceable; Dustway noisy suggest `$45.35` |
| D Floor | PASS | `start_floor` → FLOOR; attention spend OK |
| E Settle | PASS | `start_settle` → SETTLE (no day-1 rent) |
| F Day 2 | PASS | day 2 PREP |
| You offer / #1/#2 | PASS | buylist seller + Dustway priceable + open buy ≥2 |

## §10 #6 — First rent due + soft shelf

| Check | Result | Evidence |
|-------|--------|----------|
| `beat_id` | PASS | `sec10_6_rent_firesale` |
| Preconditions | PASS | Day 7 = `first_rent_due_day`; Dustway sealed in stock; soft shelf → **STEADY** band |
| Trigger PREP modal | PASS | title “Rent due today — shelf is soft”; `rent_cents=120000` |
| Fire-sale sealed | PASS | focuses `AA-DUST-ETB`; suggestion_mode `&"undercut"`; PriceEditor path |
| Cut accessories | PASS | focuses `ACC-*`; undercut mode; completes on Apply |
| Payday loan (Normal) | PASS | `loan_enabled=true`; +$5000 cash; Rep −10; still rent+daily at SETTLE |
| Dismiss | PASS | completes with warning path; **no** rent ledger until SETTLE |
| Natural day 7 | PASS | advancing PREP→FLOOR→SETTLE→day lands day-7 PREP and starts beat |
| HUD wired | PASS | RentDecision / FireSale / Accessories / Loan / Dismiss; loan visibility gated |

Sample #6 result blob:
```
triggered=true title="Rent due today — shelf is soft"
fire_sale=true accessory=true loan_normal=true
focus_sku=AA-DUST-ETB focus_mode=undercut
dismiss_ok=true rent_at_settle=true no_prep_rent=true
payday_loan_path=true soft_band=steady ui_wired=true
```

## Undercut fill = ×0.90 (S2 gate)

| Check | Result | Evidence |
|-------|--------|----------|
| HUD fill factor | PASS | `suggested_price_cents * 0.90` (no `* 0.92`) |
| Position rule | PASS | `_position`: Undercut iff `delta_percent < -0.08` |
| ×0.90 fill | PASS | δ≈**−10.01%** → position **undercut** |
| Exact −8% boundary | PASS | listed at ceili(suggest×0.92) → δ≈**−7.998%** → **competitive** (not undercut) |

**Note:** `floori(suggest×0.92)` often still yields δ`<−8%` (integer truncation). Design Competitive is inclusive at −8%; Undercut fill must stay **strict ×0.90** so the fire-sale chip is reliably Undercut. Using ×0.92 as fill is S2 when suggest×0.92 is an exact integer (lands Competitive).

## Hard loan hidden

| Check | Result | Evidence |
|-------|--------|----------|
| `hard.tres` | PASS | `loan_shark_enabled=false` |
| Day-7 Hard payload | PASS | `loan_enabled=false` |
| `take_payday_loan()` | PASS | returns false; cash unchanged |
| `choose_rent_path(payday_loan)` | PASS | fails while pending |
| HUD | PASS | `rent_loan_button.visible = bool(payload.get("loan_enabled", false))` |

## Rent still at SETTLE

| Check | Result | Evidence |
|-------|--------|----------|
| Not on PREP/dismiss | PASS | cash unchanged after dismiss |
| Not on FLOOR | PASS | cash unchanged after `start_floor` |
| On SETTLE | PASS | cash −120000¢; ledger category `&"rent"` day 7 |
| After payday loan | PASS | SETTLE charges rent **and** loan daily (20000¢) |
| Economy ownership | PASS | `settle_day` → `settle_weekly_obligations` |

## Truth leak nack (S1)

| Surface | Result |
|---------|--------|
| `hud.gd` / `demand_signal_presenter.gd` / `main_menu.gd` | No `true_market` / `p_buy` / `cert_valid` |
| Buy/Price/buylist DTO property scan | No truth-named fields |
| Rent decision payload keys | Clean |
| Presenter strings (buy/price/seller/fire-sale refresh) | Clean |

## Light smoke — prior #4 / #7 / #8

| Beat | Result |
|------|--------|
| #4 Spike Bastion/Arcbolt | PASS — QA trigger + complete on refuse |
| #7 Titan hype | PASS — focus Titan; HOT; complete Cancel |
| #8 Showcase slab | PASS — choose slab completes |

## Findings (severity-ranked)

### S1 — Critical / truth leak
**None.**

### S2 — Major
**None.** Undercut fill is strict ×0.90; exact −8% correctly maps to Competitive per §4.5.

### S3 — Minor
1. Soft-shelf helper forces demand band **`steady`** (design allows Steady/**Cold**). Acceptable for MVP reachability; Cold path not separately exercised.
2. Natural day-advance through days 3–5 also arms Spike (#4) — expected; #6 still starts cleanly on day 7 PREP.

### S4 — Polish / note
3. Foundation `test_runner.gd` already covers a subset of #6 (fire-sale focus, dismiss→SETTLE, Hard loan hide); this formal harness adds Undercut ×0.90 boundary, accessory/loan paths, natural day-7, truth nack, and prior-beat smoke.
4. Prior tip7 gap (“#6 first rent / soft shelf still out of formal slice”) is **closed** at `4ca760e2`.

## Commands re-run
```
cd /workspace/qa-playtest/tip9
godot --headless --path . --import
godot --headless --path . --script res://tests/test_runner.gd
godot --headless --path . --script res://tests/qa_s10_beat6_playtest.gd
```
Harness log: `/workspace/card-shop-qa/evidence/playtest-4ca760e2.log`  
Harness source: `tip9/tests/qa_s10_beat6_playtest.gd` (also `/workspace/card-shop-qa/qa_s10_beat6_playtest.gd`)  
Automated gates: **811 PASS / 0 FAIL** (+ foundation all passed)

## Recommendation to PM
- **Clear** formal MVP §10 #6 rent/fire-sale on Normal at `4ca760e2` — reachable day 7, three decision paths + dismiss, rent timing correct, Hard loan hidden, Undercut ×0.90 intact, fairness green.
- **Clear** Eng-Approve for PR #9 rent/fire-sale beat hooks relative to wireflows §5.1 / systems §4.5+§10.
- Optional: soft-shelf Cold band variant; polish only.
