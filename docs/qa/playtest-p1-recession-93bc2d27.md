# Playtest report — P1 Recession week formal smoke @ `93bc2d27` (PR #45)

**Scorer:** CSS QA (executor)  
**Date:** 2026-09-06 (~4:55 PM ET)  
**Build:** `adamwlarson/cardshopsimulator` tip **`93bc2d2771d5c0aa8a279d7b3b10f1f679b93eb9`** (tree `/workspace/qa-playtest/p1-93bc2d27/`)  
**Mode:** **Normal** (`data/balance/normal.tres`)  
**Godot:** 4.5.2.stable.official.6ce3de25a (`/workspace/godot452` / `/home/box/.local/bin/godot`)  
**Scope:** Formal P1 Recession week smoke after Eng APPROVE-with-notes — seeded fire; demand/sell-through ×0.65 + buylist ×2.0 observable + restore; liquidate / refuse buys no soft-lock; EventBanner macro; §4.5 clean; Option D + pack bus (Convention / Counterfeit / Theft / Hype / Fog) untouched; Softs parked; No Art  
**Method:** Headless — import `--editor --quit-after 120` + foundation `tests/test_runner.gd` (includes `_test_recession_week_*`) + SceneTree harness `tests/qa_p1_recession_smoke.gd`  
**Design SoT:** `docs/design/next-eng-sot-pick-p-v1.md` § P1; systems §8; PR #45 acceptance  
**Priors:** O1 Theft `87f78d15`; N1 Convention `1ab9983f`; M1 Counterfeit `ce5577a4`  
**No Art.** Soft Eng notes: EventBanner rumor Soft OK MVP; Soft seed / Soft far crest / Soft Fri spill Soft OK / Soft `apply_medium_capacity` parked; **buylist↑ via flipper-weight Soft OK for MVP if sell-pressure visibly rises** — non-blocking unless S0–S2.

## Executive verdict

| Gate (Designer bar) | Result |
|---------------------|--------|
| 1. Recession fires (seeded) | **PASS** |
| 2. Demand/sell-through↓ (×0.65) + buylist↑ (×2.0) observable; restore when ends | **PASS** |
| 3. Liquidate / refuse buys still player agency — no soft-lock | **PASS** |
| 4. EventBanner OK (`Macro: Recession week — demand soft · sellers inbound`) | **PASS** |
| 5. §4.5 clean (no truth on fire-sale confirms) | **PASS** — 0 UI hits |
| 6. Option D + pack bus untouched (Convention / Counterfeit / Theft / Hype / Fog) | **PASS** |
| 7. Soft seed / Soft far crest / Soft Fri spill Soft OK / Soft EventBanner rumor Soft OK / Soft `apply_medium_capacity` parked | **PASS** (soft noted) |
| 8. No Art | **PASS** |

| Supporting | Result |
|------------|--------|
| Tip SHA confirmed | **`93bc2d2771d5c0aa8a279d7b3b10f1f679b93eb9`** (`test(economy): type P1 recession buy-opportunity inject`; feat commit `e38d1929`) |
| Import `--editor --quit-after 120` | **PASS** — EXIT:0 |
| Foundation `test_runner` | **PASS** — `All foundation tests passed.` EXIT:0 (recession suite + pack coherence exercised) |
| Formal P1 smoke harness | **PASS** — **312 PASS / 0 FAIL**; `SOFT_COUNT=12` |
| Soft Eng notes disposition | **Non-blocking** — EventBanner rumor Soft OK MVP; buylist↑ via flipper-weight Soft OK MVP (sell-pressure ×2 visible); Softs parked; no S0–S2 |
| S0–S2 (severity rubric) | **None found** for this tip |

**Overall: PASS-with-notes**

P1 Recession week clears the formal pass bar on Normal at tip `93bc2d27`. Soft Eng parkeds + Soft seed/far-crest/Fri spill Soft OK/`apply_medium_capacity` + EventBanner rumor Soft OK + **buylist↑ via flipper-weight Soft OK** remain parked; no Art; no S0–S2. Instrumented demand/buylist match PR evidence (demand 0.68→0.442 = ×0.65; flipper 12→24 = ×2.0; band warm→steady; remaining_days 7→6; seeded seed **1** day **9**).

**Clear for merge?** **YES** (PASS-with-notes; soft only).

## Pass-bar checklist

| # | Check | Observed | Verdict |
|---|-------|----------|---------|
| 1a | `start_pack_event(KIND_RECESSION)` | kind `recession_week`; duration/remaining **7**; `has_recession_week` true; no PriceEditor | **PASS** |
| 1b | Seeded settle roll | seed **1** day **9** rolled recession_week | **PASS** |
| 2a | Demand / sell-through ×0.65 | off **1.0** → on **0.65** (`RECESSION_DEMAND_MULT`); staple score **0.68→0.442**; band **warm→steady**; restores | **PASS** |
| 2b | Buylist ×2.0 (flipper-weight Soft OK) | off **1.0** → on **2.0** (`RECESSION_BUYLIST_MULT`); flipper weight **12.0→24.0**; CustomerSpawner reads `active_event_buylist_mult`; restores | **PASS** (Soft OK path) |
| 2c | remaining_days window | tick **7→6**; demand stays ×0.65 while remaining > 0 | **PASS** |
| 3a | Liquidate staples | listed **500→450** (90%); sell-listed reaches sale; PriceEditor openable | **PASS** |
| 3b | Refuse buys | buylist seller queues; refuse does not purchase; OpenBuy / Refuse present | **PASS** |
| 3c | FLOOR settle | `start_floor` + `start_settle` true during recession — no soft-lock | **PASS** |
| 3d | Save/load | save `id=recession_week` remaining_days **7**; restore re-applies demand↓ / buylist↑ + macro banner | **PASS** |
| 4 | EventBanner macro | exact `"Macro: Recession week — demand soft · sellers inbound"` on service + `%EventBannerLabel` | **PASS** |
| 5 | §4.5 | fire-sale confirms/summaries/save keys + UI scan — **0** `cert_valid`/`true_market`/`p_buy` leaks | **PASS** |
| 6 | Pack bus + Option D | convention replaces recession (demand back 1.0); theft/scare OK; Hype/Fog still want PriceEditor; recession does not | **PASS** |
| 7 | Softs parked | Soft seed defined unused by recession; far crest OOS; Fri spill Soft OK MVP untouched; EventBanner rumor Soft OK; `apply_medium_capacity` unused; flipper-weight Soft OK | **PASS** (soft) |
| 8 | No Art | PR #45 files: events.json + economy/demand/customers + market_event(+service) + test_runner only | **PASS** |

## Key measured evidence

| Surface | Key numbers |
|---------|-------------|
| Constants | `RECESSION_DEMAND_MULT` **0.65**; `RECESSION_BUYLIST_MULT` **2.0**; duration **7 days** |
| Catalog | `hype_spike`, `soft_rotation_leak`, `fog_day`, `counterfeit_scare`, `convention_weekend`, `theft_ring`, `recession_week` |
| Baseline staple | score **0.68**; band **warm**; flipper weight **12.0**; demand/buylist mult **1.0** |
| Recession staple | score **0.442** (×0.65); band **steady**; flipper weight **24.0** (×2.0) |
| remaining_days | **7→6**; demand stays 0.65 |
| Seeded fire | seed **1**, day **9** |
| Banner | `Macro: Recession week — demand soft · sellers inbound` |
| Liquidate | listed **500→450**; stock **3**; FLOOR settle OK |
| Save | `id=recession_week`, `remaining_days=7`, `price_editor_prompted=false` |
| Truth scan | `truth_scan_leaks: []` |
| Harness | **312 PASS / 0 FAIL / 12 SOFT** |
| Foundation | `All foundation tests passed.` EXIT:0 |
| Import | EXIT:0 |

## Design SoT alignment

- **pick-p / Option P1:** Recession week macro; demand/sell-through ↓; buylist seller pressure ↑; liquidate / refuse / ride-out; §4.5 clean; Softs unused; no Art.
- **systems §8:** Pack event via existing MarketEvent / DemandSignals path; thin EventBanner macro only.
- **Option D:** Hype/Fog → PriceEditor one-shot unchanged; recession does not bridge.
- **Out of scope (honored):** Multi-week depression arc; loan-shark except existing bankruptcy; Option D PriceEditor for this event; Art; Soft seed / far crest; Soft Fri spill Soft OK MVP; docs/ (PM syncs).

## Soft Eng notes disposition (APPROVE-with-notes + steering)

| Soft Eng note | Disposition |
|---------------|-------------|
| EventBanner rumor Soft OK for MVP | **Non-blocking / intentional.** Thin `%EventBannerLabel` macro present and exact; do **not** FAIL for absence of richer rumor HUD. No S0–S2. |
| **buylist↑ via flipper-weight Soft OK for MVP if sell-pressure visibly rises** | **Non-blocking / intentional.** Observed flipper weight **12.0→24.0** (×2.0) and `active_event_buylist_mult=2.0`; CustomerSpawner reads pack buylist mult. Sell-pressure visibly rises. Do **not** FAIL for flipper-weight path. No S0–S2. |
| docs-only behind main | **Non-blocking.** Tip is economy + thin HUD + foundation tests; docs/ not required on this tip (PM syncs). No S0–S2. |
| Soft seed / Soft far crest / Soft Fri spill Soft OK / Soft `apply_medium_capacity` | **Non-blocking / parked.** Confirmed unused by P1 surfaces. |

## Soft Eng nits (non-blocking / parked)

1. **Soft Eng EventBanner rumor Soft OK MVP** — thin Macro EventBanner intentional; do not FAIL. (**S4**)
2. **Soft Eng buylist↑ via flipper-weight Soft OK MVP** — flipper weight ×2.0 visibly raises sell-pressure; Soft OK; do not FAIL. (**S4**)
3. **Soft seed `_ensure_priceable_sku`** — keep parked; Hype/Fog bridge only; unused by P1 recession. (**S4**)
4. **Soft far crest** — Art Large OOS; No Art for P1. (**S4**)
5. **Soft Fri spill Soft OK MVP stands** — P1 does not retune convention calendar weights. (**S4**)
6. **Soft `apply_medium_capacity` naming** — still defined for Large/Medium capacity; unused by P1 event surfaces; keep parked. (**S4**)
7. **Soft Eng docs-only behind main** — see disposition above. (**S4**)
8. **No Art** — confirmed OOS.
9. **Harness note:** cut-buys dismiss covered by foundation P1 levers suite (harness avoids `BuyOpportunity` parse dep under headless `--script` load ordering). (**S4**)

## Findings (severity-ranked)

### S0–S2
**None.**

### Soft / notes
See Soft Eng nits above. No blockers.

## Blockers
**None.**

## Evidence paths

| Artifact | Path |
|----------|------|
| Report (root) | `/workspace/card-shop-qa/playtest-p1-recession-93bc2d27.md` |
| Report (docs) | `/workspace/card-shop-qa/docs/qa/playtest-p1-recession-93bc2d27.md` |
| Evidence dir | `/workspace/card-shop-qa/evidence/p1-93bc2d27/` |
| Import log | `…/import.log` (EXIT:0) |
| Foundation log | `…/foundation.log` (EXIT:0) |
| Harness log | `…/qa_p1_smoke.log` |
| Harness JSON | `…/qa_p1_recession_smoke.json` |
| Checkout | `/workspace/qa-playtest/p1-93bc2d27/` @ `93bc2d2771d5c0aa8a279d7b3b10f1f679b93eb9` |
| Harness script | `/workspace/card-shop-qa/qa_p1_recession_smoke.gd` (copied → `tests/qa_p1_recession_smoke.gd`) |

## Harness counts

- **PASS_COUNT=312**
- **FAIL_COUNT=0**
- **SOFT_COUNT=12**
- **TIP_SHA=93bc2d2771d5c0aa8a279d7b3b10f1f679b93eb9**

## Repro (PASS path)

```bash
ROOT=/workspace/qa-playtest/p1-93bc2d27
godot --headless --editor --quit-after 120 --path "$ROOT"
godot --headless --path "$ROOT" --script res://tests/test_runner.gd
godot --headless --path "$ROOT" --script res://tests/qa_p1_recession_smoke.gd
```

## FAIL repro

N/A — no failing gates.

## Clear for merge?

**YES** — PASS-with-notes. No S0–S2 blockers. Soft Eng notes (EventBanner rumor Soft OK; **buylist↑ via flipper-weight Soft OK** with visible ×2 sell-pressure; Soft seed / far crest / Fri spill Soft OK / `apply_medium_capacity`) remain parked. No Art.

## Merge

Merged to main as **PR #45** @ `748c1c04e80c439e46d94c5b4247d7fb7e96b6c4` (2026-09-06). Soft flipper-weight buylist Soft OK MVP; Softs otherwise parked. Next Eng SoT pick from Design.
