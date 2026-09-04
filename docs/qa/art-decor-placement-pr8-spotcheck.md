# Placement PR #8 light décor visual spot-check
**Scorer:** CSS QA  
**Date:** 2026-09-04 (ET)  
**Tip:** `9cb24ab650d0781d1edd7cec174b3884e14624b5` (PR #8 merged main — *Place light décor fixtures on shop floor*)  
**Evidence:** `evidence/pr8_decor_placement.png` (gameplay camera on `scenes/shop/shop_floor.tscn`, xvfb-run Godot 4.5.2 after `--import`)  
**Scope:** Optional A10 stool / B04 shipper / B05 plant / B08 trash placement — GLB paths, `shop_floor` instances, tile×0.9 / half-tile, facing/pivots, S1/S2 placement. Art mesh readability already cleared in `art-light-decor-a10-b04-b05-b08-spotcheck.md`.

## Verdict: **PASS-with-notes**

| Check | Result | Notes |
|-------|--------|-------|
| GLB inventory under `assets/props/shop/fixtures/` | **PASS** | All four present: `prop_stool_01`, `prop_shipper_stack_01`, `prop_plant_01`, `prop_trash_bin_01` (+ `IMPORT_NOTES.md`). Godot import SUCCESS (`.glb.import` + `.godot/imported/*.scn`) |
| Docs/art duplicate GLBs | **N/A / note** | Tip ships décor under **assets** (placement PR). No `docs/art/props/` GLB copies on this tip — expected after promote-to-assets |
| `shop_floor` instances wired | **PASS** | ExtResources 24–27; nodes `CounterStool`, `BackstockShipperStack`, `CornerPlant`, `CounterTrashBin` under `Fixtures` (23 fixture kids post-PR8) |
| Tile×0.9 snap | **PASS** | All four XZ on integer or half-tile centers; `y=0` floor snap |
| Footprint 10×8 | **PASS** | All inside usable floor; plant/shipper on back wall half-tiles; stool/trash on right/front half-tiles |
| Gameplay-camera readability | **PASS w/ note** | Plant + shipper stack read clearly at default cam `(4.5, 2.25, −0.45)`. Stool shares cam depth (`z=−0.45`) → peripheral/out of aisle FOV (same class as entrance-plane fixtures in PR #4). Trash on right wall between counter/case is small and easy to miss from aisle cam — confirmed present via transform + AABB, not a missing instance |
| Pivot / facing (in situ) | **PASS** | Authored yaw=0, scale `(1,1,1)`, basis det=1 (not flipped). Mesh AABB `min_y=0` for all four → bottom-center floor pivots; no floor clip / float |
| Materials / no cel ink | **PASS** | Matches prior light-décor art gate; soft bevels, no ink outlines in frame |

No S1. No S2 for placement.

## Layout snapshot — light décor (tile = 0.9 m)

| Art ID | Stem | Node | Position (m) | Tiles (x,z) | Extents (W×D×H) | AABB min_y |
|--------|------|------|--------------|-------------|-----------------|------------|
| A10 | `prop_stool_01` | CounterStool | (8.10, 0, −0.45) | (9.0, −0.5) | 0.40×0.40×0.45 | 0.000 |
| B04 | `prop_shipper_stack_01` | BackstockShipperStack | (3.60, 0, −6.75) | (4.0, −7.5) | 0.50×0.40×0.55 | 0.000 |
| B05 | `prop_plant_01` | CornerPlant | (0.45, 0, −6.75) | (0.5, −7.5) | 0.30×0.30×0.45 | 0.000 |
| B08 | `prop_trash_bin_01` | CounterTrashBin | (8.55, 0, −2.25) | (9.5, −2.5) | 0.30×0.30×0.50 | 0.000 |

Placement intent matches IMPORT_NOTES tips: stool near counter / front sales floor; shipper near backstock door; plant back-left corner; trash at counter side / right wall.

## Shot observations
- **Gameplay cam:** Cozy aisle read intact. Sealed-wall plant + kraft shipper stack sit cleanly on the back plane with ground contact; no float/clip. Counter / case / binder / wall shelf heroes unchanged from PR #4.
- **Runtime probe** (`tests/qa_decor_capture.gd`): all four DECOR nodes print local=global, yaw=0, unit scale, positive basis det; mesh AABBs match authored extents with `P.y=0`.

## Notes for Art / Eng
- Fresh tip needs a Godot import pass before GLB instances resolve (local QA only — not a ship bug).
- `assets/props/shop/fixtures/README.md` still lists **20** props and omits A10/B04/B05/B08 — docs lag only (S4); do not block placement clear.
- Optional polish (non-blocking): slight cam nudge or stool half-tile deeper into shop if product wants stool silhouette in the default aisle frame; trash already correctly sited for counter-side filler.
- Prior art gate (`art-light-decor-a10-b04-b05-b08-spotcheck.md`) remains green; this tip only adds Eng placement wiring.

## Clear for
Art/Eng: light décor placement on main is QA-clear (PASS-with-notes). No placement S1/S2.
