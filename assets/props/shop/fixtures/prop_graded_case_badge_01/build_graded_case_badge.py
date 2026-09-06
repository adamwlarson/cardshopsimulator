#!/usr/bin/env python3
"""Procedural build for prop_graded_case_badge_01 (J2 + X1 far-crest polish).

Additive crest/plaque that parents to prop_display_case_slab_01 front.
X1: taller/fatter diamond + stronger brass/gunmetal value so the graded
path reads at shop-camera 8–12 m. Soft bevels. Placeholder bars only.
No readable IP / grader marks / text. Same node + GLB path (Eng no-op swap).
"""

from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
sys.path.insert(0, str(ROOT / "tools" / "art"))

from pbr_glb import MeshBuilder, PbrMaterial, write_build_stats  # noqa: E402

OUT = Path(__file__).resolve().parent
NODE = "prop_graded_case_badge_01"
BEVEL = 0.0018
# Parent local on slab case — lid is 1.12 m; diamond pokes above in −Z (aisle).
PARENT_LOCAL = (0.0, 1.06, -0.452)


def build() -> MeshBuilder:
    mesh = MeshBuilder()
    # X1: darker gunmetal rim / brighter brass face so values separate from oak.
    mesh.add_material(
        PbrMaterial("Metal", (0.34, 0.35, 0.38, 1.0), metallic=0.84, roughness=0.36)
    )
    mesh.add_material(
        PbrMaterial("Metal_Slab", (0.18, 0.19, 0.22, 1.0), metallic=0.88, roughness=0.28)
    )
    mesh.add_material(
        PbrMaterial("Plaque", (0.94, 0.74, 0.26, 1.0), metallic=0.58, roughness=0.26)
    )
    mesh.add_material(
        PbrMaterial("Felt", (0.12, 0.03, 0.055, 1.0), metallic=0.0, roughness=0.93)
    )
    mesh.add_material(
        PbrMaterial("Paper", (0.94, 0.90, 0.80, 1.0), metallic=0.0, roughness=0.70)
    )

    # Pivot = BACK-CENTER of the mount plate. Body extends −Z so it sits on the
    # slab-case customer face (−Z) at local (0, 1.06, −0.452) with no extra yaw.
    # X1 header is taller than J2 so the bar still reads at 8–12 m; diamond is
    # a fatter kite that clears the 1.12 m lid without a parent Y bump.

    # Gunmetal backer — wide + tall bar for far aisle read
    mesh.add_box("Metal_Slab", -0.290, -0.050, -0.012, 0.290, 0.050, 0.000, bevel=BEVEL)
    # Soft brass plaque face (brighter, slightly thicker)
    mesh.add_box("Plaque", -0.274, -0.040, -0.026, 0.274, 0.040, -0.010, bevel=BEVEL)

    # Corner studs
    for sx in (-0.256, 0.256):
        mesh.add_box("Metal", sx - 0.010, -0.010, -0.030, sx + 0.010, 0.010, -0.024)

    # Placeholder bars on the plaque (no letters) — thicker than J2 so they
    # survive downsampling at shop-camera distance.
    for y0, y1, xw in ((-0.022, -0.010, 0.086), (0.010, 0.022, 0.064)):
        mesh.add_box("Paper", -0.254, y0, -0.0276, -0.254 + xw, y1, -0.0252)
        mesh.add_box("Paper", 0.254 - xw, y0, -0.0276, 0.254, y1, -0.0252)

    # Center diamond — geometric, not a grading-house mark.
    # Outer is BRIGHT brass so the kite pops against oak/wall at 8–12 m
    # (J2 used a dark gunmetal outer that collapsed to a few dark pixels).
    # Inner gunmetal ring + burgundy enamel keep the close-up nested read.
    # J2 kite was 0.156 × 0.260 m; X1 is ~0.39 × 0.57 m, proud of the lid.
    outer = [
        (0.00, 0.420),
        (0.195, 0.038),
        (0.00, -0.150),
        (-0.195, 0.038),
    ]
    mesh.add_extruded_polygon("Plaque", outer, -0.046, -0.008)
    # Smaller gunmetal window → thicker brass rim so gold is the far-read mass.
    inner = [
        (0.00, 0.275),
        (0.088, 0.038),
        (0.00, -0.068),
        (-0.088, 0.038),
    ]
    mesh.add_extruded_polygon("Metal_Slab", inner, -0.050, -0.040)
    enamel = [
        (0.00, 0.195),
        (0.055, 0.038),
        (0.00, -0.032),
        (-0.055, 0.038),
    ]
    mesh.add_extruded_polygon("Felt", enamel, -0.0520, -0.0470)

    # Inner pip (shape only — no glyph)
    pip = [
        (0.00, 0.070),
        (0.024, 0.030),
        (0.00, -0.006),
        (-0.024, 0.030),
    ]
    mesh.add_extruded_polygon("Paper", pip, -0.0540, -0.0508)
    return mesh


def main() -> None:
    mesh = build()
    stats = mesh.stats()
    glb = OUT / f"{NODE}.glb"
    mesh.write_glb(glb, NODE, "CSS J2/X1 art pipeline (glTF 2.0, Principled/PBR)")
    write_build_stats(
        OUT / "_build_stats.txt",
        stats,
        extra=(
            "pivot=back_center_mount",
            "face=-Z",
            "parent=prop_display_case_slab_01",
            f"suggested_local={PARENT_LOCAL[0]},{PARENT_LOCAL[1]},{PARENT_LOCAL[2]}",
            "variant=graded_showcase_badge",
            "polish=X1_far_crest",
            "parent_y_bump=none",
        ),
    )
    print(f"wrote {glb}  tris={stats['tris']}  verts={stats['verts']}")
    print(
        "extents "
        f"{stats['width']:.3f} x {stats['depth']:.3f} x {stats['height']:.3f}"
    )


if __name__ == "__main__":
    main()
