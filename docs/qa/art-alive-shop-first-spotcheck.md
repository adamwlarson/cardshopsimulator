# Alive-shop first art package — spot-check (customer-npc-v1)

**Scorer:** CSS QA  
**Date:** 2026-09-04 (ET)  
**Scope:** Spot-check only — lighting amp + C1–C3 idle NPCs + overhead intent icons (Art Lead first drop, aligned to `docs/design/customer-npc-v1.md`).  
**Source tree:** local Art working copy `/workspace/card-shop-simulator/docs/art/` (+ `art/` mirrors). SoT `customer-npc-v1.md` is on GitHub `main` (`b28abfaa`); GLBs/qa-shots for this package were **not** yet on remote `main` / listed Art branches at check time.  
**Evidence:** `/workspace/card-shop-qa/evidence/alive-shop/`

### Shots reviewed
| Shot | Path |
|------|------|
| Lighting amp | `evidence/alive-shop/shots/LIGHTING_amp_interact.png` |
| NPCs interact | `evidence/alive-shop/shots/NPC_customers_interact.png` |
| NPCs approach | `evidence/alive-shop/shots/NPC_customers_approach.png` |
| Icons | `evidence/alive-shop/shots/ICONS_overhead_interact.png` |

### SoT color lock (`customer-npc-v1` §2)
| Intent | SoT | Authored accent (GLB `baseColorFactor`) |
|--------|-----|----------------------------------------|
| Browse | Neutral | `Accent_Neutral` **(0.38, 0.40, 0.44)** gunmetal |
| Buy | Teal | `Accent_Teal` **(0.16, 0.40, 0.46)** muted teal |
| Sell | Warm amber | `Accent_Amber` **(0.82, 0.52, 0.18)** — **not** burgundy |

---

## Verdict: **PASS** (spot-check)

| Asset | Verdict | Notes |
|-------|---------|-------|
| `prop_light_overhead_01` (lighting-amp) | **PASS** | Emission **(1.0, 0.82, 0.62)** × **str 9**; extents **0.900 × 0.128 × 0.095**; pivot **mount top-center** preserved |
| `char_customer_casual_a_01` (C1) | **PASS** | **1.74 m**, hoodie, bottom-center, idle A-pose, no anim |
| `char_customer_casual_b_01` (C2) | **PASS** | **1.70 m**, jacket, bottom-center, idle A-pose, no anim |
| `char_customer_casual_c_01` (C3) | **PASS** | **1.66 m**, coat, bottom-center, idle A-pose, no anim |
| `prop_icon_browse_01` | **PASS** | Hang pivot bottom-center; face **−Y**; gunmetal/neutral; no text |
| `prop_icon_buy_01` | **PASS** | Hang pivot; face **−Y**; muted teal; no text |
| `prop_icon_sell_01` | **PASS** | Hang pivot; face **−Y**; **warm amber** (retint from burgundy); no text |
| Cross-cut: no cel ink | **PASS** | Principled / soft bevel only across light, NPCs, icons |
| Cross-cut: Godot import OK | **PASS** | `.glb.import` + `.godot/imported/*.scn` present in `godot-import-test` for all seven stems; light IMPORT_NOTES explicitly **SUCCESS** |

No S1/S2. No cel-ink S3 reopen.

---

## Per-asset checks

### 1. Lighting amp — `prop_light_overhead_01`
| Check | Result | Evidence |
|-------|--------|----------|
| Warmer ~3600K emission | **PASS** | GLB `LED_Diffuser` emissive **[1, 0.82, 0.62]** + `KHR_materials_emissive_strength` **9**; `_build_stats` `kelvin_feel=3600` |
| Pivot / footprint preserved | **PASS** | Bounds size **0.900 × 0.095 × 0.128** (L×H×W in Y-up); origin at **top** (`max Y = 0`, body hangs −Y) — matches prior **0.9 × 0.128** mount |
| No cel ink | **PASS** | Soft gunmetal housing; no outline materials |
| Godot import | **PASS** | IMPORT_NOTES **SUCCESS**; `prop_light_overhead_01.glb.import` + imported `.scn` |
| Visual warmth in shot | **PASS w/ note** | `LIGHTING_amp_interact`: scene R−B ≈ **64** (warmer than prior `LIGHT_DECOR_interact` ≈ **48**); warm wall wash clear in top crop |

### 2. NPCs — C1 / C2 / C3
| Check | Result | Evidence |
|-------|--------|----------|
| Height claims | **PASS** | GLB Y extents **1.740 / 1.700 / 1.660**; matches `_build_stats` + IMPORT_NOTES |
| Bottom-center pivot | **PASS** | All three `min Y = 0` (floor between feet) |
| Idle A-pose / no anim | **PASS** | `animations=0`; A-pose readable in both NPC shots |
| Distinct customer silhouettes | **PASS** | Hoodie (muted teal) / open jacket+tee / long camel coat — capsule-quality mannequins, clearly three customers |
| No cel ink | **PASS** | Soft bevel ~2.5 mm; flat stylized-real |
| Godot import | **PASS** | Imported `.scn` + `.import` for all three under `godot-import-test/chars/` |

SoT MVP bar explicitly allows capsule/mannequin blockout first — met.

### 3. Overhead icons — browse / buy / sell
| Check | Result | Evidence |
|-------|--------|----------|
| Hang pivot (bottom-center) | **PASS** | All three `min Y = 0`; disc rises +Y; `_build_stats` `pivot=bottom_center_disc` |
| Face −Y | **PASS** | Thin depth on Z (~0.032 m); `face=-Y` in build stats / scripts |
| Browse = gunmetal/neutral | **PASS** | `Accent_Neutral` (0.38, 0.40, 0.44); magnifier glyph in shot |
| Buy = muted teal | **PASS** | `Accent_Teal` (0.16, 0.40, 0.46); teal accent readable in shot |
| Sell = warm amber (not burgundy) | **PASS** | `Accent_Amber` (0.82, 0.52, 0.18); amber tag/cash accents; no burgundy accent material |
| No baked text / SKU / price | **PASS** | Geometry-only glyphs; matches SoT §2 + N2 |
| No cel ink | **PASS** | Soft bevel ~1.2 mm |
| Godot import | **PASS** | All three imported in `godot-import-test/props/` |

---

## Soft notes (non-blocking)
1. **`LIGHTING_amp_interact` framing:** Capture looks at counter/cases (`look ≈ y 0.82`); overhead **mesh** sits above FOV. Warmth is proven by fill + GLB emission — optional follow-up: one ceiling-up / fixture-in-frame still for Art docs.
2. **Icon IMPORT_NOTES** cite the qa-shot project but omit an explicit `Result: SUCCESS` line (light amp has it). Import artifacts exist; wording polish only.
3. **Buy glyph:** Authored as pack/card silhouette (SoT allows “shopping bag / card+”). Readable as buy intent; not a fail if Eng expects a literal bag later.
4. **Icons shot** uses a grey **capsule proxy** under the three bobbers (intentional scale ref) — real C1–C3 are covered in the NPC shots, not composited under icons.
5. **Remote publish:** Package lives in the Art Lead local tree (`docs/art/props|chars|qa-shots`). Push/PR to GitHub when ready so Eng/QA clones match this evidence set.
6. **C3 vs SoT cast wording:** SoT lists C3 as optional kid/parent or Spike lean; Art shipped a shorter **adult coat** at 1.66 m — fine for first presence; remap note for PM if kid silhouette still desired later.
7. **Wood albedo under amp:** Light IMPORT_NOTES already flag oak reading cool under 3600K — tracked as notes-only; not part of this gate.

---

## Gate status
- Alive-shop **first art package** spot-check: **PASS**  
- Outline / cel-ink S3: remains **CLOSED**  
- Clear for Eng to wire C1–C3 + intent icons per `customer-npc-v1` (N1–N2 art side ready); playable FLOOR N1–N6 still Eng/systems QA  

**Report:** `/workspace/card-shop-qa/art-alive-shop-first-spotcheck.md`  
**Evidence root:** `/workspace/card-shop-qa/evidence/alive-shop/`
