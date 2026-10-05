# Next Eng SoT Pick BT v1 — post BS1

**Status:** **ADOPTED** 2026-10-05 ~7:16pm ET — BT1 Distributor weekly restock menu. Eng bar = this file on main after sync. Soft CLOSED. Soft OK list-time Soft. No Art. Park BT2 STOP / BT3 Soft / BT4 Soft. Camera hard-parked.
**Author:** CSS Designer
**Date:** 2026-10-05
**Depends on:** pick-bs (BS1 Rotation staples crash SHIPPED #101 @ `d898492c`, reviewed `04191651`; docs status `62169448`); Soft catalog CLOSED
**Rule:** Pick **one**. §4.5 never leaks. Soft catalog stays closed. Hard-park camera off-switch Soft. Do **not** turn BS1, BR1, BQ1, BP1, BO1, BN1, BM1, BL1, BK1, BJ1, BI1, BH1, BG1, BF1, BE1, BD1, BC1, BB1, BA1, AZ1, AY1, AX1, AW1, AV1, AU1, AT1, AS1, AR1, AQ1, AP1, AO1, AN1, AM1, AL1, AK1, AJ1, AI1, AH1, AG1, AF1, AC1, AD1, AE1, or AA1 into a sell weight. STOP stays parked.

---

## Context (shipped)

| Pack | Result |
|------|--------|
| A–BS1 | Full loop + fair/overprice settle + suggested day-clear + buylist drip / fewer-lots / high-% flood + daily utilities + calendar set release hype + Pro tour archetype spike + Rotation staples crash |
| Soft | Catalog CLOSED; AC1 through BS1 Soft OK MVP notes stay Soft (incl. BS1 lexicographic oldest `set_id`; mild mult re-read on load) |

**Gap:** With BS1 every named §8 event is live. The clearest systems SoT gap still dark (not Soft) is the **Distributor channel cadence** — systems §3 names Distributor as a **Weekly restock menu** (MSRP − 30–40%, perfect SKUs, sealed / accessories only, MOQ, cash lock), and wireflows §2 Prep list expects "distributor weekly + marketplace lots + scripted beats". On main (`62169448`) the only distributor lines are the scripted `skiefall-distributor-moq-day-2` entry in `data/buy_opportunities.json` (`last_day` 2) and the Q1 Supply glut restock lots (only while a glut is active). After day 2 a player who sells through their sealed / accessories has **no regular way to restock them** — the §0 goal "liquidity vs stockout" (§10 beat #2) and the AP1 Rep ≤ 24 MOQ penalty only bite once. Pricing (`PricingService.distributor_wholesale_cents`), MOQ (`distributor_minimum_units`, AP1), glut wholesale (`sealed_wholesale_cents`, Q1) and the High-confidence distributor signal already ship; nothing schedules the weekly menu. Soft OK list-time suggested stays Soft. Camera off-switch Soft hard-parked. STOP parked.

---

## Option BT1 — Distributor weekly restock menu (systems §3) — **LEAN GO**

**Player fantasy:** Rent cleared yesterday, and the distributor's weekly sheet just landed. Lock cash into a deep sealed order now, take a light mix, or skip it and risk an empty shelf until next week.

| Deliverable | Spec |
|-------------|------|
| Where | Recurring distributor `BuyOpportunity` lines built at PREP open in the existing `_open_opportunities()` path (same list as catalog / scripted / glut / AQ1 / AS1 / AT1 lines). Logic lives in a policy class (e.g. `DistributorMenuPolicy`), not UI. Out: rewriting the day-2 scripted MOQ beat; Supply glut lots; marketplace / auction / shady / buylist / player-trade channels; door-spawn or whale weight |
| Cadence | Menu day = `day ≥ distributor_menu_first_day` and `(day − distributor_menu_first_day) % distributor_menu_interval_days == 0`. Missing first day → **8** (week 1 is covered by the shipped day-2 MOQ beat; lands the day after first rent). Missing interval → **7**. Bad values (≤ 0) fall back to those defaults. Lines are open for that menu day only (PREP + any existing mid-day buy window); unbought lines expire at that day's close settle and do not carry over |
| Lines | One line per live-catalog SKU of class **SEALED** or **ACCESSORY** (MVP live catalog: `AA-SKIE-ETB`, `AA-SKIE-BLST`, `AA-DUST-ETB`, `ACC-SLV-60`, `ACC-TOP-25`). Singles and graded are **never** on the menu. Deterministic ids `distributor-weekly-d{day}-{sku}` so save/load and closed-id checks are stable. Offer label "Weekly restock" |
| Price | `unit_cost_cents` = shipped `PricingService.distributor_wholesale_cents(base market, config)` (MSRP − 30–40%). Effective cost goes through the shipped `_effective_unit_cost_cents` path, so an active Supply glut discounts sealed lines exactly as Q1 shipped — no new discount |
| MOQ | Base MOQ per line: missing `distributor_menu_moq_sealed` → **6**; missing `distributor_menu_moq_accessory` → **10**; ≤ 0 falls back. Final minimum through shipped `distributor_minimum_units` — AP1 Rep ≤ 24 doubling applies as shipped. Player may buy ≥ MOQ (existing quantity path); below MOQ is rejected as today |
| Bounds | Cash and space hard blockers as shipped (§2.3 "cannot list what you cannot store"). Buying one line closes only that line. No haggle change (distributor haggle odds as shipped). Does **not** change buyer door spawn, whale weight, BM1 drip, BN1 fewer-lots, BO1 flood, BP1 utilities, BQ1 set release, BR1 Pro tour, BS1 rotation crash, AR1 drift |
| Signal | Buy-confirm shows the shipped distributor contract: exact ask, comp range (w 0.06), demand band, **High** confidence, "NM assumed" / sealed cue, cash & space check. Comp / band read hidden market through the §4.5 noisy path, so live BQ1 / BS1 / glut effects show only as noisy signal. Never shows `true_market`, `p_buy`, wholesale discount %, or future menu contents |
| UI | Existing Prep list row per line, grouped with other opportunities. Soft toast copy OK on menu day ("Distributor weekly sheet is in"). No new screen. No Art |
| Save/load | Saving mid-menu-day and loading restores the open menu lines and which were already bought (no double-buy, no re-offer of a closed line). Loading on a non-menu day shows no menu lines |
| Untouched | Day-2 scripted MOQ beat (§10 #2), Supply glut restock lots, AP1 MOQ policy, AQ1 extra marketplace lead, AS1 snipe, AT1 trunk, distributor wholesale formula, BM1 through BS1, fee ladder, fog Inspect, mismatch stay as shipped |
| Soft | Catalog untouched; leave Soft OK list-time suggested Soft |

**Acceptance:**

1. Same seed, defaults: days 8, 15, 22 each open a distributor menu with exactly one line per live SEALED / ACCESSORY SKU and no singles / graded; days 3–7, 9–14, 16–21 open none. Day 1–2 opportunities are unchanged from main (scripted MOQ beat still there, no extra menu).
2. Each line's unit cost equals `distributor_wholesale_cents` for that SKU (and the glut-discounted effective cost while Supply glut is active); MOQ is 6 sealed / 10 accessory at Rep ≥ 25 and the AP1-doubled value at Rep ≤ 24. Buying ≥ MOQ adds stock and debits cash; below MOQ, over cash, or over space is blocked as today.
3. Unbought lines are gone the next day; a bought line is not re-offered that day. Save/load mid-menu-day restores open vs closed lines. Bad config values fall back to defaults.
4. Buy-confirm shows High confidence and no `true_market`, `p_buy`, or discount %. Buyer door spawn and whale weight unchanged. BM1/BN1/BO1/BP1/BQ1/BR1/BS1 unchanged.
5. Not a sell weight. Soft catalog CLOSED. No Art.

**Out:** STOP / win assert; camera off-switch; Soft OK list-time suggested persistence; listed-band / display-bonus Soft; recurring marketplace lots "1–3/day" (§3 — separate channel, next candidate); menu SKU randomisation / rotating "boring mix"; pre-order / allocation; distributor email telegraph beyond Q1; single-card ban variant; permanent Extended set status; sealed rotation dump; archetype-customer spawn bias; §5.2 inventory-mix spawn mod (touches door spawn); §4.2 `staff_knowledge_mod` (would make Specialist a sell weight); sell-weight rewires; changing BM1–BS1 or the day-2 beat.

**Why now:** §8 is fully live after BS1, and the Distributor "weekly restock menu" in systems §3 is the most load-bearing SoT row still dark — without it sealed / accessories cannot be restocked after day 2, so the liquidity-vs-stockout tradeoff (§0 goal 1, §10 #2) and AP1's MOQ penalty only ever fire once. All parts (wholesale formula, MOQ, glut, High-confidence signal) already ship; BT1 just schedules them. No Art.

---

## Option BT2 — STOP / win assert polish — **PARK**

**Why park:** No new Eng systems. Prefer the §3 distributor cadence close this pick.

---

## Option BT3 — Persist list-time suggested (BK1 Soft OK) — **PARK Soft**

**Why park:** Soft catalog CLOSED.

---

## Option BT4 — Listed-band / display-bonus Soft — **PARK Soft**

**Why park:** Soft catalog CLOSED.

---

## Camera off-switch — **HARD PARK Soft**

**Why park (hard):** Reopens Soft catalog.

---

## Recommendation (non-binding)

**GO BT1** (Distributor weekly restock menu). Park BT2/BT3/BT4. **Hard-park** the camera off-switch. Soft catalog stays closed. Soft OK list-time stays Soft. BS1 Soft notes stay Soft. Archetype-customer spawn bias and inventory-mix spawn stay Out (door/whale stay as shipped). BM1–BS1 untouched.

---

## PM checklist

- [x] Choose **BT1** (recommended)
- [x] If BT1: Eng vs §3 Distributor — weekly menu from day 8 every 7 days; one line per live SEALED / ACCESSORY SKU at shipped `distributor_wholesale_cents`; MOQ 6 sealed / 10 accessory through shipped AP1 `distributor_minimum_units`; glut discount via shipped path; lines expire at close; save/load restores open/closed lines; leave day-2 beat + Soft OK list-time Soft; no Art; BM1–BS1 / buyer door / whale untouched
- [x] Sync this file to main before cloud agent
- [x] Soft catalog stays closed; STOP stays parked

---

## Decision log

| When | Decision |
|------|----------|
| 2026-10-05 ~7:15pm ET | Drafted post BS1 SHIPPED #101 @ `d898492c` (reviewed `04191651`). Lean **BT1 Distributor weekly restock menu** — verified on main `62169448`: `data/buy_opportunities.json` distributor line ends day 2 and only Supply glut adds distributor lots afterwards; no recurring menu. STOP / Soft reopeners parked. Camera off-switch hard-parked. Soft CLOSED. Soft OK list-time stays Soft. BS1 Soft notes stay Soft. No Art. BM1–BS1 stay as shipped. |
| 2026-10-05 ~7:16pm ET | **ADOPTED** BT1. Park BT2 STOP / BT3 Soft / BT4 Soft. Camera off-switch hard-parked. Soft CLOSED. Soft OK list-time stays Soft. No Art. Eng bar locked; awaiting tip-freeze. |
