# Next Eng SoT Pick AX v1 — post AW1

**Status:** **AX1 ADOPTED** 2026-10-05 — Edit You offer mid-serve. Park AX2/AX3/AX4. Hard-park camera off-switch. Soft catalog CLOSED. Fees, net-worth HUD, and STOP stay parked. Do not turn rep bands, trades, shrink, walkouts, Fire, AU1 haggle, AV1 Negotiate, or AW1 buylist into a sell weight. Door spawn math stays as shipped.
**Author:** CSS Designer
**Date:** 2026-10-05
**Depends on:** pick-aw (AW1 Buylist buy-from-them SHIPPED #79 @ `d5f21d1a`); Soft catalog CLOSED
**Rule:** Pick **one**. §4.5 never leaks. Soft catalog stays closed. Hard-park camera off-switch Soft. Do **not** turn AW1, AV1, AU1, AT1, AS1, AR1, AQ1, AP1, AO1, AN1, AM1, AL1, AK1, AJ1, AI1, AH1, AG1, AF1, AC1, AD1, or AE1 into a sell weight. Fees / HUD / STOP stay parked.

---

## Context (shipped)

| Pack | Result |
|------|--------|
| A–AW1 | Full loop + buy/sell verbs + buylist You offer Buy/Walk |
| Soft | Catalog CLOSED; AC1 through AW1 Soft OK MVP notes stay Soft |

**Gap:** Mid-serve edit of You offer (systems §4.3 "you set offer") still dark. Fee cut stays parked. Camera off-switch Soft hard-parked. Fees / HUD / STOP parked by PM.

---

## Option AX1 — Edit You offer mid-serve (systems §4.3) — **LEAN GO**

**Player fantasy:** On a buylist walk-in, you can change the bid once before you buy or walk — stingy still risks a sour exit.

| Deliverable | Spec |
|-------------|------|
| Where | AW1 buylist `CustomerServe` only (customer selling to the shop). Out: shop-buy serve, AU1 Counter, auction, trades, trunk |
| Actions | **Buy**, **Walk**, and one **Change offer**. Default You offer stays as AW1 |
| Change offer | Once per serve. Player sets cents ≥ 1¢. Label stays **You offer**. No Attention cost. A second Change is refused. Change does not Buy or Walk |
| Buy / Walk | Same as AW1 against the **current** You offer (default or edited). Short-cash Buy moves nothing. Anger floor still `offer / listed_comp < 0.40` → Rep −1 once on Walk |
| Untouched | Buylist % defaults, Medium / width 0.10, fee 8%, buyer door spawn, whale weight, AV1 Negotiate, AU1 Counter stay as shipped |
| UI | Never shows `true_market` or the anger ratio as a number |
| Soft | Catalog untouched; leave AC1 through AW1 Soft OK alone |

**Acceptance:**

1. Same buylist serve: default You offer still matches AW1. One Change offer sets cents ≥ 1¢ and keeps the **You offer** label. A second Change is refused.
2. Buy after an edit pays the edited cents into backstock. Walk after an edit uses the edited offer for the 0.40 anger floor (Rep −1 once when below; else unchanged).
3. Change spends no Attention. Shop-buy Negotiate and buy Counter stay out of this path. No screen shows `true_market`.
4. Buyer door spawn and whale weight are unchanged. Marketplace fee stays 8%. Not a sell weight. Soft catalog CLOSED. No Art.

**Out:** A fee cut; net-worth HUD; STOP; camera off-switch; multi-edit bargain chains; sell-weight rewires.

**Why now:** AW1 locked the default-% Buy/Walk. §4.3 still wants the player to set the offer once on the desk.

---

## Option AX2 — Marketplace fee cut at Rep ≥ 75 — **PARK**

**Why park:** PM parked fee cuts. The 8% stays.

---

## Option AX3 — Net-worth HUD / STOP — **PARK**

**Why park:** PM parked both this pick.

---

## Option AX4 — Buylist Inspect gate polish — **PARK**

**Why park:** Real §2.2 / §4.5 line. Mid-serve offer edit is the open AW1 follow. Inspect can follow.

---

## Camera off-switch — **HARD PARK Soft**

**Why park (hard):** Reopens Soft catalog.

---

## Recommendation (non-binding)

**GO AX1** (Edit You offer mid-serve). Park AX2/AX3/AX4. **Hard-park** the camera off-switch. Soft catalog stays closed.

---

## PM checklist

- [x] Choose **AX1** (recommended)
- [x] If AX1: Eng vs systems §4.3 one Change offer on AW1 serve; leave fees and buyer door spawn alone; no Art
- [x] Sync this file to main before cloud agent
- [x] Soft catalog stays closed; fees / HUD / STOP stay parked

---

## Decision log

| When | Decision |
|------|----------|
| 2026-10-05 | Drafted post AW1 SHIPPED #79 @ `d5f21d1a`. Lean **AX1 Edit You offer mid-serve**. Fee cut / HUD / STOP / Inspect polish parked. Camera off-switch hard-parked. |
| 2026-10-05 | PM adopted **AX1**. Park AX2/AX3/AX4. Hard-park camera off-switch. Soft catalog CLOSED. One Change offer on the AW1 buylist serve. Draft sha256 `64b45fc6`. |
