# Next Eng SoT Pick H v1 — post G1

**Status:** Adopted — **H2 GO** (2026-09-06); park H1/H3; STOP §10 Normal campaign smoke  
**Author:** CSS Designer  
**Date:** 2026-09-06  
**Depends on:** systems §4.4 / §4.5 / §10, pick-g (G1 shipped #35)  
**Rule:** Pick **one**. §4.5 never leaks. Soft seed / `_ensure_priceable_sku` stay parked unless this spike touches them.

---

## Context (shipped)

| Pack | Result |
|------|--------|
| A–B / C1–C3 / HOLD / D / F1 | Attention, Medium, events, hire, outing/shady, softs, event→Price, §10 #4/#6/#8 |
| G1 | Graded authenticity / `cert_valid` fake-slab (#35) |
| Alive shop | NPC / cashier / shell / lights |

**Gap:** Online listings (Rep ≥ 35) still dark; full §10 Normal **campaign smoke** never run as a formal stop; Soft empty-SKU seeds still parked (not Won’t-Fix).

---

## Option H1 — Online listings unlock (ex-G2)

**Player fantasy:** List staples online — fees + delay vs counter bandwidth.

| Deliverable | Spec |
|-------------|------|
| Unlock | Rep ≥ 35 (systems §4.4) |
| List | Fee **8%** + ship delay 1–3 days; item → `ONLINE_HOLD` (no in-store sale) |
| Cancel | Pull before fill; frequent cancels → Rep hit |
| UI | §4.5 on list confirm (no `true_market` / `p_buy`) |

**Acceptance:**

1. Locked below Rep 35; unlock at ≥ 35.
2. List deducts fee path / holds stock; cancel before fill works.
3. Frequent-cancel Rep hit fires (instrumentation).
4. Confirm never leaks §4.5 truths.

**Out:** Multi-marketplace; shipping minigame; Large expand.

**Modules:** `economy` + `inventory` + thin list UI.

**Why park (lean):** New channel UI before we’ve smoked the bible arc end-to-end.

---

## Option H2 — STOP — Full §10 Normal playtest — **LEAN GO**

No new systems spike. QA runs required + optional §10 arc on Normal (days 1→~30 reachability); Eng only **S2+** fixes from the report. Soft seeds may become Won’t-Fix if they only paper over empty-SKU demos.

**Acceptance:**

1. Written playtest report covering #1–#10 reachability (pass/fail per beat).
2. Blockers filed with severity; no new verbs in this pick.
3. Soft seed policy called: keep parked / Won’t-Fix / tiny follow-up.

**Why now:** G1 closed the last high-pressure authenticity hole; content pack is thick — campaign smoke before another channel.

---

## Option H3 — Soft seed policy closeout (thin)

Tiny Eng-only: decide Soft `_ensure_priceable_sku` / empty-SKU inject — **Won’t-Fix** with demo note, or delete paths if unused. No new player verbs.

**Acceptance:** Eng ACK + one-line design log; QA smoke that PriceEditor / G1 paths still seed without the Soft (or document demo-only need).

**Why park (lean):** Not a player fantasy; fold into H2 report notes unless Soft is blocking demos.

---

## Recommendation (non-binding)

**GO H2** (STOP §10 Normal campaign smoke). Park H1 online until after playtest findings. Park H3 unless Soft is actively blocking.

Choose **H1** only if Adam wants the online channel before hands-on. Choose **H3** only as a same-day hygiene if Soft is noisy.

---

## PM checklist

- [x] Choose **H2** (park H1/H3)
- [x] If H2: QA owns playtest plan; Eng on standby for S2+
- [x] Sync this file to main before formal playtest kick
- [x] Soft seeds stay parked unless H3 chosen

