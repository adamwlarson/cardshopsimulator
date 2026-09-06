# Next Eng SoT Pick L v1 — post K2

**Status:** **L1 economy SHIPPED** — PR #39 @ `f43958ae` (tip `49f0153a`); Art shell #40 on main; Eng stub-swap `bc-131c43f0` in flight. Softs parked. Park L2→pick-m M1.  
**Author:** CSS Designer  
**Date:** 2026-09-06  
**Depends on:** systems §7.3 / §8 / §9, pick-k (K2 shipped @ `b94c1f51`)  
**Rule:** Pick **one**. §4.5 never leaks. Soft seed / `_ensure_priceable_sku` stay parked unless this spike touches them.

---

## Context (shipped)

| Pack | Result |
|------|--------|
| A–J2 / H2 / K2 | Early-mid loop + online + Research + Art cues + dual campaign smokes |
| Soft | Keep parked (K2 policy) |

**Gap:** Large expand / Flagship lease still dark. Counterfeit scare event thin atop G1. Soft seed not Won’t-Fix. Soft far crest thin (Art polish).

---

## Option L1 — Large expand / lease pressure (ex-K3) — **LEAN GO**

**Player fantasy:** Sign the Large lease — more floor vs rent that can kill you. Path to Flagship win.

| Deliverable | Spec |
|-------------|------|
| Unlock | Cash ≥ $40k + Rep 70 (systems §7.3) |
| Lease | Large ~2,000 sq ft; weekly rent **$4,000**; staff cap 5 |
| Traffic | Capacity scales **sublinear** vs Medium (not 2× rent for 2× traffic) |
| Decision | Sign / wait for more cash-Rep / stay Medium |
| Art | Shell extend parallel (like Medium) — PM may dual-track Art; Eng can ship gate+economy first with fog/scaffold interim if Art lags |

**Acceptance:**

1. Gate enforced (below thresholds cannot sign).
2. Sign raises rent + capacity + staff cap; refuse keeps Medium.
3. Sublinear traffic documented/tunable in BalanceConfig.
4. §4.5 clean; Soft seed unused.

**Out:** Multi-location; franchise; play-table events.

**Modules:** `shop` + `economy` (+ Art shell if dual-tracked).

**Why now:** Re-smoke proved early-mid; Large is the next tough rent-risk decision and Flagship unlock.

---

## Option L2 — Counterfeit scare event (ex-K4)

**Player fantasy:** News flash — graded trust tanks; Inspect becomes mandatory; shady gets radioactive.

| Deliverable | Spec |
|-------------|------|
| Event | systems §8 Counterfeit scare — duration + telegraph |
| Effect | Graded trust ↓; inspect mandatory on graded path |
| Lever | Avoid shady / Inspect spend / wait out |

**Acceptance:** Event fires; trust/inspect modifiers apply; §4.5 never shows raw `cert_valid`; G1 fake-slab path still coherent.

**Why park (lean):** Pressure amp — better as a follow-up after Large opens late-game space, or as a thin parallel if Adam wants event spice first.

---

## Option L3 — Soft seed Won’t-Fix / far crest Art polish

Hygiene: Soft `_ensure_priceable_sku` → Won’t-Fix **or** Art far-crest thin on J2 badge. No new verbs.

**Why park (lean):** Explicitly keep Soft parked; crest is Art polish not Eng SoT.

---

## Option L4 — STOP — Idle polish / no systems

No new systems. Eng/Art polish backlog only; QA spot-checks. Soft stay parked.

**Why park (lean):** Queue empty for a reason — Large is the real next fantasy.

---

## Recommendation (non-binding)

**GO L1** (Large expand). Park L3/L4. Dual-track Art shell with Eng economy gates if possible. Choose **L2** only if Adam wants event pressure before square footage.

---

## PM checklist

- [x] Choose **L1** (park L2/L3/L4) — PM 2026-09-06 @ `f28a1078`
- [x] If L1: Eng gates+rent first; Art shell dual-track invited — Eng spike launching
- [x] Sync this file to main before cloud agent @ `f28a1078`
- [x] Soft seeds stay parked unless L3 Soft path

---

## Decision log

| When | Decision |
|------|----------|
| 2026-09-06 | PM adopted **L1 GO** (park L2/L3/L4). Synced main @ `f28a1078`. Eng Large gates+rent spike launching. Soft seeds parked. Art shell dual-track invited. |
| 2026-09-06 | **L1 economy SHIPPED** #39 @ `f43958ae`. Art #40 on main. Eng stub-swap `bc-131c43f0` launched. Softs parked. Queue → pick-m. |
