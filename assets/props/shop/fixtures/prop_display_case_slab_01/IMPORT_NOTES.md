# prop_display_case_slab_01 — Import Notes (B01)

## File
- `prop_display_case_slab_01.glb` — binary glTF 2.0, +Y up
- Source: `prop_display_case_slab_01.blend` + `build_display_case_slab.py`

## Scale & Pivot
- **Unit:** 1 unit = **1 meter**
- **§7.1 footprint:** Same as `prop_display_case_01` — **2×1 tiles** → **1.800 × 0.900 m** (do **not** rescale)
- **Authored extents:** **1.800 × 0.900 × 1.120 m**
- **Pivot / origin:** **BOTTOM CENTER** (floor)

## Distinct vs A04 base case
- Extra **gunmetal slab/graded trim** on front glass face + wood corner caps
- **Taller inner mid-shelf** with richer burgundy felt + 3 low slab risers
- Soft brass-ish **plaque strip** + badge blocks on lower cabinet (no readable IP)

## Materials
| Name | Role |
|------|------|
| Wood / Wood_Recess | Cabinet body + seam |
| Metal / Metal_Slab | Frame + graded trim / risers |
| Glass | Clear panes (alpha+transmission) |
| Felt | Richer burgundy liner |
| Plaque | Soft brass plaque strip |

## Mesh budget
- Verts: 960 · Tris: **1760** (≤3k) · Soft bevel ~2.5 mm — **no cel/ink outlines**

## Godot tips
1. Drop-in companion to `prop_display_case_01`; same 2×1 footprint.
2. Customer face ≈ −Z in Godot after +Y-up import.

## Godot 4.5.2 import verification
- Project: `/workspace/card-shop-simulator/godot-import-test/`
- Result: **SUCCESS**
