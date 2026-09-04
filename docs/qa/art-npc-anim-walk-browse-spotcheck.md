# C1–C3 walk + browse_idle — art package spot-check

**Scorer:** CSS QA  
**Date:** 2026-09-04 (ET)  
**Scope:** Spot-check only — looping `walk` + `browse_idle` on `char_customer_casual_a/b/c_01` (C1/C2/C3). Art holds assets branch until QA clear.  
**Source tree:** local Art working copy `/workspace/card-shop-simulator/art/` (+ `docs/art/` mirrors) and agent-data mirror under `/home/box/agent-data/projects/card-shop-simulator/`.  
**Capture harness:** `godot-import-test/qa_capture_npc_anim.gd` (mid-walk t≈0.55 / 1.2s; mid-browse t≈1.10 / 2.27s).  
**Evidence:** `/workspace/card-shop-qa/evidence/npc-anim/`

### Shots reviewed
| Shot | Path |
|------|------|
| Walk mid-loop | `evidence/npc-anim/shots/NPC_anim_walk_interact.png` |
| Browse mid-loop | `evidence/npc-anim/shots/NPC_anim_browse_interact.png` |

`art/qa-shots` ≡ `docs/art/qa-shots` (identical SHA-256 for both PNGs).

### Authored targets (IMPORT_NOTES / `_build_stats`)
| Char | Stem | Height | Outfit | Clips |
|------|------|--------|--------|-------|
| C1 | `char_customer_casual_a_01` | **1.74 m** | hoodie | `walk` (~1.20s), `browse_idle` (~2.27s) |
| C2 | `char_customer_casual_b_01` | **1.70 m** | jacket+tee | same |
| C3 | `char_customer_casual_c_01` | **1.66 m** | coat | same |

Pivot claim: **BOTTOM CENTER** (`min_z≈0` / glTF `min Y = 0`), unchanged from static MVP. Root motion: **in-place**. Style: stylized-real / **no cel ink**. Skinning: rigid part→bone (Art soft note).

---

## Verdict: **PASS-with-notes** (spot-check)

| Check | Verdict | Notes |
|-------|---------|-------|
| Walk loop readable / not broken | **PASS** | Mid-walk silhouettes show stride / foot plant on all three; no severe mesh explode |
| Browse_idle readable near counter | **PASS w/ note** | C3 lean+reach at display case is clear; C1/C2 subtler at same seek time (matches Art soft) |
| Bottom-center pivot preserved | **PASS** | GLB rest bounds `min Y = 0` all three; feet grounded in both shots |
| Heights unchanged | **PASS** | GLB Y extents **1.740 / 1.700 / 1.660** — match targets + prior idle package |
| Rigid skinning | **SOFT OK** | Blocky joint hinges visible; MVP-acceptable per pass bar (not ship-blocking) |
| No cel ink | **PASS** | No outline/cel materials; soft bevel stylized-real only |
| Godot import OK | **PASS** | IMPORT_NOTES present; `.glb.import` + `.godot/imported/*.scn` for A/B/C |

**Blockers:** none.  
**Gate:** Art may clear / merge the assets branch for Eng consume.

---

## Per-char notes

### C1 — `char_customer_casual_a_01` (1.74 / hoodie)
| Item | Result |
|------|--------|
| Walk | **PASS** — Mid-stride readable (leg separation + arm hang); teal hoodie silhouette intact |
| Browse_idle | **PASS w/ note** — Near register; upright with slight arm separation / weight — readable but quieter than C3 at t≈1.10 |
| Pivot / height | **PASS** — `min Y=0`, height 1.74; feet on floor |
| Mesh / skin | **SOFT** — Rigid part weights; no explode / detach |
| Clips in GLB | **PASS** — `walk` (tmax≈1.233), `browse_idle` (tmax≈2.3); 14-bone biped; 42 channels each |

### C2 — `char_customer_casual_b_01` (1.70 / jacket)
| Item | Result |
|------|--------|
| Walk | **PASS** — Frontal mid-walk; stance readable, feet planted, jacket+tee silhouette intact |
| Browse_idle | **PASS w/ note** — Mid-aisle; subtler idle/weight at shared seek — acceptable for MVP loop; browse “hero” is C3 |
| Pivot / height | **PASS** — `min Y=0`, height 1.70 |
| Mesh / skin | **SOFT** — Same rigid skinning family; no blockers |
| Clips in GLB | **PASS** — Same clip names/durations as C1 |

### C3 — `char_customer_casual_c_01` (1.66 / coat)
| Item | Result |
|------|--------|
| Walk | **PASS** — Clear stepping pose near display case; coat silhouette holds |
| Browse_idle | **PASS (strongest)** — Lean + forward arm reach into case volume — Art soft note confirmed |
| Pivot / height | **PASS** — `min Y=0`, height 1.66 (shortest of trio, readable) |
| Mesh / skin | **SOFT** — Rigid hinges OK for MVP |
| Clips in GLB | **PASS** — Same clip names/durations as C1/C2 |

---

## Soft notes (non-blocking)
1. **Rigid skinning** — Limbs read as hinged blocks rather than soft deformation. Allowed for MVP; polish later if Eng wants softer joints.
2. **Browse strongest on C3** — Confirmed in `NPC_anim_browse_interact`. C1/C2 browse at the shared mid-seek is subtler (weight / arm hang). Still readable as “alive idle”; not a blocker. Optional: stagger seek times in a follow-up contact sheet if Art wants equal browse heroism.
3. **Static-frame walk** — Spot-check uses single mid-walk frames (harness seek 0.55s). No full loop scrub / foot-skate video in this package; nothing in the frames suggests broken cycle (no explode, feet contact, opposing limb poses). Eng playtest can scrub `AnimationPlayer` if needed.
4. **IMPORT_NOTES wording** — Points at Godot 4.5.2 qa-shots but does not print an explicit `Result: SUCCESS` line (same soft pattern as prior alive-shop icons). Import artifacts exist and captures succeeded.
5. **Publish path** — Package present in local Art tree (`art/chars`, `art/qa-shots`, `docs/art/*`) + agent-data mirror. Confirm remote assets branch matches this evidence set when Art pushes.

---

## Cross-checks (GLB / Godot)
| Stem | Height Y | min Y | Anims | Godot `.import` + `.scn` | Cel mats |
|------|----------|-------|-------|--------------------------|----------|
| C1 | 1.740 | 0 | `walk`, `browse_idle` | yes | none |
| C2 | 1.700 | 0 | `walk`, `browse_idle` | yes | none |
| C3 | 1.660 | 0 | `walk`, `browse_idle` | yes | none |

Tris remain soft MVP (~2.1–2.3k). Materials Principled-named (`Skin`/`Hair`/`Cloth*`/`Shoe`) — no outline.

---

## Gate status
- C1–C3 **walk + browse_idle** art package spot-check: **PASS-with-notes**  
- **No blockers** — clear for Art to release assets branch  
- Soft: rigid skinning + browse hierarchy (C3 > C1/C2 at mid-frame)  
- Outline / cel-ink S3: remains **CLOSED**

**Report:** `/workspace/card-shop-qa/art-npc-anim-walk-browse-spotcheck.md`  
**Evidence root:** `/workspace/card-shop-qa/evidence/npc-anim/`
