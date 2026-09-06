#!/usr/bin/env python3
"""Procedural build for prop_security_camera_01 (V1 Art dual-track).

Thin wall/ceiling security-camera fixture. Soft gunmetal + dark plastic +
smoked glass lens. Placeholder only — no brand logos / readable IP.
Pivot = MOUNT (ceiling/wall attach). Body hangs −Y; look bias +Z.
"""

from __future__ import annotations

import math
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
sys.path.insert(0, str(ROOT / "tools" / "art"))

from pbr_glb import (  # noqa: E402
    MeshBuilder,
    PbrMaterial,
    VEC3,
    _vadd,
    _vcross,
    _vmul,
    _vnorm,
    _vsub,
    write_build_stats,
)

OUT = Path(__file__).resolve().parent
NODE = "prop_security_camera_01"
BEVEL = 0.0016  # ~1.6 mm
SEGS = 8
TRIS_BUDGET = 400


def _frame(direction: VEC3) -> tuple[VEC3, VEC3, VEC3]:
    axis = _vnorm(direction)
    helper = (0.0, 1.0, 0.0) if abs(axis[1]) < 0.92 else (1.0, 0.0, 0.0)
    x = _vnorm(_vcross(helper, axis))
    y = _vcross(axis, x)
    return x, y, axis


def add_cylinder(
    mesh: MeshBuilder,
    material: str,
    p0: VEC3,
    p1: VEC3,
    radius: float,
    segs: int = SEGS,
    cap0: bool = True,
    cap1: bool = True,
) -> None:
    x, y, axis = _frame(_vsub(p1, p0))
    rings: list[list[VEC3]] = []
    for pole in (p0, p1):
        ring: list[VEC3] = []
        for i in range(segs):
            ang = 2.0 * math.pi * i / segs
            off = _vadd(_vmul(x, math.cos(ang) * radius), _vmul(y, math.sin(ang) * radius))
            ring.append(_vadd(pole, off))
        rings.append(ring)
    for i in range(segs):
        j = (i + 1) % segs
        mesh.add_quad(material, rings[0][i], rings[0][j], rings[1][j], rings[1][i])
    if cap0:
        for i in range(segs):
            j = (i + 1) % segs
            mesh.add_tri(material, p0, rings[0][j], rings[0][i], _vmul(axis, -1.0))
    if cap1:
        for i in range(segs):
            j = (i + 1) % segs
            mesh.add_tri(material, p1, rings[1][i], rings[1][j], axis)


def add_sphere(
    mesh: MeshBuilder,
    material: str,
    center: VEC3,
    radius: float,
    slices: int = SEGS,
    stacks: int = 4,
) -> None:
    def pt(st: int, sl: int) -> VEC3:
        v = math.pi * st / stacks
        u = 2.0 * math.pi * sl / slices
        return _vadd(
            center,
            (
                radius * math.sin(v) * math.cos(u),
                radius * math.cos(v),
                radius * math.sin(v) * math.sin(u),
            ),
        )

    for st in range(stacks):
        for sl in range(slices):
            sl2 = (sl + 1) % slices
            a = pt(st, sl)
            b = pt(st, sl2)
            c = pt(st + 1, sl2)
            d = pt(st + 1, sl)
            if st == 0:
                mesh.add_tri(material, a, c, d)
            elif st == stacks - 1:
                mesh.add_tri(material, a, b, d)
            else:
                mesh.add_quad(material, a, b, c, d)


def add_spherical_cap(
    mesh: MeshBuilder,
    material: str,
    center: VEC3,
    radius: float,
    normal: VEC3,
    cap_deg: float = 58.0,
    slices: int = SEGS,
    stacks: int = 3,
) -> None:
    """Shallow dome along +normal. Pole at center + radius * normal."""
    x, y, axis = _frame(normal)
    pole_ang = math.radians(cap_deg)
    rings: list[list[VEC3]] = []
    for st in range(stacks + 1):
        t = st / stacks
        v = pole_ang * t
        ring_r = radius * math.sin(v)
        along = radius * math.cos(v)
        origin = _vadd(center, _vmul(axis, along))
        ring: list[VEC3] = []
        for sl in range(slices):
            ang = 2.0 * math.pi * sl / slices
            off = _vadd(_vmul(x, math.cos(ang) * ring_r), _vmul(y, math.sin(ang) * ring_r))
            ring.append(_vadd(origin, off))
        rings.append(ring)
    pole = _vadd(center, _vmul(axis, radius))
    for sl in range(slices):
        sl2 = (sl + 1) % slices
        mesh.add_tri(material, pole, rings[1][sl], rings[1][sl2])
    for st in range(1, stacks):
        for sl in range(slices):
            sl2 = (sl + 1) % slices
            mesh.add_quad(
                material,
                rings[st][sl],
                rings[st][sl2],
                rings[st + 1][sl2],
                rings[st + 1][sl],
            )


def build() -> MeshBuilder:
    mesh = MeshBuilder()
    mesh.add_material(
        PbrMaterial("Metal", (0.46, 0.47, 0.50, 1.0), metallic=0.80, roughness=0.40)
    )
    mesh.add_material(
        PbrMaterial("Plastic", (0.16, 0.17, 0.19, 1.0), metallic=0.0, roughness=0.46)
    )
    mesh.add_material(
        PbrMaterial(
            "Glass",
            (0.10, 0.13, 0.16, 0.38),
            metallic=0.04,
            roughness=0.10,
            alpha_mode="BLEND",
            transmission=0.62,
        )
    )

    # Pivot = MOUNT. Plate top sits on Y=0 (ceiling/wall attach face).
    # Hang −Y. Authored look bias +Z with a downward tilt.
    add_cylinder(mesh, "Metal", (0.0, -0.0045, 0.0), (0.0, 0.0, 0.0), 0.040, cap0=True, cap1=True)

    # Four tiny mount pips (shape only — not fasteners with brands)
    for sx, sz in ((-0.018, -0.018), (0.018, -0.018), (-0.018, 0.018), (0.018, 0.018)):
        mesh.add_box("Metal", sx - 0.0032, -0.0058, sz - 0.0032, sx + 0.0032, -0.0038, sz + 0.0032)

    add_cylinder(mesh, "Metal", (0.0, -0.016, 0.0), (0.0, -0.0045, 0.0), 0.013, cap0=False, cap1=False)
    add_cylinder(mesh, "Metal", (0.0, -0.046, 0.0), (0.0, -0.016, 0.0), 0.0085, cap0=False, cap1=False)

    joint = (0.0, -0.054, 0.006)
    add_sphere(mesh, "Metal", joint, 0.014, slices=SEGS, stacks=4)

    # Body axis: ~32° down from +Z so the lens reads from the aisle.
    axis = _vnorm((0.0, -0.53, 0.85))
    body_center = (0.0, -0.100, 0.052)
    half_len = 0.058
    rear = _vadd(body_center, _vmul(axis, -half_len))
    front = _vadd(body_center, _vmul(axis, half_len))
    hood = _vadd(front, _vmul(axis, 0.011))
    lens_center = _vadd(front, _vmul(axis, -0.006))

    # Short arm from joint toward the body rear
    arm_dir = _vnorm(_vsub(rear, joint))
    arm_end = _vadd(joint, _vmul(arm_dir, 0.028))
    add_cylinder(mesh, "Metal", joint, arm_end, 0.0075, cap0=False, cap1=True)

    # Rear cap + plastic barrel + metal lens ring
    add_cylinder(
        mesh,
        "Metal",
        _vadd(rear, _vmul(axis, -0.008)),
        _vadd(rear, _vmul(axis, 0.010)),
        0.062,
        cap0=True,
        cap1=False,
    )
    add_cylinder(mesh, "Plastic", rear, front, 0.058, cap0=False, cap1=False)
    add_cylinder(mesh, "Metal", _vadd(front, _vmul(axis, -0.008)), hood, 0.056, cap0=False, cap1=True)

    add_spherical_cap(mesh, "Glass", lens_center, 0.046, axis, cap_deg=56.0, slices=SEGS, stacks=3)

    # Tiny status pip on the barrel (geometry only — no logo / glyph)
    pip_n = _vnorm(_vcross(axis, (1.0, 0.0, 0.0)))
    pip = _vadd(body_center, _vadd(_vmul(pip_n, 0.060), _vmul(axis, 0.012)))
    mesh.add_box(
        "Plastic",
        pip[0] - 0.004,
        pip[1] - 0.003,
        pip[2] - 0.004,
        pip[0] + 0.004,
        pip[1] + 0.003,
        pip[2] + 0.004,
        bevel=BEVEL * 0.4,
    )
    return mesh


def main() -> None:
    mesh = build()
    stats = mesh.stats()
    if int(stats["tris"]) > TRIS_BUDGET:
        raise SystemExit(f"tris budget {TRIS_BUDGET} exceeded: {stats['tris']}")
    body_span = max(float(stats["width"]), float(stats["height"]), float(stats["depth"]))
    if not (0.10 - 1e-6 <= body_span <= 0.22):
        raise SystemExit(f"body/fixture span {body_span:.3f} m outside 0.10–0.22 m class")
    # Mount face must include the origin (attach point).
    if abs(float(stats["max"][1])) > 1e-4:
        raise SystemExit(f"mount pivot must sit at Y=0, max_y={stats['max'][1]}")
    glb = OUT / f"{NODE}.glb"
    mesh.write_glb(glb, NODE, "CSS V1 art pipeline (glTF 2.0, Principled/PBR)")
    write_build_stats(
        OUT / "_build_stats.txt",
        stats,
        extra=(
            "pivot=mount_attach",
            "hang=-Y",
            "look=+Z",
            "class=dome_body_0.10-0.18",
            "variant=security_camera",
            "eng_node=SecurityCamera",
        ),
    )
    print(f"wrote {glb}  tris={stats['tris']}  verts={stats['verts']}")
    print(
        "extents "
        f"{stats['width']:.3f} x {stats['depth']:.3f} x {stats['height']:.3f}"
    )


if __name__ == "__main__":
    main()
