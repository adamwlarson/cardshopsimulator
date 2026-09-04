# Cashier apron FOV polish — art package spot-check (`char_cashier_01`)

**Scorer:** CSS QA  
**Date:** 2026-09-04 (ET)  
**Scope:** Spot-check only — cashier apron / name-tag FOV polish on `char_cashier_01` (post silhouette soft park). Art holds assets branch until QA clear. Soft MidCenter stays parked (out of scope; do not FAIL).  
**Baseline:** `/workspace/card-shop-qa/art-cashier-silhouette-spotcheck.md` (apron soft-parked as subtler than polo in customer FOV).  
**Source tree:** local Art working copy `/workspace/card-shop-simulator/art/` (+ `docs/art/` mirrors). Agent-data mirror under `/home/box/agent-data/projects/card-shop-simulator/` has docs/qa only (no apron PNGs yet).  
**Evidence:** `/workspace/card-shop-qa/evidence/cashier-apron/`

### Shots reviewed
| Shot | Path |
|------|------|
| Counter interact (apron FOV) | `evidence/cashier-apron/NPC_cashier_apron_interact.png` |
| Counter approach (apron FOV) | `evidence/cashier-apron/NPC_cashier_apron_approach.png` |

Sources (identical SHA-256):  
- `art/qa-shots/NPC_cashier_apron_{interact,approach}.png`  
- `docs/art/qa-shots/NPC_cashier_apron_{interact,approach}.png`  

| File | SHA-256 |
|------|---------|
| `NPC_cashier_apron_interact.png` | `1870d00c320539be…` |
| `NPC_cashier_apron_approach.png` | `3acb64741dcf07c2…` |

GLB SHA-256 prefix `872205822f0536ca` matches across `art/chars/`, `docs/art/chars/`, and `godot-import-test/chars/`.

### Authored targets (IMPORT_NOTES / `_build_stats`)
| Field | Claim | Measured |
|-------|-------|----------|
| Stem | `char_cashier_01` | — |
| Height | **1.72 m** | **1.7200 m** (GLB `min Y=0` → `max Y=1.72`) |
| Extents W×D×H | 0.8023 × 0.3171 × 1.7200 | **0.8023 × 0.3171 × 1.7200** |
| Pivot | BOTTOM CENTER | **PASS** — `min Y = 0.000000` |
| Clip | `idle_stand` ~2.00 s in-place | Present; duration **2.0000 s**; root in-place |
| Style | Stylized-real / **no cel ink** | Principled mats only (Skin/Hair/Cloth/Apron/Cloth_Lower/Shoe) |
| Apron | Warm canvas FOV polish | `Apron` baseColor **(0.94, 0.86, 0.58)** |
| Name-tag | Larger blank plate + dark charcoal rim, no text | `NameTag` + `NameTag_Rim` (Shoe charcoal) in build |
| Mesh | 1364 verts / 2580 tris | Matches `_build_stats` (was 1268 / 2404 pre-polish) |
| Flag | `fov_polish=apron_nametag_2026-09-04` | Present in `_build_stats` |

---

## Verdict: **PASS** (spot-check)

| Check | Verdict | Notes |
|-------|---------|-------|
| Height ~1.72 m / `idle_stand` pose language | **PASS** | GLB Y extent **1.72 m**, pivot floor; both shots read adult idle behind counter (arms relaxed, soft blocky stand) |
| Principled-only materials; no cel ink | **PASS** | Six PBR mats, metallic 0; no outline/cel extensions; soft bevel only |
| Warmer canvas apron + higher-contrast blank name-tag | **PASS** | Warm canvas apron is the FOV hero; blank tag + dark rim readable on bib; **improved vs prior soft park** |
| Cozy-but-serious stylized-real retail vibe | **PASS** | Warm shop light, muted teal polo + canvas apron + charcoal trousers; register/counter framing intact |
| Soft MidCenter | **PARKED** | Out of scope per PM — do not FAIL |

**Blockers:** none.  
**Gate:** **Clear for assets / branch** — Art may clear / merge the cashier FOV-polish package for Eng consume. Soft MidCenter remains parked separately.

---

## Per-shot notes

### Interact — `NPC_cashier_apron_interact.png`
| Item | Result |
|------|--------|
| Apron FOV read | **PASS** — Full front apron visible behind counter; warm canvas body, wider straps, waistband value break, centered pocket |
| Name-tag | **PASS** — Blank rectangular plate on upper bib with dark charcoal rim; no text/SKU; clear contrast vs canvas |
| Height / pose | **PASS** — ~1.72 m adult vs counter/register; `idle_stand` language |
| Materials / cel | **PASS** — Flat principled shading; no ink outlines |
| Vs prior silhouette interact | **Improved** — Prior soft-parked apron as secondary / often occluded or back-facing; this frame faces customer with apron as cast cue |

### Approach — `NPC_cashier_apron_approach.png`
| Item | Result |
|------|--------|
| Apron FOV read | **PASS** — Closer customer FOV; warm canvas fills torso; straps / waistband / pocket still readable despite register foreground |
| Name-tag | **PASS** — Blank plate + dark rim still pops at approach distance |
| Height / pose | **PASS** — Consistent with interact |
| Materials / cel | **PASS** |
| Vs prior silhouette approach | **Improved** — Prior approach mostly back/over-shoulder (apron body hidden); polish mesh faces −Z so CashierSlot yaw presents apron to customers |

---

## Baseline comparison (silhouette soft park → FOV polish)

| Topic | Prior silhouette spot-check | This FOV polish |
|-------|-----------------------------|-----------------|
| Apron in customer FOV | Soft note: cream apron / name-tag **subtler than polo**; often occluded or back-facing in harness frames | Warm canvas **(0.94, 0.86, 0.58)** is primary cast read; front-facing interact + approach |
| Name-tag | Present in GLB but weak screen read | Larger blank plate + charcoal rim; screen samples show brighter tag plate vs apron body |
| Mesh budget | 1268 verts / 2404 tris | 1364 verts / 2580 tris (bib / straps / tag / waistband densify) |
| Orientation | Soft: customer FOV sometimes saw back | IMPORT_NOTES: mesh front aligned Godot **−Z** for CashierSlot yaw 90 → customers (−X) |

Screen-sample (torso crop, new shots): apron mean ~**(214, 174, 126)** warm canvas; blank tag mean ~**(255, 235, 152)** — value delta ~**41–45** (readable contrast).

---

## Soft notes (non-blocking)
1. **Soft MidCenter parked** — Explicitly out of scope for this gate; do not reopen as FAIL.
2. **Teal polo still matches C1 hoodie** `(0.22, 0.40, 0.42)` — Intentional per IMPORT_NOTES; cast distinctness now carried by warm apron + name-tag + behind-counter role (addresses prior soft note).
3. **Rigid part→bone skinning** — Same blockout hinges as C1–C3 / prior cashier. MVP-acceptable.
4. **Approach register occlusion** — Lower apron/legs partially hidden by `prop_register` mass (expected customer FOV); bib + tag remain clear.

---

## Pass-bar checklist (PM)
- [x] Height ~1.72 m / `idle_stand` pose language  
- [x] Principled-only materials; no cel ink  
- [x] Warmer canvas apron + higher-contrast blank name-tag (no text)  
- [x] Cozy-but-serious stylized-real retail vibe  
- [x] Soft MidCenter parked (out of scope)  
- [x] Clear for assets / branch (no blockers)

---

## Package paths (sources)
| Item | Path |
|------|------|
| GLB | `art/chars/char_cashier_01/char_cashier_01.glb` (+ `docs/art/chars/…`, `godot-import-test/chars/`) |
| IMPORT_NOTES | `art/chars/char_cashier_01/IMPORT_NOTES.md` |
| `_build_stats` | `art/chars/char_cashier_01/_build_stats.txt` |
| Build | `art/chars/char_cashier_01/build_char_cashier_01.py` (`fov_polish=apron_nametag_2026-09-04`) |
| QA shots | `art/qa-shots/NPC_cashier_apron_{interact,approach}.png` |

### Evidence tree
```
/workspace/card-shop-qa/evidence/cashier-apron/
  NPC_cashier_apron_interact.png
  NPC_cashier_apron_approach.png
```
