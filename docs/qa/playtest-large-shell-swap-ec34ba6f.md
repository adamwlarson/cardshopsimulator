# Playtest report — Large shell stub-swap formal @ `ec34ba6f` (PR #41)

**Scorer:** CSS QA (executor)  
**Date:** 2026-09-06 (~3:44 PM ET)  
**Tip SHA:** `ec34ba6f4a2cc624c17706093fadab6850f757b5` (short `ec34ba6f`)  
**PR:** [#41](https://github.com/adamwlarson/cardshopsimulator/pull/41) — *feat(shop): swap Large scaffold for Art hero shell after Sign lease*  
**Repo extract:** `/workspace/qa-playtest/large-shell-ec34ba6f/` (fresh detached HEAD @ tip)  
**Method:** Godot 4.5.2 — import `--editor --quit-after 180`; foundation `tests/test_runner.gd`; formal `tests/qa_large_shell_swap_smoke.gd` under xvfb; aisle viewport PNG  
**Mode:** Normal  
**Priors:** Medium shell swap `d58203c2`; L1 Large economy `49f0153a`; Art Large shell `91e2020a`  
**Softs parked:** Soft seed / Soft far crest / Soft `apply_medium_capacity` naming

---

## Verdict: **PASS-with-notes**

**Clear for merge? YES**

Formal FLOOR/shell smoke on tip `ec34ba6f` clears the Large Art hero stub-swap bar after Eng+Art dual-clear. Foundation suite green (`All foundation tests passed.`, EXIT:0). Soft notes are non-blocking and remain parked by policy. **No S0–S2 blockers.**

| Gate | Result |
|------|--------|
| 1. Sign → `prop_shop_shell_large_01` as `Architecture/ShopShellLarge` at SW origin, scale (1,1,1) | **PASS** |
| 2. Small + Medium Art shells HIDDEN when Large active | **PASS** |
| 3. Large procedural scaffold GONE (`has_large_scaffold` false; no LargeFloor/walls) | **PASS** |
| 4. Wait / Stay Medium keep Medium Art shell; Large hidden | **PASS** |
| 5. New game / Small = `prop_shop_shell_01` only | **PASS** |
| 6. Walkable SoT unchanged: Large **18×13 @ 0.9 m** (16.2×11.7 / ~2040) | **PASS** |
| 7. No fog veil | **PASS** |
| 8. Economy untouched (rent $4k / staff 5 / 1.25×) — Sign gate still works | **PASS** |
| 9. §4.5 clean (UI N/A / lease confirm clean) | **PASS** |
| 10. Softs parked | **PASS** (noted) |

**Harness:** 135 PASS / 0 FAIL / 3 soft  
**Foundation:** `All foundation tests passed.` EXIT:0  
**Import:** Godot `--editor --quit-after 180` EXIT:0

---

## Soft policy (keep parked)

| Soft item | Disposition |
|-----------|-------------|
| Soft seed `_ensure_priceable_sku` | **Keep parked.** Still defined; HYPE/FOG bridge only. Large shell surfaces (`shop_floor_extent`, `shop_state`, `beat_injection`) do **not** call it. |
| Soft far crest (Art Large thin roof/wall crest at far FOV) | **Parked OOS** from Art #40 — non-blocking for Eng stub-swap. |
| Soft `apply_medium_capacity` naming on Large stacked bonuses | **Soft parked (S4).** Large Sign still calls Medium-named capacity helper; functional capacity correct; rename is hygiene-only. |

---

## Checklist (pass bar detail)

### 1 — Sign → Large Art shell
- [x] Sign lease → tier **LARGE**
- [x] `Architecture/ShopShellLarge` present and **visible**
- [x] Instance family `prop_shop_shell_large_01` / name `ShopShellLarge`
- [x] SW pivot at origin (`position == Vector3.ZERO`)
- [x] Scale `(1,1,1)` (1u=1m)
- [x] Extra tiles vs Small **154**; vs Medium **94**
- [x] `is_large_shell_visible() == true`

### 2 — Small + Medium hidden
- [x] `Architecture/ShopShell` visible **false**
- [x] `Architecture/ShopShellMedium` visible **false**
- [x] `is_medium_extension_visible() == false`

### 3 — Scaffold gone
- [x] `has_large_scaffold() == false`
- [x] `is_large_scaffold_visible() == false`
- [x] No `LargeFloor` / `LargeWallEast` / `LargeWallNorth`
- [x] FloorExtent child count **0** after sync (no gray-box hero)
- [x] MediumFloor stub also nacked (`has_code_driven_stub == false`)

### 4 — Wait / Stay Medium
- [x] Stay Medium → tier Medium, grid 14×10
- [x] Stay: Medium Art shell visible; Large hidden; scaffold absent
- [x] Wait: Medium Art shell visible; Large hidden

### 5 — New game / Small
- [x] New game Small tier, grid 10×8
- [x] Small Art shell visible (`prop_shop_shell_01` / ShopShell)
- [x] Medium + Large shells instanced but **hidden**
- [x] Extra tiles 0; fog nack; no scaffold

### 6 — Walkable SoT 18×13 @ 0.9 m
- [x] `ShopGrid.TILE_SIZE == 0.9`
- [x] Domain / layout / consts **18×13**; tiles **234**
- [x] Interior claim **16.2 × 11.7 m**
- [x] `usable_sq_ft ≈ 2040.1875`
- [x] Circulation + paths entrance→browse→desk and entrance→`(16,11)`
- [x] Package `_build_stats`: `footprint_tiles=18x13`, `floor_w/d=16.2/11.7`, `fog=none`

### 7 — No fog veil
- [x] `has_fog_veil() == false`; no `MediumVeilX` / `MediumVeilZ`
- [x] Env fog / volumetric fog nacked
- [x] IMPORT_NOTES + build_stats fog nack

### 8 — Economy Sign gate (from #39, untouched)
- [x] Rent Large **$4,000** / staff cap **5** / traffic **1.25×**
- [x] Cash/Rep gate: Sign disabled below; choose nacks
- [x] Exact gate: Sign enabled → Large tier + rent/staff/traffic hold

### 9 — §4.5
- [x] Lease confirm body clean (no `true_market` / `p_buy` / `cert_valid`)
- [x] Decision payload clean; shell-swap UI N/A

### 10 — Softs parked
- [x] Soft seed / Soft far crest / Soft `apply_medium_capacity` naming — **keep parked**

---

## Soft nits (non-blocking)

1. **Soft seed keep parked** — `_ensure_priceable_sku` remains for HYPE/FOG only.
2. **Soft far crest** — Art Large thin crest at far FOV; OOS for this Eng swap formal.
3. **`apply_medium_capacity` naming** — Large Sign reuses Medium-named helper for stacked totals; rename parked S4.

---

## Evidence

| Artifact | Path |
|----------|------|
| Import log | `/workspace/card-shop-qa/evidence/large-shell-ec34ba6f/import.log` |
| Foundation log | `/workspace/card-shop-qa/evidence/large-shell-ec34ba6f/foundation.log` |
| Smoke log | `/workspace/card-shop-qa/evidence/large-shell-ec34ba6f/smoke.log` |
| Smoke JSON | `/workspace/card-shop-qa/evidence/large-shell-ec34ba6f/smoke.json` |
| Summary JSON | `/workspace/card-shop-qa/evidence/large-shell-ec34ba6f/summary.json` |
| Tip SHA | `/workspace/card-shop-qa/evidence/large-shell-ec34ba6f/tip_sha.txt` |
| Viewport PNG | `/workspace/card-shop-qa/evidence/large-shell-ec34ba6f/large-shell-swap-aisle.png` |
| QA harness | `/workspace/qa-playtest/large-shell-ec34ba6f/tests/qa_large_shell_swap_smoke.gd` (+ evidence copy) |

---

## Commands

```bash
godot --headless --editor --quit-after 180 --path /workspace/qa-playtest/large-shell-ec34ba6f
godot --headless --path /workspace/qa-playtest/large-shell-ec34ba6f --script res://tests/test_runner.gd
xvfb-run -a godot --path /workspace/qa-playtest/large-shell-ec34ba6f -s res://tests/qa_large_shell_swap_smoke.gd
```

---

## Overall

**PASS-with-notes** — Clear for merge **YES**. Soft policy: **keep parked**. No S0–S2 blockers.

## Merge

Merged to main as **PR #41** @ `2afba0c2024491df90b43d8b2c0d872c42781784` (2026-09-06). M1 Counterfeit Eng spike next; M2 Large re-smoke clear concurrent.
