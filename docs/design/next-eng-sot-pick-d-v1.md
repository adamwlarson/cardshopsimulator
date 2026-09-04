# Next Eng SoT Pick D v1 — post C1 (hire pressure vs §10 beats)

**Status:** Adopted — **C2 hire-vs-owner shipped #28** @ `f3388f0b` (QA PASS @ `df7701e9`); C3 + D parked  
**Author:** CSS Designer  
**Date:** 2026-09-04  
**Depends on:** `next-eng-sot-pick-c-v1.md` (C1 shipped #26; densify #27 shipped); systems §6 / §10; ui-wireflows §5.1 #3/#5/#10  
**Rule:** Pick **one** spike. Specs for C2/C3 live in pick-c — this doc is the GO choice only. §4.5 fog never leaks.

---

## Context

| Done | Result |
|------|--------|
| A / B | Attention deepen + Medium 14×10 |
| C1 | Market events #26 (hype / soft rotation / fog) |
| Specialist / cashier / shell / lights | #24 / #23 / #25 / #27 |

**Gap:** Hire-vs-solo still soft (cashier mesh exists; §10 #5 + Reliability thin). Optional outing/shady beats still parked.

---

## Option C2 — Hire vs owner bandwidth — **LEAN GO**

**SoT detail:** `next-eng-sot-pick-c-v1.md` § Option C2 (do not fork — implement that table).

**Delta since pick-c written:** Specialist Att-discount **shipped** (#24). Acceptance #4 is now an **assert**, not a dependency.

| Deliverable | Spec (summary) |
|-------------|----------------|
| §10 #5 | Hire / Keep solo / Unreliable — wireflows §5.1 |
| Reliability | Low → no-show and/or shrink bias |
| Owner @ Att 0 | Block Research/Inspect/Negotiate/Pull; cashier routine-sells |
| Specialist | On duty → Inspect 2 / Research 10 (already on BalanceConfig) |
| Mesh | Hire-gated `char_cashier_01` already #23 |

**Acceptance (falsifiable):**

1. Day~5 beat: Hire / Solo / Unreliable all reachable; Hire adds wage + uses staff_cap; Solo leaves roster empty.
2. Unreliable: ≥1 no-show **or** shrink↑ in a 10-day seeded stress; no soft-lock.
3. Att 0: owner verbs disabled; routine sales still resolve with cashier on duty.
4. Specialist on duty: Inspect/Research Att costs = **2 / 10** (QA HUD + BalanceConfig).

**Out:** New staff roles; dialogue; full HR.

**Modules:** staff + wages + thin hire modal.

**Why now:** Events live; next pain should be **bandwidth vs wages** so cashier/Specialist aren’t cosmetics.

---

## Option C3 — Optional §10 #3 outing + #10 shady

**SoT detail:** `next-eng-sot-pick-c-v1.md` § Option C3.

**Acceptance:** both beats reachable; Drive burns Att + FLOOR hours; shady never leaks `cert_valid`/true condition; Report applies Rep delta.

**Why pick:** Content pressure, thin eng if staff systems busy.

**Why park:** Less systemic than hire economy after C1.

---

## Option D — (new) Event → Price pressure bridge only

**Player fantasy:** Active event forces a pricing decision the same day — not just a banner.

| Deliverable | Spec |
|-------------|------|
| Hook | On Hype / Fog active: force one PriceEditor open on affected SKU (or §10 #7 Titan path) with §4.5 chips only |
| Skip | Player may Cancel; event still runs |
| No new event types | Uses C1 bus only |

**Acceptance:**

1. Seeded Hype day opens PriceEditor on target SKU once without debug.
2. No `true_market` / `cert_valid` on that open.
3. Cancel leaves event active; Apply persists list price.

**Out:** New event kinds; full news UI.

**Why park (lean):** Nice polish; weaker than making hire hurt. Prefer after C2.

---

## Recommendation (non-binding)

**GO C2.** Point Eng at pick-c Option C2 + acceptance above (Specialist assert). Park C3 + D.

---

## PM checklist

- [x] Choose **C2** (C3 + D parked)
- [x] If C2: Eng spike uses pick-c C2 table + this acceptance (no new design doc needed beyond this GO)
- [x] Sync this file to main before cloud agent
- [ ] Update pick-c decision log when chosen spike ships

