# Playtest report — L1 Large expand / lease pressure @ `49f0153a` (PR #39)

**Scorer:** CSS QA (executor)  
**Date:** 2026-09-06 (~3:27 PM ET)  
**Tip SHA:** `49f0153af5d19ee5ba1d1e5b39f3ff965142422c` (short `49f0153a`)  
**PR:** [#39](https://github.com/adamwlarson/cardshopsimulator/pull/39) — *feat(shop): L1 Large expand / lease pressure*  
**Parents / tip note:** head merge commit *"merge main into L1 branch (docs-only)"* on Eng tip-frozen APPROVE-with-notes pack  
**Repo extract:** `/workspace/qa-playtest/l1-49f0153a/` (fresh GitHub tarball @ tip; other trees untouched)  
**Method:** Godot 4.5.2 headless — foundation `tests/test_runner.gd` + formal `tests/qa_l1_large_expand_smoke.gd` under xvfb; aisle viewport PNG  
**Mode:** Normal  
**Design SoT:** `docs/design/next-eng-sot-pick-l-v1.md` § L1; systems-design §7.3; PM bar match

---

## Verdict: **PASS-with-notes**

**Clear for merge? YES**

Formal economy smoke on Normal at tip `49f0153a` clears the L1 pass bar. Foundation suite green (`All foundation tests passed.`, EXIT:0). Soft notes are non-blocking S4 (naming hygiene + Soft seed keep-parked policy + Art #40 stub-swap after merge). **No S0–S2 blockers.**

| Gate | Result |
|------|--------|
| 1. Unlock: Cash ≥ $40k **AND** Rep ≥ 70 — cannot Sign below | **PASS** |
| 2. Sign → weekly rent **$4,000** + staff cap **5** + grid **18×13** | **PASS** |
| 3. Traffic **1.25×** sublinear (BalanceConfig tunable) | **PASS** |
| 4. Refuse / wait / stay Medium keeps Medium | **PASS** |
| 5. Scaffold interim (no fog veil as hero) | **PASS** |
| 6. §4.5 clean (no `true_market` / `p_buy` / `cert_valid` UI leaks) | **PASS** |
| 7. Soft `_ensure_priceable_sku` parked (not called from L1 surfaces) | **PASS** |

**Harness:** 122 PASS / 0 FAIL / 3 soft  
**Foundation:** `All foundation tests passed.` (includes `_test_expand_large_beat` + `_test_large_floor_growth`)  
**Import:** Godot `--editor --quit-after 180` EXIT:0

---

## Soft policy (keep parked)

| Soft item | Disposition |
|-----------|-------------|
| Soft seed `_ensure_priceable_sku` | **Keep parked.** Still defined; HYPE/FOG bridge only. L1 surfaces (`shop_state`, `beat_injection`, `balance_config`, `customer_spawner`, `hud`, `shop_floor_extent`) do **not** call it. |
| Soft seed live for HYPE/FOG bridge only (not L1) | Confirmed — non-blocking Eng Soft note honored. |
| `apply_medium_capacity` naming on Large stacked bonuses | **Soft parked (S4).** Large Sign calls `InventoryService.apply_medium_capacity(case_slot_bonus(), backstock_bonus())` which correctly applies Medium+Large stacked totals; rename is hygiene-only. |
| Art Large shell | Art #40 **PASS** @ `91e2020a` already — economy formal accepts scaffold interim; wire stub-swap after #39 merge. Non-blocking. |

---

## Eng Soft notes disposition

1. **`apply_medium_capacity` naming on Large stacked bonuses** — Soft parked (S4). Non-blocking. Functional capacity correct (Medium + Large bonuses stacked).
2. **Soft seed still live for HYPE/FOG bridge only (not L1)** — Soft parked. Policy: **keep parked.** Not a merge blocker.

---

## Checklist (pass bar detail)

### 1 — Unlock gate ($40k + Rep 70)
- [x] BalanceConfig: `expand_large_cash_cents = 4_000_000`, `expand_large_rep = 70`
- [x] Day 40 PREP on Medium auto-starts `sec10_11_expand_large` even when gates fail
- [x] Sign disabled + `choose_beat_path("sign_lease")` nacks below gate
- [x] One cent below $40k cannot Sign; Rep 69 cannot Sign
- [x] Exact $40k + Rep 70: `can_sign_large_lease` true; Sign enabled; Wait hidden
- [x] Options: **Sign lease** / **Wait for cash and Rep** / **Stay Medium**

### 2 — Sign rent / staff / grid
- [x] Sign → tier **Large**, grid / layout **18×13**, tile count **234**
- [x] `staff_cap()` **5** (`BalanceConfig.staff_cap_large`)
- [x] Signed-day rent stays Medium (**$2,400**); next week / SETTLE posts Large (**$4,000** / 400_000¢)
- [x] Case capacity = base + Medium bonus + Large bonus
- [x] `usable_sq_ft ≈ 2040.1875` (~2,040 sq ft)
- [x] Walkable / NPC grid grow; circulation holds; paths entrance→browse→desk and entrance→`(16,11)`
- [x] Save/load restores Large tier, 18×13, staff_cap 5, rent tier, traffic, circulation

### 3 — Traffic 1.25× sublinear
- [x] `expand_large_traffic_mult` default **1.25** (tunable); Medium mult **1.0**
- [x] Signed Large `traffic_mult() == 1.25`; not 2× Medium
- [x] Traffic scalar **<** rent step ($4,000/$2,400 ≈ 1.67×)
- [x] Spawn wait `12s → 9.6s` via `customer_spawn_wait_seconds`
- [x] Lease confirm documents traffic scalar (`1.25` / `×1.25`)

### 4 — Refuse / wait / stay Medium
- [x] Stay Medium: tier/grid/walkable/staff/rent/traffic unchanged
- [x] Wait: keeps Medium rent ($2,400), staff_cap 3, traffic ~1.0
- [x] Pathing refuse: demote counter → `preview_expand_large() == blocked_path`; `expand_to_large` refuses; stays Medium 14×10

### 5 — Scaffold interim (no fog hero)
- [x] `ShopFloorExtent`: Large scaffold visible (`LargeFloor` + walls); Medium Art shell stays as interior
- [x] Extra tiles vs Small **154**; vs Medium **94**
- [x] `has_fog_veil() == false`; no `MediumVeilX` / `MediumVeilZ`
- [x] Env fog / volumetric fog nacked
- [x] Scaffold floor mesh ≈ **16.2 × 11.7 m** (18×0.9 × 13×0.9)
- [x] Aisle viewport PNG captured — Art #40 GLB **not** required for this economy formal
- [x] Note: Art PASS #40 @ `91e2020a` ready for stub-swap after merge

### 6 — §4.5 clean
- [x] Beat decision payload + lease confirm body: no `true_market` / `p_buy` / `cert_valid`
- [x] Save payload §4.5 clean
- [x] `beat_injection.gd` has no truth literals

### 7 — Soft `_ensure_priceable_sku` parked
- [x] Helper still defined in `demand_signals.gd` (parked)
- [x] L1 surfaces do not call it
- [x] Soft seed HYPE/FOG bridge context still present — **keep parked** policy

---

## Soft nits (non-blocking)

1. **`apply_medium_capacity` naming** — Large Sign reuses Medium-named capacity helper for stacked Medium+Large totals. Functional OK; rename parked S4.
2. **Soft seed keep parked** — `_ensure_priceable_sku` remains for HYPE/FOG only; L1 does not touch it.
3. **Art scaffold interim** — Economy formal OK without Art #40 GLB; Art already PASS @ `91e2020a` for post-merge wire.

---

## Evidence

| Artifact | Path |
|----------|------|
| Import log | `/workspace/card-shop-qa/evidence/l1-49f0153a/import.log` |
| Foundation log | `/workspace/card-shop-qa/evidence/l1-49f0153a/foundation.log` |
| Smoke log | `/workspace/card-shop-qa/evidence/l1-49f0153a/smoke.log` |
| Smoke JSON | `/workspace/card-shop-qa/evidence/l1-49f0153a/smoke.json` |
| Summary JSON | `/workspace/card-shop-qa/evidence/l1-49f0153a/summary.json` |
| Tip SHA | `/workspace/card-shop-qa/evidence/l1-49f0153a/tip_sha.txt` |
| Viewport PNG | `/workspace/card-shop-qa/evidence/l1-49f0153a/large-scaffold-aisle.png` |
| QA harness | `/workspace/qa-playtest/l1-49f0153a/tests/qa_l1_large_expand_smoke.gd` (+ evidence copy) |

---

## Commands

```bash
godot --headless --editor --quit-after 180 --path /workspace/qa-playtest/l1-49f0153a
godot --headless --path /workspace/qa-playtest/l1-49f0153a --script res://tests/test_runner.gd
xvfb-run -a godot --path /workspace/qa-playtest/l1-49f0153a -s res://tests/qa_l1_large_expand_smoke.gd
```

---

## Overall

**PASS-with-notes** — Clear for merge **YES**. Soft policy: **keep parked**. No S0–S2 blockers.

## Merge

Merged to main as **PR #39** @ `f43958ae47c6743f9a859afe646ad77b2b669a12` (2026-09-06). Clear for Eng Large shell stub-swap (Art #40 already on main).
