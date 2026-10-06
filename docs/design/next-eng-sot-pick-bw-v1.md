# Next Eng SoT Pick BW v1 — post BV1

**Status:** **TIP-FROZEN** 2026-10-05 ~8:40pm ET — BW1 [#105](https://github.com/adamwlarson/cardshopsimulator/pull/105) @ `fb7b1e1c` (branch `cursor/bw1-auction-snipe-sku-pool-0473`). Eng review vs bar `7a51c978`. Soft CLOSED. Soft OK list-time Soft. No Art. QA held until APPROVE; no merge until PASS.
**Author:** CSS Designer
**Date:** 2026-10-05
**Depends on:** pick-bv (BV1 Recurring player-trade pool SHIPPED #104 @ `c35ae518`, reviewed `6f245024`; docs status `2321d5a5`); Soft catalog CLOSED
**Rule:** Pick **one**. §4.5 never leaks. Soft catalog stays closed. Hard-park camera off-switch Soft. Do **not** turn BV1, BU1, BT1, BS1, BR1, BQ1, BP1, BO1, BN1, BM1, BL1, BK1, BJ1, BI1, BH1, BG1, BF1, BE1, BD1, BC1, BB1, BA1, AZ1, AY1, AX1, AW1, AV1, AU1, AT1, AS1, AR1, AQ1, AP1, AO1, AN1, AM1, AL1, AK1, AJ1, AI1, AH1, AG1, AF1, AC1, AD1, AE1, or AA1 into a sell weight. STOP stays parked.

---

## Context (shipped)

| Pack | Result |
|------|--------|
| A–BV1 | Full loop + fair/overprice settle + suggested day-clear + buylist drip / fewer-lots / high-% flood + daily utilities + calendar set release hype + Pro tour archetype spike + Rotation staples crash + Distributor weekly restock menu + Recurring marketplace lots 1–3/day + Recurring player-trade pool |
| Soft | Catalog CLOSED; AC1 through BV1 Soft OK MVP notes stay Soft (incl. BV1 mid-day give swap Soft; unlock constant 50 Soft; receive NM Soft; SEEDED_OFFER_ID unused alias Soft; Soft OK list-time Soft) |

**Gap:** With BT1 + BU1 + BV1 every §3 **cadence** row and the §5.3 player-trade unlock are live. The remaining load-bearing §3 gap that is still thin (not Soft) is **Auction snipes SKU pool**. AS1 shipped the event-tied / seeded flag, Attention 10 + ask race, Medium confidence w 0.12, and steal/trap ask noise — but verified on docs status `2321d5a5`: `AuctionSnipePolicy.DEFAULT_SKU_ID` is hardcoded `AA-DUST-ETB`, and `_make_auction_snipe` always uses that constant. So every snipe is Dustway ETB, including days when a named settle event (BQ1/BR1/BS1) force-opens the flag. §3 "Event-tied / Can be steal or trap" never rotates across the live catalog. Soft OK list-time suggested stays Soft. Camera off-switch Soft hard-parked. STOP parked. (AT1 trunk is the same thin-pool shape with `AA-SKIE-052` — park as Out this pick; rarer night cadence, graded/fake lane stays distinct.)

---

## Option BW1 — Auction snipe SKU pool (systems §3) — **LEAN GO**

**Player fantasy:** When the timer pops, it isn't always the same Dustway ETB. Some days it's sealed you need; some days it's a noisy single. Bid Attention and cash, or let it go — especially when a hype / spike / crash event force-opens the board.

| Deliverable | Spec |
|-------------|------|
| Where | Extend `AuctionSnipePolicy` + the existing `_make_auction_snipe` / Prep list path (same row as AS1). Logic lives in the policy (pool pick), not UI. Out: rewriting the flag / event force-on / Attention cost / ask noise / confidence; shady / distributor / marketplace / buylist / player-trade channels; door-spawn or whale weight; Regulars return deepen |
| Cadence | Unchanged AS1: at most **one** snipe per Prep day when `should_offer` is true (seeded flag or named settle event live). Unbought / declined snipes expire at that day's close and do not carry over |
| Pool | Seeded draw from live-catalog **SEALED** and non-`bulk` **SINGLE** SKUs (same classes BU1 / BV1 use). **Never** graded, accessories, or `bulk`. Qty **1**. Deterministic for `(RUN_SEED, day)` so the same seed and day always give the same SKU (or none). Keep `AA-DUST-ETB` as one legal draw when it qualifies, so same-seed days that already sniped Dustway can still |
| Fallback | Empty live pool, or chosen SKU missing from catalog → fall back to shipped `DEFAULT_SKU_ID` when that SKU is live; else no snipe that day (same as today's "SKU missing → null") |
| Ask / bid | Unchanged AS1: ask via shipped `ask_cents(market_cents_for(sku), seed, day)` (steal/trap noise). Bid spends Attention **10** + cash equal to ask; lot → BACKSTOCK. Short Attention or cash → bid fails, nothing moves. Decline closes the day. No haggle on snipes (AS1 path) |
| Event | Unchanged: a live named settle event still force-opens the flag. MVP does **not** bias the pool toward event-tagged SKUs (Out) — rotation alone is enough so event days are not stuck on Dustway |
| Bounds | Does **not** change buyer door spawn, whale weight, BN1 / BO1 seller-lot weight, BM1 drip, BT1 menu, BU1 lots, BV1 trades, AT1 trunk, AQ1, AR1 drift, or AS1 Attention / width / flag odds |
| Signal | Buy-confirm shows the shipped Medium-confidence auction contract (§4.5): exact ask, comp range (w **0.12**), demand band, Medium confidence, photo cue. Never shows `true_market`, `p_buy`, the ask offset / steal-vs-trap bit, or future snipes |
| UI | One Prep list row via existing auction presenter. Soft toast OK on snipe days. No new screen. No Art |
| Save/load | Snipe re-derives from (seed, day, live pool at load). Closed / declined / bought state for that day persists (no double-bid). Loading with flag off / pool empty shows no snipe |
| Untouched | AS1 Attention 10, flag / event force-on, ask noise, Medium w 0.12, AT1 trunk + fake slab, BT1, BU1, BV1, AO1 Regulars, BM1–BV1 stay as shipped |
| Soft | Catalog untouched; leave Soft OK list-time suggested Soft |

**Acceptance:**

1. Same seed, defaults: every day `should_offer` is true opens at most one BW1 snipe whose SKU is a live SEALED or non-`bulk` SINGLE. Graded / accessory / `bulk` never appear. Quiet days with flag off open none. Named-event days still force the flag on.
2. Over a multi-day same-seed sim, at least two distinct SKUs appear as snipes when the live pool has ≥2 eligible SKUs. `AA-DUST-ETB` remains a legal draw when it qualifies. Empty pool falls back to DEFAULT when live, else null.
3. Bid still costs Attention 10 + ask and lands the lot in BACKSTOCK. Short Attention / cash fails with nothing moved. Decline / expire-at-close work. Ask still uses shipped steal/trap noise on `market_cents_for`.
4. Confirm never shows `true_market`, `p_buy`, or the steal/trap bit. Buyer door spawn and whale weight are unchanged. BM1 through BV1 and AT1 are unchanged.
5. Not a sell weight. Soft catalog CLOSED. No Art.

**Out:** STOP / win assert; camera off-switch; Soft OK list-time suggested persistence; listed-band / display-bonus Soft; shady trunk SKU pool deepen (AT1 still `AA-SKIE-052` — separate channel); Regulars return loop deepen; multi-snipe / multi-lot auction days; event-tag pool bias; auction haggle; graded snipes; archetype-customer spawn bias; §5.2 inventory-mix spawn mod (touches door spawn); §4.2 `staff_knowledge_mod` (would make Specialist a sell weight); sell-weight rewires; changing BM1–BV1, AS1 Attention / flag odds / ask noise, or AT1 trunk.

**Why now:** BT1 / BU1 / BV1 closed §3 cadence and the player-trade unlock. **Auction snipe SKU pool** is the last §3 channel that still plays as a one-SKU Dustway timer — including on BQ1/BR1/BS1 force-open days — so "Event-tied / steal or trap" never rotates. Extending AS1's policy into a seeded live-catalog pick keeps the race, the Attention cost, and the signal without new screens, Art, door/whale, or Soft. No Art.

---

## Option BW2 — STOP / win assert polish — **PARK**

**Why park:** No new Eng systems. Prefer the §3 auction pool close this pick.

---

## Option BW3 — Persist list-time suggested (BK1 Soft OK) — **PARK Soft**

**Why park:** Soft catalog CLOSED.

---

## Option BW4 — Listed-band retag / display-bonus Soft — **PARK Soft**

**Why park:** Soft catalog CLOSED.

---

## Camera off-switch — **HARD PARK Soft**

**Why park (hard):** Reopens Soft catalog.

---

## Recommendation (non-binding)

**GO BW1** (Auction snipe SKU pool). Park BW2/BW3/BW4. **Hard-park** the camera off-switch. Soft catalog stays closed. Soft OK list-time stays Soft. BV1 Soft notes stay Soft. Shady trunk pool deepen and Regulars deepen stay Out this pick. Archetype-customer spawn bias and inventory-mix spawn stay Out (door/whale stay as shipped). BM1–BV1 untouched.

---

## PM checklist

- [x] Choose **BW1** (recommended)
- [x] If BW1: Eng vs §3 Auction snipes. Keep AS1 flag / event force-on / Attention 10 / ask noise / Medium w 0.12. Seeded ≤1 snipe/Prep day from live SEALED / non-bulk SINGLE (never graded / accessory / bulk). Fallback to `DEFAULT_SKU_ID` when pool empty and that SKU is live. Dustway stays a legal draw. Day-scoped id + save/load. Leave Soft OK list-time Soft. No Art. BM1–BV1 / AT1 / buyer door / whale / BN1–BO1 seller weight untouched
- [x] Sync this file to main before cloud agent
- [x] Soft catalog stays closed; STOP stays parked

---

## Decision log

| When | Decision |
|------|----------|
| 2026-10-05 ~8:31pm ET | Drafted post BV1 SHIPPED #104 @ `c35ae518` (reviewed `6f245024`; docs status `2321d5a5`). Lean **BW1 Auction snipe SKU pool**. Verified on tip `2321d5a5`: `AuctionSnipePolicy.DEFAULT_SKU_ID` = `AA-DUST-ETB` and `_make_auction_snipe` always uses it, so every snipe (incl. event force-open) is Dustway. §3 cadence + player trades otherwise live. AT1 trunk still thin (`AA-SKIE-052`) — Out this pick. STOP / Soft reopeners parked. Camera off-switch hard-parked. Soft CLOSED. Soft OK list-time stays Soft. BV1 Soft notes stay Soft. No Art. BM1–BV1 stay as shipped. |
| 2026-10-05 ~8:32pm ET | **ADOPTED** BW1. Park BW2 STOP / BW3 Soft / BW4 Soft. Camera off-switch hard-parked. Soft CLOSED. Soft OK list-time stays Soft. No Art. Eng bar locked; awaiting tip-freeze. |
| 2026-10-05 ~8:40pm ET | **Tip-frozen** [#105](https://github.com/adamwlarson/cardshopsimulator/pull/105) @ `fb7b1e1c` (branch `cursor/bw1-auction-snipe-sku-pool-0473`). 3 files, no docs. Cloud agent bc-f5159730 archived. Eng review that SHA against bar `7a51c978`. QA held until APPROVE; no merge until PASS. Soft catalog CLOSED. |
