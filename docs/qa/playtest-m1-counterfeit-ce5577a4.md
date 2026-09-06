# Playtest report — M1 Counterfeit scare formal smoke @ `ce5577a4` (PR #42)

**Scorer:** CSS QA (executor)  
**Date:** 2026-09-06 (~4:05 PM ET)  
**Build:** `adamwlarson/cardshopsimulator` tip **`ce5577a4fe87a2dc51b687dcfddff4e1504f04a9`** (tree `/workspace/qa-playtest/m1-ce5577a4/`)  
**Mode:** **Normal** (`data/balance/normal.tres`)  
**Godot:** 4.5.2.stable.official.6ce3de25a (`/workspace/godot452`)  
**Scope:** Formal M1 Counterfeit scare smoke after Eng APPROVE-with-notes — event fire, graded trust↓ 0.55 + Inspect mandatory, shady ×2.5 + telegraph, G1 ON/OFF coherence, §4.5 clean, Option D Hype/Fog untouched, Softs parked, EventBanner telegraph  
**Method:** Headless — foundation `tests/test_runner.gd` (includes `_test_counterfeit_scare_*` + G1 suite) + SceneTree harness `tests/qa_m1_counterfeit_smoke.gd`  
**Design SoT:** `docs/design/next-eng-sot-pick-m-v1.md` § M1; systems §8; PR #42 acceptance  
**Priors:** G1 auth `92404cac`; C1 market `8ccdcbfd`; M2 Large re-smoke `83885e7d`  
**No Art.** Soft Eng notes: docs-only behind main; thin HUD — non-blocking unless S0–S2.

## Executive verdict

| Gate (Designer bar) | Result |
|---------------------|--------|
| 1. Event fires (seeded / `start_pack_event`) | **PASS** |
| 2. During event: graded trust↓ (0.55) + Inspect mandatory on graded path | **PASS** |
| 3. Shady risk visibly worse (fake-rate ×2.5 + telegraph) | **PASS** |
| 4. G1 fake-slab / Inspect★ coherent with event ON and OFF | **PASS** |
| 5. Never leaks `cert_valid` / `true_market` / `p_buy` (§4.5) | **PASS** — 0 UI hits |
| 6. Option D Hype/Fog → PriceEditor untouched | **PASS** |
| 7. Soft seed / Soft far crest / Soft `apply_medium_capacity` unused/parked | **PASS** (soft noted) |
| 8. EventBanner telegraph present | **PASS** |

| Supporting | Result |
|------------|--------|
| Tip SHA confirmed | **`ce5577a4fe87a2dc51b687dcfddff4e1504f04a9`** (`feat(economy): add M1 Counterfeit scare market event`) |
| Import `--editor --quit-after 120` | **PASS** — EXIT:0 |
| Foundation `test_runner` | **PASS** — `All foundation tests passed.` EXIT:0 (counterfeit suite + G1 exercised; seeded roll `counterfeit_scare` day 8) |
| Formal M1 smoke harness | **PASS** — **287 PASS / 0 FAIL**; `SOFT_COUNT=6` |
| Soft Eng notes disposition | **Non-blocking** — docs-only behind main; thin HUD intentional; no S0–S2 |
| S0–S2 (severity rubric) | **None found** for this tip |

**Overall: PASS-with-notes**

M1 Counterfeit scare clears the formal pass bar on Normal at tip `ce5577a4`. Soft Eng parkeds + Soft seed/far-crest/`apply_medium_capacity` remain parked; no Art; no S0–S2.

**Clear for merge?** **YES** (PASS-with-notes; soft only).

## Pass-bar checklist

| # | Check | Observed | Verdict |
|---|-------|----------|---------|
| 1a | `start_pack_event(KIND_COUNTERFEIT)` | kind `counterfeit_scare`; remaining_days 2; `has_counterfeit_scare` true; no PriceEditor | **PASS** |
| 1b | Seeded settle roll | seed **1** day **8** rolled scare; QA `market_event_rolled` `{graded_trust_mult:0.55, inspect_mandatory:true, shady_width_mult:1.35}` | **PASS** |
| 2a | Graded trust scalar | off **1.0** → on **0.55** (`COUNTERFEIT_TRUST_MULT`); clears back to 1.0 | **PASS** |
| 2b | Inspect mandatory | graded auction DTO `can_confirm=false`; cue contains `inspect mandatory`; confidence **low**; domain `confirm_buy` rejects until Inspect★ | **PASS** |
| 3a | Shady fake-rate ×2.5 | Normal base **0.08** → scare **0.20**; auction unchanged **0.08**; width mult **1.35** | **PASS** |
| 3b | Shady telegraph | off-event cue no scare; on-event cue contains `counterfeit scare` | **PASS** |
| 4a | G1 OFF | uninspected fake sale still fail-resolves (cash −listed) | **PASS** |
| 4b | G1 ON | uninspected sale gated; Inspect★ → `Hologram looks off`; inspected fail still cash/Rep penalty | **PASS** |
| 5 | §4.5 | HUD Buy/Inspect/confirm + save keys + UI scan — **0** `cert_valid`/`true_market`/`p_buy` leaks | **PASS** |
| 6 | Option D | scare `wants_event_price_editor=false`; Hype + Fog still bridge | **PASS** |
| 7 | Softs parked | Soft seed defined but unused on counterfeit path; far crest OOS; `apply_medium_capacity` unused by event surfaces | **PASS** (soft) |
| 8 | EventBanner | exact `"Counterfeit scare — Inspect mandatory · shady risk up"` on service + `%EventBannerLabel` | **PASS** |

## Key measured evidence

| Surface | Key numbers |
|---------|-------------|
| Constants | trust **0.55**; shady fake ×**2.5**; shady width ×**1.35** |
| Catalog | `hype_spike`, `soft_rotation_leak`, `fog_day`, `counterfeit_scare` |
| Balance Normal | `shady_fake_slab_rate` **0.08** → scare **0.20** |
| Seeded fire | seed **1**, day **8** |
| Banner | `Counterfeit scare — Inspect mandatory · shady risk up` |
| Save | `id=counterfeit_scare`, `remaining_days=1`, `price_editor_prompted=false` |
| Truth scan | `truth_scan_leaks: []` |
| Harness | 287 PASS / 0 FAIL / 6 SOFT |
| Foundation | `All foundation tests passed.` EXIT:0 |

## Design SoT alignment

- **pick-m / Option M1:** Counterfeit scare news-flash; graded trust↓; Inspect mandatory; shady riskier; G1 coherent; §4.5 clean; Softs unused.
- **systems §8:** Pack event via existing MarketEvent / DemandSignals path; thin EventBanner only.
- **Option D:** Hype/Fog → PriceEditor one-shot unchanged; scare does not bridge.
- **Out of scope (honored):** New grader brands; camera unlock / theft ring; Large rent re-tune; Art; Soft seed / far crest; docs/ (PM syncs).

## Soft Eng notes disposition (APPROVE-with-notes)

| Soft Eng note | Disposition |
|---------------|-------------|
| docs-only behind main | **Non-blocking.** Tip is economy + thin HUD + foundation tests; docs/ not required on this tip (PM syncs). No S0–S2. |
| thin HUD | **Non-blocking / intentional.** EventBanner + Inspect★ gate + Buy disabled until inspect — matches SoT thin telegraph. No S0–S2. |

## Soft Eng nits (non-blocking / parked)

1. **Soft seed `_ensure_priceable_sku`** — keep parked; Hype/Fog bridge only; unused by M1 scare. (**S4**)
2. **Soft far crest** — Art Large OOS; No Art for M1. (**S4**)
3. **Soft `apply_medium_capacity` naming** — still defined for Large/Medium capacity; unused by M1 event surfaces; keep parked. (**S4**)
4. **Soft Eng docs-only behind main** — see disposition above. (**S4**)
5. **Soft Eng thin HUD** — see disposition above. (**S4**)
6. **No Art** — confirmed OOS.

## Findings (severity-ranked)

### S0–S2
**None.**

### S3
**None.**

### S4 / notes
Soft parkeds above only. Headless `--script` may emit transient `GameState` compile noise before autoloads resolve; harness still EXIT:0 with full gate coverage (known Godot script-load ordering; non-blocking).

## Evidence paths

| Artifact | Path |
|----------|------|
| Checkout | `/workspace/qa-playtest/m1-ce5577a4` @ `ce5577a4fe87a2dc51b687dcfddff4e1504f04a9` |
| Import log | `/workspace/card-shop-qa/evidence/m1-ce5577a4/import.log` |
| Foundation log | `/workspace/card-shop-qa/evidence/m1-ce5577a4/foundation.log` |
| Harness log | `/workspace/card-shop-qa/evidence/m1-ce5577a4/qa_m1_smoke.log` |
| Harness JSON | `/workspace/card-shop-qa/evidence/m1-ce5577a4/qa_m1_counterfeit_smoke.json` |
| Harness script | `/workspace/qa-playtest/m1-ce5577a4/tests/qa_m1_counterfeit_smoke.gd` (+ `/workspace/card-shop-qa/qa_m1_counterfeit_smoke.gd`) |
| This report | `/workspace/card-shop-qa/playtest-m1-counterfeit-ce5577a4.md` |
| docs/qa copy | `/workspace/card-shop-qa/docs/qa/playtest-m1-counterfeit-ce5577a4.md` |

## Repro (PASS path)

```bash
ROOT=/workspace/qa-playtest/m1-ce5577a4
godot --headless --editor --quit-after 120 --path "$ROOT"
godot --headless --path "$ROOT" --script res://tests/test_runner.gd
godot --headless --path "$ROOT" --script res://tests/qa_m1_counterfeit_smoke.gd
```

## FAIL repro

N/A — no failing gates.

## Clear for merge?

**YES** — PASS-with-notes. No S0–S2 blockers. Soft Eng notes (docs-only / thin HUD) and Soft seed / far crest / `apply_medium_capacity` remain parked.

## Merge

Merged to main as **PR #42** @ `a266dcbcdd6b852040b95976d3d788cb30a5ec58` (2026-09-06). Softs keep parked. Next Eng SoT pick from Design.
