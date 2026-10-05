# Next Eng SoT Pick BQ v1 — post BP1

**Status:** **ADOPTED** 2026-10-05 ~4:59pm ET — **BQ1 Set release hype event**. Park BQ2 STOP / BQ3 Soft / BQ4 Soft. Camera off-switch hard-parked. Soft CLOSED. Soft OK list-time stays Soft. No Art. Eng bar locked; awaiting tip-freeze.
**Author:** CSS Designer
**Date:** 2026-10-05
**Depends on:** pick-bp (BP1 Daily utilities settle SHIPPED #98 @ `af1de62d`); Soft catalog CLOSED
**Rule:** Pick **one**. §4.5 never leaks. Soft catalog stays closed. Hard-park camera off-switch Soft. Do **not** turn BP1, BO1, BN1, BM1, BL1, BK1, BJ1, BI1, BH1, BG1, BF1, BE1, BD1, BC1, BB1, BA1, AZ1, AY1, AX1, AW1, AV1, AU1, AT1, AS1, AR1, AQ1, AP1, AO1, AN1, AM1, AL1, AK1, AJ1, AI1, AH1, AG1, AF1, AC1, AD1, AE1, or AA1 into a sell weight. STOP stays parked.

---

## Context (shipped)

| Pack | Result |
|------|--------|
| A–BP1 | Full loop + fair/overprice settle + suggested day-clear + buylist drip / fewer-lots / high-% flood + daily utilities |
| Soft | Catalog CLOSED; AC1 through BP1 Soft OK MVP notes stay Soft |

**Gap:** Systems §8 still names **Set release hype** (calendar-known; new sealed demand ↑, old set ↓) and **Pro tour / influencer spike**. Named pressure events (Counterfeit / Convention / Theft / Recession / Supply glut) plus AR1 daily drift are live; the calendar sealed-hype beat is still dark. Soft OK list-time suggested stays Soft. Camera off-switch Soft hard-parked. STOP parked. §4.3 buylist suite and §1 utilities just closed.

---

## Option BQ1 — Set release hype event (systems §8) — **LEAN GO**

**Player fantasy:** The calendar shows a new set drop — fresh sealed runs hot while yesterday's boxes cool. Pre-order depth or wait it out.

| Deliverable | Spec |
|-------------|------|
| Where | Named §8 market event on the settle / calendar path (same event bus Convention / Supply glut use). Out: inventing door-spawn or whale weight bumps; Pro tour spike; BM1/BN1/BO1/BP1 |
| Signal | **Calendar-known** telegraph (days ahead). Missing `set_release_telegraph_days` → **3**. Duration Missing `set_release_duration_days` → **5** (inclusive of release day) |
| Target | One **new/current** sealed set id and one **old/previous** sealed set id from the live catalog (seeded pick). Accessories / singles / graded are **out** of this event's demand modifiers |
| Effect | While active: new-set sealed SKUs get demand mult `hype_new_mult`; old-set sealed SKUs get `hype_old_mult`. Missing new → **1.40**. Missing old → **0.70**. Mult ≤ 0 falls back to those. Does **not** rewrite listed prices or cash |
| Lever | Player can pre-buy / hold depth into the new set, fire-sale old sealed, or ignore — no soft-lock either way |
| Bounds | Does **not** change **buyer** door spawn, whale weight, BM1 drip, BN1 fewer-lots, BO1 flood, or BP1 utilities. Does not invent distributor MOQ / wholesale rewires (Supply glut owns wholesale) |
| UI | Soft EventBanner / calendar telegraph OK. Demand band / noisy suggested may warm or cool through today's §4.5 path only. Never shows `true_market` or `p_buy` |
| Untouched | BM1 drip, BN1 fewer-lots, BO1 flood, BP1 utilities, BK1 fair/gouge, BL1 cache clear, fee ladder, AR1 drift formula, fog Inspect, mismatch stay as shipped |
| Soft | Catalog untouched; leave Soft OK list-time suggested Soft |

**Acceptance:**

1. Same seed: calendar Set release hype telegraphs ≥1 day before active; during the active window, a new-set sealed SKU's hidden demand is about ×1.40 vs pre-event baseline and an old-set sealed SKU is about ×0.70 (instrumented). Listed prices and cash unchanged by the event alone.
2. After duration ends, those sealed demand mults no longer apply from this event. A day with no Set release active does not invent the mults.
3. No screen shows `true_market` or `p_buy`. Buyer door spawn and whale weight unchanged. BM1/BN1/BO1/BP1 unchanged.
4. Not a sell weight. Soft catalog CLOSED. No Art.

**Out:** STOP / win assert; camera off-switch; Soft OK list-time suggested persistence; listed-band / display-bonus Soft; Pro tour / influencer spike; sell-weight rewires; changing BM1/BN1/BO1/BP1.

**Why now:** §4.3 buylist and §1 utilities just closed. The remaining clear named §8 hole still dark (and not Soft) is calendar Set release hype — sealed timing is the next irreversible cash/space beat.

---

## Option BQ2 — STOP / win assert polish — **PARK**

**Why park:** No new Eng systems. Prefer the §8 Set release close this pick.

---

## Option BQ3 — Persist list-time suggested (BK1 Soft OK) — **PARK Soft**

**Why park:** Soft catalog CLOSED.

---

## Option BQ4 — Listed-band / display-bonus Soft — **PARK Soft**

**Why park:** Soft catalog CLOSED.

---

## Camera off-switch — **HARD PARK Soft**

**Why park (hard):** Reopens Soft catalog.

---

## Recommendation (non-binding)

**GO BQ1** (Set release hype event). Park BQ2/BQ3/BQ4. **Hard-park** the camera off-switch. Soft catalog stays closed. Soft OK list-time stays Soft. Pro tour spike stays Out for a later pick. BM1/BN1/BO1/BP1 untouched.

---

## PM checklist

- [x] Choose **BQ1** (recommended)
- [x] If BQ1: Eng vs §8 Set release — calendar telegraph; new sealed demand ×1.40 / old sealed ×0.70 for duration; leave Soft OK list-time Soft; no Art; BM1/BN1/BO1/BP1/buyer door/whale untouched
- [x] Sync this file to main before cloud agent
- [x] Soft catalog stays closed; STOP stays parked

---

## Decision log

| When | Decision |
|------|----------|
| 2026-10-05 ~4:59pm ET | Drafted post BP1 SHIPPED #98 @ `af1de62d` (reviewed `4b9f163e`). Lean **BQ1 Set release hype event**. STOP / Soft reopeners parked. Camera off-switch hard-parked. Soft CLOSED. Soft OK list-time stays Soft. No Art. Pro tour stays Out. BM1/BN1/BO1/BP1 stay as shipped. |
| 2026-10-05 ~4:59pm ET | **ADOPTED** BQ1. Park BQ2 STOP / BQ3 Soft / BQ4 Soft. Camera off-switch hard-parked. Soft CLOSED. Soft OK list-time stays Soft. No Art. Eng bar locked; awaiting tip-freeze. |
