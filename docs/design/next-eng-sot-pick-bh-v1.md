# Next Eng SoT Pick BH v1 — post BG1

**Status:** **ADOPTED** 2026-10-05 — **BH1 Persist online cancel day-count**. Park BH2/BH3/BH4. Hard-park camera off-switch. Soft catalog CLOSED. STOP stays parked. Do not turn prior packs into a sell weight. Door spawn math stays as shipped.
**Author:** CSS Designer
**Date:** 2026-10-05
**Depends on:** pick-bg (BG1 Online frequent-cancel Rep SHIPPED #89 @ `617f929c`); Soft catalog CLOSED
**Rule:** Pick **one**. §4.5 never leaks. Soft catalog stays closed. Hard-park camera off-switch Soft. Do **not** turn BG1, BF1, BE1, BD1, BC1, BB1, BA1, AZ1, AY1, AX1, AW1, AV1, AU1, AT1, AS1, AR1, AQ1, AP1, AO1, AN1, AM1, AL1, AK1, AJ1, AI1, AH1, AG1, AF1, AC1, AD1, AE1, or AA1 into a sell weight. STOP stays parked.

---

## Context (shipped)

| Pack | Result |
|------|--------|
| A–BG1 | Full loop + online fee cut + NW HUD + frequent-cancel Rep |
| Soft | Catalog CLOSED; AC1 through BG1 Soft OK MVP notes stay Soft |

**Gap:** BG1 QA note — daily ONLINE_HOLD cancel count is in-memory only (reload mid-day resets the free cancel). Camera off-switch Soft hard-parked. STOP parked.

---

## Option BH1 — Persist online cancel day-count (systems §4.4 / save) — **LEAN GO**

**Player fantasy:** Save-scumming a cancel binge does not reset the trust meter for free.

| Deliverable | Spec |
|-------------|------|
| Where | BG1 `OnlineCancelPolicy` day counter + calendar-day key |
| Persist | Save/load carries **cancel count for the current calendar day** and the **day id** those cancels belong to |
| Behavior | Same day after reload: free cancel already spent stays spent; extras still Rep −1. New calendar day after load: count resets as BG1 already does |
| Bounds | No new cancel verb. No cash fee. Listings save path stays as shipped (do not invent listing persistence beyond today's cancel counter) |
| UI | No new screen. Soft ding path unchanged |
| Config | Same BG1 fallbacks (1 free / −1) |
| Untouched | Fee ladder, ship delay, BF1 HUD, door spawn, whale weight, fog Inspect, BB1/BD1 mismatch stay as shipped |
| Soft | Catalog untouched; leave AC1 through BG1 Soft OK alone |

**Acceptance:**

1. Same day: cancel once (free), save, reload, cancel again → Rep −1 (not a second free).
2. Advance to next calendar day (or load a save already on the next day) → first cancel is free again.
3. Completed online sales never touch the counter. No screen shows `true_market` or `p_buy`.
4. Door spawn and whale weight are unchanged. Not a sell weight. Soft catalog CLOSED. No Art.

**Out:** STOP / win assert; camera off-switch; listed-band retag UI; inventing full ONLINE_HOLD listing save if still dark beyond the counter; sell-weight rewires.

**Why now:** BG1 shipped the sting; QA already flagged the mid-day reload loophole.

---

## Option BH2 — STOP / win assert polish — **PARK**

**Why park:** No new Eng systems. Close the save hole first.

---

## Option BH3 — Listed-band retag UI (BB1 Soft) — **PARK Soft**

**Why park:** Soft catalog CLOSED.

---

## Option BH4 — Display-bonus on live sell roll (AC1 Soft) — **PARK Soft**

**Why park:** Soft catalog CLOSED.

---

## Camera off-switch — **HARD PARK Soft**

**Why park (hard):** Reopens Soft catalog.

---

## Recommendation (non-binding)

**GO BH1** (Persist online cancel day-count). Park BH2/BH3/BH4. **Hard-park** the camera off-switch. Soft catalog stays closed.

---

## PM checklist

- [x] Choose **BH1** (recommended)
- [x] If BH1: Eng vs BG1 counter + day key on save/load; leave fees and door spawn alone; no Art
- [x] Sync this file to main before cloud agent
- [x] Soft catalog stays closed; STOP stays parked

---

## Decision log

| When | Decision |
|------|----------|
| 2026-10-05 | Drafted post BG1 SHIPPED #89 @ `617f929c`. Lean **BH1 Persist online cancel day-count**. STOP / Soft reopeners parked. Camera off-switch hard-parked. |
| 2026-10-05 ~1:30pm ET | **ADOPTED** BH1. Park BH2 STOP / BH3 listed-band Soft / BH4 display-bonus Soft. Camera off-switch hard-parked. Soft CLOSED. No Art. Eng bar locked; awaiting tip-freeze. |
| 2026-10-05 ~1:36pm ET | **Tip-frozen** [#90](https://github.com/adamwlarson/cardshopsimulator/pull/90) @ `5800b0c0` (branch `cursor/bh1-persist-online-cancel-day-654c`). 5 files, no docs. Cloud agent bc-86214c57 archived. Eng review that SHA against bar `b63aaca5`. QA held until APPROVE; no merge until PASS. Soft catalog CLOSED. |
