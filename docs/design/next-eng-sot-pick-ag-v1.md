# Next Eng SoT Pick AG v1 — post AF1

**Status:** **AG1 ADOPTED** 2026-10-03 — Fire staff. Park AG2/AG4. Hard-park AG3 camera off-switch. Soft catalog CLOSED. Stocker stays placement-only. AC1/AD1/AE1 stay rank or notice.
**Author:** CSS Designer
**Date:** 2026-10-03
**Depends on:** pick-af (AF1 Stocker restock SHIPPED #62 @ `3db75f4a`); Soft catalog CLOSED
**Rule:** Pick **one**. §4.5 never leaks. Soft catalog stays closed. Hard-park camera off-switch Soft. Do **not** turn AF1 into a sell weight, or AC1/AD1/AE1 into sell-probability or live sell weights.

---

## Context (shipped)

| Pack | Result |
|------|--------|
| A–AF1 | Full loop + layout suite + Stocker restock (placement only, 4 lots/day) |
| Soft | Catalog CLOSED; AC1/AD1/AE1/AF1 Soft OK MVP notes stay Soft |

**Gap:** Fire is still bible-only (systems §6.3). Wages start when you hire; they never stop except by going broke. Camera off-switch Soft hard-parked.

---

## Option AG1 — Fire staff (systems §6.3) — **LEAN GO**

**Player fantasy:** Cut a wage before rent, and eat the reputation hit if the floor already knows them.

| Deliverable | Spec |
|-------------|------|
| Verb | Owner can **Fire** any hired Cashier, Specialist, or Stocker |
| Wage | Immediate stop: that role leaves the roster on the action, and the next settle does not charge their wage |
| Popular | Roster age **≥ 3** floor days → Rep **−5** once |
| Not popular | Roster age **< 3** floor days → Rep unchanged |
| Stocker | Fired Stocker is simply off the roster. Auto-restock stops (existing AF1 fail path). **Not** a sell-price or sell-weight change |
| Soft | Catalog untouched; leave AC1/AD1/AE1/AF1 Soft OK alone |

**Acceptance:**

1. Fire removes the named role the same day; the next settle charges no wage for them.
2. Firing a staff member with roster age ≥ 3 floor days drops Rep by 5 once, and does not tick again.
3. Firing a staff member hired fewer than 3 floor days does not drop Rep.
4. A fired Stocker moves 0 lots. Listed prices and AC1/AD1/AE1 sell math stay as shipped.
5. §4.5 clean; Soft catalog CLOSED; no Art.

**Out:** Stocker as a sell weight; reliability rewrite; camera off-switch; net-worth HUD; hire-modal redo.

**Why now:** Stocker just made the third wage real. Fire is the missing half of hire — cash now versus a one-time Rep hit.

---

## Option AG2 — Net-worth HUD — **PARK**

**Why park:** Polish, not a decision bite.

---

## Option AG3 — Camera off-switch Soft — **HARD PARK Soft**

**Why park (hard):** Reopens Soft catalog.

---

## Option AG4 — STOP idle — **PARK**

**Why park:** Adam wants progress; AF1 just shipped.

---

## Recommendation (non-binding)

**GO AG1** (Fire staff). Park AG2/AG4. **Hard-park AG3**. Do not turn the Stocker into a sell weight.

---

## PM checklist

- [x] Choose **AG1** (recommended)
- [x] If AG1: Eng vs systems §6.3 Fire; leave AF1 placement-only; no Art
- [x] Sync this file to main before cloud agent
- [x] Soft catalog stays closed

---

## Decision log

| When | Decision |
|------|----------|
| 2026-10-03 | Drafted post AF1 SHIPPED #62 @ `3db75f4a`. Lean **AG1 Fire staff**. HUD / STOP parked. Soft reopeners hard-parked. Stocker stays placement-only. |
| 2026-10-03 | PM adopted **AG1**. Park AG2/AG4. Hard-park AG3. Soft catalog CLOSED. AF1 stays placement-only. |
