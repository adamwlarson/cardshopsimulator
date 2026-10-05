# Next Eng SoT Pick BR v1 — post BQ1

**Status:** **TIP-FROZEN** 2026-10-05 ~5:33pm ET — BR1 [#100](https://github.com/adamwlarson/cardshopsimulator/pull/100) @ `cc9b37b5` (branch `cursor/br1-pro-tour-spike-057a`). Eng review vs bar `abcc8265`. Soft CLOSED. Soft OK list-time Soft. No Art. QA held until APPROVE; no merge until PASS.
**Author:** CSS Designer
**Date:** 2026-10-05
**Depends on:** pick-bq (BQ1 Set release hype event SHIPPED #99 @ `3ab5bae2`); Soft catalog CLOSED
**Rule:** Pick **one**. §4.5 never leaks. Soft catalog stays closed. Hard-park camera off-switch Soft. Do **not** turn BQ1, BP1, BO1, BN1, BM1, BL1, BK1, BJ1, BI1, BH1, BG1, BF1, BE1, BD1, BC1, BB1, BA1, AZ1, AY1, AX1, AW1, AV1, AU1, AT1, AS1, AR1, AQ1, AP1, AO1, AN1, AM1, AL1, AK1, AJ1, AI1, AH1, AG1, AF1, AC1, AD1, AE1, or AA1 into a sell weight. STOP stays parked.

---

## Context (shipped)

| Pack | Result |
|------|--------|
| A–BQ1 | Full loop + fair/overprice settle + suggested day-clear + buylist drip / fewer-lots / high-% flood + daily utilities + calendar set release hype |
| Soft | Catalog CLOSED; AC1 through BQ1 Soft OK MVP notes stay Soft |

**Gap:** Systems §8 still names **Pro tour / influencer spike** (1-day telegraph; specific archetype cards ↑ 30–80%; lever: stock depth vs FOMO buy). Set release hype (BQ1), Counterfeit / Convention / Theft / Recession / Supply glut, C1 single-SKU hype spike / soft rotation leak / fog day, and AR1 daily drift are live; the archetype-tag singles spike is still dark. Set bible §6/§8 already tags `archetype:aggro|control|mid` and names influencer spike as a `chase` amplifier — data exists, no event reads it. Soft OK list-time suggested stays Soft. Camera off-switch Soft hard-parked. STOP parked.

---

## Option BR1 — Pro tour / influencer spike event (systems §8) — **LEAN GO**

**Player fantasy:** Word drops that a pro-tour deck is about to break out — tomorrow every aggro staple is the hottest thing in the binder. Stock depth now, or chase-buy into the spike.

| Deliverable | Spec |
|-------------|------|
| Where | Named §8 market event on the same settle-rolled event bus Convention / Supply glut / Set release use. Out: C1 single-SKU hype spike rewires; Set release (BQ1) sealed mults; door-spawn or whale weight bumps; BM1/BN1/BO1/BP1/BQ1 |
| Signal | **1-day telegraph** (EventBanner day before active). Missing `pro_tour_telegraph_days` → **1**. Duration missing `pro_tour_duration_days` → **2** (inclusive of spike day) |
| Target | One archetype tag (`archetype:aggro` / `archetype:control` / `archetype:mid`) — seeded pick from tags present in the live catalog. **Singles** (CardInstance) whose CardDef carries that tag are affected; graded slabs of the same card follow the card ref. Sealed / accessories are **out** |
| Effect | While active: affected cards' hidden `true_market` read via a non-compounding event mult `pro_tour_mult`, seeded once per event in [`pro_tour_mult_min`, `pro_tour_mult_max`]. Missing min → **1.30**. Missing max → **1.80**. Min ≤ 0 or max < min falls back to those defaults. Mult is a modifier, **not** baked into AR1 drift — when the event ends the base value resumes. Does **not** rewrite listed prices or cash |
| Lever | Player can deepen tagged singles before the spike, raise listed prices into it, fire-sell, or ignore. Existing buy channels that already derive ask/comp from `true_market` read the modified value — no new channel rewires. No soft-lock |
| Bounds | Max **one** Pro tour active at a time. Does **not** change buyer door spawn, whale weight, BM1 drip, BN1 fewer-lots, BO1 flood, BP1 utilities, or BQ1 set release mults. Stacks multiplicatively with BQ1 only where both apply (none in MVP: BQ1 is sealed-only) |
| UI | Soft EventBanner copy OK ("Pro tour buzz: {archetype} decks"). Comp range / demand band / move feel warm only through today's §4.5 noisy path. Never shows `true_market`, `p_buy`, or the rolled mult |
| Untouched | BM1 drip, BN1 fewer-lots, BO1 flood, BP1 utilities, BQ1 set release, C1 hype spike, BK1 fair/gouge, BL1 cache clear, fee ladder, AR1 drift formula, fog Inspect, mismatch stay as shipped |
| Soft | Catalog untouched; leave Soft OK list-time suggested Soft |

**Acceptance:**

1. Same seed: Pro tour telegraphs ≥1 day before active; during the active window, a tagged single's hidden market is ×[1.30, 1.80] vs pre-event baseline (instrumented, same mult for all affected SKUs in that event); an untagged single and all sealed/accessories are unchanged by this event.
2. After duration ends, the mult no longer applies and base `true_market` resumes (no permanent compounding). A day with no Pro tour active does not invent the mult. Save/load restores active event, target tag, mult, and remaining days.
3. No screen shows `true_market`, `p_buy`, or the rolled mult. Listed prices and cash unchanged by the event alone. Buyer door spawn and whale weight unchanged. BM1/BN1/BO1/BP1/BQ1 unchanged.
4. Not a sell weight. Soft catalog CLOSED. No Art.

**Out:** STOP / win assert; camera off-switch; Soft OK list-time suggested persistence; listed-band / display-bonus Soft; Rotation / ban staples crash; sell-weight rewires; archetype-customer spawn bias; changing BM1/BN1/BO1/BP1/BQ1.

**Why now:** BQ1 closed the calendar sealed beat; Pro tour / influencer spike is the last named §8 event still dark (not Soft), and the archetype tags it needs already ship in the set bible — it adds the singles-side "stock depth vs FOMO" decision (§10 beat #7) with no Art.

---

## Option BR2 — STOP / win assert polish — **PARK**

**Why park:** No new Eng systems. Prefer the §8 Pro tour close this pick.

---

## Option BR3 — Persist list-time suggested (BK1 Soft OK) — **PARK Soft**

**Why park:** Soft catalog CLOSED.

---

## Option BR4 — Listed-band / display-bonus Soft — **PARK Soft**

**Why park:** Soft catalog CLOSED.

---

## Camera off-switch — **HARD PARK Soft**

**Why park (hard):** Reopens Soft catalog.

---

## Recommendation (non-binding)

**GO BR1** (Pro tour / influencer spike event). Park BR2/BR3/BR4. **Hard-park** the camera off-switch. Soft catalog stays closed. Soft OK list-time stays Soft. BM1/BN1/BO1/BP1/BQ1 untouched. Door/whale stay as shipped.

---

## PM checklist

- [x] Choose **BR1** (recommended)
- [x] If BR1: Eng vs §8 Pro tour — 1-day telegraph; one archetype tag's singles ×[1.30, 1.80] hidden market for 2 days, non-compounding; leave Soft OK list-time Soft; no Art; BM1/BN1/BO1/BP1/BQ1/buyer door/whale untouched
- [x] Sync this file to main before cloud agent
- [x] Soft catalog stays closed; STOP stays parked

---

## Decision log

| When | Decision |
|------|----------|
| 2026-10-05 ~5:21pm ET | Drafted post BQ1 SHIPPED #99 @ `3ab5bae2` (reviewed `3a59d2e5`). Lean **BR1 Pro tour / influencer spike event**. STOP / Soft reopeners parked. Camera off-switch hard-parked. Soft CLOSED. Soft OK list-time stays Soft. No Art. BM1/BN1/BO1/BP1/BQ1 stay as shipped. |
| 2026-10-05 ~5:21pm ET | **ADOPTED** BR1. Park BR2 STOP / BR3 Soft / BR4 Soft. Camera off-switch hard-parked. Soft CLOSED. Soft OK list-time stays Soft. No Art. Eng bar locked; awaiting tip-freeze. |
| 2026-10-05 ~5:33pm ET | **Tip-frozen** [#100](https://github.com/adamwlarson/cardshopsimulator/pull/100) @ `cc9b37b5` (branch `cursor/br1-pro-tour-spike-057a`). 8 files, no docs. Cloud agent bc-34c61709 archived. Eng review that SHA against bar `abcc8265`. QA held until APPROVE; no merge until PASS. Soft catalog CLOSED. |
