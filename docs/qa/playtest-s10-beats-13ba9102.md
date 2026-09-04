# Playtest report — MVP §10 beats #4/#7/#8 @ `13ba9102` (PR #7 beat hooks → main)
**Scorer:** CSS QA  
**Date:** 2026-09-04 (~1:53 AM ET)  
**Build:** `adamwlarson/cardshopsimulator` tip `13ba9102` (tree `/workspace/qa-playtest/tip7/`)  
**Mode:** **Normal** (`data/balance/normal.tres`)  
**Scope:** Formal §10 #4 Spike Bastion/Arcbolt · #7 Titan hype PriceEditor · #8 Empress slab vs singles + truth nack + light regression (warm-up A–F, BuyOpportunityList #1/#2, multi-SKU price, You offer)  
**Method:** Headless Godot 4.5.2 — foundation `tests/test_runner.gd` + new `tests/qa_s10_beats_playtest.gd`  
**Design SoT:** `docs/design/ui-wireflows-v1.md` §5.1; `docs/design/systems-design-v1.md` §4.5 / §10

## Executive verdict

| Gate | Result |
|------|--------|
| Truth leak nack (`true_market` / exact `p_buy` / `cert_valid` in UI) | **PASS** — no S1 |
| Foundation unit tests | **PASS** (`All foundation tests passed.`) |
| Warm-up A–F | **PASS** |
| BuyOpportunityList §10 #1/#2 + multi-SKU price + You offer | **PASS** (no regression) |
| §10 #4 Spike Bastion/Arcbolt | **PASS** — injectable + natural day-3 FLOOR |
| §10 #7 Titan hype PriceEditor | **PASS** — phase-stable refocus; ×1.35 once; Apply/Cancel/ignored |
| §10 #8 Empress slab vs singles | **PASS** — reachable; reversible; capacity guard |
| Hype stack check (re-focus / re-open) | **PASS** — market cents unchanged (2970→2970) |
| Phase-stability (PREP→FLOOR) | **PASS** — deferred `price_focus_requested`; beat stays pending |

**Overall:** **PASS** for formal MVP §10 #4/#7/#8 on Normal at tip `13ba9102`. Beat hooks from PR #7 are reachable without cheats in day windows; fairness/truth gates remain green.

## Executive table (per-beat)

| Beat | Reachable | Decision path | Fairness / truth | Verdict |
|------|-----------|---------------|------------------|---------|
| #4 `sec10_4_spike_staple` | Day 3–5 FLOOR (natural day 3); QA trigger | Spike wants Bastion/`AA-BASE-088` (or Arcbolt); Sell/Negotiate/Refuse; completes on resolve | CustomerServe uses **Your list**; no truth tokens | **PASS** |
| #7 `sec10_7_titan_hype` | Day 8–10 PREP (natural day 8); QA trigger | Toast “Hype: Skiefall Titan” → PriceEditor focus; HOT + elevated suggest; Apply/Cancel/ignored@SETTLE | No `true_market` in presenter; hype ×1.35 once | **PASS** |
| #8 `sec10_8_slab_vs_singles` | Day 10–12 PREP after Titan resolved; QA trigger | Modal “Showcase tight — pick display”; slab **or** both singles; reversible same day | Over-capacity rejected + `showcase_choice_failed` | **PASS** |

## Warm-up A–F + light regression (observed)

| Beat | Result | Evidence |
|------|--------|----------|
| A Orient | PASS | Cash `$8000.00` (800000¢), Day 1 PREP, seed `AA-DUST-ETB` qty=2 |
| B First buy signals | PASS | Dustway marketplace + Skiefall distributor MOQ; A1–A6; Ask rows |
| C Price set | PASS | Multi-SKU priceable stock; Dustway noisy suggest `$45.35` |
| D Floor | PASS | `start_floor` → FLOOR; attention spend OK |
| E Settle | PASS | `start_settle` → SETTLE |
| F Day 2 | PASS | day 2 PREP |
| Multi-SKU price | PASS | Sealed + ACC + named singles (Bastion/Arcbolt/Titan) in list |
| You offer | PASS | `buylist_seller_summary` + HUD `SELLING_TO_SHOP` |
| §10 #1/#2 | PASS | Dustway priceable + BuyOpportunityList Dustway + distributor MOQ |

Sample opportunity rows:
```
Marketplace · Dustway Chronicles Explorer Box · AA-DUST-ETB ×2
Ask $48.00 · STEADY · Low confidence

Distributor · Skiefall Ascension Blaster · AA-SKIE-BLST ×8
Ask $144.00 · STEADY · High confidence
```

Sample Titan hype price presenter (§10 #7):
```
Suggested (noisy): $31.11
Vs suggestion: -$9.11 (-29%)
Position: Undercut · Demand: HOT
Move feel: Should Move · Binder
```

## §10 #4 — Spike wants last staple (Bastion/Arcbolt)

| Check | Result | Evidence |
|-------|--------|----------|
| `beat_id` | PASS | `sec10_4_spike_staple` |
| QA inject on FLOOR | PASS | `trigger_qa_beat` seeds exactly 1 Bastion NM when missing |
| Prefers Bastion when present | PASS | `desired_skus[0] == AA-BASE-088` |
| Spike archetype + name | PASS | `spike` / `Spike`; tagged `beat_id` |
| CustomerServe path | PASS | HUD Sell / Negotiate / Refuse + **Your list** via `CUSTOMER_BUYING_FROM_SHOP` |
| Resolve completes beat | PASS | `customer_resolved` → completed (`refused` in harness) |
| Natural Normal window | PASS | First FLOOR on day 3 auto-starts Spike + emits scripted customer |

## §10 #7 — Titan hype PriceEditor

| Check | Result | Evidence |
|-------|--------|----------|
| Seed Titan NM | PASS | `AA-SKIE-047` present after trigger |
| Hype event | PASS | `apply_hype_event(..., 1.35)`; market 2200→**2970** (=×1.35) |
| HOT band + elevated suggest | PASS | `shown_demand_band=hot`; suggest `$31.11` > 2200¢ list |
| `price_focus_requested` | PASS | SKU Titan, beat tag, toast “Hype: Skiefall Titan”; initial count=1 |
| Phase-stable PREP→FLOOR | PASS | HUD `_close_price` on phase change; BeatDirector deferred `_refocus_titan_after_phase_change` re-emits focus; beat **not** completed by phase change |
| Hype does not stack on re-focus/re-open | PASS | market 2970→2970 after 2nd/3rd focus; listed unchanged; day-path `_start_day_beats` while pending does not re-apply |
| Resolve Apply | PASS | `beat_ui_resolved` applied → completed |
| Resolve Cancel | PASS | cancelled → completed |
| Resolve ignored | PASS | SETTLE while pending → outcome `ignored` |
| Natural day 8 | PASS | day_started / `_start_day_beats` starts Titan; HOT persists |

**Note:** Phase change closes the PriceEditor panel (clears `_active_price_beat_id` without emitting cancelled) then deferred refocus reopens on FLOOR — matches §5.1 “opens cleanly at FLOOR start (deferred `price_focus_requested` OK)”. Dying on phase change would be S2; not observed.

## §10 #8 — Empress slab vs chase singles

| Check | Result | Evidence |
|-------|--------|----------|
| Seeds Empress Prism 10 + Titan + Paragon | PASS | `AA-SKIE-052` slab, `AA-SKIE-047`, `AA-SKIE-058` |
| Free case ≥2 | PASS | free_slot_weight=24 at start in harness |
| Modal payload | PASS | title “Showcase tight — pick display”; Empress / Titan+Paragon labels |
| Choose slab | PASS | slab → CASE |
| Switch to singles (reversible) | PASS | slab leaves CASE; both singles in CASE |
| Capacity guard | PASS | stuffed case → `choose_showcase(singles)` false + `showcase_choice_failed` |
| HUD ShowcaseChoice | PASS | panel + slab/singles buttons wired |
| Day-10 serialization | PASS | Titan pending blocks showcase; after Cancel, showcase starts |

## Truth leak nack (S1)

| Surface | Result |
|---------|--------|
| `hud.gd` / `demand_signal_presenter.gd` / `main_menu.gd` | No `true_market` / `p_buy` / `cert_valid` |
| Buy/Price/buylist DTO property scan | No truth-named fields |
| Presenter strings (buy/price/seller/Titan hype) | Clean |
| QA instrumentation payloads | May contain truth when force-enabled (debug path only; default `debug/qa_instrumentation=false`) — **not** UI |

## Findings (severity-ranked)

### S1 — Critical / truth leak
**None.**

### S2 — Major
**None.** Hype does not stack on re-focus; PriceEditor beat does not die on PREP→FLOOR (deferred refocus keeps pending until Apply/Cancel/ignored).

### S3 — Minor
1. **CustomerServe “Wants” shows raw SKU id** (`AA-BASE-088`) rather than bible display name “Bastion Captain” in `hud.gd` buyer summary. Decision path still clear; polish for §5.1 naming.
2. **`trigger_qa_beat(TITAN)` does not re-guard `_started`** — a double QA inject could re-call `apply_hype_event` and stack ×1.35. **Player Normal day path is guarded** (`not _started.has`); not an S2 for ship, but QA/debug should avoid double-fire without `reset`.

### S4 — Polish / note
3. Spike fires on **first** FLOOR in day 3–5 (not every day in window) — correct one-shot; harness verifies day 3.
4. Day 10: Titan editor unresolved delays showcase start — matches eng serialization; players should resolve/ignore Titan before showcase modal.
5. Prior PR #5/#6 list + multi-SKU + You offer behavior unchanged.

## Commands re-run
```
cd /workspace/qa-playtest/tip7
godot --headless --path . --import
godot --headless --path . --script res://tests/test_runner.gd
godot --headless --path . --script res://tests/qa_s10_beats_playtest.gd
```
Harness log: `/workspace/card-shop-qa/evidence/playtest-13ba9102.log`  
Harness source: `tip7/tests/qa_s10_beats_playtest.gd` (also copied to `/workspace/card-shop-qa/qa_s10_beats_playtest.gd`)  
Automated gates: **814 PASS / 0 FAIL**

## Recommendation to PM
- **Clear** formal MVP §10 #4 / #7 / #8 on Normal at `13ba9102` — injectable, naturally reachable in day windows, fairness intact.
- **Clear** hype phase-stability + no-stack and showcase capacity/reversibility for Eng-Approve of PR #7 beat hooks.
- **Optional polish:** display names in CustomerServe “Wants”; harden `trigger_qa_beat` Titan against double-apply when already started.
- Remaining §10 gap from earlier reports: **#6 first rent / soft shelf** still out of this formal slice if not covered elsewhere.
