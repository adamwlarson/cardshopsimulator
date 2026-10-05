# Next Eng SoT Pick AZ v1 — post AY1

**Status:** **AZ1 SHIPPED** 2026-10-05 — squash-merged #82 @ `81657192` (reviewed `ad1d96d3`). Specialist inspect discount. Park AZ2/AZ3/AZ4. Hard-park camera off-switch. Soft catalog CLOSED. Fees, net-worth HUD, and STOP stay parked. Do not turn rep bands, trades, shrink, walkouts, Fire, AU1 haggle, AV1 Negotiate, AW1 buylist, AX1 Change, or AY1 Inspect into a sell weight. Door spawn math stays as shipped.
**Author:** CSS Designer
**Date:** 2026-10-05
**Depends on:** pick-ay (AY1 Buylist Inspect SHIPPED #81 @ `717047f9`); Soft catalog CLOSED
**Rule:** Pick **one**. §4.5 never leaks. Soft catalog stays closed. Hard-park camera off-switch Soft. Do **not** turn AY1, AX1, AW1, AV1, AU1, AT1, AS1, AR1, AQ1, AP1, AO1, AN1, AM1, AL1, AK1, AJ1, AI1, AH1, AG1, AF1, AC1, AD1, or AE1 into a sell weight. Fees / HUD / STOP stay parked.

---

## Context (shipped)

| Pack | Result |
|------|--------|
| A–AY1 | Full loop + buylist You offer / Change / Inspect @ 5 Att |
| Soft | Catalog CLOSED; AC1 through AY1 Soft OK MVP notes stay Soft |

**Gap:** Specialist inspect discount (systems §6.2: 5→2) still dark. Fee cut stays parked. Camera off-switch Soft hard-parked. Fees / HUD / STOP parked by PM.

---

## Option AZ1 — Specialist inspect discount (systems §6.2) — **LEAN GO**

**Player fantasy:** With a Specialist on duty, peeking condition on a buylist walk-in is cheaper — you keep more Attention for the floor.

| Deliverable | Spec |
|-------------|------|
| Where | AY1 buylist `CustomerServe` Inspect only. Out: shop-buy Negotiate Att, Research Att, marketplace/shady Inspect rewires |
| Cost | Owner Inspect is **5** Att with no Specialist on duty (AY1 as shipped). With a **Specialist on duty**, Inspect costs **2** Att |
| Gate | Paid when taken. At Att < cost: refused, Att unchanged, shot stays. Cashier still cannot Inspect |
| Reveal | Unchanged from AY1: 85% true / 15% adjacent miss; never NM↔DMG leap; UI band only; never `true_market` / `cert_valid` |
| Duty | "On duty" = Specialist hired and present for today's open floor (same duty flag staff already use). Missing duty flag → cost stays 5 |
| Bounds | One Inspect per serve still. Buy / Walk / Change stay as shipped |
| Config | Missing Specialist discount falls back to cost 2 when on duty. Missing owner cost falls back to 5 |
| Untouched | Fee stays 8%. Buyer door spawn, whale weight, AY1 accuracy, AX1 Change, AV1 Negotiate stay as shipped |
| Soft | Catalog untouched; leave AC1 through AY1 Soft OK alone |

**Acceptance:**

1. Same buylist serve, no Specialist on duty: Inspect still costs 5 Att. With Specialist on duty: Inspect costs 2 Att. At Att below the active cost the step is refused and Att stays.
2. Reveal math stays AY1 (85/15 adjacent). Cashier cannot Inspect. Second Inspect refused.
3. Buy / Walk / Change and anger floor stay as shipped. No screen shows `true_market` or `cert_valid`.
4. Buyer door spawn and whale weight are unchanged. Marketplace fee stays 8%. Not a sell weight. Soft catalog CLOSED. No Art.

**Out:** A fee cut; net-worth HUD; STOP; camera off-switch; marketplace/shady Inspect; sell-side uninspected NM mismatch; sell-weight rewires.

**Why now:** AY1 locked owner Inspect at 5. §6.2 already prices the Specialist discount on that verb.

---

## Option AZ2 — Marketplace fee cut at Rep ≥ 75 — **PARK**

**Why park:** PM parked fee cuts unless Design leans one. Not leaning — the 8% stays.

---

## Option AZ3 — Net-worth HUD / STOP — **PARK**

**Why park:** PM parked both unless Design leans one. Not leaning this pick.

---

## Option AZ4 — Marketplace / shady Inspect fog — **PARK**

**Why park:** Real §4.5 line. Specialist discount is the open AY1 follow. Channel Inspect can follow.

---

## Camera off-switch — **HARD PARK Soft**

**Why park (hard):** Reopens Soft catalog.

---

## Recommendation (non-binding)

**GO AZ1** (Specialist inspect discount 5→2). Park AZ2/AZ3/AZ4. **Hard-park** the camera off-switch. Soft catalog stays closed.

---

## PM checklist

- [x] Choose **AZ1** (recommended)
- [x] If AZ1: Eng vs systems §6.2 Specialist on-duty Inspect cost 2; leave fees and buyer door spawn alone; no Art
- [x] Sync this file to main before cloud agent
- [x] Soft catalog stays closed; fees / HUD / STOP stay parked

---

## Decision log

| When | Decision |
|------|----------|
| 2026-10-05 | Drafted post AY1 SHIPPED #81 @ `717047f9`. Lean **AZ1 Specialist inspect discount**. Fee cut / HUD / STOP / marketplace Inspect parked. Camera off-switch hard-parked. |
| 2026-10-05 | PM adopted **AZ1**. Park AZ2/AZ3/AZ4. Hard-park camera off-switch. Soft catalog CLOSED. Buylist Inspect costs 2 Att with Specialist on duty (else 5). Draft sha256 `4079dfef`. |
| 2026-10-05 | PM adopted **AZ1**. Spec on main `b77c064a`. Spike [AZ1 Specialist inspect discount](https://cursor.com/agents/bc-ce59b862-d9b8-592a-81c5-74a5fac5bb7f). Park AZ2/AZ3/AZ4. No Art. Soft catalog CLOSED. Draft sha256 `4079dfef`. |
| 2026-10-05 | Eng bar locked AZ1 against `b77c064a`. Specialist on-duty Inspect 2 Att; else 5. Awaiting tip-freeze. |
| 2026-10-05 | PM tip-froze PR #82 @ `ad1d96d3`. Ready. 4 files, no docs. Agent archived. |
| 2026-10-05 | Eng **APPROVE**-with-notes AZ1 [PR #82](https://github.com/adamwlarson/cardshopsimulator/pull/82) @ `ad1d96d3`. Soft: HUD gate mirror; empty roster → shop duty-flag fallback. Soft OK MVP. QA cleared by PM. |
| 2026-10-05 | PM SHIPPED **AZ1**. Squash-merged #82 @ `81657192` (reviewed `ad1d96d3`). QA PASS, harness 159/0/0. Soft OK Eng notes not failed. Soft catalog CLOSED. Branch `cursor/az1-specialist-inspect-discount-bb7f` deleted. |
