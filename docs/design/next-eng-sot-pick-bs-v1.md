# Next Eng SoT Pick BS v1 — post BR1

**Status:** **SHIPPED** 2026-10-05 ~7:11pm ET — squash-merged [#101](https://github.com/adamwlarson/cardshopsimulator/pull/101) @ `d898492c` (reviewed `04191651`). QA PASS-with-notes harness 281/0/0. Soft CLOSED. Soft OK list-time Soft. No Art. Next pick is BT.
**Author:** CSS Designer
**Date:** 2026-10-05
**Depends on:** pick-br (BR1 Pro tour / influencer spike SHIPPED #100 @ `f4eb0ee6`); Soft catalog CLOSED
**Rule:** Pick **one**. §4.5 never leaks. Soft catalog stays closed. Hard-park camera off-switch Soft. Do **not** turn BR1, BQ1, BP1, BO1, BN1, BM1, BL1, BK1, BJ1, BI1, BH1, BG1, BF1, BE1, BD1, BC1, BB1, BA1, AZ1, AY1, AX1, AW1, AV1, AU1, AT1, AS1, AR1, AQ1, AP1, AO1, AN1, AM1, AL1, AK1, AJ1, AI1, AH1, AG1, AF1, AC1, AD1, AE1, or AA1 into a sell weight. STOP stays parked.

---

## Context (shipped)

| Pack | Result |
|------|--------|
| A–BR1 | Full loop + fair/overprice settle + suggested day-clear + buylist drip / fewer-lots / high-% flood + daily utilities + calendar set release hype + Pro tour archetype spike |
| Soft | Catalog CLOSED; AC1 through BR1 Soft OK MVP notes stay Soft |

**Gap:** Systems §8 still names **Rotation / ban** (signal: surprise or soft leak; effect: **staples crash**; lever: Research / Specialist). C1 shipped only the **leak half** — `soft_rotation_leak` binds `set_id` (default `AA-DUST`) and shows "Rotation watch: {set}" to Research-informed / Specialist players, but `_apply_event_effects` returns `true` with **no market effect** and revert is a no-op. The crash the leak foreshadows never lands, so paying for Research to dodge rotation has no payoff. Set bible §4.1 rotation hook ("oldest non-BASE set enters Extended — demand ↓ on tournament staples; casual/collect milder") and §8 (`staple` → "Rotation **hurts**") already define the target data. With BR1 the last other named §8 event is live; Rotation crash is the only §8 effect still dark and it is **not** Soft. Soft OK list-time suggested stays Soft. Camera off-switch Soft hard-parked. STOP parked.

---

## Option BS1 — Rotation staples crash event (systems §8 Rotation / ban) — **LEAN GO**

**Player fantasy:** The Specialist mutters "Dustway's rotating out" — dump those staples now, or eat the crash when the format moves on. Skip the Research and it hits you cold.

| Deliverable | Spec |
|-------------|------|
| Where | Named §8 market event `rotation_crash` on the same settle-rolled event bus C1 / Convention / Set release / Pro tour use. Reuses the shipped `soft_rotation_leak` as its telegraph. Out: rewriting C1 leak copy / gating; Set release (BQ1) sealed mults; Pro tour (BR1) archetype mult; door-spawn or whale weight bumps; BM1/BN1/BO1/BP1/BQ1/BR1 |
| Signal | **Soft leak path:** when a `soft_rotation_leak` event ends, a `rotation_crash` for the **same `set_id`** becomes the next active event at that settle (scheduled, not re-rolled). Leak visibility stays exactly as shipped (Research-informed or Specialist on duty only) — uninformed players feel it as a surprise. **Surprise path:** `rotation_crash` may also roll directly from the catalog with no leak; missing `rotation_crash_surprise_weight` → **0.5** (vs default 1.0). Missing `rotation_crash_duration_days` → **5** |
| Target | `set_id` from the leak (default `MarketEventService.ROTATION_SET_ID` = `AA-DUST`); surprise path uses the oldest non-BASE set in the live catalog. `AA-BASE` (evergreen) **never** rotates — bind fails rather than target it. **Singles** (CardInstance) whose CardDef is in that set are affected; graded slabs follow the card ref. Sealed / accessories are **out** |
| Effect | While active: that set's `staple`-tagged singles read hidden `true_market` via a non-compounding event mult `rotation_crash_mult`, seeded once per event in [`rotation_crash_mult_min`, `rotation_crash_mult_max`]. Missing min → **0.45**. Missing max → **0.70**. Other non-`bulk` singles in the set (casual / collect / `chase-faded`) get milder `rotation_mild_mult`; missing → **0.90**. `bulk` unchanged. Min ≤ 0, max < min, max > 1, or mild ∉ (0, 1] fall back to those defaults. Mult is a modifier, **not** baked into AR1 drift — when the event ends the base value resumes. Does **not** rewrite listed prices or cash |
| Lever | Informed player can fire-sell or reprice that set's staples during the leak window, stop buying them, or buy the dip after. Uninformed player eats the crash. Existing buy channels that derive ask/comp from `true_market` read the modified value — no new channel rewires. No soft-lock |
| Bounds | Max **one** Rotation crash active at a time; bus still holds one active event, so no overlap with BQ1/BR1 in MVP (if Eng finds overlap, multiplicative, never additive). Does **not** change buyer door spawn, whale weight, BM1 drip, BN1 fewer-lots, BO1 flood, BP1 utilities, BQ1 set release mults, or BR1 Pro tour mult |
| UI | Soft EventBanner copy OK for **all** players while active ("Rotation: {set} staples cooling"). Comp range / demand band / move feel cool only through today's §4.5 noisy path; no-fog rule holds (no Hot↔Cold inversion shown without fog flag). Never shows `true_market`, `p_buy`, or the rolled mult |
| Untouched | C1 leak gating + "Rotation watch" copy, BM1 drip, BN1 fewer-lots, BO1 flood, BP1 utilities, BQ1 set release, BR1 Pro tour, C1 hype spike, BK1 fair/gouge, BL1 cache clear, fee ladder, AR1 drift formula, fog Inspect, mismatch stay as shipped |
| Soft | Catalog untouched; leave Soft OK list-time suggested Soft |

**Acceptance:**

1. Same seed: a `soft_rotation_leak` on set S, when it ends, is followed at that settle by a `rotation_crash` on S. During the crash window, a `staple` single in S has hidden market ×[0.45, 0.70] vs pre-event baseline (instrumented, same mult for every affected staple in that event); a non-bulk non-staple single in S is ×0.90; `bulk` singles in S, singles in other sets, `AA-BASE`, and all sealed / accessories are unchanged by this event. A surprise-rolled crash (no leak) applies the same effect.
2. After duration ends, the mults no longer apply and base `true_market` resumes (no permanent compounding). A day with no Rotation crash active does not invent the mults. The leak alone still has no market effect. `AA-BASE` is never targeted. Save/load restores active crash, `set_id`, mult, remaining days, and a pending leak→crash follow-on.
3. Leak visibility unchanged (Research-informed / Specialist only). No screen shows `true_market`, `p_buy`, or the rolled mult. Listed prices and cash unchanged by the event alone. Buyer door spawn and whale weight unchanged. BM1/BN1/BO1/BP1/BQ1/BR1 unchanged.
4. Not a sell weight. Soft catalog CLOSED. No Art.

**Out:** STOP / win assert; camera off-switch; Soft OK list-time suggested persistence; listed-band / display-bonus Soft; single-card **ban** variant; permanent Extended set status / format calendar; sealed rotation dump mults; archetype-customer spawn bias; sell-weight rewires; changing C1 leak gating or BM1/BN1/BO1/BP1/BQ1/BR1.

**Why now:** BR1 closed the last other named §8 event; Rotation / ban is the only §8 effect still dark (not Soft) — C1's leak telegraphs a crash that never lands, so the Research / Specialist lever (§4.5 gates, §10 "FOMO vs staples") has no payoff until the staples crash ships. No Art.

---

## Option BS2 — STOP / win assert polish — **PARK**

**Why park:** No new Eng systems. Prefer the §8 Rotation crash close this pick.

---

## Option BS3 — Persist list-time suggested (BK1 Soft OK) — **PARK Soft**

**Why park:** Soft catalog CLOSED.

---

## Option BS4 — Listed-band / display-bonus Soft — **PARK Soft**

**Why park:** Soft catalog CLOSED.

---

## Camera off-switch — **HARD PARK Soft**

**Why park (hard):** Reopens Soft catalog.

---

## Recommendation (non-binding)

**GO BS1** (Rotation staples crash event). Park BS2/BS3/BS4. **Hard-park** the camera off-switch. Soft catalog stays closed. Soft OK list-time stays Soft. Archetype-customer spawn bias stays Out (touches door-spawn weights; door/whale stay as shipped). BM1/BN1/BO1/BP1/BQ1/BR1 untouched.

---

## PM checklist

- [x] Choose **BS1** (recommended)
- [x] If BS1: Eng vs §8 Rotation / ban — leak→crash follow-on on same set (+ surprise roll weight 0.5); set's `staple` singles ×[0.45, 0.70], other non-bulk singles ×0.90 hidden market for 5 days, non-compounding; `AA-BASE` never rotates; leave C1 leak gating + Soft OK list-time Soft; no Art; BM1/BN1/BO1/BP1/BQ1/BR1/buyer door/whale untouched
- [x] Sync this file to main before cloud agent
- [x] Soft catalog stays closed; STOP stays parked

---

## Decision log

| When | Decision |
|------|----------|
| 2026-10-05 ~5:45pm ET | Drafted post BR1 SHIPPED #100 @ `f4eb0ee6` (reviewed `cc9b37b5`). Lean **BS1 Rotation staples crash event** (C1 leak shipped with no market effect — verified `soft_rotation_leak` apply/revert are no-ops on main). STOP / Soft reopeners parked. Camera off-switch hard-parked. Soft CLOSED. Soft OK list-time stays Soft. No Art. Archetype-customer spawn bias stays Out. BM1/BN1/BO1/BP1/BQ1/BR1 stay as shipped. |
| 2026-10-05 ~5:46pm ET | **ADOPTED** BS1. Park BS2 STOP / BS3 Soft / BS4 Soft. Camera off-switch hard-parked. Soft CLOSED. Soft OK list-time stays Soft. No Art. Eng bar locked; awaiting tip-freeze. Live Dustway may lack staple tags — Eng fixtures for acceptance; Soft CLOSED so no catalog Soft reopen. |
| 2026-10-05 ~5:56pm ET | **Tip-frozen** [#101](https://github.com/adamwlarson/cardshopsimulator/pull/101) @ `04191651` (branch `cursor/bs1-rotation-staples-crash-06fb`). 8 files, no docs. Cloud agent bc-cf45a9ac archived. Eng review that SHA against bar `ba3fbd4d`. QA held until APPROVE; no merge until PASS. Soft catalog CLOSED. |
| 2026-10-05 ~7:11pm ET | **SHIPPED** — squash-merged [#101](https://github.com/adamwlarson/cardshopsimulator/pull/101) @ `d898492c` (reviewed `04191651`). QA PASS-with-notes harness 281/0/0. Soft OK list-time stays Soft. Soft CLOSED. No Art. Next pick is BT. |
