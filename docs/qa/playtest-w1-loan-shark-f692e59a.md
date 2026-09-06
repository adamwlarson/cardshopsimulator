# Playtest report — W1 Loan shark / soft-fail formal smoke @ `f692e59a` (PR #54)

**Scorer:** CSS QA (executor)  
**Date:** 2026-09-06 (~6:55 PM ET)  
**Build:** `adamwlarson/cardshopsimulator` tip **`f692e59af52f1e9c183dc6ead1434425be017d79`** (short `f692e59a`) — PR #54 *W1 Loan shark / soft-fail polish (first bankruptcy recovery)*  
**Checkout:** `/workspace/qa-playtest/w1-f692e59a/`  
**Modes:** **Easy** / **Normal** / **Hard** (`data/balance/{easy,normal,hard}.tres`)  
**Godot:** 4.5.2.stable.official.6ce3de25a (`/workspace/godot452`)  
**Scope:** Formal W1 smoke after Eng APPROVE-with-notes — first-bankruptcy loan-shark offer; Accept applies terms + 40-day daily drain; Refuse = `refused_loan_shark` game over (no continue-without-loan); Hard `loan_shark_enabled=false` instant over; second bankruptcy after Accept = over (recovery once); §4.5 clean; Soft catalog CLOSED; save/load recovery flag + drain days; No Art  
**Method:** Headless — import `--editor --quit-after 120` + foundation `tests/test_runner.gd` (includes `_test_loan_shark_soft_fail`) + focused SceneTree harness `tests/qa_w1_loan_shark_smoke.gd`  
**Design SoT:** `docs/design/next-eng-sot-pick-w-v1.md` Adopted W1 GO; systems §9.3; `docs/design/difficulty-curves-v1.md` Easy/Normal/Hard loan table  
**Priors:** V1 Camera unlock #51; U1 Soft hygiene #50  
**Art:** none required (thin LoanShark / GameOver HUD panels only). Soft Easy scalars Soft OK MVP; Soft catalog closed.

## Executive verdict

| Gate (Designer bar) | Result |
|---------------------|--------|
| 1. Easy/Normal first bankruptcy shows offer; Accept applies terms; daily drain fires 40 days | **PASS** |
| 2. Refuse = game over (`refused_loan_shark`); no continue-without-loan | **PASS** |
| 3. Hard: `loan_shark_enabled=false` — no offer, instant game over | **PASS** |
| 4. Second bankruptcy after Accept = game over (recovery once) | **PASS** |
| 5. §4.5 clean; Soft catalog untouched; save/load recovery flag + drain days | **PASS** |
| 6. Foundation EXIT:0; harness covering Easy/Normal/Hard paths | **PASS** |

| Supporting | Result |
|------------|--------|
| Tip SHA confirmed | **`f692e59af52f1e9c183dc6ead1434425be017d79`** (`Add first-bankruptcy loan shark recovery on Easy/Normal.`) |
| Import `--editor --quit-after 120` | **PASS** — EXIT:0 |
| Foundation `test_runner` (`_test_loan_shark_soft_fail`) | **PASS** — `All foundation tests passed.` EXIT:0 |
| Formal W1 smoke harness | **PASS** — **91 PASS / 0 FAIL**; `SOFT_COUNT=4` |
| Soft Easy scalars Soft OK MVP | **Non-blocking** — Easy +$6k / −$150/day ×40 / Rep −5 vs Normal SoT +$5k / −$200/day ×40 / Rep −10 (`difficulty-curves`) |
| Soft catalog CLOSED | **PASS** — no `loan_shark` / camera-unlock reopen in `events.json` |
| S0–S2 (severity rubric) | **None found** for this tip |

**Overall: PASS-with-notes**

W1 loan shark / soft-fail clears the formal pass bar on Easy/Normal/Hard at tip `f692e59a`. Soft Easy scalars Soft OK MVP called out; Soft catalog closed; No Art. Instrumented Easy Accept: cash **+600000¢**, Rep **−5**, drain **40×15000¢**; Normal Refuse → `campaign_lost` reason **`refused_loan_shark`**; Hard first miss → **`missed_rent`** with empty offer; second bankruptcy after Accept → **`missed_rent`** with no re-offer; save/load keeps `loan_shark_recovery_used` + remaining drain days (**39** after one settle).

**Clear for merge?** **YES** (PASS-with-notes; soft only).

## Pass-bar checklist

| # | Check | Observed | Verdict |
|---|-------|----------|---------|
| 1a | Normal SoT terms | +$5k (500000¢) / −$200/day (20000¢) ×40 / Rep −10 | **PASS** |
| 1b | Easy Soft OK scalars | +$6k (600000¢) / −$150/day (15000¢) ×40 / Rep −5 | **PASS** (Soft OK) |
| 1c | Easy first bankruptcy offer | `loan_shark_offer_pending`; payload cash/daily/rep Easy; not lost; day advance blocked | **PASS** |
| 1d | Easy Accept + 40-day drain | Accept → cash +600000; Rep −5; `settle_payday_loan` ×40; total −600000; loan ends | **PASS** |
| 1e | Normal first bankruptcy offer | offer cash 500000 / daily 20000 / days 40 / rep 10 | **PASS** |
| 2a | Refuse = game over | `refuse_loan_shark` → `campaign_lost`; reason `refused_loan_shark` | **PASS** |
| 2b | No continue-without-loan | `is_game_active=false`; `advance_day` false | **PASS** |
| 3a | Hard enabled=false | `HARD_CONFIG.loan_shark_enabled=false` | **PASS** |
| 3b | Hard no offer / instant over | offer empty; lost reason `missed_rent`; Accept unavailable | **PASS** |
| 4 | Second bankruptcy | after Accept, recovery_used; re-trigger → no offer; lost `missed_rent` | **PASS** |
| 5a | §4.5 UI / payloads | HUD body/title clean; offer/lose payloads 0 truth keys; hud/presenter scan 0 leaks | **PASS** |
| 5b | Soft catalog untouched | `events.json` has 0 `loan_shark` / camera unlock; SH1 seed parked | **PASS** |
| 5c | Save/load | `loan_shark_recovery_used` + `payday_loan_days_remaining` (39) round-trip | **PASS** |
| 5d | HUD Normal modal | title `Loan shark`; body `$5,000.00` / `$200.00` / `40` / `10` / "Refuse is game over"; Accept starts drain | **PASS** |
| 5e | Hard HUD | no LoanShark; GameOver title `Game over` | **PASS** |
| 6 | Foundation + harness | foundation EXIT:0; harness **91/0/4** Easy+Normal+Hard | **PASS** |

## Soft Easy scalars Soft OK MVP (callout)

| Mode | Cash | Daily × days | Rep hit | Source |
|------|------|--------------|---------|--------|
| **Normal** (SoT §9.3 / pick-w) | +$5,000 (500000¢) | −$200 (20000¢) ×40 | −10 | systems §9.3; `normal.tres` |
| **Easy** (Soft OK MVP) | +$6,000 (600000¢) | −$150 (15000¢) ×40 | −5 | `difficulty-curves-v1.md`; `easy.tres` |
| **Hard** | — (disabled) | — | — | `loan_shark_enabled=false` |

Eng APPROVE-with-notes: Easy softer scalars are **Soft OK MVP** (non-blocking). Soft catalog stays **CLOSED**. No Art.

## Key measured evidence

| Surface | Key numbers |
|---------|-------------|
| Tip | `f692e59af52f1e9c183dc6ead1434425be017d79` (PR #54 head) |
| Easy offer QA | `loan_shark_offered` cash **600000** daily **15000** days **40** rep_hit **5** reason `missed_rent` |
| Easy Accept QA | `loan_shark_resolved` outcome **accept**; cash after loan **600000¢**; after 40 drains **0¢** |
| Normal offer QA | cash **500000** daily **20000** days **40** rep_hit **10** |
| Normal Refuse QA | outcome **refuse**; `campaign_lost` reason **`refused_loan_shark`**; cash 0 day 7 |
| Hard QA | no `loan_shark_offered`; `campaign_lost` reason **`missed_rent`**; `loan_offered:false` |
| Second bankruptcy | recovery_used; lost **`missed_rent`**; `loan_offered:true` (prior accept) |
| HUD body (Normal) | `First bankruptcy. Take the shark loan or fold.` + `$5,000.00` / `−$200.00/day for 40 days` / `Rep −10` / `Refuse is game over.` |
| Save/load | remaining **39** after 1 settle; restore keeps recovery + **39** days |
| Truth scan | `truth_scan_leaks: []` |
| Soft catalog | `events.json` loan_shark count **0** |
| Harness | **91 PASS / 0 FAIL / 4 SOFT** |
| Foundation | `All foundation tests passed.` EXIT:0 (`_test_loan_shark_soft_fail` + ~80 expects) |
| Import | EXIT:0 |

## Soft disposition (this tip)

| Soft | Disposition | This tip |
|------|-------------|----------|
| Soft Easy loan scalars (+$6k/−$150×40/Rep−5) | **Soft OK MVP** | Confirmed vs Normal SoT; non-blocking |
| Soft catalog reopen | **CLOSED** | Untouched — no loan_shark event / no camera unlock |
| Soft far crest / Soft seed (SH1) | Art later / Won't-Fix | Not reopened; `_ensure_priceable_sku` still parked |
| Art LoanShark prop | **N/A** | Panel-only UI; No Art required |

## Evidence paths

| Artifact | Path |
|----------|------|
| Playtest report | `/workspace/card-shop-qa/playtest-w1-loan-shark-f692e59a.md` |
| Docs mirror | `/workspace/card-shop-qa/docs/qa/playtest-w1-loan-shark-f692e59a.md` |
| Import log | `/workspace/card-shop-qa/evidence/w1-f692e59a/import.log` |
| Foundation log | `/workspace/card-shop-qa/evidence/w1-f692e59a/foundation.log` |
| Harness log | `/workspace/card-shop-qa/evidence/w1-f692e59a/qa_w1_smoke.log` |
| Smoke JSON | `/workspace/card-shop-qa/evidence/w1-f692e59a/smoke.json` |
| Harness script | `/workspace/card-shop-qa/qa_w1_loan_shark_smoke.gd` (+ tip `tests/qa_w1_loan_shark_smoke.gd`) |

## Blockers

**None.** Clear for merge (PASS-with-notes; Soft Easy scalars Soft OK MVP only).
