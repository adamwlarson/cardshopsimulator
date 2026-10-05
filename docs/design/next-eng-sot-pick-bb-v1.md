# Next Eng SoT Pick BB v1 — post BA1

**Status:** **BB1 ADOPTED** 2026-10-05 — Sell-side uninspected NM mismatch. Park BB2/BB3/BB4. Hard-park camera off-switch. Soft catalog CLOSED. Fees, net-worth HUD, and STOP stay parked. Do not turn prior packs into a sell weight. Door spawn math stays as shipped.
**Author:** CSS Designer
**Date:** 2026-10-05
**Depends on:** pick-ba (BA1 Marketplace / shady Inspect SHIPPED #83 @ `c9a303c6`); Soft catalog CLOSED
**Rule:** Pick **one**. §4.5 never leaks. Soft catalog stays closed. Hard-park camera off-switch Soft. Do **not** turn BA1, AZ1, AY1, AX1, AW1, AV1, AU1, AT1, AS1, AR1, AQ1, AP1, AO1, AN1, AM1, AL1, AK1, AJ1, AI1, AH1, AG1, AF1, AC1, AD1, or AE1 into a sell weight. Fees / HUD / STOP stay parked.

---

## Context (shipped)

| Pack | Result |
|------|--------|
| A–BA1 | Full loop + buy Inspect on buylist / marketplace / shady |
| Soft | Catalog CLOSED; AC1 through BA1 Soft OK MVP notes stay Soft |

**Gap:** Sell-side uninspected NM mismatch (systems §2.2) still dark. Fee cut stays parked. Camera off-switch Soft hard-parked. Fees / HUD / STOP parked by PM.

---

## Option BB1 — Sell-side uninspected NM mismatch (systems §2.2) — **LEAN GO**

**Player fantasy:** If you list a fog-bought single as NM without Inspect, a sale can blow up — soft Rep hit and a refund sting.

| Deliverable | Spec |
|-------------|------|
| Where | Completed **shop sale** (Sell at list or AV1 Negotiate hit) of a **single** whose buy channel was marketplace or shady, and the lot was **never Inspected** before acquire (or Inspect was skipped). Out: distributor NM-assumed, buylist (inspect optional already), graded/`cert_valid` fake path (AT1), inspected lots |
| Trigger | On sale settle: if listed condition presents as **NM** and true condition is **worse than NM**, fire mismatch once |
| Penalty | Soft Rep **−2** once. Cash refund = `round(sale_price × 0.50)` cents (claw back half the sale). Stock stays sold (no return-to-shelf MVP) |
| Safe paths | Inspected before buy (reveal spent) → no mismatch. Listed as true-or-worse band → no mismatch. Distributor / inspected / graded cert path untouched |
| UI | Sale can show a soft failure beat (refund + trust ding). Never shows `true_market`, Inspect `p`, or `cert_valid` |
| Config | Missing Rep penalty falls back to −2. Missing refund fraction falls back to 0.50 |
| Untouched | Fee stays 8%. Buyer door spawn, whale weight, BA1/AY1/AZ1 Inspect, AV1 Negotiate, AT1 fake-slab stay as shipped |
| Soft | Catalog untouched; leave AC1 through BA1 Soft OK alone |

**Acceptance:**

1. Same uninspected marketplace/shady single listed NM with true LP+: sale applies Rep −2 once and refunds half the sale cents. An inspected lot on the same seed does not.
2. Listed at true condition (or worse) → no mismatch. Distributor NM-assumed lots never fire this path.
3. No screen shows `true_market` or `cert_valid`. Graded fake-on-sale stays AT1 only.
4. Buyer door spawn and whale weight are unchanged. Marketplace fee stays 8%. Not a sell weight. Soft catalog CLOSED. No Art.

**Out:** A fee cut; net-worth HUD; STOP; camera off-switch; full stock return; inspect-mandatory scare; sell-weight rewires.

**Why now:** Buy Inspect is live on fog channels. §2.2 still needs the sell consequence when you skip it and tag NM.

---

## Option BB2 — Marketplace fee cut at Rep ≥ 75 — **PARK**

**Why park:** PM parked fee cuts unless Design leans one. Not leaning — the 8% stays.

---

## Option BB3 — Net-worth HUD / STOP — **PARK**

**Why park:** PM parked both unless Design leans one. Not leaning this pick.

---

## Option BB4 — Auction Inspect fog — **PARK**

**Why park:** Real channel polish. Sell-side mismatch is the open §2.2 line. Auction Inspect can follow.

---

## Camera off-switch — **HARD PARK Soft**

**Why park (hard):** Reopens Soft catalog.

---

## Recommendation (non-binding)

**GO BB1** (Sell-side uninspected NM mismatch). Park BB2/BB3/BB4. **Hard-park** the camera off-switch. Soft catalog stays closed.

---

## PM checklist

- [x] Choose **BB1** (recommended)
- [x] If BB1: Eng vs systems §2.2 sell mismatch on uninspected fog singles; leave fees and door spawn alone; no Art
- [x] Sync this file to main before cloud agent
- [x] Soft catalog stays closed; fees / HUD / STOP stay parked

---

## Decision log

| When | Decision |
|------|----------|
| 2026-10-05 | Drafted post BA1 SHIPPED #83 @ `c9a303c6`. Lean **BB1 Sell-side uninspected NM mismatch**. Fee cut / HUD / STOP / auction Inspect parked. Camera off-switch hard-parked. |
| 2026-10-05 | PM adopted **BB1**. Park BB2/BB3/BB4. Hard-park camera off-switch. Soft catalog CLOSED. Sell-side NM mismatch on uninspected marketplace/shady singles. Draft sha256 `692fbfc4`. |
| 2026-10-05 | PM adopted **BB1**. Spec on main `908e80fe`. Park BB2/BB3/BB4. No Art. Soft catalog CLOSED. Draft sha256 `692fbfc4`. |
| 2026-10-05 | PM adopted **BB1**. Spec on main `0ba5560c`. Spike [BB1 Sell-side uninspected NM mismatch](https://cursor.com/agents/bc-4d048863-d53c-5c84-b669-14b804622eea). Park BB2/BB3/BB4. No Art. Soft catalog CLOSED. Draft sha256 `692fbfc4`. |
