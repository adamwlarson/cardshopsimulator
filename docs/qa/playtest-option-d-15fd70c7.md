# Playtest report — Option D event→PriceEditor bridge @ `15fd70c7` (PR #33)

**Scorer:** CSS QA (executor)  
**Date:** 2026-09-06 (~10:25 AM ET)  
**Build:** `adamwlarson/cardshopsimulator` tip **`15fd70c793946663642420c63d439d7df5644af6`** (tree `/workspace/qa-playtest/option-d-15fd70c7/`)  
**Mode:** **Normal** (`data/balance/normal.tres`)  
**Godot:** 4.5.2.stable.official.6ce3de25a (`/home/box/.local/bin/godot`)  
**Scope:** Formal Option D smoke — C1 Hype/Fog → one-shot PriceEditor bridge; Cancel keeps event; Apply persists list; §4.5 truth nack; C1 bus only; soft `_ensure_priceable_sku` parked  
**Method:** Headless — foundation `tests/test_runner.gd` (includes `_test_option_d_seeded_hype_opens_price_editor_once`, `_test_option_d_price_editor_has_no_truth`, `_test_option_d_cancel_keeps_event_apply_persists`) + SceneTree harness `tests/qa_option_d_smoke.gd`  
**Design SoT:** `docs/design/next-eng-sot-pick-d-v1.md` § Option D; PR #33 body

## Executive verdict

| Gate (pass bar) | Result |
|-----------------|--------|
| 1. Seeded Hype opens PriceEditor once (no debug); Fog hook + Titan #7 OK | **PASS** |
| 2. Cancel keeps event active; Apply persists list price | **PASS** |
| 3. §4.5 clean — no `true_market` / `cert_valid` / `p_buy` on that open | **PASS** — 0 hits |
| 4. C1 bus only — no new event kinds | **PASS** |
| 5. Soft Eng parked: `_ensure_priceable_sku` may `receive_card` Titan into binder if stock empty | **PASS** (soft / non-blocking) |

| Supporting | Result |
|------------|--------|
| Tip SHA confirmed | **`15fd70c793946663642420c63d439d7df5644af6`** |
| Foundation `test_runner` | **PASS** — `All foundation tests passed.` (EXIT 0) |
| Formal Option D smoke harness | **PASS** — **98 PASS / 0 FAIL**; `SOFT_COUNT=1` |
| S0–S2 (severity rubric) | **None found** for this tip |

**Overall: PASS**

Option D event→PriceEditor bridge clears the formal pass bar on Normal at tip `15fd70c7`. Soft Eng note on `_ensure_priceable_sku` Titan seed is explicitly parked and non-blocking.

**Clear for merge?** **YES**

## Pass-bar checklist

| # | Check | Observed | Verdict |
|---|-------|----------|---------|
| 1a | Seeded Hype opens PriceEditor once, no debug | `start_pack_event(KIND_HYPE, Titan)` opens `%PriceEditor` on `AA-SKIE-047`; `price_editor_prompted=true`; re-call does not spam; Cancel does not reopen | **PASS** |
| 1b | Seeded Normal run rolls Hype without debug | RNG seed **7** rolled Hype on `AA-BASE-088`; PriceEditor opened + prompted | **PASS** |
| 1c | Fog hook | Fog resolves priceable SKU **`AA-SKIE-047`**; one-shot open; no spam | **PASS** |
| 1d | Titan §10 #7 OK | Pack `start_pack_event(KIND_HYPE, AA-SKIE-047)` + bridge open; does not use QA Titan beat trigger for seeded path | **PASS** |
| 2a | Cancel keeps event | After Cancel: active `hype_spike`, same SKU, `remaining_days` unchanged; panel closed | **PASS** |
| 2b | Apply persists list | Listed **2200 → 2575** (+375); event stays active hype | **PASS** |
| 3 | §4.5 / truth nack on open | DTO has no truth fields; chips Demand/Position/Move shown; summary/banner/labels clean; UI file scan **0** leaks | **PASS** |
| 4 | C1 bus only | `events.json` exactly `hype_spike` / `soft_rotation_leak` / `fog_day`; `EVENT_PRICE_BRIDGE` is beat id, not a new kind | **PASS** |
| 5 | Soft `_ensure_priceable_sku` | Helper present (`receive_card` Titan binder seed); fog resolve → Titan; parked S4 | **PASS** (soft) |

## Key measured evidence

| Surface | Key numbers |
|---------|-------------|
| Tip | `15fd70c793946663642420c63d439d7df5644af6` |
| Foundation | `All foundation tests passed.` / EXIT 0 — log `evidence/option-d-15fd70c7/foundation.log` |
| Smoke harness | **98 PASS / 0 FAIL / 1 SOFT** — `evidence/option-d-15fd70c7/option_d_smoke.json` |
| Hype prompt | `price_editor_prompted=true` after one open |
| Rolled Hype | seed **7**, SKU **`AA-BASE-088`** |
| Fog SKU | **`AA-SKIE-047`** |
| Apply | listed_before **2200**, apply_cents **2575**, listed_after **2575** |
| Chips (open) | demand `■ HOT`; position `▼ Undercut`; move `→ Should Move`; banner `Hype: Skiefall Titan · HOT` |
| Truth scan | `truth_scan_leaks: []` |
| Event catalog | `["hype_spike", "soft_rotation_leak", "fog_day"]` |

## Design SoT alignment

- **pick-d § Option D:** Active Hype/Fog forces one PriceEditor open on affected SKU (Fog → Titan path); Cancel leaves event running; Apply persists list; no new event kinds / news UI.
- **PR #33 acceptance:** Gates 1–4 mapped to `demand_signals.gd` / `market_event.gd` / `hud.gd` + foundation Option D tests — all exercised.
- **§4.5 / ui-wireflows truth nacks:** Clear on PriceEditor open surface (DTO + chips + UI sources).
- **C1 bus:** Unchanged three-event pack; bridge uses `EVENT_PRICE_BRIDGE` beat id only.

## Soft Eng nits (non-blocking)

1. **`_ensure_priceable_sku` may `receive_card` Titan into binder if stock empty** — MVP OK for Fog/Hype resolve when no priceable stock; parked **S4**, non-blocking. Observed helper present; fog resolve `AA-SKIE-047`.

## Evidence paths

| Artifact | Path |
|----------|------|
| Report | `/workspace/card-shop-qa/playtest-option-d-15fd70c7.md` |
| Docs QA copy | `/workspace/card-shop-qa/docs/qa/playtest-option-d-15fd70c7.md` |
| Foundation log | `/workspace/card-shop-qa/evidence/option-d-15fd70c7/foundation.log` |
| Smoke log | `/workspace/card-shop-qa/evidence/option-d-15fd70c7/smoke.log` |
| Smoke JSON | `/workspace/card-shop-qa/evidence/option-d-15fd70c7/option_d_smoke.json` |
| Checkout | `/workspace/qa-playtest/option-d-15fd70c7` @ `15fd70c7` |
| Harness | `/workspace/card-shop-qa/qa_option_d_smoke.gd` (also `tests/qa_option_d_smoke.gd` in checkout) |

## Repro

```bash
ROOT=/workspace/qa-playtest/option-d-15fd70c7
godot --headless --path "$ROOT" --import
godot --headless --path "$ROOT" --script res://tests/test_runner.gd
godot --headless --path "$ROOT" -s res://tests/qa_option_d_smoke.gd
```

Expect: `All foundation tests passed.` then `PASS_COUNT=98 FAIL_COUNT=0` / `All Option D smoke checks passed.`

## Notes

- Transient headless `InventoryService` compile warning at smoke script first load is pre-existing Godot reload noise; suite still executes and passes (same class of noise as prior formal smokes).
- No S0–S2 severity findings. Soft Eng park only.

## Merge

Merged to main as **PR #33** @ `b32703d93b14327850e2b7e3cc1f81dfb8b48725` (2026-09-06).
