# Next Eng SoT Pick CC v1 — post CB1

**Status:** ADOPTED — Pick CC1. Spec on main (this commit). Soft CLOSED. Soft OK list-time Soft. No Art. STOP unparked. QA formal re-smoke; Eng S2+ only on win-path regression.
**Author:** CSS Designer
**Date:** 2026-10-05 (~11:40pm ET)
**Depends on:** pick-cb (CB1 Walk-in seller "Last sold in-shop" line SHIPPED #110 @ `ef8d7510`, reviewed `0f7110c1`; QA PASS-with-notes harness 1120/0/4 +5 Soft OK — list-time Soft; SceneTree Soft; greps Soft; CA1 online list-confirm keep Soft; list-confirm byte-compare Soft; reuses `sale_history` (no new save key); Soft CLOSED; Soft OK list-time Soft; No Art; docs status `5f3ab994`); pick-ca (CA1 Price-confirm "Last sold in-shop" SHIPPED #109 @ `8b48d370`, reviewed `397524ad`; reuses `sale_history`); pick-bz (BZ1 Buy-confirm "Last sold in-shop" SHIPPED #108 @ `df1fd35a`; save key `sale_history`); Soft catalog CLOSED
**Rule:** Pick **one**. §4.5 never leaks. Soft catalog stays closed. Hard-park camera off-switch Soft. Do **not** turn CB1, CA1, BZ1, BY1, BX1, BW1, BV1, BU1, BT1, BS1, BR1, BQ1, BP1, BO1, BN1, BM1, BL1, BK1, BJ1, BI1, BH1, BG1, BF1, BE1, BD1, BC1, BB1, BA1, AZ1, AY1, AX1, AW1, AV1, AU1, AT1, AS1, AR1, AQ1, AP1, AO1, AN1, AM1, AL1, AK1, AJ1, AI1, AH1, AG1, AF1, AC1, AD1, AE1, or AA1 into a sell weight. **STOP unparked this pick** (systems rows exhausted).

---

## Context (shipped)

| Pack | Result |
|------|--------|
| A–CB1 | Full loop + fair/overprice settle + suggested day-clear + buylist drip / fewer-lots / high-% flood + daily utilities + calendar set release hype + Pro tour archetype spike + Rotation staples crash + Distributor weekly restock menu + Recurring marketplace lots 1–3/day + Recurring player-trade pool + Auction snipe SKU pool + Shady trunk SKU pool + Regulars relationship stock + Buy-confirm "Last sold in-shop" + Price-confirm "Last sold in-shop" + Walk-in seller "Last sold in-shop" |
| Soft | Catalog CLOSED; AC1 through CB1 Soft OK MVP notes stay Soft (incl. Soft OK list-time Soft; CB1 SceneTree Soft; no-writer/no-HUD greps Soft; list-confirm byte-compare Soft; CA1 online list-confirm Last sold line Soft keep) |

**Gap:** With CB1, every §3 channel row, every §8 named event, the §4.3 buylist suite, §4.4 online, §2.4 shrink mods, §5.3 band unlocks, §6.3 hire/fire/Reliability, §9 win/lose (R1 Flagship + S1 Survive Y1 / Liquidity; W1 loan shark; Z1 Ironman; AA1 Sandbox PBs; BF1 net-worth HUD), and **every §4.5 history surface the player decides on** — buy-confirm (BZ1), price/list-confirm (CA1), trade confirm, and the live walk-in seller panel (CB1) — are live on the shipped `SaleHistory` store. Verified read-only on CB1 tip `0f7110c1`: `DemandSignalPresenter.last_sold_in_shop_line` is called from `buy_confirm_snapshot`, `price_summary`, `buylist_seller_summary`, and `PlayerTradePresenter`. Soft OK list-time suggested stays Soft. Camera off-switch Soft hard-parked. Remaining named fantasies (Named Regular cast, patience/budget buffs, archetype spawn bias, §5.2 inventory-mix spawn, §4.2 `staff_knowledge_mod`, online sale history, charts/sparklines, class-/set-level "similar", grade-split history) are **Out** — Soft, door/whale, sell-weight, §4.5 D post-MVP, or fairness risks. **§3 / §4–§9 systems rows are exhausted.** Soft reopeners stay Closed. The honest lean GO is STOP, not another thin systems bite and not Soft.

---

## Option CC1 — STOP / win assert polish (systems §9 re-assert after systems close) — **LEAN GO**

**Player fantasy:** "I closed the shop systems — do Flagship / Survive Year 1 / Liquidity king still light up?" No new mechanics. Cool-down assert that the prestige wins still award once on the post-CB1 tip after the full history close.

| Deliverable | Spec |
|-------------|------|
| Where | No new Eng systems. QA owns the formal re-smoke against systems §9.2 on the post-CB1 tip (`ef8d7510` / current main). Eng **S2+** only if a win path regresses. Out: new verbs, new events, Soft catalog reopen, camera off-switch, sell-weight rewires, door/whale changes, history-line changes |
| Assert | Flagship (Own Large + Rep ≥ 80 + cash ≥ $50k) awards once and deactivates; Survive Y1 (day ≥ 365 + cash > 0 + Rep ≥ 40) awards once; Liquidity king (end any month cash ≥ $100k) awards once. Large lease gates stay coherent with L1. Idempotent awards (Soft dual cash-eval Soft OK stays Soft) |
| Bounds | No change to BM1–CB1, AO1/BY1 Regulars, door spawn, whale weight, BN1/BO1 seller weight, BK1 settle, AR1 drift, `sale_history` writers/readers, or any §4.5 signal. Not a sell weight |
| Soft | Catalog untouched; leave Soft OK list-time Soft; CB1 Soft notes Soft; CA1 Soft keeps Soft |
| UI / Art | No new screen. No Art. Optional thin HUD/menu copy polish only if a win award already surfaces there and a Soft-clean string fix is needed for the assert |
| Save/load | No new save key |

**Acceptance:**

1. Written playtest report on the locked tip: Flagship / Survive Y1 / Liquidity king each award once when gates are met; second evaluate does not re-fire; Large / Flagship gates remain distinct.
2. No new Eng systems land. BM1–CB1, `sale_history`, door spawn, whale weight, and BN1/BO1 seller weight are unchanged. §4.5 never leaks (`true_market` / `p_buy` stay off UI).
3. Soft catalog CLOSED. Soft OK list-time Soft. CB1 Soft notes Soft CLOSED (not a fail). Soft dual cash-eval Soft OK stays Soft if awards stay idempotent.
4. Not a sell weight. No Art.

**Out:** Soft OK list-time suggested persistence; listed-band retag / display-bonus Soft; camera off-switch Soft; online sale history (new writers / separate from BZ1 in-shop-only record); multi-sale averages / charts / sparklines (§4.5 D); class- or set-level "similar" fallback; grade-split history; named Regular cast / multi-Regular roster; patience or budget streak buffs; archetype-customer spawn bias; §5.2 inventory-mix spawn mod (touches door spawn); §4.2 `staff_knowledge_mod` (would make Specialist a sell weight); sell-weight rewires; changing BM1–CB1 or door/whale.

**Why now:** CB1 closed the last live §4.5 history surface. Every load-bearing systems row that is not Soft / camera / door / whale / sell-weight is live. Prefer an honest STOP re-assert over inventing a thin systems bite or reopening Soft.

---

## Option CC2 — Online sale history / multi-sale averages — **PARK**

**Why park:** Online fills were deliberately Out of BZ1 writers (in-shop sales only). Multi-sale averages / charts / sparklines are §4.5 D post-MVP and risk forecasting tone. Not Soft, but not a lean systems close after CB1 — prefer STOP.

---

## Option CC3 — Persist list-time suggested (BK1 Soft OK) — **PARK Soft**

**Why park:** Soft catalog CLOSED.

---

## Option CC4 — Listed-band retag / display-bonus Soft — **PARK Soft**

**Why park:** Soft catalog CLOSED.

---

## Camera off-switch — **HARD PARK Soft**

**Why park (hard):** Reopens Soft catalog.

---

## Recommendation (non-binding)

**GO CC1** (STOP / win assert polish). Park CC2/CC3/CC4. **Hard-park** the camera off-switch. Soft catalog stays closed. Soft OK list-time stays Soft. CB1 Soft notes stay Soft. CA1 Soft keeps stay Soft. Named Regular cast, patience buffs, archetype spawn bias, inventory-mix spawn, online sale history, and charts/sparklines stay Out (door/whale stay as shipped). BM1–CB1 untouched.

Honest call: after CB1 there is **no** remaining lean systems GO that is not Soft, not camera, not door/whale, and not a sell weight. Unparking STOP is the right move.

---

## PM checklist

- [x] Choose **CC1** (recommended)
- [x] If CC1: QA formal re-smoke Flagship / Survive Y1 / Liquidity king on post-CB1 tip; Eng S2+ only on win-path regression. No new systems, no new save key, no Art. Soft catalog CLOSED; Soft OK list-time Soft; CB1 Soft notes Soft CLOSED. BM1–CB1 / buyer door / whale / BN1–BO1 seller weight / `sale_history` untouched
- [x] Sync this file to main before any agent / QA kick
- [x] Soft catalog stays closed; Soft reopeners stay PARK Soft; camera stays hard-parked

---

## Decision log

| When | Decision |
|------|----------|
| 2026-10-05 ~11:40pm ET | Drafted post CB1 SHIPPED #110 @ `ef8d7510` (reviewed `0f7110c1`; QA PASS-with-notes harness 1120/0/4 +5 Soft OK; reuses `sale_history`; Soft CLOSED; Soft OK list-time Soft; No Art; docs status `5f3ab994`). Lean **CC1 STOP / win assert polish** (§9 re-assert after systems close). Verified read-only on CB1 tip `0f7110c1`: `last_sold_in_shop_line` reaches buy-confirm / price-summary / buylist_seller_summary / trade — every decision surface live. §3 channels / §8 events / §4.3–§4.4 / §5.3 / §6.3 / §9 / §4.5 A+B otherwise live. Remaining fantasies Out (Soft / door / whale / sell-weight / §4.5 D / fairness). **STOP unparked** as LEAN GO. Soft reopeners PARK Soft. Camera off-switch hard-parked. Soft CLOSED. Soft OK list-time stays Soft. CB1 Soft notes stay Soft. No Art. BM1–CB1 stay as shipped. CB left SHIPPED (not rewritten). |
| 2026-10-05 ~11:42pm ET | ADOPTED — Pick CC1 STOP / win assert polish. Draft sha256 `84771e12b09fe7a3cff5928401edc3814c82c0437b7191a1a352d080a3943d54` (pre-adopt). Park CC2/CC3/CC4. Hard-park camera. Soft CLOSED. Soft OK list-time Soft. No Art. No new Eng systems — QA formal re-smoke Flagship / Survive Y1 / Liquidity king on post-CB1 tip `ef8d7510`; Eng S2+ only on regression. |
