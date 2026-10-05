# Next Eng SoT Pick BC v1 — post BB1

**Status:** **BC1 ADOPTED** 2026-10-05 — Auction Inspect fog. Park BC2/BC3/BC4. Hard-park camera off-switch. Soft catalog CLOSED. Fees, net-worth HUD, and STOP stay parked. Do not turn prior packs into a sell weight. Door spawn math stays as shipped.
**Author:** CSS Designer
**Date:** 2026-10-05
**Depends on:** pick-bb (BB1 Sell-side uninspected NM mismatch SHIPPED #84 @ `17deced0`); Soft catalog CLOSED
**Rule:** Pick **one**. §4.5 never leaks. Soft catalog stays closed. Hard-park camera off-switch Soft. Do **not** turn BB1, BA1, AZ1, AY1, AX1, AW1, AV1, AU1, AT1, AS1, AR1, AQ1, AP1, AO1, AN1, AM1, AL1, AK1, AJ1, AI1, AH1, AG1, AF1, AC1, AD1, or AE1 into a sell weight. Fees / HUD / STOP stay parked.

---

## Context (shipped)

| Pack | Result |
|------|--------|
| A–BB1 | Full loop + buy Inspect on buylist / marketplace / shady + sell-side uninspected NM mismatch |
| Soft | Catalog CLOSED; AC1 through BB1 Soft OK MVP notes stay Soft |

**Gap:** Auction snipes (AS1) still have photo cue with no Inspect spend. Fee cut stays parked. Camera off-switch Soft hard-parked. Fees / HUD / STOP parked by PM.

---

## Option BC1 — Auction Inspect fog (systems §3 / §4.5) — **LEAN GO**

**Player fantasy:** Before you burn Attention and cash on a timed auction lot, you can spend a little Attention to peek condition — recommended, not forced.

| Deliverable | Spec |
|-------------|------|
| Where | AS1 auction snipe offer only (prep timed Bid / Decline). Out: buylist Inspect (AY1/AZ1), marketplace/shady Inspect (BA1), distributor, trades, trunk |
| Cue | Condition cue stays **Photo only — inspect recommended** (AS1). True condition stays hidden until Inspect. Confidence stays **Medium** |
| Actions | Existing Bid / Decline stay as shipped, plus one **Inspect** before Bid |
| Cost | Same Att ladder as AZ1/BA1: **5** with no Specialist on duty; **2** with Specialist on duty (hired + present; missing duty → 5). Paid when taken. Att < cost refuses, Att unchanged, offer stays. Cashier cannot Inspect |
| Reveal | Seeded once. **85%** true condition band / **15%** adjacent miss (never NM↔DMG leap). UI shows revealed band only — never `true_market`, never `cert_valid` |
| Bounds | One Inspect per auction offer. Second refused. Inspect does not Bid or clear the offer. Bid without Inspect stays allowed |
| After | Winning Bid stores the lot's **true** condition in domain even when the reveal was wrong |
| Untouched | Bid still costs Attention **10** plus the ask (AS1). Fee stays 8%. Buyer door spawn, whale weight, BA1/AY1/AZ1 Inspect, BB1 mismatch (marketplace/shady only), AV1, AT1 stay as shipped |
| Soft | Catalog untouched; leave AC1 through BB1 Soft OK alone (including no listed-band retag UI) |

**Acceptance:**

1. Same auction offer: one Inspect spends the active Att cost (5 or 2) and shows a condition band. Second Inspect refused. Att below cost refuses with Att unchanged.
2. Cue before Inspect stays photo/inspect-recommended. Reveal stays 85/15 adjacent. No screen shows `true_market` or `cert_valid`.
3. Bid without Inspect still works (Att 10 + ask). Bid after a wrong reveal still stores true condition in domain. Buylist / marketplace / shady Inspect paths unchanged.
4. Buyer door spawn and whale weight are unchanged. Marketplace fee stays 8%. BB1 mismatch scope stays marketplace/shady only. Not a sell weight. Soft catalog CLOSED. No Art.

**Out:** A fee cut; net-worth HUD; STOP; camera off-switch; extend BB1 mismatch onto auction lots; listed-band retag UI; inspect-mandatory; sell-weight rewires.

**Why now:** Fog Inspect is live on buylist + marketplace/shady. Auction is the last §3 buy channel with a photo cue and no peek.

---

## Option BC2 — Marketplace fee cut at Rep ≥ 75 — **PARK**

**Why park:** PM parked fee cuts unless Design leans one. Not leaning — the 8% stays.

---

## Option BC3 — Net-worth HUD / STOP — **PARK**

**Why park:** PM parked both unless Design leans one. Not leaning this pick.

---

## Option BC4 — Extend BB1 mismatch onto auction buys — **PARK**

**Why park:** Real follow-on. Auction Inspect closes the peek first; mismatch scope can widen after.

---

## Camera off-switch — **HARD PARK Soft**

**Why park (hard):** Reopens Soft catalog.

---

## Recommendation (non-binding)

**GO BC1** (Auction Inspect fog). Park BC2/BC3/BC4. **Hard-park** the camera off-switch. Soft catalog stays closed.

---

## PM checklist

- [x] Choose **BC1** (recommended)
- [x] If BC1: Eng vs systems §3/§4.5 Inspect on auction snipe; reuse AZ1 Att ladder; leave Bid Att 10 + ask, fees, and door spawn alone; no Art
- [x] Sync this file to main before cloud agent
- [x] Soft catalog stays closed; fees / HUD / STOP stay parked

---

## Decision log

| When | Decision |
|------|----------|
| 2026-10-05 | Drafted post BB1 SHIPPED #84 @ `17deced0`. Lean **BC1 Auction Inspect fog**. Fee cut / HUD / STOP / BB1-to-auction extend parked. Camera off-switch hard-parked. |
| 2026-10-05 | PM adopted **BC1**. Park BC2/BC3/BC4. Hard-park camera off-switch. Soft catalog CLOSED. Auction snipe Inspect with AZ1 Att ladder. Draft sha256 `f9bf3c2d`. |
| 2026-10-05 | PM adopted **BC1**. Spec on main `102fa3da`. Park BC2/BC3/BC4. No Art. Soft catalog CLOSED. Draft sha256 `f9bf3c2d`. |
| 2026-10-05 | PM adopted **BC1**. Spec on main `183a889c`. Spike [BC1 Auction Inspect fog](https://cursor.com/agents/bc-33bbc3ae-372f-5311-a456-bb02d282fede). Park BC2/BC3/BC4. No Art. Soft catalog CLOSED. Draft sha256 `f9bf3c2d`. |
| 2026-10-05 | PM tip-froze PR #85 @ `3e9755bd`. Ready. 6 files, no docs. Agent archived. |
| 2026-10-05 | PM tip-froze PR #85 @ `3e9755bd`. Ready. 6 files, no docs. Agent archived. |
| 2026-10-05 | Eng **APPROVE**-with-notes BC1 [PR #85](https://github.com/adamwlarson/cardshopsimulator/pull/85) @ `3e9755bd`. Soft: HUD mirrors Att<cost; unused apply_fog_cue. Soft OK MVP. Soft catalog CLOSED. |
| 2026-10-05 | Design Soft OK MVP on Eng Softs (HUD Att mirror; unused apply_fog_cue). QA formal released; Soft OK notes not fail criteria. |
| 2026-10-05 | BC1 SHIPPED — squash-merged #85 @ `89ae3b0a` (reviewed `3e9755bd`). QA PASS harness 170/0/0. Soft OK Eng notes not failed. |
