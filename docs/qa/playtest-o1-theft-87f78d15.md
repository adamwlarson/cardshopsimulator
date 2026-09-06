# Playtest report — O1 Theft ring formal smoke @ `87f78d15` (PR #44)

**Scorer:** CSS QA (executor)  
**Date:** 2026-09-06 (~4:40 PM ET)  
**Build:** `adamwlarson/cardshopsimulator` tip **`87f78d15fded087b1ebb3da21cf6b993c37d0c26`** (tree `/workspace/qa-playtest/o1-87f78d15/`)  
**Mode:** **Normal** (`data/balance/normal.tres`)  
**Godot:** 4.5.2.stable.official.6ce3de25a (`/workspace/godot452` / `/home/box/.local/bin/godot`)  
**Scope:** Formal O1 Theft ring smoke after Eng APPROVE-with-notes — seeded fire; shrink ×3 for 3 days (instrumented rate ×3, remaining_days); staff-on-floor reduces loss vs unstaffed **and** wait-out restores; EventBanner rumor; §4.5 clean; Convention / Counterfeit / Option D Hype/Fog untouched; Softs parked; No Art  
**Method:** Headless — import `--editor --quit-after 120` + foundation `tests/test_runner.gd` (includes `_test_theft_ring_*`) + SceneTree harness `tests/qa_o1_theft_smoke.gd`  
**Design SoT:** `docs/design/next-eng-sot-pick-o-v1.md` § O1; systems §8; PR #44 acceptance  
**Priors:** N1 Convention `1ab9983f`; M1 Counterfeit `ce5577a4`  
**No Art.** Soft Eng notes: EventBanner-only rumor Soft OK MVP; Soft seed / Soft far crest / Soft Fri spill Soft OK / Soft `apply_medium_capacity` parked — non-blocking unless S0–S2.

## Executive verdict

| Gate (Designer bar) | Result |
|---------------------|--------|
| 1. Theft ring fires (seeded) | **PASS** |
| 2. Shrink ×3 for 3 days (rate ×3, remaining_days) | **PASS** |
| 3. Staff-on-floor reduces loss vs unstaffed **or** wait-out restores; no camera unlock | **PASS** (both levers) |
| 4. EventBanner rumor OK | **PASS** (thin rumor Soft OK MVP) |
| 5. §4.5 clean | **PASS** — 0 UI hits |
| 6. Convention / Counterfeit / Option D Hype/Fog untouched | **PASS** |
| 7. Soft seed / Soft far crest / Soft Fri spill Soft OK / Soft `apply_medium_capacity` parked | **PASS** (soft noted) |
| 8. No Art | **PASS** |

| Supporting | Result |
|------------|--------|
| Tip SHA confirmed | **`87f78d15fded087b1ebb3da21cf6b993c37d0c26`** (`feat(economy): add O1 Theft ring market event`) |
| Import `--editor --quit-after 120` | **PASS** — EXIT:0 |
| Foundation `test_runner` | **PASS** — `All foundation tests passed.` EXIT:0 (theft suite + pack coherence exercised) |
| Formal O1 smoke harness | **PASS** — **227 PASS / 0 FAIL**; `SOFT_COUNT=10` |
| Soft Eng notes disposition | **Non-blocking** — EventBanner-only rumor Soft OK MVP; Softs parked; no S0–S2 |
| S0–S2 (severity rubric) | **None found** for this tip |

**Overall: PASS-with-notes**

O1 Theft ring clears the formal pass bar on Normal at tip `87f78d15`. Soft Eng parkeds + Soft seed/far-crest/Fri spill Soft OK/`apply_medium_capacity` + EventBanner-only rumor Soft OK remain parked; no Art; no S0–S2. Instrumented shrink matches PR evidence hints exactly (0.007→0.021; staffed 0.006; remaining_days 3→2; COGS 20225¢).

**Clear for merge?** **YES** (PASS-with-notes; soft only).

## Pass-bar checklist

| # | Check | Observed | Verdict |
|---|-------|----------|---------|
| 1a | `start_pack_event(KIND_THEFT_RING)` | kind `theft_ring`; duration/remaining **3**; `has_theft_ring` true; no PriceEditor | **PASS** |
| 1b | Seeded settle roll | seed **1** day **9** rolled theft_ring | **PASS** |
| 2a | Shrink mult ×3 | off **1.0** → on **3.0** (`THEFT_RING_SHRINK_MULT`); clears back to 1.0 | **PASS** |
| 2b | Instrumented rate ×3 | baseline unstaffed **0.007** → theft **0.021**; same COGS **20225**; loss **150→425** | **PASS** |
| 2c | remaining_days window | tick **3→2→1** then clear; shrink stays ×3 while remaining > 0 | **PASS** |
| 3a | Staff-on-floor lever | hire_cashier; theft+cashier rate **0.006** (×3 of staffed base 0.002); loss **125 < 425** | **PASS** |
| 3b | Wait-out restore | clear / end window → shrink mult **1.0**; cameras out of pack documented | **PASS** |
| 3c | Save/load | save `id=theft_ring` remaining_days **3**; restore re-applies ×3 + rumor banner | **PASS** |
| 4 | EventBanner rumor | exact `"Rumor: extra loss on the floor — staff up or wait it out"` on service + `%EventBannerLabel` | **PASS** |
| 5 | §4.5 | banners/confirms/save keys + UI scan — **0** `cert_valid`/`true_market`/`p_buy` leaks | **PASS** |
| 6 | Convention + Counterfeit + Option D | convention replaces theft (shrink back 1.0); scare trust 0.55; Hype/Fog still want PriceEditor; theft does not | **PASS** |
| 7 | Softs parked | Soft seed defined unused by theft settle; far crest OOS; Fri spill Soft OK MVP untouched; `apply_medium_capacity` unused | **PASS** (soft) |
| 8 | No Art | PR #44 files: events.json + economy/demand + market_event(+service) + test_runner only | **PASS** |

## Key measured evidence

| Surface | Key numbers |
|---------|-------------|
| Constants | `THEFT_RING_SHRINK_MULT` **3.0**; duration **3 days** |
| Catalog | `hype_spike`, `soft_rotation_leak`, `fog_day`, `counterfeit_scare`, `convention_weekend`, `theft_ring` |
| Baseline unstaffed | rate **0.007**; shrink_mult **1.0**; loss **150**; COGS **20225** |
| Theft unstaffed | rate **0.021** (×3); shrink_mult **3.0**; loss **425**; units_removed **17** |
| Theft + cashier | rate **0.006** (×3 of staffed **0.002**); loss **125**; staff_on_floor true |
| remaining_days | **3→2→1→clear**; shrink restores to 1.0 |
| Seeded fire | seed **1**, day **9** |
| Banner | `Rumor: extra loss on the floor — staff up or wait it out` |
| Save | `id=theft_ring`, `remaining_days=3`, `price_editor_prompted=false` |
| Truth scan | `truth_scan_leaks: []` |
| Harness | **227 PASS / 0 FAIL / 10 SOFT** |
| Foundation | `All foundation tests passed.` EXIT:0 |
| Import | EXIT:0 |

## Design SoT alignment

- **pick-o / Option O1:** Theft ring rumor; Shrink ×3 for 3 days; staff coverage / wait-out; §4.5 clean; Softs unused; no Art; cameras out.
- **systems §8:** Pack event via existing MarketEvent / DemandSignals path; thin EventBanner rumor only.
- **Option D:** Hype/Fog → PriceEditor one-shot unchanged; theft does not bridge.
- **Out of scope (honored):** Camera prop unlock mini-tree; multi-week crime arc; Art; Soft seed / far crest; Soft Fri spill Soft OK MVP; docs/ (PM syncs).

## Soft Eng notes disposition (APPROVE-with-notes)

| Soft Eng note | Disposition |
|---------------|-------------|
| EventBanner-only rumor Soft OK for MVP | **Non-blocking / intentional.** Thin `%EventBannerLabel` rumor present and exact; do **not** FAIL for absence of richer rumor HUD. No S0–S2. |
| docs-only behind main | **Non-blocking.** Tip is economy + thin HUD + foundation tests; docs/ not required on this tip (PM syncs). No S0–S2. |
| cameras stay locked this pack | **Non-blocking / intentional OOS.** Wait-out + staff lever documented; no camera unlock mini-tree. |

## Soft Eng nits (non-blocking / parked)

1. **Soft Eng EventBanner-only rumor Soft OK MVP** — thin rumor HUD intentional; do not FAIL. (**S4**)
2. **Soft seed `_ensure_priceable_sku`** — keep parked; Hype/Fog bridge only; unused by O1 theft. (**S4**)
3. **Soft far crest** — Art Large OOS; No Art for O1. (**S4**)
4. **Soft Fri spill Soft OK MVP stands** — O1 does not retune convention calendar weights. (**S4**)
5. **Soft `apply_medium_capacity` naming** — still defined for Large/Medium capacity; unused by O1 event surfaces; keep parked. (**S4**)
6. **Soft Eng docs-only behind main** — see disposition above. (**S4**)
7. **No Art** — confirmed OOS.
8. **Cameras locked** — intentional OOS wait-out lever. (**S4**)

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
| Report (root) | `/workspace/card-shop-qa/playtest-o1-theft-87f78d15.md` |
| Report (docs) | `/workspace/card-shop-qa/docs/qa/playtest-o1-theft-87f78d15.md` |
| Evidence dir | `/workspace/card-shop-qa/evidence/o1-87f78d15/` |
| Import log | `…/import.log` (EXIT:0) |
| Foundation log | `…/foundation.log` (EXIT:0) |
| Harness log | `…/qa_o1_smoke.log` |
| Harness JSON | `…/qa_o1_theft_smoke.json` |
| Checkout | `/workspace/qa-playtest/o1-87f78d15/` @ `87f78d15fded087b1ebb3da21cf6b993c37d0c26` |
| Harness script | `/workspace/card-shop-qa/qa_o1_theft_smoke.gd` (copied → `tests/qa_o1_theft_smoke.gd`) |

## Harness counts

- **PASS_COUNT=227**
- **FAIL_COUNT=0**
- **SOFT_COUNT=10**
- **TIP_SHA=87f78d15fded087b1ebb3da21cf6b993c37d0c26**

## Merge

Merged to main as **PR #44** @ `3074c9d6ec4af81b6e299b3047d3628d0904bfbe` (2026-09-06). Soft EventBanner-only rumor Soft OK MVP; Softs otherwise parked. Next Eng SoT pick from Design.
