# Customer NPC v1 — 3D floor presence SoT

**Status:** Adopted — shipped main @ d069216e (PR #20); soft Art icon notes parked  
**Author:** CSS Designer  
**Date:** 2026-09-04  
**Adam priority:** Amp 3D presence + customer characters  
**Depends on:** systems §5 (archetypes), ui-wireflows §3 (CustomerServe / buylist labels), shop grid pathing, Attention/cashier rules  
**Invariant:** §4.5 forbidden fields never appear on overhead icons or thin desk HUD.

---

## 0. Goals (falsifiable)

1. On FLOOR, ≥1 customer NPC is visible walking/browsing (not HUD-only) whenever the queue is non-empty.
2. Player can read intent (browse / buy / sell) from **overhead icon only** at counter distance — no text dump of wants/price.
3. Desk interaction opens **thin counter HUD** only when NPC is in the counter interact volume; closing HUD does not despawn NPC until exit.
4. Buy and sell (buylist) both resolve through existing domain; cashiers/Attention rules unchanged.

---

## 1. Loop (per customer instance)

```
SPAWN (entrance tile)
  → BROWSE (wander displays / binder / sealed wall / play table if placed)
  → QUEUE / APPROACH counter
  → RESOLVE (buy from shop OR sell to shop)
  → EXIT (entrance) → despawn
```

| State | Behavior | Player affordance |
|-------|----------|-------------------|
| Spawn | Appear at entrance; pick archetype weight from systems §5 | None |
| Browse | Path to 1–3 browse points; dwell 2–6s each; patience ticks slow | Optional: none (MVP) |
| Approach | Join counter queue / path to desk slot | Highlight when next |
| Resolve | At desk volume → thin HUD | Open serve / buylist |
| Exit | Path to entrance; fade/despawn | None |

**Fail:** Teleport to counter; stuck with no path; resolve without desk volume.

---

## 2. Intent icons (overhead)

| Intent | Icon (MVP) | When |
|--------|------------|------|
| Browse | Magnifier / eyes | Browse state |
| Buy | Shopping bag / card+ | Approach + Resolve when wanting to purchase |
| Sell | Cash / tag-out | Approach + Resolve when buylist seller |

**Rules:**

- Icon only — **no** SKU name, price, or comps on the bobber (truth-leak / clutter).
- Billboard to camera; readable at ~5–8 m shop cam.
- Color: teal buy, warm amber sell, neutral browse (match HUD accent language).
- Intent can flip once (browse→buy or browse→sell) when leaving browse; no mid-desk flip without reason.

---

## 3. Thin counter HUD

**When:** NPC enters counter interact volume **and** is front-of-queue (or sole desk customer).  
**What:** Existing CustomerServe / buylist flows (wireflows §3) — **Your list** / **You offer** / §3.2b Wants names.  
**Not:** Full-screen replacement of the shop; floor NPC stays visible behind dim ≤40%.  
**Cashier:** If cashier on duty + Att spare rules already allow auto-serve routine sales — NPC still plays approach/exit; HUD may auto-resolve routine buys (eng: keep current domain policy).

Attention costs (negotiate, inspect, pull) unchanged.

---

## 4. MVP cast (Art)

| Slot | Role | Spec |
|------|------|------|
| C1 | Adult browse/buy | Stylized-real silhouette ~1.7 m; simple idle/walk |
| C2 | Adult sell/buylist | Distinct silhouette/palette from C1 |
| C3 (optional) | Kid/parent or Spike lean | Third body if bandwidth; else remap archetype to C1/C2 |

**MVP bar:** Capsule or mannequin blockout **OK to ship first** with icons if hero meshes lag (PM lean).  
**Out for v1:** Facial performance, lip sync, unique per-archetype hero sculpts, cloth sim.

Archetype (Spike/Whale/…) is data on the instance; mesh slot is C1–C3 mapping.

---

## 5. Pathing

- Use existing shop grid / nav (tile × 0.9 m).
- Browse points: display case, binder rack, sealed wall, play table (if present) — tagged markers.
- Queue: 1–3 stand points leading to counter; no overlapping destinations.
- Blocked path → wait or repath; never clip through counter.

---

## 6. Acceptance (QA)

| ID | Check | Sev if fail |
|----|-------|-------------|
| N1 | Non-empty FLOOR queue ⇒ ≥1 visible NPC in browse or approach | S2 |
| N2 | Overhead icon is browse/buy/sell only — no price/SKU on bobber | S1 if price/true_market; else S2 |
| N3 | Thin HUD opens only in desk volume; Esc closes without deleting NPC mid-resolve incorrectly | S2 |
| N4 | Buy and sell paths both completable; exit after resolve | S2 |
| N5 | Pathing: entrance→browse→desk→exit without soft-lock on Small grid | S2 |
| N6 | Att 0 still allows cashier routine if hired; owner blocked actions stay blocked | S2 |

---

## 7. Out of scope

- Full dialogue trees / lip sync / combat  
- Free-roam player walk (RMB look / desk cam stays)  
- Per-archetype unique hero meshes (post-MVP)  
- Crowds > staff_cap-driven queue soft cap (keep current spawn rates)

---

## 8. Handoff

**Eng:** NPC state machine + path + icons + desk volume → existing serve/buylist.  
**Art:** C1–C3 silhouettes (or approve capsule placeholder); icon sprites.  
**QA:** N1–N6 on Normal FLOOR.  
**PM:** Sync this file; prefer blockout+icons if meshes lag.

