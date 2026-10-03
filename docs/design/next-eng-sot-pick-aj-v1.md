# Next Eng SoT Pick AJ v1 — post AI1

**Status:** **AJ1 ADOPTED** 2026-10-03 — High-rep whale bias, band 75–100 only. Park AJ2/AJ4. Hard-park AJ3 camera off-switch. Soft catalog CLOSED. Do not turn the quiet floor, walkouts, or Fire into a sell weight. AC1/AD1/AE1 stay rank or notice. AI1 stays as shipped.
**Author:** CSS Designer
**Date:** 2026-10-03
**Depends on:** pick-ai (AI1 Low-rep quiet floor SHIPPED #65 @ `ea2bd0d4`); Soft catalog CLOSED
**Rule:** Pick **one**. §4.5 never leaks. Soft catalog stays closed. Hard-park camera off-switch Soft. Do **not** turn AI1, AH1, AG1, AF1, AC1, AD1, or AE1 into a sell weight.

---

## Context (shipped)

| Pack | Result |
|------|--------|
| A–AI1 | Full loop + layout suite + Stocker + Fire + walkouts + low-rep quiet floor |
| Soft | Catalog CLOSED; AC1 through AI1 Soft OK MVP notes stay Soft |

**Gap:** Band 0–24 now empties the door. Band 75–100 still does nothing (systems §5.3). Camera off-switch Soft hard-parked.

---

## Option AJ1 — High-rep whale bias (systems §5.3, band 75–100) — **LEAN GO**

**Player fantasy:** Keep Rep at 75 or above and whales show up more often.

| Deliverable | Spec |
|-------------|------|
| Gate | Read Rep at the spawn roll |
| Bias | Rep **≥ 75** → whale spawn weight **×1.5** versus the same seed at Rep **≤ 74** (after Convention and play-table bumps, if any) |
| Baseline | Rep **≤ 74** → today's whale weight, including Convention and play-table bumps |
| Quiet floor | AI1 stays as shipped. Rep **≤ 24** still halves spawn and zeros whale weight before bumps |
| Untouched | Listed prices, walkouts, Fire, marketplace fees, and distributor leads stay as shipped |
| Soft | Catalog untouched; leave AC1 through AI1 Soft OK alone |

**Acceptance:**

1. Same seed at Rep 75 yields a higher whale weight than at Rep 74, at ×1.5 after any event bumps.
2. Same seed at Rep 74 keeps today's whale weight.
3. Same seed at Rep 24 still has whale weight 0 before bumps, and half spawn (AI1 unchanged).
4. A completed sale still pays the listed price. Walkouts and Fire stay as shipped. §4.5 clean. Soft catalog CLOSED. No Art.

**Out:** Marketplace fee cuts; better leads; sell-weight rewires; camera off-switch; net-worth HUD; daily shrink.

**Why now:** The quiet floor just made low Rep bite. The high band is the matching carrot for keeping Rep up after Fire and walkouts.

---

## Option AJ2 — Marketplace fee cut at high Rep — **PARK**

**Why park:** Real §5.3 line, but whale bias is the clearer floor fantasy. Ship fees later if needed.

---

## Option AJ3 — Camera off-switch Soft — **HARD PARK Soft**

**Why park (hard):** Reopens Soft catalog.

---

## Option AJ4 — Net-worth HUD / STOP — **PARK**

**Why park:** Polish, not a decision bite.

---

## Recommendation (non-binding)

**GO AJ1** (High-rep whale bias). Park AJ2/AJ4. **Hard-park AJ3**. Do not turn the quiet floor, walkouts, or Fire into a sell weight.

---

## PM checklist

- [x] Choose **AJ1** (recommended)
- [x] If AJ1: Eng vs systems §5.3 band 75–100 whale bias only; leave AI1 quiet floor alone; no Art
- [x] Sync this file to main before cloud agent
- [x] Soft catalog stays closed

---

## Decision log

| When | Decision |
|------|----------|
| 2026-10-03 | Drafted post AI1 SHIPPED #65 @ `ea2bd0d4`. Lean **AJ1 High-rep whale bias**. Fees / HUD / STOP parked. Soft reopeners hard-parked. Quiet floor, walkouts, and Fire stay off the sell roll. |
| 2026-10-03 | PM adopted **AJ1**. Park AJ2/AJ4. Hard-park AJ3. Soft catalog CLOSED. Quiet floor, walkouts, and Fire stay off the sell roll. Draft sha256 `b612ba8a`. |
| 2026-10-03 | PM adopted **AJ1**. Park AJ2/AJ4. Hard-park AJ3. Soft catalog CLOSED. Synced main @ `425af091`; Eng spike `bc-422f84a5` launching. Eng/QA bar matches SoT (×1.5 vs 74 after bumps; no stack on high-band table; AI1 still zeros whales at ≤24). Holding for tip-freeze. |
| 2026-10-03 | Tip-frozen [PR #66](https://github.com/adamwlarson/cardshopsimulator/pull/66) @ `311010fe`. 4 files, no docs. Eng reviews that SHA only. QA holds. |
