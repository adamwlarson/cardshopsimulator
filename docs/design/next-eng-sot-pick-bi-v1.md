# Next Eng SoT Pick BI v1 — post BH1

**Status:** **ADOPTED** 2026-10-05 — **BI1 ONLINE_HOLD soft cap (Rep-gated)**. Park BI2/BI3/BI4. Hard-park camera off-switch. Soft catalog CLOSED. STOP stays parked. Do not turn prior packs into a sell weight. Door spawn math stays as shipped.
**Author:** CSS Designer
**Date:** 2026-10-05
**Depends on:** pick-bh (BH1 Persist online cancel day-count SHIPPED #90 @ `04deb9e2`); Soft catalog CLOSED
**Rule:** Pick **one**. §4.5 never leaks. Soft catalog stays closed. Hard-park camera off-switch Soft. Do **not** turn BH1, BG1, BF1, BE1, BD1, BC1, BB1, BA1, AZ1, AY1, AX1, AW1, AV1, AU1, AT1, AS1, AR1, AQ1, AP1, AO1, AN1, AM1, AL1, AK1, AJ1, AI1, AH1, AG1, AF1, AC1, AD1, AE1, or AA1 into a sell weight. STOP stays parked.

---

## Context (shipped)

| Pack | Result |
|------|--------|
| A–BH1 | Full loop + online fee cut + NW HUD + frequent-cancel Rep + persist cancel day-count |
| Soft | Catalog CLOSED; AC1 through BH1 Soft OK MVP notes stay Soft |

**Gap:** Systems §2 still names ONLINE_HOLD as a **soft cap (reputation-gated)**; I1 unlocked list/cancel/fee without a concurrent-hold ceiling. Camera off-switch Soft hard-parked. STOP parked.

---

## Option BI1 — ONLINE_HOLD soft cap (Rep-gated) (systems §2 / §4.4) — **LEAN GO**

**Player fantasy:** Trust earns listing bandwidth — flood the channel only after the shop has earned it.

| Deliverable | Spec |
|-------------|------|
| Where | Create / accept path that places stock into `ONLINE_HOLD` (I1 list). Out: cancel, fill/ship complete, in-shop sales |
| Count | Cap applies to **concurrent** `ONLINE_HOLD` lots (one lot = one hold slot). Cancel or ship/fill frees a slot |
| Ladder | Rep **35–49** → **4**; Rep **50–74** → **8**; Rep **75–100** → **12**. Below Rep 35 stays locked (I1). Crossing a band mid-day raises the cap immediately; dropping below never force-cancels existing holds |
| Over cap | New list refused while `holds ≥ cap`. Soft refuse beat OK. Never shows `true_market` or `p_buy` |
| Config | Missing band caps fall back to **4 / 8 / 12**. Cap ≤ 0 treated as **1** once unlocked (never silent infinite) |
| Untouched | Fee ladder (8%/5%), ship delay, BG1/BH1 cancel rules, BF1 HUD, door spawn, whale weight, fog Inspect, BB1/BD1 mismatch stay as shipped |
| Soft | Catalog untouched; leave AC1 through BH1 Soft OK alone |

**Acceptance:**

1. At Rep 40 with 4 holds, a fifth list is refused; after one cancel or fill, a new list succeeds.
2. Same save raised to Rep 50 allows up to 8 concurrent holds without canceling the existing four. At Rep 75, cap is 12.
3. Cap never applies to in-shop stock or completed sales. No screen shows `true_market` or `p_buy`.
4. Door spawn and whale weight are unchanged. Fee ladder / cancel day rules unchanged. Not a sell weight. Soft catalog CLOSED. No Art.

**Out:** STOP / win assert; camera off-switch; listed-band retag UI; inventing multi-marketplace; sell-weight rewires.

**Why now:** Cancel sting + persist closed §4.4's trust verbs; the bible's remaining online line is the Rep-gated soft cap.

---

## Option BI2 — STOP / win assert polish — **PARK**

**Why park:** No new Eng systems. Prefer the §2 hold ceiling this pick.

---

## Option BI3 — Listed-band retag UI (BB1 Soft) — **PARK Soft**

**Why park:** Soft catalog CLOSED.

---

## Option BI4 — Display-bonus on live sell roll (AC1 Soft) — **PARK Soft**

**Why park:** Soft catalog CLOSED.

---

## Camera off-switch — **HARD PARK Soft**

**Why park (hard):** Reopens Soft catalog.

---

## Recommendation (non-binding)

**GO BI1** (ONLINE_HOLD soft cap Rep-gated). Park BI2/BI3/BI4. **Hard-park** the camera off-switch. Soft catalog stays closed.

---

## PM checklist

- [x] Choose **BI1** (recommended)
- [x] If BI1: Eng vs systems §2 soft cap — concurrent ONLINE_HOLD 4/8/12 by Rep band; leave fees and cancel rules alone; no Art
- [x] Sync this file to main before cloud agent
- [x] Soft catalog stays closed; STOP stays parked

---

## Decision log

| When | Decision |
|------|----------|
| 2026-10-05 | Drafted post BH1 SHIPPED #90 @ `04deb9e2`. Lean **BI1 ONLINE_HOLD soft cap (Rep-gated)**. STOP / Soft reopeners parked. Camera off-switch hard-parked. |
| 2026-10-05 ~1:44pm ET | **ADOPTED** BI1. Park BI2 STOP / BI3 listed-band Soft / BI4 display-bonus Soft. Camera off-switch hard-parked. Soft CLOSED. No Art. Eng bar locked; awaiting tip-freeze. |
| 2026-10-05 ~1:51pm ET | **Tip-frozen** [#91](https://github.com/adamwlarson/cardshopsimulator/pull/91) @ `2e2bc472` (branch `cursor/online-hold-soft-cap-a842`). 9 files, no docs. Cloud agent bc-a10c424f archived. Eng review that SHA against bar `942a6863`. QA held until APPROVE; no merge until PASS. Soft catalog CLOSED. |
