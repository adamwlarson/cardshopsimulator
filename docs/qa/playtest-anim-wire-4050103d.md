# Playtest report — anim-wire FLOOR smoke @ `4050103d` (PR #22)

**Scorer:** CSS QA (executor)  
**Date:** 2026-09-04 (~4:46 PM ET)  
**Build:** `adamwlarson/cardshopsimulator` tip **`4050103d37ac0d489caf00839838cb30a9d2a054`** (tree `/workspace/qa-playtest/tip22/` from GitHub tarball)  
**Mode:** **Normal** (`data/balance/normal.tres`)  
**Godot:** 4.5.2.stable.official.6ce3de25a (`/workspace/godot452`) + xvfb / OpenGL llvmpipe  
**Scope:** FLOOR smoke — Wire C1–C3 `walk` / `browse_idle` AnimationPlayer clips (in-place + Presenter translation); intent icons; soft skinning parked; soft camera/Esc desk HUD  
**Method:** Headless foundation `tests/test_runner.gd` + SceneTree harness `tests/qa_anim_wire_smoke.gd` + frozen mid-seek capture `tests/qa_anim_wire_capture.gd`  
**Tip note:** Docs-only past Eng tip `cfe36065` — compare `cfe36065...4050103d` = `docs/design/next-eng-sot-pick-v1.md` only.

## Executive verdict

| Gate (pass bar) | Result |
|-----------------|--------|
| 1. Spawn customers — ≥1 NPC visible when queue non-empty | **PASS** |
| 2. Walk cycles play (in-place walk + Presenter translation) | **PASS** |
| 3. Browse idle at case readable | **PASS** |
| 4. Intent icons still readable (amber sell / teal buy / neutral browse) | **PASS** (data + behind-desk bobber; aisle soft note) |
| 5. Soft skinning parked — non-blocking | **PASS** (noted; do not fail tip) |
| Soft: camera SoT / Esc desk HUD; no truth leaks | **PASS** |

| Supporting | Result |
|------------|--------|
| Tip SHA confirmed | **`4050103d37ac0d489caf00839838cb30a9d2a054`** (tarball root `cardshopsimulator-4050103d37ac0d489caf00839838cb30a9d2a054/`) |
| Docs-only past `cfe36065` | **Confirmed** — only `docs/design/next-eng-sot-pick-v1.md` |
| Foundation `test_runner` | **PASS** — `All foundation tests passed.` (includes `_test_customer_npc_locomotion_clips`) |
| Formal harness | **PASS** — **84 PASS / 0 FAIL**; `SOFT_COUNT=4` |
| S0–S3 | **None** |

**Overall: PASS-with-notes**

Anim-wire FLOOR clears the pass bar on Normal at tip `4050103d`. Soft skinning (rigid hinges) and browse-gesture hierarchy (C3 > C1/C2) remain parked non-blocking per PR / Art spot-check.

## Pass-bar checklist

| # | Check | Observed | Verdict |
|---|-------|----------|---------|
| 1 | Non-empty queue ⇒ ≥1 visible NPC | `customer_arrived` → `visible_npc_count()≥1`; C1–C3 heroes on floor in captures | **PASS** |
| 2a | `walk` while pathing | C1–C3 `has_locomotion_clips`; `current_locomotion_clip()==walk` while `is_moving`; AnimationPlayer playing `walk` | **PASS** |
| 2b | In-place clips; Presenter owns translation | `body_root_local_position≈(0,0,0)` while world pos moves >0.05; no AnimationTree | **PASS** |
| 2c | Mid-walk readable in viewport | Frozen seek t=0.55: C1 mid-aisle stride (leg plant / opposing limbs) in `aisle_walk_browse.png` | **PASS** |
| 3a | `browse_idle` at case when not translating | Advance to BROWSE stop → clip `browse_idle`; AnimationPlayer playing; mid-seek t=1.10 | **PASS** |
| 3b | Browse idle readable at case | C3 lean/reach at display case in aisle capture; RESOLVE also holds `browse_idle` | **PASS** |
| 4a | Intent browse→buy / browse→sell; intent-only payload | Spawn browse; buyer→buy; seller→sell; payload size=1; `has_truth_fields()=false` | **PASS** |
| 4b | Colors amber sell / teal buy / neutral browse | `COLOR_SELL≈(0.92,0.62,0.22)`; `COLOR_BUY≈(0.22,0.72,0.68)`; browse gray | **PASS** |
| 4c | Viewport icons readable; no truth leak | Behind-desk: teal **buy** bobber over C3; aisle bobber weaker (soft); truth scan clean | **PASS** (soft aisle) |
| 5 | Soft skinning parked | Rigid hinged limbs visible; no mesh explode; non-blocking by bar | **PASS / soft** |
| Soft | Esc desk HUD | Closed off volume; open at desk_ready; KEY_ESCAPE hides without despawn | **PASS** |
| Soft | Camera SoT | Behind `(7.2,1.6,-0.65)/(-18,0,0)/70`; aisle `(4.5,1.65,-1.8)/(-28,0,0)/70`; NPC does not mutate cam/FOV | **PASS** |

## Key measured evidence

| Surface | Key numbers |
|---------|-------------|
| Locomotion | C1/C2/C3 expose `walk`+`browse_idle`; walk↔idle on move/stop; in-place root; RESOLVE holds idle |
| Capture seeks | Walk t=0.55 / browse_idle t=1.10 (Art spot-check aligned) |
| Icons | browse/buy/sell intent-only; sell Accent_Amber; buy teal; GLBs instanced |
| HUD | Closed off volume; open at desk_ready; Esc does not despawn |
| Camera | Behind + aisle FOV **70** intact; no NPC `fov` churn |
| Viewport | Aisle: C1 mid-stride + C3 case lean; behind-desk: teal buy bobber |
| Truth scan | `truth_leaks: []` |
| Harness | 84 PASS / 0 FAIL / 4 soft |
| Foundation | All foundation tests passed |

## Soft Eng/Art nits (non-blocking)

1. **Rigid blockout skinning** (hinged limbs) — parked per PR #22 / Art spot-check; MVP-acceptable. (**S4**)  
2. **Browse gesture strongest on C3**; C1/C2 subtler at shared mid-seek — parked soft. (**S4**)  
3. **`ICON_READ_SCALE=2.0`** on bobber holder — intentional aisle-cam readability. (**S4**)  
4. **Capsule fallback remains** if GLB import fails — OK for MVP; import verified this tip (`.scn` for A/B/C). (**S4**)  
5. **Aisle-cam bobber read weaker than behind-desk** — bodies/poses clear mid-aisle; teal buy bobber confirmed from behind-desk FOV. C2 parked near left frustum edge in frozen capture. (**S4**, visual)

## Findings (severity-ranked)

### S0–S3
**None.**

### S4
Soft nits above only.

## Evidence paths

| Artifact | Path |
|----------|------|
| Report | `/workspace/card-shop-qa/playtest-anim-wire-4050103d.md` |
| Harness | `/workspace/card-shop-qa/qa_anim_wire_smoke.gd` (+ tip `tests/qa_anim_wire_smoke.gd`) |
| Capture | tip `tests/qa_anim_wire_capture.gd` |
| Aisle mid-walk + browse | `/workspace/card-shop-qa/evidence/anim-wire-4050103d/aisle_walk_browse.png` |
| Aisle mid-walk alias | `/workspace/card-shop-qa/evidence/anim-wire-4050103d/aisle_mid_walk.png` |
| Behind-desk + icons | `/workspace/card-shop-qa/evidence/anim-wire-4050103d/behind_desk_with_npcs.png` |
| Harness stdout | `/workspace/card-shop-qa/evidence/anim-wire-4050103d/harness.log` |
| Foundation log | `/workspace/card-shop-qa/evidence/anim-wire-4050103d/foundation.log` |
| Capture log / notes | `/workspace/card-shop-qa/evidence/anim-wire-4050103d/capture.log`, `capture_notes.json` |
| Machine summary | `/workspace/card-shop-qa/evidence/anim-wire-4050103d/summary.json` |
| Run checklist | `/workspace/card-shop-qa/evidence/anim-wire-4050103d/run.txt` |
| Import log | `/workspace/card-shop-qa/evidence/anim-wire-4050103d/import.log` |

## How reproduced

```bash
curl -sL https://github.com/adamwlarson/cardshopsimulator/archive/4050103d.tar.gz \
  -o /workspace/qa-playtest/tip22.tar.gz
mkdir -p /workspace/qa-playtest/tip22
tar -xzf /workspace/qa-playtest/tip22.tar.gz -C /workspace/qa-playtest/tip22 --strip-components=1

/workspace/godot452 --headless --editor --quit-after 180 --path /workspace/qa-playtest/tip22
/workspace/qa-playtest/run_tip22_foundation.sh
xvfb-run -a -s "-screen 0 1280x720x24" /workspace/godot452 \
  --path /workspace/qa-playtest/tip22 --script res://tests/qa_anim_wire_smoke.gd
/workspace/qa-playtest/run_tip22_anim_capture.sh
```
