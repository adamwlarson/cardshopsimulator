# Next Eng SoT Pick AO v1 — post AN1

**Status:** **AO1 SHIPPED** 2026-10-03 — squash-merged #71 @ `b0224aae` (reviewed `2b1f45d6`). Regulars return, Rep ≥ 50. Park AO2/AO3/AO4. Hard-park camera off-switch. Soft catalog CLOSED. Fees, net-worth HUD, and STOP stay parked. Do not turn rep bands, trades, shrink, walkouts, or Fire into a sell weight. Door spawn math stays as shipped.
**Author:** CSS Designer
**Date:** 2026-10-03
**Depends on:** pick-an (AN1 Player trades unlock SHIPPED #70 @ `ae1647ba`); Soft catalog CLOSED
**Rule:** Pick **one**. §4.5 never leaks. Soft catalog stays closed. Hard-park camera off-switch Soft. Do **not** turn AN1, AM1, AL1, AK1, AJ1, AI1, AH1, AG1, AF1, AC1, AD1, or AE1 into a sell weight. Fees / HUD / STOP stay parked.

---

## Context (shipped)

| Pack | Result |
|------|--------|
| A–AN1 | Full loop + staff suite + rep bands + shrink + player trades at Rep ≥ 50 |
| Soft | Catalog CLOSED; AC1 through AN1 Soft OK MVP notes stay Soft |

**Gap:** Band 50–74 named Regulars in systems §5.3 and the Regular archetype in §5.1. Trades shipped. The return visit never happens. Camera off-switch Soft hard-parked. Fees / HUD / STOP parked by PM.

---

## Option AO1 — Regulars return loop (systems §5.1 Regular, §5.3 band 50–74) — **LEAN GO**

**Player fantasy:** Treat a buyer fairly at Rep 50 and they come back the next day. Under 50, they don't.

| Deliverable | Spec |
|-------------|------|
| Unlock | Read Rep when a sale completes. Rep **≥ 50** and the sale paid the listed price → queue one Regular for the next floor open. Rep **≤ 49** → no queue |
| Treated well | Listed-price sale only. A walkout, a refuse, or no sale queues nothing |
| Cap | One queued return. A second listed sale the same day does not queue another |
| Arrival | Next floor open, one customer tagged Regular. They use the existing sale path. No new price, no new want table |
| One-shot | That return does not queue another visit by itself. The next listed sale can queue again |
| Bands | Door spawn count and whale weight stay the AM1/AN1 baseline. This is not a door-roll bonus |
| Config | Missing or ≤ 0 falls back to Rep 50 and cap 1 |
| Untouched | Player trades, listed prices, shrink, walkouts, Fire, and marketplace fees stay as shipped |
| Soft | Catalog untouched; leave AC1 through AN1 Soft OK alone |

**Acceptance:**

1. Same seed: a listed sale at Rep 50 queues one Regular on the next floor open. The same sale at Rep 49 queues nothing.
2. A walkout or a refuse the same day queues nothing. A second listed sale does not queue a second Regular.
3. The return is tagged Regular, buys on the existing sale path, and never shows `true_market`.
4. Door spawn count and whale weight at Rep 50 still match Rep 49. A completed sale still pays the listed price. Not a sell weight. Soft catalog CLOSED. No Art.

**Out:** Distributor MOQ; marketplace fee cuts; better leads; net-worth HUD; STOP; camera off-switch; a door-spawn bonus at 50; sell-weight rewires.

**Why now:** AN1 shipped the trade half of the 50–74 band. The other half is the Regular who comes back, and it is a yes/no on the next floor open.

---

## Option AO2 — Distributor MOQ worse at Rep ≤ 24 — **PARK**

**Why park:** Real §5.3 line, and AI1 left it out on purpose. Regulars are the open half of the band we just touched.

---

## Option AO3 — Fees and better leads at Rep ≥ 75 — **PARK**

**Why park:** PM parked fee cuts. Leads ride with that late-band line.

---

## Option AO4 — Net-worth HUD / STOP — **PARK**

**Why park:** PM parked both this pick.

---

## Camera off-switch — **HARD PARK Soft**

**Why park (hard):** Reopens Soft catalog.

---

## Recommendation (non-binding)

**GO AO1** (Regulars return). Park AO2/AO3/AO4. **Hard-park** the camera off-switch. Soft catalog stays closed.

---

## PM checklist

- [x] Choose **AO1** (recommended)
- [x] If AO1: Eng vs systems §5.1 Regular and §5.3 band 50–74; leave door spawn math alone; no Art
- [x] Sync this file to main before cloud agent
- [x] Soft catalog stays closed; fees / HUD / STOP stay parked

---

## Decision log

| When | Decision |
|------|----------|
| 2026-10-03 | Drafted post AN1 SHIPPED #70 @ `ae1647ba`. Lean **AO1 Regulars return**. MOQ / fees / leads / HUD / STOP parked. Camera off-switch hard-parked. |
| 2026-10-03 | PM adopted **AO1**. Park AO2/AO3/AO4. Hard-park camera off-switch. Soft catalog CLOSED. Fees / HUD / STOP stay parked. No door-spawn bonus. Draft sha256 `5e512c79`. |
| 2026-10-03 | SHIPPED squash-merge #71 @ `b0224aae` (reviewed `2b1f45d6`). QA PASS-with-notes, harness 79/0/4. Soft: a later listed buy by that Regular may queue one more. Branch `cursor/ao1-regulars-return-bb00` deleted. |
