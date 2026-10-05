# Next Eng SoT Pick BF v1 — post BE1

**Status:** **BF1 SHIPPED** 2026-10-05 — squash-merged #88 @ `08947d2c` (reviewed `6f59c603`). QA PASS harness 176/0/0. Soft OK Eng notes not failed. Soft catalog CLOSED. No Art. Net-worth HUD (AA1 formula, all modes).
**Author:** CSS Designer
**Date:** 2026-10-05
**Depends on:** pick-be (BE1 Online fee cut SHIPPED #87 @ `a6a0bb3f`); Soft catalog CLOSED
**Rule:** Pick **one**. §4.5 never leaks. Soft catalog stays closed. Hard-park camera off-switch Soft. Do **not** turn BE1, BD1, BC1, BB1, BA1, AZ1, AY1, AX1, AW1, AV1, AU1, AT1, AS1, AR1, AQ1, AP1, AO1, AN1, AM1, AL1, AK1, AJ1, AI1, AH1, AG1, AF1, AC1, AD1, AE1, or AA1 into a sell weight. STOP stays parked.

---

## Context (shipped)

| Pack | Result |
|------|--------|
| A–BE1 | Full loop + fog Inspect/mismatch + §5.3 fee cut at Rep ≥ 75 |
| Soft | Catalog CLOSED; AC1 through BE1 Soft OK MVP notes stay Soft |

**Gap:** Live net worth is Sandbox high-water only (AA1). Campaign modes still lack a HUD read of the same formula. Camera off-switch Soft hard-parked. STOP parked.

---

## Option BF1 — Net-worth HUD (systems §9 / economy) — **LEAN GO**

**Player fantasy:** See how rich the shop is right now — cash plus stock haircut — without opening a spreadsheet.

| Deliverable | Spec |
|-------------|------|
| Where | Persistent HUD (or always-visible status chip) in **all** modes: Flagship / Survive Y1 / Liquidity / Sandbox |
| Formula | Reuse AA1: `cash + inventory at true_market × liquidity haircut` (sealed **0.85**, singles **0.70**, graded **0.60**, accessories **0.90**). Missing haircut keys fall back to those defaults |
| Refresh | Updates on cash or inventory settle (buy, sale, fee, refund, list/cancel ONLINE_HOLD). Not a per-frame poll inventing new economy ticks |
| UI | Shows one currency number (net worth). Never shows raw `true_market`, per-SKU basis, haircut table, or `p_buy` |
| Sandbox | AA1 peak high-water stays; HUD live value can sit beside it without replacing the peak |
| Untouched | Fee ladder (8%/5%), door spawn, whale weight, fog Inspect, BB1/BD1 mismatch, win awards stay as shipped |
| Soft | Catalog untouched; leave AC1 through BE1 Soft OK alone |

**Acceptance:**

1. Same seed: after a cash sale, HUD net worth rises by the cash delta plus any inventory haircut change; after buying stock, cash down and inventory haircut up are both reflected.
2. HUD number matches the AA1 formula for the same save (within rounding). No screen shows raw `true_market`.
3. Flagship / Survive Y1 / Liquidity / Sandbox win or PB rules unchanged. Sandbox peak still records high water.
4. Door spawn and whale weight are unchanged. Not a sell weight. Soft catalog CLOSED. No Art.

**Out:** STOP / win assert; camera off-switch; listed-band retag UI; leaderboards; sell-weight rewires.

**Why now:** Economy loop + fee cut are live. Players need the AA1 wealth read outside Sandbox highs.

---

## Option BF2 — STOP / win assert polish — **PARK**

**Why park:** No new systems. Prefer the HUD decision bite this pick.

---

## Option BF3 — Online frequent-cancel Rep polish — **PARK**

**Why park:** I1 already named the hit. Re-verify only if QA finds it dark; not the lean GO now.

---

## Option BF4 — Listed-band retag UI (BB1 Soft) — **PARK Soft**

**Why park:** Soft catalog CLOSED.

---

## Camera off-switch — **HARD PARK Soft**

**Why park (hard):** Reopens Soft catalog.

---

## Recommendation (non-binding)

**GO BF1** (Net-worth HUD). Park BF2/BF3/BF4. **Hard-park** the camera off-switch. Soft catalog stays closed.

---

## PM checklist

- [x] Choose **BF1** (recommended)
- [x] If BF1: Eng vs AA1 NW formula on HUD for all modes; §4.5 never shows raw `true_market`; no Art
- [x] Sync this file to main before cloud agent @ `cd55fceb`
- [x] Soft catalog stays closed; STOP stays parked

---

## Decision log

| When | Decision |
|------|----------|
| 2026-10-05 | Drafted post BE1 SHIPPED #87 @ `a6a0bb3f`. Lean **BF1 Net-worth HUD** (AA1 formula, all modes). STOP / online-cancel polish / listed-band Soft parked. Camera off-switch hard-parked. |
| 2026-10-05 | PM adopted **BF1 GO** Net-worth HUD (AA1 formula, all modes). Park BF2 STOP / BF3 online-cancel polish / BF4 listed-band Soft. Hard-park camera off-switch. Soft catalog CLOSED. No Art. |
| 2026-10-05 ~1:06pm ET | **Tip-frozen** [#88](https://github.com/adamwlarson/cardshopsimulator/pull/88) @ `6f59c603` (branch `cursor/bf1-net-worth-hud-b517`). 6 files, no docs. Cloud agent bc-30e6c712 archived. Eng review that SHA against bar `a0e1efb8`. QA held until APPROVE; no merge until PASS. Soft catalog CLOSED. |
| 2026-10-05 ~1:12pm ET | **SHIPPED** — squash-merged [#88](https://github.com/adamwlarson/cardshopsimulator/pull/88) @ `08947d2c` (reviewed `6f59c603`). QA PASS harness 176/0/0. Soft OK Eng notes not failed. Soft catalog CLOSED. No Art. Branch `cursor/bf1-net-worth-hud-b517` deleted. |
