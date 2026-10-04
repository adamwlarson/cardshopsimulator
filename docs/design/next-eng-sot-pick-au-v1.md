# Next Eng SoT Pick AU v1 — post AT1

**Status:** **AU1 SHIPPED** 2026-10-03 — squash-merged #77 @ `44a1b299` (reviewed `30c77934`). One-counter haggle. Park AU2/AU3/AU4. Hard-park camera off-switch. Soft catalog CLOSED. Fees, net-worth HUD, and STOP stay parked. Do not turn rep bands, trades, shrink, walkouts, or Fire into a sell weight. Door spawn math stays as shipped.
**Author:** CSS Designer
**Date:** 2026-10-03
**Depends on:** pick-at (AT1 Shady trunk SHIPPED #76 @ `f1323259`); Soft catalog CLOSED
**Rule:** Pick **one**. §4.5 never leaks. Soft catalog stays closed. Hard-park camera off-switch Soft. Do **not** turn AT1, AS1, AR1, AQ1, AP1, AO1, AN1, AM1, AL1, AK1, AJ1, AI1, AH1, AG1, AF1, AC1, AD1, or AE1 into a sell weight. Fees / HUD / STOP stay parked.

---

## Context (shipped)

| Pack | Result |
|------|--------|
| A–AT1 | Full loop + buy channels through shady trunk |
| Soft | Catalog CLOSED; AC1 through AT1 Soft OK MVP notes stay Soft |

**Gap:** One-counter haggle (systems §3) still dark. Fee cut stays parked. Camera off-switch Soft hard-parked. Fees / HUD / STOP parked by PM.

---

## Option AU1 — One-counter haggle (systems §3) — **LEAN GO**

**Player fantasy:** On a cash buy offer, you get one shot to name a lower price. They take it, or the deal is gone.

| Deliverable | Spec |
|-------------|------|
| Where | Cash buy offers that already show an ask: distributor, marketplace, and shady trunk **Buy**. Out: auction snipes (timer), player trades (in-kind), Report, Walk |
| Actions | **Accept** (pay ask), **Counter** (one lower cash offer), **Decline**. Counter is once per offer |
| Accept chance | Seeded. `p = clamp((offer / ask) × (0.40 + Rep × 0.006) × channel_w, 0, 1)`. Roll once. Hit → buy at the counter price into BACKSTOCK. Miss → offer gone, same as Decline |
| Channel weights | Distributor `1.10`. Marketplace `1.00`. Shady trunk `0.80` |
| Bounds | Counter must be ≥ 1¢ and < ask. At or above ask is refused and the counter is not spent |
| Fail | Missed counter or Decline: no cash move, no lot, no Rep change |
| UI | Never shows `true_market`, `p`, or the accept roll |
| Config | Missing channel weight falls back to `1.00`. Missing Rep term falls back to `0.40 + Rep × 0.006` |
| Untouched | Fee stays 8%. Door spawn, auction, trunk Report/Walk, drift, and shrink stay as shipped |
| Soft | Catalog untouched; leave AC1 through AT1 Soft OK alone |

**Acceptance:**

1. Same seeded offer: Accept still buys at the ask. One Counter below the ask either buys at that price or clears the offer. A second Counter is refused.
2. A Counter ≥ ask is refused and the one-shot stays available. A missed Counter leaves cash, lots, and Rep unchanged.
3. Same offer/ask/Rep: distributor `p` is higher than marketplace, and marketplace is higher than shady, using the weights above. No screen shows `true_market` or `p`.
4. Door spawn and whale weight are unchanged. A completed sale still pays the listed price. Marketplace fee stays 8%. Not a sell weight. Soft catalog CLOSED. No Art.

**Out:** A fee cut; sell-side Negotiate ±10%; net-worth HUD; STOP; camera off-switch; sell-weight rewires.

**Why now:** Every buy channel can appear. The bible's missing verb on those offers is the one counter.

---

## Option AU2 — Marketplace fee cut at Rep ≥ 75 — **PARK**

**Why park:** PM parked fee cuts. The 8% stays.

---

## Option AU3 — Sell-side Negotiate ±10% — **PARK**

**Why park:** Real §5.2 line. Buy-side haggle is the open §3 line. Sell negotiate can follow.

---

## Option AU4 — Net-worth HUD / STOP — **PARK**

**Why park:** PM parked both this pick.

---

## Camera off-switch — **HARD PARK Soft**

**Why park (hard):** Reopens Soft catalog.

---

## Recommendation (non-binding)

**GO AU1** (One-counter haggle). Park AU2/AU3/AU4. **Hard-park** the camera off-switch. Soft catalog stays closed.

---

## PM checklist

- [x] Choose **AU1** (recommended)
- [x] If AU1: Eng vs systems §3 haggle; leave fees and the door spawn alone; no Art
- [x] Sync this file to main before cloud agent
- [x] Soft catalog stays closed; fees / HUD / STOP stay parked

---

## Decision log

| When | Decision |
|------|----------|
| 2026-10-03 | Drafted post AT1 SHIPPED #76 @ `f1323259`. Lean **AU1 One-counter haggle**. Fee cut / sell negotiate / HUD / STOP parked. Camera off-switch hard-parked. |
| 2026-10-03 | PM adopted **AU1**. Park AU2/AU3/AU4. Hard-park camera off-switch. Soft catalog CLOSED. One counter on distributor, marketplace, and shady Buy. Draft sha256 `dc4b10d0`. |
| 2026-10-03 | PM adopted **AU1**. Spec on main `02763134`. Spike [AU1 one-counter haggle](https://cursor.com/agents/bc-9ee6ae0d-dd54-59e8-a845-b11dc960f08d). Park AU2/AU3/AU4. No Art. Soft catalog CLOSED. Draft sha256 `dc4b10d0`. |
| 2026-10-03 | PM tip-froze PR #77 @ `30c77934`. Ready. 5 files, no docs. Agent archived. |
| 2026-10-03 | PM SHIPPED **AU1**. Squash-merged #77 @ `44a1b299` (reviewed `30c77934`). QA PASS, harness 73/0/0. No new Soft note. Branch `cursor/au1-one-counter-haggle-f08d` deleted. |
