# V1 Security Camera — Art MVP (SoT)

**Asset:** `prop_security_camera_01`  
**Audience:** Eng (place when Camera unlock is owned) + Art Lead (scale / pivot lock)  
**Rule:** Art authors the hero GLB only. Art does **not** edit `shop_floor.tscn`, economy, or Soft seeds. Eng V1 may ship text/placeholder first — this pack is optional dual-track.

Soft catalog stays **CLOSED** (U1). Soft far crest (J2 badge) stays **Art later** — do not polish the crest in this package.

---

## 1. Scale / pivot (do not drift)

| Item | Value |
|------|-------|
| Unit | **1u = 1 m** |
| Dome / body | **~0.12 m** diameter (class **0.10–0.18 m**) |
| Authored AABB | **0.124 × 0.182 × 0.184 m** (W × D × H), arm/mount included |
| Pivot | **MOUNT** — attach-plate top center at **(0,0,0)** |
| Hang | **−Y** (below the attach face) |
| Look | Authored **+Z**, tilted down (~32°) |
| Scale | **(1,1,1)** — do not rescale |
| Tris | **332** (≤400) · Principled/PBR · **no cel/ink** |

Materials: **Metal** (gunmetal), **Plastic** (charcoal barrel), **Glass** (smoked lens). Placeholder only — no brand logos / readable IP.

Rebuild:

```
python3 assets/props/shop/fixtures/prop_security_camera_01/build_security_camera.py
```

---

## 2. Eng place tips (docs only — Art does not wire)

Expected node: **`SecurityCamera`**. Mesh / import name: **`prop_security_camera_01`**.

Visibility: show when cameras are **owned**; hide otherwise. No GDScript in this Art PR. Do **not** invent buy/install/economy verbs here.

### Ceiling (Medium / Large)

Ceiling underside is **~2.80 m** (`prop_shop_shell_medium_01` / `prop_shop_shell_large_01`). Hang the mount on that plane — same band as overhead-light mounts (~2.78–2.79).

| Spot | Suggested node (m) | Yaw | Notes |
|------|--------------------|-----|-------|
| Medium entrance | `(6.30, 2.80, −1.80)` | **180°** | Look into the shop (**−Z**) |
| Medium case aisle | `(4.50, 2.80, −4.20)` | **180°** | Covers display-case run |
| Large extra (optional) | `(10.40, 2.80, −8.40)` | **180°** | Deep aisle; Large only |

Small shell is pre-unlock / stay-small — Eng decides whether a cam instance exists there. Art does not add Small wiring.

Keep clear of `prop_light_overhead_01` AABBs (lights are ~0.90 m long). Do not move Small overhead-light nodes to “make room.”

### Wall

On a wall that faces **+Z** into the room: **Y = 180°**, then **X = −90°**. The plate sits on the wall, the body hangs into the room, and the lens looks down. Origin stays on the wall surface. Extra yaw if the wall faces another axis.

Suggested height **Y = 2.35–2.50** (above head, still readable at interact). Example back-wall: `(6.30, 2.40, −8.95)` on Medium (wall at Z ≈ −9.0).

---

## 3. QA stills

Studio PBR rasters of the GLB (same bar as J2 / Large shell) — not an in-engine viewport.

| Shot | Path |
|------|------|
| Alone | `docs/art/qa-shots/CAM_security_alone.png` |
| Approach | `docs/art/qa-shots/CAM_security_approach.png` |
| Interact | `docs/art/qa-shots/CAM_security_interact.png` |
| Wall (optional) | `docs/art/qa-shots/CAM_security_wall.png` |

```
python3 tools/art/render_security_camera_qa_shots.py
```

---

## 4. Parked (not this PR)

- Soft catalog reopen (U1 **CLOSED**)
- Soft J2 far-crest polish (`prop_graded_case_badge_01`)
- Economy / Camera unlock verbs, cash/Attention gates, Theft shrink math
- Multi-cam, alarm, staff camera skill
- Wiring `shop_floor.tscn`
- Any GDScript
