# Playtest report — T1 Campaign mode picker @ `605be23b` (PR #49)

**Scorer:** CSS QA (executor)  
**Date:** 2026-09-06 (~6:08 PM ET)  
**Build:** `adamwlarson/cardshopsimulator` tip **`605be23bc0da1f8369cf6e953599f33b796c4f43`** (short `605be23b`) — PR #49 *T1 Campaign mode picker on the main menu*  
**Checkout:** `/workspace/qa-playtest/t1-605be23b/`  
**Mode:** **Normal** (`data/balance/normal.tres`)  
**Godot:** 4.5.2.stable.official.6ce3de25a (`/workspace/godot452`)  
**Scope:** Formal T1 smoke after Eng APPROVE-with-notes. Soft Sandbox PBs Soft OK MVP; Soft no mode-picker closed by this tip; Softs otherwise parked; no Art.  
**Method:** Headless — import `--editor --quit-after 120` + foundation `tests/test_runner.gd` (expects `_test_campaign_mode_picker`) + SceneTree harness `tests/qa_t1_mode_picker_smoke.gd`  
**Design SoT:** `docs/design/next-eng-sot-pick-t-v1.md` § T1; systems §9 modes  
**Prior S1:** `/workspace/card-shop-qa/playtest-s1-survive-liquidity-7bbbd508.md`  
**No Art.** Soft catalog stays parked except Soft no mode-picker (CLOSED).

## Executive verdict

| Gate (Designer / Eng bar) | Result |
|---------------------------|--------|
| 1. Main-menu 2×2 text picker → `select_campaign_mode()` (menu/new-game only; mid-run rejected) | **PASS** |
| 2. Selection persists into `start_new_game`; only selected mode awards | **PASS** |
| 3. Modes: Flagship / Survive Y1 / Liquidity / Sandbox — Sandbox awards none | **PASS** |
| 4. Thin Sandbox PBs (day + cash); Soft Sandbox PB day-1 baseline Soft OK MVP | **PASS** (Soft OK) |
| 5. Closes Soft no mode-picker | **PASS** — **CLOSED** |
| 6. §4.5 clean; Soft catalog parked (seed/far crest/Fri spill/EventBanner/flipper/apply_medium_capacity/dual cash-eval) | **PASS** |
| 7. No Art; text UI OK | **PASS** |
| 8. Flagship / Survive / Liquidity win paths still work when selected | **PASS** |

| Supporting | Result |
|------------|--------|
| Tip SHA confirmed | **`605be23bc0da1f8369cf6e953599f33b796c4f43`** (`Put campaign mode buttons in the main menu scene.`) |
| Import `--editor --quit-after 120` | **PASS** — EXIT:0 |
| Foundation `test_runner` (incl. `_test_campaign_mode_picker`) | **PASS** — `All foundation tests passed.` EXIT:0 |
| Formal T1 harness | **PASS-with-notes** — **135 PASS / 0 FAIL / 9 SOFT** |
| Soft no mode-picker | **CLOSED** by this tip |
| Soft Eng notes disposition | **Non-blocking** — Soft Sandbox day-1 Soft OK MVP; Soft catalog otherwise parked |
| Clear for merge | **YES** |

**Overall: PASS-with-notes**

Player-facing main-menu 2×2 ModePicker (Flagship / Survive Year 1 / Liquidity king / Sandbox) writes `GameState.campaign_mode` via `select_campaign_mode()` (menu/new-game only). Selection persists into `start_new_game`; mid-run switch rejected. Only the selected mode awards; Sandbox awards none and tracks thin day+cash personal bests (save/menu). Soft no mode-picker from #48 is **closed**. Soft Sandbox PB day-1 baseline Soft OK MVP. Soft catalog otherwise parked; no Art.

**Clear for merge?** **YES**

## Pass-bar checklist

| # | Check | Observed | Verdict |
|---|-------|----------|---------|
| 1a | ModePicker 2×2 GridContainer + 4 buttons | columns=2; Flagship / Survive Year 1 / Liquidity king / Sandbox texts | **PASS** |
| 1b | Click → `select_campaign_mode` | Survive→1, Liquidity→2, Sandbox→3, Flagship→0; labels/blurbs follow | **PASS** |
| 1c | Mid-run rejected | active Survive run rejects Sandbox select; mode stays 1 | **PASS** |
| 2a | Persist into `start_new_game` | Flagship / Survive / Liquidity / Sandbox all persist | **PASS** |
| 2b | Only selected awards | Survive≠Flagship; Flagship≠Survive; Survive≠Liquidity | **PASS** |
| 3a | Flagship when selected | Large+Rep80+$50k awards `flagship`; deactivate | **PASS** |
| 3b | Survive when selected | day365+Rep40+cash>0 awards `survive_y1` | **PASS** |
| 3c | Liquidity when selected | day30 SETTLE + $100k awards `liquidity_king` | **PASS** |
| 3d | Sandbox awards none | meets all three gates; evaluate false; stays active/incomplete; no signal | **PASS** |
| 4a | Thin Sandbox PBs | day→390; cash→10_000_000; save/restore; menu SandboxBests visible | **PASS** |
| 4b | Soft Sandbox PB day-1 baseline Soft OK MVP | start_new_game records day **1** + cash **800000** | **PASS** (soft) |
| 5 | Soft no mode-picker closed | ModePicker bind + `select_displayed_mode` present; player-facing | **PASS** — **CLOSED** |
| 6a | §4.5 | hud / main_menu / presenter / beat_injection / game_state — no truth leaks | **PASS** |
| 6b | Soft catalog parked | seed / far crest / Fri spill Soft OK / EventBanner Soft OK / flipper Soft OK / apply_medium_capacity / dual cash-eval | **PASS** (soft) |
| 7 | No Art; text UI OK | text buttons + labels only | **PASS** |
| 8 | Win paths when selected | Flagship / Survive / Liquidity award paths green | **PASS** |

## Soft no mode-picker — CLOSED

Prior S1 Soft OK MVP (tests/harness set `campaign_mode`; no ModePicker UI) is **closed** by T1:

| Surface | Evidence |
|---------|----------|
| `scenes/ui/main_menu.tscn` | `ModePicker` GridContainer columns=2 + unique-name buttons |
| `scripts/ui/main_menu.gd` | `_bind_mode_picker` / `select_displayed_mode` → `GameState.select_campaign_mode` |
| Player flow | New game → pick mode → Start; mid-run switch rejected |

## Modes (player-facing)

| Button | `campaign_mode` | Mode id | Awards when |
|--------|-----------------|---------|-------------|
| **Flagship** | **0** | `flagship` | Own Large + Rep≥80 + cash≥$50k |
| **Survive Year 1** | **1** | `survive_y1` | day≥365 + cash>0 + Rep≥40 Normal |
| **Liquidity king** | **2** | `liquidity_king` | month-end SETTLE + cash≥$100k Normal |
| **Sandbox** | **3** | `sandbox` | **never** — thin PBs (day + cash) only |

## Key measured evidence

| Surface | Key numbers |
|---------|-------------|
| Tip | `605be23bc0da1f8369cf6e953599f33b796c4f43` (PR #49 head) |
| ModePicker | columns **2**; 4 player-facing buttons |
| Flagship exact | Large + Rep **80** + cash `5_000_000¢` → award `flagship` |
| Survive exact | day **365** + Rep **40** + cash **1** → award `survive_y1` |
| Liquidity exact | day **30** SETTLE + cash `10_000_000¢` → award `liquidity_king` |
| Sandbox none | day **390** + Large + Rep80 + $100k SETTLE → no award; active |
| Sandbox PB | day **390**; cash **10_000_000**; menu shows `$100,000.00` |
| Soft day-1 PB | day **1**; cash **800000** (= `start_cash_cents`) Soft OK MVP |
| Harness | **135 PASS / 0 FAIL / 9 SOFT** |
| Foundation | `All foundation tests passed.` EXIT:0 (incl. `_test_campaign_mode_picker`) |
| Import | EXIT:0 |

## Design SoT alignment

- **pick-t / T1:** Campaign mode picker UI — **shipped and smoked green**.
- **Acceptance 1:** Player selects mode before/at new game; selection persists — **met**.
- **Acceptance 2:** Only selected mode awards; Sandbox none — **met**.
- **Acceptance 3:** §4.5 clean; Softs unused; text UI OK — **met**.
- **Soft close:** Soft “no mode-picker” from #48 — **CLOSED**.
- **Out of scope (honored):** Mid-run mode switch; multi-goal parallel awards; Soft catalog; Art.

## Soft policy recommendation (Soft no mode-picker CLOSED; others parked)

**Recommend:** Soft no mode-picker **closed**. Soft Sandbox PB day-1 baseline Soft OK MVP. Soft catalog otherwise **keep parked / Won't-Fix**. No Art.

| Soft item | Disposition |
|-----------|-------------|
| Soft no mode-picker Soft OK MVP | **CLOSED** by T1 main-menu 2×2 picker @ `605be23b`. |
| Soft Sandbox PB day-1 baseline Soft OK MVP | **Soft OK** — `start_new_game` records day 1 + start cash $8,000. |
| Soft dual cash-eval Soft OK | **Keep parked** — award idempotent from S1; unused by picker UI. |
| Soft seed `_ensure_priceable_sku` | **Keep parked / Won't-Fix candidate.** Unused by T1. |
| Soft far crest | **Parked (Art).** Unused. |
| Soft Fri spill Soft OK | **Keep parked / Won't-Fix MVP.** Unused. |
| Soft EventBanner rumor Soft OK | **Keep parked / Won't-Fix MVP.** Unused. |
| Soft flipper-weight Soft OK | **Keep parked / Won't-Fix MVP.** Unused. |
| Soft `apply_medium_capacity` naming | **Keep parked.** Large still calls for stacked capacity; hygiene-only. |

## Findings (severity-ranked)

1. **None blocking.** Soft Sandbox day-1 PB baseline is intentional Soft OK MVP (records opening day/cash as personal bests).
2. **Info:** Foundation `test_runner --script` still prints transient early `GameState` compile noise before autoloads bind (same as S1); then runs to `All foundation tests passed.` EXIT:0 — non-blocking.

## Blockers

**None.**

## Evidence paths

| Artifact | Path |
|----------|------|
| Import log | `/workspace/card-shop-qa/evidence/t1-605be23b/import.log` |
| Foundation log | `/workspace/card-shop-qa/evidence/t1-605be23b/foundation.log` |
| Harness log | `/workspace/card-shop-qa/evidence/t1-605be23b/qa_t1_smoke.log` |
| Smoke JSON | `/workspace/card-shop-qa/evidence/t1-605be23b/smoke.json` |
| Harness script | `/workspace/card-shop-qa/qa_t1_mode_picker_smoke.gd` |
| Report (root) | `/workspace/card-shop-qa/playtest-t1-mode-picker-605be23b.md` |
| Report (docs/qa) | `/workspace/card-shop-qa/docs/qa/playtest-t1-mode-picker-605be23b.md` |

## Verdict line

**PASS-with-notes — Clear for merge YES — Soft no mode-picker CLOSED — tip `605be23bc0da1f8369cf6e953599f33b796c4f43` — harness 135/0/9**
