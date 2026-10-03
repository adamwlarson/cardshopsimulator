# Next Eng SoT Pick AS v1 — post AR1

**Status:** **AS1 ADOPTED** 2026-10-03 — Auction snipes. Park AS2/AS3/AS4. Hard-park camera off-switch. Soft catalog CLOSED. Fees, net-worth HUD, and STOP stay parked. Do not turn rep bands, trades, shrink, walkouts, or Fire into a sell weight. Door spawn math stays as shipped.
**Author:** CSS Designer
**Date:** 2026-10-03
**Depends on:** pick-ar (AR1 Daily true_market drift SHIPPED #74 @ `86438938`); Soft catalog CLOSED
**Rule:** Pick **one**. §4.5 never leaks. Soft catalog stays closed. Hard-park camera off-switch Soft. Do **not** turn AR1, AQ1, AP1, AO1, AN1, AM1, AL1, AK1, AJ1, AI1, AH1, AG1, AF1, AC1, AD1, or AE1 into a sell weight. Fees / HUD / STOP stay parked.

---

## Context (shipped)

| Pack | Result |
|------|--------|
| A–AR1 | Full loop + §5.3 bands + §8 events + daily drift |
| Soft | Catalog CLOSED; AC1 through AR1 Soft OK MVP notes stay Soft |

**Gap:** Auction snipes (systems §3) still dark. Fee cut stays parked. Camera off-switch Soft hard-parked. Fees / HUD / STOP parked by PM.

---

## Option AS1 — Auction snipes (systems §3) — **LEAN GO**

**Player fantasy:** A timer pops during prep. Bid Attention and cash for a noisy lot, or let it go.

| Deliverable | Spec |
|-------------|------|
| Gate | On prep, a seeded auction flag can offer **one** snipe. No flag → no auction that day |
| Offer | One lot. SKU visible. Ask visible. Condition stays the photo cue. Confidence **Medium**. Comp width is today's auction width (0.12) |
| Ask | Seeded. Can sit under or over the noisy basis so the same path can be a steal or a trap. Player never sees which |
| Bid | Spend **Attention 10** and cash equal to the ask. Lot enters BACKSTOCK. If Attention < 10 or cash < ask, the bid fails and nothing moves |
| Decline | Offer is gone for the day. No Rep change |
| Event tie | When a named settle event is live, the auction flag is forced on for the next prep. Quiet days still use the seeded flag alone |
| UI | No screen shows `true_market` |
| Config | Missing Attention cost falls back to 10. Missing width falls back to 0.12 |
| Untouched | Drift, fee 8%, door spawn, marketplace leads, trades, Regulars, MOQ, and shrink stay as shipped |
| Soft | Catalog untouched; leave AC1 through AR1 Soft OK alone |

**Acceptance:**

1. Same seed: a day with the auction flag shows one snipe. A day without the flag shows none.
2. A successful bid drops Attention by 10 and cash by the ask, and the lot lands in backstock. A bid with Attention 9 or cash short fails and nothing moves.
3. Decline leaves Rep, cash, Attention, and lots unchanged. The offer never shows `true_market`.
4. Door spawn and whale weight are unchanged. A completed sale still pays the listed price. Marketplace fee stays 8%. Not a sell weight. Soft catalog CLOSED. No Art.

**Out:** A fee cut; shady trunk; net-worth HUD; STOP; camera off-switch; sell-weight rewires.

**Why now:** Drift closed the last §8 line. Auction is the open §3 channel that is still a yes/no race, not a fee change.

---

## Option AS2 — Marketplace fee cut at Rep ≥ 75 — **PARK**

**Why park:** PM parked fee cuts. The 8% stays.

---

## Option AS3 — Shady trunk channel — **PARK**

**Why park:** Real §3 line. Auction is the cleaner timer race. Trunk can follow.

---

## Option AS4 — Net-worth HUD / STOP — **PARK**

**Why park:** PM parked both this pick.

---

## Camera off-switch — **HARD PARK Soft**

**Why park (hard):** Reopens Soft catalog.

---

## Recommendation (non-binding)

**GO AS1** (Auction snipes). Park AS2/AS3/AS4. **Hard-park** the camera off-switch. Soft catalog stays closed.

---

## PM checklist

- [x] Choose **AS1** (recommended)
- [x] If AS1: Eng vs systems §3 auction; leave fees and the door spawn alone; no Art
- [x] Sync this file to main before cloud agent
- [x] Soft catalog stays closed; fees / HUD / STOP stay parked

---

## Decision log

| When | Decision |
|------|----------|
| 2026-10-03 | Drafted post AR1 SHIPPED #74 @ `86438938`. Lean **AS1 Auction snipes**. Fee cut / shady trunk / HUD / STOP parked. Camera off-switch hard-parked. |
| 2026-10-03 | PM adopted **AS1**. Park AS2/AS3/AS4. Hard-park camera off-switch. Soft catalog CLOSED. Fees / HUD / STOP stay parked. One timed auction lot, Attention 10 plus the ask. Draft sha256 `b07c675c`. |
| 2026-10-03 | PM adopted **AS1**. Spec on main `ff4a3018`. Spike [AS1 auction snipes](https://cursor.com/agents/bc-6163683c-282f-5a9e-96f8-4ec7e6026041). Park AS2/AS3/AS4. No Art. Soft catalog CLOSED. Draft sha256 `b07c675c`. |
| 2026-10-03 | Tip-frozen PR #75 @ `79263eaa` (branch `cursor/as1-auction-snipes-6041`). Five files, no docs. Prep flag offers one auction snipe. Bid is Attention 10 plus the ask. |
