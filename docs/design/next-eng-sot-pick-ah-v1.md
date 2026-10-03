# Next Eng SoT Pick AH v1 — post AG1

**Status:** **AH1 ADOPTED** 2026-10-03 — Register walkouts. Spec on main @ `fbdad4e8`. Eng spike `bc-c9e88571`. Park AH2/AH4. Hard-park AH3. Soft catalog CLOSED.
**Author:** CSS Designer
**Date:** 2026-10-03
**Depends on:** pick-ag (AG1 Fire staff SHIPPED #63 @ `f4987e8d`); Soft catalog CLOSED
**Rule:** Pick **one**. §4.5 never leaks. Soft catalog stays closed. Hard-park camera off-switch Soft. Do **not** turn AG1, AF1, AC1, AD1, or AE1 into a sell weight.

---

## Context (shipped)

| Pack | Result |
|------|--------|
| A–AG1 | Full loop + layout suite + Stocker restock + Fire staff |
| Soft | Catalog CLOSED; AC1/AD1/AE1/AF1/AG1 Soft OK MVP notes stay Soft |

**Gap:** Fire stops the wage, but an empty register does not empty the line (systems §5.2). Cutting the cashier is only a one-time Rep hit. Camera off-switch Soft hard-parked.

---

## Option AH1 — Register walkouts (systems §5.2) — **LEAN GO**

**Player fantasy:** Fire the cashier to save the wage, and the people waiting at the counter leave.

| Deliverable | Spec |
|-------------|------|
| Coverage | An on-duty **Cashier**, or the **Owner** with Attention above 0, covers the register |
| Not coverage | Specialist and Stocker never cover the register |
| Walkout | A customer who needs service and finds no coverage leaves that step |
| Rep | **−1** Rep per walkout, once, capped at **−3** per day |
| Staffed | Same seeded day with a Cashier on duty → 0 walkouts from this rule |
| Fire | Unchanged. Firing the cashier only removes coverage. It does not change listed prices |
| Soft | Catalog untouched; leave AC1/AD1/AE1/AF1/AG1 Soft OK alone |

**Acceptance:**

1. Seeded day, customers waiting, no Cashier, Owner at Attention 0 → at least 1 walkout.
2. Same seed with a Cashier on duty → 0 walkouts from this rule.
3. Specialist or Stocker on duty, and nobody else covering, still walks customers out.
4. Each walkout drops Rep by 1, once, and a day cannot drop more than 3 from walkouts.
5. A completed sale still pays the listed price. AC1, AD1, AE1, AF1, and AG1 stay as shipped. §4.5 clean. Soft catalog CLOSED. No Art.

**Out:** Sell-weight rewires; play-table path patience (AB1 stays patience, not a walkout); camera off-switch; net-worth HUD; archetype rewrite.

**Why now:** Fire just made cutting the cashier a real button. §5.2 says the line should leave when nobody can ring them up.

---

## Option AH2 — Net-worth HUD — **PARK**

**Why park:** Polish, not a decision bite.

---

## Option AH3 — Camera off-switch Soft — **HARD PARK Soft**

**Why park (hard):** Reopens Soft catalog.

---

## Option AH4 — STOP idle — **PARK**

**Why park:** Adam wants progress; AG1 just shipped.

---

## Recommendation (non-binding)

**GO AH1** (Register walkouts). Park AH2/AH4. **Hard-park AH3**. Do not turn Fire or the Stocker into a sell weight.

---

## PM checklist

- [x] Choose **AH1** (recommended)
- [x] If AH1: Eng vs systems §5.2 walkouts; leave AG1 fire math alone; no Art
- [x] Sync this file to main before cloud agent
- [x] Soft catalog stays closed

---

## Decision log

| When | Decision |
|------|----------|
| 2026-10-03 | Drafted post AG1 SHIPPED #63 @ `f4987e8d`. Lean **AH1 Register walkouts**. HUD / STOP parked. Soft reopeners hard-parked. Fire and Stocker stay off the sell roll. |
| 2026-10-03 | PM adopted **AH1**. Park AH2/AH4. Hard-park AH3. Soft catalog CLOSED. Fire and Stocker stay off the sell roll. Draft sha256 `0bf9ca40`. |
| 2026-10-03 | PM locked **AH1 GO**. Synced main @ `fbdad4e8`; Eng spike `bc-c9e88571` launching. Eng/QA bar matches SoT. Holding for tip-freeze. |
| 2026-10-03 | Tip-frozen [PR #64](https://github.com/adamwlarson/cardshopsimulator/pull/64) @ `f037b379`. Eng reviews that SHA only. QA holds. |
| 2026-10-03 | Eng APPROVE-with-notes #64 @ `f037b379`. Designer SoT-ok Soft MVP: only WAITING customers walk (served stay); missing coverage hook fail-opens as covered; config ≤0 falls back to Rep 1 and cap 3; walkout at Rep 0 still spends a cap slot; tests enqueue the line, not the live spawner. Fire stays remove-only. Soft catalog CLOSED. QA formal cleared. |
