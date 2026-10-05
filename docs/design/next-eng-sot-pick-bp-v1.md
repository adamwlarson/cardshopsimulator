# Next Eng SoT Pick BP v1 — post BO1

**Status:** **Tip-frozen** 2026-10-05 ~4:49pm ET — **BP1** [#98](https://github.com/adamwlarson/cardshopsimulator/pull/98) @ `4b9f163e` (branch `cursor/bp1-daily-utilities-settle-531f`). 8 files, no docs. Cloud agent bc-7d93fba3 archived. Eng review that SHA against bar `cb1cd553`. QA held until APPROVE; no merge until PASS. Soft catalog CLOSED. Soft OK list-time stays Soft. No Art.
**Author:** CSS Designer
**Date:** 2026-10-05
**Depends on:** pick-bo (BO1 Buylist high-% seller flood SHIPPED #97 @ `7a8cfb78`); Soft catalog CLOSED
**Rule:** Pick **one**. §4.5 never leaks. Soft catalog stays closed. Hard-park camera off-switch Soft. Do **not** turn BO1, BN1, BM1, BL1, BK1, BJ1, BI1, BH1, BG1, BF1, BE1, BD1, BC1, BB1, BA1, AZ1, AY1, AX1, AW1, AV1, AU1, AT1, AS1, AR1, AQ1, AP1, AO1, AN1, AM1, AL1, AK1, AJ1, AI1, AH1, AG1, AF1, AC1, AD1, AE1, or AA1 into a sell weight. STOP stays parked.

---

## Context (shipped)

| Pack | Result |
|------|--------|
| A–BO1 | Full loop + fair/overprice settle + suggested day-clear + buylist drip / fewer-lots / high-% flood |
| Soft | Catalog CLOSED; AC1 through BO1 Soft OK MVP notes stay Soft |

**Gap:** Systems §1 close settle still names **utilities** beside rent, wages, shrink, reputation tick, and event roll. Rent / wages / shrink / Rep ticks / events are live; the settle hook even comments that utility services can attach — but no daily utilities expense fires. Soft OK list-time suggested stays Soft. Camera off-switch Soft hard-parked. STOP parked. §4.3 buylist suite is closed.

---

## Option BP1 — Daily utilities settle (systems §1 / economy) — **LEAN GO**

**Player fantasy:** Keeping the lights on costs money every night — even a quiet shop burns overhead before tomorrow's open.

| Deliverable | Spec |
|-------------|------|
| Where | Close settle obligation pass (after wages; before or with shrink). Out: inventing new lose conditions; rent/wage rewires; BM1/BN1/BO1 |
| Charge | Apply one **utilities** ledger expense each settle day for the **current shop tier** (Small / Medium / Large) |
| Amount | Read `utilities_*_daily_cents` from BalanceConfig by tier. Missing Small → **4000** ($40). Missing Medium → **7000** ($70). Missing Large → **11000** ($110). Amount ≤ 0 falls back to that tier's default |
| Pay | Prefer the same unpaid path wages use (attempt expense; if unpaid, note once that settle). Do **not** invent a utilities-specific bankruptcy. Do not go through payday-loan forced drain |
| Caps | Exactly one utilities charge per settle day. Expanding mid-week uses the **new** tier on the next settle only |
| UI | Soft settle line / ledger memo OK (`utilities`). Never shows `true_market` or `p_buy` |
| Untouched | BM1 drip, BN1 fewer-lots, BO1 flood, BK1 fair/gouge, BL1 cache clear, rent, wages, shrink, fee ladder, **buyer** door spawn, whale weight, fog Inspect, mismatch stay as shipped |
| Soft | Catalog untouched; leave Soft OK list-time suggested Soft |

**Acceptance:**

1. Same seed: Small shop, settle with enough cash → ledger shows one `utilities` expense of 4000¢ that day; cash down by 4000¢ from this rule. A second settle the next day charges again.
2. Sign Medium, then settle → charge is 7000¢ (not Small). Large settle → 11000¢. Missing / ≤0 config falls back to the tier defaults above.
3. No screen shows `true_market` or `p_buy`. Rent, wages, shrink, BM1/BN1/BO1 unchanged. Buyer door spawn and whale weight unchanged.
4. Not a sell weight. Soft catalog CLOSED. No Art.

**Out:** STOP / win assert; camera off-switch; Soft OK list-time suggested persistence; listed-band / display-bonus Soft; sell-weight rewires; inventing utilities bankruptcy; changing BM1/BN1/BO1.

**Why now:** §4.3 buylist costs just closed. The remaining named close-settle line still dark is utilities — rent and wages already burn cash; the shop should pay overhead every night.

---

## Option BP2 — STOP / win assert polish — **PARK**

**Why park:** No new Eng systems. Prefer the §1 utilities close this pick.

---

## Option BP3 — Persist list-time suggested (BK1 Soft OK) — **PARK Soft**

**Why park:** Soft catalog CLOSED.

---

## Option BP4 — Listed-band / display-bonus Soft — **PARK Soft**

**Why park:** Soft catalog CLOSED.

---

## Camera off-switch — **HARD PARK Soft**

**Why park (hard):** Reopens Soft catalog.

---

## Recommendation (non-binding)

**GO BP1** (Daily utilities settle). Park BP2/BP3/BP4. **Hard-park** the camera off-switch. Soft catalog stays closed. Soft OK list-time stays Soft. BM1/BN1/BO1 untouched.

---

## PM checklist

- [x] Choose **BP1** (recommended)
- [x] If BP1: Eng vs settle — daily utilities by shop tier (Small $40 / Medium $70 / Large $110); leave Soft OK list-time Soft; no Art; BM1/BN1/BO1/buyer door/whale untouched
- [x] Sync this file to main before cloud agent
- [x] Soft catalog stays closed; STOP stays parked

---

## Decision log

| When | Decision |
|------|----------|
| 2026-10-05 ~4:36pm ET | Drafted post BO1 SHIPPED #97 @ `7a8cfb78` (reviewed `01c5f1ac`). Lean **BP1 Daily utilities settle**. STOP / Soft reopeners parked. Camera off-switch hard-parked. Soft CLOSED. Soft OK list-time stays Soft. No Art. BM1/BN1/BO1 stay as shipped. |
| 2026-10-05 ~4:37pm ET | **ADOPTED** BP1. Park BP2 STOP / BP3 Soft / BP4 Soft. Camera off-switch hard-parked. Soft CLOSED. Soft OK list-time stays Soft. No Art. Eng bar locked; awaiting tip-freeze. |
| 2026-10-05 ~4:49pm ET | **Tip-frozen** [#98](https://github.com/adamwlarson/cardshopsimulator/pull/98) @ `4b9f163e` (branch `cursor/bp1-daily-utilities-settle-531f`). 8 files, no docs. Cloud agent bc-7d93fba3 archived. Eng review that SHA against bar `cb1cd553`. QA held until APPROVE; no merge until PASS. Soft catalog CLOSED. |
