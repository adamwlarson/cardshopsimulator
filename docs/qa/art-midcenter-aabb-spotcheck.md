# Art Soft MidCenter AABB — densify soft-park fix spot-check

**Scorer:** CSS QA  
**Date:** 2026-09-04 (~6:24–6:30 PM ET)  
**Gate:** Soft MidCenter AABB polish (post densify PASS-with-notes)  
**Art package:** local `/workspace/card-shop-simulator/` (`docs/art/` + `art/` + agent-data mirror)  
**SoT:** `docs/art/MEDIUM_OVERHEAD_LIGHTS_MVP.md` (updated Soft MidCenter AABB polish post #27)  
**Prior:** `/workspace/card-shop-qa/art-medium-lights-densify-spotcheck.md` (MidCenter was 6.30; soft park parked)  
**Evidence:** `/workspace/card-shop-qa/evidence/midcenter-aabb-spotcheck/shots/`  
**Package touchpoints:** `render_medium_densify_qa.py` (V3 / MidCenter 5.40), re-rendered `LIGHTS_medium_densify_{interact,approach}.png` @ 22:23 UTC, IMPORT_NOTES Medium densify pointer, same `prop_light_overhead_01` GLB

### Pass bar (PM)
1. MidCenter at **(5.40, 2.79, -4.95)** — densify soft park fix  
2. Principled-only / fog nack  
3. MidCenter ≠ BackRight (distinct nodes; BackRight still ~**6.75** on mid row)  
4. Soft teal polo parked — do not FAIL  

---

## Verdict: **PASS**

| Gate | Result | Evidence |
|------|--------|----------|
| 1. MidCenter coords | **PASS** | SoT §2 table + Soft MidCenter AABB polish: MidCenter **(5.40, 2.79, -4.95)**. `render_medium_densify_qa.py` ALL list line MidCenter **(5.40, 2.79, -4.95)**. Agent-data SoT mirror matches. |
| 2. Principled / fog nack | **PASS** | SoT §3 Eng rule **Fog nack**; IMPORT_NOTES LED_Diffuser / mesh budget **Principled only, no cel/ink**; `build_light_overhead.py` uses `ShaderNodeBsdfPrincipled`. QA stills crisp, no fog/veil/haze planes. |
| 3. Distinct vs BackRight | **PASS** | BackRight **unchanged** (6.75, 2.79, -4.95) in SoT Small KEEP + render script. MidCenter ≠ BackRight (separate named nodes). **dX = 1.35 m**. Mesh L=**0.900** → edge gap **0.45 m**, AABB overlap **0.00 m** (was dX 0.45 / overlap ~0.45). DeepCenter stays X=6.30 on deep row only. |
| 4. Soft teal polo | **PASS** (parked / OOS) | Not in densify ceiling stills; explicitly **non-blocking** per PM. Do not FAIL. |

No S1/S2. **Clear for Eng place at updated SoT: Yes** (MidCenter → 5.40; do not move Small BackRight).

---

## Separation math (mid-depth row Z = −4.95)

| Node | Position | Notes |
|------|----------|-------|
| BackLeft | (2.25, 2.79, -4.95) | Small KEEP |
| **MidCenter** | **(5.40, 2.79, -4.95)** | Medium ADD — **fixed** |
| **BackRight** | **(6.75, 2.79, -4.95)** | Small KEEP — **unchanged** |
| FarBack | (10.35, 2.79, -4.95) | Medium ADD |

| Pair | Prior dX | Now dX | AABB (L=0.9 along X) |
|------|----------|--------|----------------------|
| MidCenter ↔ BackRight | **0.45 m** (overlap) | **1.35 m** | Centers clear; face gap **0.45 m**; overlap **0** |

Prior densify soft park: MidCenter at 6.30 shared volume with BackRight on coplanar mid row. Fix moves MidCenter left into mid-aisle (between left 2.25 and Small right 6.75) without touching Small nodes — matches SoT “additive only / never move Small.”

---

## Visual score (re-rendered densify stills)

| Shot | Path | Notes |
|------|------|-------|
| Interact | `LIGHTS_medium_densify_interact.png` | Mid-row fixtures readable as distinct linear amps; clear gap between center-ish and right fixtures; cream ceiling + wood crown; **no fog / no ink** |
| Approach | `LIGHTS_medium_densify_approach.png` | Center column + right neighbor separated; densify language intact; Principled warm fill, no volumetric veil |

Studio Eevee empty-shell stills (same pattern as densify gate) — layout proof, not playable aisle. Script banner `QA_MEDIUM_DENSIFY_V3_DONE` after MidCenter 5.40 update.

---

## Soft notes (non-blocking)

1. **Soft teal polo** — OOS / parked; not scored as blocker.  
2. **Empty-shell framing** — ceiling densify proof only; Eng/playable prop-filled Medium stills remain follow-up.  
3. **Blender Omni energy=100** in QA script ≠ Godot Omni **1.65** — studio proxy; Eng uses SoT Omni recipe at `(5.40, 2.55, -4.95)` for MidCenter fill.  
4. **Art SoT + shots local / assets-branch path** — Eng places from SoT when wiring `tier=MEDIUM`; do not re-nudge MidCenter unless playable collision/readability says otherwise (AABB gate closed).

---

## Blockers

**None.**

---

## Clear for Eng place nudge?

**Yes — place MidCenter at SoT (5.40, 2.79, -4.95)** (+ OmniFill at Y=2.55). Art closed the soft AABB park in SoT/render/shots. **Do not move BackRight** (or any Small KEEP node). No further Art AABB fix required for this gate.

---

## Evidence paths

- `/workspace/card-shop-qa/evidence/midcenter-aabb-spotcheck/shots/LIGHTS_medium_densify_interact.png`  
- `/workspace/card-shop-qa/evidence/midcenter-aabb-spotcheck/shots/LIGHTS_medium_densify_approach.png`  
- Source: `docs/art/qa-shots/LIGHTS_medium_densify_{interact,approach}.png` (+ `art/qa-shots/` mirror)  
- SoT: `docs/art/MEDIUM_OVERHEAD_LIGHTS_MVP.md` (§2 MidCenter 5.40 + Soft MidCenter AABB polish)  
- Render: `art/props/prop_light_overhead_01/render_medium_densify_qa.py`  
- Prior densify report: `/workspace/card-shop-qa/art-medium-lights-densify-spotcheck.md`
