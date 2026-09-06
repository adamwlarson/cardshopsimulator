# Large Shop Shell — Art MVP (SoT)

**Asset:** `prop_shop_shell_large_01`  
**Audience:** Eng (stub swap) + Art Lead (footprint lock)  
**Rule:** Art authors the hero GLB only. Art does **not** edit `shop_floor.tscn`, economy, or Soft seeds. Fog/scaffold is Eng interim only.

---

## 1. Tile lock (do not drift)

| Item | Value |
|------|-------|
| Tile | **1 tile = 0.9 m** |
| Large grid | **18 × 13 tiles** |
| Interior floor | **16.2 × 11.7 m** (= 18×0.9 × 13×0.9) |
| Interior area | 16.2 × 11.7 = **189.54 m²** |
| Square feet | 189.54 × 10.76391 ≈ **2,040 sq ft** |
| Marketing / systems §7.3 | **~2,000 sq ft** · weekly rent **$4,000** · staff cap **5** |
| Eng tile sq ft (`8.71875`) | 18 × 13 × 8.71875 = **2,040.1875** |

Small/Medium remain locked:

| Tier | Tiles | Interior (m) | ≈ sq ft | Hero GLB |
|------|-------|--------------|---------|----------|
| Small | 10×8 | 9.0 × 7.2 | ~698 | `prop_shop_shell_01` |
| Medium | 14×10 | 12.6 × 9.0 | ~1,221 / markets 1,200 | `prop_shop_shell_medium_01` |
| Large | **18×13** | **16.2 × 11.7** | **~2,040 / markets 2,000** | `prop_shop_shell_large_01` |

Wall height matches Medium: **~2.80 m** ceiling. Front/south door cutout **~1.0 × 2.10 m**, centered.

---

## 2. Pivot / axes

- **Pivot:** floor **southwest** corner at **(0,0,0)** — same Eng stub-swap pattern as Medium.
- Floor top at **Y = 0**. Interior grows **+X** and **−Z**.
- Front door faces customer approach **+Z**.
- Instance scale **(1,1,1)**. 1u = 1 m.

---

## 3. Eng stub-swap (Art does not land this)

One-liner: when `tier=LARGE`, hide `ShopShell` / `ShopShellMedium`; instance

`res://assets/props/shop/fixtures/prop_shop_shell_large_01/prop_shop_shell_large_01.glb`

as `Architecture/ShopShellLarge` at SW origin, scale 1. Fog/scaffold interim is Eng-only and must not ship as the hero.

Do **not** edit `shop_floor.tscn` from this Art package.

---

## 4. Materials

Exact Small/Medium palette — Floor / Wall / Trim / TrimMetal / Ceiling. Soft 3 mm bevel. **No cel/ink. No fog mesh.**

---

## 5. Builder

```
python3 assets/props/shop/fixtures/prop_shop_shell_large_01/build_shop_shell.py --size=large
```

`--size=small|medium|large` (or `CSS_SHELL_SIZE`). Small/Medium overwrite is blocked unless `--force` (locked Blender heroes).

---

## 6. QA stills

| Shot | Path |
|------|------|
| Far | `docs/art/qa-shots/SHELL_large_far.png` |
| Approach | `docs/art/qa-shots/SHELL_large_approach.png` |
| Interact | `docs/art/qa-shots/SHELL_large_interact.png` |
| Medium vs Large | `docs/art/qa-shots/SHELL_medium_vs_large.png` |

Studio PBR rasters of the GLB (same bar as J2 / Medium shell) — not an in-engine viewport.

---

## 7. Parked (not this PR)

- Soft `_ensure_priceable_sku`
- Soft J2 far-crest polish
- Economy / rent / staff-cap verbs
- Large overhead densify
- Wiring `shop_floor.tscn`
