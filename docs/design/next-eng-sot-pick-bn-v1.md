# Next Eng SoT Pick BN v1 — post BM1

**Status:** **ADOPTED** 2026-10-05 ~4:05pm ET — **BN1 Buylist low-% fewer lots**. Park BN2 STOP / BN3 Soft / BN4 Soft. Camera off-switch hard-parked. Soft CLOSED. Soft OK list-time stays Soft. No Art. Eng bar locked; awaiting tip-freeze.
**Author:** CSS Designer
**Date:** 2026-10-05
**Depends on:** pick-bm (BM1 Buylist low-% settle Rep drip SHIPPED #95 @ `dcc7f748`); Soft catalog CLOSED
**Rule:** Pick **one**. §4.5 never leaks. Soft catalog stays closed. Hard-park camera off-switch Soft. Do **not** turn BM1, BL1, BK1, BJ1, BI1, BH1, BG1, BF1, BE1, BD1, BC1, BB1, BA1, AZ1, AY1, AX1, AW1, AV1, AU1, AT1, AS1, AR1, AQ1, AP1, AO1, AN1, AM1, AL1, AK1, AJ1, AI1, AH1, AG1, AF1, AC1, AD1, AE1, or AA1 into a sell weight. STOP stays parked.

---

## Context (shipped)

| Pack | Result |
|------|--------|
| A–BM1 | Full loop + fair/overprice settle + suggested day-clear + buylist low-% Rep drip |
| Soft | Catalog CLOSED; AC1 through BM1 Soft OK MVP notes stay Soft |

**Gap:** Systems §4.3 still names **low buylist % → fewer lots** beside the drip BM1 just shipped. Stingy shops burn trust overnight but still see full seller traffic. Soft OK list-time suggested stays Soft. High-% seller flood still dark (park this pick). Camera off-switch Soft hard-parked. STOP parked.

---

## Option BN1 — Buylist low-% fewer lots (systems §4.3) — **LEAN GO**

**Player fantasy:** Keep the buylist stingy and regulars stop bringing lots — not just a quiet Rep drip at close.

| Deliverable | Spec |
|-------------|------|
| Where | Buylist **seller** walk-in / lot opportunity cadence for the open day (AW1 buy-from-them sellers). Out: buyer door spawn; whale weight; BM1 overnight drip; high-% seller flood |
| Gate | Read the player's **buylist % of market** per category (sealed / singles NM / graded) as AW1/BM1 store them |
| Starve | If **any** category is **strictly below** `drip_floor` at open (same floor BM1 uses) → apply `fewer_lots_mult` to that day's seller-lot / seller-walk-in weight |
| Floor | Missing `drip_floor` → **0.40**. Floor ≤ 0 falls back to **0.40**. Categories at exactly the floor do **not** starve |
| Mult | Missing `fewer_lots_mult` → **0.50**. Mult ≤ 0 or > 1 falls back to **0.50**. Multiple low categories do not stack below one mult |
| Bounds | Does **not** invent marketplace / auction / distributor lot counts. Does not change BM1 settle −1. Does not raise seller traffic when % is high |
| UI | Soft empty-desk beat OK. Never shows `true_market` or `p_buy` |
| Untouched | BM1 drip, BK1 fair/gouge, BL1 cache clear, AW1 defaults, AX1 edit, fee ladder, **buyer** door spawn, whale weight, fog Inspect, mismatch stay as shipped |
| Soft | Catalog untouched; leave Soft OK list-time suggested Soft |

**Acceptance:**

1. Same seed: sealed buylist at 0.39 (others ≥ 0.40), open day → seller-lot / seller-walk-in opportunities are about half the baseline (instrumented weight × 0.50). All categories at 0.40 → no starve from this rule.
2. Two categories below floor the same day still apply only one mult (no double starve). BM1 settle still −1 once if still low at close.
3. No screen shows `true_market` or `p_buy`. Buyer door spawn and whale weight unchanged.
4. Not a sell weight. Soft catalog CLOSED. No Art.

**Out:** STOP / win assert; camera off-switch; Soft OK list-time suggested persistence; high-% seller flood; sell-weight rewires.

**Why now:** BM1 closed the overnight trust half of §4.3's low-% line; fewer lots is the remaining floor-side cost on that same stingy desk.

---

## Option BN2 — STOP / win assert polish — **PARK**

**Why park:** No new Eng systems. Prefer the §4.3 fewer-lots close this pick.

---

## Option BN3 — Persist list-time suggested (BK1 Soft OK) — **PARK Soft**

**Why park:** Soft catalog CLOSED.

---

## Option BN4 — Listed-band / display-bonus Soft — **PARK Soft**

**Why park:** Soft catalog CLOSED.

---

## Camera off-switch — **HARD PARK Soft**

**Why park (hard):** Reopens Soft catalog.

---

## Recommendation (non-binding)

**GO BN1** (Buylist low-% fewer lots). Park BN2/BN3/BN4. **Hard-park** the camera off-switch. Soft catalog stays closed. High-% seller flood stays Out for a later pick.

---

## PM checklist

- [x] Choose **BN1** (recommended)
- [x] If BN1: Eng vs open-day seller cadence — any buylist category < 0.40 → seller-lot weight × 0.50; leave high-% flood and Soft OK list-time Soft; no Art; buyer door/whale untouched
- [x] Sync this file to main before cloud agent
- [x] Soft catalog stays closed; STOP stays parked

---

## Decision log

| When | Decision |
|------|----------|
| 2026-10-05 ~3:16pm ET | Drafted post BM1 SHIPPED #95 @ `dcc7f748` (reviewed `a47ec381`). Lean **BN1 Buylist low-% fewer lots**. STOP / Soft reopeners parked. Camera off-switch hard-parked. Soft CLOSED. High-% seller flood stays Out. |
| 2026-10-05 ~4:05pm ET | **ADOPTED** BN1. Park BN2 STOP / BN3 Soft / BN4 Soft. Camera off-switch hard-parked. Soft CLOSED. Soft OK list-time stays Soft. No Art. Eng bar locked; awaiting tip-freeze. |
| 2026-10-05 ~4:12pm ET | **Tip-frozen** [#96](https://github.com/adamwlarson/cardshopsimulator/pull/96) @ `4fd16f94` (branch `cursor/bn1-buylist-fewer-lots-17d3`). 10 files, no docs. Cloud agent bc-4bd4eeea archived. Eng review that SHA against bar `7979a02a`. QA held until APPROVE; no merge until PASS. Soft catalog CLOSED. |
