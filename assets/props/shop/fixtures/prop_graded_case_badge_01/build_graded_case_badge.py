#!/usr/bin/env python3
"""Procedural build for prop_graded_case_badge_01 (J2 Art).

Thin additive crest/plaque that parents to prop_display_case_slab_01 front.
Soft brass + gunmetal + muted burgundy enamel. Placeholder bars only.
No readable IP / grader marks / text.
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


def build() -> MeshBuilder:
    mesh = MeshBuilder()
    mesh.add_material(
        PbrMaterial("Metal", (0.50, 0.51, 0.53, 1.0), metallic=0.78, roughness=0.40)
    )
    mesh.add_material(
        PbrMaterial("Metal_Slab", (0.42, 0.43, 0.46, 1.0), metallic=0.82, roughness=0.35)
    )
    mesh.add_material(
        PbrMaterial("Plaque", (0.80, 0.64, 0.36, 1.0), metallic=0.52, roughness=0.34)
    )
    mesh.add_material(
        PbrMaterial("Felt", (0.16, 0.04, 0.07, 1.0), metallic=0.0, roughness=0.93)
    )
    mesh.add_material(
        PbrMaterial("Paper", (0.90, 0.86, 0.78, 1.0), metallic=0.0, roughness=0.72)
    )

    # Pivot = BACK-CENTER of the mount plate. Body extends −Z so it sits on the
    # slab-case customer face (−Z) at local (0, 1.06, −0.452) with no extra yaw.
    # Wide bar for far-read; center diamond pokes above the 1.12 m slab lid.

    # Gunmetal backer / rim — wide bar for far aisle read
    mesh.add_box("Metal_Slab", -0.260, -0.036, -0.008, 0.260, 0.036, 0.000, bevel=BEVEL)
    # Soft brass plaque face
    mesh.add_box("Plaque", -0.246, -0.028, -0.016, 0.246, 0.028, -0.007, bevel=BEVEL)

    # Corner studs
    for sx in (-0.232, 0.232):
        mesh.add_box("Metal", sx - 0.007, -0.007, -0.018, sx + 0.007, 0.007, -0.014)

    # Placeholder bars on the plaque (no letters)
    for y0, y1, xw in ((-0.014, -0.007, 0.070), (0.007, 0.014, 0.052)):
        mesh.add_box("Paper", -0.228, y0, -0.0172, -0.228 + xw, y1, -0.0156)
        mesh.add_box("Paper", 0.228 - xw, y0, -0.0172, 0.228, y1, -0.0156)

    # Center diamond crest — geometric, not a grading-house mark
    outer = [
        (0.00, 0.168),
        (0.078, 0.016),
        (0.00, -0.092),
        (-0.078, 0.016),
    ]
    mesh.add_extruded_polygon("Metal_Slab", outer, -0.020, -0.004)
    inner = [
        (0.00, 0.140),
        (0.058, 0.016),
        (0.00, -0.068),
        (-0.058, 0.016),
    ]
    mesh.add_extruded_polygon("Plaque", inner, -0.022, -0.018)
    enamel = [
        (0.00, 0.108),
        (0.038, 0.016),
        (0.00, -0.042),
        (-0.038, 0.016),
    ]
    mesh.add_extruded_polygon("Felt", enamel, -0.0232, -0.0212)

    # Tiny inner pip (shape only)
    pip = [
        (0.00, 0.028),
        (0.010, 0.012),
        (0.00, -0.004),
        (-0.010, 0.012),
    ]
    mesh.add_extruded_polygon("Paper", pip, -0.0240, -0.0228)
    return mesh


def main() -> None:
    mesh = build()
    stats = mesh.stats()
    glb = OUT / f"{NODE}.glb"
    mesh.write_glb(glb, NODE, "CSS J2 art pipeline (glTF 2.0, Principled/PBR)")
    write_build_stats(
        OUT / "_build_stats.txt",
        stats,
        extra=(
            "pivot=back_center_mount",
            "face=-Z",
            "parent=prop_display_case_slab_01",
            "suggested_local=0.0,1.06,-0.452",
            "variant=graded_showcase_badge",
        ),
    )
    print(f"wrote {glb}  tris={stats['tris']}  verts={stats['verts']}")
    print(
        "extents "
        f"{stats['width']:.3f} x {stats['depth']:.3f} x {stats['height']:.3f}"
    )


if __name__ == "__main__":
    main()
