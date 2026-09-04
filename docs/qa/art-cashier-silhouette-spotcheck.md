# Cashier silhouette — art package spot-check (`char_cashier_01`)

**Scorer:** CSS QA  
**Date:** 2026-09-04 (ET)  
**Scope:** Spot-check only — optional cashier / clerk silhouette for counter distance. Art holds assets branch until QA clear. Soft notes park unless blocker.  
**Out of scope:** Medium PR #21 formal (do not wait).  
**Source tree:** local Art working copy `/workspace/card-shop-simulator/art/` (+ `docs/art/` mirrors) and agent-data mirror under `/home/box/agent-data/projects/card-shop-simulator/`.  
**Capture harness:** `godot-import-test/qa_capture_cashier.gd` (behind counter; `idle_stand` seek t≈0.85 / ~2.03s).  
**Evidence:** `/workspace/card-shop-qa/evidence/cashier/`

### Shots reviewed
| Shot | Path |
|------|------|
| Counter interact | `evidence/cashier/shots/NPC_cashier_interact.png` |
| Counter approach | `evidence/cashier/shots/NPC_cashier_approach.png` |
| Customer cast ref | `evidence/cashier/shots/NPC_customers_interact_ref.png` (C1–C3 compare) |

`art/qa-shots` ≡ `docs/art/qa-shots` ≡ agent-data qa-shots (identical SHA-256 for both cashier PNGs).  
GLB SHA-256 prefix `d3b94de220fbdde1` matches across `art/`, `docs/art/`, and `godot-import-test/chars/`.

### Authored targets (IMPORT_NOTES / `_build_stats`)
| Field | Claim | Measured (GLB rest bounds) |
|-------|-------|----------------------------|
| Stem | `char_cashier_01` | — |
| Role | Optional adult retail clerk behind counter | Polo + apron silhouette in both shots |
| Height | **1.72 m** (between C1 1.74 / C2 1.70) | **1.7200 m** (`min Y=0` → `max Y=1.72`) |
| Extents W×D×H | 0.8023 × 0.3098 × 1.7200 | **0.8023 × 0.3098 × 1.7200** |
| Pivot | **BOTTOM CENTER** (`min_z≈0` / glTF `min Y=0`) | **PASS** — `min Y = 0.000000` |
| Clip | `idle_stand` ~2.00 s in-place | Present; duration **≈2.033 s**; root in-place |
| Style | Stylized-real / **no cel ink** | Principled mats only (Skin/Hair/Cloth/Apron/Cloth_Lower/Shoe) |
| Mesh | 1268 verts / 2404 tris | Matches `_build_stats` |
| Skinning | Rigid part→bone (same family as C1–C3) | Soft note |

---

## Verdict: **PASS-with-notes** (spot-check)

| Check | Verdict | Notes |
|-------|---------|-------|
| Readable cashier silhouette at counter distance | **PASS** | Interact + approach both read clear humanoid clerk behind register; no explode / detach |
| Scale vs C1–C3 (~human height) | **PASS** | **1.72 m** sits between C1 **1.74** and C2 **1.70**; counter/register scale reads adult |
| Pivot bottom-center | **PASS** | GLB `min Y = 0`; harness places at floor `y=0` behind `prop_counter_01` |
| Distinct from customer cast if possible | **PASS w/ note** | Apron + blank name-tag plate + behind-counter role; **polo teal RGB matches C1 hoodie teal** `(0.22, 0.40, 0.42)` — cast distinction is apron/placement more than hue |
| No cel ink | **PASS** | No outline/cel materials; soft bevel stylized-real only |
| Godot import OK | **PASS** | IMPORT_NOTES present; `.glb.import` + `.godot/imported/*.scn` in `godot-import-test`; harness wrote both QA shots |
| Mesh / pivot / scale blockers | **none** | No mesh explode, wrong pivot, or wrong scale |

**Blockers:** none.  
**Gate:** Art may clear / merge the assets branch for Eng consume (optional cashier; not required to wait on Medium PR #21).

---

## Per-shot notes

### Interact — `NPC_cashier_interact.png`
| Item | Result |
|------|--------|
| Silhouette | **PASS** — Clerk readable over counter at customer FOV; register in foreground; shelf/case props frame the beat |
| Height / grounding | **PASS** — Head/torso scale vs counter matches ~1.7 m adult; feet intended on floor behind counter (lower body occluded by counter — expected) |
| Outfit read | **PASS w/ note** — Muted teal polo short sleeves + dark hair mass clear; cream apron / name-tag plate subtler at this distance/occlusion (still present in GLB mats) |
| Mesh / skin | **SOFT** — Blocky rigid hinges; no explode |
| Cel ink | **PASS** |

### Approach — `NPC_cashier_approach.png`
| Item | Result |
|------|--------|
| Silhouette | **PASS** — Closer customer-side read; collar/sleeve/hair mass readable; still no mesh blow-up |
| Height / grounding | **PASS** — Consistent with interact; register screen + counter give scale anchors |
| Outfit read | **PASS w/ note** — Same teal polo hero; apron remains secondary read behind register mass |
| Mesh / skin | **SOFT** — Same family as C1–C3 |
| Cel ink | **PASS** |

---

## Soft notes (non-blocking)
1. **Teal overlap with C1** — Cashier `Cloth` baseColorFactor **(0.22, 0.40, 0.42)** is identical to C1 hoodie teal. Distinctness for MVP relies on **cream apron + blank name-tag + behind-counter placement**, not hue alone. Optional later: shift clerk teal or emphasize apron in customer FOV if cast confusion shows up in playtest.
2. **Apron / name-tag subtler than polo in QA frames** — Counter + register occlude lower torso; approach/interact hero the polo from customer side. GLB still carries `Apron` material and authored plate (no text/SKU). Not a blocker for silhouette spot-check.
3. **Rigid part→bone skinning** — Same blockout hinges as C1–C3. Allowed for MVP; polish later if Eng wants softer joints.
4. **Single mid-idle frame** — Harness seeks `idle_stand` @0.85s (paused). No full loop scrub video in this package; rest bounds + mid-idle pose show no explode / root drift. Eng can scrub `AnimationPlayer` if needed.

---

## Package paths (sources)
| Item | Path |
|------|------|
| GLB | `art/chars/char_cashier_01/char_cashier_01.glb` (+ `docs/art/chars/…`, agent-data mirror) |
| IMPORT_NOTES | `art/chars/char_cashier_01/IMPORT_NOTES.md` |
| `_build_stats` | `art/chars/char_cashier_01/_build_stats.txt` |
| QA shots | `art/qa-shots/NPC_cashier_{interact,approach}.png` |
| Godot import test | `godot-import-test/chars/char_cashier_01.glb[.import]` + imported `.scn` |
| Capture | `godot-import-test/qa_capture_cashier.gd` / `run_qa_cashier.sh` |

### Evidence tree
```
/workspace/card-shop-qa/evidence/cashier/
  shots/NPC_cashier_interact.png
  shots/NPC_cashier_approach.png
  shots/NPC_customers_interact_ref.png
  pkg/char_cashier_01.glb
  pkg/IMPORT_NOTES.md
  pkg/_build_stats.txt
  pkg/char_cashier_01.glb.import
```

---

## Pass-bar checklist (copy for Art Lead)
- [x] Readable cashier silhouette at counter distance  
- [x] Scale/pivot consistent with C1–C3 (~human height, bottom-center) — **1.72 m**, `min Y=0`  
- [x] Distinct from customer cast if possible — **apron + role** (soft: teal = C1)  
- [x] No cel ink; Godot import OK  
- [x] Soft notes only (no mesh explode / wrong pivot / wrong scale)
