# Playtest report — N1 Convention weekend formal smoke @ `1ab9983f` (PR #43)

**Scorer:** CSS QA (executor)  
**Date:** 2026-09-06 (~4:25 PM ET)  
**Build:** `adamwlarson/cardshopsimulator` tip **`1ab9983fdb83b7e3f60eb973cfe572b5ba0f15ae`** (tree `/workspace/qa-playtest/n1-1ab9983f/`)  
**Mode:** **Normal** (`data/balance/normal.tres`)  
**Godot:** 4.5.2.stable.official.6ce3de25a (`/workspace/godot452` / `/home/box/.local/bin/godot`)  
**Scope:** Formal N1 Convention weekend smoke after Eng APPROVE-with-notes — Fri telegraph → Sat/Sun weight; traffic ×2 stacked on tier; whale ×2.5; staff/price/refuse agency + FLOOR settle; EventBanner; §4.5 clean; Counterfeit scare + Option D Hype/Fog untouched; Softs parked; No Art  
**Method:** Headless — foundation `tests/test_runner.gd` (includes `_test_convention_weekend_*`) + SceneTree harness `tests/qa_n1_convention_smoke.gd`  
**Design SoT:** `docs/design/next-eng-sot-pick-n-v1.md` § N1; systems §8 Convention weekend; PR #43 acceptance  
**Priors:** M1 Counterfeit `ce5577a4`; C1 market `8ccdcbfd`; M2 Large re-smoke `83885e7d`  
**No Art.** Soft Eng notes: Sat/Sun peak SoT (Mon/Tue bleed Soft OK; Fri settle-weight spill Soft OK); docs-only / thin HUD / CustomerSpawner.new headless — non-blocking unless S0–S2.

## Executive verdict

| Gate (Designer bar) | Result |
|---------------------|--------|
| 1. Convention fires (Fri telegraph → Sat/Sun weight; seeded `start_pack_event` / settle) | **PASS** |
| 2. During active: traffic ×2 stacked on tier (spawn interval ≈ half); whale weight ×2.5; restore when ends | **PASS** |
| 3. Staff / price / refuse still player agency — no soft-lock; FLOOR can settle | **PASS** |
| 4. EventBanner OK | **PASS** |
| 5. §4.5 clean (no `cert_valid` / `true_market` / `p_buy` on banners/confirms) | **PASS** — 0 UI hits |
| 6. Counterfeit scare + Option D Hype/Fog untouched | **PASS** |
| 7. Soft `_ensure_priceable_sku` / Soft far crest / Soft `apply_medium_capacity` parked | **PASS** (soft noted) |
| 8. No Art | **PASS** |

| Supporting | Result |
|------------|--------|
| Tip SHA confirmed | **`1ab9983fdb83b7e3f60eb973cfe572b5ba0f15ae`** (`test(economy): avoid CustomerSpawner.new in N1 headless suite`; PR tip after feat commit `776bf700`) |
| Import `--editor --quit-after 120` | **PASS** — EXIT:0 |
| Foundation `test_runner` | **PASS** — `All foundation tests passed.` EXIT:0 (N1 suite + seeded roll `convention_weekend` day **13** Sat; `traffic_mult=2.0 whale_weight_mult=2.5 calendar_day=true`) |
| Formal N1 smoke harness | **PASS** — **288 PASS / 0 FAIL**; `SOFT_COUNT=12` |
| Soft Eng calendar notes | **Non-blocking** — Sat/Sun peak 2.5 dominate Mon/Tue 1.0; Fri telegraph shares 2.5× (spill Soft OK) |
| Soft Eng notes disposition | **Non-blocking** — docs-only / thin HUD / headless spawner assert; no S0–S2 |
| S0–S2 (severity rubric) | **None found** for this tip |

**Overall: PASS-with-notes**

N1 Convention weekend clears the formal pass bar on Normal at tip `1ab9983f`. Soft Eng parkeds + Soft seed/far-crest/`apply_medium_capacity` + Fri spill / Mon-Tue bleed Softs remain parked; no Art; no S0–S2. Seeded settle fire landed **Saturday day 13** (SoT peak).

**Clear for merge?** **YES** (PASS-with-notes; soft only).

## Pass-bar checklist

| # | Check | Observed | Verdict |
|---|-------|----------|---------|
| 1a | Fri telegraph → Sat/Sun weight | Fri day 5 telegraph `"Calendar: Convention weekend incoming"`; Sat/Sun weight **2.5**; Wed/Thu **1.0**; Sat/Sun dominate Mon/Tue | **PASS** |
| 1b | `start_pack_event(KIND_CONVENTION)` | kind `convention_weekend`; remaining_days 2; `has_convention_weekend` true; no PriceEditor | **PASS** |
| 1c | Seeded settle roll | seed **20260904** day **13** (Sat weekday 6) rolled convention; calendar_fired true | **PASS** |
| 2a | Traffic ×2 stacked on tier | Small 12→**6**; Medium 12→**6**; Large 9.6→**4.8** (12/1.25/2); restores to baseline | **PASS** |
| 2b | Whale weight ×2.5 | baseline **4.0** → con **10.0**; low-rep gate still **0.0**; restores to 1.0 / baseline | **PASS** |
| 3a | Staff / price / refuse | hire_cashier OK; list price 4499→4749; refuse over-queue OK (no sale) | **PASS** |
| 3b | FLOOR settle | `start_floor` + `start_settle` true during convention — no soft-lock | **PASS** |
| 4 | EventBanner | exact `"Calendar: Convention weekend — busier floor · whales inbound"` on service + `%EventBannerLabel` | **PASS** |
| 5 | §4.5 | HUD banners/confirms + save keys + UI scan — **0** `cert_valid`/`true_market`/`p_buy` leaks | **PASS** |
| 6 | Counterfeit + Option D | scare replaces convention on shared bus; Hype/Fog still want PriceEditor; convention does not | **PASS** |
| 7 | Softs parked | Soft seed defined but unused on convention path; far crest OOS; `apply_medium_capacity` unused by event surfaces | **PASS** (soft) |
| 8 | No Art | PR #43 files: events.json + economy/customers/hud + test_runner only | **PASS** |

## Key measured evidence

| Surface | Key numbers |
|---------|-------------|
| Constants | traffic **2.0**; whale **2.5**; calendar weight **2.5** |
| Catalog | `hype_spike`, `soft_rotation_leak`, `fog_day`, `counterfeit_scare`, `convention_weekend` |
| Spawn wait | Small/Medium **12→6**; Large **9.6→4.8**; restore Large **9.6** |
| Whale weight | high-rep **4.0→10.0**; low-rep gate **0.0** |
| Seeded fire | seed **20260904**, day **13** (Sat), `calendar_day=true` |
| Banner | `Calendar: Convention weekend — busier floor · whales inbound` |
| Friday news | `Calendar: Convention weekend incoming` |
| Save | `id=convention_weekend`, `remaining_days=2`, `price_editor_prompted=false` |
| Truth scan | `truth_scan_leaks: []` |
| Harness | 288 PASS / 0 FAIL / 12 SOFT |
| Foundation | `All foundation tests passed.` EXIT:0 |

## Design SoT alignment

- **pick-n / Option N1:** Convention weekend calendar telegraph; traffic ×2; whale ↑; staff/price/refuse levers; §4.5 clean; Softs unused; no Art.
- **systems §8:** Calendar Convention weekend — Traffic ×2, whale chance ↑; Staff up, price up carefully.
- **Calendar Soft steering:** Sat/Sun peak is SoT. Fri settle-weight spill Soft OK (Fri shares 2.5× telegraph). Mon/Tue bleed Soft OK for MVP if Sat/Sun still dominate (this tip: Mon/Tue stay 1.0).
- **Option D:** Hype/Fog → PriceEditor one-shot unchanged; Convention does not bridge.
- **M1 Counterfeit:** Still replaces on shared pack bus; trust/shady/Inspect path untouched.
- **Out of scope (honored):** Full event-night play-table; multi-day con circuit; Art meshes; BalanceConfig lease/rent/staff-cap rewrites; Softs.

## Soft Eng notes disposition (APPROVE-with-notes + steering)

| Soft Eng note | Disposition |
|---------------|-------------|
| Sat/Sun peak SoT; Mon/Tue bleed Soft OK | **Non-blocking.** Sat/Sun weight **2.5** dominate Mon/Tue **1.0**. Seeded fire on Sat day 13. No FAIL. |
| Fri settle-weight spill Soft OK | **Non-blocking.** Friday telegraph shares weekend **2.5×** settle weight; Sat/Sun still peak. Do not FAIL. |
| docs-only behind main | **Non-blocking.** Tip is economy + thin HUD + foundation tests; docs/ not required on this tip (PM syncs). No S0–S2. |
| thin HUD | **Non-blocking / intentional.** Calendar EventBanner only — matches SoT thin telegraph. No S0–S2. |
| CustomerSpawner.new headless | **Non-blocking.** Tip commit asserts spawn hooks from source (autoload compile order). Landed at tip. |

## Soft Eng nits (non-blocking / parked)

1. **Soft seed `_ensure_priceable_sku`** — keep parked; Hype/Fog bridge only; unused by N1 convention. (**S4**)
2. **Soft far crest** — Art Large OOS; No Art for N1. (**S4**)
3. **Soft `apply_medium_capacity` naming** — still defined for Large/Medium capacity; unused by N1 event surfaces; keep parked. (**S4**)
4. **Fri settle-weight spill Soft** — Friday shares 2.5× calendar weight with Sat/Sun; intentional telegraph; Soft OK. (**S4**)
5. **Mon/Tue bleed Soft** — unused on this tip (weight 1.0); Soft OK if later MVP bleed stays under Sat/Sun. (**S4**)
6. **Soft Eng docs-only / thin HUD / headless spawner** — see disposition above. (**S4**)
7. **No Art** — confirmed OOS.

## Findings (severity-ranked)

### S0–S2
**None.**

### S3
**None.**

### S4 / notes
Soft parkeds above only. Headless `--script` may emit transient `GameState` compile noise before autoloads resolve; foundation + harness still EXIT:0 with full gate coverage (known Godot script-load ordering; non-blocking).

## Evidence paths

| Artifact | Path |
|----------|------|
| Checkout | `/workspace/qa-playtest/n1-1ab9983f` @ `1ab9983fdb83b7e3f60eb973cfe572b5ba0f15ae` |
| Import log | `/workspace/card-shop-qa/evidence/n1-1ab9983f/import.log` |
| Foundation log | `/workspace/card-shop-qa/evidence/n1-1ab9983f/foundation.log` |
| Harness log | `/workspace/card-shop-qa/evidence/n1-1ab9983f/qa_n1_smoke.log` |
| Harness JSON | `/workspace/card-shop-qa/evidence/n1-1ab9983f/qa_n1_convention_smoke.json` |
| Harness script | `/workspace/qa-playtest/n1-1ab9983f/tests/qa_n1_convention_smoke.gd` (+ `/workspace/card-shop-qa/qa_n1_convention_smoke.gd`) |
| This report | `/workspace/card-shop-qa/playtest-n1-convention-1ab9983f.md` |
| docs/qa copy | `/workspace/card-shop-qa/docs/qa/playtest-n1-convention-1ab9983f.md` |

## Repro (PASS path)

```bash
ROOT=/workspace/qa-playtest/n1-1ab9983f
godot --headless --editor --quit-after 120 --path "$ROOT"
godot --headless --path "$ROOT" --script res://tests/test_runner.gd
godot --headless --path "$ROOT" --script res://tests/qa_n1_convention_smoke.gd
```

## FAIL repro

N/A — no failing gates.

## Clear for merge?

**YES** — PASS-with-notes. No S0–S2 blockers. Soft Eng calendar notes (Sat/Sun peak; Fri spill Soft OK; Mon/Tue bleed Soft OK) and Soft seed / far crest / `apply_medium_capacity` remain parked. No Art.

## Merge

Merged to main as **PR #43** @ `73ac9daee5df81d68950f12e883c47e9dabd3bcd` (2026-09-06). Soft Fri spill OK for MVP; Softs otherwise parked. Next Eng SoT pick from Design.
