# Playtest report — Q1 Supply glut formal smoke @ `b727a84a` (PR #46)

**Scorer:** CSS QA (executor)  
**Date:** 2026-09-06 (~5:15 PM ET)  
**Build:** `adamwlarson/cardshopsimulator` tip **`b727a84ae25e54a72f577bb9748b1bd1d1360695`** (tree `/workspace/qa-playtest/q1-b727a84a/`)  
**Mode:** **Normal** (`data/balance/normal.tres`)  
**Godot:** 4.5.2.stable.official.6ce3de25a (`/workspace/godot452` / `/home/box/.local/bin/godot`)  
**Scope:** Formal Q1 Supply glut smoke after Eng APPROVE-with-notes — seeded fire; sealed wholesale↓ (×0.75) observable + restore; buy deep / skim / skip still work; mild sealed retail-race (×0.90) OK; no soft-lock; EventBanner distributor telegraph; §4.5 clean; Recession + Convention + Counterfeit + Theft + Option D (pack bus) untouched; Softs parked; No Art; economy owns event  
**Method:** Headless — import `--editor --quit-after 120` + foundation `tests/test_runner.gd` (includes `_test_supply_glut_*`) + SceneTree harness `tests/qa_q1_supply_glut_smoke.gd`  
**Design SoT:** `docs/design/next-eng-sot-pick-q-v1.md` § Q1; systems §8; PR #46 acceptance  
**Priors:** P1 Recession `93bc2d27`; O1 Theft `87f78d15`; N1 Convention `1ab9983f`; M1 Counterfeit `ce5577a4`  
**No Art.** Soft Eng notes: Soft seed / Soft far crest / Soft Fri spill Soft OK / Soft EventBanner rumor Soft OK / Soft flipper-weight Soft OK / Soft `apply_medium_capacity` parked — non-blocking unless S0–S2.

## Executive verdict

| Gate (Designer bar) | Result |
|---------------------|--------|
| 1. Seeded Supply glut fires (distributor telegraph / EventBanner) | **PASS** |
| 2. Sealed wholesale↓ observable (×0.75); buy deep / skim / skip still work; restore when ends | **PASS** |
| 3. Mild sealed retail-race pressure OK; no soft-lock | **PASS** |
| 4. EventBanner OK (`Distributor: Supply glut — sealed cheap · retail race`) | **PASS** |
| 5. §4.5 clean on buy/price confirms | **PASS** — 0 UI hits |
| 6. Recession + Convention + Counterfeit + Theft + Option D still work (pack bus untouched) | **PASS** |
| 7. Soft seed / Soft far crest / Soft Fri spill Soft OK / Soft EventBanner rumor Soft OK / Soft flipper-weight Soft OK / Soft `apply_medium_capacity` parked | **PASS** (soft noted) |
| 8. No Art; economy owns event (ui does not own domain rules) | **PASS** |

| Supporting | Result |
|------------|--------|
| Tip SHA confirmed | **`b727a84ae25e54a72f577bb9748b1bd1d1360695`** (`test(economy): avoid InventoryService autoload in Q1 suite`; feat commit `3d585ab`) |
| Import `--editor --quit-after 120` | **PASS** — EXIT:0 |
| Foundation `test_runner` | **PASS** — `All foundation tests passed.` EXIT:0 (supply glut suite + pack coherence exercised) |
| Formal Q1 smoke harness | **PASS** — **422 PASS / 0 FAIL**; `SOFT_COUNT=12` |
| Soft Eng notes disposition | **Non-blocking** — EventBanner rumor Soft OK MVP; Soft seed / far crest / Fri spill Soft OK / flipper-weight Soft OK / `apply_medium_capacity` parked; no S0–S2 |
| S0–S2 (severity rubric) | **None found** for this tip |

**Overall: PASS-with-notes**

Q1 Supply glut clears the formal pass bar on Normal at tip `b727a84a`. Soft Eng parkeds remain parked; no Art; no S0–S2. Instrumented sealed wholesale/race match PR evidence (MOQ wholesale **1800→1350** = ×0.75; sealed retail comp **1000→900** = ×0.90; remaining_days **3→2**; seeded seed **1** day **9**; banner exact).

**Clear for merge?** **YES** (PASS-with-notes; soft only).

## Pass-bar checklist

| # | Check | Observed | Verdict |
|---|-------|----------|---------|
| 1a | `start_pack_event(KIND_SUPPLY_GLUT)` | kind `supply_glut`; duration/remaining **3**; `has_supply_glut` true; no PriceEditor | **PASS** |
| 1b | Seeded settle roll | seed **1** day **9** rolled supply_glut | **PASS** |
| 2a | Sealed wholesale ×0.75 | off **1.0** → on **0.75** (`SUPPLY_GLUT_WHOLESALE_MULT`); MOQ **1800→1350**; restores | **PASS** |
| 2b | Deep / skim lots | deep `supply-glut-deep-skie-blst` qty≥6; skim lighter; both at restock×glut | **PASS** |
| 2c | Buy deep / skim / skip | confirm deep+skim land stock; dismiss MOQ closes — no soft-lock | **PASS** |
| 2d | remaining_days window | tick **3→2**; wholesale stays ×0.75 while remaining > 0 | **PASS** |
| 3a | Mild sealed retail-race ×0.90 | sealed comp **1000→900**; singles unchanged; restores | **PASS** |
| 3b | Price race / hold margin | listed **2999→2699** (90%); hold+race DTOs clean; PriceEditor openable | **PASS** |
| 3c | FLOOR settle | `start_floor` + `start_settle` true during glut — no soft-lock | **PASS** |
| 3d | Save/load | save `id=supply_glut` remaining_days **3**; restore re-applies wholesale↓ / race + distributor banner | **PASS** |
| 4 | EventBanner distributor | exact `"Distributor: Supply glut — sealed cheap · retail race"` on service + `%EventBannerLabel` | **PASS** |
| 5 | §4.5 | buy/price confirms/summaries/save keys + UI scan — **0** `cert_valid`/`true_market`/`p_buy` leaks | **PASS** |
| 6 | Pack bus + Option D | recession replaces glut (wholesale back 1.0); convention/theft/scare OK; Hype/Fog still want PriceEditor; glut does not | **PASS** |
| 7 | Softs parked | Soft seed defined unused by glut; far crest OOS; Fri spill Soft OK MVP untouched; EventBanner rumor Soft OK; flipper-weight Soft OK untouched; `apply_medium_capacity` unused | **PASS** (soft) |
| 8 | No Art / economy owns | PR #46 files: events.json + economy/demand + market_event(+service) + pricing_service + test_runner only | **PASS** |

## Key measured evidence

| Surface | Key numbers |
|---------|-------------|
| Constants | `SUPPLY_GLUT_WHOLESALE_MULT` **0.75**; `SUPPLY_GLUT_SEALED_RACE_MULT` **0.90**; duration **3 days** |
| Catalog | `hype_spike`, `soft_rotation_leak`, `fog_day`, `counterfeit_scare`, `convention_weekend`, `theft_ring`, `recession_week`, `supply_glut` |
| Baseline MOQ | unit cost **1800**; wholesale/race mult **1.0** |
| Glut MOQ | unit cost **1350** (×0.75); restock baseline sealed **1949** |
| Retail race | sealed comp **1000→900**; singles stay **1000** |
| remaining_days | **3→2**; wholesale stays 0.75 |
| Seeded fire | seed **1**, day **9** |
| Banner | `Distributor: Supply glut — sealed cheap · retail race` |
| Levers | deep+skim confirm; skip dismisses MOQ; race listed **2999→2699**; FLOOR settle OK |
| Save | `id=supply_glut`, `remaining_days=3`, `price_editor_prompted=false` |
| Truth scan | `truth_scan_leaks: []` |
| Harness | **422 PASS / 0 FAIL / 12 SOFT** |
| Foundation | `All foundation tests passed.` EXIT:0 |
| Import | EXIT:0 |

## Design SoT alignment

- **pick-q / Option Q1:** Supply glut distributor telegraph; sealed wholesale ↓; retail race; buy deep / skim / skip; §4.5 clean; Softs unused; no Art.
- **systems §8:** Pack event via existing MarketEvent / DemandSignals path; thin EventBanner distributor only.
- **Option D:** Hype/Fog → PriceEditor one-shot unchanged; supply glut does not bridge.
- **Out of scope (honored):** Multi-distributor war; long glut seasons; Option D PriceEditor for this event; Art; Soft seed / far crest; Soft Fri spill Soft OK MVP; Soft flipper-weight Soft OK; docs/ (PM syncs).

## Soft Eng notes disposition (APPROVE-with-notes + steering)

| Soft Eng note | Disposition |
|---------------|-------------|
| EventBanner rumor Soft OK for MVP | **Non-blocking / intentional.** Thin `%EventBannerLabel` distributor telegraph present and exact; do **not** FAIL for absence of richer rumor HUD. No S0–S2. |
| Soft seed / Soft far crest / Soft Fri spill Soft OK / Soft flipper-weight Soft OK / Soft `apply_medium_capacity` | **Non-blocking / parked.** Confirmed unused by Q1 surfaces. |
| docs-only behind main | **Non-blocking.** Tip is economy + thin HUD + foundation tests; docs/ not required on this tip (PM syncs). No S0–S2. |

## Soft Eng nits (non-blocking / parked)

1. **Soft Eng EventBanner rumor Soft OK MVP** — thin Distributor EventBanner intentional; do not FAIL. (**S4**)
2. **Soft seed `_ensure_priceable_sku`** — keep parked; Hype/Fog bridge only; unused by Q1 supply glut. (**S4**)
3. **Soft far crest** — Art Large OOS; No Art for Q1. (**S4**)
4. **Soft Fri spill Soft OK MVP stands** — Q1 does not retune convention calendar weights. (**S4**)
5. **Soft flipper-weight Soft OK MVP stands** — Q1 does not retune buylist/flipper; parked. (**S4**)
6. **Soft `apply_medium_capacity` naming** — still defined for Large/Medium capacity; unused by Q1 event surfaces; keep parked. (**S4**)
7. **Soft Eng docs-only behind main** — see disposition above. (**S4**)
8. **No Art** — confirmed OOS; economy owns event (ui does not own domain rules).
9. **Harness note:** `DemandSignalService` class_name refs avoided under headless `--script` (Channel ints) so QaInstrumentation loads — same class of dep as P1 BuyOpportunity note. (**S4**)

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
| Report (root) | `/workspace/card-shop-qa/playtest-q1-supply-glut-b727a84a.md` |
| Report (docs) | `/workspace/card-shop-qa/docs/qa/playtest-q1-supply-glut-b727a84a.md` |
| Evidence dir | `/workspace/card-shop-qa/evidence/q1-b727a84a/` |
| Import log | `…/import.log` (EXIT:0) |
| Foundation log | `…/foundation.log` (EXIT:0) |
| Harness log | `…/qa_q1_smoke.log` |
| Harness JSON | `…/qa_q1_supply_glut_smoke.json` |
| Checkout | `/workspace/qa-playtest/q1-b727a84a/` @ `b727a84ae25e54a72f577bb9748b1bd1d1360695` |
| Harness script | `/workspace/card-shop-qa/qa_q1_supply_glut_smoke.gd` (copied → `tests/qa_q1_supply_glut_smoke.gd`) |

## Harness counts

- **PASS_COUNT=422**
- **FAIL_COUNT=0**
- **SOFT_COUNT=12**
- **TIP_SHA=b727a84ae25e54a72f577bb9748b1bd1d1360695**

## Repro (PASS path)

```bash
ROOT=/workspace/qa-playtest/q1-b727a84a
godot --headless --editor --quit-after 120 --path "$ROOT"
godot --headless --path "$ROOT" --script res://tests/test_runner.gd
godot --headless --path "$ROOT" --script res://tests/qa_q1_supply_glut_smoke.gd
```

## FAIL repro

N/A — no failing gates.

## Clear for merge?

**YES** — PASS-with-notes. No S0–S2 blockers. Soft Eng notes (EventBanner rumor Soft OK; Soft seed / far crest / Fri spill Soft OK / flipper-weight Soft OK / `apply_medium_capacity`) remain parked. No Art; economy owns event.

## Merge

Merged to main as **PR #46** @ `116ad889ce9ed5017d8f7eef31e57b9ff4188192` (2026-09-06). Softs parked. §8 event suite largely closed. Next Eng SoT pick from Design.
