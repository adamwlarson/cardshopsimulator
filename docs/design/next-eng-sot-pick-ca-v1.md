# Next Eng SoT Pick CA v1 — post BZ1

**Status:** TIP-FROZEN — PR #109 at `397524ad` (branch `cursor/ca1-price-confirm-last-sold-5aee`). Eng bar `a6d96f99`. Reuses `sale_history` (no new save key). Soft CLOSED. Soft OK list-time Soft. No Art. Eng review pending; QA held.
**Author:** CSS Designer
**Date:** 2026-10-05
**Depends on:** pick-bz (BZ1 Buy-confirm "Last sold in-shop" history line SHIPPED #108 @ `df1fd35a`, reviewed `d1801c97`; QA PASS-with-notes harness 991/0/4 +4 Soft OK; save key `sale_history`; docs status `099ca43d`); Soft catalog CLOSED
**Rule:** Pick **one**. §4.5 never leaks. Soft catalog stays closed. Hard-park camera off-switch Soft. Do **not** turn BZ1, BY1, BX1, BW1, BV1, BU1, BT1, BS1, BR1, BQ1, BP1, BO1, BN1, BM1, BL1, BK1, BJ1, BI1, BH1, BG1, BF1, BE1, BD1, BC1, BB1, BA1, AZ1, AY1, AX1, AW1, AV1, AU1, AT1, AS1, AR1, AQ1, AP1, AO1, AN1, AM1, AL1, AK1, AJ1, AI1, AH1, AG1, AF1, AC1, AD1, AE1, or AA1 into a sell weight. STOP stays parked.

---

## Context (shipped)

| Pack | Result |
|------|--------|
| A–BZ1 | Full loop + fair/overprice settle + suggested day-clear + buylist drip / fewer-lots / high-% flood + daily utilities + calendar set release hype + Pro tour archetype spike + Rotation staples crash + Distributor weekly restock menu + Recurring marketplace lots 1–3/day + Recurring player-trade pool + Auction snipe SKU pool + Shady trunk SKU pool + Regulars relationship stock + Buy-confirm "Last sold in-shop" history line |
| Soft | Catalog CLOSED; AC1 through BZ1 Soft OK MVP notes stay Soft (incl. BZ1 SceneTree GameState lookup Soft; line-before-condition Soft; trade/online greps Soft; Soft OK list-time Soft) |

**Gap:** With BZ1, every §3 channel row, every §8 named event, the §4.3 buylist suite, §4.4 online, §2.4 shrink mods, §5.3 band unlocks, §6.3 hire/fire/Reliability, and the §4.5 A buy-confirm optional history line are live (`SaleHistory` store + save key `sale_history`). Verified on reviewed tip `d1801c97` / ship `df1fd35a`: `DemandSignalPresenter.last_sold_in_shop_line` is wired into buy-confirm / trade confirm only; harness asserts `price_summary` never contains `Last sold in-shop` ("price confirm stays dark this pick"). So when the player lists or re-prices a SKU they already sold in-shop, §4.5 B still has suggested / vs-sug / position chip / band / move feel / display context — but no factual register memory of what *they* got last time. The buy→sell→buy skill loop closed; the sell→reprice half is still dark. Soft OK list-time suggested stays Soft. Camera off-switch Soft hard-parked. STOP parked. (Named Regular cast, patience/budget buffs, archetype spawn bias, §5.2 inventory-mix spawn, §4.2 `staff_knowledge_mod`, charts/sparklines stay Out.)

---

## Option CA1 — Price-confirm "Last sold in-shop" history line (systems §4.5 B mirror of BZ1) — **LEAN GO**

**Player fantasy:** "I sold one of these for $42 three days ago — am I listing too high or too low?" Before you confirm a price, the panel shows the same hard register fact BZ1 already shows on buy-confirm. Good sellers learn to reprice better.

| Deliverable | Spec |
|-------------|------|
| Where | Reuse the shipped BZ1 `SaleHistory` store (`GameState.sale_history` / save key `sale_history`). The existing price-confirm presenter (`DemandSignalPresenter.price_summary` / HUD `%PriceConfirmSummary`) reads it and formats the line. Logic stays in the store (lookup); no new recorder, no new save key. Out: rewriting BZ1 record rules; buy-confirm changes; online sale history; charts / sparklines / forecasts |
| Record | Unchanged BZ1: only completed in-shop sales (listed or negotiated; counter / case / binder / pull) write `{sku_id, unit_price_cents, day}`; most recent per `sku_id` wins. Online fills, walkouts, refusals, buylist buys, trades, refunds / mismatch refunds, fake-slab `sale_fail` never write or delete. CA1 does **not** add writers |
| "Similar" | Exact `sku_id` only — same as BZ1. No condition / grade / class / set fallback. No entry → line hidden |
| Line | Price-confirm shows one factual line when an entry exists: `Last sold in-shop: $X, N days ago` (`N = today − day`; `0` → "today", `1` → "1 day ago") — same string helpers BZ1 already ships (`last_sold_in_shop_line` / `SaleHistory.days_ago_label`). Shows on every price-confirm (list or reprice), never changes buy-confirm |
| Bounds | Display only. Does **not** change suggested price, vs-sug delta, position chip, demand band, move feel, display context, `p_buy`, `price_fit`, AR1 drift, door spawn, whale weight, BN1/BO1 seller weight, BK1 settle basis, or any channel ask. Not a sell weight |
| Signal (§4.5) | The value is the player's own historic sale price — never `true_market`, never `p_buy`, never a comp midpoint, never "will sell for", never a forecast or trend arrow. Never changes move-feel mapping. Debug-only `last_sold_*` on `demand_signal_shown` for `screen: price_confirm` is OK |
| UI | One text line in the existing price-confirm panel (under suggested / position / band block is fine). No new screen. No Art |
| Save/load | No new key. Reuses `sale_history`. Old saves / empty history → line hidden until next in-shop sale |
| Untouched | BZ1 record path + buy-confirm line, BM1–BZ1, AO1/BY1 Regulars, door/whale stay as shipped |
| Soft | Catalog untouched; leave Soft OK list-time suggested Soft |

**Acceptance:**

1. Same seed: sell SKU X in-shop at $P on day d. On day d+N, any price-confirm for SKU X shows `Last sold in-shop: $P, N days ago`. A second sale at $Q overwrites to $Q / that day. Buy-confirm for X still shows the same line (BZ1 unchanged).
2. SKU never sold in-shop → no price-confirm line. Online fill, buylist buy, trade, refund, walkout, refusal, or fake-slab `sale_fail` never creates or changes an entry (BZ1 writers stay sole writers).
3. Price-confirm never shows `true_market`, `p_buy`, or a forecast; suggested / vs-sug / position chip / band / move feel / display context are byte-identical with and without history. Buy-confirm snapshot stays byte-identical to BZ1.
4. Save/load still restores `sale_history`; no new save key. Door spawn, whale weight, and BM1 through BZ1 are unchanged.
5. Not a sell weight. Soft catalog CLOSED. No Art.

**Out:** STOP / win assert; camera off-switch; Soft OK list-time suggested persistence; listed-band retag / display-bonus Soft; online sale history; multi-sale averages / charts / sparklines (§4.5 D); class- or set-level "similar" fallback; grade-split history; named Regular cast / multi-Regular roster; patience or budget streak buffs; archetype-customer spawn bias; §5.2 inventory-mix spawn mod (touches door spawn); §4.2 `staff_knowledge_mod` (would make Specialist a sell weight); sell-weight rewires; changing BM1–BZ1 or door/whale.

**Why now:** BZ1 closed the §4.5 A buy-confirm history line and left price-confirm (B) explicitly dark. Reusing the shipped `sale_history` store for the price-confirm panel is the thinnest remaining §4.5 skill-channel close — zero new save key, zero new writers, no Art, no door/whale, no Soft. No Art.

---

## Option CA2 — STOP / win assert polish — **PARK**

**Why park:** Prefer the §4.5 B history-line close this pick. Flagship / Survive Y1 / Liquidity already wired (R1/S1). Unpark only if PM judges CA1 too thin after BZ1.

---

## Option CA3 — Persist list-time suggested (BK1 Soft OK) — **PARK Soft**

**Why park:** Soft catalog CLOSED.

---

## Option CA4 — Listed-band retag / display-bonus Soft — **PARK Soft**

**Why park:** Soft catalog CLOSED.

---

## Camera off-switch — **HARD PARK Soft**

**Why park (hard):** Reopens Soft catalog.

---

## Recommendation (non-binding)

**GO CA1** (Price-confirm "Last sold in-shop" history line). Park CA2/CA3/CA4. **Hard-park** the camera off-switch. Soft catalog stays closed. Soft OK list-time stays Soft. BZ1 Soft notes stay Soft. Named Regular cast, patience buffs, archetype spawn bias, and inventory-mix spawn stay Out (door/whale stay as shipped). BM1–BZ1 untouched.

If PM judges CA1 too thin to be load-bearing: §3 / §4–§9 systems rows are otherwise exhausted after BZ1, so the honest alternative is **CA2 STOP** (unpark) rather than reopening Soft.

---

## PM checklist

- [ ] Choose **CA1** (recommended)
- [ ] If CA1: Eng vs §4.5 B mirror of BZ1. Reuse `SaleHistory` / `sale_history` (no new save key, no new writers). Price-confirm shows `Last sold in-shop: $X, N days ago` when the SKU has history, else hidden. Display only — no change to suggested / vs-sug / position / band / move feel / display context / `p_buy`. Buy-confirm / BZ1 record path untouched. Leave Soft OK list-time Soft. No Art. BM1–BZ1 / buyer door / whale / BN1–BO1 seller weight untouched
- [ ] Sync this file to main before cloud agent
- [ ] Soft catalog stays closed; STOP stays parked

---

## Decision log

| When | Decision |
|------|----------|
| 2026-10-05 ~10:05pm ET | Drafted post BZ1 SHIPPED #108 @ `df1fd35a` (reviewed `d1801c97`; QA PASS-with-notes harness 991/0/4 +4 Soft OK; save key `sale_history`; docs status `099ca43d`). Lean **CA1 Price-confirm "Last sold in-shop" history line** (§4.5 B mirror of BZ1). Verified on tip `d1801c97`: harness asserts price confirm stays dark; `last_sold_in_shop_line` is buy/trade only. Reuses shipped store — no new key/writers. §3 channels / §8 events / §4.3–§4.4 / §5.3 / §6.3 / §4.5 A otherwise live. STOP / Soft reopeners parked. Camera off-switch hard-parked. Soft CLOSED. Soft OK list-time stays Soft. BZ1 Soft notes stay Soft. No Art. BM1–BZ1 stay as shipped. |
