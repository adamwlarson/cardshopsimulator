# Next Eng SoT Pick G v1 — post F1

**Status:** Adopted — **G1 shipped #35** @ `8a7f7a73` (2026-09-06); park G2; G3 STOP not chosen  
**Author:** CSS Designer  
**Date:** 2026-09-06  
**Depends on:** systems §2.2 / §4.5 / §3 (online), ui-wireflows Inspect★, pick-f (F1 shipped #34)  
**Rule:** Pick **one**. §4.5 never leaks. Soft seed / `_ensure_priceable_sku` stay parked unless this spike touches them.

---

## Context (shipped)

| Pack | Result |
|------|--------|
| A–B / C1–C3 / HOLD / D | Attention, Medium, events, hire, outing/shady, softs, event→Price |
| F1 | §10 #4/#6/#8 + #7 assert (#34) |
| Alive shop | NPC / cashier / shell / lights |

**Gap:** Graded `cert_valid` / fake-slab risk still thin; online listings (Rep 35) dark; full §10 Normal playtest not yet a formal “campaign smoke.”

---

## Option G1 — Graded authenticity pressure (ex-F2) — **LEAN GO**

**Player fantasy:** That Prism 10 might be fake — Inspect★ or eat the Rep bomb.

| Deliverable | Spec |
|-------------|------|
| `cert_valid` | Shady/auction (and trunk if present) **8%** fake-slab (systems §2.2) |
| Inspect★ | Existing Attention cost; ~85% reveal true cert; updates condition/cert cue only |
| Sale fail | Selling fail-slab without clear Inspect → Rep + cash hit (bible) |
| UI | No raw `cert_valid` / true condition on confirm without Inspect spend (§4.5) |

**Acceptance:**

1. Seeded fake slab can sell-fail without prior Inspect (instrumentation).
2. Inspect spend can clear cert fog for that instance (not comps).
3. Confirm screens never show raw `cert_valid` without Inspect.
4. Empress / graded path from #8 still works; §4.5 clean.

**Out:** New grader brands; lab mini-game; Large expand.

**Modules:** `inventory` + `economy` + Inspect UI (exists) + thin shady seed.

**Why now:** #8 just taught case slots — authenticity makes slabs *scary*, not wallpaper.

---

## Option G2 — Online listings unlock (ex-F3)

**Player fantasy:** List staples online — fees + delay vs counter bandwidth.

| Deliverable | Spec |
|-------------|------|
| Unlock | Rep ≥ 35 (systems §4.4) |
| List | Fee + ship delay; §4.5 on list confirm |
| Cancel | Can pull listing before fill |

**Acceptance:** locked below Rep 35; unlock lists with fee; cancel works; no truth leak on confirm.

**Why park (lean):** New channel UI; less decision-pressure per eng hour than fake slabs after #8.

---

## Option G3 — STOP — Full §10 Normal playtest

No new systems spike. QA runs required+optional §10 arc on Normal; Eng only S2+ fixes. Soft seeds may Won’t-Fix.

**Acceptance:** written playtest report covering #1–#10 reachability; blockers filed; no new verbs.

**Why pick:** Content pack is thick — Adam may want hands-on before more systems.  
**Why park (lean):** Fake-slab hole remains if we never ship G1.

---

## Recommendation (non-binding)

**GO G1** (graded authenticity). Park G2. Choose **G3 STOP** only if Adam wants a playtest day first.

---

## PM checklist

- [x] Choose **G1** (park G2/G3) — PM 2026-09-06 @ `c9cc3b4b`
- [x] If G1: Eng vs systems §2.2 + existing Inspect★ (no new screen) — Eng spike launching
- [x] Sync this file to main before cloud agent @ `c9cc3b4b`
- [x] Soft seeds stay parked

---

## Decision log

| When | Decision |
|------|----------|
| 2026-09-06 | PM adopted **G1 GO** (park G2/G3). Synced main @ `c9cc3b4b`. Eng graded-authenticity / fake-slab spike launching. Soft seeds parked. |
