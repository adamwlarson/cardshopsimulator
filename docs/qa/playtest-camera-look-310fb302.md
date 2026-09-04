# Playtest: ShopCamera RMB look + behind-desk Day1 home

| Field | Value |
|-------|-------|
| **Tip SHA** | `310fb302` (`310fb302e75d01f5be0d73e4dda4333f9512426e`) |
| **Repo** | https://github.com/adamwlarson/cardshopsimulator |
| **PR** | #15 ShopCamera RMB look + behind-desk Day1 home |
| **Date** | 2026-09-04 (America/New_York) |
| **Engine** | Godot 4.5.2.stable (xvfb + OpenGL llvmpipe) |
| **Harness** | `tests/qa_camera_look_smoke.gd` (SceneTree; shop_floor + ShopCamera API) |
| **Verdict** | **PASS** (37/37 checks, 0 fails) |

## Pass bar checklist

| # | Bar | Result | Runtime evidence |
|---|-----|--------|------------------|
| 1 | Day1 spawn = behind buy desk home: pos `Vector3(7.2, 1.60, -0.65)`, pitch ≈ −18, FOV 70 | **PASS** | `pos=(7.2, 1.6, -0.65) rot_deg=(-18.0, 0.0, 0.0) fov=70.0 pose=behind_counter` |
| 2 | Hold RMB: look; pitch clamps −40…+5, yaw −70…+70; FOV stays 70 | **PASS** | Extreme `apply_look_delta`: pitch_lo=-40.00, pitch_hi=5.00, yaw_neg=-70.00, yaw_pos=70.00, fov=70.0 throughout |
| 3 | MMB / R / Home → aisle reset: pos `(4.5, 1.65, -1.8)`, rot `(-28, 0, 0)`, FOV 70 (Art SoT) | **PASS** | `reset_to_aisle_home()` → `pos=(4.5, 1.65, -1.8) rot_deg=(-28.0, 0.0, 0.0) fov=70.0 pose=aisle` |
| 4 | No crash on PREP→FLOOR or HUD open | **PASS** | `gameplay_hud` present on shop_floor; soft `GameState.start_new_game` → phase 0 PREP, `start_floor` → phase 1 FLOOR; camera/shop remained valid, FOV 70 |

## Observed runtime values (exact)

### Home / Day1 (after Camera `_ready` → `apply_home_pose(behind_counter)`)
- **position:** `(7.2, 1.6, -0.65)`
- **rotation_degrees:** `(-18.0, 0.0, 0.0)`
- **fov:** `70.0`
- **pose:** `behind_counter`

### Look clamps (programmatic extremes via `apply_look_delta`)
- **pitch floor:** `-40.00` (absolute clamp)
- **pitch ceiling:** `5.00`
- **yaw floor:** `-70.00`
- **yaw ceiling:** `70.00`
- **fov after all look ops:** `70.0` (locked)

### Aisle reset (`reset_to_aisle_home` — same path as MMB / R / Home)
- **position:** `(4.5, 1.65, -1.8)`
- **rotation_degrees:** `(-28.0, 0.0, 0.0)`
- **fov:** `70.0`
- **pose:** `aisle`

## Notes / soft findings

- Source SoT matches Art Lead: `shop_camera.gd` constants + `shop_floor.tscn` Camera node both set behind-desk Day1 home; `default_home_pose = behind_counter`.
- RMB look was exercised through `ShopCamera.apply_look_delta` (API equivalent of captured mouse motion while looking). Source `_input` wires `MOUSE_BUTTON_RIGHT` → `_set_looking`, `MOUSE_BUTTON_MIDDLE` / `KEY_R` / `KEY_HOME` → `reset_to_aisle_home` (skips when GUI text focus owns input).
- Pitch/yaw clamps are **absolute** world degrees (`clampf(home + offset, min, max)`), not offsets-only — verified at both extrema from behind_counter home.
- Soft PREP→FLOOR: autoloads available under `--path` + `--script`; HUD already embedded as `HUDLayer/HUD`. Phase transition PREP(0)→FLOOR(1) completed without crash.
- Soft: harness did not inject raw `InputEventMouseButton` RMB press/release (xvfb); input map presence confirmed by source + reset API call. Full interactive RMB capture is a follow-up for human playtest if desired.
- Rendering fell back Vulkan→OpenGL under xvfb (expected in this CI box); audio dummy driver — neither affected camera asserts.

## Evidence paths

| Artifact | Path |
|----------|------|
| Home / behind-desk viewport | `/workspace/card-shop-qa/evidence/smoke_310fb302_home_behind_desk.png` |
| After aisle reset viewport | `/workspace/card-shop-qa/evidence/smoke_310fb302_aisle_reset.png` |
| Harness stdout | `/workspace/card-shop-qa/evidence/smoke_310fb302_run.txt` |
| Machine summary | `/workspace/card-shop-qa/evidence/smoke_310fb302_summary.txt` |
| This report | `/workspace/card-shop-qa/playtest-camera-look-310fb302.md` |

## How reproduced

```bash
ROOT=/workspace/qa-playtest/cardshopsimulator-310fb302e75d01f5be0d73e4dda4333f9512426e
# tip fetched via: curl tarball adamwlarson/cardshopsimulator @ 310fb302
godot --headless --path "$ROOT" --import
xvfb-run -a godot --path "$ROOT" --script res://tests/qa_camera_look_smoke.gd
```
