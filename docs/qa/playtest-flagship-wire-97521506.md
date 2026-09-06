# Playtest report — Flagship win-wire re-smoke @ `97521506` (PR #47 Eng S2+ fix)

**Scorer:** CSS QA (executor)  
**Date:** 2026-09-06 (~5:39 PM ET)  
**Build:** `adamwlarson/cardshopsimulator` tip **`975215067403f4d10dc51958cb97a9c6803f4288`** (short `97521506`) — PR #47 *Wire Flagship win detect/award*  
**Checkout:** `/workspace/qa-playtest/flagship-wire-97521506/`  
**Mode:** **Normal** (`data/balance/normal.tres`)  
**Godot:** 4.5.2.stable.official.6ce3de25a (`/workspace/godot452`)  
**Scope:** Formal Flagship win-wire re-smoke after Eng APPROVE-with-notes. Prior R1 FAIL @ `f4021222` was missing win detect/award. Softs parked; no R2; no Art.  
**Method:** Headless — import `--editor --quit-after 120` + foundation `tests/test_runner.gd` (expects `_test_flagship_win_award`) + SceneTree harness `tests/qa_r1_flagship_smoke.gd`  
**Design SoT:** systems §9 Flagship = Own Large + Rep ≥ 80 + cash ≥ $50k; `BalanceConfig.meets_flagship()`; `GameState.evaluate_campaign_win()` → `campaign_won` + deactivate  
**Prior FAIL:** `/workspace/card-shop-qa/playtest-r1-flagship-f4021222.md`  
**No Art.** Soft Eng notes stay parked / Won't-Fix fold (no R2).

## Executive verdict

| Gate (Designer / Eng bar) | Result |
|---------------------------|--------|
| 1. `BalanceConfig.meets_flagship()` — Large + Rep≥80 + cash≥flagship_cash_cents | **PASS** |
| 2. Runtime award once via `GameState.evaluate_campaign_win()` → campaign_won + deactivate (`is_game_active=false`, prestige flagship) | **PASS** |
| 3. Thin HUD/menu Flagship surfaces; §4.5 clean | **PASS** |
| 4. Negatives: cash under / Rep 79 / Medium / L1-only stay no-award | **PASS** |
| 5. L1 Sign gates unchanged ($40k+Rep70) | **PASS** |
| 6. Soft dual cash-eval Soft OK if award idempotent | **PASS** (Soft OK) |
| 7. Survive Y1 / Liquidity Soft OK this beat (stay unwired) | **PASS** (Soft OK) |
| 8. Soft seed / far crest / Fri spill Soft OK / EventBanner Soft OK / flipper Soft OK / apply_medium_capacity parked; no R2 | **PASS** |
| 9. No Art; no new player verbs | **PASS** |

| Supporting | Result |
|------------|--------|
| Tip SHA confirmed | **`975215067403f4d10dc51958cb97a9c6803f4288`** (`Bind Flagship checks from cash, Sign, and session start.`) |
| Import `--editor --quit-after 120` | **PASS** — EXIT:0 |
| Foundation `test_runner` (incl. `_test_flagship_win_award`) | **PASS** — `All foundation tests passed.` EXIT:0 |
| Formal re-smoke harness | **PASS-with-notes** — **128 PASS / 0 FAIL / 8 SOFT** |
| Prior R1 S2 (missing win detect/award) | **CLOSED** |
| Soft Eng notes disposition | **Non-blocking** — keep parked; do **not** open R2 |
| Clear for merge | **YES** |

**Overall: PASS-with-notes**

Prior S2 blocker is closed: Flagship §9 predicate is consumed at runtime; exact Large+Rep80+$50k awards once (`campaign_complete`, `last_prestige=flagship`, `is_game_active=false`, `EventBus.campaign_won`). Negatives and L1 Sign remain distinct. Softs stay parked.

**Clear for merge?** **YES**

## Pass-bar checklist

| # | Check | Observed | Verdict |
|---|-------|----------|---------|
| 1a | `BalanceConfig.meets_flagship` exact / rejects | Large+80+$50k true; cash-under & Medium false | **PASS** |
| 1b | `GameState.meets_flagship` / `evaluate_campaign_win` | APIs present; award fires | **PASS** |
| 1c | Award once → deactivate + prestige | `campaign_complete`; `is_game_active=false`; `last_prestige=flagship` | **PASS** |
| 1d | `campaign_won` payload | mode flagship; cash 5_000_000; Rep 80; tier Large; §4.5 clean | **PASS** |
| 1e | SETTLE + cash_changed paths | SETTLE awards; income cent-cross awards | **PASS** |
| 2a | L1 Sign Cash≥$40k + Rep≥70 | still gates; exact Signs; below nacks | **PASS** |
| 2b | L1 Sign does not award Flagship | evaluate false; stays active; no signal | **PASS** |
| 3a | Negatives no-award | cash $49,999.99; Rep 79; Medium+$50k+Rep80; L1-only | **PASS** |
| 3b | Idempotent second evaluate | first true; second false; sticky complete | **PASS** |
| 3c | Soft dual cash-eval | Soft OK — award idempotent | **PASS** (soft) |
| 4 | Survive Y1 / Liquidity | floors present; runtime unwired | **PASS** (soft) |
| 5 | Thin HUD/menu | CampaignWin + Flagship title; Campaign: Flagship; last prestige | **PASS** |
| 6 | §4.5 | hud / main_menu / presenter / beat_injection / game_state — no truth leaks | **PASS** |
| 7 | Soft parked list | seed / far crest / Fri spill Soft OK / EventBanner Soft OK / flipper Soft OK / apply_medium_capacity | **PASS** (soft) |
| 8 | No new verbs / no Art | prestige signal only; Soft seed unused on Flagship surfaces | **PASS** |

## Key measured evidence

| Surface | Key numbers |
|---------|-------------|
| Tip | `975215067403f4d10dc51958cb97a9c6803f4288` (PR #47 head) |
| L1 Sign | cash `4_000_000¢` ($40k); Rep **70** |
| Flagship SoT | Own Large + Rep **80** + cash `5_000_000¢` ($50k) via `flagship_rep` / `flagship_cash_cents` |
| Survive Y1 floor | Rep **40** (threshold only; unwired) |
| Liquidity king | `10_000_000¢` ($100k) (threshold only; unwired) |
| Positive exact | tier Large; cash **5000000**; rep **80**; award **true**; `is_game_active=false`; prestige **flagship** |
| Negative cash | `4_999_999` → no award; stays active |
| Negative Rep | **79** → no award |
| Negative Medium | tier Medium + Rep80 + $50k → no award |
| Negative L1-only | Large + Rep70 + $40k → no award |
| Idempotent | 2nd `evaluate_campaign_win` → false |
| Harness | **128 PASS / 0 FAIL / 8 SOFT** |
| Foundation | `All foundation tests passed.` EXIT:0 (incl. `_test_flagship_win_award`) |
| Import | EXIT:0 |

## Design SoT alignment

- **pick-r / R1 Eng S2+:** Wire Flagship win detect/award — **shipped and re-smoked green**.
- **systems §9.2 Flagship:** Own Large + Rep ≥ 80 + cash ≥ $50k — **predicate + award wired**.
- **L1 coherence:** Sign Large still Cash≥$40k+Rep70; Flagship stricter and distinct; Sign alone does not award.
- **R2 Soft hygiene:** Softs parked — **do not open R2**.
- **Out of scope (honored):** No Art; Survive Y1 / Liquidity stay unwired; no new player verbs beyond thin win surface.

## Soft policy recommendation (parked; no R2)

**Recommend: keep parked / Won't-Fix list.** Do **not** open R2 Soft hygiene from this re-smoke.

| Soft item | Disposition |
|-----------|-------------|
| Soft dual cash-eval Soft OK | **Soft OK** — award idempotent (SETTLE skip + cash_changed / second evaluate). |
| Survive Y1 / Liquidity unwired | **Soft OK this beat** — Flagship only; thresholds present. |
| Soft seed `_ensure_priceable_sku` | **Keep parked / Won't-Fix candidate.** Unused by Flagship win-wire. |
| Soft far crest | **Parked (Art R4).** Unused. |
| Soft Fri spill Soft OK | **Keep parked / Won't-Fix MVP.** Unused. |
| Soft EventBanner rumor Soft OK | **Keep parked / Won't-Fix MVP.** Unused. |
| Soft flipper-weight Soft OK | **Keep parked / Won't-Fix MVP.** Unused. |
| Soft `apply_medium_capacity` naming | **Keep parked.** Large still calls for stacked capacity; hygiene-only. |

## Findings (severity-ranked)

### Prior S2 — CLOSED
**Summary:** Win detect/award is wired. `BalanceConfig.meets_flagship()` + `GameState.evaluate_campaign_win()` → `_award_flagship()` sets `campaign_complete`, `last_prestige=flagship`, `is_game_active=false`, emits `EventBus.campaign_won`. Hooks on SETTLE, cash posts (non-SETTLE), reputation, layout/Sign. Thin HUD CampaignWin + main_menu Campaign/prestige copy.  
**Impact:** Campaign Flagship mode can complete. Prior R1 FAIL @ `f4021222` closed.  
**Disposition:** **Clear for merge YES.** Softs remain parked (no R2; no Art).

### Soft / notes
See Soft policy table. No blockers.

## Blockers
None.

## Evidence paths

- Checkout: `/workspace/qa-playtest/flagship-wire-97521506/`
- Evidence: `/workspace/card-shop-qa/evidence/flagship-wire-97521506/` (`import.log`, `foundation.log`, `qa_r1_smoke.log`, `smoke.json`)
- Harness: `tests/qa_r1_flagship_smoke.gd` (+ copy `/workspace/card-shop-qa/qa_r1_flagship_smoke.gd`)
- Reports: `/workspace/card-shop-qa/playtest-flagship-wire-97521506.md` and `/workspace/card-shop-qa/docs/qa/playtest-flagship-wire-97521506.md`

## Clear for merge?

**YES** — prior S2 closed; award wired; negatives + L1 intact; Softs parked (no R2; no Art).

---

*End of Flagship win-wire re-smoke formal report @ `97521506`.*
