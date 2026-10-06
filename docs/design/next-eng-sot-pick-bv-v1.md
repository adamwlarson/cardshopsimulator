# Next Eng SoT Pick BV v1 — post BU1

**Status:** **ADOPTED** 2026-10-05 ~8:07pm ET — BV1 Recurring player-trade pool. Eng bar = this file on main after sync. Soft CLOSED. Soft OK list-time Soft. No Art. Park BV2 STOP / BV3 Soft / BV4 Soft. Camera hard-parked.
**Author:** CSS Designer
**Date:** 2026-10-05
**Depends on:** pick-bu (BU1 Recurring marketplace lots 1–3/day SHIPPED #103 @ `ef34b630`, reviewed `966445c5`; docs status `fb60287d`); Soft catalog CLOSED
**Rule:** Pick **one**. §4.5 never leaks. Soft catalog stays closed. Hard-park camera off-switch Soft. Do **not** turn BU1, BT1, BS1, BR1, BQ1, BP1, BO1, BN1, BM1, BL1, BK1, BJ1, BI1, BH1, BG1, BF1, BE1, BD1, BC1, BB1, BA1, AZ1, AY1, AX1, AW1, AV1, AU1, AT1, AS1, AR1, AQ1, AP1, AO1, AN1, AM1, AL1, AK1, AJ1, AI1, AH1, AG1, AF1, AC1, AD1, AE1, or AA1 into a sell weight. STOP stays parked.

---

## Context (shipped)

| Pack | Result |
|------|--------|
| A–BU1 | Full loop + fair/overprice settle + suggested day-clear + buylist drip / fewer-lots / high-% flood + daily utilities + calendar set release hype + Pro tour archetype spike + Rotation staples crash + Distributor weekly restock menu + Recurring marketplace lots 1–3/day |
| Soft | Catalog CLOSED; AC1 through BU1 Soft OK MVP notes stay Soft (incl. BU1 toast overstate; cash gate on partial; haggle on fetch) |

**Gap:** With BT1 + BU1 every §3 **cadence** row is live (Distributor weekly, Marketplace 1–3/day, Auction seeded/event snipes, Shady night trunk, Buylist walk-ins). The remaining load-bearing §3 / §5.3 gap that is still thin (not Soft) is **Player trades**. AN1 unlocked the Rep ≥ 50 gate and ships a single hardcoded in-kind pair (`AA-DUST-ETB` give → `AA-SKIE-ETB` receive). Verified on main tip `fb60287d` / reviewed `966445c5`: `PlayerTradePolicy` exposes only `SEEDED_OFFER_ID` / those two SKUs; `PlayerTradeService.roll_open` returns that one offer or null when Dustway is missing. So band 50–74's named unlock (§5.3 "Regulars + player trades unlock", §3 "In-kind / Full / Opportunity cost of stock given") almost never fires after the player sells through seed Dustway, and never rotates. Soft OK list-time suggested stays Soft. Camera off-switch Soft hard-parked. STOP parked.

---

## Option BV1 — Recurring player-trade pool (systems §3 / §5.3) — **LEAN GO**

**Player fantasy:** At Rep 50 the other shops start calling. Some days they want your sealed; some days they want a chase single. You give stock you can spare and take stock you need — or you hang up.

| Deliverable | Spec |
|-------------|------|
| Where | Recurring player-trade offer built at PREP open through the existing `PlayerTradeService.roll_open` / Prep list path (same row as AN1). Logic lives in `PlayerTradePolicy` (extend, do not replace the Rep gate). Out: cash buys; auction / shady / distributor / marketplace / buylist channels; door-spawn or whale weight; Regulars return loop |
| Unlock | Unchanged AN1 gate: Rep **≥ 50** can offer; Rep **≤ 49** never offers. Missing / bad unlock falls back to **50** |
| Cadence | At most **one** open trade per Prep day when unlocked. Seed mixes `RUN_SEED`, day, and lane so the same seed and day give the same pair (or none). Unaccepted / declined trades expire at that day's close settle and do not carry over |
| Pool | Seeded without-replacement draw from live-catalog **SEALED** and non-`bulk` **SINGLE** SKUs the player **owns** (≥ give qty) as the give side, and a different live SEALED / non-bulk SINGLE as the receive side. **Never** graded, accessories, or `bulk`. Give qty **1** sealed or single (MVP). Receive qty **1**. If the owned pool is empty, no trade that day (same as today's "no Dustway → no offer") |
| Pair | Deterministic id `player-trade-d{day}` (day-scoped so closed-id / decline persist). Offer label "Shop trade". Counterparty label "Another shop". Condition on both sides is **Full** / visible (sealed NM or the owned lot's graded-visible cue as shipped for trades — never photo-fog). Keep the AN1 Dust→Skie pair as one legal draw when both SKUs qualify, so same-seed days that already offered it can still |
| Accept / Decline | Accept: give lot leaves inventory, receive lot enters BACKSTOCK at the give lot's unit cost (shipped AN1 path). Cash does **not** change. Decline: offer closes for the day. Space short on BACKSTOCK → Accept disabled (shipped). No haggle on trades (in-kind; AU1 already Out'd trades) |
| Bounds | Does **not** change buyer door spawn, whale weight, BN1 / BO1 seller-lot weight, BM1 drip, BT1 menu, BU1 lots, AQ1 / AS1 / AT1, AR1 drift, or AN1 unlock Rep |
| Signal | Trade confirm shows both SKUs, qtys, visible conditions, and counterparty. Confidence tag is not a cash buy — no comp range / ask / `true_market` / `p_buy`. Never shows future trades or tomorrow's pair |
| UI | One Prep list row via existing player-trade presenter. Soft toast OK on trade days ("A shop wants to trade"). No new screen. No Art |
| Save/load | Pair re-derives from (seed, day, owned pool at load). Closed / declined state for that day persists (no double-accept). Loading at Rep ≤ 49 shows no trade. Loading mid-day without the give lot shows none |
| Untouched | AN1 unlock Rep 50, AO1 Regulars, AU1 haggle (cash channels only), AT1 trunk, AS1 snipes, BT1, BU1, BM1–BU1 stay as shipped |
| Soft | Catalog untouched; leave Soft OK list-time suggested Soft |

**Acceptance:**

1. Same seed, defaults: every day at Rep ≥ 50 with ≥1 owned live SEALED / non-bulk SINGLE can open at most one BV1 trade whose give SKU is owned and receive SKU is a different live SEALED / non-bulk SINGLE. Days at Rep ≤ 49 open none. Graded / accessory / `bulk` never appear.
2. Accept moves give→out and receive→BACKSTOCK with cash unchanged. Decline closes the day. Space-short Accept is disabled. Bad unlock config falls back to 50.
3. Unaccepted trades are gone the next day. Saving and loading mid-day restores the same pair and open vs closed state when the give lot is still owned.
4. Confirm never shows `true_market`, `p_buy`, or a cash ask. Buyer door spawn and whale weight are unchanged. BM1 through BU1 are unchanged.
5. Not a sell weight. Soft catalog CLOSED. No Art.

**Out:** STOP / win assert; camera off-switch; Soft OK list-time suggested persistence; listed-band / display-bonus Soft; Regulars return loop deepen; multi-lot / multi-SKU basket trades; cash boot on top of in-kind; trade haggle; auction multi-SKU pool deepen (AS1 still single default SKU — separate channel); shady trunk SKU pool deepen; archetype-customer spawn bias; §5.2 inventory-mix spawn mod (touches door spawn); §4.2 `staff_knowledge_mod` (would make Specialist a sell weight); sell-weight rewires; changing BM1–BU1 or the AN1 unlock gate.

**Why now:** BT1 + BU1 closed the §3 cadence rows. **Player trades** is the last §3 / §5.3 unlock that still plays as a one-shot Dust→Skie swap — band 50–74's named verb goes dark the moment seed Dustway sells through. Extending AN1's policy into a seeded owned-pool roll keeps the unlock, the in-kind fantasy, and the opportunity-cost beat without new screens, Art, door/whale, or Soft. No Art.

---

## Option BV2 — STOP / win assert polish — **PARK**

**Why park:** No new Eng systems. Prefer the §3 player-trade pool close this pick.

---

## Option BV3 — Persist list-time suggested (BK1 Soft OK) — **PARK Soft**

**Why park:** Soft catalog CLOSED.

---

## Option BV4 — Listed-band retag / display-bonus Soft — **PARK Soft**

**Why park:** Soft catalog CLOSED.

---

## Camera off-switch — **HARD PARK Soft**

**Why park (hard):** Reopens Soft catalog.

---

## Recommendation (non-binding)

**GO BV1** (Recurring player-trade pool). Park BV2/BV3/BV4. **Hard-park** the camera off-switch. Soft catalog stays closed. Soft OK list-time stays Soft. BU1 Soft notes stay Soft. Archetype-customer spawn bias and inventory-mix spawn stay Out (door/whale stay as shipped). BM1–BU1 untouched.

---

## PM checklist

- [x] Choose **BV1** (recommended)
- [x] If BV1: Eng vs §3 / §5.3 Player trades. Keep AN1 Rep ≥ 50 unlock. Seeded ≤1 trade/Prep day from owned live SEALED / non-bulk SINGLE → different live SEALED / non-bulk SINGLE. Full visible condition. Accept is in-kind only (cash unchanged; receive → BACKSTOCK). Decline / expire at close. Day-scoped id + save/load. Leave Soft OK list-time Soft. No Art. BM1–BU1 / buyer door / whale / BN1–BO1 seller weight untouched
- [x] Sync this file to main before cloud agent
- [x] Soft catalog stays closed; STOP stays parked

---

## Decision log

| When | Decision |
|------|----------|
| 2026-10-05 ~8:07pm ET | Drafted post BU1 SHIPPED #103 @ `ef34b630` (reviewed `966445c5`; docs status `fb60287d`). Lean **BV1 Recurring player-trade pool**. Verified on tip `966445c5` / status `fb60287d`: `PlayerTradePolicy` is a single Dust→Skie seeded pair behind the Rep ≥ 50 gate, so band 50–74's unlock dies once Dustway is gone. §3 cadence (BT1/BU1/AS1/AT1/buylist) is otherwise live. STOP / Soft reopeners parked. Camera off-switch hard-parked. Soft CLOSED. Soft OK list-time stays Soft. BU1 Soft notes stay Soft. No Art. BM1–BU1 stay as shipped. |
| 2026-10-05 ~8:07pm ET | **ADOPTED** BV1. Park BV2 STOP / BV3 Soft / BV4 Soft. Camera off-switch hard-parked. Soft CLOSED. Soft OK list-time stays Soft. No Art. Eng bar locked; awaiting tip-freeze. |
