# Next Eng SoT Pick AQ v1 — post AP1

**Status:** **AQ1 SHIPPED** 2026-10-03 — squash-merged #73 @ `059ebf76` (reviewed `4622610b`). Better marketplace lead at Rep ≥ 75. Park AQ2/AQ3/AQ4. Hard-park camera off-switch. Soft catalog CLOSED. Fees, net-worth HUD, and STOP stay parked. Do not turn rep bands, trades, shrink, walkouts, or Fire into a sell weight. Door spawn math stays as shipped.
**Author:** CSS Designer
**Date:** 2026-10-03
**Depends on:** pick-ap (AP1 Distributor MOQ SHIPPED #72 @ `dbf2f918`); Soft catalog CLOSED
**Rule:** Pick **one**. §4.5 never leaks. Soft catalog stays closed. Hard-park camera off-switch Soft. Do **not** turn AP1, AO1, AN1, AM1, AL1, AK1, AJ1, AI1, AH1, AG1, AF1, AC1, AD1, or AE1 into a sell weight. Fees / HUD / STOP stay parked.

---

## Context (shipped)

| Pack | Result |
|------|--------|
| A–AP1 | Full loop + staff + all four rep bands' named verbs except the 75 lead and the fee cut |
| Soft | Catalog CLOSED; AC1 through AP1 Soft OK MVP notes stay Soft |

**Gap:** Band 75–100 still owes better marketplace leads (systems §5.3, channel in §3). Whale bias already shipped. The fee cut stays parked. Camera off-switch Soft hard-parked. Fees / HUD / STOP parked by PM.

---

## Option AQ1 — Better marketplace lead (systems §5.3, §3) — **LEAN GO**

**Player fantasy:** At Rep 75 the marketplace offers one cleaner lot. At Rep 74 you only get today's leads.

| Deliverable | Spec |
|-------------|------|
| Gate | When prep marketplace leads roll. Rep **≥ 75** adds one extra lead. Rep **≤ 74** does not. Rep 74's list is today's list |
| Better | That extra lead's ask is the low end of today's marketplace band: 40% of the same basis today's leads already use. Not a new basis |
| Fog | Condition stays hidden, same as today's marketplace leads. The player sees the ask and the noisy photo, not the basis |
| Fee | Marketplace sell fee stays today's 8%. This is not a fee cut |
| Skip | Declining the extra lead does not change Rep |
| Bands | Door spawn count and whale weight stay as shipped, including the ×1.5 whale bias at 75 |
| Config | Missing or ≤ 0 falls back to one extra lead at 40% |
| Untouched | Distributor MOQ, Regulars, player trades, listed prices, shrink, walkouts, and Fire stay as shipped |
| Soft | Catalog untouched; leave AC1 through AP1 Soft OK alone |

**Acceptance:**

1. Same seed: Rep 74's lead count is today's count. Rep 75 is that count + 1. Rep 100 matches Rep 75.
2. The extra lead is absent at Rep 74. Its ask is 40% of the same basis, and the other leads match Rep 74.
3. Condition stays hidden. The offer never shows `true_market`. Declining it does not change Rep.
4. Door spawn and whale weight are unchanged. A completed sale still pays the listed price. Marketplace fee stays 8%. Not a sell weight. Soft catalog CLOSED. No Art.

**Out:** A fee cut; daily `true_market` drift; net-worth HUD; STOP; camera off-switch; a door-spawn bonus at 75; sell-weight rewires.

**Why now:** Every other §5.3 cell has a verb. The fee cut is parked, so the remaining 75 line is the cleaner lead.

---

## Option AQ2 — Marketplace fee cut at Rep ≥ 75 — **PARK**

**Why park:** PM parked fee cuts. The lead does not touch the 8%.

---

## Option AQ3 — Daily `true_market` drift — **PARK**

**Why park:** §8 is real, and a visible drift can leak §4.5. Not this pick.

---

## Option AQ4 — Net-worth HUD / STOP — **PARK**

**Why park:** PM parked both this pick.

---

## Camera off-switch — **HARD PARK Soft**

**Why park (hard):** Reopens Soft catalog.

---

## Recommendation (non-binding)

**GO AQ1** (one extra marketplace lead at 40% of today's basis, Rep ≥ 75). Park AQ2/AQ3/AQ4. **Hard-park** the camera off-switch. Soft catalog stays closed.

---

## PM checklist

- [x] Choose **AQ1** (recommended)
- [x] If AQ1: Eng vs systems §5.3 leads and today's marketplace list; leave the 8% fee and the door spawn alone; no Art
- [x] Sync this file to main before cloud agent
- [x] Soft catalog stays closed; fees / HUD / STOP stay parked

---

## Decision log

| When | Decision |
|------|----------|
| 2026-10-03 | Drafted post AP1 SHIPPED #72 @ `dbf2f918`. Lean **AQ1 Better marketplace lead**. Fee cut / drift / HUD / STOP parked. Camera off-switch hard-parked. |
| 2026-10-03 | PM adopted **AQ1**. Park AQ2/AQ3/AQ4. Hard-park camera off-switch. Soft catalog CLOSED. Fees / HUD / STOP stay parked. One extra marketplace lead at 40% of today's basis when Rep ≥ 75. Draft sha256 `39049612`. |
| 2026-10-03 | PM adopted **AQ1**. Spec on main `c1459dd7`. Spike [AQ1 better marketplace lead](https://cursor.com/agents/bc-cd6c0319-f83c-574a-9ff1-c49746e032cd). Park AQ2/AQ3/AQ4. No Art. Soft catalog CLOSED. Draft sha256 `39049612`. |
| 2026-10-03 | Tip-frozen PR #73 @ `4622610b` (branch `cursor/aq1-marketplace-lead-32cd`). Three files, no docs. Rep 75 adds one extra lead at 40% of today's basis. Rep 74 keeps today's list. |
| 2026-10-03 | Eng APPROVE #73 @ `4622610b`. No Soft notes. Formal released. Fee stays 8%. Door spawn stays as shipped. |
| 2026-10-03 | SHIPPED squash-merge #73 @ `059ebf76` (reviewed `4622610b`). QA PASS, harness 60/0/0. No new Soft note. Rep 74 one lead Dustway ETB ×2 at 2400¢. Rep 75 extra ask 1800¢. Branch `cursor/aq1-marketplace-lead-32cd` deleted. |
