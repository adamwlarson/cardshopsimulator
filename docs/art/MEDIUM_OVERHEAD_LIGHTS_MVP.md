# Medium Overhead Lights — Densify MVP (SoT)

**Asset:** `prop_light_overhead_01` (existing GLB — no new mesh unless broken)  
**Shell:** Medium 14×10 tiles → interior floor **12.6 × 9.0 m**, ceiling ~**2.80 m**  
**Audience:** Eng (tier wiring) + Art Lead (layout SoT)  
**Rule of thumb:** Small layout is **locked**. Medium adds extras; never move/rename Small nodes.

---

## 1. Small layout — KEEP (SoT — do not change)

From main `shop_floor` `Fixtures/OverheadLights`. These five mesh instances + matching Omni fills stay for **Small** and remain the base set when Medium is active (Medium only **adds**).

| Node | Position (shell / Godot, m) |
|------|-----------------------------|
| FrontLeft | (2.25, 2.79, -2.25) |
| FrontRight | (6.75, 2.79, -2.25) |
| BackLeft | (2.25, 2.79, -4.95) |
| BackRight | (6.75, 2.79, -4.95) |
| BackLeftAisle | (2.8, 2.78, -5.4) |

### Companion OmniFill (Small — match lighting-amp)

Per overhead mesh, pair an `OmniLight3D` at the **same XZ**, **Y = 2.55**:

| Field | Value |
|-------|-------|
| Color | `(1.0, 0.83, 0.66)` (~3600K practical warm) |
| Energy | **1.65** |
| Range | **7.0** |
| Attenuation | **1.2** |
| Shadows | off (MVP) |

Mesh emission stays per `prop_light_overhead_01` IMPORT_NOTES (emission RGB ~(1.0, 0.82, 0.62), strength 9.0). Omni RGB tracks that band — alive fill, not white blow-out.

---

## 2. Medium densify — ADD (NEW — Eng places when `tier=MEDIUM`)

Extra instances of the **same** `prop_light_overhead_01` GLB + matching Omni fills. Mount Y ≈ **2.78–2.79** (under ceiling ~2.8).

| Node | Position (shell / Godot, m) |
|------|-----------------------------|
| MidCenter | (5.40, 2.79, -4.95) |
| FarFront | (10.35, 2.79, -2.25) |
| FarBack | (10.35, 2.79, -4.95) |
| DeepLeft | (2.25, 2.79, -7.20) |
| DeepCenter | (6.30, 2.79, -7.20) |
| DeepRight | (10.35, 2.79, -7.20) |

### Companion OmniFill (Medium extras)

Same recipe as Small: Omni at `(x, 2.55, z)`, color `(1, 0.83, 0.66)`, energy **1.65**, range **7**, atten **1.2**.

### Coverage rationale

Rough **3×3-ish** practical coverage over the Medium **12.6 × 9.0** floor:

- Rows (depth −Z): front ≈ −2.25 · mid ≈ −4.95 · deep ≈ −7.20  
- Columns (X): left ≈ 2.25 · mid-aisle MidCenter ≈ 5.40 · deep-center ≈ 6.30 · right/far ≈ 10.35  
- Small’s **2×2 + aisle** remains the Small-tier set; Medium only lights the wider/deeper volume.


### Soft MidCenter AABB polish (post #27)
- **Was:** MidCenter `(6.30, 2.79, -4.95)` — only **0.45 m** from Small `BackRight` `(6.75, 2.79, -4.95)`.
- Overhead mesh AABB length ≈ **0.90 m** → instances overlapped in X when coplanar.
- **Now:** MidCenter **`(5.40, 2.79, -4.95)`** — **1.35 m** from BackRight (clear AABB); still fills the mid-depth aisle between left (2.25) and Small right (6.75).
- OmniFill follows at `(5.40, 2.55, -4.95)`. Same GLB / fog nack / tier gate.
- DeepCenter stays at X=6.30 on the deep row (no Small neighbor on that Z).

**Medium total meshes when tier=MEDIUM:** Small 5 + Medium 6 = **11** overhead instances (plus 11 Omni fills).

---

## 3. Eng rules

1. **Hide/show Medium extras with tier** — Medium nodes + their Omni fills visible only when shop tier is `MEDIUM`. Small nodes always use the Small SoT positions above.
2. **Never move Small nodes** — do not translate/rename/rescale FrontLeft / FrontRight / BackLeft / BackRight / BackLeftAisle to “make room.” Additive only.
3. **Fog nack** — no volumetric fog / fog volumes for this densify beat.
4. **Reuse `prop_light_overhead_01`** — instance the existing GLB; **no new overhead GLB** unless the current hero is broken.
5. **Do not edit Art ownership of mesh** — Art owns GLB + this SoT; Eng owns `shop_floor.tscn` placement / tier gating (Art does not land those edits).
6. **Scale 1,1,1** — pivot is mount (top center); hang under ceiling, do not rescale heroes.

---

## 4. Companion Omni — lighting-amp notes (summary)

| Topic | Guidance |
|-------|----------|
| Kelvin feel | ~3600K practical warm |
| Mesh emission | See `art/props/prop_light_overhead_01/IMPORT_NOTES.md` |
| Omni color | `(1.0, 0.83, 0.66)` — match amp band |
| Omni energy | **1.65** (alive; avoid white blow-out; amp band was ~1.6–1.8) |
| Omni range / atten | **7.0** / **1.2** |
| Omni Y | **2.55** (slightly below mount so fill reads under diffuser) |
| Wood heroes | Do not mass-reexport; richer oak notes only if needed later |

---

## 5. QA shots (Art)

Densified Medium shell interior, lights lit:

| Shot | Path |
|------|------|
| Interact | `docs/art/qa-shots/LIGHTS_medium_densify_interact.png` |
| Approach | `docs/art/qa-shots/LIGHTS_medium_densify_approach.png` |

Mirrored under `art/qa-shots/` and `agent-data/.../docs/art/qa-shots/` when present.

Shell GLB: `art/props/prop_shop_shell_medium_01/prop_shop_shell_medium_01.glb`  
Light GLB: `art/props/prop_light_overhead_01/prop_light_overhead_01.glb`

---

## 6. Related

- `art/props/prop_light_overhead_01/IMPORT_NOTES.md` — mesh + lighting-amp + Medium densify pointer  
- `art/props/prop_shop_shell_medium_01/IMPORT_NOTES.md` — Medium shell extents / ceiling  
- `docs/art/VISUAL_DIRECTION_MVP.md` — A11 overhead language  
