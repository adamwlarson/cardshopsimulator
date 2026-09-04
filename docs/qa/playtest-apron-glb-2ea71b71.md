# Playtest report — apron FOV GLB hire-gate FLOOR smoke @ `2ea71b71` (PR #30)

**Scorer:** CSS QA (executor)  
**Date:** 2026-09-04 (~6:44 PM ET)  
**Build:** `adamwlarson/cardshopsimulator` tip **`2ea71b71c7b88b14fe10f970ccaea397ef93a092`** (tree `/workspace/qa-playtest/apron-2ea71b71/` shallow checkout of PR #30 head)  
**Mode:** **Normal** (`data/balance/normal.tres`)  
**Godot:** 4.5.2.stable.official.6ce3de25a (`/home/box/.local/bin/godot`) + xvfb / OpenGL llvmpipe (optional stills)  
**Scope:** Formal FLOOR hire-gate smoke — Art polished `char_cashier_01` warm canvas apron + blank name-tag GLB live on hire-gated `StaffPresenter`; pose / idle / AABB unchanged; soft teal polo parked  
**Method:** Headless import + foundation `tests/test_runner.gd` + SceneTree harness `tests/qa_apron_hire_smoke.gd` + optional xvfb stills `tests/qa_apron_still.gd`  
**Design SoT:** PR #30 body; prior Art spot-check `docs/qa/art-cashier-apron-fov-spotcheck.md` (PASS); Soft MidCenter / soft teal polo parked (non-blocking)

## Executive verdict

| Gate (pass bar) | Result |
|-----------------|--------|
| 1. Apron FOV GLB live (warm canvas apron + blank name-tag; SHA prefix `872205822f0536ca`) | **PASS** |
| 2. Hire-gated: owner-only `visible_clerk_count=0`; after `hire_cashier` `visible=1` | **PASS** |
| 3. CashierSlot pose: `(8.05, 0, -0.95)` yaw **+90** | **PASS** |
| 4. `idle_stand` looping; height **1.72 m** (AABB ~0.802×1.72×0.317) | **PASS** |
| 5. Soft teal polo parked — do not FAIL / do not recolor | **PASS** (soft noted) |

| Supporting | Result |
|------------|--------|
| Tip SHA confirmed | **`2ea71b71c7b88b14fe10f970ccaea397ef93a092`** |
| Foundation `test_runner` | **PASS** — `All foundation tests passed.` (includes `_test_cashier_silhouette_on_floor`) |
| Formal apron hire harness | **PASS** — **58 PASS / 0 FAIL**; `SOFT_COUNT=5` |
| Optional xvfb stills | **PASS** — customer-side after-hire shows warm canvas apron + blank name-tag |
| S0–S3 | **None** |

**Overall: PASS-with-notes**

Apron FOV GLB swap clears the formal hire-gate FLOOR pass bar on Normal at tip `2ea71b71`. Soft teal polo + Soft MidCenter remain parked non-blocking. Clear for merge.

## Pass-bar checklist

| # | Check | Observed | Verdict |
|---|-------|----------|---------|
| 1a | GLB stem + FOV polish on disk | `res://assets/chars/staff/char_cashier_01/char_cashier_01.glb` size **198468**; `fov_polish=apron_nametag_2026-09-04` in `_build_stats` | **PASS** |
| 1b | SHA-256 prefix | **`872205822f0536ca`** matches Art spot-check / PR claim | **PASS** |
| 1c | Warm canvas apron + blank name-tag | IMPORT_NOTES warm canvas apron + blank name-tag; materials include `Apron`; still shows canvas bib + blank plate | **PASS** |
| 2a | Owner-only empty | Normal `is_owner_only`; `cashier_count=0`; `visible_clerk_count()=0` | **PASS** |
| 2b | After hire visible=1 | `hire_cashier(false)` → `cashier_count=1`; `visible_clerk_count()=1`; clerk node visible | **PASS** |
| 3a | CashierSlot / defaults | Slot + `DEFAULT_STATION=(8.05, 0, -0.95)`; `DEFAULT_YAW=90` | **PASS** |
| 3b | Spawned clerk pose | Clerk `(8.05, 0, -0.95)` yaw **90**; forward `(−1, 0, 0)` (−X / customers) | **PASS** |
| 4a | `idle_stand` looping | `current_idle_clip()==idle_stand`; AnimationPlayer playing; `LOOP_LINEAR`; length ≈ **2.033 s**; body root in-place; hero GLB (not capsule) | **PASS** |
| 4b | Height / AABB | `BODY_HEIGHT=1.72`; stats **0.8023 × 0.3171 × 1.7200**; imported AABB **(0.802, 1.72, 0.317)**; pivot `min_z=0` | **PASS** |
| 5 | Soft teal polo parked | IMPORT_NOTES still documents muted teal polo; not recolored; soft-only | **PASS / soft** |

## Key measured evidence

| Surface | Key numbers |
|---------|-------------|
| Tip | `2ea71b71c7b88b14fe10f970ccaea397ef93a092` |
| GLB | SHA-256 prefix `872205822f0536ca`; **198468** B; verts **1364** / tris **2580** |
| Hire gate | owner-only visible **0** → after hire visible **1** |
| Slot / clerk | `(8.05, 0, -0.95)` yaw **90**; forward `(−1, 0, 0)` |
| Idle | `idle_stand` LOOP_LINEAR; length ≈2.033 s; `has_idle_loop()=true`; `used_hero_glb=true` |
| AABB (stats / imported) | **0.8023 × 0.3171 × 1.7200** / **(0.802, 1.72, 0.317)** |
| Harness | 58 PASS / 0 FAIL / 5 soft |
| Foundation | All foundation tests passed |

## Soft Eng/Art nits (non-blocking)

1. **Soft teal polo parked** — muted teal polo retained; apron FOV polish carries cast distinctness. Do not FAIL / do not recolor. (**S4**)
2. **Soft MidCenter lights parked (OOS)** — do not FAIL. (**S4**)
3. **Rigid part→bone skinning** — same blockout hinges as C1–C3; MVP OK. (**S4**)
4. **StaffPresenter / CashierSlot / hire path unchanged** — GLB swap only (as designed). (**S4**)
5. **Headless harness skips DisplayServer still** — optional xvfb capture used instead (`after_hire_customer_side.png`). (**S4**)
6. **HUD re-instantiate duplicate Signal connect ERRORs** — known foundation noise; `All foundation tests passed.` (**S4**)

## Findings (severity-ranked)

### S0–S3
**None.**

### S4
Soft nits above only.

## Evidence tree

```
/workspace/card-shop-qa/playtest-apron-glb-2ea71b71.md
/workspace/card-shop-qa/docs/qa/playtest-apron-glb-2ea71b71.md
/workspace/qa-playtest/apron-2ea71b71/docs/qa/playtest-apron-glb-2ea71b71.md
/workspace/card-shop-qa/evidence/apron-2ea71b71/
  foundation.log
  import.log
  harness.log
  harness_stdout.log
  summary.json
  still.log
  after_hire_customer_side.png   ← primary apron FOV still (hired)
  after_hire_behind_desk.png
/workspace/card-shop-qa/qa_apron_hire_smoke.gd
/workspace/qa-playtest/apron-2ea71b71/tests/qa_apron_hire_smoke.gd
```

## Harness / repro

```bash
# Tip tree @ 2ea71b71 → /workspace/qa-playtest/apron-2ea71b71
/home/box/.local/bin/godot --headless --editor --quit-after 180 --path /workspace/qa-playtest/apron-2ea71b71
bash /workspace/qa-playtest/run_apron_foundation.sh
bash /workspace/qa-playtest/run_apron_hire_smoke.sh
xvfb-run -a /home/box/.local/bin/godot --path /workspace/qa-playtest/apron-2ea71b71 --script res://tests/qa_apron_still.gd
```

## Clear for merge?

**Yes** — formal hire-gate FLOOR apron FOV GLB smoke **PASS-with-notes** at tip `2ea71b71`. Soft teal polo + Soft MidCenter remain parked non-blocking.
