#!/usr/bin/env python3
"""Shop-camera QA stills for J2 graded-badge + ONLINE_HOLD tag.

Renders the authored GLBs under warm key / cool fill (shop lighting language).
Not a Godot viewport — proof of silhouette + material read at far / approach /
interact distances. Drop-in Godot review still uses the same GLBs.
"""

from __future__ import annotations

import math
import sys
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(Path(__file__).resolve().parent))

from pbr_glb import LoadedTri, load_glb_tris, xform_tris  # noqa: E402

FIXTURES = ROOT / "assets" / "props" / "shop" / "fixtures"
QA = ROOT / "docs" / "art" / "qa-shots"

# Shop lighting language (shop_floor.tscn)
SUN_DIR = np.array([0.42, 0.78, 0.46], dtype=np.float32)
SUN_DIR = SUN_DIR / np.linalg.norm(SUN_DIR)
SUN_COL = np.array([1.00, 0.91, 0.78], dtype=np.float32) * 1.25
AMB = np.array([0.72, 0.78, 0.86], dtype=np.float32) * 0.38
FILL_DIR = np.array([-0.35, 0.25, -0.90], dtype=np.float32)
FILL_DIR = FILL_DIR / np.linalg.norm(FILL_DIR)
FILL_COL = np.array([1.00, 0.83, 0.66], dtype=np.float32) * 0.35
BG = np.array([0.10, 0.12, 0.15], dtype=np.float32)


def look_at(eye, target, up=(0.0, 1.0, 0.0)):
    eye = np.array(eye, dtype=np.float32)
    target = np.array(target, dtype=np.float32)
    f = target - eye
    f = f / (np.linalg.norm(f) or 1.0)
    r = np.cross(f, np.array(up, dtype=np.float32))
    r = r / (np.linalg.norm(r) or 1.0)
    u = np.cross(r, f)
    return eye, f, r, u


def project(p, eye, f, r, u, fov_deg, aspect, near=0.05):
    v = p - eye
    z = np.dot(v, f)
    if z <= near:
        return None
    x = np.dot(v, r)
    y = np.dot(v, u)
    t = math.tan(math.radians(fov_deg) * 0.5)
    return x / (z * t * aspect), y / (z * t), z


def shade(n, color, metallic, roughness, view):
    n = n / (np.linalg.norm(n) or 1.0)
    if n[1] < 0 and n[2] < 0:
        n = -n
    ndl = max(0.0, float(np.dot(n, SUN_DIR)))
    ndf = max(0.0, float(np.dot(n, FILL_DIR)))
    h = SUN_DIR + view
    h = h / (np.linalg.norm(h) or 1.0)
    spec = (max(0.0, float(np.dot(n, h))) ** (8.0 + (1.0 - roughness) * 48.0)) * (
        0.12 + 0.55 * metallic
    )
    albedo = np.array(color, dtype=np.float32)
    diff = albedo * (1.0 - 0.65 * metallic)
    rgb = AMB * albedo + SUN_COL * (diff * ndl + spec) + FILL_COL * diff * ndf
    return np.clip(rgb, 0.0, 1.0)


def add_ground(tris: list[LoadedTri], half=6.0) -> None:
    y = 0.0
    c = (0.42, 0.38, 0.32)
    tris.append(
        LoadedTri(
            (-half, y, -half),
            (half, y, -half),
            (half, y, half),
            (0, 1, 0),
            (0, 1, 0),
            (0, 1, 0),
            c,
            0.0,
            0.85,
            1.0,
            0.0,
        )
    )
    tris.append(
        LoadedTri(
            (-half, y, -half),
            (half, y, half),
            (-half, y, half),
            (0, 1, 0),
            (0, 1, 0),
            (0, 1, 0),
            c,
            0.0,
            0.85,
            1.0,
            0.0,
        )
    )


def add_back_wall(tris: list[LoadedTri], z=-1.35, half=6.0, h=2.6) -> None:
    c = (0.78, 0.72, 0.64)
    # Face the origin so either +Z or −Z walls light correctly.
    n = (0.0, 0.0, -1.0 if z > 0 else 1.0)
    if z > 0:
        q = ((-half, 0, z), (-half, h, z), (half, h, z), (half, 0, z))
    else:
        q = ((-half, 0, z), (half, 0, z), (half, h, z), (-half, h, z))
    tris.append(LoadedTri(q[0], q[1], q[2], n, n, n, c, 0.0, 0.78, 1.0, 0.0))
    tris.append(LoadedTri(q[0], q[2], q[3], n, n, n, c, 0.0, 0.78, 1.0, 0.0))


def rasterize(tris: list[LoadedTri], eye, target, w=1280, h=720, fov=70.0, caption=""):
    eye, f, r, u = look_at(eye, target)
    aspect = w / h
    color = np.tile(BG, (h, w, 1)).astype(np.float32)
    depth = np.full((h, w), 1e9, dtype=np.float32)
    view = -f

    packed = []
    for t in tris:
        pts = [np.array(t.v0, dtype=np.float32), np.array(t.v1, dtype=np.float32), np.array(t.v2, dtype=np.float32)]
        projs = [project(p, eye, f, r, u, fov, aspect) for p in pts]
        if any(p is None for p in projs):
            continue
        xs = np.array([(p[0] * 0.5 + 0.5) * w for p in projs], dtype=np.float32)
        ys = np.array([(1.0 - (p[1] * 0.5 + 0.5)) * h for p in projs], dtype=np.float32)
        zs = np.array([p[2] for p in projs], dtype=np.float32)
        minx = max(0, int(math.floor(float(xs.min()))))
        maxx = min(w - 1, int(math.ceil(float(xs.max()))))
        miny = max(0, int(math.floor(float(ys.min()))))
        maxy = min(h - 1, int(math.ceil(float(ys.max()))))
        if minx > maxx or miny > maxy:
            continue
        ns = np.stack(
            [
                np.array(t.n0, dtype=np.float32),
                np.array(t.n1, dtype=np.float32),
                np.array(t.n2, dtype=np.float32),
            ]
        )
        packed.append((xs, ys, zs, ns, t, minx, maxx, miny, maxy))

    packed.sort(key=lambda it: 1 if (it[4].alpha < 0.95 or it[4].transmission > 0.2) else 0)

    for xs, ys, zs, ns, t, minx, maxx, miny, maxy in packed:
        x0, x1, x2 = xs
        y0, y1, y2 = ys
        denom = (y1 - y2) * (x0 - x2) + (x2 - x1) * (y0 - y2)
        if abs(float(denom)) < 1e-8:
            continue
        xs_px, ys_px = np.meshgrid(
            np.arange(minx, maxx + 1, dtype=np.float32),
            np.arange(miny, maxy + 1, dtype=np.float32),
        )
        w0 = ((y1 - y2) * (xs_px - x2) + (x2 - x1) * (ys_px - y2)) / denom
        w1 = ((y2 - y0) * (xs_px - x2) + (x0 - x2) * (ys_px - y2)) / denom
        w2 = 1.0 - w0 - w1
        mask = (w0 >= -0.001) & (w1 >= -0.001) & (w2 >= -0.001)
        if not np.any(mask):
            continue
        z = w0 * zs[0] + w1 * zs[1] + w2 * zs[2]
        sl = (slice(miny, maxy + 1), slice(minx, maxx + 1))
        zbuf = depth[sl]
        closer = mask & (z < zbuf)
        glass = t.alpha < 0.95 or t.transmission > 0.2
        if not glass:
            if not np.any(closer):
                continue
            n = (
                w0[:, :, None] * ns[0]
                + w1[:, :, None] * ns[1]
                + w2[:, :, None] * ns[2]
            )
            nn = np.linalg.norm(n, axis=2, keepdims=True)
            nn = np.maximum(nn, 1e-6)
            n = n / nn
            flip = (n[:, :, 1] < 0) & (n[:, :, 2] < 0)
            n[flip] *= -1
            ndl = np.clip(n @ SUN_DIR, 0.0, 1.0)
            ndf = np.clip(n @ FILL_DIR, 0.0, 1.0)
            hvec = SUN_DIR + view
            hvec = hvec / (np.linalg.norm(hvec) or 1.0)
            spec = np.clip(n @ hvec, 0.0, 1.0) ** (8.0 + (1.0 - t.roughness) * 48.0)
            spec = spec * (0.12 + 0.55 * t.metallic)
            albedo = np.array(t.color, dtype=np.float32)
            diff = albedo * (1.0 - 0.65 * t.metallic)
            rgb = AMB * albedo + SUN_COL * (diff * ndl[:, :, None] + spec[:, :, None])
            rgb = rgb + FILL_COL * diff * ndf[:, :, None]
            rgb = np.clip(rgb, 0.0, 1.0)
            dest = color[sl]
            dest[closer] = rgb[closer]
            zbuf[closer] = z[closer]
        else:
            # cheap glass: tint whatever is already there
            a = max(0.16, min(0.42, t.alpha + 0.10))
            n = ns[0] / (np.linalg.norm(ns[0]) or 1.0)
            tint = shade(n, t.color, t.metallic, t.roughness, view)
            dest = color[sl]
            dest[mask] = dest[mask] * (1.0 - a) + tint * a
            zbuf[closer] = z[closer]

    img = Image.fromarray((np.clip(color, 0, 1) * 255).astype(np.uint8), "RGB")
    if caption:
        draw = ImageDraw.Draw(img)
        bar_h = 36
        draw.rectangle((0, h - bar_h, w, h), fill=(18, 20, 24))
        try:
            font = ImageFont.truetype(
                "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 16
            )
        except OSError:
            font = ImageFont.load_default()
        draw.text((16, h - 26), caption, fill=(230, 220, 200), font=font)
    return img


def glb(name: str) -> Path:
    return FIXTURES / name / f"{name}.glb"


def render_graded() -> None:
    base, _ = load_glb_tris(glb("prop_display_case_01"))
    slab, _ = load_glb_tris(glb("prop_display_case_slab_01"))
    badge, _ = load_glb_tris(glb("prop_graded_case_badge_01"))

    base = xform_tris(base, (-1.05, 0.0, 0.0))
    slab = xform_tris(slab, (1.05, 0.0, 0.0))
    # suggested local (0, 1.06, -0.452) on slab at x=1.05
    badge = xform_tris(badge, (1.05, 1.06, -0.452))

    scene = []
    add_ground(scene, 8.0)
    add_back_wall(scene, z=1.55)
    scene.extend(base)
    scene.extend(slab)
    scene.extend(badge)

    shots = (
        (
            "J2_graded_case_far.png",
            (2.2, 1.78, -8.15),
            (0.15, 0.82, -0.10),
            "J2  base vs slab+badge   far ~8.2 m   fov 70",
        ),
        (
            "J2_graded_case_approach.png",
            (0.85, 1.52, -3.55),
            (0.10, 0.80, -0.10),
            "J2  base vs slab+badge   approach ~3.6 m   fov 70",
        ),
        (
            "J2_graded_case_interact.png",
            (0.40, 1.38, -1.95),
            (0.20, 0.88, -0.20),
            "J2  base vs slab+badge   interact ~1.9 m   fov 70",
        ),
        (
            "J2_graded_case_badge_detail.png",
            (1.05, 1.14, -1.05),
            (1.05, 1.07, -0.46),
            "J2  graded badge on slab case   placeholder bars / diamond only",
        ),
    )
    for name, eye, target, cap in shots:
        img = rasterize(scene, eye, target, caption=cap)
        dest = QA / name
        img.save(dest, "PNG")
        print("wrote", dest)


def render_hold_tag() -> None:
    tag, _ = load_glb_tris(glb("prop_online_hold_tag_01"))
    price, _ = load_glb_tris(glb("prop_price_tag_01"))
    talker, _ = load_glb_tris(glb("prop_shelf_talker_01"))
    shelf, _ = load_glb_tris(glb("prop_shelf_01"))
    case, _ = load_glb_tris(glb("prop_display_case_01"))

    # Alone + teal siblings for header contrast
    alone = []
    add_ground(alone, 0.6)
    add_back_wall(alone, z=-0.12, half=0.4, h=0.25)
    alone.extend(xform_tris(tag, (0.0, 0.06, 0.0)))
    alone.extend(xform_tris(price, (-0.12, 0.06, 0.0)))
    alone.extend(xform_tris(talker, (0.14, 0.16, 0.0)))
    img = rasterize(
        alone,
        (0.02, 0.03, 0.22),
        (0.0, 0.03, 0.01),
        caption="J2  ONLINE_HOLD tag (amber) vs price tag + teal talker",
    )
    dest = QA / "J2_online_hold_tag_alone.png"
    img.save(dest, "PNG")
    print("wrote", dest)

    # On shelf lip — customer face −X; tag face +Z needs yaw +90 → −X
    shelf_scene = []
    add_ground(shelf_scene, 4.0)
    add_back_wall(shelf_scene, z=2.2, half=4.0, h=2.4)
    shelf_scene.extend(xform_tris(shelf, (0.0, 0.0, 0.0)))
    hold_on_shelf = xform_tris(tag, (-0.452, 1.35, 0.12), yaw_deg=90)
    price_on_shelf = xform_tris(price, (-0.452, 1.00, -0.18), yaw_deg=90)
    shelf_scene.extend(hold_on_shelf)
    shelf_scene.extend(price_on_shelf)

    shots = (
        (
            "J2_online_hold_tag_shelf_approach.png",
            (-2.85, 1.50, 0.85),
            (-0.15, 1.20, 0.05),
            "J2  ONLINE_HOLD tag on shelf lip   approach",
        ),
        (
            "J2_online_hold_tag_shelf_interact.png",
            (-1.25, 1.40, 0.35),
            (-0.42, 1.30, 0.10),
            "J2  ONLINE_HOLD tag on shelf lip   interact",
        ),
    )
    for name, eye, target, cap in shots:
        img = rasterize(shelf_scene, eye, target, caption=cap)
        dest = QA / name
        img.save(dest, "PNG")
        print("wrote", dest)

    # Case-lip clip — front −Z, tag yaw 180 so face points down-aisle
    case_scene = []
    add_ground(case_scene, 4.0)
    add_back_wall(case_scene, z=1.45, half=3.5, h=2.2)
    case_scene.extend(xform_tris(case, (0.0, 0.0, 0.0)))
    case_scene.extend(xform_tris(tag, (0.18, 0.72, -0.452), yaw_deg=180))
    img = rasterize(
        case_scene,
        (0.35, 1.28, -2.15),
        (0.05, 0.78, -0.15),
        caption="J2  ONLINE_HOLD tag on case lip   interact",
    )
    dest = QA / "J2_online_hold_tag_case_lip_interact.png"
    img.save(dest, "PNG")
    print("wrote", dest)


def main() -> None:
    QA.mkdir(parents=True, exist_ok=True)
    render_graded()
    render_hold_tag()


if __name__ == "__main__":
    main()
