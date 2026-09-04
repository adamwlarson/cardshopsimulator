# prop_shop_shell_medium_01 — Import Notes (Medium shell)

## File
- `prop_shop_shell_medium_01.glb` — binary glTF 2.0, +Y up
- Source: `prop_shop_shell_medium_01.blend` + `build_shop_shell.py` (Blender 4.3 procedural)
- Size flag: `--size=medium` / `CSS_SHELL_SIZE=medium` (same builder language as Small)

## Scale & Pivot
- **Unit:** 1 unit = **1 meter**
- **Tile lock:** 1 tile = **0.9 m** → medium shop **14×10 tiles**
- **Floor interior:** **12.6 m × 9.0 m** (walls/trim extend AABB slightly beyond)
- **Wall height:** **2.80 m** (ceiling above); total AABB H ≈ 2.87 m incl. floor slab + ceiling thickness
- **Pivot / origin:** **FLOOR SOUTHWEST CORNER** at (0,0,0). Floor top sits at Z=0. Place shell so SW floor corner snaps to grid origin.
- Axis: glTF **+Y up** (Blender Z-up → export)
- Front / entrance wall with door cutout = Blender **−Y** (south) → Godot **+Z** typically

## Door cutout
- Centered on front (south) wall; ~1.0 m wide × 2.10 m tall; soft gunmetal frame (same as Small)

## Materials (PBR) — exact Small palette
| Name | Role | Metallic | Roughness |
|------|------|----------|-----------|
| Floor | Med gray commercial tile | 0 | ~0.55 |
| Wall | Cream / warm gray | 0 | ~0.72 |
| Trim | Warm wood baseboard/crown | 0 | ~0.58 |
| TrimMetal | Soft gunmetal door frame | ~0.78 | ~0.40 |
| Ceiling | Soft warm white | 0 | ~0.78 |

## Mesh budget
- Verts: 480 · Tris: 880 · Soft bevel ~3 mm (no cel/ink outlines, no fog)
- Soft visual distinction from Small: longer side walls (9.0 m depth vs 7.2 m); same materials/bevel language

## Eng stub swap
- Replaces Eng procedural Medium stub (gray floor / cream walls / wood trim) with this authored hero shell.
- Do **not** edit `shop_floor.tscn` / Eng stub scripts from Art — Eng wires the GLB swap.
- Instance at Medium shop grid origin (SW). Scale 1,1,1.

## Godot tips
1. Interior usable volume: X 0…12.6, Y 0…9.0 (Blender) / corresponding Godot axes after +Y-up.
2. Pair with `prop_light_overhead_01` hung under ceiling (~Z=2.8); Medium may need multiple lights across the longer aisle.
3. Front door opening faces customer approach (+Z in Godot after glTF import).
