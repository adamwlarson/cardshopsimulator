# Next Eng SoT Pick AR v1 — post AQ1

**Status:** **AR1 ADOPTED** 2026-10-03 — Daily true_market drift. Park AR2/AR3/AR4. Hard-park camera off-switch. Soft catalog CLOSED. Fees, net-worth HUD, and STOP stay parked. Do not turn rep bands, trades, shrink, walkouts, or Fire into a sell weight. Door spawn math stays as shipped.
**Author:** CSS Designer
**Date:** 2026-10-03
**Depends on:** pick-aq (AQ1 Better marketplace lead SHIPPED #73 @ `059ebf76`); Soft catalog CLOSED
**Rule:** Pick **one**. §4.5 never leaks. Soft catalog stays closed. Hard-park camera off-switch Soft. Do **not** turn AQ1, AP1, AO1, AN1, AM1, AL1, AK1, AJ1, AI1, AH1, AG1, AF1, AC1, AD1, or AE1 into a sell weight. Fees / HUD / STOP stay parked.

---

## Context (shipped)

| Pack | Result |
|------|--------|
| A–AQ1 | Full loop + staff + all four §5.3 bands + §8 events + marketplace lead |
| Soft | Catalog CLOSED; AC1 through AQ1 Soft OK MVP notes stay Soft |

**Gap:** Daily `true_market` drift (systems §8) still dark. The fee cut at 75 stays parked. Camera off-switch Soft hard-parked. Fees / HUD / STOP parked by PM.

---

## Option AR1 — Daily true_market drift (systems §8) — **LEAN GO**

**Player fantasy:** Overnight the comps nudge. You never see the true number, only the noisy ask you already use.

| Deliverable | Spec |
|-------------|------|
| When | Once per settle night, after wages/rent/shrink, before the next prep roll |
| Drift | Each live SKU: `true_market *= U(lo, hi)` for its class. Seeded. No player choice |
| Class | Accessories `U(0.99, 1.01)`. Sealed `U(0.98, 1.02)`. Singles `U(0.97, 1.03)`. Graded `U(0.96, 1.04)` |
| Floor | After multiply, clamp cents to at least 1 |
| Listed | Player-set listed prices do not change. Cash does not change |
| UI | No screen shows `true_market`. Suggested comps and marketplace basis use the drifted value through today's noisy path only |
| Events | Named §8 events still apply their own modifiers after this drift, same as today |
| Config | Missing class range falls back to sealed `U(0.98, 1.02)` |
| Untouched | Fee stays 8%. Door spawn, whale bias, trades, Regulars, MOQ, and shrink stay as shipped |
| Soft | Catalog untouched; leave AC1 through AQ1 Soft OK alone |

**Acceptance:**

1. Same seed: after one settle night with no event, a sealed SKU's hidden `true_market` is inside ×0.98–1.02 of the pre-settle value. Graded is inside ×0.96–1.04. Listed price and cash are unchanged.
2. A second settle night with the same seed path drifts again. Two nights are not identical to one night.
3. No UI, offer, or notice string contains `true_market` or the exact hidden cents.
4. Door spawn and whale weight are unchanged. A completed sale still pays the listed price. Marketplace fee stays 8%. Not a sell weight. Soft catalog CLOSED. No Art.

**Out:** A fee cut; net-worth HUD; STOP; camera off-switch; surfacing `true_market`; sell-weight rewires.

**Why now:** Every §5.3 cell has a verb. The remaining §8 line is the quiet overnight nudge, and it can stay behind the §4.5 wall.

---

## Option AR2 — Marketplace fee cut at Rep ≥ 75 — **PARK**

**Why park:** PM parked fee cuts. The 8% stays.

---

## Option AR3 — Auction snipes channel — **PARK**

**Why park:** Real §3 channel, but drift is the named open §8 line. Auction can follow.

---

## Option AR4 — Net-worth HUD / STOP — **PARK**

**Why park:** PM parked both this pick.

---

## Camera off-switch — **HARD PARK Soft**

**Why park (hard):** Reopens Soft catalog.

---

## Recommendation (non-binding)

**GO AR1** (daily true_market drift, class bands, never shown). Park AR2/AR3/AR4. **Hard-park** the camera off-switch. Soft catalog stays closed.

---

## PM checklist

- [x] Choose **AR1** (recommended)
- [x] If AR1: Eng vs systems §8 daily drift and §4.5; leave fees and the door spawn alone; no Art
- [x] Sync this file to main before cloud agent
- [x] Soft catalog stays closed; fees / HUD / STOP stay parked

---

## Decision log

| When | Decision |
|------|----------|
| 2026-10-03 | Drafted post AQ1 SHIPPED #73 @ `059ebf76`. Lean **AR1 Daily true_market drift**. Fee cut / auction / HUD / STOP parked. Camera off-switch hard-parked. |
| 2026-10-03 | PM adopted **AR1**. Park AR2/AR3/AR4. Hard-park camera off-switch. Soft catalog CLOSED. Fees / HUD / STOP stay parked. Overnight class-band drift, never shown. Draft sha256 `85281e87`. |
| 2026-10-03 | PM adopted **AR1**. Spec on main `4add953f`. Spike [AR1 daily true_market drift](https://cursor.com/agents/bc-5195d136-d5af-5618-82ce-393a8b9c61f8). Park AR2/AR3/AR4. No Art. Soft catalog CLOSED. Draft sha256 `85281e87`. |
| 2026-10-03 | Tip-frozen PR #74 @ `8f104626` (branch `cursor/ar1-daily-market-drift-61f8`). Five files, no docs. Settle night drifts hidden market by class band after shrink and before named events. |
