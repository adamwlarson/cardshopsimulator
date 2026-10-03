# Next Eng SoT Pick AF v1 — post AE1

**Status:** **AF1 SHIPPED** 2026-10-03 — merged #62 @ `3db75f4a` (reviewed `49fba1e3`). Stocker restock, 4 lots/day. QA PASS-with-notes. Soft OK MVP stays Soft. Park AF2/AF4. Hard-park AF3. Soft catalog CLOSED.  
**Author:** CSS Designer  
**Date:** 2026-10-03  
**Depends on:** pick-ae (AE1 Impulse shelf SHIPPED #61 @ `d31d6539`); Soft catalog CLOSED  
**Rule:** Pick **one**. §4.5 never leaks. Soft catalog stays closed. Hard-park camera off-switch Soft. Do **not** turn AC1/AD1/AE1 into sell-probability or live sell weights.

---

## Context (shipped)

| Pack | Result |
|------|--------|
| A–AE1 | Full loop + play table + sightline notice + case/binder/backstock ladder + impulse shelf |
| Soft | Catalog CLOSED; AC1/AD1/AE1 Soft OK MVP notes stay Soft |

**Gap:** Stocker restock loop still thin (systems §6.1). Layout levers land — nobody auto-fills the floor from backstock. Camera off-switch Soft hard-parked.

---

## Option AF1 — Stocker restock loop (systems §6.1) — **LEAN GO**

**Player fantasy:** Hire a Stocker — they haul backstock onto the floor so walk-ins actually see it, while you run the desk.

| Deliverable | Spec |
|-------------|------|
| Role | **Stocker** already hireable ($70/day) — deepen: while on duty, auto-moves eligible stock from BACKSTOCK → floor SHELF / CASE / BINDER within a daily budget |
| Budget | Thin Attention-equivalent or N moves/day (document; suggest 3–5 lots/day) |
| Priority | Prefer filling empty impulse / case slots that unlock walk-in interest (respect AD1/AE1 location rules; do not invent sell weights) |
| Fail | No Stocker on duty → no auto-restock (owner still rearranges manually) |
| Soft | Catalog untouched; leave AC1/AD1/AE1 Soft OK alone |

**Acceptance:**

1. With Stocker on duty, ≥1 backstock lot moves to a valid floor location within a seeded day when space exists.
2. Without Stocker, no auto-restock that day.
3. Does **not** change AC1 notice-only, AD1 rank-not-weight, or AE1 impulse rank into sell weights.
4. §4.5 clean; Soft catalog CLOSED; no Art.

**Out:** Sell-weight rewires; Soft camera off-switch; net-worth HUD; Specialist deepen redo.

**Why now:** Layout suite (play table / sightline / ladder / impulse) made *where* stock sits matter — Stocker is the staff lever that keeps those locations fed.

---

## Option AF2 — Net-worth HUD — **PARK**

**Why park:** Polish, not a decision bite.

---

## Option AF3 — Camera off-switch Soft — **HARD PARK Soft**

**Why park (hard):** Reopens Soft catalog.

---

## Option AF4 — STOP idle — **PARK**

**Why park:** Adam wants progress; AE1 just shipped.

---

## Recommendation (non-binding)

**GO AF1** (Stocker restock loop). Park AF2/AF4. **Hard-park AF3**. Do not reopen sell-weight Softs.

---

## PM checklist

- [x] Choose **AF1** (recommended)
- [x] If AF1: Eng vs systems §6.1 Stocker; leave AC1/AD1/AE1 Soft OK; no Art
- [x] Sync this file to main before cloud agent
- [x] Soft catalog stays closed

---

## Decision log

| When | Decision |
|------|----------|
| 2026-10-03 | Drafted post AE1 SHIPPED. Lean **AF1 Stocker restock loop**. Soft reopeners hard-parked. Sell-weight rewires parked. |
| 2026-10-03 | PM adopted **AF1**. Park AF2/AF4. Hard-park AF3. Soft catalog CLOSED. AC1/AD1/AE1 stay as shipped. |
| 2026-10-03 | **AF1 SHIPPED** #62 @ `3db75f4a` (tip `49fba1e3`). QA PASS-with-notes. Placement only, 4 lots/day. Soft OK MVP stays Soft. Soft catalog CLOSED. |
| 2026-10-03 | PM locked **AF1 GO** (Stocker restock). Park AF2/AF4. Hard-park AF3 Soft. Soft catalog CLOSED. AC1/AD1/AE1 Soft OK stays Soft. Synced main @ `58d136d6`; Eng spike `bc-f9405d05` launching. |
| 2026-10-03 | Eng APPROVE-with-notes #62 @ `49fba1e3`. Designer SoT-ok Soft MVP: hired Stocker on duty every floor open (no-show cashier-only; off-duty gate unused by day loop); empty impulse = one shelf within 2 tiles with no shelf lot; CASE is next-in-line plus slot check, not a separate empty-case scan; slabs stay backstock if case full. Cap 4 lots inside 3–5. Placement only. AC1/AD1/AE1 unchanged. Soft catalog CLOSED. QA formal cleared. |
