# Next Eng SoT Pick AN v1 — post AM1

**Status:** **AN1 SHIPPED** 2026-10-03 — squash-merged #70 @ `ae1647ba`. Player trades unlock, Rep ≥ 50. Park AN2/AN4. Hard-park AN3 camera off-switch. Soft catalog CLOSED. Fees, net-worth HUD, and STOP stay parked. Do not turn rep bands, shrink, walkouts, or Fire into a sell weight. AM1 spawn math stays as shipped.
**Author:** CSS Designer
**Date:** 2026-10-03
**Depends on:** pick-am (AM1 Mid-band baseline SHIPPED #69 @ `e7a2b830`); Soft catalog CLOSED
**Rule:** Pick **one**. §4.5 never leaks. Soft catalog stays closed. Hard-park camera off-switch Soft. Do **not** turn AM1, AL1, AK1, AJ1, AI1, AH1, AG1, AF1, AC1, AD1, or AE1 into a sell weight. Fees / HUD / STOP stay parked.

---

## Context (shipped)

| Pack | Result |
|------|--------|
| A–AM1 | Full loop + staff suite + rep bands 0–24 / 25–49 / 75 whale + shrink suite |
| Soft | Catalog CLOSED; AC1 through AM1 Soft OK MVP notes stay Soft |

**Gap:** Band 50–74 still has no verb (systems §5.3 / §3). Player trades unlock at Rep 50 and never offer. Camera off-switch Soft hard-parked. Fees / HUD / STOP parked by PM.

---

## Option AN1 — Player trades unlock (systems §3, band 50–74) — **LEAN GO**

**Player fantasy:** Hit Rep 50 and another shop offers a straight swap. Under 50, that door stays shut.

| Deliverable | Spec |
|-------------|------|
| Unlock | Read Rep when prep offers roll. Rep **≥ 50** → a player-trade offer can appear. Rep **≤ 49** → that channel does not offer |
| Offer | In-kind. Give one owned lot, receive one lot. SKU and condition of both are visible. **No** `true_market` |
| Accept | Given lot leaves. Received lot enters BACKSTOCK. Cash does not change |
| Decline | Offer is gone. No Rep change |
| Bands | Spawn count and whale weight at Rep 50 stay the AM1 baseline. No new traffic bonus |
| Untouched | Listed prices, shrink, walkouts, Fire, and marketplace fees stay as shipped |
| Soft | Catalog untouched; leave AC1 through AM1 Soft OK alone |

**Acceptance:**

1. Same seed at Rep 50 shows a player-trade offer. At Rep 49 it does not.
2. Accept swaps the lots and leaves cash unchanged.
3. The offer never shows `true_market` or any §4.5 leak.
4. Spawn count and whale weight at Rep 50 match Rep 49. A completed sale still pays the listed price. Not a sell weight. Soft catalog CLOSED. No Art.

**Out:** Regulars return loop; marketplace fee cuts; net-worth HUD; STOP; camera off-switch; sell-weight rewires; a spawn bonus at 50.

**Why now:** AM1 named 25–49 as baseline and left 50 with no bonus. The bible's 50 unlock is the trade, not more foot traffic.

---

## Option AN2 — Regulars return loop — **PARK**

**Why park:** Real §5.3 line, but the trade is the named unlock with a yes/no. Regulars can follow.

---

## Option AN3 — Camera off-switch Soft — **HARD PARK Soft**

**Why park (hard):** Reopens Soft catalog.

---

## Option AN4 — Fees / net-worth HUD / STOP — **PARK**

**Why park:** PM parked all three this pick.

---

## Recommendation (non-binding)

**GO AN1** (Player trades unlock). Park AN2/AN4. **Hard-park AN3**. Soft catalog stays closed.

---

## PM checklist

- [x] Choose **AN1** (recommended)
- [x] If AN1: Eng vs systems §3 player trades; leave AM1 spawn math alone; no Art
- [x] Sync this file to main before cloud agent
- [x] Soft catalog stays closed; fees / HUD / STOP stay parked

---

## Decision log

| When | Decision |
|------|----------|
| 2026-10-03 | Drafted post AM1 SHIPPED #69 @ `e7a2b830`. Lean **AN1 Player trades unlock**. Regulars / fees / HUD / STOP parked. Soft reopeners hard-parked. |
| 2026-10-03 | PM adopted **AN1**. Park AN2/AN4. Hard-park AN3. Soft catalog CLOSED. Fees / HUD / STOP stay parked. No spawn bonus at 50. Draft sha256 `dbb9dfd3`. |
