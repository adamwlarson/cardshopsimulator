# Playtest report — R1 STOP Flagship win assert @ `f4021222` (main post-Q1)

**Scorer:** CSS QA (executor)  
**Date:** 2026-09-06 (~5:22 PM ET)  
**Build:** `adamwlarson/cardshopsimulator` tip **`f4021222c344a5f65e59958dc9810d0d2eec6b9c`** (tree `/workspace/qa-playtest/r1-flagship-f4021222/`)  
**Tip note:** docs-only ahead of Q1 merge `116ad889` (PR #46); ancestry confirmed (`116ad889` is ancestor of tip). Intermediate docs: `7ef4ef11`, `67f3f08`, `d4cb7b1`, `99db244`.  
**Mode:** **Normal** (`data/balance/normal.tres`)  
**Godot:** 4.5.2.stable.official.6ce3de25a (`/workspace/godot452`)  
**Scope:** Formal R1 STOP — Flagship path reachability (systems §9); L1 Large gate coherence; win/Flagship detect assert; negatives; Soft parked / Won't-Fix fold (R2 hygiene); optional Survive Y1 / Liquidity king spot-check; no new verbs; §4.5 clean (no win UI touched)  
**Method:** Headless — import `--editor --quit-after 120` + foundation `tests/test_runner.gd` + SceneTree harness `tests/qa_r1_flagship_smoke.gd` (seed/force Large + Rep≥80 + cash≥$50k; no new verbs)  
**Design SoT:** `docs/design/next-eng-sot-pick-r-v1.md` § R1; systems §9 Flagship = Own Large + Rep ≥ 80 + cash ≥ $50k  
**Priors:** Q1 Supply glut `b727a84a`; L1 Large `49f0153a`; H2 campaign `8a7f7a73`  
**No Art.** Soft Eng notes: Soft seed `_ensure_priceable_sku`, Soft far crest, Soft Fri spill Soft OK, Soft EventBanner rumor Soft OK, Soft flipper-weight Soft OK, Soft `apply_medium_capacity` — keep parked / Won't-Fix fold.

## Executive verdict

| Gate (Designer bar) | Result |
|---------------------|--------|
| 1. Flagship reachability (Own Large + Rep≥80 + cash≥$50k) — state achievable | **PASS** (QA §9 predicate) |
| 1b. Game win/Flagship detect / award when predicate met | **FAIL — S2 blocker** |
| 2. Large lease + Rep/cash gates coherent with L1 ($40k+Rep70 Sign; Flagship distinct) | **PASS** |
| 3. No new verbs; Soft callout (parked / Won't-Fix list) | **PASS** |
| 4. Optional Survive Y1 / Liquidity king spot-check | **PASS** (thresholds present; same unwired class — Soft note) |
| 5. §4.5 clean (no win screen; HUD/menu/beat truth scan) | **PASS** — 0 UI truth leaks |

| Supporting | Result |
|------------|--------|
| Tip SHA confirmed | **`f4021222c344a5f65e59958dc9810d0d2eec6b9c`** (`docs(design): re-sync pick-r Status Adopted R1`) ≥ `116ad889` |
| Import `--editor --quit-after 120` | **PASS** — EXIT:0 |
| Foundation `test_runner` | **PASS** — `All foundation tests passed.` EXIT:0 |
| Formal R1 smoke harness | **FAIL** — **68 PASS / 4 FAIL / 7 SOFT** |
| Soft Eng notes disposition | **Non-blocking** — keep parked / Won't-Fix fold; do **not** open R2 |
| S0–S2 (severity rubric) | **S2:** Flagship win detect/award absent (BalanceConfig thresholds only) |

**Overall: FAIL**

Flagship **state** is reachable on Normal (L1 Large Sign path + Rep/cash seed). **Win detect is not wired:** `flagship_cash_cents` / Survive Y1 / Liquidity king live only on `BalanceConfig` + `.tres`; no runtime consumer, no EventBus win signal, no HUD/menu Flagship victory surface. Meeting §9 leaves `is_game_active=true` with no award.

**Clear Eng S2+?** **YES** — wire Flagship win check/award (and ideally campaign-mode select) against systems §9; Eng owns S2+.

## Pass-bar checklist

| # | Check | Observed | Verdict |
|---|-------|----------|---------|
| 1a | Seed/force Own Large | `expand_to_large` / BeatInjection `sign_lease` → tier Large, 18×13 | **PASS** |
| 1b | Rep ≥ 80 + cash ≥ $50k | exact `5_000_000¢` + Rep 80; overshoot 95 / $60k | **PASS** (state) |
| 1c | QA systems §9 predicate | `tier==LARGE && rep≥80 && cash≥flagship_cash` true | **PASS** |
| 1d | Game Flagship detect/award | no `flagship_cash_cents` consumer outside config; no win API/signal/UI | **FAIL S2** |
| 2a | L1 Sign Cash≥$40k + Rep≥70 | still gates; exact gate Signs; below nacks | **PASS** |
| 2b | Flagship gates distinct | $50k > $40k; Rep 80 > Rep 70; L1-only state is **not** Flagship | **PASS** |
| 3a | Negatives | cash $49,999.99; Rep 79; Medium+$50k+Rep80; L1-only | **PASS** (QA predicate) |
| 3b | No new verbs | EventBus has no flagship signal; Soft unused | **PASS** |
| 3c | Soft parked list | seed / far crest / Fri spill Soft OK / EventBanner Soft OK / flipper-weight Soft OK / `apply_medium_capacity` | **PASS** (soft) |
| 4 | Survive Y1 / Liquidity | floors $100k / Rep 40 present; runtime unwired (same class) | **PASS** (optional note) |
| 5 | §4.5 | hud / main_menu / presenter / beat_injection — no `true_market`/`p_buy`/`cert_valid` UI leaks; no win screen touched | **PASS** |

## Key measured evidence

| Surface | Key numbers |
|---------|-------------|
| Tip | `f4021222c344a5f65e59958dc9810d0d2eec6b9c` (docs-only ahead of `116ad889`) |
| L1 Sign | cash `4_000_000¢` ($40k); Rep **70** |
| Flagship SoT | Own Large + Rep **80** + cash `5_000_000¢` ($50k) |
| Survive Y1 floor | Rep **40** (day 365 design; threshold only) |
| Liquidity king | `10_000_000¢` ($100k) |
| Positive exact | tier **2** Large; cash **5000000**; rep **80**; `qa_predicate_met=true`; `detect_fired=false` |
| Negative cash | `4_999_999` → predicate false |
| Negative Rep | **79** → predicate false |
| Negative Medium | tier Medium + Rep80 + $50k → false |
| Negative L1-only | Large + Rep70 + $40k → false (gates distinct) |
| Win scan | consumers `[]`; win_api_hits `[]` |
| Harness | **68 PASS / 4 FAIL / 7 SOFT** |
| Foundation | `All foundation tests passed.` EXIT:0 |
| Import | EXIT:0 |

## Design SoT alignment

- **pick-r / R1:** STOP Flagship win assert; Eng S2+ only if blockers need code — **triggered**.
- **systems §9.2 Flagship:** Own Large + Rep ≥ 80 + cash ≥ $50k — **state reachable; award missing**.
- **L1 coherence:** Sign Large still Cash≥$40k+Rep70; Flagship stricter and distinct.
- **R2 Soft hygiene:** Folded into Soft callout — **keep parked / Won't-Fix list**; do not open R2.
- **Out of scope (honored):** No new verbs; no Art; R3 cameras / R4 far crest parked; no Eng code in this STOP.

## Soft policy recommendation (R2 fold)

**Recommend: keep parked / Won't-Fix list.** Do **not** open R2 Soft hygiene from this stop.

| Soft item | Disposition |
|-----------|-------------|
| Soft seed `_ensure_priceable_sku` | **Keep parked / Won't-Fix candidate.** HYPE/FOG bridge only; unused by Flagship. |
| Soft far crest | **Parked (Art R4).** Unused by Flagship assert. |
| Soft Fri spill Soft OK | **Keep parked / Won't-Fix MVP.** Unused. |
| Soft EventBanner rumor Soft OK | **Keep parked / Won't-Fix MVP.** Unused. |
| Soft flipper-weight Soft OK | **Keep parked / Won't-Fix MVP.** Unused. |
| Soft `apply_medium_capacity` naming | **Keep parked.** Large still calls for stacked capacity; hygiene-only. |

## Findings (severity-ranked)

### S2 — Flagship win detect/award absent
**Summary:** BalanceConfig exports `flagship_cash_cents` (Normal $50k) plus Survive Y1 / Liquidity king floors, but **no runtime consumer** awards or detects Flagship when Own Large + Rep≥80 + cash≥$50k. No EventBus win/prestige signal; no GameState/Economy/BeatDirector win API; no HUD/main_menu Flagship victory UI.  
**Impact:** Campaign Flagship mode cannot complete; player can reach the SoT state without a win.  
**Disposition:** **Clear Eng S2+ YES** — implement detect (settle/day or explicit check), campaign-mode binding, and thin win surface (§4.5 clean). Softs stay parked.

### Soft / notes
See Soft policy table. Optional Survive Y1 / Liquidity king same unwired class (informational Soft).

## Blockers
1. **S2** Flagship win detect/award missing (see above).

## Evidence paths

- Checkout: `/workspace/qa-playtest/r1-flagship-f4021222/`
- Evidence: `/workspace/card-shop-qa/evidence/r1-f4021222/` (`import.log`, `foundation.log`, `qa_r1_smoke.log`, `smoke.json`)
- Harness: `tests/qa_r1_flagship_smoke.gd` (+ copy `/workspace/card-shop-qa/qa_r1_flagship_smoke.gd`)
- Reports: `/workspace/card-shop-qa/playtest-r1-flagship-f4021222.md` and `/workspace/card-shop-qa/docs/qa/playtest-r1-flagship-f4021222.md`

## Clear Eng S2+?

**YES** — S2 Flagship win detect/award needs Eng code. Softs remain parked (no R2). Path reachability of the §9 **state** is green; **win assert** fails until detect ships.

---

*End of R1 Flagship formal report @ `f4021222`.*
