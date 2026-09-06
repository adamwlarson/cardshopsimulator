#!/usr/bin/env python3
"""Shop-camera QA stills for X1 Soft far-crest polish (graded badge).

Renders the authored GLBs under warm key / cool fill (shop lighting language).
Not a Godot viewport — proof the X1 diamond reads at far / approach /
interact distances vs the J2-thin crest. Same parent pose as J2.
"""

from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(Path(__file__).resolve().parent))

from pbr_glb import load_glb_tris, xform_tris  # noqa: E402
from render_j2_qa_shots import add_back_wall, add_ground, glb, rasterize  # noqa: E402

QA = ROOT / "docs" / "art" / "qa-shots"

# J2 SoT parent — unchanged for X1 (no lid-clear Y bump).
BADGE_LOCAL = (1.05, 1.06, -0.452)


def _scene(slab_x: float = 1.05):
    """Default: J2 layout (base −X, slab+badge +X). Frontal +Z look flips X on screen."""
    base, _ = load_glb_tris(glb("prop_display_case_01"))
    slab, _ = load_glb_tris(glb("prop_display_case_slab_01"))
    badge, _ = load_glb_tris(glb("prop_graded_case_badge_01"))

    base_x = -slab_x
    base = xform_tris(base, (base_x, 0.0, 0.0))
    slab = xform_tris(slab, (slab_x, 0.0, 0.0))
    badge = xform_tris(badge, (slab_x, BADGE_LOCAL[1], BADGE_LOCAL[2]))

    scene = []
    add_ground(scene, 8.0)
    add_back_wall(scene, z=1.55)
    scene.extend(base)
    scene.extend(slab)
    scene.extend(badge)
    return scene


def main() -> None:
    QA.mkdir(parents=True, exist_ok=True)
    # Frontal +Z look has camera-right = −X, so put slab on −X to read as screen-right.
    frontal = _scene(slab_x=-1.05)
    three_q = _scene(slab_x=1.05)

    shots = (
        (
            frontal,
            "X1_graded_crest_far.png",
            (0.00, 1.62, -10.00),
            (0.00, 0.92, 0.00),
            "X1  base (L) vs slab+badge (R)   far ~10.0 m frontal   fov 70",
        ),
        (
            three_q,
            "X1_graded_crest_approach.png",
            (0.85, 1.52, -3.55),
            (0.10, 0.80, -0.10),
            "X1  base vs slab+badge   approach ~3.6 m   fov 70",
        ),
        (
            three_q,
            "X1_graded_crest_interact.png",
            (0.40, 1.38, -1.95),
            (0.20, 0.88, -0.20),
            "X1  base vs slab+badge   interact ~1.9 m   fov 70",
        ),
        (
            three_q,
            "X1_graded_crest_detail.png",
            (1.05, 1.22, -1.18),
            (1.05, 1.16, -0.47),
            "X1  graded crest   thicker diamond / brass vs gunmetal   bars only",
        ),
        (
            three_q,
            "X1_graded_crest_far_vs_base.png",
            (2.20, 1.78, -8.15),
            (0.15, 0.82, -0.10),
            "X1  base vs slab+badge   far ~8.2 m (J2 camera)   fov 70",
        ),
    )
    for scene, name, eye, target, cap in shots:
        img = rasterize(scene, eye, target, caption=cap)
        dest = QA / name
        img.save(dest, "PNG")
        print("wrote", dest)


if __name__ == "__main__":
    main()
