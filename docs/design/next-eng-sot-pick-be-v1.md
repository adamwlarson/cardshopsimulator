# Next Eng SoT Pick BE v1 — post BD1

**Status:** **BE1 ADOPTED** 2026-10-05 — Online fee cut at Rep ≥ 75 (8%→5% on ONLINE_HOLD). Spec on main `21e9cc18`. Park BE2/BE3/BE4. Hard-park camera off-switch. Soft catalog CLOSED. Net-worth HUD and STOP stay parked. Do not turn prior packs into a sell weight. Door spawn math stays as shipped.
**Author:** CSS Designer
**Date:** 2026-10-05
**Depends on:** pick-bd (BD1 Extend BB1 NM mismatch onto auction SHIPPED #86 @ `58fc3c13`); Soft catalog CLOSED
**Rule:** Pick **one**. §4.5 never leaks. Soft catalog stays closed. Hard-park camera off-switch Soft. Do **not** turn BD1, BC1, BB1, BA1, AZ1, AY1, AX1, AW1, AV1, AU1, AT1, AS1, AR1, AQ1, AP1, AO1, AN1, AM1, AL1, AK1, AJ1, AI1, AH1, AG1, AF1, AC1, AD1, or AE1 into a sell weight. HUD / STOP stay parked.

---

## Context (shipped)

| Pack | Result |
|------|--------|
| A–BD1 | Full loop + fog Inspect on all photo channels + NM mismatch on marketplace/shady/auction |
| Soft | Catalog CLOSED; AC1 through BD1 Soft OK MVP notes stay Soft |

**Gap:** §5.3 band 75–100 still owes **lower fees** (whale bias AJ1 + better leads AQ1 already shipped). Camera off-switch Soft hard-parked. HUD / STOP parked by PM.

---

## Option BE1 — Online fee cut at Rep ≥ 75 (systems §4.4 / §5.3) — **LEAN GO**

**Player fantasy:** At high Rep, online listings take a thinner cut — keeping trust pays out in margin.

| Deliverable | Spec |
|-------------|------|
| Where | Online listing settle only (§4.4 `ONLINE_HOLD` sales). Out: in-shop sales, buylist buys, distributor, auction Bid ask, trades |
| Gate | When a completed online sale settles its fee: Rep **≥ 75** uses the cut rate; Rep **≤ 74** stays today's **8%** |
| Cut | Fee becomes **5%** of the sale price (same cents rounding as today's 8% path). Not a refund of past fees |
| UI | Fee line can show the active %; never shows `true_market` or `p_buy` |
| Config | Missing cut rate falls back to **5**. Missing gate falls back to **75**. Base fee stays **8** below the gate |
| Untouched | Ship time 1–3 days, ONLINE_HOLD lock, cancel-Rep rules, AQ1 extra lead, AJ1 whale ×1.5, door spawn, fog Inspect, BB1/BD1 mismatch stay as shipped |
| Soft | Catalog untouched; leave AC1 through BD1 Soft OK alone |

**Acceptance:**

1. Same online sale seed: at Rep 74 fee is 8% of sale cents; at Rep 75 (and 100) fee is 5% of the same sale cents.
2. An in-shop sale at Rep 75 does not use the cut (shop path unchanged). ONLINE_HOLD and ship timing unchanged.
3. No screen shows `true_market` or `p_buy`. Declining or canceling listings still follows today's Rep rules.
4. Door spawn and whale weight are unchanged. Not a sell weight. Soft catalog CLOSED. No Art.

**Out:** Net-worth HUD; STOP; camera off-switch; listed-band retag UI; fee cuts on in-shop sales; sell-weight rewires.

**Why now:** Fog Inspect + mismatch loop is closed. §5.3's last 75–100 verb is lower fees.

---

## Option BE2 — Net-worth HUD — **PARK**

**Why park:** PM parked HUD unless Design leans one. Not leaning this pick.

---

## Option BE3 — STOP / win assert polish — **PARK**

**Why park:** PM parked STOP unless Design leans one. Not leaning this pick.

---

## Option BE4 — Listed-band retag UI (BB1 Soft) — **PARK Soft**

**Why park:** Soft catalog CLOSED. Eng Soft from BB1 stays Soft OK MVP.

---

## Camera off-switch — **HARD PARK Soft**

**Why park (hard):** Reopens Soft catalog.

---

## Recommendation (non-binding)

**GO BE1** (Online fee cut at Rep ≥ 75). Park BE2/BE3/BE4. **Hard-park** the camera off-switch. Soft catalog stays closed.

---

## PM checklist

- [x] Choose **BE1** (recommended)
- [x] If BE1: Eng vs systems §4.4 / §5.3 — online fee 8%→5% at Rep ≥ 75; leave door spawn and in-shop sales alone; no Art
- [x] Sync this file to main before cloud agent
- [x] Soft catalog stays closed; HUD / STOP stay parked

---

## Decision log

| When | Decision |
|------|----------|
| 2026-10-05 | Drafted post BD1 SHIPPED #86 @ `58fc3c13`. Lean **BE1 Online fee cut at Rep ≥ 75** (8%→5%). HUD / STOP / listed-band Soft parked. Camera off-switch hard-parked. |
| 2026-10-05 | PM ADOPTED **BE1**. Sync to main; Eng bar = this commit. Soft CLOSED. No Art. |
| 2026-10-05 | PM adopted **BE1**. Spec on main `21e9cc18`. Spike [BE1 Online fee cut](https://cursor.com/agents/bc-828a09a3-6751-51a1-9572-bfc5497b030f). Park BE2/BE3/BE4. No Art. Soft catalog CLOSED. Draft sha256 `e1228cf9`. |
| 2026-10-05 | Eng bar locked BE1 against `21e9cc18`. ONLINE_HOLD 8%→5% at Rep ≥ 75. Awaiting tip-freeze. |
| 2026-10-05 | PM tip-froze PR #87 @ `4b81341b`. Ready. 7 files, no docs. Agent archived. |
