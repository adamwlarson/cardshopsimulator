#!/usr/bin/env python3
"""Procedural build for prop_online_hold_tag_01 (J2 Art).

Shelf-edge / case-lip clip matching prop_price_tag_01 scale + pivot.
Accent_Amber header (sell-icon lock) so it is distinct from teal talkers.
Placeholder bars / diamond only — no readable SKU/IP text.
"""

from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
sys.path.insert(0, str(ROOT / "tools" / "art"))

from pbr_glb import MeshBuilder, PbrMaterial, write_build_stats  # noqa: E402

OUT = Path(__file__).resolve().parent
NODE = "prop_online_hold_tag_01"
BEVEL = 0.0012  # ~1.2 mm

# Accent_Amber lock (H7 / sell icon): 0.82, 0.52, 0.18
AMBER = (0.82, 0.52, 0.18, 1.0)


def build() -> MeshBuilder:
    mesh = MeshBuilder()
    mesh.add_material(
        PbrMaterial("Metal", (0.48, 0.49, 0.51, 1.0), metallic=0.75, roughness=0.42)
    )
    mesh.add_material(
        PbrMaterial("Plastic", (0.90, 0.91, 0.92, 1.0), metallic=0.0, roughness=0.38)
    )
    mesh.add_material(
        PbrMaterial("Paper", (0.94, 0.93, 0.90, 1.0), metallic=0.0, roughness=0.70)
    )
    mesh.add_material(PbrMaterial("Accent_Amber", AMBER, metallic=0.0, roughness=0.48))

    # Pivot = CLIP / MOUNT TOP-BACK. Tag hangs −Y; face +Z (aisle when unrotated
    # on a back-wall fixture). Matches prop_price_tag_01.
    # Clip: small gunmetal U that bites the shelf lip at the origin.
    mesh.add_box("Metal", -0.014, -0.002, -0.001, 0.014, 0.0015, 0.010)
    mesh.add_box("Metal", -0.014, -0.004, -0.001, 0.014, 0.0005, 0.0012)

    # Card body — 0.08 × 0.02 × 0.05 class (soft bevel on the readable mass)
    mesh.add_box("Plastic", -0.040, -0.050, 0.0010, 0.040, -0.002, 0.0185, bevel=BEVEL)

    # Matte paper face (inset, no text)
    mesh.add_box("Paper", -0.036, -0.046, 0.0182, 0.036, -0.016, 0.0196)

    # Amber header — thicker than teal price-tag strip so far/approach reads
    mesh.add_box("Accent_Amber", -0.036, -0.0155, 0.0182, 0.036, -0.0035, 0.0200)

    # Diamond pip in the header (shape cue, not a letter)
    diamond = [
        (0.0, -0.0048),
        (0.0065, -0.0095),
        (0.0, -0.0142),
        (-0.0065, -0.0095),
    ]
    mesh.add_extruded_polygon("Paper", diamond, 0.0194, 0.0208)

    # Placeholder value bars (no SKU / price glyphs)
    mesh.add_box("Plastic", -0.022, -0.028, 0.0194, 0.022, -0.024, 0.0204)
    mesh.add_box("Plastic", -0.016, -0.036, 0.0194, 0.016, -0.032, 0.0204)
    mesh.add_box("Plastic", -0.010, -0.043, 0.0194, 0.010, -0.040, 0.0204)
    return mesh


def main() -> None:
    mesh = build()
    stats = mesh.stats()
    if stats["tris"] > 200:
        raise SystemExit(f"tris budget 200 exceeded: {stats['tris']}")
    glb = OUT / f"{NODE}.glb"
    mesh.write_glb(glb, NODE, "CSS J2 art pipeline (glTF 2.0, Principled/PBR)")
    write_build_stats(
        OUT / "_build_stats.txt",
        stats,
        extra=(
            "pivot=clip_mount_top_back",
            "face=+Z",
            "hang=-Y",
            "class=0.08x0.02x0.05",
            "accent=Accent_Amber",
            "variant=online_hold",
        ),
    )
    print(f"wrote {glb}  tris={stats['tris']}  verts={stats['verts']}")
    print(
        "extents "
        f"{stats['width']:.3f} x {stats['depth']:.3f} x {stats['height']:.3f}"
    )


if __name__ == "__main__":
    main()
