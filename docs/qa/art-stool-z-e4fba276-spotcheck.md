# QA — CounterStool Z nudge smoke (PR #14)

**Tip:** `e4fba276` (main, PR #14 merged)  
**Date:** 2026-09-04  
**Scope:** Light smoke — CounterStool not in entrance lane under aisle cam; soft HUD/cam regression.

## Verdict: **PASS**

| Check | Result |
|-------|--------|
| CounterStool transform | `(8.1, 0, -0.9)` in `shop_floor.tscn` |
| Runtime global pos | `(8.1, 0.0, -0.9)` |
| Old entrance-lane Z cleared | **not** `(8.1, 0, -0.45)` |
| Out of entrance (`z ≤ -0.85`) | PASS (one full 0.9m tile deeper than prior half-tile) |
| Aisle-cam visual | Entrance lane clear; stool not blocking path under aisle cam |
| Camera SoT | pos `(4.5, 1.65, -1.8)`, rot `(-28, 0, 0)`, fov `70` unchanged |
| Soft HUD/cam regression | Camera SoT intact; viewport HUD Day1 PREP `$8,000` / Att 100 readable; no stool-related HUD delta |

**Harness:** `10 PASS / 0 FAIL` (`tests/qa_stool_smoke.gd` local)

## Notes

- Stool sits on counter-right wall (`x=8.1`), rotated `Y=90°`, now at `z=-0.9` (was `-0.45`). Under aisle cam looking −Z from `z=-1.8`, it is no longer in the near-entrance band.
- Soft: Prep seed / HUD readability last locked on PR #13 (`f34bd25a`); this tip is placement-only.

## Evidence

- Viewport: `evidence/smoke_e4fba276_stool.png`
- Log: `evidence/playtest-e4fba276.log`

## Severity

None (ship).
