# Next Eng SoT Pick C v1 — post A+B decision pressure

**Status:** Adopted — **C1 Market events pack shipped #26** @ `dd713c26` (QA PASS @ `8ccdcbfd`); Specialist Att-discount shipped #24; Medium shell #25; Medium lights densify #27 in review; C2/C3 parked  
**Author:** CSS Designer  
**Date:** 2026-09-04  
**Depends on:** systems §6 / §8 / §10, ui-wireflows §5.1, customer-npc-v1, next-eng-sot-pick-v1 (A+B shipped)  
**Rule:** Pick **one** spike. Other parks. Same systems; falsifiable acceptance; §4.5 fog never leaks.

---

## Context (shipped)

| Spike | Result |
|-------|--------|
| A — Deepen Attention | Shipped #19 — Research + layout Att costs |
| B — Medium floor growth | Shipped #21 — Sign→**14×10** + stub shell |
| NPC / anim / cashier | Shipped #20/#22/#23 — floor presence + hire-gated cashier mesh |

**Shipped (do not re-spec):** Specialist Att-discount #24 — closes Option A Inspect★ stub: `research_attention_specialist = 10`, `inspect_attention_specialist = 2`. Medium hero shell #25 (hide stub, 14×10, fog nack).

**Shipped (do not re-spec):** C1 Market events #26 — hype / soft rotation leak / fog day; Titan #7 from pack; EventBanner; save/load.

**Gap:** Hire vs owner bandwidth (C2) and optional §10 beats (C3) still parked; day-to-day event pressure now live.

---

## Option C1 — Market events pack (decision pressure)

**Player fantasy:** The market moves under you — hold through hype, dump before rotation, or eat fog.

| Deliverable | Spec |
|-------------|------|
| Event bus | At least **3** SETTLE/PREP-rolled events from systems §8: **Hype spike** (one SKU/set HOT 1–3 days), **Soft rotation leak** (Research/Specialist foreshadow), **Fog day** (σ widened; still no Cold↔Hot inversion without fog flag) |
| UI | Thin banner + PriceEditor / BuyOpportunity chips already §4.5-legal; no new screens |
| §10 bridge | Event #7 Titan hype can fire from this pack (wireflows §5.1) |
| BalanceConfig | `event_rate_*` already on difficulty-curves — wire rates, don’t invent parallel knobs |

**Acceptance:**

1. On Normal, ≥1 non-null event in a 7-day seeded run (instrumentation).
2. Hype elevates band/comps for target SKU only; §4.5 forbidden fields stay hidden.
3. Fog day widens σ; without fog flag, Cold↔Hot inversion never shown.
4. Save/load restores active event + remaining days.

**Out:** Full news ticker narrative; multi-SKU correlation matrix; player-authored events.

**Modules:** `economy` (events) + thin `ui` + existing DemandSignal.

**Why:** Highest decision-pressure per eng hour; uses bible §8 already written.

---

## Option C2 — Hire vs owner bandwidth (staff pressure)

**Player fantasy:** Cashier buys time; Specialist buys accuracy; solo burns Attention — wages vs survival.

| Deliverable | Spec |
|-------------|------|
| §10 #5 | Hire-first-cashier beat fully live (wireflows §5.1) — Hire / Keep solo / cheap unreliable |
| Reliability | Hired cashier `Reliability` 0–1; low → rare no-show (FLOOR understaffed) or shrink tick bias (systems §6.3) |
| Owner gate | At Att 0: owner blocked on Research/Inspect/Negotiate/Pull; cashier still routine-sells (already rule — assert in QA) |
| Specialist | **Depends on in-flight Att-discount merge** — on-duty applies `research_attention_specialist` / `inspect_attention_specialist`; no duplicate spike |
| Cashier mesh | Already shipped #23 — wire hire gate only if not already hire-gated in domain |

**Acceptance:**

1. Day~5 beat offers Hire / Solo / Unreliable; Hire adds wage + staff_cap use; Solo leaves roster empty.
2. Unreliable path can no-show ≥1 time in a 10-day seeded stress (or shrink ↑) without soft-lock.
3. Att 0: owner verbs disabled; routine sales still resolve with cashier on duty.
4. Specialist on duty changes Inspect/Research Att to 2 / 10 (post in-flight merge).

**Out:** New staff roles; dialogue trees; full HR sim.

**Modules:** `customers`/`shop` staff + `economy` wages + thin hire modal `ui`.

**Why:** Makes #5 and cashier silhouette pay rent as a real choice axis.

---

## Option C3 — Optional §10 pressure beats (#3 outing / #10 shady)

**Player fantasy:** Leave the floor for a “steal,” or take a shady trunk — risk vs cash.

| Deliverable | Spec |
|-------------|------|
| #3 Marketplace outing | Drive (Att 25 + miss FLOOR hours) / Courier fee / Skip — wireflows §5.1 |
| #10 Shady trunk | Buy / Report / Walk — Rep/cash forks; no `cert_valid` reveal without Inspect |
| Shared | Both use existing BuyOpportunityDetail + §4.5; BeatInjection only |

**Acceptance:**

1. Both beats reachable on Normal day windows without debug.
2. Drive outing reduces Attention + shortens FLOOR that day; Courier keeps FLOOR.
3. Shady paths never leak true condition / `cert_valid` on confirm screen.
4. Report path applies Rep delta from BalanceConfig (or Normal default).

**Out:** Full off-site 3D scenes; combat; lip sync.

**Modules:** BeatInjection + `ui` + light `economy` Rep/cash.

**Why:** Content pressure without new simulation systems — good if events/staff eng is busy.

---

## Recommendation (non-binding)

**Prefer C1** if Adam wants the shop to *feel* like a living market next.  
**Prefer C2** if hire-vs-solo should hurt before more events (cashier mesh already live).  
**Prefer C3** if Eng bandwidth is thin — beat hooks only.

Specialist Att-discount stays **out of pick** (already in flight).

---

## Decision log

| Pick | Result |
|------|--------|
| C1 Market events | **In flight** — Eng spike launched (hype / soft rotation / fog per Option C1) |
| C2 Hire vs owner | Parked |
| C3 Optional #3/#10 | Parked |
| Specialist Att-discount | **Shipped** #24 (`research_attention_specialist` 10 / `inspect_attention_specialist` 2) |
| Medium shell swap | **Shipped** #25 |

---

## PM checklist

- [x] Choose **C1** / **C2** / **C3** → **C1**
- [x] Sync this file to main (@ 735a9f53)
- [x] Losers park (C2/C3)
- [x] Sync Adopted status bump to main
- [x] Specialist Att-discount shipped (#24)
- [x] Eng C1 spike launched
- [ ] Sync this in-flight status bump to main
- [ ] C1 tip-freeze → Eng → QA → merge

