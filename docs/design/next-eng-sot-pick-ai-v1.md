# Next Eng SoT Pick AI v1 — post AH1

**Status:** **AI1 ADOPTED** 2026-10-03 — Low-rep quiet floor, band 0–24 only. Park AI2/AI4. Hard-park AI3 camera off-switch. Soft catalog CLOSED. Do not turn walkouts, Fire, or the Stocker into a sell weight. AC1/AD1/AE1 stay rank or notice.
**Author:** CSS Designer
**Date:** 2026-10-03
**Depends on:** pick-ah (AH1 Register walkouts SHIPPED #64 @ `982259fe`); Soft catalog CLOSED
**Rule:** Pick **one**. §4.5 never leaks. Soft catalog stays closed. Hard-park camera off-switch Soft. Do **not** turn AH1, AG1, AF1, AC1, AD1, or AE1 into a sell weight.

---

## Context (shipped)

| Pack | Result |
|------|--------|
| A–AH1 | Full loop + layout suite + Stocker + Fire + register walkouts |
| Soft | Catalog CLOSED; AC1/AD1/AE1/AF1/AG1/AH1 Soft OK MVP notes stay Soft |

**Gap:** Fire and walkouts spend Rep, but systems §5.3 bands never change the floor. Under 25 should be a quiet shop. Camera off-switch Soft hard-parked.

---

## Option AI1 — Low-rep quiet floor (systems §5.3, band 0–24) — **LEAN GO**

**Player fantasy:** Let Rep fall under 25 and the door goes quiet. Whales stop coming in.

| Deliverable | Spec |
|-------------|------|
| Gate | Read Rep at the spawn roll |
| Sparse | Rep **≤ 24** → customer spawn count **×0.5** versus the same seed at Rep **≥ 25** (round down, floor 0) |
| Whales | Rep **≤ 24** → whale spawn weight **0**. Rep **≥ 25** → existing whale weight, including Convention and play-table bumps |
| Restore | The next spawn after Rep is back to **≥ 25** uses the baseline count and whale gate |
| Untouched | Listed prices, walkout math, and Fire math stay as shipped. Distributor MOQ is **out** |
| Soft | Catalog untouched; leave AC1 through AH1 Soft OK alone |

**Acceptance:**

1. Same seed at Rep 24 spawns fewer customers than at Rep 25, at half, rounded down.
2. Same seed at Rep 24 spawns no whales. At Rep 40 the existing whale weight is allowed.
3. Raising Rep from 24 to 25 restores the baseline on the next spawn.
4. A completed sale still pays the listed price. AH1 walkouts and AG1 Fire stay as shipped. §4.5 clean. Soft catalog CLOSED. No Art.

**Out:** High band (75–100) whale bias and fee cuts; distributor MOQ; sell-weight rewires; camera off-switch; net-worth HUD.

**Why now:** Walkouts and firing a popular cashier spend Rep, and nothing on the floor notices until this band exists.

---

## Option AI2 — High-rep whale bias (band 75–100) — **PARK**

**Why park:** Real, but the band you can fall into after Fire and walkouts is 0–24. Ship the quiet floor first.

---

## Option AI3 — Camera off-switch Soft — **HARD PARK Soft**

**Why park (hard):** Reopens Soft catalog.

---

## Option AI4 — Net-worth HUD / STOP — **PARK**

**Why park:** Polish, not a decision bite.

---

## Recommendation (non-binding)

**GO AI1** (Low-rep quiet floor). Park AI2/AI4. **Hard-park AI3**. Do not turn walkouts or Fire into a sell weight.

---

## PM checklist

- [x] Choose **AI1** (recommended)
- [x] If AI1: Eng vs systems §5.3 band 0–24 only; leave AH1 walkout math alone; no Art
- [x] Sync this file to main before cloud agent
- [x] Soft catalog stays closed

---

## Decision log

| When | Decision |
|------|----------|
| 2026-10-03 | Drafted post AH1 SHIPPED #64 @ `982259fe`. Lean **AI1 Low-rep quiet floor**. High band / HUD / STOP parked. Soft reopeners hard-parked. Walkouts and Fire stay off the sell roll. |
| 2026-10-03 | PM adopted **AI1**. Park AI2/AI4. Hard-park AI3. Soft catalog CLOSED. Walkouts and Fire stay off the sell roll. Draft sha256 `775fc87f`. |
| 2026-10-03 | PM adopted **AI1**. Park AI2/AI4. Hard-park AI3. Soft catalog CLOSED. Synced main @ `61df7704`; Eng spike `bc-2dc718aa` launching. Eng/QA bar matches SoT. Holding for tip-freeze. |
| 2026-10-03 | Tip-frozen [PR #65](https://github.com/adamwlarson/cardshopsimulator/pull/65) @ `a0226acf`. Eng reviews that SHA only. QA holds. |
