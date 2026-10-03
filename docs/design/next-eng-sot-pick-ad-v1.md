# Next Eng SoT Pick AD v1 — post AC1

**Status:** **AD1 SHIPPED** #60 @ `b32e162d` (tip `85011dc2`) — Case / binder / backstock display ladder, rank-not-weight. Park AD2/AD4. Hard-park AD3 camera off-switch. Soft catalog CLOSED. AC1 notice-only stays. Soft OK MVP: SHELF 1.0 / ONLINE_HOLD 0.0, backstock lot still offered, sale removes first visible copy, find_listed_sku_offer does not rank case.  
**Author:** CSS Designer  
**Date:** 2026-10-03  
**Depends on:** pick-ac (AC1 Sightline SHIPPED #59 @ `5c9bab43`, notice-only); Soft catalog CLOSED  
**Rule:** Pick **one**. §4.5 never leaks. Soft catalog stays closed (do not reopen Softs, camera off-switch, or #58/#59 Soft OK notes).

---

## Context (shipped)

| Pack | Result |
|------|--------|
| A–AC1 | Full loop + play table + entrance sightline (notice-only) |
| Soft | Catalog CLOSED; AC1 ×1.15 not on live sell roll stays Soft OK MVP |

**Gap:** Location ladder `display_bonus` (case > binder > backstock) still dark (systems §4). Stocker deepen parked. Camera off-switch Soft hard-parked.

---

## Option AD1 — Case / binder / backstock display ladder — **LEAN GO**

**Player fantasy:** A single in the case sells harder than the same card in a binder; backstock is invisible to walk-ins.

| Deliverable | Spec |
|-------------|------|
| Ladder | Location class bonus on walk-in interest (systems §4 `display_bonus`: **case > binder > backstock**) |
| Suggested | Case ×1.20, binder ×1.00, backstock ×0.00 for walk-in browse (online/pull still allowed) |
| Scope | Singles (and graded already in case). Do **not** change AC1 entrance notice |
| Distinct | AC1 sightline stays notice-only. This ladder is location class, not distance-to-door |
| Soft | Catalog untouched |

**Acceptance:**

1. Same single in CASE gets higher walk-in interest than BINDER; BACKSTOCK gets none from walk-ins.
2. Moving the card between locations updates the ladder next tick / rearrange.
3. AC1 entrance notice behavior unchanged (no live sell-weight required there).
4. §4.5 clean; Soft catalog CLOSED; no Art.

**Out:** Rebalancing AC1 to a live sell weight; impulse-shelf-only spike; stocker loop; Soft camera off-switch; net-worth HUD.

**Why now:** Sightline taught door placement. The named §4 ladder is the other layout decision: which furniture holds the card.

---

## Option AD2 — Stocker restock loop — **PARK**

Stocker auto-moves backstock → floor (systems §6.1).

**Why park:** PM asked to park stocker unless a stronger layout/decision bite exists. AD1 is stronger.

---

## Option AD3 — Camera off-switch Soft — **HARD PARK Soft**

**Why park (hard):** Reopens Soft catalog.

---

## Option AD4 — Net-worth HUD / STOP — **PARK**

**Why park:** Not a stronger bite than the location ladder.

---

## Recommendation (non-binding)

**GO AD1** (case / binder / backstock ladder). Park AD2/AD4. **Hard-park AD3**.

---

## PM checklist

- [x] Choose **AD1** (recommended)
- [x] If AD1: Eng vs systems §4 display_bonus ladder; leave AC1 notice-only; no Art
- [x] Sync this file to main before cloud agent
- [x] Soft catalog stays closed

---

## Decision log

| When | Decision |
|------|----------|
| 2026-10-03 | Drafted post AC1 SHIPPED. Lean **AD1 location display ladder**. Stocker / HUD / STOP parked. Soft reopeners hard-parked. |
| 2026-10-03 | PM adopted **AD1**. Park AD2/AD4. Hard-park AD3. Soft catalog CLOSED. AC1 notice-only stays. |
| 2026-10-03 | PM locked **AD1 GO** (location display ladder). Park AD2/AD4. Hard-park AD3 Soft. AC1 notice-only stays. Soft catalog CLOSED. No Art. Synced main @ `8a5df031`; Eng spike `bc-3a012466` launching. |
| 2026-10-03 | **AD1 SHIPPED** #60 @ `b32e162d` (tip `85011dc2`). QA PASS-with-notes. Rank-not-weight SoT-ok. Soft OK MVP notes stay Soft. Soft catalog CLOSED. |
