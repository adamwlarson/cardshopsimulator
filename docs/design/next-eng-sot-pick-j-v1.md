# Next Eng SoT Pick J v1 — post I1

**Status:** Adopted — **J1 shipped #37** @ `8bd03a47`; **J2 Art shipped #38** @ `2bfa0efd` (2026-09-06); park J3/J4
**Author:** CSS Designer  
**Date:** 2026-09-06  
**Depends on:** systems §3 / §4.5 / §6.2, pick-i (I1 shipped #36)  
**Rule:** Pick **one**. §4.5 never leaks. Soft seed / `_ensure_priceable_sku` stay parked unless this spike touches them.

---

## Context (shipped)

| Pack | Result |
|------|--------|
| A–G1 / H2 | Core loops, §10 beats + campaign smoke, graded auth |
| I1 | Online listings Rep ≥ 35 / 8% / `ONLINE_HOLD` (#36) |

**Gap:** Research/Specialist skill channel may still be thin vs §4.5 fairness contract. Soft seed parked. Art idle through Eng-heavy packs. Online not yet in a formal re-smoke.

---

## Option J1 — Research / Specialist skill deepen (ex-I2) — **LEAN GO**

**Player fantasy:** Spend cash+Attention on Research (or keep a Specialist) — comps tighten, rotation soft-leaks. Skill beats raw FOMO.

| Deliverable | Spec |
|-------------|------|
| Research | $50 + Att cost (systems §4.5 / §6.2); disabled at Att 0 |
| Noise narrow | Comp width ×0.55; demand σ 0.12→0.07 while buff active |
| Specialist | On duty = same narrow without Research spend |
| Rotation | Soft telegraph only via Research/Specialist ("Rotation watch: {set}" 24–72h) |
| Hard walls | Research never reveals condition / `cert_valid` / `true_market` / `p_buy` |

**Acceptance:**

1. Att 0 blocks Research; Att ≥ cost + $50 succeeds.
2. Post-Research (or Specialist on duty) buy/price confirms show narrower comps / tighter bands (instrumentation).
3. Rotation soft-leak appears only with Research buff or Specialist.
4. Condition / cert / truth never leak via Research; §4.5 clean on online + counter confirms.

**Out:** Perfect charts; multi-set Research; Large expand.

**Modules:** `economy` + `ui` (existing Research verb) + thin Specialist hook. **No Art.**

**Why now:** Online just added another fogged confirm path — skill channel makes imperfect info *fair*, not cruel.

---

## Option J2 — Art lane kick (ex-I3)

Art-owned: showcase-case read for graded path **and/or** simple `ONLINE_HOLD` shelf/tag cue. Thin Eng marker wire only.

**Acceptance:** Art APPROVE + Eng ACK of marker (if any); no new economy verbs.

**Why park (lean):** Real — Art has been idle — but PM can dual-track Art without making this the Eng SoT. Prefer J1 for Eng queue.

---

## Option J3 — Soft seed Won’t-Fix / delete (ex-I4)

Tiny Eng hygiene: Soft `_ensure_priceable_sku` → **Won’t-Fix** with demo note, or delete if unused.

**Why park (lean):** Still “keep parked” after H2/I1; not player fantasy.

---

## Option J4 — STOP — Online + §10 polish re-smoke

No new systems. QA re-smokes §10 Normal **with** online listings in play (list/cancel mid-arc); Eng S2+ only. Soft policy reaffirm.

**Acceptance:** Written report; online list/cancel exercised; blockers filed; no new verbs.

**Why park (lean):** Fresh channel deserves skill-channel closeout first; re-smoke after J1 is richer.

---

## Recommendation (non-binding)

**GO J1** (Research/Specialist deepen). Park J3. Dual-track **J2 Art** separately if Adam wants Art moving. Choose **J4** only if hands-on day before more systems.

---

## PM checklist

- [x] Choose **J1** (park J2/J3/J4) — PM 2026-09-06 @ `b4afce4a`
- [x] If J1: Eng vs systems §4.5 Research table; no Art — Eng spike launching
- [x] Sync this file to main before cloud agent @ `b4afce4a`
- [x] Soft seeds stay parked unless J3

---

## Decision log

| When | Decision |
|------|----------|
| 2026-09-06 | PM adopted **J1 GO** (park J2/J3/J4). Synced main @ `b4afce4a`. Eng Research/Specialist spike launching. Soft seeds parked. No Art. |
| 2026-09-06 | **J2 Art dual-track** (not Eng SoT): showcase graded read + `ONLINE_HOLD` cue parallel with J1. Soft parked. No J1 drift. |
| 2026-09-06 | **J1 shipped #37** merged @ `8bd03a47`. Softs parked. J2 Art #38 still in flight — next Eng SoT holds until J2 merges. Queue → pick-k. |
