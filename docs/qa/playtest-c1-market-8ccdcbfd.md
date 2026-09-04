# Playtest report — C1 Market events pack (hype / rotation leak / fog) @ `8ccdcbfd` (PR #26)

**Scorer:** CSS QA (executor)  
**Date:** 2026-09-04 (~5:55 PM ET)  
**Build:** `adamwlarson/cardshopsimulator` tip **`8ccdcbfde19b72854fe8ee7602189d7fc1cc1e87`** (tree `/workspace/qa-playtest/c1-8ccdcbfd/` shallow checkout of PR head)  
**Mode:** **Normal** (`data/balance/normal.tres`) — Easy/Hard settle chance + negative weight mult verified  
**Godot:** 4.5.2.stable.official.6ce3de25a (`/home/box/.local/bin/godot`)  
**Scope:** Formal smoke — C1 pack (hype_spike / soft_rotation_leak / fog_day) + Titan §10 #7 pack start + EventBanner + save-load + BalanceConfig knobs + truth nack + fog σ / inversion  
**Method:** Headless — foundation `tests/test_runner.gd` (includes `_test_market_events_seven_day_seeded_run`, `_test_hype_spike_target_sku_only`, `_test_fog_day_sigma_and_inversion`, `_test_market_event_save_load`) + SceneTree harness `tests/qa_c1_market_events.gd`  
**Design SoT:** `docs/design/next-eng-sot-pick-c-v1.md` Option C1; PR #26 body

## Executive verdict

| Gate (pass bar) | Result |
|-----------------|--------|
| 1. Hype spike / soft rotation leak / fog day present + functional | **PASS** |
| 2. Titan §10 #7 fires from pack (`start_pack_event` / HOT on Skiefall Titan) | **PASS** |
| 3. HUD EventBanner for hype/fog; rotation blank until Research/Specialist | **PASS** |
| 4. Save/load restores active event + remaining days | **PASS** |
| 5. BalanceConfig `event_chance_settle` + `negative_event_weight_mult` wired — no parallel knobs | **PASS** |
| 6. Truth leak nack (`true_market` / `p_buy` / `cert_valid` in UI) | **PASS** — 0 hits |
| 7. Fog widens σ; Cold↔Hot inversion never without fog flag | **PASS** |
| 8. Soft Eng parkeds stay parked (non-blocking) | **PASS** (soft noted) |
| 9. Soft MidCenter lights / apron / icon / skinning / usable_sq_ft parked | **PASS** (soft / OOS) |

| Supporting | Result |
|------------|--------|
| Tip SHA confirmed | **`8ccdcbfde19b72854fe8ee7602189d7fc1cc1e87`** |
| Foundation `test_runner` | **PASS** — `All foundation tests passed.` |
| Formal C1 smoke harness | **PASS** — **76 PASS / 0 FAIL**; `SOFT_COUNT=3` |
| S0–S3 (severity rubric) | **None found** for this tip |

**Overall: PASS-with-notes**

C1 Market events pack clears the formal pass bar on Normal at tip `8ccdcbfd`. Soft Eng parkeds (MidCenter polish / news ticker / multi-SKU correlation / player-authored events / docs edits) and known HUD re-instantiate duplicate-connect noise are explicitly parked and non-blocking.

## Pass-bar checklist

| # | Check | Observed | Verdict |
|---|-------|----------|---------|
| 1a | Pack catalogs 3 events | `data/events.json` + `MarketEventService.defs` include `hype_spike`, `soft_rotation_leak`, `fog_day` | **PASS** |
| 1b | Hype elevates target only | Titan band **hot**; control SKU market unchanged; comps elevated for target | **PASS** |
| 1c | 7-day seeded run ≥1 event | Foundation seed `20260904` rolled `fog_day` day 1 (σ 0.18), then nulls | **PASS** |
| 2 | Titan §10 #7 pack start | `beat_injection._start_titan_hype` → `DemandSignals.start_pack_event(KIND_HYPE, AA-SKIE-047)`; banner **HOT** / Titan | **PASS** |
| 3a | EventBanner hype/fog | `%EventBannerLabel` in `gameplay_hud.tscn`; HUD visible for hype (**HOT**) and fog (**Fog day**) | **PASS** |
| 3b | Rotation leak gated | Banner `""` without Research/Specialist; Specialist hire reveals Dustway rotation watch | **PASS** |
| 4 | Save/load | `market_event` id `hype_spike`, `remaining_days=3`, sku restored; rotation+Specialist path also restores | **PASS** |
| 5 | Balance knobs only | Normal 0.18 / Easy 0.12 / Hard 0.26 settle; neg weight 1.0 / 0.7 / 1.4; **no** `event_rate` on BalanceConfig | **PASS** |
| 6 | Truth nack UI | Scanned `hud.gd`, `demand_signal_presenter.gd`, `main_menu.gd`, `gameplay_hud.tscn`, `hud.tscn`, `main_menu.tscn` — **0** tokens | **PASS** |
| 7a | Fog widens σ | Base 0.12 → fog 0.18 (= × `FOG_SIGMA_MULT` 1.5) | **PASS** |
| 7b | No Cold↔Hot without fog | 0/160 inversion samples without fog flag | **PASS** |
| 8–9 | Soft parkeds | MidCenter lights/apron/icon/skinning/usable_sq_ft + Eng soft OOS — non-blocking | **PASS** (soft) |

## Key measured evidence

| Surface | Key numbers |
|---------|-------------|
| Balance Normal | `event_chance_settle=0.18`; `negative_event_weight_mult=1.0`; base σ **0.12** |
| Balance Easy / Hard | settle 0.12 / 0.26; neg weight 0.7 / 1.4 |
| Fog day | fog σ **0.18**; fog_flag true; banner "Fog day — demand signals noisier" |
| Hype Titan | band **hot**; banner "Hype: … Titan · HOT"; control market unchanged |
| 7-day seed 20260904 | day1 `fog_day` σ 0.18; days 2–7 null |
| Save payload | `id=hype_spike`, `remaining_days=3`, `sku_id=AA-SKIE-047` |
| Truth scan | `truth_scan_leaks: []` |
| Harness | 76 PASS / 0 FAIL / 3 SOFT |

## Design SoT alignment

- **Option C1 / systems §8:** Three-event pack through existing DemandSignal path; thin EventBanner only.
- **BalanceConfig:** Wires existing `event_chance_settle` + `negative_event_weight_mult` — does not invent parallel `event_rate_*` knobs.
- **§10 #7 Titan:** Starts from pack `start_pack_event` (HOT chip / PriceEditor focus retained).
- **ui-wireflows truth nacks:** Clear on HUD / presenter / EventBanner.
- **Out of scope (tip):** news ticker, multi-SKU correlation, player-authored events, docs/ edits, MidCenter lights/apron/icon/skinning/usable_sq_ft — soft parked as expected.

## Soft Eng nits (non-blocking)

1. **Soft MidCenter lights / apron / icon / skinning / usable_sq_ft** remain parked — out of scope for C1. (**S4**)
2. **News ticker / multi-SKU correlation / player-authored events / docs/ edits** — PR OOS. (**S4**)
3. **HUD re-instantiate duplicate Signal connect ERRORs** — observed in foundation tail when HUD is instantiated more than once; foundation still prints `All foundation tests passed.`; non-blocking prior nit. (**S4**)

## Findings (severity-ranked)

### S0–S3
**None.**

### S4 (soft / parked)
See Soft Eng nits above.

## Evidence paths

| Artifact | Path |
|----------|------|
| Foundation log | `/workspace/card-shop-qa/evidence/c1-8ccdcbfd/foundation.log` |
| C1 harness log | `/workspace/card-shop-qa/evidence/c1-8ccdcbfd/qa_c1_smoke.log` |
| C1 harness JSON | `/workspace/card-shop-qa/evidence/c1-8ccdcbfd/c1_market_events_smoke.json` |
| Import log | `/workspace/card-shop-qa/evidence/c1-8ccdcbfd/import.log` |
| Harness script | `/workspace/qa-playtest/c1-8ccdcbfd/tests/qa_c1_market_events.gd` (+ copy `/workspace/card-shop-qa/qa_c1_market_events.gd`) |
| Checkout | `/workspace/qa-playtest/c1-8ccdcbfd` @ `8ccdcbfde19b72854fe8ee7602189d7fc1cc1e87` |

## Clear for merge?

**Yes** — PASS-with-notes. No S0–S3 blockers. Soft parkeds only.

