# Combined smoke — polish #11 + camera #12 @ `931b9ecd`
**Scorer:** CSS QA  
**Date:** 2026-09-04 (~10:19 AM ET)  
**Build:** `adamwlarson/cardshopsimulator` main tip `931b9ecd` (PR #11 polish + PR #12 camera)  
**Scope:** Light visual + polish smoke (not full §10 formal)  
**Evidence:** `evidence/smoke_931b9ecd_viewport.png`, `evidence/playtest-931b9ecd.log`

## Verdict: **PASS**

| Gate | Result | Notes |
|------|--------|-------|
| Camera Art SoT | **PASS** | pos `(4.5, 1.65, −1.8)`, rot `(−28, 0, 0)`, FOV `70` |
| Ambient COLOR fill | **PASS** | `ambient_light_source = 2` |
| Viewport floor+fixtures | **PASS** | Aisle floor + fixtures visible — not ceiling/void |
| Prep cash / attention | **PASS** | `$8000.00` (800000¢), Attention `100` |
| Wants §3.2b | **PASS** | `Bastion Captain · NM` — no raw `AA-` SKU |
| Undercut ×0.90 | **PASS** | presenter fill helper; no `* 0.92` |
| Truth leak | **PASS** | UI sources clean |

Harness re-run: **PASS**. No S1/S2. Not held on tip `807516c0` / `23fa0375`.

## Recommendation
Clear polish #11 + camera #12 combined smoke on main `931b9ecd`.
