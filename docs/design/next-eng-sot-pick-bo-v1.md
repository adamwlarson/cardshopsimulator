# Next Eng SoT Pick BO v1 — post BN1

**Status:** **ADOPTED** 2026-10-05 ~4:21pm ET — **BO1 Buylist high-% seller flood**. Park BO2 STOP / BO3 Soft / BO4 Soft. Camera off-switch hard-parked. Soft CLOSED. Soft OK list-time stays Soft. No Art. Eng bar locked; awaiting tip-freeze.
**Author:** CSS Designer
**Date:** 2026-10-05
**Depends on:** pick-bn (BN1 Buylist low-% fewer lots SHIPPED #96 @ `4eb7c9ea`); Soft catalog CLOSED
**Rule:** Pick **one**. §4.5 never leaks. Soft catalog stays closed. Hard-park camera off-switch Soft. Do **not** turn BN1, BM1, BL1, BK1, BJ1, BI1, BH1, BG1, BF1, BE1, BD1, BC1, BB1, BA1, AZ1, AY1, AX1, AW1, AV1, AU1, AT1, AS1, AR1, AQ1, AP1, AO1, AN1, AM1, AL1, AK1, AJ1, AI1, AH1, AG1, AF1, AC1, AD1, AE1, or AA1 into a sell weight. STOP stays parked.

---

## Context (shipped)

| Pack | Result |
|------|--------|
| A–BN1 | Full loop + fair/overprice settle + suggested day-clear + buylist low-% Rep drip + low-% fewer lots |
| Soft | Catalog CLOSED; AC1 through BN1 Soft OK MVP notes stay Soft |

**Gap:** Systems §4.3 still names **high buylist % → more sellers** (thinner margins / cash drain). BM1/BN1 closed the stingy-% half; generous desks still see baseline seller traffic only. Soft OK list-time suggested stays Soft. Camera off-switch Soft hard-parked. STOP parked.

---

## Option BO1 — Buylist high-% seller flood (systems §4.3) — **LEAN GO**

**Player fantasy:** Post a fat buylist and the desk fills with sellers — more lots to buy, thinner margins, cash at risk.

| Deliverable | Spec |
|-------------|------|
| Where | Buylist **seller** walk-in / lot opportunity cadence for the open day (same AW1 seller path BN1 touches). Out: buyer door spawn; whale weight; BM1 overnight drip; BN1 fewer-lots rule body |
| Gate | Read the player's **buylist % of market** per category (sealed / singles NM / graded) as AW1/BM1/BN1 store them |
| Flood | If **any** category is **strictly above** `flood_ceiling` at open **and** **no** category is strictly below `drip_floor` → apply `flood_lots_mult` to that day's seller-lot / seller-walk-in weight |
| Ceiling | Missing `flood_ceiling` → **0.70**. Ceiling ≤ 0 or ≥ 1 falls back to **0.70**. Categories at exactly the ceiling do **not** flood |
| Floor guard | Missing `drip_floor` → **0.40** (same as BM1/BN1). If any category is below drip_floor, **BN1 starve wins** that day — do not also flood |
| Mult | Missing `flood_lots_mult` → **1.50**. Mult ≤ 1 or > 3 falls back to **1.50**. Multiple high categories do not stack above one mult |
| Bounds | Does **not** invent marketplace / auction / distributor lot counts. Does not change BM1 settle −1 or BN1 ×0.50. Does not invent a separate cash-drain tick (margin thinness is the high % itself) |
| UI | Soft busy-desk beat OK. Never shows `true_market` or `p_buy` |
| Untouched | BM1 drip, BN1 fewer-lots, BK1 fair/gouge, BL1 cache clear, AW1 defaults, AX1 edit, fee ladder, **buyer** door spawn, whale weight, fog Inspect, mismatch stay as shipped |
| Soft | Catalog untouched; leave Soft OK list-time suggested Soft |

**Acceptance:**

1. Same seed: sealed buylist at 0.71 (others in [0.40, 0.70]), open day → seller-lot / seller-walk-in opportunities are about 1.5× baseline (instrumented weight × 1.50). All categories at 0.70 → no flood from this rule.
2. One category at 0.39 and another at 0.75 the same day → BN1 starve only (×0.50); no flood mult. Two categories above ceiling still apply only one flood mult.
3. No screen shows `true_market` or `p_buy`. Buyer door spawn and whale weight unchanged. BM1 drip and BN1 fewer-lots unchanged.
4. Not a sell weight. Soft catalog CLOSED. No Art.

**Out:** STOP / win assert; camera off-switch; Soft OK list-time suggested persistence; inventing cash-drain settle ticks; sell-weight rewires.

**Why now:** BM1/BN1 closed §4.3's low-% costs; high-% seller flood is the remaining live half of that same buylist desk line.

---

## Option BO2 — STOP / win assert polish — **PARK**

**Why park:** No new Eng systems. Prefer the §4.3 high-% flood close this pick.

---

## Option BO3 — Persist list-time suggested (BK1 Soft OK) — **PARK Soft**

**Why park:** Soft catalog CLOSED.

---

## Option BO4 — Listed-band / display-bonus Soft — **PARK Soft**

**Why park:** Soft catalog CLOSED.

---

## Camera off-switch — **HARD PARK Soft**

**Why park (hard):** Reopens Soft catalog.

---

## Recommendation (non-binding)

**GO BO1** (Buylist high-% seller flood). Park BO2/BO3/BO4. **Hard-park** the camera off-switch. Soft catalog stays closed. Soft OK list-time stays Soft.

---

## PM checklist

- [x] Choose **BO1** (recommended)
- [x] If BO1: Eng vs open-day seller cadence — any buylist category > 0.70 (and none < 0.40) → seller-lot weight × 1.50; leave Soft OK list-time Soft; no Art; BM1/BN1/buyer door/whale untouched
- [x] Sync this file to main before cloud agent
- [x] Soft catalog stays closed; STOP stays parked

---

## Decision log

| When | Decision |
|------|----------|
| 2026-10-05 ~4:20pm ET | Drafted post BN1 SHIPPED #96 @ `4eb7c9ea` (reviewed `4fd16f94`). Lean **BO1 Buylist high-% seller flood**. STOP / Soft reopeners parked. Camera off-switch hard-parked. Soft CLOSED. Soft OK list-time stays Soft. No Art. |
| 2026-10-05 ~4:21pm ET | **ADOPTED** BO1. Park BO2 STOP / BO3 Soft / BO4 Soft. Camera off-switch hard-parked. Soft CLOSED. Soft OK list-time stays Soft. No Art. Eng bar locked; awaiting tip-freeze. |
