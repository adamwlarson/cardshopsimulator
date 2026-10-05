# Next Eng SoT Pick BG v1 — post BF1

**Status:** **BG1 ADOPTED** 2026-10-05 — Online frequent-cancel Rep (first cancel/day free; each extra same day Rep −1). Park BG2/BG3/BG4. Hard-park camera off-switch. Soft catalog CLOSED. STOP stays parked. Do not turn prior packs into a sell weight. Door spawn math stays as shipped.
**Author:** CSS Designer
**Date:** 2026-10-05
**Depends on:** pick-bf (BF1 Net-worth HUD SHIPPED #88 @ `08947d2c`); Soft catalog CLOSED
**Rule:** Pick **one**. §4.5 never leaks. Soft catalog stays closed. Hard-park camera off-switch Soft. Do **not** turn BF1, BE1, BD1, BC1, BB1, BA1, AZ1, AY1, AX1, AW1, AV1, AU1, AT1, AS1, AR1, AQ1, AP1, AO1, AN1, AM1, AL1, AK1, AJ1, AI1, AH1, AG1, AF1, AC1, AD1, AE1, or AA1 into a sell weight. STOP stays parked.

---

## Context (shipped)

| Pack | Result |
|------|--------|
| A–BF1 | Full loop + online fee cut + net-worth HUD |
| Soft | Catalog CLOSED; AC1 through BF1 Soft OK MVP notes stay Soft |

**Gap:** §4.4 still says frequent online cancels cost Rep, but I1 left the threshold soft. Camera off-switch Soft hard-parked. STOP parked.

---

## Option BG1 — Online frequent-cancel Rep (systems §4.4) — **LEAN GO**

**Player fantasy:** Yanking listings all day burns trust — one rethink is fine, a habit is not.

| Deliverable | Spec |
|-------------|------|
| Where | Cancel of an `ONLINE_HOLD` listing before fill (I1 cancel path). Out: completed online sales, in-shop pulls, list create |
| Free | First cancel each calendar day is free — no Rep change |
| Frequent | Each additional cancel the **same day** applies soft Rep **−1** once per cancel |
| Stock | Cancel always returns the lot off `ONLINE_HOLD` to backstock (or prior non-hold location) as today's cancel already does |
| UI | Soft feedback beat OK (trust ding). Never shows `true_market` or `p_buy` |
| Config | Missing free-count falls back to **1**/day. Missing Rep penalty falls back to **−1** |
| Untouched | Fee ladder (8%/5%), ship delay, BF1 HUD formula, door spawn, whale weight, fog Inspect, BB1/BD1 mismatch stay as shipped |
| Soft | Catalog untouched; leave AC1 through BF1 Soft OK alone |

**Acceptance:**

1. Same day: first ONLINE_HOLD cancel leaves Rep unchanged; second and third each apply Rep −1 once.
2. Next calendar day: first cancel is free again. A completed online sale never fires this path.
3. Cancel still returns stock off ONLINE_HOLD. No screen shows `true_market` or `p_buy`.
4. Door spawn and whale weight are unchanged. Fee ladder unchanged. Not a sell weight. Soft catalog CLOSED. No Art.

**Out:** STOP / win assert; camera off-switch; listed-band retag UI; cancel fees in cash; sell-weight rewires.

**Why now:** Online list + fee cut + wealth HUD are live. §4.4's frequent-cancel sting needs a hard threshold.

---

## Option BG2 — STOP / win assert polish — **PARK**

**Why park:** No new Eng systems. Prefer the §4.4 verb this pick.

---

## Option BG3 — Listed-band retag UI (BB1 Soft) — **PARK Soft**

**Why park:** Soft catalog CLOSED.

---

## Option BG4 — Display-bonus on live sell roll (AC1 Soft) — **PARK Soft**

**Why park:** Soft catalog CLOSED. AC1 notice-only Soft OK MVP stays Soft.

---

## Camera off-switch — **HARD PARK Soft**

**Why park (hard):** Reopens Soft catalog.

---

## Recommendation (non-binding)

**GO BG1** (Online frequent-cancel Rep). Park BG2/BG3/BG4. **Hard-park** the camera off-switch. Soft catalog stays closed.

---

## PM checklist

- [x] Choose **BG1** (recommended)
- [x] If BG1: Eng vs systems §4.4 — first cancel/day free, further cancels Rep −1 each; leave fees and door spawn alone; no Art
- [x] Sync this file to main before cloud agent (pending commit SHA)
- [x] Soft catalog stays closed; STOP stays parked

---

## Decision log

| When | Decision |
|------|----------|
| 2026-10-05 | Drafted post BF1 SHIPPED #88 @ `08947d2c`. Lean **BG1 Online frequent-cancel Rep**. STOP / listed-band Soft / display-bonus Soft parked. Camera off-switch hard-parked. |
| 2026-10-05 | PM adopted **BG1 GO** Online frequent-cancel Rep (first cancel/day free; each extra same day Rep −1). Park BG2 STOP / BG3 listed-band Soft / BG4 display-bonus Soft. Hard-park camera off-switch. Soft catalog CLOSED. No Art. |
