# Next Eng SoT Pick CB v1 — post CA1

**Status:** SHIPPED — squash-merged #110 @ `ef8d7510` (reviewed `0f7110c1`). QA PASS-with-notes harness 1120/0/4 +5 Soft OK. Reuses `sale_history` (no new save key). Soft CLOSED. Soft OK list-time Soft. No Art. Docs status this commit.
**Author:** CSS Designer
**Date:** 2026-10-05
**Depends on:** pick-ca (CA1 Price-confirm "Last sold in-shop" history line SHIPPED #109 @ `8b48d370`, reviewed `397524ad`; QA PASS-with-notes harness 1034/0/4 +4 Soft OK; reuses `sale_history` (no new save key); docs status `b171e1cf`); pick-bz (BZ1 Buy-confirm "Last sold in-shop" SHIPPED #108 @ `df1fd35a`; save key `sale_history`); Soft catalog CLOSED
**Rule:** Pick **one**. §4.5 never leaks. Soft catalog stays closed. Hard-park camera off-switch Soft. Do **not** turn CA1, BZ1, BY1, BX1, BW1, BV1, BU1, BT1, BS1, BR1, BQ1, BP1, BO1, BN1, BM1, BL1, BK1, BJ1, BI1, BH1, BG1, BF1, BE1, BD1, BC1, BB1, BA1, AZ1, AY1, AX1, AW1, AV1, AU1, AT1, AS1, AR1, AQ1, AP1, AO1, AN1, AM1, AL1, AK1, AJ1, AI1, AH1, AG1, AF1, AC1, AD1, AE1, or AA1 into a sell weight. STOP stays parked.

---

## Context (shipped)

| Pack | Result |
|------|--------|
| A–CA1 | Full loop + fair/overprice settle + suggested day-clear + buylist drip / fewer-lots / high-% flood + daily utilities + calendar set release hype + Pro tour archetype spike + Rotation staples crash + Distributor weekly restock menu + Recurring marketplace lots 1–3/day + Recurring player-trade pool + Auction snipe SKU pool + Shady trunk SKU pool + Regulars relationship stock + Buy-confirm "Last sold in-shop" history line + Price-confirm "Last sold in-shop" history line |
| Soft | Catalog CLOSED; AC1 through CA1 Soft OK MVP notes stay Soft (incl. CA1 online list-confirm Last sold line Soft keep; SceneTree GameState lookup Soft; trade/online + presenter no-writer greps Soft; Soft OK list-time Soft) |

**Gap:** With CA1, every §3 channel row, every §8 named event, the §4.3 buylist suite, §4.4 online, §2.4 shrink mods, §5.3 band unlocks, §6.3 hire/fire/Reliability, and both §4.5 history surfaces (A buy-confirm, B price/list-confirm) are live on the shipped `SaleHistory` store. Verified read-only on main `b171e1cf`: `DemandSignalPresenter.last_sold_in_shop_line` is called from `buy_confirm_snapshot`, `price_summary`, and `PlayerTradePresenter` only. The **walk-in seller serve panel** — the live §4.3 / §5.2 "Buy-from-them" surface (AW1 / AX1 "You offer" / AY1 Inspect) — renders through `DemandSignalPresenter.buylist_seller_summary` (HUD `customer_summary`, `hud.gd` SELLER path), which has **no** history line. `data/buy_opportunities.json` carries no `buylist`-channel Prep opportunities, so BZ1's BUYLIST coverage is the synthetic `buy_confirm_snapshot` test path only; in live play a walk-in seller never shows "Last sold in-shop". That is the one buy surface where the player **sets the price** (You offer), and it is the §4.5 A history promise BZ1 named for buylist but never reached in gameplay. Soft OK list-time suggested stays Soft. Camera off-switch Soft hard-parked. STOP parked. (Named Regular cast, patience/budget buffs, archetype spawn bias, §5.2 inventory-mix spawn, §4.2 `staff_knowledge_mod`, charts/sparklines stay Out.)

---

## Option CB1 — Walk-in seller "Last sold in-shop" line (systems §4.3 / §4.5 A buylist close) — **LEAN GO**

**Player fantasy:** "This kid wants to sell me the card I sold for $42 three days ago — what do I offer?" When a walk-in seller is at the counter, the serve panel shows the same hard register fact buy-confirm and price-confirm already show. Good buyers stop overpaying at the counter.

| Deliverable | Spec |
|-------------|------|
| Where | Reuse the shipped `SaleHistory` store (`GameState.sale_history` / save key `sale_history`). The existing walk-in seller presenter (`DemandSignalPresenter.buylist_seller_summary` → HUD `customer_summary` on the SELLER serve path) reads it via the shipped `last_sold_in_shop_line(dto.sku_id)` helper. No new recorder, no new save key, no logic in the HUD. Out: rewriting BZ1 record rules; buy-confirm / price-confirm / trade confirm changes; Prep `buy_summary` detail panel; online sale history; charts / sparklines / forecasts |
| Record | Unchanged BZ1: only completed in-shop sales (listed or negotiated; counter / case / binder / pull) write `{sku_id, unit_price_cents, day}`; most recent per `sku_id` wins. Buylist buys (accept), seller refusals / walk-outs, online fills, trades, refunds / mismatch refunds, fake-slab `sale_fail` never write or delete. CB1 does **not** add writers |
| "Similar" | Exact `sku_id` of the seller's `buylist_signal` only — same as BZ1/CA1. No condition / grade / class / set fallback. No entry → line hidden |
| Line | One factual line when an entry exists: `Last sold in-shop: $X, N days ago` (`N = today − day`; `0` → "today", `1` → "1 day ago") — the shipped helper string, byte-for-byte. Placed after `Demand · Confidence`, before `Condition` / `Slab` (same order as `buy_confirm_snapshot`). Persists across AX1 offer edits and AY1 Inspect re-renders (same helper, same SKU) |
| Bounds | Display only. Does **not** change You offer default, buylist % settings, `BuylistPolicy` listed comp / anger floor / accept odds, AX1 edit rules, AY1 inspect cost / accuracy, comp range, demand band, confidence, condition cue, BM1 drip, BN1 fewer lots, BO1 flood, BN1/BO1 seller weight, door spawn, whale weight, BK1 settle basis, suggested price, AR1 drift, or any channel ask. Not a sell weight |
| Signal (§4.5) | The value is the player's own historic in-shop sale price — never `true_market`, never `p_buy`, never a comp midpoint, never "worth", never a forecast or trend arrow. Debug-only `last_sold_*` on the buylist `demand_signal_shown` payload is OK |
| UI | One text line in the existing serve panel. No new screen, no new button. No Art |
| Save/load | No new key. Reuses `sale_history`. Old saves / empty history → line hidden until next in-shop sale |
| Untouched | BZ1 record path + buy-confirm line, CA1 price / list-confirm line, trade confirm, BM1–CA1, AO1/BY1 Regulars, door/whale stay as shipped |
| Soft | Catalog untouched; leave Soft OK list-time suggested Soft; CA1 Soft keeps stay Soft |

**Acceptance:**

1. Same seed: sell SKU X in-shop at $P on day d. On day d+N, a walk-in seller offering X shows `Last sold in-shop: $P, N days ago` in `buylist_seller_summary` and the HUD SELLER `customer_summary`. A second in-shop sale at $Q overwrites to $Q / that day. The line survives an AX1 You-offer edit and an AY1 Inspect re-render.
2. Seller offering a SKU never sold in-shop (or a different `sku_id`) → no line. Accepting the seller's lot, refusing, or the seller walking out never creates or changes an entry (BZ1 writers stay sole writers).
3. With vs without history, every other `buylist_seller_summary` line is byte-identical, and You offer / listed comp / anger floor / accept outcome on the same seed are identical. `buy_confirm_snapshot`, `price_summary`, list-confirm, and trade confirm stay byte-identical to CA1. Summary never shows `true_market` / `p_buy` (`_assert_text_has_no_truth`).
4. Save/load still restores `sale_history`; no new save key. Door spawn, whale weight, BN1/BO1 seller weight, and BM1 through CA1 are unchanged.
5. Not a sell weight. Soft catalog CLOSED. No Art.

**Out:** STOP / win assert; camera off-switch; Soft OK list-time suggested persistence; listed-band retag / display-bonus Soft; Prep `buy_summary` detail line (confirm already carries it); online sale history; multi-sale averages / charts / sparklines (§4.5 D); class- or set-level "similar" fallback (misleads across rarity — fairness risk); grade-split history; changing buylist accept odds / anger floor / default offer; named Regular cast / multi-Regular roster; patience or budget streak buffs; archetype-customer spawn bias; §5.2 inventory-mix spawn mod (touches door spawn); §4.2 `staff_knowledge_mod` (would make Specialist a sell weight); sell-weight rewires; changing BM1–CA1 or door/whale.

**Why now:** BZ1 promised the history line on buylist and CA1 closed the sell side, but the only *live* buylist surface — the walk-in seller panel where the player types the offer — is still dark. Wiring the shipped helper into `buylist_seller_summary` is the thinnest remaining load-bearing systems close: zero new save key, zero new writers, no Art, no door/whale, no Soft.

---

## Option CB2 — STOP / win assert polish — **PARK**

**Why park:** Prefer the walk-in seller history close this pick. Flagship / Survive Y1 / Liquidity already wired (R1/S1). Unpark only if PM judges CB1 too thin after CA1.

---

## Option CB3 — Persist list-time suggested (BK1 Soft OK) — **PARK Soft**

**Why park:** Soft catalog CLOSED.

---

## Option CB4 — Listed-band retag / display-bonus Soft — **PARK Soft**

**Why park:** Soft catalog CLOSED.

---

## Camera off-switch — **HARD PARK Soft**

**Why park (hard):** Reopens Soft catalog.

---

## Recommendation (non-binding)

**GO CB1** (Walk-in seller "Last sold in-shop" line). Park CB2/CB3/CB4. **Hard-park** the camera off-switch. Soft catalog stays closed. Soft OK list-time stays Soft. CA1 Soft keeps (online list-confirm line; SceneTree GameState lookup; no-writer greps) stay Soft. Named Regular cast, patience buffs, archetype spawn bias, and inventory-mix spawn stay Out (door/whale stay as shipped). BM1–CA1 untouched.

If PM judges CB1 too thin to be load-bearing: after CB1 every §4.5 history surface the player decides on (buy-confirm, price/list-confirm, trade confirm, walk-in seller) is live and §3 / §4–§9 systems rows are otherwise exhausted, so the honest alternative — now or for CC — is **CB2 STOP** (unpark) rather than reopening Soft.

---

## PM checklist

- [x] Choose **CB1** (recommended)
- [x] If CB1: Eng vs §4.3 / §4.5 A buylist close. Reuse `SaleHistory` / `sale_history` via `last_sold_in_shop_line` inside `buylist_seller_summary` (no new save key, no new writers). Walk-in seller panel shows `Last sold in-shop: $X, N days ago` when the seller's SKU has history, else hidden; survives AX1 edit / AY1 Inspect re-render. Display only — no change to You offer / buylist % / accept odds / anger floor / comp / band / confidence / condition. Buy-confirm / price-confirm / trade confirm byte-identical to CA1. Leave Soft OK list-time Soft. No Art. BM1–CA1 / buyer door / whale / BN1–BO1 seller weight untouched
- [x] Sync this file to main before cloud agent
- [x] Soft catalog stays closed; STOP stays parked

---

## Decision log

| When | Decision |
|------|----------|
| 2026-10-05 ~11:20pm ET | Drafted post CA1 SHIPPED #109 @ `8b48d370` (reviewed `397524ad`; QA PASS-with-notes harness 1034/0/4 +4 Soft OK; reuses `sale_history`; docs status `b171e1cf`). Lean **CB1 Walk-in seller "Last sold in-shop" line** (§4.3 / §4.5 A buylist close). Verified read-only on main `b171e1cf`: `last_sold_in_shop_line` reaches buy-confirm / price-summary / trade only; `buylist_seller_summary` (live SELLER serve panel) has no line; `data/buy_opportunities.json` has no buylist-channel Prep opportunities, so BZ1 buylist coverage is synthetic-only. Reuses shipped store — no new key/writers. §3 channels / §8 events / §4.3–§4.4 / §5.3 / §6.3 / §4.5 A+B otherwise live. STOP / Soft reopeners parked. Camera off-switch hard-parked. Soft CLOSED. Soft OK list-time stays Soft. CA1 Soft keeps stay Soft. No Art. BM1–CA1 stay as shipped. |
| 2026-10-05 ~11:30pm ET | TIP-FROZEN — PR #110 ready at `0f7110c1` (branch `cursor/cb1-walk-in-seller-last-sold-ab0f`). 2 files (`demand_signal_presenter.gd`, `test_runner.gd`), no docs. Reuses `sale_history` (no new save key). Cloud agent `bc-ed1bdf8c` archived. Eng review that SHA against bar `213977b8`. QA held until APPROVE; no merge until PASS. Soft CLOSED. Soft OK list-time Soft. No Art. Harness EXIT 0. |
| 2026-10-05 ~11:39pm ET | SHIPPED — squash-merged #110 @ `ef8d7510` (reviewed `0f7110c1`). QA PASS-with-notes harness 1120/0/4 +5 Soft OK. Reuses `sale_history` (no new save key). Soft CLOSED. Soft OK list-time Soft. Soft notes Soft CLOSED (SceneTree Soft; greps Soft; list-confirm byte-compare Soft). No Art. Branch deleted. Next pick CC. |
