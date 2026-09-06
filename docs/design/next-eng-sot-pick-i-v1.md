# Next Eng SoT Pick I v1 — post H2

**Status:** Adopted — **I1 GO** (2026-09-06); park I2/I3/I4  
**Author:** CSS Designer  
**Date:** 2026-09-06  
**Depends on:** systems §4.4 / §4.5, pick-h (H2 shipped @ `8a7f7a73`)  
**Rule:** Pick **one**. §4.5 never leaks. Soft seed / `_ensure_priceable_sku` stay parked unless this spike touches them.

---

## Context (shipped)

| Pack | Result |
|------|--------|
| A–G1 | Attention, Medium, events, hire, outing/shady, softs, event→Price, §10 beats, graded auth |
| H2 | §10 #1–#10 Normal campaign smoke PASS; Soft keep parked |

**Gap:** Online listings (Rep ≥ 35) still dark — last major sales channel. Research/Specialist skill channel may be thin. Soft seed still parked (not Won’t-Fix). Art idle through Eng-heavy packs.

---

## Option I1 — Online listings unlock (ex-H1) — **LEAN GO**

**Player fantasy:** List staples online — fees + delay vs counter bandwidth.

| Deliverable | Spec |
|-------------|------|
| Unlock | Rep ≥ 35 (systems §4.4) |
| List | Fee **8%** + ship delay 1–3 days; item → `ONLINE_HOLD` (cannot sell in-store) |
| Cancel | Pull before fill; frequent cancels → Rep hit |
| UI | §4.5 on list confirm (no `true_market` / `p_buy`) |

**Acceptance:**

1. Locked below Rep 35; unlock at ≥ 35.
2. List holds stock + fee path; cancel before fill works.
3. Frequent-cancel Rep hit fires (instrumentation).
4. Confirm never leaks §4.5 truths; Soft seed unused.

**Out:** Multi-marketplace; shipping minigame; Large expand.

**Modules:** `economy` + `inventory` + thin list UI. **No Art required** (text/HUD OK for MVP).

**Why now:** Campaign smoke cleared the bible arc — online is the parked channel with real liquidity pressure.

---

## Option I2 — Research / Specialist skill channel deepen

**Player fantasy:** Pay Attention (+$50 Research) or keep a Specialist — comps get less noisy; rotation soft-leak.

| Deliverable | Spec |
|-------------|------|
| Research | $50 + Att cost; narrows §4.5 σ (systems §4.5) |
| Specialist | On duty = same noise narrow without Research spend |
| Rotation | Soft leak only via Research/Specialist (systems §3) |

**Acceptance:** Research disabled at Att 0; noise narrow measurable; no condition/cert reveal via Research; §4.5 clean.

**Why park (lean):** Online unlocks a whole new decision axis; Research is polish on an existing verb.

---

## Option I3 — Art lane kick (showcase / ONLINE cue)

Art-owned deliverable with thin Eng hook: showcase-case read for graded path **or** simple `ONLINE_HOLD` shelf/tag cue. Eng only wires marker if needed.

**Acceptance:** Art APPROVE + Eng ACK of marker (if any); no new economy verbs.

**Why park (lean):** Real, but not the empty Eng queue’s highest decision-pressure fill — pick if Adam wants Art moving in parallel.

---

## Option I4 — Soft seed Won’t-Fix / delete

Tiny Eng hygiene: Soft `_ensure_priceable_sku` → **Won’t-Fix** with demo note, or delete if unused. No player verbs.

**Why park (lean):** Fold later; Soft is explicitly keep-parked after H2.

---

## Recommendation (non-binding)

**GO I1** (online listings). Park I2/I4. Choose **I3** only if Adam wants Art parallel while Eng does I1 (PM can dual-track Art separately without making I3 the Eng SoT).

---

## PM checklist

- [x] Choose **I1** (park I2/I3/I4)
- [x] If I1: Eng spike vs systems §4.4; no Art required
- [x] Sync this file to main before cloud agent
- [x] Soft seeds stay parked unless I4

