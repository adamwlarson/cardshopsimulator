# prop_security_camera_01 — Import Notes (V1 Art dual-track)

## File
- `prop_security_camera_01.glb` — binary glTF 2.0, +Y up
- Source: `build_security_camera.py` (procedural Principled/PBR, 1u=1m)

## Scale & Pivot
- **Unit:** 1 unit = **1 meter**
- **Authored extents:** **0.124 × 0.182 × 0.184 m** (W × D × H). Dome/body class **~0.12 m** dia; arm/mount included in the hang.
- **Pivot / origin:** **MOUNT** — center of the attach plate, top face at **Y = 0**. Fixture hangs below (**−Y**). Authored look bias **+Z** (downward tilt).
- Soft bevel / low-seg cylinders — **no cel/ink outlines**
- Placeholder silhouette only — **no brand logos / readable IP / SKU text**

## Materials (PBR metallic-roughness)
| Name | Role | Metallic | Roughness |
|------|------|----------|-----------|
| Metal | Soft gunmetal plate, stem, joint, rear cap, lens ring | 0.80 | 0.40 |
| Plastic | Dark charcoal barrel + status pip | 0 | 0.46 |
| Glass | Smoked lens dome (BLEND + transmission) | 0.04 | 0.10 |

Glass is dark smoked retail lens — not a brand mark, not a HUD pip.

## Mesh budget
- Verts: 996 · Tris: **332** (≤400) ✓

## Godot usage tips
1. Instance scale **1,1,1**. Do not rescale the hero.
2. **Ceiling:** place the node on the underside of Medium/Large ceiling (**Y ≈ 2.80 m**, same band as `prop_light_overhead_01` mounts at ~2.78–2.79). Yaw so authored **+Z** points at the coverage volume (into the shop is often **Y = 180°** so look becomes **−Z**).
3. **Wall:** on a wall that faces **+Z** into the room, set **Y = 180°** then **X = −90°** so the plate sits on the wall, the body hangs into the room, and the lens looks down. Origin stays on the wall surface. Extra yaw after that if the wall faces another axis.
4. Suggested Medium ceiling spots (docs only — Eng places later): entrance watch **(6.30, 2.80, −1.80)**; case aisle **(4.50, 2.80, −4.20)**. Large may add a deep-aisle copy near **X ≈ 10.4**, **Z ≈ −8.4**.
5. Do **not** parent to Soft J2 far crest / `prop_graded_case_badge_01`. Soft catalog stays closed (U1). Soft far crest stays **Art later**.

## Eng marker hook (visibility only — no economy verbs)
- Instance as `SecurityCamera` (or keep imported mesh name `prop_security_camera_01`).
- **ACK:** toggle `MeshInstance3D.visible` (or a `Marker3D` parent) when cameras are **owned**.
- Hide when cameras are not owned. Eng V1 economy may ship text/placeholder first.
- Do **not** invent buy/install HUD chrome, multi-cam, alarm, or staff-camera verbs in this Art pack.

## Godot 4.x import
- Drop GLB into `res://`; let Godot generate `.import`.
- Principled slots import as StandardMaterial3D metallic-roughness. Glass may need a transparency pass after import.
