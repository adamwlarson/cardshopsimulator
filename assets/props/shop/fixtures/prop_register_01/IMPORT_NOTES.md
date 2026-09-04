# prop_register_01 — Import Notes

## File
- `prop_register_01.glb` — binary glTF 2.0, +Y up
- Source: `prop_register_01.blend` + `build_register.py` (Blender 4.3 procedural blockout)

## Scale & Pivot
- **Unit:** 1 Blender/glTF unit = **1 meter**
- **Placement:** Countertop POS — sits **ON** counter (not a floor tile). No §7.1 floor footprint.
- **Authored extents:** **0.4000 m W × 0.3400 m D × 0.4050 m H** (target band ~0.35–0.45 × 0.30–0.40 × 0.35–0.50)
- **Pivot / origin:** **BOTTOM CENTER** of register base. Place node on countertop surface; no extra Z offset.
- Axis: glTF **+Y up** (Blender Z-up converted on export)
- Grid lock: tile_size_m=0.9 ratified by Eng; register is a surface prop, not a grid occupant.

## Materials (PBR metallic-roughness)
| Name          | Role                         | Metallic | Roughness | Notes                                      |
|---------------|------------------------------|----------|-----------|--------------------------------------------|
| Plastic_Body  | Dark matte body / base / drawer | 0     | ~0.55     | Main mass, drawer, screen housing, printer |
| Screen        | Soft emissive POS display    | 0        | ~0.25     | Teal emission for soft glow                |
| Metal         | Dark metal accents           | 1        | ~0.30     | Bezel, drawer handle, card reader, trim    |
| Button_Pad    | Keypad / button plastic      | 0        | ~0.45     | Front pad + button stubs                   |

Godot 4: Screen emission may need a small Emission energy tweak after import for shop lighting.

## Mesh budget
- **Verts:** 600
- **Tris:** 1100 (LOD0 blockout — well under 5k)
- Single mesh object `prop_register_01` with material slots: Plastic_Body,Metal,Button_Pad,Screen

## Godot usage tips
1. Drop GLB into `res://`; let Godot generate `.import`.
2. Parent/place on countertop (counter height ≈ 1.0 m for `prop_counter_01`).
3. Scale 1,1,1. Customer-facing keypad/screen toward aisle (−Z after +Y-up import; verify in scene).
4. Readable silhouette: drawer mass + upright screen + keypad shelf.

## Style intent
Cozy-but-serious stylized-real retail POS — dark plastic body, soft teal screen glow, metal bezel/handle accents, matte button pad. Strong vertical read when sitting on counter for shop-camera gate (A08).

## Godot 4.5.2 import verification
- Project: `/workspace/card-shop-simulator/godot-import-test/`
- Result: **SUCCESS** (exit 0). `prop_register_01.glb` imported; `.glb.import` generated.
- QA shots: `A08_far.png`, `A08_approach.png`, `A08_interact.png` (on-counter context).
