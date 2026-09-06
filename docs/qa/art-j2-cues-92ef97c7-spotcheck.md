# J2 Art cues spot-check — graded showcase badge + ONLINE_HOLD tag

**Scorer:** CSS QA (Art executor)  
**Date:** 2026-09-06 (ET)  
**Tip / PR:** `92ef97c7` — PR #38 `cursor/j2-art-cues-b14c` (assets/shots identical to prior tip `a73753f4`; tip delta = SoT yaw lock + Eng re-ACK)  
**SoT:** `docs/art/J2_ART_CUES_MVP.md` (+ fixture `IMPORT_NOTES.md`)  
**Scope:** Showcase graded case badge + ONLINE_HOLD tag. Soft `_ensure_priceable_sku` **parked (OOS)**. Soft yaw **CLOSED** on this tip (SoT + IMPORT_NOTES). Eng marker ACK already done.  
**Evidence crops:** `/workspace/card-shop-qa/evidence/j2-cues/`  
**Checkout:** `/workspace/qa-playtest/j2-92ef97c7/adamwlarson-cardshopsimulator-92ef97c/`

### Shots reviewed (`docs/art/qa-shots/J2_*.png`)
| Shot | SHA-256 prefix | Role |
|------|----------------|------|
| `J2_graded_case_far.png` | `aca818bca4ae075b` | base vs slab+badge ~8.2 m |
| `J2_graded_case_approach.png` | `6524885918c2b048` | ~3.6 m |
| `J2_graded_case_interact.png` | `eff8efa8b687f0da` | ~1.9 m |
| `J2_graded_case_badge_detail.png` | `024a34c459611af1` | crest detail |
| `J2_online_hold_tag_alone.png` | `3092b4a34bee8459` | amber HOLD vs teal price/talker |
| `J2_online_hold_tag_shelf_approach.png` | `76c0e4e8fd3058ae` | shelf lip approach |
| `J2_online_hold_tag_shelf_interact.png` | `4dbb725693dafed5` | shelf lip interact |
| `J2_online_hold_tag_case_lip_interact.png` | `6df6e8ec54695d5e` | case lip interact |

**Note:** Stills are PBR rasters of GLBs (no Godot viewport) — scored against that bar, not in-engine FOV.

### Props / IMPORT_NOTES
| Prop | Path | GLB mats (Principled MR only) | Notes |
|------|------|-------------------------------|-------|
| `prop_graded_case_badge_01` | `assets/props/shop/fixtures/prop_graded_case_badge_01/` | Metal, Metal_Slab, Plaque, Felt, Paper | 672v/224t; pivot back-center mount; parent `(0,1.06,-0.452)` on slab case; **no cel/ink** |
| `prop_online_hold_tag_01` | `assets/props/shop/fixtures/prop_online_hold_tag_01/` | Metal, Plastic, Paper, **Accent_Amber (0.82,0.52,0.18)** | 432v/144t; CLIP/MOUNT TOP-BACK; price-tag class; **no cel/ink** |

Yaw (CLOSED / SoT on tip `92ef97c7`): shelf customer face **−X → Y = −90°**; case customer face **−Z → Y = 180°**. Fixture IMPORT_NOTES are SoT if chat disagrees. Does **not** break silhouette in proof shots (tags face aisle).

---

## Verdict: **PASS-with-notes**

| # | Pass bar | Verdict | Notes |
|---|----------|---------|-------|
| 1 | Silhouette / contrast / affordance at shop-camera distance | **PASS-with-notes** | Approach (~3.6 m) + interact (~1.9 m): brass diamond crest readable vs empty base case; ONLINE_HOLD tag readable on shelf/case lip. Far (~8.2 m): crest is only a few pixels — side-by-side vs base shows a header poke, but alone read is thin (expected for additive crest; SoT designed for this). Affordance carried by approach/interact. |
| 2 | Amber vs teal distinction (ONLINE_HOLD vs teal talkers; graded distinct) | **PASS** | Alone shot: mid tag **Accent_Amber** header + white diamond pip vs left price **Accent_Teal** and right tall teal talker — clear. Shelf/case-lip proofs: header samples ~`(156,93,46)` amber, not teal. Graded cue is **brass/gunmetal diamond crest** (Plaque ~`(0.8,0.64,0.36)`), not amber — distinct shape/role from ONLINE_HOLD tag. (Pass-bar parenthetical “graded vs ONLINE_HOLD” maps to SoT as crest-vs-amber-tag + amber-vs-teal-talkers.) |
| 3 | Props Principled-only; no cel ink | **PASS** | Both GLBs: `pbrMetallicRoughness` only; no extensions; build scripts procedural PBR; soft bevel only; IMPORT_NOTES + SoT forbid cel/ink. |
| 4 | Required J2_* shot set present | **PASS** | All 8 SoT-listed filenames present under `docs/art/qa-shots/`. |
| — | Soft `_ensure_priceable_sku` | **PARKED** | OOS — do not FAIL. |
| — | Soft yaw −90° | **CLOSED** | Locked in SoT + IMPORT_NOTES on `92ef97c7`; Eng re-ACK done. Not Soft. |

**Blockers:** none.  

**Clear for Eng marker / assets?** **YES** — Art package clear for Eng consume. Eng marker ACK already on tip `92ef97c7` (`GradedCaseBadge` static; `OnlineHoldTag` visibility on `location.type == ONLINE_HOLD` only). Soft seed remains parked.

---

## Per-shot notes

### Graded case
- **Far** — Base (left) vs slab+badge (right) at ~8.2 m / fov 70. Crest is sub-silhouette alone; comparison frame shows slight header difference. Score as soft note, not blocker.
- **Approach** — Diamond crest + side bars readable on left case vs empty right; brass pops against dark interior / glass.
- **Interact** — Crest clear; placeholder bars / diamond only (no IP/cert text).
- **Badge detail** — Nested diamond (gunmetal rim / brass face / burgundy pip) + plaque bars; Principled, no ink.

### ONLINE_HOLD
- **Alone** — Amber HOLD (diamond pip) vs teal price tag + teal talker — primary color-distinction proof. **PASS**.
- **Shelf approach / interact** — Tag on shelf lip; amber header readable at approach; interact confirms clip body + amber band (pixel sample amber, not teal).
- **Case lip interact** — Light tag body on case lip; amber header present; silhouette OK at interact.

## Eng consume reminders (already ACK’d)
- `GradedCaseBadge` — optional **static** child of slab case; no runtime toggle; do not bind to `cert_valid`/economy.
- `OnlineHoldTag` — visibility only when slot `ONLINE_HOLD`; hide otherwise; no new economy/HUD APIs.
- Do not rescale `prop_display_case_slab_01` (2×1 @ 0.9 m locked).

## Notes (non-blocking)
1. Far graded crest thin at ~8.2 m PBR still — approach/interact carry shop-camera affordance.
2. SoT color map: ONLINE_HOLD = **Accent_Amber**; price/talker = **Accent_Teal**; graded = **brass crest** (not amber fill).
3. Yaw closed on tip `92ef97c7` — follow IMPORT_NOTES; proofs face aisle.
4. Soft `_ensure_priceable_sku` parked OOS.

## Merge

Merged to main as **PR #38** @ `2bfa0efd46fa423bc0fa9dd54b7acb3cbaaba505` (2026-09-06). Spot-check tip `92ef97c7`; merge included main catch-up.
