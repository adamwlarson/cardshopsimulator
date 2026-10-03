# Next Eng SoT Pick AP v1 — post AO1

**Status:** **AP1 SHIPPED** 2026-10-03 — squash-merged #72 @ `dbf2f918` (reviewed `726bbd39`). Distributor MOQ ×2 at Rep ≤ 24. Park AP2/AP3/AP4. Hard-park camera off-switch. Soft catalog CLOSED. Fees, net-worth HUD, and STOP stay parked. Do not turn rep bands, trades, shrink, walkouts, or Fire into a sell weight. Door spawn math stays as shipped.
**Author:** CSS Designer
**Date:** 2026-10-03
**Depends on:** pick-ao (AO1 Regulars return SHIPPED #71 @ `b0224aae`); Soft catalog CLOSED
**Rule:** Pick **one**. §4.5 never leaks. Soft catalog stays closed. Hard-park camera off-switch Soft. Do **not** turn AO1, AN1, AM1, AL1, AK1, AJ1, AI1, AH1, AG1, AF1, AC1, AD1, or AE1 into a sell weight. Fees / HUD / STOP stay parked.

---

## Context (shipped)

| Pack | Result |
|------|--------|
| A–AO1 | Full loop + staff + rep bands + shrink + trades + Regulars |
| Soft | Catalog CLOSED; AC1 through AO1 Soft OK MVP notes stay Soft |

**Gap:** Band 0–24 still owes distributor MOQ worse (systems §5.3). AI1 shipped the quiet floor and left MOQ out. Camera off-switch Soft hard-parked. Fees / HUD / STOP parked by PM.

---

## Option AP1 — Distributor MOQ worse at Rep ≤ 24 (systems §5.3, §3) — **LEAN GO**

**Player fantasy:** A quiet shop cannot break the distributor's case. At Rep 25 the same menu is today's minimum.

| Deliverable | Spec |
|-------------|------|
| Gate | Read Rep when the distributor offer is built. Rep **≤ 24** → minimum units is today's MOQ × 2. Rep **≥ 25** → today's MOQ, unchanged |
| Same menu | Same seed, same SKUs, same unit price. Only the minimum count changes |
| Buy | A count under the minimum is refused and cash does not move. A count at the minimum succeeds and cash drops by unit price × count |
| Discount | The MSRP discount stays today's band. This bite is the floor, not a worse price |
| Bands | Door spawn count and whale weight stay as shipped. Not a traffic change |
| Visible | The offer shows the minimum count. No `true_market` |
| Config | Missing or ≤ 0 falls back to ×2 |
| Untouched | Regulars, player trades, listed prices, shrink, walkouts, Fire, and marketplace fees stay as shipped |
| Soft | Catalog untouched; leave AC1 through AO1 Soft OK alone |

**Acceptance:**

1. Same seed: Rep 24 minimum is exactly twice Rep 25's minimum. Rep 0 matches Rep 24. Rep 25 matches today's MOQ.
2. A buy under the Rep 24 floor is refused and cash is unchanged. A buy at that floor succeeds.
3. SKUs and unit price match across Rep 24 and Rep 25. The offer shows the minimum and never shows `true_market`.
4. Door spawn count and whale weight are unchanged. A completed sale still pays the listed price. Not a sell weight. Soft catalog CLOSED. No Art.

**Out:** A worse distributor discount; marketplace fee cuts; better leads; net-worth HUD; STOP; camera off-switch; sell-weight rewires.

**Why now:** The quiet band already halves the door. The bible's other line there is the distributor refusing a small order.

---

## Option AP2 — Better marketplace leads at Rep ≥ 75 — **PARK**

**Why park:** Real §5.3 line, but it rides next to the fee cut PM keeps parking. MOQ is the open quiet-band debt.

---

## Option AP3 — Daily `true_market` drift — **PARK**

**Why park:** §8 is real, and a visible drift can leak §4.5. Not this pick.

---

## Option AP4 — Net-worth HUD / STOP — **PARK**

**Why park:** PM parked both this pick.

---

## Camera off-switch — **HARD PARK Soft**

**Why park (hard):** Reopens Soft catalog.

---

## Recommendation (non-binding)

**GO AP1** (Distributor MOQ ×2 at Rep ≤ 24). Park AP2/AP3/AP4. **Hard-park** the camera off-switch. Soft catalog stays closed.

---

## PM checklist

- [x] Choose **AP1** (recommended)
- [x] If AP1: Eng vs systems §5.3 MOQ and today's distributor minimum; leave the discount and the door spawn alone; no Art
- [x] Sync this file to main before cloud agent
- [x] Soft catalog stays closed; fees / HUD / STOP stay parked

---

## Decision log

| When | Decision |
|------|----------|
| 2026-10-03 | Drafted post AO1 SHIPPED #71 @ `b0224aae`. Lean **AP1 Distributor MOQ ×2 at Rep ≤ 24**. Leads / drift / HUD / STOP parked. Camera off-switch hard-parked. |
| 2026-10-03 | PM adopted **AP1**. Park AP2/AP3/AP4. Hard-park camera off-switch. Soft catalog CLOSED. Fees / HUD / STOP stay parked. Same menu, only the minimum doubles at Rep ≤ 24. Draft sha256 `c30db000`. |
| 2026-10-03 | PM adopted **AP1**. Spec on main `03232240`. Spike [AP1 distributor MOQ](https://cursor.com/agents/bc-4e9ee13b-9034-58fa-89b2-9eea30678140). Eng bar locked. Park AP2/AP3/AP4. No Art. Soft catalog CLOSED. Draft sha256 `c30db000`. |
| 2026-10-03 | Tip-frozen PR #72 @ `726bbd39` (branch `cursor/ap1-distributor-moq-worse-8140`). Five files, no docs. Rep 24 doubles today's MOQ. Rep 25 keeps today's minimum. |
| 2026-10-03 | Eng APPROVE #72 @ `726bbd39`. No Soft notes. Formal released. Quiet floor at 24 stays as shipped. |
| 2026-10-03 | SHIPPED squash-merge #72 @ `dbf2f918` (reviewed `726bbd39`). QA PASS-with-notes, harness 88/0/3. No new Soft note. Seeded menu AA-SKIE-BLST, today 8 at 1800¢, Rep 24 and Rep 0 offer 16. Branch `cursor/ap1-distributor-moq-worse-8140` deleted. |
