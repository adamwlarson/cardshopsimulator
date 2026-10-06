# Next Eng SoT Pick BY v1 — post BX1

**Status:** **ENG APPROVE** 2026-10-05 ~9:21pm ET — BY1 [#107](https://github.com/adamwlarson/cardshopsimulator/pull/107) @ `da5b39d7` (bar `01538252`). Soft CLOSED. Soft OK list-time Soft. No Art. Soft notes Soft (100M sentinel budget; fallback clear in build; listed-at-release; pre-BY1 saves queue 0; no-truth grep). QA formal released; hold merge until PASS.
**Author:** CSS Designer
**Date:** 2026-10-05
**Depends on:** pick-bx (BX1 Shady trunk SKU pool SHIPPED #106 @ `d94a7c6f`, reviewed `1046fd24`; docs status `ed21cd8b`); Soft catalog CLOSED
**Rule:** Pick **one**. §4.5 never leaks. Soft catalog stays closed. Hard-park camera off-switch Soft. Do **not** turn BX1, BW1, BV1, BU1, BT1, BS1, BR1, BQ1, BP1, BO1, BN1, BM1, BL1, BK1, BJ1, BI1, BH1, BG1, BF1, BE1, BD1, BC1, BB1, BA1, AZ1, AY1, AX1, AW1, AV1, AU1, AT1, AS1, AR1, AQ1, AP1, AO1, AN1, AM1, AL1, AK1, AJ1, AI1, AH1, AG1, AF1, AC1, AD1, AE1, or AA1 into a sell weight. STOP stays parked.

---

## Context (shipped)

| Pack | Result |
|------|--------|
| A–BX1 | Full loop + fair/overprice settle + suggested day-clear + buylist drip / fewer-lots / high-% flood + daily utilities + calendar set release hype + Pro tour archetype spike + Rotation staples crash + Distributor weekly restock menu + Recurring marketplace lots 1–3/day + Recurring player-trade pool + Auction snipe SKU pool + Shady trunk SKU pool |
| Soft | Catalog CLOSED; AC1 through BX1 Soft OK MVP notes stay Soft (incl. BX1 haggle wording vs AU1 Soft; Prism 10.0 Soft; empty-catalog existence skip Soft; Empress dual-pool Soft; Soft OK list-time Soft) |

**Gap:** With BT1 + BU1 + BV1 + BW1 + BX1 every §3 **cadence** row and both thin **SKU pools** (auction + shady) are live. The remaining load-bearing systems gap that is still thin (not Soft, not camera, not STOP-only) is **Regulars relationship stock**. AO1 shipped the §5.3 band 50–74 return visit (listed-price sale → queue ≤1 Regular for next floor open), but verified on BX1 tip `1046fd24`: `RegularsReturnService` only stores `_queued` count; `note_outcome` / `note_listed_sale` never read `customer.target_sku` / `desired_skus`; `build_return_customer` copies the catalog Regular midpoints and `interest_tags` (`accessory` / `staple` / `sealed`) with no memory of what they bought. So §5.1 Regular "**Relationship stock** / Returns if treated well" still plays as a faceless archetype bounce — they come back, but not for the stock you sold them. Soft OK list-time suggested stays Soft. Camera off-switch Soft hard-parked. STOP parked. (Archetype-customer spawn bias and §5.2 inventory-mix spawn stay Out — they touch door spawn.)

---

## Option BY1 — Regulars relationship stock (systems §5.1 Regular / §5.3) — **LEAN GO**

**Player fantasy:** Treat a buyer fairly at Rep 50 and they come back tomorrow for **that** card (or class) — not a random accessory/staple bounce. Stock what they love and they keep the loop alive.

| Deliverable | Spec |
|-------------|------|
| Where | Extend `RegularsReturnPolicy` + `RegularsReturnService` (same AO1 queue / `take_floor_return` / Prep→floor release path). Logic lives in the service (remember SKU on queue; set `wants_sku` / `desired_skus` on build). Out: rewriting the Rep gate / queue cap / listed-price-only rule; door-spawn or whale weight; archetype spawn bias; buy channels (BT1–BX1) |
| Unlock / cadence | Unchanged AO1: Rep **≥ 50** can queue; Rep **≤ 49** never queues. Cap **1** queued return. Listed-price sale only (walkout / refuse / negotiated sale queues nothing). A second listed sale the same day does not add another. Arrival alone does not re-queue |
| Relationship stock | On a successful queue, remember the sold customer's `target_sku` (fallback: first of `desired_skus` if `target_sku` empty). When `build_return_customer` / `take_floor_return` builds the Regular: if that SKU is still a live catalog SKU **and** currently floor-listed (same "on the floor" check the existing sale path already uses for offers), set `wants_sku` and `desired_skus = [sku]` so they target that SKU. Else clear the remembered SKU for this release and fall back to shipped AO1 archetype `interest_tags` midpoints (so a sold-out / delisted chase still yields a playable Regular, not a stuck null) |
| Bounds | Does **not** change buyer door spawn count, whale weight, BN1 / BO1 seller-lot weight, BM1 drip, BT1–BX1 buy channels, AO1 unlock Rep / queue cap, or sell-through weights |
| Signal | Floor UI may show the existing wants label for the targeted SKU. Never shows `true_market`, `p_buy`, or a "guaranteed sell" cue. Soft toast OK ("Your Regular is back") |
| UI | Existing Regular / scripted-customer release path. No new screen. No Art |
| Save/load | Persist queued count **and** remembered relationship `sku_id` (empty string when none). Loading with queue 0 clears the SKU. Loading with a remembered SKU that is no longer live / not floor-listed still releases a Regular via the AO1 fallback (do not drop the visit). Any new save key gets called out |
| Untouched | AO1 unlock Rep 50 / cap 1 / listed-only, AN1/BV1 trades, AT1/BX1 trunk, AS1/BW1 snipes, BT1, BU1, BM1–BX1 stay as shipped |
| Soft | Catalog untouched; leave Soft OK list-time suggested Soft |

**Acceptance:**

1. Same seed, defaults: a listed sale at Rep ≥ 50 of SKU X queues one Regular whose next-floor `wants_sku` / `desired_skus` is X when X is still floor-listed. The same sale at Rep ≤ 49 queues nothing.
2. If X is delisted or missing at release, the Regular still arrives as AO1 (archetype interest_tags), not null. Walkout / refuse / negotiated sale still queue nothing. Cap stays 1.
3. Confirm / floor UI never shows `true_market` or `p_buy`. Buyer door spawn and whale weight at Rep 50 still match Rep 49.
4. Save/load mid-queue restores count + remembered SKU. BM1 through BX1 are unchanged.
5. Not a sell weight. Soft catalog CLOSED. No Art.

**Out:** STOP / win assert; camera off-switch; Soft OK list-time suggested persistence; listed-band / display-bonus Soft; named Regular cast / multi-Regular roster; patience or budget streak buffs; multi-queue / cap > 1; archetype-customer spawn bias; §5.2 inventory-mix spawn mod (touches door spawn); §4.2 `staff_knowledge_mod` (would make Specialist a sell weight); sell-weight rewires; auction event-tag bias; changing BM1–BX1, AO1 unlock / cap, or door/whale.

**Why now:** §3 cadence + thin SKU pools closed with BX1. **Regulars relationship stock** is the last §5.1 / §5.3 unlock half that still plays as a faceless bounce — AO1 proved the return visit; this pick makes the return about the stock you sold, without new screens, Art, door/whale, or Soft. No Art.

---

## Option BY2 — STOP / win assert polish — **PARK**

**Why park:** No new Eng systems. Prefer the §5.1 relationship-stock close this pick. Flagship / Survive Y1 / Liquidity already wired (R1/S1).

---

## Option BY3 — Persist list-time suggested (BK1 Soft OK) — **PARK Soft**

**Why park:** Soft catalog CLOSED.

---

## Option BY4 — Listed-band retag / display-bonus Soft — **PARK Soft**

**Why park:** Soft catalog CLOSED.

---

## Camera off-switch — **HARD PARK Soft**

**Why park (hard):** Reopens Soft catalog.

---

## Recommendation (non-binding)

**GO BY1** (Regulars relationship stock). Park BY2/BY3/BY4. **Hard-park** the camera off-switch. Soft catalog stays closed. Soft OK list-time stays Soft. BX1 Soft notes stay Soft. Archetype-customer spawn bias and inventory-mix spawn stay Out (door/whale stay as shipped). BM1–BX1 untouched.

---

## PM checklist

- [ ] Choose **BY1** (recommended)
- [ ] If BY1: Eng vs §5.1 Regular / §5.3. Keep AO1 Rep ≥ 50 / cap 1 / listed-only. On queue remember sold `target_sku`; on release set `wants_sku` / `desired_skus` when that SKU is still floor-listed, else AO1 interest_tags fallback. Persist queue + sku_id. Leave Soft OK list-time Soft. No Art. BM1–BX1 / buyer door / whale / BN1–BO1 seller weight untouched
- [ ] Sync this file to main before cloud agent
- [ ] Soft catalog stays closed; STOP stays parked

---

## Decision log

| When | Decision |
|------|----------|
| 2026-10-05 ~9:12pm ET | **ADOPTED** BY1. Park BY2 STOP / BY3 Soft / BY4 Soft. Camera off-switch hard-parked. Soft CLOSED. Soft OK list-time stays Soft. No Art. Eng bar locked; awaiting tip-freeze. |
| 2026-10-05 ~9:20pm ET | **Tip-frozen** [#107](https://github.com/adamwlarson/cardshopsimulator/pull/107) @ `da5b39d7` (branch `cursor/by1-regulars-relationship-stock-0478`). 5 files, no docs. New save key `regulars_return` `{queued, sku_id}`. Cloud agent bc-6c9d8f00 archived. Eng review that SHA against bar `01538252`. QA held until APPROVE; no merge until PASS. Soft catalog CLOSED. |
| 2026-10-05 ~9:21pm ET | **Eng APPROVE** [#107](https://github.com/adamwlarson/cardshopsimulator/pull/107) @ `da5b39d7` (SoT `01538252`). Soft CLOSED. Soft OK list-time Soft. No Art. Soft notes Soft (100M sentinel budget; fallback clear in build; listed-at-release; pre-BY1 saves queue 0; no-truth grep). QA formal released. Do not merge until PASS. |
| 2026-10-05 ~9:12pm ET | Drafted post BX1 SHIPPED #106 @ `d94a7c6f` (reviewed `1046fd24`; docs status `ed21cd8b`). Lean **BY1 Regulars relationship stock**. Verified on BX1 tip `1046fd24`: `RegularsReturnService` stores only `_queued`; `build_return_customer` copies catalog Regular midpoints / `interest_tags` with no sale-SKU memory, so §5.1 "Relationship stock" never lands. §3 cadence + auction/shady pools otherwise live. STOP / Soft reopeners parked. Camera off-switch hard-parked. Soft CLOSED. Soft OK list-time stays Soft. BX1 Soft notes stay Soft. No Art. BM1–BX1 stay as shipped. |
