# Next Eng SoT Pick AT v1 — post AS1

**Status:** **AT1 ADOPTED** 2026-10-03 — Shady trunk. Park AT2/AT3/AT4. Hard-park camera off-switch. Soft catalog CLOSED. Fees, net-worth HUD, and STOP stay parked. Do not turn rep bands, trades, shrink, walkouts, or Fire into a sell weight. Door spawn math stays as shipped.
**Author:** CSS Designer
**Date:** 2026-10-03
**Depends on:** pick-as (AS1 Auction snipes SHIPPED #75 @ `967ecd37`); Soft catalog CLOSED
**Rule:** Pick **one**. §4.5 never leaks. Soft catalog stays closed. Hard-park camera off-switch Soft. Do **not** turn AS1, AR1, AQ1, AP1, AO1, AN1, AM1, AL1, AK1, AJ1, AI1, AH1, AG1, AF1, AC1, AD1, or AE1 into a sell weight. Fees / HUD / STOP stay parked.

---

## Context (shipped)

| Pack | Result |
|------|--------|
| A–AS1 | Full loop + §5.3 bands + §8 events + drift + auction snipes |
| Soft | Catalog CLOSED; AC1 through AS1 Soft OK MVP notes stay Soft |

**Gap:** Shady trunk (systems §3, §10 #10) still dark. Fee cut stays parked. Camera off-switch Soft hard-parked. Fees / HUD / STOP parked by PM.

---

## Option AT1 — Shady trunk (systems §3, §2.2, §10 #10) — **LEAN GO**

**Player fantasy:** A night flag offers a too-cheap lot. Buy it, report it, or walk. You do not learn if the slab is fake until a later sale.

| Deliverable | Spec |
|-------------|------|
| Gate | A seeded night flag can show **one** trunk offer. No flag → no trunk that night |
| Offer | One lot. SKU visible. Ask is **25%** of the same basis today's leads use. Condition stays the photo cue. Confidence **Low**. Comp width is today's shady width (0.22) |
| Buy | Cash drops by the ask. Lot enters BACKSTOCK. No Attention cost. Cash short → nothing moves |
| Report | Offer is gone. Rep **+2** once. No cash, no lot |
| Walk | Offer is gone. Rep, cash, and lots unchanged |
| Fake | A graded lot on this channel is `cert_valid` false **8%** of the time (systems §2.2). The offer never shows `cert_valid` or `true_market`. The fail-on-sale path stays as shipped |
| Config | Missing ask falls back to 25%. Missing report Rep falls back to +2. Missing fake rate falls back to 8% |
| Untouched | Auction, drift, fee 8%, door spawn, marketplace leads, trades, Regulars, MOQ, and shrink stay as shipped |
| Soft | Catalog untouched; leave AC1 through AS1 Soft OK alone |

**Acceptance:**

1. Same seed: a night with the flag shows one trunk offer. A night without the flag shows none.
2. Buy drops cash by the ask and lands the lot in backstock. A short-cash buy moves nothing. Report adds Rep 2 and moves no cash or lots. Walk changes nothing.
3. The ask is 25% of the same basis. A graded roll can be fake at 8%, and the offer does not say so. No screen shows `true_market` or `cert_valid`.
4. Door spawn and whale weight are unchanged. A completed sale still pays the listed price. Marketplace fee stays 8%. Not a sell weight. Soft catalog CLOSED. No Art.

**Out:** A fee cut; net-worth HUD; STOP; camera off-switch; revealing `cert_valid` on the offer; sell-weight rewires.

**Why now:** Auction closed the timer race. The trunk is the remaining §3 channel with a three-way fork and a hidden fake.

---

## Option AT2 — Marketplace fee cut at Rep ≥ 75 — **PARK**

**Why park:** PM parked fee cuts. The 8% stays.

---

## Option AT3 — Haggle counter-offer — **PARK**

**Why park:** Systems §3 haggle is real, but the trunk fork is the open channel. Haggle can follow.

---

## Option AT4 — Net-worth HUD / STOP — **PARK**

**Why park:** PM parked both this pick.

---

## Camera off-switch — **HARD PARK Soft**

**Why park (hard):** Reopens Soft catalog.

---

## Recommendation (non-binding)

**GO AT1** (Shady trunk). Park AT2/AT3/AT4. **Hard-park** the camera off-switch. Soft catalog stays closed.

---

## PM checklist

- [x] Choose **AT1** (recommended)
- [x] If AT1: Eng vs systems §3 trunk and §2.2 fake-slab; leave fees and the door spawn alone; no Art
- [x] Sync this file to main before cloud agent
- [x] Soft catalog stays closed; fees / HUD / STOP stay parked

---

## Decision log

| When | Decision |
|------|----------|
| 2026-10-03 | Drafted post AS1 SHIPPED #75 @ `967ecd37`. Lean **AT1 Shady trunk**. Fee cut / haggle / HUD / STOP parked. Camera off-switch hard-parked. |
| 2026-10-03 | PM adopted **AT1**. Park AT2/AT3/AT4. Hard-park camera off-switch. Soft catalog CLOSED. Fees / HUD / STOP stay parked. One night trunk lot at 25% of today's basis. Draft sha256 `7d96b64d`. |
| 2026-10-03 | PM adopted **AT1**. Spec on main `cc103dd3`. Spike [AT1 shady trunk](https://cursor.com/agents/bc-a8c6fdaa-6d2f-5d7c-bd24-aa8b228f5324). Park AT2/AT3/AT4. No Art. Soft catalog CLOSED. Draft sha256 `7d96b64d`. |
