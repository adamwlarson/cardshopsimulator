# Next Eng SoT Pick BL v1 — post BK1

**Status:** **ADOPTED** 2026-10-05 ~2:46pm ET — **BL1 Day-rollover clear of cached noisy suggested**. Park BL2 STOP / BL3 Soft / BL4 Soft. Camera off-switch hard-parked. Soft CLOSED. No Art. Eng bar locked; awaiting tip-freeze.
**Author:** CSS Designer
**Date:** 2026-10-05
**Depends on:** pick-bk (BK1 Fair / overprice settle Rep tick SHIPPED #93 @ `6a125022`); Soft catalog CLOSED
**Rule:** Pick **one**. §4.5 never leaks. Soft catalog stays closed. Hard-park camera off-switch Soft. Do **not** turn BK1, BJ1, BI1, BH1, BG1, BF1, BE1, BD1, BC1, BB1, BA1, AZ1, AY1, AX1, AW1, AV1, AU1, AT1, AS1, AR1, AQ1, AP1, AO1, AN1, AM1, AL1, AK1, AJ1, AI1, AH1, AG1, AF1, AC1, AD1, AE1, or AA1 into a sell weight. STOP stays parked.

---

## Context (shipped)

| Pack | Result |
|------|--------|
| A–BK1 | Full loop + online trust/save + fair/overprice settle Rep tick |
| Soft | Catalog CLOSED; AC1 through BK1 Soft OK MVP notes stay Soft |

**Gap:** BK1 QA S3 (not fail) — cached noisy suggested is **not cleared on day rollover**; HUD refreshes before Sell so play can mask it, but BK1's settle basis and UI can stick on yesterday's cache after AR1 drift. Soft OK list-time suggested persistence stays Soft (CLOSED). Camera off-switch Soft hard-parked. STOP parked.

---

## Option BL1 — Day-rollover clear of cached noisy suggested (systems §4.5 / BK1 basis) — **LEAN GO**

**Player fantasy:** A new day gets a fresh noisy comp — last night's sticker cache does not silently judge today's prices.

| Deliverable | Spec |
|-------------|------|
| Where | Calendar-day advance / open-prep after settle (same moment the day id flips). Also clear after AR1 overnight drift settles if that path keeps a suggested cache |
| Clear | Invalidate / drop any **cached noisy suggested** (and sibling position/move-feel caches keyed off it) for live SKUs so the next read re-rolls or re-derives today's §4.5 noisy suggested |
| Behavior | First HUD / PriceConfirm / BK1 sale log after rollover uses the new day's suggested — not yesterday's cached cents |
| Bounds | No new price verb. Do **not** persist list-time `suggested_at_list_cents` (BK1 Soft OK stays Soft). Do not surface `true_market` |
| UI | Existing chips refresh on next open; no new screen |
| Untouched | Fee ladder, soft cap, cancel day, listing save, BK1 fair/gouge mults, BF1 HUD formula, door spawn, whale weight, fog Inspect, mismatch stay as shipped |
| Soft | Catalog untouched; leave BK1 Soft OK (list-time suggested) Soft |

**Acceptance:**

1. Same seed: cache a suggested, advance calendar day (or settle+open with AR1 drift), next suggested read for that SKU is **not** the previous day's cached cents (re-derived).
2. BK1 fair/gouge on the new day compares against the post-clear suggested the player is shown — not a stale cache.
3. No screen shows `true_market` or `p_buy`. Soft OK list-time suggested persistence stays Soft (unchanged).
4. Door spawn and whale weight are unchanged. Not a sell weight. Soft catalog CLOSED. No Art.

**Out:** STOP / win assert; camera off-switch; listed-band retag UI; inventing list-time suggested persistence; sell-weight rewires.

**Why now:** BK1 just wired settle to noisy suggested; QA already flagged the day-rollover cache stale.

---

## Option BL2 — STOP / win assert polish — **PARK**

**Why park:** No new Eng systems. Prefer the cache clear this pick.

---

## Option BL3 — Persist list-time suggested on ONLINE_HOLD (BK1 Soft OK) — **PARK Soft**

**Why park:** Soft catalog CLOSED. Soft OK MVP stays Soft.

---

## Option BL4 — Listed-band retag UI / display-bonus Soft — **PARK Soft**

**Why park:** Soft catalog CLOSED.

---

## Camera off-switch — **HARD PARK Soft**

**Why park (hard):** Reopens Soft catalog.

---

## Recommendation (non-binding)

**GO BL1** (Day-rollover clear of cached noisy suggested). Park BL2/BL3/BL4. **Hard-park** the camera off-switch. Soft catalog stays closed.

---

## PM checklist

- [x] Choose **BL1** (recommended)
- [x] If BL1: Eng vs invalidate noisy-suggested cache on day rollover (+ post-AR1 drift if cached); leave Soft OK list-time persistence Soft; no Art
- [x] Sync this file to main before cloud agent
- [x] Soft catalog stays closed; STOP stays parked

---

## Decision log

| When | Decision |
|------|----------|
| 2026-10-05 | Drafted post BK1 SHIPPED #93 @ `6a125022`. Lean **BL1 Day-rollover clear of cached noisy suggested**. STOP / Soft reopeners parked. Camera off-switch hard-parked. |
| 2026-10-05 ~2:46pm ET | **ADOPTED** BL1. Park BL2 STOP / BL3 Soft / BL4 Soft. Camera off-switch hard-parked. Soft CLOSED. No Art. Eng bar locked; awaiting tip-freeze. |
| 2026-10-05 ~2:54pm ET | **Tip-frozen** [#94](https://github.com/adamwlarson/cardshopsimulator/pull/94) @ `2affb937` (branch `cursor/bl1-day-rollover-clear-suggested-76ae`). 4 files, no docs. Cloud agent bc-12d70111 archived. Eng review that SHA against bar `f35aae5f`. QA held until APPROVE; no merge until PASS. Soft catalog CLOSED. |
| 2026-10-05 ~2:59pm ET | **SHIPPED** — squash-merged [#94](https://github.com/adamwlarson/cardshopsimulator/pull/94) @ `78628a58` (reviewed `2affb937`). QA PASS-with-notes harness 136/0/0. Soft OK list-time stays Soft. Soft CLOSED. No Art. Next pick is BM. |
