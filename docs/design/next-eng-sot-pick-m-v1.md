# Next Eng SoT Pick M v1 — post L1

**Status:** Adopted **M1 GO** — Eng spike in flight `bc-243a6aaf`. **M2 Large re-smoke SHIPPED** PASS @ `83885e7dc1fafe468a9de1e7d89458851ce19dd7` (no Eng S2+). Park M3/M4. Softs parked.
**Author:** CSS Designer  
**Date:** 2026-09-06  
**Depends on:** systems §8 / §7.3, pick-l (L1 economy shipped #39; Art shell #40 on main; stub-swap in flight)  
**Rule:** Pick **one**. §4.5 never leaks. Soft seed / `_ensure_priceable_sku` / Soft far crest stay parked unless this spike touches them.

---

## Context (shipped / in flight)

| Pack | Result |
|------|--------|
| A–K2 / J1–J2 | Early-mid + online + Research + Art cues + smokes |
| L1 economy | Large gates/rent/staff/18×13/1.25× (#39) |
| L1 Art shell | #40 on main — Eng stub-swap cloud `bc-131c43f0` cooking |

**Gap:** Counterfeit scare event still thin atop G1. Soft seed / Soft far crest parked. No formal smoke with Large shell live (post stub-swap).

---

## Option M1 — Counterfeit scare event (ex-L2) — **LEAN GO**

**Player fantasy:** News flash — graded trust tanks; Inspect becomes mandatory; shady gets radioactive.

| Deliverable | Spec |
|-------------|------|
| Event | systems §8 Counterfeit scare — duration + telegraph |
| Effect | Graded trust ↓; inspect mandatory on graded path |
| Lever | Avoid shady / Inspect spend / wait out |
| Coherence | G1 fake-slab + Inspect★ still work; no raw `cert_valid` on confirms |

**Acceptance:**

1. Event can fire (seeded/formal).
2. During event: graded trust↓ + inspect mandatory path observable.
3. §4.5 clean; Softs unused.
4. Shady channel visibly worse / riskier (instrumentation OK).

**Out:** New grader brands; camera unlock (theft ring); Large re-tune.

**Modules:** `economy` (events) + thin UI telegraph. **No Art required.**

**Why now:** Large just opened late-game space; scare amp makes graded inventory feel dangerous again.

---

## Option M2 — STOP — Large shell + lease re-smoke

No new systems. QA smokes Sign→Large with live shell (post stub-swap) + rent pressure; Eng S2+ only. Soft policy reaffirm.

**Acceptance:** Written report; Sign/Wait/Stay; shell visible; Soft callout; no new verbs.

**Why park (lean):** Do after stub-swap regardless as a QA beat — can be formal without being the Eng SoT if M1 ships first. Prefer M1 for Eng queue.

---

## Option M3 — Soft seed Won’t-Fix / Soft far crest Art

Hygiene only. Soft keep-parked was K2/L1 policy — escalate only if Soft blocks demos.

**Why park (lean):** Explicit keep parked.

---

## Option M4 — STOP idle / polish backlog

No new systems. Art/Eng polish only.

**Why park (lean):** Counterfeit is the parked pressure fantasy.

---

## Recommendation (non-binding)

**GO M1** (Counterfeit scare). Park M3/M4. Run **M2 Large re-smoke** as QA after stub-swap (can be concurrent with or after M1 tip — not blocking M1 adopt).

---

## PM checklist

- [x] Choose **M1** (park M3/M4; M2 = QA beat) — PM 2026-09-06
- [x] Prefer Eng cloud after stub-swap lands — **lifted**; #41 merged @ `2afba0c2`; M1 Eng `bc-243a6aaf` launched
- [x] Sync this file to main when adopting (PM sha256 `96c39e9a…`)
- [x] Softs stay parked unless M3

---

## Decision log

| When | Decision |
|------|----------|
| 2026-09-06 | PM adopted **M1 GO** (park M3/M4). M2 Large re-smoke = QA beat after stub-swap. Softs parked. Eng holds until `bc-131c43f0` tip-freeze. |
| 2026-09-06 | Stub-swap #41 merged @ `2afba0c2`. M1 Eng spike launched `bc-243a6aaf`. M2 Large re-smoke kicked concurrent. Softs parked. |
