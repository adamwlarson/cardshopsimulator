# Playtest — Cashier wire formal (PR #23)

**Tip:** `a7a1b4e9` (`a7a1b4e9ed6ef1e34c0f0c57d12668379481f103`)  
**Date:** 2026-09-04  
**Harness:** 61 PASS / 0 FAIL / 5 soft  

## Verdict: **PASS-with-notes**

| # | Pass bar | Result |
|---|----------|--------|
| 1 | Hire-gated clerk | **PASS** — owner-only empty; hire shows clerk |
| 2 | idle_stand loop | **PASS** — AnimationPlayer LOOP_LINEAR ~2.03s playing |
| 3 | Owner-only empty | **PASS** — cashier_count=0, visible=0 when solo |
| 4 | Customers path OK | **PASS** — entrance→desk 4 pts; APPROACH with clerk present |
| 5 | Pose `(8.05, 0, -0.95)` yaw `+90` | **PASS** — slot + hired clerk; faces −X |
| 6 | Soft apron parked | **Noted** (non-blocking) |

## Soft notes
1. Apron subtler at customer FOV / counter occlusion  
2. Headless smoke — viewport PNG optional follow-up  
3. Rigid part→bone skinning (MVP OK)  
4. Teal polo ≈ C1 hoodie — apron/role distinguishes  
5. REGISTER_STATIONS=1 even at Medium staff_cap 3 — by design  

## Evidence
- `/workspace/card-shop-qa/evidence/cashier-wire-a7a1b4e9/` (`summary.json`, `harness_stdout.log`, foundation/import logs)
