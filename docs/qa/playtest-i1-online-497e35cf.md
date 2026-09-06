# Playtest report — I1 online listings formal smoke @ `497e35cf` (PR #36)

**Scorer:** CSS QA (executor)  
**Date:** 2026-09-06 (~2:45 PM ET)  
**Build:** `adamwlarson/cardshopsimulator` tip **`497e35cfd04269a295537b87f3d1a0d511ab52b5`** (short `497e35cf`)  
**Tree:** `/workspace/qa-playtest/i1-497e35cf/` (detached worktree @ tip)  
**Mode:** **Normal** (`data/balance/normal.tres`) — Easy/Hard fee + inherit cross-check  
**Godot:** 4.5.2.stable.official.6ce3de25a (`/workspace/godot452`)  
**Scope:** Formal I1 online listings smoke — unlock Rep 35; list→ONLINE_HOLD + 8% fee + ship 1–3 + cancel restore; frequent-cancel Rep hit; §4.5 confirm nack; Soft `_ensure_priceable_sku` parked  
**Method:** Headless — foundation `tests/test_runner.gd` (five `_test_i1_*`) + SceneTree harness `tests/qa_i1_online_smoke.gd`  
**Design SoT:** pick-i Option I1; systems §4.4 / §4.5; PR #36 body; Soft Eng parkeds non-blocking; **No Art**

**Evidence:** `/workspace/card-shop-qa/evidence/i1-497e35cf/` (`import.log`, `foundation.log`, `qa_i1_smoke.log`, `qa_i1_online_smoke.json`)

---

## Executive verdict

| Gate (pass bar) | Result |
|-----------------|--------|
| 1. Locked below Rep 35; unlock at ≥ 35 | **PASS** |
| 2. List → ONLINE_HOLD + fee path (8%) + ship delay 1–3; cancel restores location; held stock not sellable in-store | **PASS** |
| 3. Frequent-cancel Rep hit (`online_cancel_rep_hit`; defaults ~7/3/−3) | **PASS** |
| 4. List confirm §4.5 clean — no `true_market` / `p_buy` / `cert_valid` | **PASS** — 0 hard UI hits |
| 5. Soft `_ensure_priceable_sku` unused / parked | **PASS** |
| 6. Soft Eng parked (non-blocking) | **PASS** (soft noted) |

| Supporting | Result |
|------------|--------|
| Tip SHA confirmed | **`497e35cfd04269a295537b87f3d1a0d511ab52b5`** (`merge main into I1 branch (docs-only Status bump)`) |
| Godot import | **PASS** (`IMPORT_EXIT:0`) |
| Foundation `test_runner` | **PASS** — `All foundation tests passed.` (`EXIT:0`); I1 QA `online_listed` / `online_cancelled` / `online_filled` / `online_cancel_rep_hit` observed |
| Formal I1 smoke harness | **PASS** — **134 PASS / 0 FAIL**; `SOFT_COUNT=6` |
| S0–S2 (severity rubric) | **None found** for this tip |

**Overall: PASS-with-notes**

I1 online listings clears the formal pass bar on Normal at tip `497e35cf`. Soft Eng parkeds only; no S0–S2.

**Clear for merge?** **YES** (PASS-with-notes; soft only).

---

## Pass-bar checklist

| # | Check | Observed | Verdict |
|---|-------|----------|---------|
| 1a | Unlock Rep 35 | `online_unlock_rep=35`; locked at Rep 34 (`reason=locked`); unlocks at 35 | **PASS** |
| 1b | HUD gate | `%OpenOnlineButton` enabled at 35; disabled below; locked copy names “Rep 35” | **PASS** |
| 2a | List → ONLINE_HOLD | Card moves to `ONLINE_HOLD`; `find_listed_sku_offer` empty; `confirm_customer_sale` false | **PASS** |
| 2b | Fee 8% + ship 1–3 | list price **2500** → fee **200**; ship_days **1** and **3** accepted; fill at settle posts `online_sale` + `online_fee`; net cash **+2300** | **PASS** |
| 2c | Cancel restore | Cancel before fill → BINDER; no `online_fee` ledger on cancel; QA `online_cancelled` | **PASS** |
| 3 | Frequent cancel | 3 cancels in window → Rep **40→37** (−3); QA `online_cancel_rep_hit` `{cancels_in_window:3, window_days:7, rep_delta:-3}` | **PASS** |
| 4a | Confirm §4.5 | `OnlineListConfirmSignal` + presenter summary/row + HUD chips have no truth fields/tokens; demand/position/move chips shown | **PASS** |
| 4b | UI truth scan | hud / presenter / main_menu / gameplay_hud — **0** hard hits | **PASS** |
| 5 | Soft parked | `_ensure_priceable_sku` still in DemandSignals; I1 surfaces do not call it; missing SKU list fails without Titan seed | **PASS** |
| 6 | Soft Eng | Inherit knobs + hardcoded “8%” copy noted; non-blocking | **PASS** (soft) |

---

## Key measured evidence

| Surface | Key numbers |
|---------|-------------|
| BalanceConfig (Normal) | `online_fee` **0.08**; `online_unlock_rep` **35**; ship **1–3**; cancel **7 / 3 / −3** |
| Easy / Hard fee | **0.06** / **0.10** (mirrored in `.tres`) |
| Gate1 | lock reason `locked`; HUD gated |
| Gate2 | fee **200** on **2500**; cash delta **+2300**; ship `[1,3]` |
| Gate3 | Rep **37**; `online_cancel_rep_hit` payload complete |
| Gate4 summary (excerpt) | `Fee: 8% · $1.44 taken when the listing fills` + ships 1–3 + Online hold copy; chips WARM / Competitive / Should Move |
| Truth scan | `truth_scan_leaks: []` |
| Harness | 134 PASS / 0 FAIL / 6 SOFT |

Foundation I1 instrumentation (from `foundation.log`):

- `online_listed` → `online_cancelled` → re-list → `online_filled` (fee 200 / net 2300)
- 3rd cancel: `online_cancel_rep_hit` `{rep_delta:-3, cancels_in_window:3, window_days:7, reputation:37}`

Note: headless foundation log shows transient early `GameState` compile noise while autoloads resolve (`Failed to load script test_runner.gd`), then the suite runs to `All foundation tests passed.` / `EXIT:0`. Non-blocking; same tip verifies under the focused harness with clean PASS.

---

## Design SoT alignment

- **pick-i / Option I1:** Online channel unlock at Rep ≥ 35; list/hold/fee/ship/cancel; frequent-cancel Rep instrumentation; thin HUD confirm inside §4.5 fog.
- **systems §4.4 / §4.5:** Confirm/detail never show raw `true_market` / `p_buy` / `cert_valid`; fog chips only.
- **Out of scope (honored):** No Art; Soft `_ensure_priceable_sku` parked; no multi-marketplace / shipping minigame / Large expand / I2–I4.

---

## Soft Eng nits (non-blocking)

1. **Soft `_ensure_priceable_sku`** — left parked; OOS for I1. (**S4**)
2. **Soft BalanceConfig knobs inherit** — `online_unlock_rep`, `online_ship_days_*`, `online_cancel_*` live as script defaults only (not mirrored in `easy.tres` / `hard.tres` / `normal.tres`). `online_fee` **is** mirrored (0.06 / 0.08 / 0.10). Prefer mirroring cancel/unlock/ship for diff clarity. (**S4**)
3. **Soft cancel defaults 7/3/−3** — asserted via inherit; works. Same mirror gap as (2). (**S4**)
4. **Soft hardcoded “8%” copy vs runtime fee** — `gameplay_hud.tscn` blurb (“Fee 8%…”) and ledger memo `"Online listing fee 8%"` stay Normal-centric while Easy/Hard fees are 6%/10%. Presenter/`list_confirm_summary` correctly uses `dto.fee_percent`. (**S4**)
5. **Defensive filter tokens** in `customer_intent_icon.gd` (`true_market` / `cert_valid`) — filter-only; not player-facing; non-blocking. (**S4**)
6. **No Art** — confirmed OOS.

## Findings (severity-ranked)

| Severity | ID | Summary | Disposition |
|----------|----|---------|-------------|
| — | — | **None found** (S0–S2 empty for this tip/smoke) | Soft S4 notes only |

---

## Clear for merge?

| Question | Answer |
|----------|--------|
| Clear for merge? | **YES** — PASS-with-notes; Soft Eng only |
| Eng S2+ standby from this report? | **No** |
| Art needed? | **No** |

Harness lives under the playtest tree (`tests/qa_i1_online_smoke.gd`) and is mirrored at `/workspace/card-shop-qa/qa_i1_online_smoke.gd` — not pushed.

## Merge

Merged to main as **PR #36** @ `7c40f3b849abb935d84bff71fa8e1622f05cf5e8` (2026-09-06).
