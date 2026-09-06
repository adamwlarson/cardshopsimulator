# prop_shop_shell_large_01 — Import Notes (Large shell)

## File
- `prop_shop_shell_large_01.glb` — binary glTF 2.0, +Y up
- Source: `build_shop_shell.py` (Python PBR pipeline — same `--size` language as Small/Medium)
- Size flag: `--size=large` / `CSS_SHELL_SIZE=large`

## Scale & Pivot
- **Unit:** 1 unit = **1 meter**
- **Tile lock:** 1 tile = **0.9 m** → large shop **18×13 tiles**
- **Floor interior:** **16.2 m × 11.7 m** (walls/trim extend AABB slightly beyond)
- **Usable area:** 16.2 × 11.7 = **189.54 m²** → **≈ 2,040 sq ft** (16.2 × 11.7 × 10.76391)
  - Marketing / systems-design §7.3: **~2,000 sq ft** / $4,000 rent / staff 5
  - Eng tile convention (`SQ_FT_PER_TILE` 8.71875): 18 × 13 × 8.71875 = **2,040.1875 sq ft**
- **Wall height:** **2.80 m** (ceiling above); total AABB H ≈ 2.87 m incl. floor slab + ceiling thickness
- **Pivot / origin:** **FLOOR SOUTHWEST CORNER** at (0,0,0). Floor top sits at Y=0. Place shell so SW floor corner snaps to grid origin.
- Axis: glTF **+Y up**
- Front / entrance wall with door cutout = **+Z** (south). Interior volume is **−Z**.

## Door cutout
- Centered on front (south) wall; ~1.0 m wide × 2.10 m tall; soft gunmetal frame (same as Small/Medium)
- Opening X **7.60…8.60** (centered on 16.2 m width)

## Materials (PBR) — exact Small/Medium palette
| Name | Role | Metallic | Roughness |
|------|------|----------|-----------|
| Floor | Med gray commercial tile | 0 | ~0.55 |
| Wall | Cream / warm gray | 0 | ~0.72 |
| Trim | Warm wood baseboard/crown | 0 | ~0.58 |
| TrimMetal | Soft gunmetal door frame | ~0.78 | ~0.40 |
| Ceiling | Soft warm white | 0 | ~0.78 |

## Mesh budget
- Soft bevel ~3 mm (no cel/ink outlines, **no fog**)
- Blockout-quality shell; tri count can sit above Medium’s ~880 — keep the same box language
- Soft visual distinction from Medium: longer side walls (11.7 m depth vs 9.0 m); same materials/bevel language

## Eng stub swap
- Replaces Eng procedural Large stub / fog-scaffold interim with this authored hero shell.
- Do **not** edit `shop_floor.tscn` / Eng stub scripts from Art — Eng wires the GLB swap.
- Instance at Large shop grid origin (SW). Scale 1,1,1.
- One-liner for Eng: hide Small/Medium shells; instance `prop_shop_shell_large_01.glb` as `Architecture/ShopShellLarge` at SW origin, scale `(1,1,1)`, visible when `tier=LARGE`.

## Godot tips
1. Interior usable volume: X 0…16.2, Z 0…−11.7 (glTF / Godot +Y up).
2. Pair with `prop_light_overhead_01` hung under ceiling (~Y=2.8); Large will need more fixtures than Medium across the longer aisle (Art densify later — not this package).
3. Front door opening faces customer approach (+Z). Pair with `prop_door_01` (DOOR_W=1.0, DOOR_H=2.10).
