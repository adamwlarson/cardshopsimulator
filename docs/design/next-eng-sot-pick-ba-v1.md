# Next Eng SoT Pick BA v1 — post AZ1

**Status:** **BA1 SHIPPED** 2026-10-05 — squash-merged #83 @ `c9a303c6` (reviewed `369d9836`). Marketplace / shady Inspect. Park BA2/BA3/BA4. Hard-park camera off-switch. Soft catalog CLOSED. Fees, net-worth HUD, and STOP stay parked. Do not turn prior packs into a sell weight. Door spawn math stays as shipped.
**Author:** CSS Designer
**Date:** 2026-10-05
**Depends on:** pick-az (AZ1 Specialist inspect discount SHIPPED #82 @ `81657192`); Soft catalog CLOSED
**Rule:** Pick **one**. §4.5 never leaks. Soft catalog stays closed. Hard-park camera off-switch Soft. Do **not** turn AZ1, AY1, AX1, AW1, AV1, AU1, AT1, AS1, AR1, AQ1, AP1, AO1, AN1, AM1, AL1, AK1, AJ1, AI1, AH1, AG1, AF1, AC1, AD1, or AE1 into a sell weight. Fees / HUD / STOP stay parked.

---

## Context (shipped)

| Pack | Result |
|------|--------|
| A–BA1 | Full loop + buylist + marketplace/shady Inspect @ AZ1 ladder |
| Soft | Catalog CLOSED; AC1 through BA1 Soft OK MVP notes stay Soft |

**Gap:** Fee cut stays parked. Camera off-switch Soft hard-parked. Fees / HUD / STOP parked by PM. Sell-side NM mismatch still dark.

---

## Option BA1 — Marketplace / shady Inspect (systems §2.2 / §4.5) — **LEAN GO**

**Player fantasy:** On a noisy photo lot or a trunk buy, you can spend Attention to peek condition before you commit — strongly recommended, not forced.

| Deliverable | Spec |
|-------------|------|
| Where | Marketplace `BuyOpportunityDetail` and shady trunk **Buy** path only. Out: buylist Inspect (AY1/AZ1), distributor, auction, trades, trunk Report/Walk |
| Cue | Condition cue is **Photo only — inspect recommended**. True condition stays hidden until Inspect |
| Actions | Existing Accept / Counter / Decline (or trunk Buy) stay as shipped, plus one **Inspect** |
| Cost | Same Att ladder as AZ1: **5** with no Specialist on duty; **2** with Specialist on duty (hired + present; missing duty → 5). Paid when taken. Att < cost refuses, Att unchanged, shot stays. Cashier cannot Inspect |
| Reveal | Seeded once. **85%** true condition band / **15%** adjacent miss (never NM↔DMG leap). UI shows revealed band only — never `true_market`, never `cert_valid` |
| Bounds | One Inspect per offer. Second refused. Inspect does not buy or clear the offer. Buy without Inspect stays allowed |
| After | Accept / Counter / trunk Buy store the lot's **true** condition in domain even when the reveal was wrong |
| Untouched | Fee stays 8%. Buyer door spawn, whale weight, AU1 Counter math, AT1 trunk fork, AY1/AZ1 buylist Inspect stay as shipped |
| Soft | Catalog untouched; leave AC1 through AZ1 Soft OK alone |

**Acceptance:**

1. Same marketplace or shady Buy offer: one Inspect spends the active Att cost (5 or 2) and shows a condition band. Second Inspect refused. Att below cost refuses with Att unchanged.
2. Cue before Inspect is photo/inspect-recommended. Reveal stays 85/15 adjacent. No screen shows `true_market` or `cert_valid`.
3. Buy without Inspect still works. Buy after a wrong reveal still stores true condition in domain. Buylist Inspect path unchanged.
4. Buyer door spawn and whale weight are unchanged. Marketplace fee stays 8%. Not a sell weight. Soft catalog CLOSED. No Art.

**Out:** A fee cut; net-worth HUD; STOP; camera off-switch; auction Inspect; inspect-mandatory (Counterfeit scare); sell-side uninspected NM mismatch; sell-weight rewires.

**Why now:** Buylist Inspect + Specialist discount are shipped. §4.5 still wants the fog channels to offer the same peek.

---

## Option BA2 — Marketplace fee cut at Rep ≥ 75 — **PARK**

**Why park:** PM parked fee cuts unless Design leans one. Not leaning — the 8% stays.

---

## Option BA3 — Net-worth HUD / STOP — **PARK**

**Why park:** PM parked both unless Design leans one. Not leaning this pick.

---

## Option BA4 — Sell-side uninspected NM mismatch — **PARK**

**Why park:** Real §2.2 line. Channel Inspect on buy is the open fog verb. Sell mismatch can follow.

---

## Camera off-switch — **HARD PARK Soft**

**Why park (hard):** Reopens Soft catalog.

---

## Recommendation (non-binding)

**GO BA1** (Marketplace / shady Inspect). Park BA2/BA3/BA4. **Hard-park** the camera off-switch. Soft catalog stays closed.

---

## PM checklist

- [x] Choose **BA1** (recommended)
- [x] If BA1: Eng vs systems §2.2/§4.5 Inspect on marketplace + shady Buy; reuse AZ1 Att ladder; leave fees and door spawn alone; no Art
- [x] Sync this file to main before cloud agent
- [x] Soft catalog stays closed; fees / HUD / STOP stay parked

---

## Decision log

| When | Decision |
|------|----------|
| 2026-10-05 | Drafted post AZ1 SHIPPED #82 @ `81657192`. Lean **BA1 Marketplace / shady Inspect**. Fee cut / HUD / STOP / sell-side mismatch parked. Camera off-switch hard-parked. |
| 2026-10-05 | PM adopted **BA1**. Park BA2/BA3/BA4. Hard-park camera off-switch. Soft catalog CLOSED. Marketplace/shady Inspect with AZ1 Att ladder. Draft sha256 `2856e9a1`. |
| 2026-10-05 | PM adopted **BA1**. Spec on main `ecbc538c`. Spike [BA1 Marketplace / shady Inspect](https://cursor.com/agents/bc-c4b171ba-02a7-581b-8c43-0a4cbbcd069b). Park BA2/BA3/BA4. No Art. Soft catalog CLOSED. Draft sha256 `2856e9a1`. |
| 2026-10-05 | Eng bar locked BA1 against `ecbc538c`. Marketplace + shady Buy Inspect; AZ1 Att ladder. Awaiting tip-freeze. |
| 2026-10-05 | PM tip-froze PR #83 @ `369d9836`. Ready. 7 files, no docs. Agent archived. |
| 2026-10-05 | Eng **APPROVE**-with-notes BA1 [PR #83](https://github.com/adamwlarson/cardshopsimulator/pull/83) @ `369d9836`. Soft: HUD gate mirror; shady cue AT1 strongly recommended; unused apply_fog_cue. Soft OK MVP. QA cleared by PM. |
| 2026-10-05 | PM SHIPPED **BA1**. Squash-merged #83 @ `c9a303c6` (reviewed `369d9836`). QA PASS, harness 140/0/0. Soft OK Eng notes not failed. Soft catalog CLOSED. Branch `cursor/ba1-marketplace-shady-inspect-069b` deleted. |
