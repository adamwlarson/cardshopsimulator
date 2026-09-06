# Playtest report — G1 graded authenticity formal smoke @ `92404cac` (PR #35)

**Scorer:** CSS QA (executor)  
**Date:** 2026-09-06 (~2:30 PM ET)  
**Build:** `adamwlarson/cardshopsimulator` tip **`92404cac8e1859ab8869162d43071b2d6fd400d6`** (tree `/workspace/qa-playtest/g1-92404cac/`)  
**Mode:** **Normal** (`data/balance/normal.tres`) — Easy/Hard rate + Rep-inherit cross-check  
**Godot:** 4.5.2.stable.official.6ce3de25a (`/workspace/godot452`)  
**Scope:** Formal G1 graded authenticity smoke — fake-slab sell-fail, Inspect★ cert fog, §4.5 confirm nacks, Empress/#8 path, shady/auction rates  
**Method:** Headless — foundation `tests/test_runner.gd` (includes `_test_g1_graded_authenticity` + `_test_g1_*`) + SceneTree harness `tests/qa_g1_authenticity_smoke.gd`  
**Design SoT:** pick-g G1 GO; PR #35 body; systems §4.5 fog / Inspect★ Attention; Soft Eng parkeds non-blocking; **No Art**

## Executive verdict

| Gate (pass bar) | Result |
|-----------------|--------|
| 1. Seeded fake slab can sell-fail without prior Inspect (Rep/cash + instrumentation) | **PASS** |
| 2. Inspect★ spend clears cert fog for that instance (not comps); Attention cost ~85% accuracy path | **PASS** |
| 3. Confirm screens never show raw `cert_valid` / `true_market` / `p_buy` without Inspect (§4.5) | **PASS** — 0 hard UI hits |
| 4. Empress / #8 graded path still works; §4.5 clean | **PASS** |
| 5. Shady/auction rates wired (Normal ~8% `shady_fake_slab_rate`) | **PASS** |
| 6. Soft parked (non-blocking) | **PASS** (soft noted) |

| Supporting | Result |
|------------|--------|
| Tip SHA confirmed | **`92404cac8e1859ab8869162d43071b2d6fd400d6`** (`Fix G1 inspect test to reuse the same price DTO.`) |
| Foundation `test_runner` | **PASS** — `All foundation tests passed.` (G1 suite exercised; `slab_sale_failed` QA event observed) |
| Formal G1 smoke harness | **PASS** — **217 PASS / 0 FAIL**; `SOFT_COUNT=7` |
| S0–S2 (severity rubric) | **None found** for this tip |

**Overall: PASS-with-notes**

G1 graded authenticity clears the formal pass bar on Normal at tip `92404cac`. Soft Eng parkeds only; no S0–S2.

**Clear for merge?** **YES** (PASS-with-notes; soft only).

## Pass-bar checklist

| # | Check | Observed | Verdict |
|---|-------|----------|---------|
| 1 | Sell-fail without Inspect | `seed_fake_slab` → uninspected fail; `confirm_customer_sale` removes slab; cash **800000→788000** (−12000 listed); Rep **40→25** (−15); QA `slab_sale_failed` `{outcome:sale_fail, inspected:false, cash_penalty_cents:12000, rep_delta:-15}` | **PASS** |
| 2a | Inspect clears cert fog (not comps) | Fog `Slab — inspect recommended` → `Hologram looks off` (accurate domain inspect); comps **7482–8232** + demand band frozen on same price DTO | **PASS** |
| 2b | HUD Inspect★ Attention | PriceEditor Inspect★ visible/enabled; Att **100→95** (cost **5**); fog cleared; button disables after | **PASS** |
| 2c | ~85% accuracy path | Normal `inspect_accuracy=0.85`; `inspect_attention=5` | **PASS** |
| 3a | Confirm §4.5 | Shady graded DTO has no truth fields; cue inspect fog; BuySummary + BuyConfirmSummary hide `cert_valid`/`true_market`/`p_buy` pre/post Inspect★ | **PASS** |
| 3b | UI truth scan | hud / presenter / main_menu (+ tscn) — **0** hard hits | **PASS** |
| 4 | Empress / #8 | Day 11 PREP starts `sec10_8_slab_vs_singles`; Empress slab authentic Prism; `choose_showcase(slab)` → CASE; cue clean | **PASS** |
| 5 | Rates wired | Normal **0.08** / Easy **0.04** / Hard **0.14**; shady 100%→fake; auction 0%→valid; non-risky receive authentic | **PASS** |
| 6 | Soft parkeds | Soft Eng only (see below) | **PASS** (soft) |

## Key measured evidence

| Surface | Key numbers |
|---------|-------------|
| BalanceConfig (Normal) | `shady_fake_slab_rate` **0.08**; `inspect_accuracy` **0.85**; `inspect_attention` **5**; `fake_slab_sale_rep_hit` **15** |
| Easy / Hard rates | **0.04** / **0.14**; Rep hit inherits **15** |
| Gate1 sell-fail | cash −**12000**; Rep −**15**; QA `slab_sale_failed` |
| Gate2 domain inspect | cue → **Hologram looks off**; comps unchanged |
| Gate2 HUD | Att **100→95**; cost **5** |
| Gate4 #8 | beat started; `cert_valid=true`; grader Prism; CASE display |
| Truth scan | `truth_scan_leaks: []` (hard UI paths) |
| Harness | 217 PASS / 0 FAIL / 7 SOFT |

## Design SoT alignment

- **pick-g / Option G1:** Fake-slab authenticity on graded shady/auction stock; Inspect★ cert reveal; sale-fail penalties; Empress/#8 unchanged; §4.5 confirm clean.
- **systems §4.5:** Confirm/detail never show raw `cert_valid` / `true_market` / `p_buy`; hologram cues only after Inspect.
- **Inspect★:** Attention spend updates condition/cert cue only (not comps); Normal accuracy ~85%.
- **Out of scope (honored):** No Art; Soft `_ensure_priceable_sku` parked; no new grader brands / lab mini-game / Large expand / G2 online listings.

## Soft Eng nits (non-blocking)

1. **Soft `_ensure_priceable_sku`** — left parked; OOS for G1. (**S4**)
2. **Soft `fake_slab_sale_rep_hit` inherits 15** across Easy/Hard (and Normal) diffs via `BalanceConfig` script default — not mirrored in `easy.tres` / `hard.tres` / `normal.tres`. Foundation + harness assert inherit. Prefer mirroring for diff clarity. (**S4**)
3. **Soft sku-first Inspect multi-slab edge** — `InventoryService.get_slab(sku)` returns first match; PriceEditor Inspect★ targets that instance only when multiple slabs share a SKU. (**S4**)
4. **Soft thin player-facing fail toast vs strong instrumentation** — `_fail_fake_slab_sale` applies cash/Rep + QA `slab_sale_failed` but no dedicated BeatToast copy for the authenticity fail. (**S4**)
5. **Defensive filter tokens** in `customer_intent_icon.gd` (`true_market` / `cert_valid` rejection predicates) — filter-only; not player-facing; non-blocking. (**S4**)
6. **No Art** — confirmed OOS.

## Findings (severity-ranked)

### S0–S2
**None.**

### S3
**None.**

### S4 / notes
Soft Eng parkeds above only.

## Evidence paths

| Artifact | Path |
|----------|------|
| Checkout | `/workspace/qa-playtest/g1-92404cac` @ `92404cac8e1859ab8869162d43071b2d6fd400d6` |
| Import log | `/workspace/card-shop-qa/evidence/g1-92404cac/import.log` (+ `import_full.log`) |
| Foundation log | `/workspace/card-shop-qa/evidence/g1-92404cac/foundation.log` |
| Harness log | `/workspace/card-shop-qa/evidence/g1-92404cac/qa_g1_smoke.log` |
| Harness JSON | `/workspace/card-shop-qa/evidence/g1-92404cac/qa_g1_authenticity_smoke.json` |
| Harness script | `/workspace/card-shop-qa/qa_g1_authenticity_smoke.gd` (also `tests/qa_g1_authenticity_smoke.gd` in checkout) |
| This report | `/workspace/card-shop-qa/playtest-g1-auth-92404cac.md` |
| docs/qa copy | `/workspace/card-shop-qa/docs/qa/playtest-g1-auth-92404cac.md` |

## Repro (PASS path)

```bash
ROOT=/workspace/qa-playtest/g1-92404cac
# after Godot editor import completes
godot --headless --path "$ROOT" --script res://tests/test_runner.gd
godot --headless --path "$ROOT" --script res://tests/qa_g1_authenticity_smoke.gd
```

## FAIL repro

N/A — no failing gates.

## Merge

Merged to main as **PR #35** @ `8a7f7a73becb3f50712398c79466be33ae23c1e1` (2026-09-06).
