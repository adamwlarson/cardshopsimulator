# prop_back_office_glimpse_01 — Import Notes (B07)

## File
- `prop_back_office_glimpse_01.glb` — binary glTF 2.0, +Y up
- Source: `prop_back_office_glimpse_01.blend` + `build_back_office_glimpse.py`

## Scale & Pivot
- **Unit:** 1 unit = **1 meter**
- **Footprint:** **≤0.90 × 0.90 m** (fits 1×1 backstock tile beyond door) — authored **0.880 × 0.880 × 1.520 m**
- **Pivot / origin:** **BOTTOM CENTER** (floor)
- Placement: sit **behind** `prop_backstock_door_01` as set dressing glimpse

## Design
- Wood desk + pedestal, monitor silhouette (emissive cool screen, no readable UI/IP)
- Wall shelf with binders/box/paper stack clutter
- Desk mug (muted teal) + keyboard + paper — lived-in office read

## Materials
Wood, Wood_Dark, Metal, Plastic, Screen (emissive), Paper, Accent

## Mesh budget
- Verts: 576 · Tris: **1056** (≤1.2k) · Soft bevel ~2.5 mm — **no cel/ink outlines**

## Godot tips
1. Place in alcove tile behind A13; desk faces toward door (−Y in Blender).
2. Optional: only visible when door open / camera peeks.

## Godot 4.5.2 import verification
- Project: `/workspace/card-shop-simulator/godot-import-test/`
- Result: **SUCCESS**
