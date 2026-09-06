# Next Eng SoT Pick F v1 — post Option D

**Status:** Adopted — **F1 GO** (2026-09-06); park F2/F3; STOP not chosen  
**Author:** CSS Designer  
**Date:** 2026-09-06  
**Depends on:** systems §2.2 / §7.3 / §9–§10, ui-wireflows §5.1, pick-e (C3/HOLD/D shipped)  
**Rule:** Pick **one**. §4.5 never leaks. Soft `_ensure_priceable_sku` from #33 stays parked unless this spike touches it.

---

## Context (shipped)

| Pack | Result |
|------|--------|
| A / B | Attention deepen + Medium 14×10 |
| C1 / C2 / C3 | Events + hire-vs-owner + outing/shady |
| HOLD / D | Soft polish + event→PriceEditor bridge (#33) |
| Alive shop | NPC / cashier / shell / lights |

**Gap:** Tutorial-arc **required** §10 beats #4 / #6 / #8 may still be thin vs wireflows §5.1 (D covers much of #7’s PriceEditor force). Graded authenticity + Large expand + online listings still dark.

---

## Option F1 — §10 required beat closeout — **LEAN GO**

**Player fantasy:** Early-mid tough calls finish the bible arc — Spike staple, rent fire-sale, slab vs singles.

| Deliverable | Spec |
|-------------|------|
| #4 Spike staple | wireflows §5.1 — Bastion Captain / Arcbolt Adept; CustomerServe |
| #6 Rent fire-sale | PREP rent-due modal — Fire-sale sealed / Cut accessories / Payday loan (Hard: loan hidden) |
| #8 Slab vs singles | Empress slab vs two chase singles; case slot-weight pressure |
| #7 assert | Option D + existing Titan hype path — QA assert `sec10_7_titan_hype` or D-equivalent; **no duplicate spike** |

**Acceptance:**

1. #4 / #6 / #8 reachable on Normal day windows without debug; emit `beat_started` / `beat_completed`.
2. #4 resolves sell/refuse with inventory/cash/Rep update.
3. #6 three options reachable (Hard: loan disabled); choosing one closes beat.
4. #8 case capacity blocks illegal slab place; player can choose slab / singles / rotate.
5. §4.5 clean on all opens; no `cert_valid` / `true_market` leak.

**Out:** New event kinds; Large expand; full graded economy.

**Modules:** BeatInjection + `ui` + thin `inventory`/`economy`.

**Why now:** Closes the **required** §10 set after optional C3 + D; highest remaining decision clarity for playtest.

---

## Option F2 — Graded authenticity pressure

**Player fantasy:** Slab might be fake — Inspect★ / shady risk / Rep bomb.

| Deliverable | Spec |
|-------------|------|
| `cert_valid` | Shady/auction channel 8% fake-slab (systems §2.2) |
| Inspect | Attention cost; 85% reveal; sale of fail → Rep + cash hit |
| UI | Condition/cert cues stay §4.5 fog until Inspect |

**Acceptance:** seeded fake slab can fail on sale without prior Inspect; Inspect can clear fog; no raw `cert_valid` on confirm without Inspect spend.

**Why park (lean):** Needs #8 case flow feel good first — pair after F1 or fold Inspect assert into F1 #8.

---

## Option F3 — Online listings unlock (Rep 35)

**Player fantasy:** List staples online — fees vs floor bandwidth.

**Acceptance:** unlock at Rep ≥ 35; listing fee + delay; §4.5 on list confirm; can cancel listing.

**Why park:** New channel surface; weaker than finishing §10 required beats.

---

## Option STOP — Playtest / polish-only

No new Eng spike. QA runs full §10 Normal arc; Eng only fixes S2+ from playtest. Soft `_ensure_priceable_sku` may Won’t-Fix or tiny follow-up.

**Why pick:** Content pack is thick; Adam may want hands-on before more systems.  
**Why park (lean):** #4/#6/#8 still incomplete leaves playtest holes.

---

## Recommendation (non-binding)

**GO F1** (§10 #4/#6/#8 closeout + #7 assert). Park F2/F3. STOP only if Adam wants a playtest day first.

---

## PM checklist

- [x] Choose **F1** (park F2/F3/STOP)
- [x] If F1: Eng implements against ui-wireflows §5.1 (no fork)
- [x] Sync this file to main before cloud agent
- [x] Soft `_ensure_priceable_sku` stays parked unless Eng touches seed path

