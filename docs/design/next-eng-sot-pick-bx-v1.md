# Next Eng SoT Pick BX v1 — post BW1

**Status:** **ENG APPROVE + Soft OK** 2026-10-05 ~9:02pm ET — BX1 [#106](https://github.com/adamwlarson/cardshopsimulator/pull/106) @ `1046fd24` (bar `f817422e`). Soft CLOSED. Soft OK list-time Soft. No Art. Design Soft OK on Soft notes. QA formal running; hold merge until PASS.
**Author:** CSS Designer
**Date:** 2026-10-05
**Depends on:** pick-bw (BW1 Auction snipe SKU pool SHIPPED #105 @ `f2b1eb61`, reviewed `fb7b1e1c`; docs status `eaab995a`); Soft catalog CLOSED
**Rule:** Pick **one**. §4.5 never leaks. Soft catalog stays closed. Hard-park camera off-switch Soft. Do **not** turn BW1, BV1, BU1, BT1, BS1, BR1, BQ1, BP1, BO1, BN1, BM1, BL1, BK1, BJ1, BI1, BH1, BG1, BF1, BE1, BD1, BC1, BB1, BA1, AZ1, AY1, AX1, AW1, AV1, AU1, AT1, AS1, AR1, AQ1, AP1, AO1, AN1, AM1, AL1, AK1, AJ1, AI1, AH1, AG1, AF1, AC1, AD1, AE1, or AA1 into a sell weight. STOP stays parked.

---

## Context (shipped)

| Pack | Result |
|------|--------|
| A–BW1 | Full loop + fair/overprice settle + suggested day-clear + buylist drip / fewer-lots / high-% flood + daily utilities + calendar set release hype + Pro tour archetype spike + Rotation staples crash + Distributor weekly restock menu + Recurring marketplace lots 1–3/day + Recurring player-trade pool + Auction snipe SKU pool |
| Soft | Catalog CLOSED; AC1 through BW1 Soft OK MVP notes stay Soft (incl. BW1 empty-catalog pick_sku_id skip Soft; AA-SKIE-052 also AT1 Soft; event-tag bias grep Soft; no graded fixture Soft; Soft OK list-time Soft) |

**Gap:** With BT1 + BU1 + BV1 + BW1 every §3 **cadence** row, the player-trade unlock, and the auction snipe **SKU pool** are live. The remaining load-bearing §3 gap that is still thin (not Soft) is **Shady trunk SKU pool**. AT1 shipped the night flag, Buy / Report / Walk fork, ask at 25% of `_marketplace_basis_cents`, Low confidence w 0.22, photo cue, and graded fake-slab 8% — but verified on BW1 tip `fb7b1e1c` / docs status `eaab995a`: `ShadyTrunkPolicy.DEFAULT_SKU_ID` is hardcoded `AA-SKIE-052`, and `_make_shady_trunk` always uses that constant (always sets shipped grader / grade on the opportunity). So every trunk night is Empress of Updrafts PSA-style, and §3 "Rare, night flag / Deep discount / High fake/condition risk" never rotates across the live singles catalog. Soft OK list-time suggested stays Soft. Camera off-switch Soft hard-parked. STOP parked. (BW1 Soft note already flagged that `AA-SKIE-052` can also draw as an auction snipe — Out of BX scope; channels stay distinct.)

---

## Option BX1 — Shady trunk SKU pool (systems §3) — **LEAN GO**

**Player fantasy:** When the night flag pops, it isn't always the same Empress slab. Some nights it's a chase single in a slab; some nights it's a quieter staple with the same deep-discount / fake risk. Buy, report, or walk.

| Deliverable | Spec |
|-------------|------|
| Where | Extend `ShadyTrunkPolicy` + the existing `_make_shady_trunk` / Prep list path (same row as AT1). Logic lives in the policy (pool pick), not UI. Out: rewriting the night flag / ask rate / Report Rep / fake rate / confidence / Buy-Report-Walk fork; auction / distributor / marketplace / buylist / player-trade channels; door-spawn or whale weight; Regulars return deepen |
| Cadence | Unchanged AT1: at most **one** trunk per Prep night when `should_offer` / night flag is true. Unbought / walked / reported trunks expire that night and do not carry over |
| Pool | Seeded draw from live-catalog non-`bulk` **SINGLE** SKUs (the graded/fake lane — AT1 always offers as a slab with shipped grader / grade). **Never** sealed, accessories, or `bulk`. Qty **1**. Deterministic for `(RUN_SEED, day)` so the same seed and day always give the same SKU (or none). Keep `AA-SKIE-052` as one legal draw when it qualifies, so same-seed nights that already trunked Empress can still |
| Fallback | Empty live pool, or chosen SKU missing from catalog → fall back to shipped `DEFAULT_SKU_ID` when that SKU is live; else no trunk that night (same as today's "SKU missing → null") |
| Ask / fork | Unchanged AT1: ask = 25% of `_marketplace_basis_cents(sku)` (missing → 25%). Buy: cash − ask, lot → BACKSTOCK as graded (shipped grader / grade / space). Report: offer gone, Rep **+2** once. Walk: offer gone, nothing else moves. Short cash → Buy fails. No haggle on trunks (AT1 path) |
| Fake | Unchanged: graded lot on this channel is `cert_valid` false at **8%** (missing → 8%). Offer never shows `cert_valid` or `true_market`. Fail-on-sale path stays as shipped |
| Bounds | Does **not** change buyer door spawn, whale weight, BN1 / BO1 seller-lot weight, BM1 drip, BT1 menu, BU1 lots, BV1 trades, BW1 auction pool, AQ1, AR1 drift, or AT1 ask / Report Rep / fake rate / flag odds |
| Signal | Buy-confirm shows the shipped Low-confidence shady contract (§4.5): exact ask, comp range (w **0.22**), demand band, Low confidence, photo cue ("inspect strongly recommended"). Never shows `true_market`, `p_buy`, `cert_valid`, the ask rate, or future trunks |
| UI | One Prep list row via existing shady trunk presenter. Soft toast OK on trunk nights. No new screen. No Art |
| Save/load | Trunk re-derives from (seed, day, live pool at load). Closed / bought / reported / walked state for that day persists (no double-act). Loading with flag off / pool empty shows no trunk |
| Untouched | AT1 night flag, ask 25%, Report +2, Walk, fake 8%, Low w 0.22, BW1 auction pool, BT1, BU1, BV1, AO1 Regulars, BM1–BW1 stay as shipped |
| Soft | Catalog untouched; leave Soft OK list-time suggested Soft |

**Acceptance:**

1. Same seed, defaults: every night the flag is on opens at most one BX1 trunk whose SKU is a live non-`bulk` SINGLE offered as a graded slab (shipped grader / grade). Sealed / accessory / `bulk` never appear. Quiet nights with flag off open none.
2. Over a multi-night same-seed sim, at least two distinct SKUs appear as trunks when the live pool has ≥2 eligible SKUs. `AA-SKIE-052` remains a legal draw when it qualifies. Empty pool falls back to DEFAULT when live, else null.
3. Buy / Report / Walk still behave as AT1 (cash / Rep / nothing). Ask still 25% of `_marketplace_basis_cents`. Fake slab still 8% on graded; confirm never shows `cert_valid`.
4. Confirm never shows `true_market`, `p_buy`, or `cert_valid`. Buyer door spawn and whale weight are unchanged. BM1 through BW1 and AS1 are unchanged.
5. Not a sell weight. Soft catalog CLOSED. No Art.

**Out:** STOP / win assert; camera off-switch; Soft OK list-time suggested persistence; listed-band / display-bonus Soft; Regulars return loop deepen; multi-trunk nights; sealed / accessory trunks; changing fake rate or revealing `cert_valid` on the offer; auction event-tag bias; archetype-customer spawn bias; §5.2 inventory-mix spawn mod (touches door spawn); §4.2 `staff_knowledge_mod` (would make Specialist a sell weight); sell-weight rewires; changing BM1–BW1, AT1 ask / Report / fake / flag odds, or BW1 auction pool.

**Why now:** BW1 closed the auction one-SKU Dustway timer. **Shady trunk SKU pool** is the last §3 channel that still plays as a one-SKU Empress night — so "Rare / Deep discount / High fake risk" never rotates. Extending AT1's policy into a seeded live-singles pick keeps the fork, the fake lane, and the signal without new screens, Art, door/whale, or Soft. No Art.

---

## Option BX2 — STOP / win assert polish — **PARK**

**Why park:** No new Eng systems. Prefer the §3 shady trunk pool close this pick.

---

## Option BX3 — Persist list-time suggested (BK1 Soft OK) — **PARK Soft**

**Why park:** Soft catalog CLOSED.

---

## Option BX4 — Listed-band retag / display-bonus Soft — **PARK Soft**

**Why park:** Soft catalog CLOSED.

---

## Camera off-switch — **HARD PARK Soft**

**Why park (hard):** Reopens Soft catalog.

---

## Recommendation (non-binding)

**GO BX1** (Shady trunk SKU pool). Park BX2/BX3/BX4. **Hard-park** the camera off-switch. Soft catalog stays closed. Soft OK list-time stays Soft. BW1 Soft notes stay Soft. Regulars deepen stays Out this pick. Archetype-customer spawn bias and inventory-mix spawn stay Out (door/whale stay as shipped). BM1–BW1 untouched.

---

## PM checklist

- [x] Choose **BX1** (recommended)
- [x] If BX1: Eng vs §3 Shady trunk. Keep AT1 night flag / ask 25% / Report +2 / Walk / fake 8% / Low w 0.22. Seeded ≤1 trunk/Prep night from live non-bulk SINGLE offered as graded slab (never sealed / accessory / bulk). Fallback to `DEFAULT_SKU_ID` when pool empty and that SKU is live. Empress (`AA-SKIE-052`) stays a legal draw. Day-scoped id + save/load. Leave Soft OK list-time Soft. No Art. BM1–BW1 / BW1 auction pool / buyer door / whale / BN1–BO1 seller weight untouched
- [x] Sync this file to main before cloud agent
- [x] Soft catalog stays closed; STOP stays parked

---

## Decision log

| When | Decision |
|------|----------|
| 2026-10-05 ~8:50pm ET | Drafted post BW1 SHIPPED #105 @ `f2b1eb61` (reviewed `fb7b1e1c`; docs status `eaab995a`). Lean **BX1 Shady trunk SKU pool**. Verified on BW1 tip `fb7b1e1c`: `ShadyTrunkPolicy.DEFAULT_SKU_ID` = `AA-SKIE-052` and `_make_shady_trunk` always uses it (always graded with shipped grader / grade), so every trunk night is Empress. §3 cadence + auction pool + player trades otherwise live. STOP / Soft reopeners parked. Camera off-switch hard-parked. Soft CLOSED. Soft OK list-time stays Soft. BW1 Soft notes stay Soft. No Art. BM1–BW1 stay as shipped. |
| 2026-10-05 ~8:51pm ET | **ADOPTED** BX1. Park BX2 STOP / BX3 Soft / BX4 Soft. Camera off-switch hard-parked. Soft CLOSED. Soft OK list-time stays Soft. No Art. Eng bar locked; awaiting tip-freeze. |
| 2026-10-05 ~9:00pm ET | **Tip-frozen** [#106](https://github.com/adamwlarson/cardshopsimulator/pull/106) @ `1046fd24` (branch `cursor/bx1-shady-trunk-sku-pool-26d3`). 3 files, no docs. Cloud agent bc-fd6dee9b archived. Eng review that SHA against bar `f817422e`. QA held until APPROVE; no merge until PASS. Soft catalog CLOSED. |
| 2026-10-05 ~9:02pm ET | **Eng APPROVE** [#106](https://github.com/adamwlarson/cardshopsimulator/pull/106) @ `1046fd24` (SoT `f817422e`). Soft CLOSED. Soft OK list-time Soft. No Art. Soft notes Soft (haggle wording vs AU1; Prism 10.0; empty-catalog existence skip test-only; Empress dual-pool). QA formal released. Do not merge until PASS. |
| 2026-10-05 ~9:02pm ET | **Design Soft OK** on BX1 Eng Soft notes (haggle wording vs AU1; Prism 10.0; empty-catalog existence skip test-only; Empress dual-pool) — Soft CLOSED, not a fail. Soft OK list-time Soft. QA formal still running on #106 @ `1046fd24`; hold merge until PASS. |
