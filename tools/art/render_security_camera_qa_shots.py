#!/usr/bin/env python3
"""Shop-camera QA stills for prop_security_camera_01 (V1 Art dual-track).

Renders the authored GLB under warm key / cool fill (shop lighting language).
Not a Godot viewport — proof of silhouette + material read at alone /
approach / interact distances. Optional wall-mount still included.
"""

from __future__ import annotations

import math
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(Path(__file__).resolve().parent))

from pbr_glb import LoadedTri, load_glb_tris, xform_tris  # noqa: E402
from render_j2_qa_shots import add_back_wall, add_ground, rasterize  # noqa: E402
from render_large_shell_qa_shots import subdivide  # noqa: E402

FIXTURES = ROOT / "assets" / "props" / "shop" / "fixtures"
QA = ROOT / "docs" / "art" / "qa-shots"
CAM = FIXTURES / "prop_security_camera_01" / "prop_security_camera_01.glb"


def add_ceiling(
    tris: list[LoadedTri],
    y: float = 2.80,
    x0: float = 0.0,
    x1: float = 9.0,
    z0: float = -8.0,
    z1: float = 0.4,
) -> None:
    # Shade as if lit from below-aisle so the cream underside reads (studio cheat).
    n = (0.18, 0.88, 0.44)
    c = (0.90, 0.86, 0.78)
    q = ((x0, y, z0), (x1, y, z0), (x1, y, z1), (x0, y, z1))
    tris.append(LoadedTri(q[0], q[1], q[2], n, n, n, c, 0.0, 0.78, 1.0, 0.0))
    tris.append(LoadedTri(q[0], q[2], q[3], n, n, n, c, 0.0, 0.78, 1.0, 0.0))


def add_wood_wall(
    tris: list[LoadedTri],
    z: float = 0.0,
    x0: float = -1.4,
    x1: float = 1.4,
    y0: float = 0.0,
    y1: float = 2.80,
) -> None:
    n = (0.0, 0.0, 1.0)
    c = (0.52, 0.34, 0.17)
    q = ((x0, y0, z), (x1, y0, z), (x1, y1, z), (x0, y1, z))
    tris.append(LoadedTri(q[0], q[1], q[2], n, n, n, c, 0.0, 0.62, 1.0, 0.0))
    tris.append(LoadedTri(q[0], q[2], q[3], n, n, n, c, 0.0, 0.62, 1.0, 0.0))


def xform_yaw_pitch(
    tris: list[LoadedTri],
    translation=(0.0, 0.0, 0.0),
    yaw_deg: float = 0.0,
    pitch_deg: float = 0.0,
):
    """Yaw around +Y, then pitch around +X, then translate.

    Wall-mount on a +Z-facing wall: yaw 180° + pitch −90° hangs into +Z and looks down.
    """
    ys, yc = math.sin(math.radians(yaw_deg)), math.cos(math.radians(yaw_deg))
    ps, pc = math.sin(math.radians(pitch_deg)), math.cos(math.radians(pitch_deg))

    def rot(v):
        x, y, z = v
        x, z = x * yc - z * ys, x * ys + z * yc
        y, z = y * pc - z * ps, y * ps + z * pc
        return (x, y, z)

    tx, ty, tz = translation
    out: list[LoadedTri] = []
    for t in tris:
        def _p(p):
            r = rot(p)
            return (r[0] + tx, r[1] + ty, r[2] + tz)

        out.append(
            LoadedTri(
                _p(t.v0),
                _p(t.v1),
                _p(t.v2),
                rot(t.n0),
                rot(t.n1),
                rot(t.n2),
                t.color,
                t.metallic,
                t.roughness,
                t.alpha,
                t.transmission,
            )
        )
    return out


def main() -> None:
    QA.mkdir(parents=True, exist_ok=True)
    cam, meta = load_glb_tris(CAM)
    assert "Metal" in meta["materials"]
    assert "Plastic" in meta["materials"]
    assert "Glass" in meta["materials"]
    assert "prop_security_camera_01" in meta["nodes"]

    def add_oak_case(tris: list[LoadedTri], origin=(4.50, 0.0, -5.55)) -> None:
        """Simple 1.8×0.9×1.05 oak mass for scale (not the hero case)."""
        ox, oy, oz = origin
        x0, x1 = ox - 0.90, ox + 0.90
        y0, y1 = oy, oy + 1.05
        z0, z1 = oz - 0.45, oz + 0.45
        wood = (0.52, 0.34, 0.17)
        faces = (
            ((x0, y0, z1), (x1, y0, z1), (x1, y1, z1), (x0, y1, z1), (0, 0, 1)),
            ((x1, y0, z0), (x0, y0, z0), (x0, y1, z0), (x1, y1, z0), (0, 0, -1)),
            ((x0, y0, z0), (x0, y0, z1), (x0, y1, z1), (x0, y1, z0), (-1, 0, 0)),
            ((x1, y0, z1), (x1, y0, z0), (x1, y1, z0), (x1, y1, z1), (1, 0, 0)),
            ((x0, y1, z1), (x1, y1, z1), (x1, y1, z0), (x0, y1, z0), (0, 1, 0)),
        )
        for a, b, c, d, n in faces:
            tris.append(LoadedTri(a, b, c, n, n, n, wood, 0.0, 0.62, 1.0, 0.0))
            tris.append(LoadedTri(a, c, d, n, n, n, wood, 0.0, 0.62, 1.0, 0.0))

    # --- Alone: studio, hanging from a small ceiling patch ---
    alone: list[LoadedTri] = []
    add_ground(alone, 0.55)
    add_ceiling(alone, y=0.0, x0=-0.28, x1=0.28, z0=-0.28, z1=0.28)
    add_back_wall(alone, z=-0.22, half=0.40, h=0.08)
    alone.extend(cam)
    img = rasterize(
        alone,
        (0.16, -0.10, 0.24),
        (0.00, -0.08, 0.04),
        fov=42.0,
        caption="V1  prop_security_camera_01  alone  mount pivot  look +Z",
    )
    dest = QA / "CAM_security_alone.png"
    img.save(dest, "PNG")
    print("wrote", dest)

    # --- Ceiling in a Medium-ish bay (approach + interact) ---
    # Case-aisle mount; yaw 0 so authored +Z look faces the approaching player.
    cam_pos = (4.50, 2.80, -4.20)
    scene: list[LoadedTri] = []
    add_ground(scene, 8.0)
    add_back_wall(scene, z=-7.15, half=8.0, h=2.82)
    add_ceiling(scene, y=2.80, x0=1.4, x1=8.2, z0=-7.4, z1=0.15)
    add_oak_case(scene, (4.50, 0.0, -5.55))
    scene.extend(xform_tris(cam, cam_pos, yaw_deg=0.0))
    scene = subdivide(scene, max_edge=1.15)

    shots = (
        (
            "CAM_security_approach.png",
            (3.70, 1.42, -1.85),
            (4.50, 2.45, -4.35),
            44.0,
            "V1  security camera  ceiling Medium aisle  approach ~2.7 m",
        ),
        (
            "CAM_security_interact.png",
            (4.75, 1.70, -2.85),
            (4.50, 2.64, -4.08),
            40.0,
            "V1  security camera  ceiling Medium aisle  interact ~1.4 m",
        ),
    )
    for name, eye, target, fov, cap in shots:
        img = rasterize(scene, eye, target, fov=fov, caption=cap)
        dest = QA / name
        img.save(dest, "PNG")
        print("wrote", dest)

    # --- Optional wall mount ---
    wall: list[LoadedTri] = []
    add_ground(wall, 3.2)
    add_wood_wall(wall, z=0.0, x0=-1.6, x1=1.6, y0=0.0, y1=2.80)
    add_ceiling(wall, y=2.80, x0=-1.8, x1=1.8, z0=0.0, z1=2.4)
    wall.extend(xform_yaw_pitch(cam, (0.0, 2.40, 0.0), yaw_deg=180.0, pitch_deg=-90.0))
    wall = subdivide(wall, max_edge=1.15)
    img = rasterize(
        wall,
        (0.55, 1.85, 1.45),
        (0.00, 2.22, 0.12),
        fov=44.0,
        caption="V1  security camera  wall mount  Y=180 X=-90  Y=2.40  optional",
    )
    dest = QA / "CAM_security_wall.png"
    img.save(dest, "PNG")
    print("wrote", dest)


if __name__ == "__main__":
    main()
