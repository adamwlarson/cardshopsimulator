# UI visual smoke — PR #13 @ `f34bd25a`
**Scorer:** CSS QA  
**Date:** 2026-09-04 (~11:03 AM ET)  
**Build:** `adamwlarson/cardshopsimulator` main tip `f34bd25a`  
**Scope:** Light smoke — HUD readable Day1 Prep + camera SoT floor still visible + Prep/Wants intact  
**Evidence:** `evidence/smoke_f34bd25a_viewport.png`, `evidence/playtest-f34bd25a.log`

## Verdict: **PASS**

| Gate | Result | Notes |
|------|--------|-------|
| HUD readable Day1 Prep | **PASS** | Top bar: Day 1, PREP chip, `$8,000.00`, Att `100/100`, Queue 0; action buttons Open floor / Buy opportunity / Price inventory legible |
| Camera still shows floor | **PASS** | SoT `(4.5, 1.65, −1.8)` / `(−28,0,0)` / FOV 70; aisle floor + fixtures in frame — not ceiling/void |
| Prep seed | **PASS** | Cash 800000¢ / Attention 100 |
| Wants bible · condition | **PASS** | `Bastion Captain · NM` — no raw `AA-` |
| Undercut ×0.90 | **PASS** | No regression |
| Truth leak | **PASS** | UI sources clean |

Harness: **27 PASS / 0 FAIL**. No S1/S2.

## Notes
- Phase chip + Att `100/100` formatting read cleaner than pre-#13 strip.
- Soft décor FOV nits from PR #8 remain parked.

## Recommendation
Clear UI visual pass smoke on main `f34bd25a`.
