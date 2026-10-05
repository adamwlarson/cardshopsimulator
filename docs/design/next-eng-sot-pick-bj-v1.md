# Next Eng SoT Pick BJ v1 — post BI1

**Status:** **ADOPTED** 2026-10-05 — **BJ1 Persist ONLINE_HOLD listings**. Park BJ2/BJ3/BJ4. Hard-park camera off-switch. Soft catalog CLOSED. STOP stays parked. Do not turn prior packs into a sell weight. Door spawn math stays as shipped.
**Author:** CSS Designer
**Date:** 2026-10-05
**Depends on:** pick-bi (BI1 ONLINE_HOLD soft cap SHIPPED #91 @ `d018f567`); Soft catalog CLOSED
**Rule:** Pick **one**. §4.5 never leaks. Soft catalog stays closed. Hard-park camera off-switch Soft. Do **not** turn BI1, BH1, BG1, BF1, BE1, BD1, BC1, BB1, BA1, AZ1, AY1, AX1, AW1, AV1, AU1, AT1, AS1, AR1, AQ1, AP1, AO1, AN1, AM1, AL1, AK1, AJ1, AI1, AH1, AG1, AF1, AC1, AD1, AE1, or AA1 into a sell weight. STOP stays parked.

---

## Context (shipped)

| Pack | Result |
|------|--------|
| A–BI1 | Full loop + online fee/cancel/persist-day + soft cap |
| Soft | Catalog CLOSED; AC1 through BI1 Soft OK MVP notes stay Soft |

**Gap:** BG1/BH1 QA already noted ONLINE_HOLD **listings** themselves were not on the save path (BH1 only persisted the cancel day-count). Soft cap + ship delay reset on reload until holds persist. Camera off-switch Soft hard-parked. STOP parked.

---

## Option BJ1 — Persist ONLINE_HOLD listings (systems §4.4 / save) — **LEAN GO**

**Player fantasy:** Closing the shop mid-ship does not vanish your listed stock or free the soft cap for free.

| Deliverable | Spec |
|-------------|------|
| Where | Save/load of concurrent `ONLINE_HOLD` lots from I1 list path |
| Persist | Each hold carries enough to restore: stock identity, listed ask, remaining ship days (or equivalent ETA), and hold membership so BI1 soft-cap count matches post-load |
| Behavior | After reload: holds still cannot sell in-store; cancel + BG1/BH1 cancel-day rules still apply; ship/fill continues from remaining days; soft-cap slots stay occupied until cancel/fill |
| Bounds | No new list/cancel verb. No fee change. Do not invent multi-marketplace or courier minigame |
| UI | Existing list/cancel UI; no new screen. Never shows `true_market` or `p_buy` |
| Untouched | Fee ladder (8%/5%), BI1 soft-cap ladder, BG1/BH1 cancel day rules, BF1 HUD, door spawn, whale weight, fog Inspect, BB1/BD1 mismatch stay as shipped |
| Soft | Catalog untouched; leave AC1 through BI1 Soft OK alone |

**Acceptance:**

1. List N holds (under soft cap), save, reload → same N holds still ONLINE_HOLD, same asks, remaining ship days continue (not reset to a fresh 1–3 unless that was already remaining).
2. Soft-cap count after load matches pre-save; at-cap refuse still works without a free ghost slot from vanished holds.
3. Cancel after load still returns stock and still respects BG1/BH1 free/extra day rules. Completed sales never reappear as holds.
4. Door spawn and whale weight are unchanged. Not a sell weight. Soft catalog CLOSED. No Art.

**Out:** STOP / win assert; camera off-switch; listed-band retag UI; inventing listing marketplace UI; sell-weight rewires.

**Why now:** Soft cap + cancel day are live; without listing persistence both reset on reload and the online trust loop is soft.

---

## Option BJ2 — STOP / win assert polish — **PARK**

**Why park:** No new Eng systems. Close the hold save hole first.

---

## Option BJ3 — Listed-band retag UI (BB1 Soft) — **PARK Soft**

**Why park:** Soft catalog CLOSED.

---

## Option BJ4 — Display-bonus on live sell roll (AC1 Soft) — **PARK Soft**

**Why park:** Soft catalog CLOSED.

---

## Camera off-switch — **HARD PARK Soft**

**Why park (hard):** Reopens Soft catalog.

---

## Recommendation (non-binding)

**GO BJ1** (Persist ONLINE_HOLD listings). Park BJ2/BJ3/BJ4. **Hard-park** the camera off-switch. Soft catalog stays closed.

---

## PM checklist

- [x] Choose **BJ1** (recommended)
- [x] If BJ1: Eng vs save/load of concurrent ONLINE_HOLD lots (stock, ask, remaining ship days); leave fees / soft-cap / cancel-day alone; no Art
- [x] Sync this file to main before cloud agent
- [x] Soft catalog stays closed; STOP stays parked

---

## Decision log

| When | Decision |
|------|----------|
| 2026-10-05 | Drafted post BI1 SHIPPED #91 @ `d018f567`. Lean **BJ1 Persist ONLINE_HOLD listings**. STOP / Soft reopeners parked. Camera off-switch hard-parked. |
| 2026-10-05 ~2:01pm ET | **ADOPTED** BJ1. Park BJ2 STOP / BJ3 listed-band Soft / BJ4 display-bonus Soft. Camera off-switch hard-parked. Soft CLOSED. No Art. Eng bar locked; awaiting tip-freeze. |
| 2026-10-05 ~2:13pm ET | **Tip-frozen** [#92](https://github.com/adamwlarson/cardshopsimulator/pull/92) @ `71274114` (branch `cursor/bj1-persist-online-hold-listings-303c`). 5 files, no docs. Cloud agent bc-c9048320 archived. Eng review that SHA against bar `dbec78cf`. QA held until APPROVE; no merge until PASS. Soft catalog CLOSED. |
| 2026-10-05 ~2:17pm ET | **SHIPPED** — squash-merged [#92](https://github.com/adamwlarson/cardshopsimulator/pull/92) @ `47776097` (reviewed `71274114`). QA PASS harness 178/0/0. Soft CLOSED. No Art. Next pick is BK. |
