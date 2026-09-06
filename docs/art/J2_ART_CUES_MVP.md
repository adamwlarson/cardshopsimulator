# J2 Art cues (MVP) — graded showcase + ONLINE_HOLD

**Owner:** CSS Art  
**Status:** Art-ready (Eng marker ACK later)  
**SoT companions:** `VISUAL_DIRECTION_MVP.md`, fixture `IMPORT_NOTES.md`  
**Not SoT:** economy verbs, HUD list/cancel chrome, `_ensure_priceable_sku`

Thin additive props only. No hero-case rescale. No cel/ink. Principled/PBR, 1u=1m.

## 1. Graded showcase read

| Item | Path |
|------|------|
| Badge GLB | `assets/props/shop/fixtures/prop_graded_case_badge_01/` |
| Host case | `prop_display_case_slab_01` (B01) — footprint **2×1 @ 0.9 m**, pivot bottom-center, locked |
| Parent | Local `(0.0, 1.06, -0.452)` on the slab case, yaw 0 |

Far / approach / interact proof: `docs/art/qa-shots/J2_graded_case_{far,approach,interact}.png` plus `J2_graded_case_badge_detail.png`.

**Eng ACK (optional static):** node `GradedCaseBadge` — no runtime toggle.

## 2. ONLINE_HOLD shelf/tag cue

| Item | Path |
|------|------|
| Tag GLB | `assets/props/shop/fixtures/prop_online_hold_tag_01/` |
| Pattern | Same clip class as `prop_price_tag_01` (pivot CLIP/MOUNT TOP-BACK) |
| Distinct | **Accent_Amber (0.82, 0.52, 0.18)** header + diamond pip vs teal talkers |

Proof: `docs/art/qa-shots/J2_online_hold_tag_{alone,shelf_approach,shelf_interact,case_lip_interact}.png`.

**Eng ACK (visibility only):** show `OnlineHoldTag` / `prop_online_hold_tag_01` when slot `location.type == ONLINE_HOLD`. Hide otherwise. No new economy API.

## Parked

- Soft `_ensure_priceable_sku`
- List/cancel HUD widgets
- Authenticity / `cert_valid` world labels
