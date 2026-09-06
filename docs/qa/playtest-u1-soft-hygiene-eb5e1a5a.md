# Playtest report — U1 Soft hygiene S3 spot-check @ `eb5e1a5a` (PR #50 SH8)

**Scorer:** CSS QA (executor)  
**Date:** 2026-09-06 (~6:22 PM ET)  
**Build:** `adamwlarson/cardshopsimulator` tip **`eb5e1a5a93fb4f168305099e6e24c770d380fa9b`** (short `eb5e1a5a`) — PR #50 *SH8: rename apply_medium_capacity to apply_shop_capacity_bonuses*  
**Checkout:** `/workspace/qa-playtest/u1-eb5e1a5a/`  
**Mode:** **Normal** (`data/balance/normal.tres`)  
**Godot:** 4.5.2.stable.official.6ce3de25a (`/workspace/godot452`)  
**Scope:** S3 spot-check after Eng APPROVE — **SH8 rename only**. Softs SH1–SH6 Won’t-Fix locked; Soft no mode-picker CLOSED (#49); SH7 Art later. No new verbs.  
**Method:** Headless — import `--editor --quit-after 120` + foundation `tests/test_runner.gd` + focused SceneTree harness `tests/qa_u1_soft_hygiene_smoke.gd` (PriceEditor / Large Sign capacity / Flagship)  
**Design SoT:** `docs/design/soft-hygiene-u1-v1.md`; pick-u U1 (`docs/design/next-eng-sot-pick-u-v1.md`)  
**No Art.** No new player verbs. Behavior unchanged (hard rename, no alias).

## Executive verdict

| Gate (S3 smoke bar) | Result |
|---------------------|--------|
| 1. Old name `apply_medium_capacity` gone from tip `scripts/` + `tests/` | **PASS** — COUNT:0 |
| 2. New name `apply_shop_capacity_bonuses` used; Large expand stacked Medium+Large bonuses | **PASS** |
| 3. PriceEditor still works (SH1 Soft seed Won’t-Fix — still present, unused by rename) | **PASS** |
| 4. Large expand Sign path OK (capacity bonuses) | **PASS** |
| 5. Flagship award still works | **PASS** |
| 6. Foundation EXIT:0 | **PASS** |
| 7. SH1–SH6 Won’t-Fix locked; Soft no mode-picker CLOSED; SH7 Art later | **PASS** |
| 8. No behavior change / no new verbs / §4.5 clean | **PASS** |

| Supporting | Result |
|------------|--------|
| Tip SHA confirmed | **`eb5e1a5a93fb4f168305099e6e24c770d380fa9b`** (`Rename apply_medium_capacity to apply_shop_capacity_bonuses.`) |
| Import `--editor --quit-after 120` | **PASS** — EXIT:0 |
| Foundation `test_runner` | **PASS** — `All foundation tests passed.` EXIT:0 |
| Focused U1 harness | **PASS-with-notes** — **58 PASS / 0 FAIL / 14 SOFT** |
| Soft disposition | **Non-blocking** — SH8 Eng rename DONE; SH1–SH6 Won’t-Fix locked; SH7 Art later; Soft no mode-picker CLOSED |
| Clear for merge | **YES** |

**Overall: PASS-with-notes**

Hard rename of Soft `apply_medium_capacity` → `apply_shop_capacity_bonuses` lands cleanly. Tip `scripts/` + tip `tests/test_runner.gd` have **zero** old-name hits. Large Sign still applies stacked Medium+Large capacity via the renamed helper (case bonus **28** = 12+16; backstock **44** = 20+24; limits **52** / **84**). PriceEditor panel still binds; SH1 `_ensure_priceable_sku` remains (Won’t-Fix). Flagship award exact Large+Rep80+$50k still awards once and deactivates. §4.5 UI surfaces clean; no new verbs.

**Clear for merge?** **YES**

## Pass-bar checklist

| # | Check | Observed | Verdict |
|---|-------|----------|---------|
| 1a | Old name gone from tip `scripts/` | 0 hits | **PASS** |
| 1b | Old name gone from tip `tests/` (`test_runner.gd`) | 0 hits | **PASS** |
| 1c | Hard rename (no alias method) | `InventoryService.has_method(apply_medium_capacity)==false` | **PASS** |
| 2a | New name defined | `func apply_shop_capacity_bonuses` in `inventory_service.gd` | **PASS** |
| 2b | Call sites updated | Medium Sign, Large Sign (`case_slot_bonus()`/`backstock_bonus()`), save restore, foundation helpers | **PASS** |
| 2c | Large stacked capacity | case bonus **28**, backstock **44**; limits **52** / **84** | **PASS** |
| 3a | PriceEditor panel present | `%PriceEditor` show/hide OK | **PASS** |
| 3b | SH1 seed still present / unused by rename | `_ensure_priceable_sku` defined; unused by inventory/beat rename surfaces | **PASS** (Won’t-Fix) |
| 4 | Large Sign path | `$40k+Rep70` Sign → tier Large, grid 18×13, stacked bonuses applied | **PASS** |
| 5 | Flagship award | Large+Rep80+$50k → `campaign_won` mode flagship; deactivate; idempotent | **PASS** |
| 6 | Foundation | `All foundation tests passed.` EXIT:0 | **PASS** |
| 7 | Soft disposition locked | SH1–SH6 Won’t-Fix; SH7 Art later; Soft no mode-picker CLOSED; SH8 DONE | **PASS** |
| 8a | §4.5 UI clean | hud / main_menu / beat_injection / game_state — no `true_market` / `p_buy` / `cert_valid` | **PASS** |
| 8b | No new verbs / no behavior change | rename-only; `sign_lease` unchanged | **PASS** |

## Soft disposition callout (U1)

| ID | Soft | Disposition (locked) | This tip |
|----|------|----------------------|----------|
| SH1 | `_ensure_priceable_sku` / empty-SKU seed | **Won’t-Fix** MVP | Still present; unused by rename — confirmed |
| SH2 | Soft Fri Convention spill | **Won’t-Fix** MVP | Untouched |
| SH3 | Soft EventBanner Theft rumor | **Won’t-Fix** MVP | Untouched |
| SH4 | Soft flipper-weight Recession buylist↑ | **Won’t-Fix** MVP | Untouched |
| SH5 | Soft dual cash-eval Flagship | **Won’t-Fix** MVP | Soft OK — award idempotent |
| SH6 | Soft Sandbox PB day-1 | **Won’t-Fix** MVP | Untouched |
| SH7 | Soft far crest thin (J2) | **Art later** | No Eng code |
| SH8 | Soft `apply_medium_capacity` naming | **Eng rename** | **DONE** → `apply_shop_capacity_bonuses` |
| — | Soft no mode-picker | **CLOSED** (#49) | Not reopened |

## Key measured evidence

| Surface | Key numbers |
|---------|-------------|
| Tip | `eb5e1a5a93fb4f168305099e6e24c770d380fa9b` (PR #50 head) |
| Diff | 4 files, +14/−14 — `inventory_service.gd`, `beat_injection.gd`, `game_state.gd`, `tests/test_runner.gd` |
| Medium bonuses | case **12**, backstock **20** |
| Large add-on | case **16**, backstock **24** |
| Stacked Large | case **28**, backstock **44**; limits **52** / **84** |
| L1 Sign gate | cash `4_000_000¢` ($40k); Rep **70** |
| Flagship SoT | Own Large + Rep **80** + cash `5_000_000¢` ($50k) |
| Flagship award | prestige **flagship**; `is_game_active=false`; 2nd evaluate **false** |
| Harness | **58 PASS / 0 FAIL / 14 SOFT** |
| Foundation | `All foundation tests passed.` EXIT:0 |
| Import | EXIT:0 |
| Old name (tip scripts+tests) | **YES gone** (COUNT:0) |

## Design SoT alignment

- **pick-u U1 Soft hygiene closeout:** SH8 Eng rename preferred — **shipped**.
- **soft-hygiene-u1-v1.md:** SH1–SH6 Won’t-Fix locked; SH7 Art later; Soft no mode-picker CLOSED; SH8 rename → `apply_shop_capacity_bonuses`.
- **Out of scope (honored):** No new economy verbs; docs/ not edited by Eng (PM syncs); Soft seed / Fri spill / EventBanner / flipper / dual cash-eval / Sandbox PB untouched; Soft far crest remains Art later.

## Soft nits (non-blocking)

1. **PriceEditor unique-name chips** — `%YourList` / `%DemandChip` not present under those exact unique names on this tip; panel `%PriceEditor` still binds and toggles. Soft OK (naming drift / alt labels). Foundation PriceEditor tests still green.
2. **inventory_service `slab.cert_valid`** — backend slab authenticity field; not a UI §4.5 leak. Soft noted.
3. **Local QA harness** mentions old name only as assertion strings in `/workspace/qa-playtest/.../qa_u1_soft_hygiene_smoke.gd` (not tip-committed). Tip `scripts/` + `tests/test_runner.gd` remain COUNT:0.

## Evidence

| Artifact | Path |
|----------|------|
| Import log | `/workspace/card-shop-qa/evidence/u1-eb5e1a5a/import.log` |
| Foundation log | `/workspace/card-shop-qa/evidence/u1-eb5e1a5a/foundation.log` |
| Harness log | `/workspace/card-shop-qa/evidence/u1-eb5e1a5a/qa_u1_smoke.log` |
| Smoke JSON | `/workspace/card-shop-qa/evidence/u1-eb5e1a5a/smoke.json` |
| Grep tip rename | `/workspace/card-shop-qa/evidence/u1-eb5e1a5a/grep_rename_tip.txt` |
| Harness source | `/workspace/card-shop-qa/qa_u1_soft_hygiene_smoke.gd` |
| Report (root) | `/workspace/card-shop-qa/playtest-u1-soft-hygiene-eb5e1a5a.md` |
| Report (docs/qa) | `/workspace/card-shop-qa/docs/qa/playtest-u1-soft-hygiene-eb5e1a5a.md` |

## Blockers

**None.** No S0–S2. Soft nits non-blocking.

## Clear for merge?

**YES** — rename verified; PriceEditor / Large Sign capacity / Flagship green; foundation EXIT:0; Soft disposition locked; §4.5 clean; no new verbs.
