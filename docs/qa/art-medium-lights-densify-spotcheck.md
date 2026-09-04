# Art Medium densify overhead lights — spot-check

**Scorer:** CSS QA  
**Date:** 2026-09-04 (ET)  
**Main tip checked:** `65a738018f` (docs next-eng SoT; includes merges **#24** `@39d6f5cb`, **#25** `@f656019b`)  
**Art package source:** local Art working copy `/workspace/card-shop-simulator/` (`docs/art/` + `art/` mirrors) — densify SoT + QA shots **not yet on main** (Art holds assets branch until PASS)  
**SoT:** `docs/art/MEDIUM_OVERHEAD_LIGHTS_MVP.md`  
**Package:** reuse `prop_light_overhead_01` (no new overhead GLB) + Medium shell `prop_shop_shell_medium_01`  
**Evidence:** `/workspace/card-shop-qa/evidence/medium-lights-densify/shots/`  
**Related:** Medium shell PASS-with-notes (PR #25 / local shell spot-check); Soft MidCenter X share **parked** unless blocker

### Shots reviewed
| Shot | Path |
|------|------|
| Interact (mid-floor → far/deep ceiling) | `LIGHTS_medium_densify_interact.png` |
| Approach (entrance-ish → deep ceiling) | `LIGHTS_medium_densify_approach.png` |

Also present under `docs/art/qa-shots/` + `art/qa-shots/` mirrors. Prop folder: `art/props/prop_light_overhead_01/` (+ `render_medium_densify_qa.py`, IMPORT_NOTES Medium densify pointer).

### Pass bar (this gate)
1. **11 overhead instances** when tier=MEDIUM (Small 5 KEEP + Medium 6 ADD) — same GLB, scale 1,1,1  
2. Positions / mount Y ≈ 2.78–2.79 under Medium ceiling ~2.80; Omni recipe warm ~3600K  
3. Footprint/scale vs Medium **14×10 @ 0.9 m** (floor 12.6×9.0) and locked amp extents **0.900×0.128×0.095**  
4. Materials: soft gunmetal + warm LED diffuser; emission ~(1.0, 0.82, 0.62) / strength **9.0**; Principled only  
5. Pivot = **mount top center**; hang under ceiling; no rescale  
6. **No cel/ink**, **no fog veil**  
7. Readability under aisle / ceiling densify framing  
8. Soft **MidCenter X share** parked unless true blocker (collision / shell clip / unreadable hotspots)

---

## Verdict: **PASS-with-notes**

| Gate | Result | Evidence |
|------|--------|----------|
| 1. Fixture count / additive layout | **PASS** | `render_medium_densify_qa.py` instances **all 11** SoT nodes (Small 5 + MidCenter, FarFront, FarBack, DeepLeft, DeepCenter, DeepRight); positions match SoT table exactly |
| 2. Mount Y / ceiling / Omni band | **PASS** | Mounts at Y **2.78–2.79**; hang bottom ≈ **2.695** (under ceiling **2.80**, ~1 cm clearance); Omni at Y **2.55**, color `(1.0, 0.83, 0.66)` in render script; IMPORT_NOTES + `_build_stats` emission/Kelvin lock |
| 3. Scale vs Medium shell + amp extents | **PASS** | Locked `_build_stats` L×W×H **0.900×0.128×0.095**; Medium floor **12.6×9.0**; Far/Deep columns at X≈10.35 / Z≈−7.20 cover wider/deeper volume without rescale |
| 4. Materials / emission amp | **PASS** | Housing gunmetal + EndCap + LED_Diffuser Principled; emission RGB **(1.0, 0.82, 0.62)** strength **9.0** (~3600K). QA stills: lit ceiling/wall R−B median **~20** (warm); diffuser cores near-white (expected hot emissive) |
| 5. Pivot / placement rules | **PASS** | Pivot mount top center; script places at SoT mounts, scale default 1; Small nodes not moved in SoT (additive Medium only) |
| 6. No cel ink / no fog | **PASS** | Soft bevel language; PNGs crisp, no ink outlines, no fog/veil/haze planes |
| 7. Readability (densify framing) | **PASS** | Approach: center column + side glimpses of densified ceiling; Interact: multi-fixture grid under cream ceiling + wood crown; fixtures readable as linear amp LEDs |
| 8. Soft MidCenter X share | **PASS** (soft only) | Known MidCenter↔BackRight X proximity — **parked**, not a blocker (see Soft notes) |

No S1/S2. **Clear for Art assets branch: Yes.**

---

## Layout check (SoT vs render script)

| Set | Nodes | Positions (Godot m) |
|-----|-------|---------------------|
| Small KEEP | FrontLeft, FrontRight, BackLeft, BackRight, BackLeftAisle | (2.25/6.75, 2.79, −2.25/−4.95) + aisle (2.8, 2.78, −5.4) |
| Medium ADD | MidCenter, FarFront, FarBack, DeepLeft, DeepCenter, DeepRight | Mid/Deep X **6.30**; Far/DeepRight X **10.35**; deep Z **−7.20** |

**Medium total = 11** meshes (+ matching Omni fills in Eng). Art QA Blender script mirrors the same 11 mounts.

---

## MidCenter X share (soft — parked)

| Pair | dX | dZ | Notes |
|------|----|----|-------|
| **MidCenter (6.30, −4.95)** vs **BackRight (6.75, −4.95)** | **0.45 m** | **0.00** | Only XZ AABB overlap among the 11; long-axis is **X (0.9 m)** → mesh bodies share volume on mid-depth row |

**Not treated as blocker this gate:** no shell pierce (mounts sit ~1 cm under ceiling), no unreadable hotspot blow-out unique to the pair in QA stills, collision not applicable to decorative overheads for this Art spot-check. Explicitly **parked** per QA brief / prior Medium soft-park pattern. Eng may nudge MidCenter X later when wiring `tier=MEDIUM` — do **not** move Small BackRight.

---

## Visual score (qa-shots)

| Shot | Framing (`render_medium_densify_qa.py`) | Score notes |
|------|----------------------------------------|-------------|
| `LIGHTS_medium_densify_interact` | Cam ~(5.0, 2.0, 1.50) → far/deep ceiling, lens 36 | Multiple linear fixtures + warm fill on cream ceiling/walls; wood crown readable; **no fog / no ink** |
| `LIGHTS_medium_densify_approach` | Cam ~(6.3, 0.55, 1.60) along center X looking deep/up, lens 30 | Center column (Mid/Deep) + edge fixtures; mount plates readable; densify language clear vs Small 4–5 |

Studio Eevee empty-shell stills (weak sun + Point fills) — Art layout proof, not in-engine playable aisle with fixtures/props. Eng wires tier gating in `shop_floor.tscn`.

---

## Soft notes (non-blocking)

1. **MidCenter X share** — MidCenter X=6.30 sits 0.45 m from BackRight on Z=−4.95; mesh AABB overlaps. **Parked.** Optional Eng nudge of MidCenter only when placing Medium extras.  
2. **Ceiling-up framing** — shots prove densify mount language; full aisle/behind-desk prop-filled Medium stills remain Eng/playable follow-up (same pattern as shell empty-shell QA).  
3. **Diffuser cores clip toward white** in stills while authored emission stays warm 3600K amp — expected for strength 9 + Point energy; do not retint mesh this beat.  
4. **SoT / densify shots not on main yet** — local Art tree only; publish on assets branch after this PASS-with-notes. Main already has lighting-amp `prop_light_overhead_01` under `assets/props/shop/fixtures/`.  
5. **Blender Omni energy=100** in QA script ≠ Godot Omni energy **1.65** — studio proxy only; Eng must use SoT Omni recipe.

---

## Blockers

**None.**

---

## Clear for assets branch?

**Yes** — Art may land Medium densify SoT + `LIGHTS_medium_densify_*.png` (+ IMPORT_NOTES Medium pointer) on assets branch. Eng placement / tier hide-show remains Eng-owned per SoT §3.

---

## Evidence paths

- `/workspace/card-shop-qa/evidence/medium-lights-densify/shots/LIGHTS_medium_densify_interact.png`  
- `/workspace/card-shop-qa/evidence/medium-lights-densify/shots/LIGHTS_medium_densify_approach.png`  
- Source mirrors: `docs/art/qa-shots/LIGHTS_medium_densify_{interact,approach}.png`  
- SoT: `docs/art/MEDIUM_OVERHEAD_LIGHTS_MVP.md`  
- Prop: `art/props/prop_light_overhead_01/` (`prop_light_overhead_01.glb`, `IMPORT_NOTES.md`, `_build_stats.txt`, `render_medium_densify_qa.py`)
