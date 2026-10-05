# Next Eng SoT Pick BM v1 — post BL1

**Status:** **ADOPTED** 2026-10-05 ~3:01pm ET — **BM1 Buylist low-% settle Rep drip**. Park BM2 STOP / BM3 Soft / BM4 Soft. Camera off-switch hard-parked. Soft CLOSED. No Art. Eng bar locked; awaiting tip-freeze.
**Author:** CSS Designer
**Date:** 2026-10-05
**Depends on:** pick-bl (BL1 Day-rollover clear of cached noisy suggested SHIPPED #94 @ `78628a58`); Soft catalog CLOSED
**Rule:** Pick **one**. §4.5 never leaks. Soft catalog stays closed. Hard-park camera off-switch Soft. Do **not** turn BL1, BK1, BJ1, BI1, BH1, BG1, BF1, BE1, BD1, BC1, BB1, BA1, AZ1, AY1, AX1, AW1, AV1, AU1, AT1, AS1, AR1, AQ1, AP1, AO1, AN1, AM1, AL1, AK1, AJ1, AI1, AH1, AG1, AF1, AC1, AD1, AE1, or AA1 into a sell weight. STOP stays parked.

---

## Context (shipped)

| Pack | Result |
|------|--------|
| A–BL1 | Full loop + fair/overprice settle tick + suggested day-rollover clear |
| Soft | Catalog CLOSED; AC1 through BL1 Soft OK MVP notes stay Soft |

**Gap:** Systems §4.3 still names **low buylist % → reputation drip** (angry regulars / fewer lots). AW1/AX1 shipped buy-from-them + mid-serve edit; the overnight drip is still dark. Soft OK list-time suggested stays Soft. Camera off-switch Soft hard-parked. STOP parked.

---

## Option BM1 — Buylist low-% settle Rep drip (systems §4.3) — **LEAN GO**

**Player fantasy:** Starve sellers with a stingy buylist and the shop's trust drips overnight — not free margin forever.

| Deliverable | Spec |
|-------------|------|
| Where | Close settle reputation pass (after shrink; can share the settle beat with BK1). Out: high-% lot flood (park); walkouts; cancel; fair/gouge sale ticks (BK1) |
| Gate | Read the player's **buylist % of market** per category (sealed / singles NM / graded) as AW1 stores them |
| Drip | If **any** category is **strictly below** `drip_floor` at settle → apply Rep **−1** once that day |
| Floor | Missing `drip_floor` → **0.40**. Floor ≤ 0 falls back to **0.40**. Categories at exactly the floor do **not** drip |
| Caps | At most one −1 from this rule per settle day (multiple low categories do not stack) |
| Lots | **Out this pick** — do not invent fewer-lots spawn math yet (bible's "fewer lots" stays parked) |
| UI | Soft ding OK. Never shows `true_market` or `p_buy` |
| Untouched | AW1 defaults, AX1 edit offer, BK1 fair/gouge, BL1 cache clear, fee ladder, door spawn, whale weight, fog Inspect, mismatch stay as shipped |
| Soft | Catalog untouched; leave Soft OK list-time suggested Soft |

**Acceptance:**

1. Same seed: sealed buylist at 0.39 (others ≥ 0.40), settle → Rep −1 once. All categories at 0.40 → no drip from this rule.
2. Two categories below floor the same day still apply only one −1. Next settle day can drip again if still low.
3. No screen shows `true_market` or `p_buy`. BK1 fair/gouge and AH1 walkouts unchanged.
4. Door spawn and whale weight are unchanged. Not a sell weight. Soft catalog CLOSED. No Art.

**Out:** STOP / win assert; camera off-switch; Soft OK list-time suggested persistence; fewer-lots spawn; high-% seller flood; sell-weight rewires.

**Why now:** Buylist verbs are live; §4.3's stingy-% drip is the remaining overnight trust cost on that desk.

---

## Option BM2 — STOP / win assert polish — **PARK**

**Why park:** No new Eng systems. Prefer the §4.3 drip this pick.

---

## Option BM3 — Persist list-time suggested (BK1 Soft OK) — **PARK Soft**

**Why park:** Soft catalog CLOSED.

---

## Option BM4 — Listed-band / display-bonus Soft — **PARK Soft**

**Why park:** Soft catalog CLOSED.

---

## Camera off-switch — **HARD PARK Soft**

**Why park (hard):** Reopens Soft catalog.

---

## Recommendation (non-binding)

**GO BM1** (Buylist low-% settle Rep drip). Park BM2/BM3/BM4. **Hard-park** the camera off-switch. Soft catalog stays closed.

---

## PM checklist

- [x] Choose **BM1** (recommended)
- [x] If BM1: Eng vs settle — any buylist category < 0.40 → Rep −1 once/day; leave fewer-lots and Soft OK list-time Soft; no Art
- [x] Sync this file to main before cloud agent
- [x] Soft catalog stays closed; STOP stays parked

---

## Decision log

| When | Decision |
|------|----------|
| 2026-10-05 | Drafted post BL1 SHIPPED #94 @ `78628a58`. Lean **BM1 Buylist low-% settle Rep drip**. STOP / Soft reopeners parked. Camera off-switch hard-parked. |
| 2026-10-05 ~3:01pm ET | **ADOPTED** BM1. Park BM2 STOP / BM3 Soft / BM4 Soft. Camera off-switch hard-parked. Soft CLOSED. No Art. Eng bar locked; awaiting tip-freeze. |
| 2026-10-05 ~3:08pm ET | **Tip-frozen** [#95](https://github.com/adamwlarson/cardshopsimulator/pull/95) @ `a47ec381` (branch `cursor/bm1-buylist-low-pct-rep-drip-2e37`). 10 files, no docs. Cloud agent bc-2439be34 archived. Eng review that SHA against bar `719356bc`. QA held until APPROVE; no merge until PASS. Soft catalog CLOSED. |
| 2026-10-05 ~3:15pm ET | **SHIPPED** — squash-merged [#95](https://github.com/adamwlarson/cardshopsimulator/pull/95) @ `dcc7f748` (reviewed `a47ec381`). QA PASS-with-notes harness 159/0/0. Soft OK list-time stays Soft. Soft CLOSED. No Art. Next pick is BN. |
