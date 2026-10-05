# Next Eng SoT Pick AW v1 — post AV1

**Status:** **AW1 ADOPTED** 2026-10-05 — Buylist buy-from-them. Park AW2/AW3/AW4. Hard-park camera off-switch. Soft catalog CLOSED. Fees, net-worth HUD, and STOP stay parked. Do not turn rep bands, trades, shrink, walkouts, Fire, AU1 haggle, or AV1 Negotiate into a sell weight. Door spawn math stays as shipped.
**Author:** CSS Designer
**Date:** 2026-10-05
**Depends on:** pick-av (AV1 Sell-side Negotiate SHIPPED #78 @ `6f881d6b`); Soft catalog CLOSED
**Rule:** Pick **one**. §4.5 never leaks. Soft catalog stays closed. Hard-park camera off-switch Soft. Do **not** turn AV1, AU1, AT1, AS1, AR1, AQ1, AP1, AO1, AN1, AM1, AL1, AK1, AJ1, AI1, AH1, AG1, AF1, AC1, AD1, or AE1 into a sell weight. Fees / HUD / STOP stay parked.

---

## Context (shipped)

| Pack | Result |
|------|--------|
| A–AV1 | Full loop + buy channels + buy Counter + sell Negotiate |
| Soft | Catalog CLOSED; AC1 through AV1 Soft OK MVP notes stay Soft |

**Gap:** Buylist buy-from-them on the floor (systems §3, §4.3, §5.2; wireflows §3.2a) still dark as a serve verb. Fee cut stays parked. Camera off-switch Soft hard-parked. Fees / HUD / STOP parked by PM.

---

## Option AW1 — Buylist buy-from-them (systems §3 / §4.3 / §5.2) — **LEAN GO**

**Player fantasy:** Someone walks in to sell you a card. You see **You offer**, buy it into backstock, or walk — and a stingy bid can sour them.

| Deliverable | Spec |
|-------------|------|
| Where | `CustomerServe` when the customer is **selling to the shop** (buylist walk-in). Out: customer buying from shop (AV1 path), AU1 buy Counter, auction, trades, shady trunk |
| Spawn | Seeded floor can show a buylist seller. Buyer door spawn and whale weight stay as shipped. Seller weight uses today's buylist pressure as shipped (P1 Soft OK stays Soft) |
| Offer | One lot. SKU visible. Label is **You offer** (never Ask / Your list). Default offer = `round(buylist_pct[category] × listed_comp)` cents (≥ 1¢). Confidence **Medium**. Comp width **0.10** |
| Buylist % defaults | Sealed `0.55`. Singles NM `0.50`. Graded `0.45`. Missing category falls back to `0.50` |
| Actions | **Buy**, **Walk**. Inspect stays as shipped if already on the serve. No AV1 Negotiate. No AU1 Counter |
| Buy | Cash drops by You offer. Lot enters BACKSTOCK. No Attention cost. Cash short → nothing moves |
| Walk | Offer is gone. If `offer / listed_comp < 0.40`, soft Rep **−1** once (bad-offer anger). Else Rep unchanged |
| UI | Never shows `true_market`, `p`, or anger thresholds as numbers. §4.5 chips stay channel-honest (Medium) |
| Config | Missing width falls back to 0.10. Missing anger floor falls back to 0.40. Missing miss Rep falls back to −1 |
| Untouched | Fee stays 8%. Door spawn (buyers), AU1 Counter, AV1 Negotiate, trunk, auction, drift, and shrink stay as shipped |
| Soft | Catalog untouched; leave AC1 through AV1 Soft OK alone |

**Acceptance:**

1. Same seed: a buylist seller serve shows **You offer** (not Ask / Your list). Buy drops cash by the offer and lands the lot in backstock. Short-cash Buy moves nothing. Walk clears the offer.
2. Default offer matches `round(buylist_pct × listed_comp)` with the category defaults above. Confidence is Medium and width is 0.10.
3. Same offer/comp: Walk with `offer / listed_comp < 0.40` applies Rep −1 once; Walk at or above that ratio leaves Rep unchanged. No screen shows `true_market`.
4. Buyer door spawn and whale weight are unchanged. A completed shop sale still pays its resolved price. Marketplace fee stays 8%. Not a sell weight. Soft catalog CLOSED. No Art.

**Out:** A fee cut; net-worth HUD; STOP; camera off-switch; editing You offer mid-serve; multi-step buylist haggle; sell-weight rewires.

**Why now:** Sell Negotiate closed the shop-side serve verb. The mirror floor verb is buying from a walk-in under §4.3 labels.

---

## Option AW2 — Marketplace fee cut at Rep ≥ 75 — **PARK**

**Why park:** PM parked fee cuts. The 8% stays.

---

## Option AW3 — Net-worth HUD / STOP — **PARK**

**Why park:** PM parked both this pick.

---

## Option AW4 — Edit You offer mid-serve — **PARK**

**Why park:** Real polish. Default-% Buy/Walk is the open §4.3 line. One-shot edit can follow.

---

## Camera off-switch — **HARD PARK Soft**

**Why park (hard):** Reopens Soft catalog.

---

## Recommendation (non-binding)

**GO AW1** (Buylist buy-from-them). Park AW2/AW3/AW4. **Hard-park** the camera off-switch. Soft catalog stays closed.

---

## PM checklist

- [x] Choose **AW1** (recommended)
- [x] If AW1: Eng vs systems §3/§4.3/§5.2 buylist serve; leave fees and buyer door spawn alone; no Art
- [x] Sync this file to main before cloud agent
- [x] Soft catalog stays closed; fees / HUD / STOP stay parked

---

## Decision log

| When | Decision |
|------|----------|
| 2026-10-05 | Drafted post AV1 SHIPPED #78 @ `6f881d6b`. Lean **AW1 Buylist buy-from-them**. Fee cut / HUD / STOP / mid-serve offer edit parked. Camera off-switch hard-parked. |
| 2026-10-05 | PM adopted **AW1**. Park AW2/AW3/AW4. Hard-park camera off-switch. Soft catalog CLOSED. Buylist seller serve with You offer, Buy, Walk. Draft sha256 `ddf0e9c9`. |
