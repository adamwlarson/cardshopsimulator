#!/usr/bin/env python3
"""Procedural shop-shell builder — size-flag language (Small / Medium / Large).

Same shell language as the Blender 4.3 Small/Medium heroes:
  --size=small|medium|large   (or CSS_SHELL_SIZE)

Large is the authored hero for this package. Small/Medium flags exist so Art
does not invent a second shell language; they write sibling folders and do
**not** overwrite the locked Blender GLBs unless --force is passed.

1u=1m, +Y up, Principled/PBR. Soft bevel ~3 mm. No cel/ink. No fog mesh.
Pivot = FLOOR SOUTHWEST CORNER at (0,0,0); floor top at Y=0; interior −Z.
"""

from __future__ import annotations

import argparse
import os
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
sys.path.insert(0, str(ROOT / "tools" / "art"))

from pbr_glb import MeshBuilder, PbrMaterial, write_build_stats  # noqa: E402

TILE_M = 0.9
WALL_H = 2.80
FLOOR_T = 0.04
CEIL_T = 0.03
WALL_T = 0.12
BEVEL = 0.003  # 3 mm — matches Small/Medium
DOOR_W = 1.00
DOOR_H = 2.10
BASE_H = 0.10
TRIM_D = 0.02
CROWN_H = 0.07
FRAME_T = 0.04
FRAME_Z0 = -0.01
FRAME_Z1 = 0.13
# South baseboard stops 20 mm before the left jamb and starts 10 mm after the
# right jamb — same slight asymmetry as the Medium hero.
SOUTH_TRIM_LEFT_GAP = 0.02
SOUTH_TRIM_RIGHT_GAP = 0.01

# Exact Small/Medium palette (art-medium-shell-spotcheck + hero GLBs).
MATS = {
    "Floor": ((0.42, 0.43, 0.45, 1.0), 0.0, 0.55),
    "Wall": ((0.78, 0.74, 0.68, 1.0), 0.0, 0.72),
    "TrimMetal": ((0.48, 0.49, 0.51, 1.0), 0.78, 0.40),
    "Trim": ((0.46, 0.30, 0.16, 1.0), 0.0, 0.58),
    "Ceiling": ((0.82, 0.80, 0.76, 1.0), 0.0, 0.78),
}

SIZES = {
    "small": {
        "tiles": (10, 8),
        "node": "prop_shop_shell_01",
        "folder": "prop_shop_shell_01",
    },
    "medium": {
        "tiles": (14, 10),
        "node": "prop_shop_shell_medium_01",
        "folder": "prop_shop_shell_medium_01",
    },
    "large": {
        "tiles": (18, 13),
        "node": "prop_shop_shell_large_01",
        "folder": "prop_shop_shell_large_01",
    },
}

LOCKED_BLENDER_SIZES = frozenset({"small", "medium"})


def _sq_ft(floor_w: float, floor_d: float) -> float:
    return floor_w * floor_d * 10.76391041671


def build_shell(size: str) -> tuple[MeshBuilder, dict]:
    spec = SIZES[size]
    tiles_x, tiles_z = spec["tiles"]
    floor_w = tiles_x * TILE_M
    floor_d = tiles_z * TILE_M
    door_l = (floor_w - DOOR_W) * 0.5
    door_r = door_l + DOOR_W

    mesh = MeshBuilder()
    for name, (color, metallic, roughness) in MATS.items():
        mesh.add_material(PbrMaterial(name, color, metallic=metallic, roughness=roughness))

    # Floor slab — top at Y=0, SW corner at (0,0,0), interior −Z.
    mesh.add_box("Floor", 0.0, -FLOOR_T, -floor_d, floor_w, 0.0, 0.0, bevel=BEVEL)

    # Ceiling covers wall outer AABB (same as Medium).
    mesh.add_box(
        "Ceiling",
        -WALL_T,
        WALL_H,
        -floor_d - WALL_T,
        floor_w + WALL_T,
        WALL_H + CEIL_T,
        WALL_T,
        bevel=BEVEL,
    )

    # West / east span full depth including wall thickness (owns corners).
    mesh.add_box(
        "Wall",
        -WALL_T,
        0.0,
        -floor_d - WALL_T,
        0.0,
        WALL_H,
        WALL_T,
        bevel=BEVEL,
    )
    mesh.add_box(
        "Wall",
        floor_w,
        0.0,
        -floor_d - WALL_T,
        floor_w + WALL_T,
        WALL_H,
        WALL_T,
        bevel=BEVEL,
    )
    # North (back)
    mesh.add_box(
        "Wall",
        0.0,
        0.0,
        -floor_d - WALL_T,
        floor_w,
        WALL_H,
        -floor_d,
        bevel=BEVEL,
    )
    # South (front) with centered 1.0 × 2.10 door cutout
    mesh.add_box("Wall", 0.0, 0.0, 0.0, door_l, WALL_H, WALL_T, bevel=BEVEL)
    mesh.add_box("Wall", door_r, 0.0, 0.0, floor_w, WALL_H, WALL_T, bevel=BEVEL)
    mesh.add_box("Wall", door_l, DOOR_H, 0.0, door_r, WALL_H, WALL_T, bevel=BEVEL)

    # Soft gunmetal door frame (same extents language as Medium).
    mesh.add_box(
        "TrimMetal",
        door_l - FRAME_T,
        0.0,
        FRAME_Z0,
        door_l,
        DOOR_H + FRAME_T,
        FRAME_Z1,
        bevel=BEVEL,
    )
    mesh.add_box(
        "TrimMetal",
        door_r,
        0.0,
        FRAME_Z0,
        door_r + FRAME_T,
        DOOR_H + FRAME_T,
        FRAME_Z1,
        bevel=BEVEL,
    )
    mesh.add_box(
        "TrimMetal",
        door_l - FRAME_T,
        DOOR_H,
        FRAME_Z0,
        door_r + FRAME_T,
        DOOR_H + FRAME_T,
        FRAME_Z1,
        bevel=BEVEL,
    )

    def _base(x0: float, z0: float, x1: float, z1: float) -> None:
        mesh.add_box("Trim", x0, 0.0, z0, x1, BASE_H, z1, bevel=BEVEL)

    def _crown(x0: float, z0: float, x1: float, z1: float) -> None:
        mesh.add_box("Trim", x0, WALL_H - CROWN_H, z0, x1, WALL_H, z1, bevel=BEVEL)

    # Interior wood base + crown (0.02 m deep). South interrupted by door.
    _base(0.0, -floor_d, TRIM_D, 0.0)
    _base(floor_w - TRIM_D, -floor_d, floor_w, 0.0)
    _base(TRIM_D, -floor_d, floor_w - TRIM_D, -floor_d + TRIM_D)
    _base(TRIM_D, -TRIM_D, door_l - SOUTH_TRIM_LEFT_GAP, 0.0)
    _base(door_r + SOUTH_TRIM_RIGHT_GAP, -TRIM_D, floor_w - TRIM_D, 0.0)

    _crown(0.0, -floor_d, TRIM_D, 0.0)
    _crown(floor_w - TRIM_D, -floor_d, floor_w, 0.0)
    _crown(TRIM_D, -floor_d, floor_w - TRIM_D, -floor_d + TRIM_D)
    _crown(TRIM_D, -TRIM_D, door_l - SOUTH_TRIM_LEFT_GAP, 0.0)
    _crown(door_r + SOUTH_TRIM_RIGHT_GAP, -TRIM_D, floor_w - TRIM_D, 0.0)

    meta = {
        "size": size,
        "tiles_x": tiles_x,
        "tiles_z": tiles_z,
        "floor_w": floor_w,
        "floor_d": floor_d,
        "door_l": door_l,
        "door_r": door_r,
        "node": spec["node"],
        "folder": spec["folder"],
        "sq_ft": _sq_ft(floor_w, floor_d),
        "eng_sq_ft": tiles_x * tiles_z * 8.71875,
    }
    return mesh, meta


def write_shell(size: str, force: bool = False) -> Path:
    spec = SIZES[size]
    out_dir = Path(__file__).resolve().parent.parent / spec["folder"]
    out_dir.mkdir(parents=True, exist_ok=True)
    glb = out_dir / f"{spec['node']}.glb"
    if size in LOCKED_BLENDER_SIZES and glb.exists() and not force:
        raise SystemExit(
            f"{glb} is the locked Blender hero — pass --force to overwrite, "
            "or build --size=large (this PR)."
        )

    mesh, meta = build_shell(size)
    stats = mesh.stats()
    mesh.write_glb(
        glb,
        spec["node"],
        "CSS shop-shell builder (glTF 2.0, Principled/PBR, --size flag)",
    )
    extra = (
        f"floor_w={meta['floor_w']:.4f}",
        f"floor_d={meta['floor_d']:.4f}",
        f"wall_h={WALL_H:.4f}",
        f"door_w={DOOR_W:.4f}",
        f"door_h={DOOR_H:.4f}",
        f"door_x={meta['door_l']:.4f}..{meta['door_r']:.4f}",
        f"footprint_tiles={meta['tiles_x']}x{meta['tiles_z']}",
        f"tile_m={TILE_M}",
        "pivot=floor_southwest_corner",
        f"size={size}",
        f"sq_ft_interior={meta['sq_ft']:.1f}",
        f"sq_ft_eng_tiles={meta['eng_sq_ft']:.4f}",
        "fog=none",
        "bevel_m=0.003",
    )
    # write_build_stats already emits verts/tris/materials; keep Medium extras.
    write_build_stats(out_dir / "_build_stats.txt", stats, extra=extra)
    return glb


def main() -> None:
    parser = argparse.ArgumentParser(description="Build CSS shop shell GLB")
    parser.add_argument(
        "--size",
        choices=sorted(SIZES),
        default=os.environ.get("CSS_SHELL_SIZE", "large"),
        help="Shell size flag (default large / CSS_SHELL_SIZE)",
    )
    parser.add_argument(
        "--force",
        action="store_true",
        help="Allow overwriting locked Small/Medium Blender heroes",
    )
    args = parser.parse_args()
    glb = write_shell(args.size, force=args.force)
    mesh, meta = build_shell(args.size)
    stats = mesh.stats()
    print(
        f"wrote {glb}  size={args.size}  tiles={meta['tiles_x']}x{meta['tiles_z']}  "
        f"floor={meta['floor_w']:.1f}x{meta['floor_d']:.1f} m  "
        f"sq_ft≈{meta['sq_ft']:.0f}  tris={stats['tris']}  verts={stats['verts']}"
    )


if __name__ == "__main__":
    main()
