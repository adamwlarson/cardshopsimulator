# Next Eng SoT Pick E v1 — post C2 (beats vs polish)

**Status:** Adopted — **C3 shipped #29**; **HOLD shipped #32**; **Option D shipped #33** @ `b32703d9` (2026-09-06)
**Author:** CSS Designer  
**Date:** 2026-09-04  
**Depends on:** pick-c (C1/C3), pick-d (C2 shipped #28), ui-wireflows §5.1 #3/#10, systems §8/#10  
**Rule:** Pick **one**. Specs for C3/D already in pick-c / pick-d — this is the GO. §4.5 never leaks.

---

## Context

| Shipped | |
|---------|--|
| C1 events | #26 |
| C2 hire-vs-owner | #28 |
| Specialist / cashier / shell / lights | #24 / #23 / #25 / #27 |

**Parked soft (non-blocking):** MidCenter densify AABB, apron FOV, `can_research` / Easy-Hard inherit, icon 2× / sell-tint, etc.

**Gap:** Option D #33 + F1 #34 shipped. Next: pick-g **G1** (graded authenticity) in flight.

---

## Option C3 — §10 #3 outing + #10 shady — **LEAN GO**

**SoT:** `next-eng-sot-pick-c-v1.md` § Option C3 + ui-wireflows §5.1.

| Deliverable | Spec |
|-------------|------|
| #3 Marketplace outing | Drive (Att 25 + miss FLOOR hours) / Courier fee / Skip |
| #10 Shady trunk | Buy / Report / Walk — Rep/cash forks |
| Shared | BuyOpportunityDetail + §4.5; BeatInjection only |

**Acceptance:**

1. Both beats reachable on Normal day windows without debug.
2. Drive reduces Attention + shortens FLOOR that day; Courier keeps FLOOR.
3. Shady paths never leak true condition / `cert_valid` on confirm.
4. Report applies Rep delta (BalanceConfig or Normal default).

**Out:** Off-site 3D scenes; combat; lip sync.

**Why now:** Hire + events live — next pain should be **risk forks** players feel in the first weeks. Highest decision-pressure left in the parked pack.

---

## Option D — Event → PriceEditor bridge — **GO**

**SoT:** `next-eng-sot-pick-d-v1.md` § Option D (do not fork).

On active Hype/Fog: once force PriceEditor on affected SKU (§4.5 chips only); Cancel OK; no new event kinds (C1 bus only). May use §10 #7 Titan path as the seeded SKU.

**Acceptance (confirmed 2026-09-06):**

1. Seeded Hype day opens PriceEditor on target SKU **once** without debug.
2. No `true_market` / `cert_valid` (or other §4.5 forbidden) on that open.
3. Cancel leaves event active; Apply persists list price.
4. No new event kinds — uses existing C1 hype/fog bus only.

**Out:** New event kinds; full news UI.

---

## Option HOLD — Soft polish pass (no new spike)

Sweep parked softs that Eng/QA already named: `can_research` / Easy-Hard inherit, StaffPanel, MidCenter note (Art), apron FOV (Art). **No new player verb.**

**Acceptance:** each parked soft either fixed or explicitly Won’t-Fix with owner; no new S2+.

**Why pick:** Clear debt before content.  
**Why park (lean):** Softs are non-blocking; Adam priority has been decision pressure — C3 delivers more play.

---

## Recommendation (non-binding)

**GO C3.** Park D + HOLD until after #3/#10 land (or Art apron finishes in parallel).

---

## PM checklist

- [x] Choose **C3** (D + HOLD parked)
- [x] If C3: Eng uses pick-c C3 + wireflows §5.1 (no fork)
- [x] Sync this file to main before cloud agent
- [ ] Update pick-c/d decision logs when spike ships

