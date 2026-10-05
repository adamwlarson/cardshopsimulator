# Next Eng SoT Pick BK v1 — post BJ1

**Status:** **ADOPTED** 2026-10-05 ~2:20pm ET — **BK1 Fair / overprice settle Rep tick**. Park BK2 STOP / BK3 listed-band Soft / BK4 display-bonus Soft. Camera off-switch hard-parked. Soft CLOSED. No Art. Eng bar locked; awaiting tip-freeze.
**Author:** CSS Designer
**Date:** 2026-10-05
**Depends on:** pick-bj (BJ1 Persist ONLINE_HOLD listings SHIPPED #92 @ `47776097`); Soft catalog CLOSED
**Rule:** Pick **one**. §4.5 never leaks. Soft catalog stays closed. Hard-park camera off-switch Soft. Do **not** turn BJ1, BI1, BH1, BG1, BF1, BE1, BD1, BC1, BB1, BA1, AZ1, AY1, AX1, AW1, AV1, AU1, AT1, AS1, AR1, AQ1, AP1, AO1, AN1, AM1, AL1, AK1, AJ1, AI1, AH1, AG1, AF1, AC1, AD1, AE1, or AA1 into a sell weight. STOP stays parked.

---

## Context (shipped)

| Pack | Result |
|------|--------|
| A–BJ1 | Full loop + online fee/cancel/soft-cap/persist listings |
| Soft | Catalog CLOSED; AC1 through BJ1 Soft OK MVP notes stay Soft |

**Gap:** Systems §5.3 **Ticks** still name fair deals (+) and overprice (−) on the close-settle reputation pass; walkouts, cancel, mismatch, and Fire already sting, but honest vs gouging list price has no settle tick. Camera off-switch Soft hard-parked. STOP parked.

---

## Option BK1 — Fair / overprice settle Rep tick (systems §5.3 Ticks / day loop) — **LEAN GO**

**Player fantasy:** Price fairly and the shop earns trust overnight; gouge and it spends trust — without a spreadsheet of truth.

| Deliverable | Spec |
|-------------|------|
| Where | Close settle reputation tick (after wages/rent/shrink; with or before event roll). Out: walkouts (AH1), cancel (BG1/BH1), NM mismatch (BB1/BD1), Fire (AG1) — leave those alone |
| Fair | If the day had ≥1 **completed listed-price sale** whose ask was ≤ **noisy suggested × fair_mult**, and **no** overprice sale that day → apply Rep **+1** once |
| Overprice | If the day had ≥1 completed listed-price sale whose ask was ≥ **noisy suggested × gouge_mult** → apply Rep **−1** once and **skip** the fair +1 that day |
| Basis | Compare ask to the **same noisy suggested** the player already sees for that SKU (§4.5). Never to `true_market` |
| Scope | In-shop listed sales and completed online holds both count (same ask rule). Refuses, walkouts, cancels, and failed hagles do not |
| Caps | Fair +1 at most once/day. Overprice −1 at most once/day |
| Config | Missing `fair_mult` → **1.10**. Missing `gouge_mult` → **1.25**. Mult ≤ 0 falls back to those. Missing Rep deltas → **+1** / **−1** |
| UI | Soft ding / soft boost OK. Never shows `true_market`, `p_buy`, or the mult math |
| Untouched | Fee ladder, BI1 soft cap, BG1/BH1 cancel, BJ1 listing save, BF1 HUD, door spawn, whale weight, fog Inspect, BB1/BD1 mismatch stay as shipped |
| Soft | Catalog untouched; leave AC1 through BJ1 Soft OK alone |

**Acceptance:**

1. Same seed: one fair listed sale only (ask ≤ noisy suggested × 1.10), settle → Rep +1 once. Same day with one gouge sale (ask ≥ noisy suggested × 1.25) → Rep −1 once and no fair +1.
2. A day with no completed listed sales → neither tick. A second fair sale the same day does not add a second +1.
3. No screen shows `true_market` or `p_buy`. AH1 walkouts and BG1 cancel rules unchanged.
4. Door spawn and whale weight are unchanged. Not a sell weight. Soft catalog CLOSED. No Art.

**Out:** STOP / win assert; camera off-switch; listed-band retag UI; inventing new price bands beyond the two mults; sell-weight rewires.

**Why now:** Online trust loop is closed. The remaining §5.3 tick line is fair vs gouge on settle, and it stays behind the noisy suggested wall.

---

## Option BK2 — STOP / win assert polish — **PARK**

**Why park:** No new Eng systems. Prefer the settle Rep tick this pick.

---

## Option BK3 — Listed-band retag UI (BB1 Soft) — **PARK Soft**

**Why park:** Soft catalog CLOSED.

---

## Option BK4 — Display-bonus on live sell roll (AC1 Soft) — **PARK Soft**

**Why park:** Soft catalog CLOSED.

---

## Camera off-switch — **HARD PARK Soft**

**Why park (hard):** Reopens Soft catalog.

---

## Recommendation (non-binding)

**GO BK1** (Fair / overprice settle Rep tick). Park BK2/BK3/BK4. **Hard-park** the camera off-switch. Soft catalog stays closed.

---

## PM checklist

- [x] Choose **BK1** (recommended)
- [x] If BK1: Eng vs settle tick — fair ≤ noisy×1.10 → +1 once/day; gouge ≥ noisy×1.25 → −1 once/day and blocks fair; leave walkout/cancel/mismatch alone; no Art
- [x] Sync this file to main before cloud agent
- [x] Soft catalog stays closed; STOP stays parked

---

## Decision log

| When | Decision |
|------|----------|
| 2026-10-05 | Drafted post BJ1 SHIPPED #92 @ `47776097`. Lean **BK1 Fair / overprice settle Rep tick**. STOP / Soft reopeners parked. Camera off-switch hard-parked. |
| 2026-10-05 ~2:20pm ET | **ADOPTED** BK1. Park BK2 STOP / BK3 listed-band Soft / BK4 display-bonus Soft. Camera off-switch hard-parked. Soft CLOSED. No Art. Eng bar locked; awaiting tip-freeze. |
| 2026-10-05 ~2:33pm ET | **Tip-frozen** [#93](https://github.com/adamwlarson/cardshopsimulator/pull/93) @ `08c1b53f` (branch `cursor/bk1-fair-overprice-settle-rep-53b3`). 13 files, no docs. Cloud agent bc-ed8df823 archived. Eng review that SHA against bar `6c144830`. QA held until APPROVE; no merge until PASS. Soft catalog CLOSED. |
