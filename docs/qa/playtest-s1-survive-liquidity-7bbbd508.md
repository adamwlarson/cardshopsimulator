# Playtest report — S1 Survive Y1 + Liquidity king win-wire @ `7bbbd508` (PR #48)

**Scorer:** CSS QA (executor)  
**Date:** 2026-09-06 (~5:50 PM ET)  
**Build:** `adamwlarson/cardshopsimulator` tip **`7bbbd508995d95f907ab8a4c6c9759007b7adb97`** (short `7bbbd508`) — PR #48 *Wire Survive Year 1 and Liquidity king campaign wins*  
**Checkout:** `/workspace/qa-playtest/s1-7bbbd508/`  
**Mode:** **Normal** (`data/balance/normal.tres`)  
**Godot:** 4.5.2.stable.official (`/workspace/godot452`)  
**Scope:** Formal S1 smoke after Eng APPROVE-with-notes. Soft no mode-picker Soft OK MVP; Softs parked; no Art.  
**Method:** Headless — import `--editor --quit-after 120` + foundation `tests/test_runner.gd` (expects `_test_survive_y1_win_award` / `_test_liquidity_king_win_award`) + SceneTree harness `tests/qa_s1_survive_liquidity_smoke.gd`  
**Design SoT:** `docs/design/next-eng-sot-pick-s-v1.md` § S1; systems §9  
**Prior Flagship wire:** `/workspace/card-shop-qa/playtest-flagship-wire-97521506.md`  
**No Art.** Soft Eng notes stay parked / Won't-Fix fold.

## Executive verdict

| Gate (Designer / Eng bar) | Result |
|---------------------------|--------|
| 1. Survive Y1: day≥365 + cash>0 + Rep≥40 (Normal; Easy 30 / Hard 50) — award once; deactivate; no re-fire | **PASS** |
| 2. Liquidity king: month-end SETTLE (day%30==0) + cash≥$100k Normal ($75k Easy / $125k Hard) — award once; mid-month/non-SETTLE no award | **PASS** |
| 3. Campaign mode select: only selected mode awards (Flagship / Survive Y1 / Liquidity); Sandbox never awards | **PASS** |
| 4. Flagship path unchanged | **PASS** |
| 5. Thin HUD/menu prestige; §4.5 clean | **PASS** |
| 6. Soft no mode-picker Soft OK MVP (tests set `campaign_mode`) | **PASS** (Soft OK) |
| 7. Soft dual cash-eval Soft OK if idempotent | **PASS** (Soft OK) |
| 8. Soft seed / far crest / Fri spill Soft OK / EventBanner Soft OK / flipper Soft OK / apply_medium_capacity parked | **PASS** |
| 9. Negatives: day 364 / cash 0 / Rep-under / mid-month / cross-mode | **PASS** |

| Supporting | Result |
|------------|--------|
| Tip SHA confirmed | **`7bbbd508995d95f907ab8a4c6c9759007b7adb97`** (`Wire Survive Year 1 and Liquidity king campaign wins.`) |
| Import `--editor --quit-after 120` | **PASS** — EXIT:0 |
| Foundation `test_runner` (incl. Survive Y1 + Liquidity suites) | **PASS** — `All foundation tests passed.` EXIT:0 |
| Formal S1 harness | **PASS-with-notes** — **184 PASS / 0 FAIL / 9 SOFT** |
| Soft Eng notes disposition | **Non-blocking** — keep parked; Soft no mode-picker Soft OK MVP |
| Clear for merge | **YES** |

**Overall: PASS-with-notes**

Both Survive Year 1 and Liquidity king §9 predicates are consumed at runtime via `campaign_mode` select. Survive exact day365+Rep40+cash>0 awards once (`survive_y1`, deactivate). Liquidity month-end SETTLE + $100k awards once (`liquidity_king`); mid-month / PREP / FLOOR / cash-under stay no-award. Only selected mode awards; Sandbox never; Flagship path + L1 Sign intact. Softs parked.

**Clear for merge?** **YES**

## Pass-bar checklist

| # | Check | Observed | Verdict |
|---|-------|----------|---------|
| 1a | `BalanceConfig.meets_survive_y1` exact / rejects | day365+Rep40+cash1 true; day364 / cash0 / Rep39 false | **PASS** |
| 1b | Survive award once → deactivate + prestige | `campaign_complete`; `is_game_active=false`; `last_prestige=survive_y1` | **PASS** |
| 1c | Survive advance 364→365 awards | SETTLE advance_day lands day 365 + awards | **PASS** |
| 1d | Easy/Hard Survive floors | Easy Rep30 / Hard Rep50 thresholds present | **PASS** |
| 2a | `BalanceConfig.meets_liquidity_king` month-end | day30+$100k true; day29 / cash-under false; day60 true | **PASS** |
| 2b | Liquidity requires SETTLE | PREP/FLOOR meets_gs false even on day30+$100k | **PASS** |
| 2c | Liquidity SETTLE path | `start_floor`→`start_settle` awards `liquidity_king` | **PASS** |
| 2d | Mid-day cash spike no award | FLOOR income cross $100k → no award | **PASS** |
| 3a | Mode select isolation | Flagship≠Survive≠Liquidity; cross-mode no award | **PASS** |
| 3b | Sandbox never awards | Survive / Liquidity / Flagship gates all no-award | **PASS** |
| 4 | Flagship path unchanged | Large+Rep80+$50k awards `flagship`; L1 Sign no-award | **PASS** |
| 5a | Thin HUD/menu | Survive Year 1 / Liquidity king titles; Campaign/prestige labels | **PASS** |
| 5b | §4.5 | hud / main_menu / presenter / beat_injection / game_state — no truth leaks | **PASS** |
| 6 | Soft no mode-picker Soft OK MVP | harness sets `campaign_mode`; no ModePicker UI; document which mode awards | **PASS** (soft) |
| 7 | Soft dual cash-eval | Soft OK — award idempotent | **PASS** (soft) |
| 8 | Soft parked list | seed / far crest / Fri spill Soft OK / EventBanner Soft OK / flipper Soft OK / apply_medium_capacity | **PASS** (soft) |
| 9 | Negatives | day364 / cash0 / Rep39 / mid-month / cross-mode | **PASS** |

## Which mode awards (Soft no mode-picker Soft OK MVP)

Harness/tests set `GameState.campaign_mode` — no ModePicker UI this beat.

| `campaign_mode` | Mode id | Awards when |
|-----------------|---------|-------------|
| **0** | `flagship` | Own Large + Rep≥80 + cash≥$50k (unchanged) |
| **1** | `survive_y1` | day≥365 + cash>0 + Rep≥40 Normal (Easy 30 / Hard 50) |
| **2** | `liquidity_king` | month-end SETTLE (`day%30==0`) + cash≥$100k Normal ($75k Easy / $125k Hard) |
| **3** | `sandbox` | **never** |

## Key measured evidence

| Surface | Key numbers |
|---------|-------------|
| Tip | `7bbbd508995d95f907ab8a4c6c9759007b7adb97` (PR #48 head) |
| Survive Y1 SoT | day **365** + cash **>0** + Rep **40** Normal (Easy **30** / Hard **50**) |
| Liquidity king SoT | month-end SETTLE + cash `10_000_000¢` ($100k) Normal; Easy `7_500_000`; Hard `12_500_000` |
| Flagship intact | Own Large + Rep **80** + cash `5_000_000¢` ($50k) |
| L1 Sign | cash `4_000_000¢` ($40k) + Rep **70** — still gates; does not award Flagship |
| Survive positive | day **365**; cash **1**; rep **40**; award **true**; prestige **survive_y1**; inactive |
| Liquidity positive | day **30** SETTLE; cash **10000000**; award **true**; prestige **liquidity_king**; inactive |
| Survive negatives | day **364** / cash **0** / Rep **39** → no award |
| Liquidity negatives | day **29** / PREP / FLOOR / cash **9999999** / mid-FLOOR spike → no award |
| Idempotent | 2nd `evaluate_campaign_win` → false (Survive + Liquidity) |
| Harness | **184 PASS / 0 FAIL / 9 SOFT** |
| Foundation | `All foundation tests passed.` EXIT:0 (incl. `_test_survive_y1_win_award` + `_test_liquidity_king_win_award`) |
| Import | EXIT:0 |

## Design SoT alignment

- **pick-s / S1:** Wire Survive Year 1 + Liquidity king win-wire — **shipped and smoked green**.
- **systems §9 Survive Y1:** Day ≥ 365 + cash > 0 + Rep ≥ 40 — **predicate + award wired** (mode 1).
- **systems §9 Liquidity king:** End any month with cash ≥ $100k at SETTLE — **predicate + award wired** (mode 2).
- **Mode select:** only selected CampaignMode awards; Sandbox never; Flagship branch unchanged.
- **Soft no mode-picker Soft OK MVP:** tests/harness set `campaign_mode`; document which mode awards (table above).
- **Out of scope (honored):** No Art; Softs parked; no new player verbs beyond thin win surface.

## Soft policy recommendation (parked; no R2 / no Art)

**Recommend: keep parked / Won't-Fix list.** Soft no mode-picker Soft OK MVP confirmed.

| Soft item | Disposition |
|-----------|-------------|
| Soft no mode-picker Soft OK MVP | **Soft OK** — harness/tests set `campaign_mode`; no ModePicker UI; which mode awards documented; Flagship unchanged. |
| Soft dual cash-eval Soft OK | **Soft OK** — award idempotent (second evaluate false; sticky complete). |
| Soft seed `_ensure_priceable_sku` | **Keep parked / Won't-Fix candidate.** Unused by S1 win-wire. |
| Soft far crest | **Parked (Art).** Unused. |
| Soft Fri spill Soft OK | **Keep parked / Won't-Fix MVP.** Unused. |
| Soft EventBanner rumor Soft OK | **Keep parked / Won't-Fix MVP.** Unused. |
| Soft flipper-weight Soft OK | **Keep parked / Won't-Fix MVP.** Unused. |
| Soft `apply_medium_capacity` naming | **Keep parked.** Large still calls for stacked capacity; hygiene-only. |

## Findings (severity-ranked)

### S1 win-wire — SHIPPED / GREEN
**Summary:** Survive Y1 + Liquidity king detect/award wired. `BalanceConfig.meets_survive_y1` / `meets_liquidity_king` + `GameState.evaluate_campaign_win()` match on `campaign_mode` → `_award_campaign(mode)` sets `campaign_complete`, `last_prestige`, `is_game_active=false`, emits `EventBus.campaign_won`. Thin HUD CampaignWin titles + main_menu Campaign/prestige copy. Flagship path + L1 Sign unchanged.  
**Impact:** Campaign Survive Y1 and Liquidity king modes can complete. Cross-mode and Sandbox stay no-award.  
**Disposition:** **Clear for merge YES.** Softs remain parked (Soft no mode-picker Soft OK MVP; no Art).

### Soft / notes
See Soft policy table. No blockers.

## Blockers
None.

## Evidence paths

- Checkout: `/workspace/qa-playtest/s1-7bbbd508/`
- Evidence: `/workspace/card-shop-qa/evidence/s1-7bbbd508/` (`import.log`, `foundation.log`, `qa_s1_smoke.log`, `smoke.json`)
- Harness: `tests/qa_s1_survive_liquidity_smoke.gd` (+ copy `/workspace/card-shop-qa/qa_s1_survive_liquidity_smoke.gd`)
- Reports: `/workspace/card-shop-qa/playtest-s1-survive-liquidity-7bbbd508.md` and `/workspace/card-shop-qa/docs/qa/playtest-s1-survive-liquidity-7bbbd508.md`

## Clear for merge?

**YES** — Survive Y1 + Liquidity king scored; Flagship intact; mode-select + Sandbox correct; Softs parked (Soft no mode-picker Soft OK MVP; no Art).

---

*End of S1 Survive Y1 + Liquidity king formal report @ `7bbbd508`.*
