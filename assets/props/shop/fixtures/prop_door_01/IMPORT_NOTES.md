# prop_door_01 — Import Notes (A02)

## File
- `prop_door_01.glb` — binary glTF 2.0, +Y up
- Source: `prop_door_01.blend` + `build_door.py`

## Scale & Pivot
- **Unit:** 1 unit = **1 meter**
- **Door leaf:** **0.90 W × 0.06 D × 2.05 H** (within 0.05–0.08 D spec)
- **With optional frame:** AABB ≈ **1.02 × 0.16 × 2.13 m** (fits shell cutout ~1.0 × 2.10 with clearance)
- **Pivot / origin:** **HINGE-SIDE BOTTOM** — hinge edge at **X≈0**, floor at **Z=0**, thickness centered on Y. Rotate about local up-axis to open.
- **Hinge edge:** −X (leaf extends +X into the opening)

## Materials
| Name | Role |
|------|------|
| Wood | Main door leaf |
| Wood_Panel | Recessed lower panels |
| Glass | Upper lite (cool tint, low roughness) |
| Metal | Soft gunmetal frame, hinges, handle, lite trim |

## Mesh budget
- Soft bevel ~2.5 mm — **no cel/ink outlines**
- Frame included (jambs + lintel + sill); hide/separate in Godot if shell already provides frame

## Godot tips
1. Instance at hinge foot of doorway. Scale 1,1,1.
2. Pair with `prop_shop_shell_01` front cutout (DOOR_W=1.0, DOOR_H=2.10).
3. Hang `prop_sign_open_closed_01` on glass lite or latch jamb via mount-center pivot.
