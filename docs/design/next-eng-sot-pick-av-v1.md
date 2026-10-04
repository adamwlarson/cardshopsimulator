# Next Eng SoT Pick AV v1 — post AU1

**Status:** **AV1 ADOPTED** 2026-10-03 — Sell-side Negotiate ±10%. Park AV2/AV3/AV4. Hard-park camera off-switch. Soft catalog CLOSED. Fees, net-worth HUD, and STOP stay parked. Do not turn rep bands, trades, shrink, walkouts, Fire, or AU1 haggle into a sell weight. Door spawn math stays as shipped.
**Author:** CSS Designer
**Date:** 2026-10-03
**Depends on:** pick-au (AU1 One-counter haggle SHIPPED #77 @ `44a1b299`); Soft catalog CLOSED
**Rule:** Pick **one**. §4.5 never leaks. Soft catalog stays closed. Hard-park camera off-switch Soft. Do **not** turn AU1, AT1, AS1, AR1, AQ1, AP1, AO1, AN1, AM1, AL1, AK1, AJ1, AI1, AH1, AG1, AF1, AC1, AD1, or AE1 into a sell weight. Fees / HUD / STOP stay parked.

---

## Context (shipped)

| Pack | Result |
|------|--------|
| A–AU1 | Full loop + buy channels + one-counter buy haggle |
| Soft | Catalog CLOSED; AC1 through AU1 Soft OK MVP notes stay Soft |

**Gap:** Sell-side Negotiate ±10% (systems §5.2, ui-wireflows §3) still dark. Fee cut stays parked. Camera off-switch Soft hard-parked. Fees / HUD / STOP parked by PM.

---

## Option AV1 — Sell-side Negotiate ±10% (systems §5.2) — **LEAN GO**

**Player fantasy:** At the counter, you can try one nudge off list — drop 10% to close, or ask 10% more. Spike may walk.

| Deliverable | Spec |
|-------------|------|
| Where | `CustomerServe` when the customer is **buying from the shop**. Out: buylist walk-ins (they sell to you), AU1 buy Counter, auction, trades |
| Actions | **Sell at list**, **Negotiate** (one step, choose −10% or +10% of listed), **Refuse**. Pull stays as shipped |
| Price | On hit: sale cash = `round(listed × 0.90)` for −10%, or `round(listed × 1.10)` for +10%, in cents (≥ 1¢). Stock out same as Sell at list |
| Attention | Negotiate costs **8** Attention (systems §6.2). Paid when the step is taken. At Att < 8: Negotiate refused, shot stays, Att unchanged. Cashier cannot Negotiate |
| Accept chance | Seeded once. `p = clamp(direction_w × (0.45 + Rep × 0.005) × archetype_w, 0, 1)`. Roll once. Hit → sale at the negotiated price. Miss → customer walks; soft Rep **−1** once |
| Direction weights | −10% → `1.15`. +10% → `0.70` |
| Archetype weights | Kid `1.10`. Regular `1.05`. Collector `1.00`. Whale `0.90`. Flipper `0.85`. Spike `0.70`. Missing archetype → `1.00` |
| Bounds | One Negotiate per serve. A second Negotiate is refused. Sell at list still pays listed with no Att cost |
| Fail | Miss: no cash, no stock move beyond the walk, Rep −1. Decline/Refuse path stays as shipped |
| UI | Shows list and the ±10% choice; never shows `true_market`, `p`, or the roll. §4.5 chips stay as shipped |
| Config | Missing direction weight falls back as above. Missing Att cost falls back to 8. Missing miss Rep falls back to −1 |
| Untouched | Fee stays 8%. Door spawn, AU1 buy Counter, trunk, auction, drift, and shrink stay as shipped |
| Soft | Catalog untouched; leave AC1 through AU1 Soft OK alone |

**Acceptance:**

1. Same serve: Sell at list still pays listed with no Att spend. One Negotiate at −10% or +10% either sells at the rounded negotiated cents or walks the customer. A second Negotiate is refused.
2. Negotiate spends 8 Att when taken. At Att < 8 the step is refused and Att is unchanged. Cashier cannot take Negotiate. A miss leaves stock and cash unchanged and applies Rep −1 once.
3. Same listed/Rep: −10% `p` is higher than +10% using the weights above. Spike `p` is lower than Regular at the same direction. No screen shows `true_market` or `p`.
4. Door spawn and whale weight are unchanged. A completed sale still pays the resolved price (list or negotiated). Marketplace fee stays 8%. Not a sell weight. Soft catalog CLOSED. No Art.

**Out:** A fee cut; net-worth HUD; STOP; camera off-switch; buylist buy-from-them polish; sell-weight rewires; multi-step bargain chains.

**Why now:** Buy haggle closed systems §3. The matching floor verb on serve is §5.2 Negotiate.

---

## Option AV2 — Marketplace fee cut at Rep ≥ 75 — **PARK**

**Why park:** PM parked fee cuts. The 8% stays.

---

## Option AV3 — Net-worth HUD / STOP — **PARK**

**Why park:** PM parked both this pick.

---

## Option AV4 — Buylist buy-from-them polish — **PARK**

**Why park:** Real §5.2 line. Sell Negotiate is the open serve verb. Buylist can follow.

---

## Camera off-switch — **HARD PARK Soft**

**Why park (hard):** Reopens Soft catalog.

---

## Recommendation (non-binding)

**GO AV1** (Sell-side Negotiate ±10%). Park AV2/AV3/AV4. **Hard-park** the camera off-switch. Soft catalog stays closed.

---

## PM checklist

- [x] Choose **AV1** (recommended)
- [x] If AV1: Eng vs systems §5.2 Negotiate + Attention 8; leave fees and the door spawn alone; no Art
- [x] Sync this file to main before cloud agent
- [x] Soft catalog stays closed; fees / HUD / STOP stay parked

---

## Decision log

| When | Decision |
|------|----------|
| 2026-10-03 | Drafted post AU1 SHIPPED #77 @ `44a1b299`. Lean **AV1 Sell-side Negotiate ±10%**. Fee cut / HUD / STOP / buylist polish parked. Camera off-switch hard-parked. |
| 2026-10-03 | Local draft ready for PM. Path `docs/design/next-eng-sot-pick-av-v1.md`. |
| 2026-10-03 | PM adopted **AV1**. Park AV2/AV3/AV4. Hard-park camera off-switch. Soft catalog CLOSED. One ±10% negotiate on a customer buying from the shop. Draft sha256 `2840d41c`. |
| 2026-10-03 | PM adopted **AV1**. Spec on main `dafc70ef`. Spike [AV1 sell-side negotiate](https://cursor.com/agents/bc-89fcaeae-e81d-5295-bcb1-391172750d16). Park AV2/AV3/AV4. No Art. Soft catalog CLOSED. Draft sha256 `2840d41c`. |
| 2026-10-03 | PM tip-froze PR #78 @ `3332d3cd`. Ready. 7 files, no docs. Agent archived. |
