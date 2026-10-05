# Next Eng SoT Pick BD v1 — post BC1

**Status:** **BD1 ADOPTED** 2026-10-05 — Extend BB1 NM mismatch onto auction. Spec on main `f54e9335`. Park BD2/BD3/BD4. Hard-park camera off-switch. Soft catalog CLOSED. Fees, net-worth HUD, and STOP stay parked. Do not turn prior packs into a sell weight. Door spawn math stays as shipped.
**Author:** CSS Designer
**Date:** 2026-10-05
**Depends on:** pick-bc (BC1 Auction Inspect fog SHIPPED #85 @ `89ae3b0a`); Soft catalog CLOSED
**Rule:** Pick **one**. §4.5 never leaks. Soft catalog stays closed. Hard-park camera off-switch Soft. Do **not** turn BC1, BB1, BA1, AZ1, AY1, AX1, AW1, AV1, AU1, AT1, AS1, AR1, AQ1, AP1, AO1, AN1, AM1, AL1, AK1, AJ1, AI1, AH1, AG1, AF1, AC1, AD1, or AE1 into a sell weight. Fees / HUD / STOP stay parked.

---

## Context (shipped)

| Pack | Result |
|------|--------|
| A–BC1 | Full loop + fog Inspect on buylist / marketplace / shady / auction + BB1 sell mismatch on marketplace/shady |
| Soft | Catalog CLOSED; AC1 through BC1 Soft OK MVP notes stay Soft |

**Gap:** Auction buys can skip Inspect and list NM without BB1 sting. Fee cut stays parked. Camera off-switch Soft hard-parked. Fees / HUD / STOP parked by PM.

---

## Option BD1 — Extend BB1 NM mismatch onto auction buys (systems §2.2) — **LEAN GO**

**Player fantasy:** Skipping Inspect on an auction snipe and tagging the single NM has the same soft blow-up as a fog marketplace/shady buy.

| Deliverable | Spec |
|-------------|------|
| Where | Completed **shop sale** (Sell at list or AV1 Negotiate hit) of a **single** whose buy channel was **auction** (AS1), and the lot was **never Inspected** before acquire. Same fire rules as BB1 |
| Trigger | On sale settle: listed condition presents as **NM** and true condition is **worse than NM** → fire mismatch once |
| Penalty | Soft Rep **−2** once. Cash refund = `round(sale_price × 0.50)` cents. Stock stays sold (no return-to-shelf MVP) |
| Channel set | BB1 channels stay: marketplace + shady. This pick **adds** auction. Still out: distributor NM-assumed, buylist, graded/`cert_valid` fake path (AT1), inspected lots |
| Safe paths | Inspected before Bid (BC1 reveal spent) → no mismatch. Listed as true-or-worse band → no mismatch |
| UI | Same soft failure beat as BB1. Never shows `true_market`, Inspect `p`, or `cert_valid` |
| Config | Same BB1 fallbacks (−2 / 0.50) |
| Untouched | Fee stays 8%. Door spawn, whale weight, BC1/BA1/AY1/AZ1 Inspect, AV1, AT1, Bid Att 10 stay as shipped |
| Soft | Catalog untouched; leave AC1 through BC1 Soft OK alone |

**Acceptance:**

1. Same uninspected auction single listed NM with true LP+: sale applies Rep −2 once and refunds half the sale cents. An inspected auction lot on the same seed does not.
2. Marketplace/shady BB1 path unchanged. Listed at true condition (or worse) → no mismatch. Distributor lots never fire.
3. No screen shows `true_market` or `cert_valid`.
4. Buyer door spawn and whale weight are unchanged. Marketplace fee stays 8%. Not a sell weight. Soft catalog CLOSED. No Art.

**Out:** A fee cut; net-worth HUD; STOP; camera off-switch; listed-band retag UI; inspect-mandatory; sell-weight rewires.

**Why now:** Auction Inspect is live. §2.2 sell consequence should match the other fog photo channels.

---

## Option BD2 — Marketplace fee cut at Rep ≥ 75 — **PARK**

**Why park:** PM parked fee cuts unless Design leans one. Not leaning — the 8% stays.

---

## Option BD3 — Net-worth HUD / STOP — **PARK**

**Why park:** PM parked both unless Design leans one. Not leaning this pick.

---

## Option BD4 — Listed-band retag UI (BB1 Soft) — **PARK Soft**

**Why park:** Soft catalog CLOSED. Eng Soft from BB1 stays Soft OK MVP.

---

## Camera off-switch — **HARD PARK Soft**

**Why park (hard):** Reopens Soft catalog.

---

## Recommendation (non-binding)

**GO BD1** (Extend BB1 NM mismatch onto auction). Park BD2/BD3/BD4. **Hard-park** the camera off-switch. Soft catalog stays closed.

---

## PM checklist

- [x] Choose **BD1** (recommended)
- [x] If BD1: Eng vs systems §2.2 — add auction to BB1 fog-channel set; leave fees and door spawn alone; no Art
- [x] Sync this file to main before cloud agent
- [x] Soft catalog stays closed; fees / HUD / STOP stay parked

---

## Decision log

| When | Decision |
|------|----------|
| 2026-10-05 | Drafted post BC1 SHIPPED #85 @ `89ae3b0a`. Lean **BD1 Extend BB1 NM mismatch onto auction**. Fee cut / HUD / STOP / listed-band retag parked. Camera off-switch hard-parked. |
| 2026-10-05 | PM ADOPTED **BD1**. Sync to main; Eng bar = this commit. Soft CLOSED. No Art. |
| 2026-10-05 | PM adopted **BD1**. Spec on main `f54e9335`. Spike [BD1 Extend BB1 NM mismatch onto auction](https://cursor.com/agents/bc-7959cef1-9fd5-5dd8-8f5a-7a878ac2dc50). Park BD2/BD3/BD4. No Art. Soft catalog CLOSED. Draft sha256 `4e30f141`. |
| 2026-10-05 | Eng bar locked BD1 against `f54e9335`. Auction joins BB1 fog set. Awaiting tip-freeze. |
| 2026-10-05 | PM tip-froze PR #86 @ `a0094b84`. Ready. 3 files, no docs. Agent archived. |
| 2026-10-05 | PM tip-froze PR #86 @ `a0094b84`. Ready. 3 files, no docs. Agent archived. |
| 2026-10-05 | Eng **APPROVE** BD1 [PR #86](https://github.com/adamwlarson/cardshopsimulator/pull/86) @ `a0094b84`. No Soft OK notes. Soft catalog CLOSED. QA formal released. |
| 2026-10-05 | BD1 SHIPPED — squash-merged #86 @ `58fc3c13` (reviewed `a0094b84`). QA PASS harness 152/0/0. |
