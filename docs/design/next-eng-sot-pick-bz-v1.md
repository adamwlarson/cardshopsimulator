# Next Eng SoT Pick BZ v1 — post BY1

**Status:** SHIPPED — squash-merged #108 @ `df1fd35a` (reviewed `d1801c97`). QA PASS-with-notes harness 991/0/4 +4 Soft OK (list-time Soft; SceneTree GameState lookup Soft; line-before-condition Soft; trade/online greps Soft). Save key `sale_history`. Soft CLOSED. Soft OK list-time Soft. No Art. Docs status this commit.
**Author:** CSS Designer
**Date:** 2026-10-05
**Depends on:** pick-by (BY1 Regulars relationship stock SHIPPED #107 @ `44cb48e4`, reviewed `da5b39d7`; QA PASS-with-notes harness 885/0/4 +6 Soft OK; save key `regulars_return` `{queued, sku_id}`; docs status `6079a61c`); Soft catalog CLOSED
**Rule:** Pick **one**. §4.5 never leaks. Soft catalog stays closed. Hard-park camera off-switch Soft. Do **not** turn BY1, BX1, BW1, BV1, BU1, BT1, BS1, BR1, BQ1, BP1, BO1, BN1, BM1, BL1, BK1, BJ1, BI1, BH1, BG1, BF1, BE1, BD1, BC1, BB1, BA1, AZ1, AY1, AX1, AW1, AV1, AU1, AT1, AS1, AR1, AQ1, AP1, AO1, AN1, AM1, AL1, AK1, AJ1, AI1, AH1, AG1, AF1, AC1, AD1, AE1, or AA1 into a sell weight. STOP stays parked.

---

## Context (shipped)

| Pack | Result |
|------|--------|
| A–BY1 | Full loop + fair/overprice settle + suggested day-clear + buylist drip / fewer-lots / high-% flood + daily utilities + calendar set release hype + Pro tour archetype spike + Rotation staples crash + Distributor weekly restock menu + Recurring marketplace lots 1–3/day + Recurring player-trade pool + Auction snipe SKU pool + Shady trunk SKU pool + Regulars relationship stock |
| Soft | Catalog CLOSED; AC1 through BY1 Soft OK MVP notes stay Soft (incl. BY1 100M sentinel Soft; fallback clear in build Soft; listed-at-release Soft; pre-BY1 saves Soft; no-truth grep Soft; Soft OK list-time Soft) |

**Gap:** With BY1, every §3 channel row, every §8 named event, the §4.3 buylist suite, §4.4 online (fee cut / cancel Rep / soft cap / persist), §2.4 shrink mods, §5.3 band unlocks, and §6.3 hire/fire/Reliability are live. The one §4.5 buy-confirm line still dark (not Soft, not camera, not STOP) is **§4.5 A "Optional line (if history exists): 'Last sold similar in-shop: $X, N days ago' — factual, no forecast."** Read-only repo code search (`"Last sold"`) hits only `systems-design-v1.md` — no sale-history store, no buy-confirm line. So the player's own sell results never feed back into buy decisions: the §4.5 skill channel ("players can rank which deals were worse **above chance** using only on-screen signals") has only noisy comp + band + confidence, even after weeks of selling the same SKU. Soft OK list-time suggested stays Soft. Camera off-switch Soft hard-parked. STOP parked. (Named Regular cast, patience/budget buffs, archetype spawn bias, §5.2 inventory-mix spawn, §4.2 `staff_knowledge_mod` stay Out.)

---

## Option BZ1 — Buy-confirm "Last sold in-shop" history line (systems §4.5 A optional line) — **LEAN GO**

**Player fantasy:** "I sold one of these for $42 three days ago." Before you buy a lot, the confirm shows what *you* actually got for that SKU last time — a hard fact from your own register, not a forecast. Good sellers learn to buy better.

| Deliverable | Spec |
|-------------|------|
| Where | New small domain store `SaleHistory` (or a method on the existing sale/economy recorder) that records completed in-shop sales; read by the existing buy-confirm presenter for every BuyOpportunity channel (distributor / buylist / marketplace / auction / shady / trade). Logic lives in the store (record + lookup), not UI. Out: online sales history, price charts, sparklines, forecasts |
| Record | On each **completed in-shop sale** (listed or negotiated; counter / case / binder / pull), record `{sku_id, unit_price_cents, day}` — price actually paid by the customer, per unit. Keep only the **most recent** entry per `sku_id` (overwrite). Refunds / mismatch refunds do not create entries (and do not delete one). Online fills, walkouts, refusals, buylist buys, trades, fire-sale dumps outside the sale path: no entry |
| "Similar" | Same `sku_id` only (singles: same SKU regardless of condition; graded slabs: same SKU — v1 does not split by grade). No class-wide or set-wide fallback. No entry → line hidden (spec says "if history exists") |
| Line | Buy-confirm shows one factual line when an entry exists: `Last sold in-shop: $X, N days ago` (`N = today − day`; `0` → "today", `1` → "1 day ago"). For multi-SKU lots, show the line for the lot's primary `sku_id` only |
| Bounds | Display only. Does **not** change `p_buy`, `price_fit`, comp range, demand band, confidence, haggle odds, AR1 drift, door spawn, whale weight, BN1/BO1 seller weight, BK1 settle basis, suggested price, or any channel ask. Not a sell weight |
| Signal (§4.5) | The value is the player's own historic sale price — never `true_market`, never `p_buy`, never a comp midpoint, never "will sell for", never a forecast or trend arrow. Never shown on price confirm (B) this pick. QA instrumentation may add `last_sold_cents` / `last_sold_day` to `demand_signal_shown` (debug only) |
| UI | One text line in the existing buy-confirm panel under the comp/band block. No new screen. No Art |
| Save/load | Persist the per-SKU map (`sku_id → {unit_price_cents, day}`). Old saves without the key load with empty history (line hidden until next sale). Call out the new save key |
| Untouched | §4.5 A items 1–6, channel widths, BM1–BY1, AO1/BY1 Regulars, door/whale stay as shipped |
| Soft | Catalog untouched; leave Soft OK list-time suggested Soft |

**Acceptance:**

1. Same seed: sell SKU X in-shop at $P on day d. On day d+N, any buy-confirm whose (primary) SKU is X shows `Last sold in-shop: $P, N days ago`. A second sale at $Q overwrites to $Q / that day.
2. SKU never sold in-shop → no line. Online fill, buylist buy, trade, refund, walkout, or refusal never creates or changes an entry.
3. Buy-confirm never shows `true_market`, `p_buy`, or a forecast; comp range / band / confidence / ask and haggle odds are byte-identical with and without history.
4. Save/load restores the map; old saves load clean with empty history. Door spawn, whale weight, and BM1 through BY1 are unchanged.
5. Not a sell weight. Soft catalog CLOSED. No Art.

**Out:** STOP / win assert; camera off-switch; Soft OK list-time suggested persistence; listed-band retag / display-bonus Soft; price-confirm (B) history line; online sale history; multi-sale averages / charts / sparklines (§4.5 D); class- or set-level "similar" fallback; grade-split history; named Regular cast / multi-Regular roster; patience or budget streak buffs; archetype-customer spawn bias; §5.2 inventory-mix spawn mod (touches door spawn); §4.2 `staff_knowledge_mod` (would make Specialist a sell weight); sell-weight rewires; changing BM1–BY1 or door/whale.

**Why now:** BY1 closed the last §5.1 / §5.3 relationship half. The only §4.5 buy-confirm line still dark is the factual in-shop history line — it closes the loop from sell results back into buy reads (the §4.5 "rank deals above chance" probe) with zero truth leak, no new screen, no Art, no door/whale, no Soft. No Art.

---

## Option BZ2 — STOP / win assert polish — **PARK**

**Why park:** No new Eng systems. Prefer the §4.5 A history-line close this pick. Flagship / Survive Y1 / Liquidity already wired (R1/S1).

---

## Option BZ3 — Persist list-time suggested (BK1 Soft OK) — **PARK Soft**

**Why park:** Soft catalog CLOSED.

---

## Option BZ4 — Listed-band retag / display-bonus Soft — **PARK Soft**

**Why park:** Soft catalog CLOSED.

---

## Camera off-switch — **HARD PARK Soft**

**Why park (hard):** Reopens Soft catalog.

---

## Recommendation (non-binding)

**GO BZ1** (Buy-confirm "Last sold in-shop" history line). Park BZ2/BZ3/BZ4. **Hard-park** the camera off-switch. Soft catalog stays closed. Soft OK list-time stays Soft. BY1 Soft notes stay Soft. Named Regular cast, patience buffs, archetype spawn bias, and inventory-mix spawn stay Out (door/whale stay as shipped). BM1–BY1 untouched.

If PM judges BZ1 too thin to be load-bearing: §3 / §4–§9 systems rows are otherwise exhausted after BY1, so the honest alternative is **BZ2 STOP** (unpark) rather than reopening Soft.

---

## PM checklist

- [ ] Choose **BZ1** (recommended)
- [ ] If BZ1: Eng vs §4.5 A optional line. Record most-recent in-shop sale `{sku_id, unit_price_cents, day}` on completed in-shop sales only; buy-confirm shows `Last sold in-shop: $X, N days ago` when the SKU has history, else hidden. Display only — no change to comp / band / confidence / ask / haggle / `p_buy`. Persist map; call out new save key; old saves load empty. Leave Soft OK list-time Soft. No Art. BM1–BY1 / buyer door / whale / BN1–BO1 seller weight untouched
- [ ] Sync this file to main before cloud agent
- [ ] Soft catalog stays closed; STOP stays parked

---

## Decision log

| When | Decision |
|------|----------|
| 2026-10-05 ~9:35pm ET | Drafted post BY1 SHIPPED #107 @ `44cb48e4` (reviewed `da5b39d7`; docs status `6079a61c`). Lean **BZ1 Buy-confirm "Last sold in-shop" history line** (§4.5 A optional line). Read-only code search for `"Last sold"` hits only `systems-design-v1.md` — no sale-history store or confirm line. §3 channels / §8 events / §4.3–§4.4 / §5.3 / §6.3 otherwise live. STOP / Soft reopeners parked. Camera off-switch hard-parked. Soft CLOSED. Soft OK list-time stays Soft. BY1 Soft notes stay Soft. No Art. BM1–BY1 stay as shipped. |
| 2026-10-05 ~9:33pm ET | **ADOPTED** BZ1. Park BZ2 STOP / BZ3 Soft / BZ4 Soft. Camera off-switch hard-parked. Soft CLOSED. Soft OK list-time stays Soft. No Art. Eng bar locked; awaiting tip-freeze. |
| 2026-10-05 ~9:43pm ET | **Tip-frozen** [#108](https://github.com/adamwlarson/cardshopsimulator/pull/108) @ `5f49149b` (branch `cursor/bz1-last-sold-in-shop-ab41`). 6 files, no docs. New save key `sale_history`. Cloud agent bc-8711d38b archived. Eng review that SHA against bar `e21c83a3`. QA held until APPROVE; no merge until PASS. Soft catalog CLOSED. |
