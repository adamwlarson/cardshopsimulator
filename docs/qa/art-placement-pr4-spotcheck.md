# Placement PR #4 fixture visual spot-check
**Scorer:** CSS QA  
**Date:** 2026-09-04  
**Tip:** `76d00d02` (PR #4 merged main)  
**Evidence:** `evidence/pr4_placement_gameplay.png` (gameplay camera on `scenes/shop/shop_floor.tscn`)  
**Scope:** Optional fixture placement / tile×0.9 / pivot-facing spot-check only. Domain §10 / BuyOpportunityList retest still **held** until UI S2 tip freezes.

## Verdict: **PASS**

| Check | Result | Notes |
|-------|--------|-------|
| GLB inventory under `assets/props/shop/fixtures/` | **PASS** | All 20 fixture folders present with `.glb` (shell, doors, counter, case, register, shelf, sealed wall, binder rack, lights, posters, price props, proxies) |
| `shop_floor` instances wired | **PASS** | Architecture: ShopShell; Fixtures: 18 props + OverheadLights×4; Systems + HUD intact |
| Tile×0.9 snap | **PASS** | All fixture XZ on integer or half-tile centers (0.9 m). Floor heroes on y=0; register/signage/poster heights sensible |
| Footprint 10×8 | **PASS** | Placements inside 9.0×7.2 m usable; wall fixtures sit on perimeter half-tiles |
| Gameplay-camera readability | **PASS** | Counter, case, binder rack, sealed wall, wall shelf, backstock door, poster strip, 4 overheads all legible; aisle reads open |
| Pivot / facing (in situ) | **PASS w/ note** | Most yaw=0 (authored in GLB). Proxies/talker use 90°/180° where needed (explorer box, shelf talker, booster box). Interaction faces read toward the floor from gameplay cam |
| Materials / no cel ink | **PASS** | Matches prior P0a/P0b/P1 language; soft bevels, no ink outlines |

No S1. No S2 for placement.

## Layout snapshot (tile = 0.9 m)

| Node | Position (m) | Tiles (x,z) |
|------|--------------|-------------|
| EntranceDoor | (4.05, 0, 0) | (4.5, 0) |
| BackstockDoor | (4.5, 0, −6.75) | (5, −7.5) |
| CheckoutCounter / Register | (7.2, 0/1, −1.35) | (8, −1.5) |
| HighValueDisplayCase | (7.2, 0, −3.15) | (8, −3.5) |
| BinderRack | (1.35, 0, −3.6) | (1.5, −4) |
| SealedWall | (1.8, 0, −6.75) | (2, −7.5) |
| WallShelf | (8.55, 0, −5.4) | (9.5, −6) |
| Posters sm/md/lg | z=−7.2 row | (−8) |
| OverheadLights ×4 | y=2.79 | half-tile grid |

## Notes
- Fresh tip needs a Godot import pass before GLB instances resolve (local QA only — not a ship bug).
- Open/closed sign + entrance sit on the front plane (behind gameplay cam); not required for this interior placement gate.
- Proxy stock cubes on case/shelf are intentional placeholders until merch art; not a placement fail.
- **Still held:** warm-up A–F + §10 #1/#2 retest until UI S2 (`BuyOpportunityList` + §3.2a) Eng-Approves.

## Clear for
Art/Eng: placement fixture layout on main is QA-clear. Next QA wake = UI S2 tip freeze.
