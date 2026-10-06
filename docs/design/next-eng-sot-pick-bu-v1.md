# Next Eng SoT Pick BU v1 — post BT1

**Status:** **SHIPPED** 2026-10-05 ~8:04pm ET — squash-merged [#103](https://github.com/adamwlarson/cardshopsimulator/pull/103) @ `ef34b630` (reviewed `966445c5`). QA PASS-with-notes harness 488/0/1. Soft CLOSED. Soft OK list-time Soft. No Art. Next pick is BV.
**Author:** CSS Designer
**Date:** 2026-10-05
**Depends on:** pick-bt (BT1 Distributor weekly restock menu SHIPPED #102 @ `c22525a5`, reviewed `a1c2b34c`; docs status `c376c6eb`); Soft catalog CLOSED
**Rule:** Pick **one**. §4.5 never leaks. Soft catalog stays closed. Hard-park camera off-switch Soft. Do **not** turn BT1, BS1, BR1, BQ1, BP1, BO1, BN1, BM1, BL1, BK1, BJ1, BI1, BH1, BG1, BF1, BE1, BD1, BC1, BB1, BA1, AZ1, AY1, AX1, AW1, AV1, AU1, AT1, AS1, AR1, AQ1, AP1, AO1, AN1, AM1, AL1, AK1, AJ1, AI1, AH1, AG1, AF1, AC1, AD1, AE1, or AA1 into a sell weight. STOP stays parked.

---

## Context (shipped)

| Pack | Result |
|------|--------|
| A–BT1 | Full loop + fair/overprice settle + suggested day-clear + buylist drip / fewer-lots / high-% flood + daily utilities + calendar set release hype + Pro tour archetype spike + Rotation staples crash + Distributor weekly restock menu |
| Soft | Catalog CLOSED; AC1 through BT1 Soft OK MVP notes stay Soft (incl. BT1 closed-ID saving covers every channel; closed-ID list never pruned) |

**Gap:** Systems §3 names the **Marketplace lot** channel at **1–3/day**, 40–70% of market, noisy photos / condition hidden, tradeoff "travel time (skip 1–2 floor hours) or fee courier"; wireflows §2 Prep list expects "distributor weekly + marketplace lots + scripted beats". BT1 closed the distributor half. Verified on main `c376c6eb`: the only marketplace lines are the scripted `dustway-marketplace-day-1` entry in `data/buy_opportunities.json` (`last_day` 2), the §10 #3 day-3 outing steal (`marketplace-outing-steal`, one-shot beat), and the AQ1 Rep ≥ 75 extra lead (`high-rep-marketplace-lead`). Nothing rolls daily marketplace lots, so from day 3 a Rep < 75 player never sees the Low-confidence channel again, and BA1 marketplace Inspect, BB1/BD1 NM mismatch and the shipped drive-out / courier costs go dark after the beat. Ask basis (`_marketplace_basis_cents`), Low-confidence w 0.15 signal, fog cue, BA1 Inspect, haggle, and the outing costs (`marketplace_outing_attention` 25, `marketplace_outing_floor_skip_seconds` 34, `marketplace_courier_fee_cents` $35) all ship already; BU1 just schedules lots and charges the fetch. Soft OK list-time suggested stays Soft. Camera off-switch Soft hard-parked. STOP parked.

---

## Option BU1 — Recurring marketplace lots 1–3/day (systems §3) — **LEAN GO**

**Player fantasy:** Every morning the classifieds hold one to three lots. Some are steals, some are junk in a nice photo. Drive out and lose floor time, pay the courier, or let it go.

| Deliverable | Spec |
|-------------|------|
| Where | Recurring marketplace `BuyOpportunity` lines built at PREP open in the existing `_open_opportunities()` path (same list as catalog / scripted / glut / BT1 / AQ1 / AS1 / AT1 lines). Logic lives in a policy class (e.g. `MarketplaceLotPolicy`), not UI. Append **after** the AQ1 `_high_rep_marketplace_leads(...)` call so AQ1's template input and output stay byte-identical to main. Out: rewriting the day-1 scripted lot, the §10 #3 outing beat, or the AQ1 lead; auction / shady / distributor / buylist / player-trade channels; door-spawn or whale weight |
| Cadence | Lot day = `day ≥ marketplace_lots_first_day`. Missing first day → **4** (days 1–2 have the scripted lot; day 3 stays the §10 #3 outing beat, whose `_ensure_marketplace_steal` would otherwise grab a BU1 lot). Bad values (≤ 0) fall back. Lots are open that day only (PREP + any existing mid-day buy window). Unbought lots expire at that day's close settle and do not carry over |
| Count | Per day, a seeded integer in [`marketplace_lots_min_per_day`, `marketplace_lots_max_per_day`]. Missing min → **1**. Missing max → **3**. Min ≤ 0 or max < min falls back to both defaults. Capped at pool size. Seed = policy `RUN_SEED` mixed with day + lane (same `_mix` style AS1 / AT1 ship), so the same seed and day always give the same lots |
| Pool | Live-catalog SKUs of class **SEALED** plus **SINGLE** without the `bulk` tag (MVP: `AA-SKIE-ETB`, `AA-SKIE-BLST`, `AA-DUST-ETB`, `AA-BASE-088`, `AA-BASE-078`, `AA-SKIE-047`, `AA-SKIE-052`, `AA-SKIE-058`). **Never** graded, accessories, or `bulk`. Seeded draw without replacement, so there are no duplicate SKUs in one day. Quantity is **2** for sealed and **1** for a single (policy constants, matching the day-1 lot). `space_required` 1. Deterministic ids `marketplace-lot-d{day}-{n}` (n = 1..count). Offer label "Marketplace lot" |
| Ask | Per lot, a seeded rate in [`marketplace_lot_ask_min`, `marketplace_lot_ask_max`]. Missing min → **0.40**. Missing max → **0.70**. Min ≤ 0, max < min, or max > 1 fall back to both defaults. `unit_cost_cents` = `max(1, round(_marketplace_basis_cents(sku) × rate))`, the same live basis AQ1 / AT1 already read. Any live BQ1 / BR1 / BS1 effect moves the basis exactly as it moves those channels. No new discount formula, and no glut hook beyond what `_effective_unit_cost_cents` already does for the marketplace channel |
| Fetch | This is the §3 tradeoff. A BU1 lot buy **requires** one fetch pick on the existing buy-confirm. **Drive out:** spend shipped `marketplace_outing_attention` (25) via `consume_attention` and queue shipped `marketplace_outing_floor_skip_seconds` (34) via `queue_floor_skip`. **Courier:** pay shipped `marketplace_courier_fee_cents` ($35) via `Economy.record_expense(&"courier", "Marketplace courier fee")`. The fetch is charged **per lot**, once, only on a successful buy (straight or haggled). Decline, a failed haggle, or a blocked buy charges nothing. A pick is disabled when you can't cover it: Attention < 25, or cash < lot total + courier. There's no new save field |
| Condition | Condition fog, BA1 Inspect (owner 5 Att; Specialist 2), lot condition roll (`ensure_lot_condition` seeded per dto + day), and BB1 / BD1 NM mismatch all apply exactly as shipped for the marketplace channel. No new condition roll |
| Bounds | Cash and space are hard blockers as shipped (§2.3). Buying one lot closes only that lot. Haggle is one counter, with marketplace odds as shipped. Does **not** change buyer door spawn, whale weight, BN1 / BO1 seller-lot weight (these aren't seller walk-ins), BM1 drip, BP1 utilities, BQ1 / BR1 / BS1 events, BT1 menu, AQ1 lead, AS1 snipe, AT1 trunk, or AR1 drift |
| Signal | Buy-confirm shows the shipped marketplace contract (§4.5 A): exact ask / lot total, comp range (w **0.15**, ×0.55 with Research / Specialist as shipped), demand band, **Low** confidence, "Photo only — inspect recommended", and a cash & space check that includes the courier fee on the courier pick. Fetch picks show only shipped plain costs ("Drive out · Attention 25 · miss 1–2 FLOOR hours" / "Courier · $35"). Never shows `true_market`, `p_buy`, the rolled ask rate / discount %, true condition, future lots, or tomorrow's count |
| UI | One row per lot in the existing Prep list, grouped with other opportunities. A Soft toast is OK on lot days ("{n} marketplace lots posted"). The two fetch picks replace the single Buy button on a BU1 lot's existing buy-confirm. No new screen. No Art |
| Save/load | Lots re-derive from (seed, day), so loading mid-day rebuilds the same SKUs, asks, and quantities. Shipped closed-opportunity ids restore which lots were bought or dismissed (no double-buy, no re-offer). Lot condition re-rolls from the same seed. A pending drive-out floor skip persists through shipped `pending_floor_skip_seconds`. Loading on day 1–3 shows no BU1 lots |
| Untouched | Day-1 scripted marketplace lot, §10 #3 outing beat + its steal, AQ1 extra lead (no fetch added), AS1, AT1, BT1 + day-2 distributor beat, BA1 Inspect costs, BB1 / BD1 mismatch, online fee ladder, fog Inspect, BM1 through BT1 stay as shipped |
| Soft | Catalog untouched; leave Soft OK list-time suggested Soft |

**Acceptance:**

1. Same seed, defaults: every day ≥ 4 opens 1–3 BU1 lots (instrumented: the count over a 30-day sim hits each of 1, 2, and 3 at least once), with distinct SKUs drawn only from live SEALED and non-`bulk` SINGLE SKUs. There are never graded, accessory, or `bulk` lots. Days 1–3 open none, and the day-1 lot, the day-3 outing beat, and the AQ1 lead match main (same ids, SKU, ask, qty).
2. Each lot's unit ask / `_marketplace_basis_cents(sku)` is in [0.40, 0.70]. Sealed lots are qty 2 and singles qty 1. The same seed and day reproduce the identical lots, and bad config values fall back to defaults.
3. A buy with Drive out debits 25 Attention and queues 34 s floor skip. A buy with Courier debits $35 plus the lot total. Each lot charges its fetch once. Decline, a failed haggle, over-cash, or over-space charges no fetch. A pick you can't cover is disabled.
4. Unbought lots are gone the next day, and a bought or dismissed lot is not re-offered. Saving and loading mid-day restores the same lots and their open vs closed state.
5. Buy-confirm shows Low confidence, w 0.15, and the photo-only cue. It never shows `true_market`, `p_buy`, the ask rate, or true condition. BA1 Inspect and BB1 / BD1 mismatch behave as shipped. Buyer door spawn, whale weight, and BN1 / BO1 seller weight are unchanged. BM1 through BT1 are unchanged.
6. Not a sell weight. Soft catalog CLOSED. No Art.

**Out:** STOP / win assert; camera off-switch; Soft OK list-time suggested persistence; listed-band / display-bonus Soft; one-trip-per-day fetch bundling; fetch on the day-1 lot / AQ1 lead / AT1 trunk; marketplace sell-side multi-marketplace or shipping minigame; mixed-SKU "bulk box" lots; per-lot noisy photo art; travel-time distance tiers; AQ1 template reading BU1 lots; condition-bias retune beyond shipped `roll_true_band`; archetype-customer spawn bias; §5.2 inventory-mix spawn mod (touches door spawn); §4.2 `staff_knowledge_mod` (would make Specialist a sell weight); sell-weight rewires; changing BM1–BT1, the day-1 lot, or the §10 #3 beat.

**Why now:** BT1 closed the distributor row. **Marketplace lot 1–3/day** is the last §3 cadence row still dark and it isn't Soft. Without it, the Low-confidence channel, Inspect-before-buy, NM mismatch risk, and the drive-out vs courier bandwidth tradeoff (§0 goal "asymmetric info + bandwidth", §10 #3) fire once on day 3 and never again for Rep < 75. Every part already ships (basis, signal, fog, Inspect, haggle, outing costs), and BU1 just schedules lots and charges the fetch. The per-lot fetch keeps a 40–70% ask from being free money, so cheap singles lots are a skip and only real reads pay. No Art.

---

## Option BU2 — STOP / win assert polish — **PARK**

**Why park:** No new Eng systems. This pick closes the §3 marketplace cadence instead.

---

## Option BU3 — Persist list-time suggested (BK1 Soft OK) — **PARK Soft**

**Why park:** Soft catalog CLOSED.

---

## Option BU4 — Listed-band retag / display-bonus Soft — **PARK Soft**

**Why park:** Soft catalog CLOSED.

---

## Camera off-switch — **HARD PARK Soft**

**Why park (hard):** Reopens Soft catalog.

---

## Recommendation (non-binding)

**GO BU1** (Recurring marketplace lots 1–3/day). Park BU2/BU3/BU4. **Hard-park** the camera off-switch. Soft catalog stays closed. Soft OK list-time stays Soft. BT1 Soft notes stay Soft. Archetype-customer spawn bias and inventory-mix spawn stay Out (door/whale stay as shipped). BM1–BT1 untouched.

---

## PM checklist

- [x] Choose **BU1** (recommended)
- [x] If BU1: Eng vs §3 Marketplace lot. Seeded 1–3 lots/day from day 4. Distinct live SEALED (qty 2) / non-bulk SINGLE (qty 1) SKUs. Ask = seeded [0.40, 0.70] × shipped `_marketplace_basis_cents`. A per-lot fetch is required on buy, either Drive out (25 Att + 34 s floor skip) or Courier ($35), using shipped config. Low confidence w 0.15 + photo-only fog + BA1 Inspect / BB1 mismatch as shipped. Lots expire at close, and save/load re-derives lots plus closed ids. Append after AQ1 so day-1 lot / §10 #3 beat / AQ1 stay byte-identical. Leave Soft OK list-time Soft. No Art. BM1–BT1 / buyer door / whale / BN1–BO1 seller weight untouched
- [x] Sync this file to main before cloud agent
- [x] Soft catalog stays closed; STOP stays parked

---

## Decision log

| When | Decision |
|------|----------|
| 2026-10-05 ~7:40pm ET | Drafted post BT1 SHIPPED #102 @ `c22525a5` (reviewed `a1c2b34c`; docs status `c376c6eb`). Lean **BU1 Recurring marketplace lots 1–3/day**. Verified on main `c376c6eb`: marketplace lines are only `dustway-marketplace-day-1` (`last_day` 2), the §10 #3 one-shot `marketplace-outing-steal`, and the AQ1 Rep ≥ 75 lead, with no daily roll. The outing costs (`marketplace_outing_attention` 25 / `marketplace_outing_floor_skip_seconds` 34 / `marketplace_courier_fee_cents` 3500) already ship in `BalanceConfig`. First day 4 keeps the day-3 beat's steal pick untouched. STOP / Soft reopeners parked. Camera off-switch hard-parked. Soft CLOSED. Soft OK list-time stays Soft. BT1 Soft notes stay Soft. No Art. BM1–BT1 stay as shipped. |
| 2026-10-05 ~7:38pm ET | **ADOPTED** BU1. Park BU2 STOP / BU3 Soft / BU4 Soft. Camera off-switch hard-parked. Soft CLOSED. Soft OK list-time stays Soft. No Art. Eng bar locked; awaiting tip-freeze. Soft notes noted (AQ1 lead id not day-scoped; fetch per lot not per trip) — Soft CLOSED, not in scope. |
| 2026-10-05 ~7:52pm ET | **Tip-frozen** [#103](https://github.com/adamwlarson/cardshopsimulator/pull/103) @ `966445c5` (branch `cursor/bu1-recurring-marketplace-lots-e248`). 6 files, no docs. Cloud agent bc-4c0c2de5 archived. Eng review that SHA against bar `5cbfbbf3`. QA held until APPROVE; no merge until PASS. Soft catalog CLOSED. |
| 2026-10-05 ~8:04pm ET | **SHIPPED** — squash-merged [#103](https://github.com/adamwlarson/cardshopsimulator/pull/103) @ `ef34b630` (reviewed `966445c5`). QA PASS-with-notes harness 488/0/1. Soft OK list-time stays Soft. Soft CLOSED. No Art. Next pick is BV. |
