# Playtest — Customer NPC FLOOR smoke (PR #20)

**Tip:** `26b5551b` (`26b5551b020e9ae3f56d53e505d7004a5869bef4`)  
**Date:** 2026-09-04  
**SoT:** `docs/design/customer-npc-v1.md`  
**Harness:** 106 PASS / 0 FAIL  

## Verdict: **PASS-with-notes**

| # | Pass bar | Result |
|---|----------|--------|
| 1 | ≥1 NPC when queue non-empty; spawn→browse→approach→resolve→exit | **PASS** — C1–C3 visible; lifecycle path entrance→desk→exit |
| 2 | Intent icons readable (amber sell / teal buy / neutral browse); no truth leak | **PASS** — sell `(0.92,0.62,0.22)`; buy `(0.22,0.72,0.68)`; browse `(0.82,0.84,0.86)`; truth scan clean |
| 3 | Serve HUD only in desk volume; Esc dismisses without despawn | **PASS** — closed off-volume; open in-volume; Esc hides HUD, NPC stays RESOLVE |
| 4 | Camera RMB / aisle reset / behind-desk SoT intact | **PASS** — aisle `(4.5,1.65,-1.8)/(-28)/70`; behind-desk `(7.2,1.6,-0.65)/(-18)/70`; RMB clamps; NPC does not move cam |
| 5 | Soft Eng/Art nits non-blocking | **Noted** |

## Soft notes (S4)
1. `customer-npc-v1.md` still Status: Draft (usable; sync before freeze).
2. `ICON_READ_SCALE=2.0` on bobber (Art disc 0.32 m) — intentional aisle-cam readability.
3. Capsule fallback remains if GLB import fails — OK for MVP.
4. SoT §3 ≤40% dim behind thin HUD — no explicit 40% dim in `hud.gd` (modal veil may cover).

## Evidence
- `/workspace/card-shop-qa/evidence/npc-floor-26b5551b/` (aisle_with_npcs.png, behind_desk_with_npcs.png, summary.json, harness.log)
