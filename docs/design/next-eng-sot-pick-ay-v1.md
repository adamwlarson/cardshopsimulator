# Next Eng SoT Pick AY v1 — post AX1

**Status:** **AY1 ADOPTED** 2026-10-05 — Buylist Inspect. Park AY2/AY3/AY4. Hard-park camera off-switch. Soft catalog CLOSED. Fees, net-worth HUD, and STOP stay parked. Do not turn rep bands, trades, shrink, walkouts, Fire, AU1 haggle, AV1 Negotiate, AW1 buylist, or AX1 Change offer into a sell weight. Door spawn math stays as shipped.
**Author:** CSS Designer
**Date:** 2026-10-05
**Depends on:** pick-ax (AX1 Edit You offer SHIPPED #80 @ `84cdf7c9`); Soft catalog CLOSED
**Rule:** Pick **one**. §4.5 never leaks. Soft catalog stays closed. Hard-park camera off-switch Soft. Do **not** turn AX1, AW1, AV1, AU1, AT1, AS1, AR1, AQ1, AP1, AO1, AN1, AM1, AL1, AK1, AJ1, AI1, AH1, AG1, AF1, AC1, AD1, or AE1 into a sell weight. Fees / HUD / STOP stay parked.

---

## Context (shipped)

| Pack | Result |
|------|--------|
| A–AX1 | Full loop + buylist You offer + one Change offer |
| Soft | Catalog CLOSED; AC1 through AX1 Soft OK MVP notes stay Soft |

**Gap:** Buylist Inspect optional (systems §2.2, §3, §4.5 condition fog) still dark on the seller serve. Fee cut stays parked. Camera off-switch Soft hard-parked. Fees / HUD / STOP parked by PM.

---

## Option AY1 — Buylist Inspect (systems §2.2 / §4.5) — **LEAN GO**

**Player fantasy:** Before you buy from a walk-in, you can spend Attention to peek the condition — usually right, sometimes wrong.

| Deliverable | Spec |
|-------------|------|
| Where | AW1/AX1 buylist `CustomerServe` only (customer selling to the shop). Out: shop-buy serve, marketplace/shady Inspect if already separate, auction, trades |
| Cue before Inspect | Condition cue is **inspect optional** copy (e.g. "Inspect optional" / photo cue). True condition stays hidden until Inspect |
| Actions | Existing **Buy** / **Walk** / **Change offer**, plus one **Inspect** |
| Inspect | Costs **5** Attention (systems §6.2). Paid when taken. At Att < 5: refused, Att unchanged, shot stays. Cashier cannot Inspect on this path |
| Reveal | Seeded once. **85%** shows the true condition band (NM/LP/MP/HP/DMG). **15%** shows an adjacent wrong band (never leaps NM↔DMG). UI shows the revealed band only — never `true_market`, never `cert_valid` |
| Bounds | One Inspect per serve. A second Inspect is refused. Inspect does not Buy, Walk, or Change offer |
| After | Buy / Walk / Change stay as shipped against current You offer. Acquired lot stores the **true** condition in domain even when the reveal was wrong |
| Untouched | Fee stays 8%. Buyer door spawn, whale weight, AV1 Negotiate, AU1 Counter, AX1 Change rules stay as shipped |
| Soft | Catalog untouched; leave AC1 through AX1 Soft OK alone |

**Acceptance:**

1. Same buylist serve: one Inspect spends 5 Att and shows a condition band. A second Inspect is refused. At Att < 5 the step is refused and Att stays.
2. Same seed: 85% of Inspects match true condition; 15% show an adjacent wrong band. No screen shows `true_market` or `cert_valid`.
3. Buy after Inspect still pays current You offer into backstock; the lot's true condition in domain is unchanged by a wrong reveal. Walk / Change anger floor stay as AX1/AW1.
4. Buyer door spawn and whale weight are unchanged. Marketplace fee stays 8%. Not a sell weight. Soft catalog CLOSED. No Art.

**Out:** A fee cut; net-worth HUD; STOP; camera off-switch; Specialist inspect 5→2; marketplace/shady Inspect rewires; sell-side uninspected NM mismatch; sell-weight rewires.

**Why now:** Change offer closed §4.3 "you set offer". The matching §2.2 verb on that desk is optional Inspect.

---

## Option AY2 — Marketplace fee cut at Rep ≥ 75 — **PARK**

**Why park:** PM parked fee cuts unless Design leans one. Not leaning — the 8% stays.

---

## Option AY3 — Net-worth HUD / STOP — **PARK**

**Why park:** PM parked both unless Design leans one. Not leaning this pick.

---

## Option AY4 — Specialist inspect discount (5→2) — **PARK**

**Why park:** Real §6.2 line. Owner Inspect at 5 is the open gate. Staff discount can follow.

---

## Camera off-switch — **HARD PARK Soft**

**Why park (hard):** Reopens Soft catalog.

---

## Recommendation (non-binding)

**GO AY1** (Buylist Inspect). Park AY2/AY3/AY4. **Hard-park** the camera off-switch. Soft catalog stays closed.

---

## PM checklist

- [x] Choose **AY1** (recommended)
- [x] If AY1: Eng vs systems §2.2 Inspect 5 Att / 85% accuracy on buylist serve; leave fees and buyer door spawn alone; no Art
- [x] Sync this file to main before cloud agent
- [x] Soft catalog stays closed; fees / HUD / STOP stay parked

---

## Decision log

| When | Decision |
|------|----------|
| 2026-10-05 | Drafted post AX1 SHIPPED #80 @ `84cdf7c9`. Lean **AY1 Buylist Inspect**. Fee cut / HUD / STOP / Specialist discount parked. Camera off-switch hard-parked. |
| 2026-10-05 | PM adopted **AY1**. Park AY2/AY3/AY4. Hard-park camera off-switch. Soft catalog CLOSED. One Inspect on the AW1/AX1 buylist serve. Draft sha256 `b9c2513b`. |
| 2026-10-05 | PM adopted **AY1**. Spec on main `98b7e177`. Spike [AY1 buylist Inspect](https://cursor.com/agents/bc-7fa02845-7904-52da-b1d8-a1fe89e9a0a4). Park AY2/AY3/AY4. No Art. Soft catalog CLOSED. Draft sha256 `b9c2513b`. |
