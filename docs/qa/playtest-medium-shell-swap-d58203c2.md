# Playtest — Medium shell swap formal (PR #25)

**Tip:** `d58203c2` (`d58203c25b2fe205e2b7c5c345f8c65c7cd46037`)  
**Date:** 2026-09-04  
**Harness:** 97 PASS / 0 FAIL / 3 soft  

## Verdict: **PASS-with-notes**

| # | Pass bar | Result |
|---|----------|--------|
| 1 | Sign → Art Medium shell visible | **PASS** — `prop_shop_shell_medium_01` / ShopShellMedium |
| 2 | Stub gone after expand | **PASS** — no MediumFloor/walls/stub children |
| 3 | Stay Small = Small-only | **PASS** — Medium hidden; Small visible |
| 4 | 14×10 @ 0.9 m (interior 12.6×9.0) | **PASS** |
| 5 | Fog nack | **PASS** — no veil / fog feature |
| 6 | Save/load Medium | **PASS** — tier/grid/shell restore |
| 7 | Soft apron parked | **Noted** |

## Soft notes
1. Soft apron FOV (prior cashier) — non-blocking  
2. Optional extra Medium aisle lights later  
3. usable_sq_ft ~1221 vs 1200 parked  

## Evidence
- `/workspace/card-shop-qa/evidence/medium-shell-swap-d58203c2/` (`medium-shell-swap-aisle.png`, `smoke.json`, logs)
