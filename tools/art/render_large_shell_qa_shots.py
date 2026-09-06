#!/usr/bin/env python3
"""QA stills for the Large shop shell (far / approach / interact + vs Medium).

PBR raster of authored GLBs — same bar as J2 / Medium shell studio shots.
Not a Godot viewport.
"""

from __future__ import annotations

import math
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(Path(__file__).resolve().parent))

from pbr_glb import LoadedTri, load_glb_tris, xform_tris  # noqa: E402
from render_j2_qa_shots import add_ground, rasterize  # noqa: E402

FIXTURES = ROOT / "assets" / "props" / "shop" / "fixtures"
QA = ROOT / "docs" / "art" / "qa-shots"

LARGE = FIXTURES / "prop_shop_shell_large_01" / "prop_shop_shell_large_01.glb"
MEDIUM = FIXTURES / "prop_shop_shell_medium_01" / "prop_shop_shell_medium_01.glb"

def _dist(a, b) -> float:
    return math.sqrt(sum((a[i] - b[i]) ** 2 for i in range(3)))


def _mid(a, b) -> tuple[float, float, float]:
    return ((a[0] + b[0]) * 0.5, (a[1] + b[1]) * 0.5, (a[2] + b[2]) * 0.5)


def subdivide(tris: list[LoadedTri], max_edge: float = 2.2) -> list[LoadedTri]:
    """Split long faces so an interior camera does not discard whole slabs."""
    out: list[LoadedTri] = []
    stack = list(tris)
    while stack:
        t = stack.pop()
        edges = (
            (_dist(t.v0, t.v1), t.v0, t.v1, t.v2, t.n0, t.n1, t.n2),
            (_dist(t.v1, t.v2), t.v1, t.v2, t.v0, t.n1, t.n2, t.n0),
            (_dist(t.v2, t.v0), t.v2, t.v0, t.v1, t.n2, t.n0, t.n1),
        )
        longest = max(edges, key=lambda e: e[0])
        if longest[0] <= max_edge:
            out.append(t)
            continue
        _, a, b, c, na, nb, nc = longest
        m = _mid(a, b)
        nm = ((na[0] + nb[0]) * 0.5, (na[1] + nb[1]) * 0.5, (na[2] + nb[2]) * 0.5)
        stack.append(
            LoadedTri(a, m, c, na, nm, nc, t.color, t.metallic, t.roughness, t.alpha, t.transmission)
        )
        stack.append(
            LoadedTri(m, b, c, nm, nb, nc, t.color, t.metallic, t.roughness, t.alpha, t.transmission)
        )
    return out


def main() -> None:
    QA.mkdir(parents=True, exist_ok=True)
    shell, meta = load_glb_tris(LARGE)
    assert "Floor" in meta["materials"]
    assert "fog" not in " ".join(meta["materials"]).lower()
    shell = subdivide(shell)

    scene = []
    add_ground(scene, 22.0)
    scene.extend(shell)

    shots = (
        (
            "SHELL_large_far.png",
            (20.4, 6.4, 10.6),
            (7.6, 1.05, -4.8),
            36,
            "Large shell  18x13 @ 0.9 m  16.2 x 11.7 m  ~2040 sq ft  far",
        ),
        (
            "SHELL_large_approach.png",
            (8.10, 1.62, 7.40),
            (8.10, 1.28, 0.02),
            30,
            "Large shell  south facade + 1.0 x 2.10 door  approach",
        ),
        (
            "SHELL_large_interact.png",
            (3.55, 1.62, -1.85),
            (9.40, 1.05, -9.20),
            52,
            "Large shell  interior aisle  cream + wood  interact",
        ),
    )
    for name, eye, target, fov, cap in shots:
        img = rasterize(scene, eye, target, fov=fov, caption=cap)
        dest = QA / name
        img.save(dest, "PNG")
        print("wrote", dest)

    medium, _ = load_glb_tris(MEDIUM)
    medium = subdivide(medium)
    combo = []
    add_ground(combo, 28.0)
    combo.extend(xform_tris(medium, (0.0, 0.0, 0.0)))
    combo.extend(xform_tris(shell, (14.8, 0.0, 0.0)))
    img = rasterize(
        combo,
        (22.8, 7.2, 14.8),
        (13.6, 1.05, -4.6),
        fov=34,
        caption="Medium 14x10 (left) vs Large 18x13 (right)  same SW pivot / palette",
    )
    dest = QA / "SHELL_medium_vs_large.png"
    img.save(dest, "PNG")
    print("wrote", dest)


if __name__ == "__main__":
    main()
