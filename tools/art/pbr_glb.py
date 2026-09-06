"""Minimal glTF 2.0 / GLB builder + loader for CSS shop props.

Meters, +Y up, Principled/PBR metallic-roughness. No Blender required.
Matches the material-name conventions used by existing fixture GLBs.
"""

from __future__ import annotations

import json
import math
import struct
from dataclasses import dataclass, field
from pathlib import Path
from typing import Iterable

VEC3 = tuple[float, float, float]


def _vadd(a: VEC3, b: VEC3) -> VEC3:
    return (a[0] + b[0], a[1] + b[1], a[2] + b[2])


def _vsub(a: VEC3, b: VEC3) -> VEC3:
    return (a[0] - b[0], a[1] - b[1], a[2] - b[2])


def _vmul(a: VEC3, s: float) -> VEC3:
    return (a[0] * s, a[1] * s, a[2] * s)


def _vdot(a: VEC3, b: VEC3) -> float:
    return a[0] * b[0] + a[1] * b[1] + a[2] * b[2]


def _vcross(a: VEC3, b: VEC3) -> VEC3:
    return (
        a[1] * b[2] - a[2] * b[1],
        a[2] * b[0] - a[0] * b[2],
        a[0] * b[1] - a[1] * b[0],
    )


def _vnorm(a: VEC3) -> VEC3:
    length = math.sqrt(_vdot(a, a)) or 1.0
    return (a[0] / length, a[1] / length, a[2] / length)


@dataclass
class PbrMaterial:
    name: str
    base_color: tuple[float, float, float, float]
    metallic: float
    roughness: float
    double_sided: bool = True
    alpha_mode: str | None = None
    transmission: float | None = None


@dataclass
class _Prim:
    positions: list[float] = field(default_factory=list)
    normals: list[float] = field(default_factory=list)
    uvs: list[float] = field(default_factory=list)
    indices: list[int] = field(default_factory=list)

    @property
    def vert_count(self) -> int:
        return len(self.positions) // 3

    @property
    def tri_count(self) -> int:
        return len(self.indices) // 3


class MeshBuilder:
    def __init__(self) -> None:
        self.materials: list[PbrMaterial] = []
        self._prims: dict[str, _Prim] = {}

    def add_material(self, material: PbrMaterial) -> PbrMaterial:
        self.materials.append(material)
        self._prims.setdefault(material.name, _Prim())
        return material

    def _prim(self, material: str) -> _Prim:
        if material not in self._prims:
            raise KeyError(f"unknown material '{material}'")
        return self._prims[material]

    def add_tri(
        self,
        material: str,
        v0: VEC3,
        v1: VEC3,
        v2: VEC3,
        normal: VEC3 | None = None,
        uvs: tuple[tuple[float, float], tuple[float, float], tuple[float, float]]
        | None = None,
    ) -> None:
        prim = self._prim(material)
        n = normal or _vnorm(_vcross(_vsub(v1, v0), _vsub(v2, v0)))
        if uvs is None:
            uvs = ((0.0, 0.0), (1.0, 0.0), (0.0, 1.0))
        base = prim.vert_count
        for vert, uv in zip((v0, v1, v2), uvs):
            prim.positions.extend(vert)
            prim.normals.extend(n)
            prim.uvs.extend(uv)
        prim.indices.extend((base, base + 1, base + 2))

    def add_quad(
        self,
        material: str,
        v00: VEC3,
        v10: VEC3,
        v11: VEC3,
        v01: VEC3,
        normal: VEC3 | None = None,
    ) -> None:
        n = normal or _vnorm(_vcross(_vsub(v10, v00), _vsub(v01, v00)))
        self.add_tri(material, v00, v10, v11, n, ((0.0, 0.0), (1.0, 0.0), (1.0, 1.0)))
        self.add_tri(material, v00, v11, v01, n, ((0.0, 0.0), (1.0, 1.0), (0.0, 1.0)))

    def add_box(
        self,
        material: str,
        xmin: float,
        ymin: float,
        zmin: float,
        xmax: float,
        ymax: float,
        zmax: float,
        bevel: float = 0.0,
    ) -> None:
        """Axis-aligned box. Soft chamfer when bevel > 0 (no cel/ink)."""
        sx, sy, sz = xmax - xmin, ymax - ymin, zmax - zmin
        b = min(bevel, 0.49 * min(sx, sy, sz)) if bevel > 0 else 0.0
        if b <= 1e-6:
            self._add_sharp_box(material, xmin, ymin, zmin, xmax, ymax, zmax)
            return
        x0, x1 = xmin + b, xmax - b
        y0, y1 = ymin + b, ymax - b
        z0, z1 = zmin + b, zmax - b
        # inset faces sit on the outer planes
        self.add_quad(
            material, (x0, y0, zmin), (x1, y0, zmin), (x1, y1, zmin), (x0, y1, zmin), (0, 0, -1)
        )
        self.add_quad(
            material, (x1, y0, zmax), (x0, y0, zmax), (x0, y1, zmax), (x1, y1, zmax), (0, 0, 1)
        )
        self.add_quad(
            material, (xmin, y0, z1), (xmin, y0, z0), (xmin, y1, z0), (xmin, y1, z1), (-1, 0, 0)
        )
        self.add_quad(
            material, (xmax, y0, z0), (xmax, y0, z1), (xmax, y1, z1), (xmax, y1, z0), (1, 0, 0)
        )
        self.add_quad(
            material, (x0, ymin, z0), (x1, ymin, z0), (x1, ymin, z1), (x0, ymin, z1), (0, -1, 0)
        )
        self.add_quad(
            material, (x0, ymax, z1), (x1, ymax, z1), (x1, ymax, z0), (x0, ymax, z0), (0, 1, 0)
        )
        # 12 edge chamfers (45° lips — not cel ink)
        edges = (
            ((x0, y0, zmin), (x1, y0, zmin), (x1, ymin, z0), (x0, ymin, z0)),
            ((x1, y1, zmin), (x0, y1, zmin), (x0, ymax, z0), (x1, ymax, z0)),
            ((x0, ymin, z1), (x1, ymin, z1), (x1, y0, zmax), (x0, y0, zmax)),
            ((x0, ymax, z1), (x1, ymax, z1), (x1, y1, zmax), (x0, y1, zmax)),
            ((xmin, y0, z0), (x0, y0, zmin), (x0, y1, zmin), (xmin, y1, z0)),
            ((x1, y0, zmin), (xmax, y0, z0), (xmax, y1, z0), (x1, y1, zmin)),
            ((x0, y0, zmax), (xmin, y0, z1), (xmin, y1, z1), (x0, y1, zmax)),
            ((xmax, y0, z1), (x1, y0, zmax), (x1, y1, zmax), (xmax, y1, z1)),
            ((xmin, y0, z0), (xmin, y0, z1), (x0, ymin, z1), (x0, ymin, z0)),
            ((x1, ymin, z0), (x1, ymin, z1), (xmax, y0, z1), (xmax, y0, z0)),
            ((x0, ymax, z0), (x0, ymax, z1), (xmin, y1, z1), (xmin, y1, z0)),
            ((xmax, y1, z0), (xmax, y1, z1), (x1, ymax, z1), (x1, ymax, z0)),
        )
        for q in edges:
            self.add_quad(material, *q)
        # 8 corner triangles
        corners = (
            ((x0, ymin, z0), (x0, y0, zmin), (xmin, y0, z0)),
            ((x1, ymin, z0), (xmax, y0, z0), (x1, y0, zmin)),
            ((x0, ymax, z0), (xmin, y1, z0), (x0, y1, zmin)),
            ((x1, ymax, z0), (x1, y1, zmin), (xmax, y1, z0)),
            ((x0, ymin, z1), (xmin, y0, z1), (x0, y0, zmax)),
            ((x1, ymin, z1), (x1, y0, zmax), (xmax, y0, z1)),
            ((x0, ymax, z1), (x0, y1, zmax), (xmin, y1, z1)),
            ((x1, ymax, z1), (xmax, y1, z1), (x1, y1, zmax)),
        )
        for tri in corners:
            self.add_tri(material, *tri)

    def _add_sharp_box(
        self,
        material: str,
        xmin: float,
        ymin: float,
        zmin: float,
        xmax: float,
        ymax: float,
        zmax: float,
    ) -> None:
        self.add_quad(
            material, (xmin, ymin, zmin), (xmax, ymin, zmin), (xmax, ymax, zmin), (xmin, ymax, zmin)
        )
        self.add_quad(
            material, (xmax, ymin, zmax), (xmin, ymin, zmax), (xmin, ymax, zmax), (xmax, ymax, zmax)
        )
        self.add_quad(
            material, (xmin, ymin, zmax), (xmin, ymin, zmin), (xmin, ymax, zmin), (xmin, ymax, zmax)
        )
        self.add_quad(
            material, (xmax, ymin, zmin), (xmax, ymin, zmax), (xmax, ymax, zmax), (xmax, ymax, zmin)
        )
        self.add_quad(
            material, (xmin, ymin, zmin), (xmax, ymin, zmin), (xmax, ymin, zmax), (xmin, ymin, zmax)
        )
        self.add_quad(
            material, (xmin, ymax, zmax), (xmax, ymax, zmax), (xmax, ymax, zmin), (xmin, ymax, zmin)
        )

    def add_extruded_polygon(
        self,
        material: str,
        points_xy: list[tuple[float, float]],
        z0: float,
        z1: float,
        cap: bool = True,
    ) -> None:
        """Extrude a CCW XY polygon along Z."""
        pts = points_xy
        n = len(pts)
        if n < 3:
            return
        if z1 < z0:
            z0, z1 = z1, z0
        for i in range(n):
            x0, y0 = pts[i]
            x1, y1 = pts[(i + 1) % n]
            self.add_quad(
                material,
                (x0, y0, z0),
                (x1, y1, z0),
                (x1, y1, z1),
                (x0, y0, z1),
            )
        if cap:
            # fan caps (CCW on +Z, CW on −Z)
            cx = sum(p[0] for p in pts) / n
            cy = sum(p[1] for p in pts) / n
            for i in range(n):
                x0, y0 = pts[i]
                x1, y1 = pts[(i + 1) % n]
                self.add_tri(
                    material,
                    (cx, cy, z1),
                    (x0, y0, z1),
                    (x1, y1, z1),
                    (0, 0, 1),
                )
                self.add_tri(
                    material,
                    (cx, cy, z0),
                    (x1, y1, z0),
                    (x0, y0, z0),
                    (0, 0, -1),
                )

    def bounds(self) -> tuple[VEC3, VEC3]:
        mins = [1e9, 1e9, 1e9]
        maxs = [-1e9, -1e9, -1e9]
        for prim in self._prims.values():
            pos = prim.positions
            for i in range(0, len(pos), 3):
                for k in range(3):
                    mins[k] = min(mins[k], pos[i + k])
                    maxs[k] = max(maxs[k], pos[i + k])
        return (mins[0], mins[1], mins[2]), (maxs[0], maxs[1], maxs[2])

    def stats(self) -> dict[str, float | int | str]:
        verts = sum(p.vert_count for p in self._prims.values())
        tris = sum(p.tri_count for p in self._prims.values())
        mn, mx = self.bounds()
        return {
            "verts": verts,
            "tris": tris,
            "width": mx[0] - mn[0],
            "height": mx[1] - mn[1],
            "depth": mx[2] - mn[2],
            "min": mn,
            "max": mx,
            "materials": ",".join(m.name for m in self.materials),
        }

    def write_glb(self, path: Path, node_name: str, generator: str) -> None:
        path = Path(path)
        blobs: list[bytes] = []
        views: list[dict] = []
        accessors: list[dict] = []
        primitives: list[dict] = []

        def _pad4(data: bytes) -> bytes:
            pad = (4 - (len(data) % 4)) % 4
            return data if pad == 0 else data + b"\x00" * pad

        def _push_f32(values: list[float], typ: str, count: int) -> int:
            raw = struct.pack("<" + "f" * len(values), *values)
            raw = _pad4(raw)
            view_index = len(views)
            views.append({"buffer": 0, "byteOffset": sum(len(b) for b in blobs), "byteLength": len(raw)})
            blobs.append(raw)
            ncomp = {"SCALAR": 1, "VEC2": 2, "VEC3": 3}[typ]
            mins = [min(values[i::ncomp]) for i in range(ncomp)]
            maxs = [max(values[i::ncomp]) for i in range(ncomp)]
            acc = {
                "bufferView": view_index,
                "componentType": 5126,
                "count": count,
                "type": typ,
                "min": mins,
                "max": maxs,
            }
            accessors.append(acc)
            return len(accessors) - 1

        def _push_u16(values: list[int]) -> int:
            raw = struct.pack("<" + "H" * len(values), *values)
            raw = _pad4(raw)
            view_index = len(views)
            views.append(
                {
                    "buffer": 0,
                    "byteOffset": sum(len(b) for b in blobs),
                    "byteLength": len(raw),
                    "target": 34963,
                }
            )
            blobs.append(raw)
            accessors.append(
                {
                    "bufferView": view_index,
                    "componentType": 5123,
                    "count": len(values),
                    "type": "SCALAR",
                    "min": [min(values)],
                    "max": [max(values)],
                }
            )
            return len(accessors) - 1

        used_mats: list[PbrMaterial] = []
        for mat in self.materials:
            prim = self._prims[mat.name]
            if prim.tri_count == 0:
                continue
            used_mats.append(mat)
            pos_i = _push_f32(prim.positions, "VEC3", prim.vert_count)
            nrm_i = _push_f32(prim.normals, "VEC3", prim.vert_count)
            uv_i = _push_f32(prim.uvs, "VEC2", prim.vert_count)
            idx_i = _push_u16(prim.indices)
            primitives.append(
                {
                    "attributes": {"POSITION": pos_i, "NORMAL": nrm_i, "TEXCOORD_0": uv_i},
                    "indices": idx_i,
                    "material": len(used_mats) - 1,
                }
            )

        materials_json = []
        used_ext: set[str] = set()
        for mat in used_mats:
            entry: dict = {
                "name": mat.name,
                "pbrMetallicRoughness": {
                    "baseColorFactor": list(mat.base_color),
                    "metallicFactor": mat.metallic,
                    "roughnessFactor": mat.roughness,
                },
            }
            if mat.double_sided:
                entry["doubleSided"] = True
            if mat.alpha_mode:
                entry["alphaMode"] = mat.alpha_mode
            if mat.transmission is not None:
                entry.setdefault("extensions", {})["KHR_materials_transmission"] = {
                    "transmissionFactor": mat.transmission
                }
                used_ext.add("KHR_materials_transmission")
            materials_json.append(entry)

        bin_blob = b"".join(blobs)
        doc: dict = {
            "asset": {"generator": generator, "version": "2.0"},
            "scene": 0,
            "scenes": [{"name": "Scene", "nodes": [0]}],
            "nodes": [{"mesh": 0, "name": node_name}],
            "meshes": [{"name": node_name, "primitives": primitives}],
            "materials": materials_json,
            "accessors": accessors,
            "bufferViews": views,
            "buffers": [{"byteLength": len(bin_blob)}],
        }
        if used_ext:
            doc["extensionsUsed"] = sorted(used_ext)

        json_bytes = json.dumps(doc, separators=(",", ":")).encode("utf-8")
        json_pad = (4 - (len(json_bytes) % 4)) % 4
        json_bytes = json_bytes + (b" " * json_pad)
        bin_pad = (4 - (len(bin_blob) % 4)) % 4
        bin_bytes = bin_blob + (b"\x00" * bin_pad)

        total = 12 + 8 + len(json_bytes) + 8 + len(bin_bytes)
        header = struct.pack("<4sII", b"glTF", 2, total)
        json_chunk = struct.pack("<I4s", len(json_bytes), b"JSON") + json_bytes
        bin_chunk = struct.pack("<I4s", len(bin_bytes), b"BIN\x00") + bin_bytes
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_bytes(header + json_chunk + bin_chunk)


def write_build_stats(path: Path, stats: dict, extra: Iterable[str] = ()) -> None:
    lines = [
        f"width={stats['width']:.4f}",
        f"depth={stats['depth']:.4f}",
        f"height={stats['height']:.4f}",
        f"min_x={stats['min'][0]:.6f}",
        f"min_y={stats['min'][1]:.6f}",
        f"min_z={stats['min'][2]:.6f}",
        f"max_x={stats['max'][0]:.6f}",
        f"max_y={stats['max'][1]:.6f}",
        f"max_z={stats['max'][2]:.6f}",
        f"verts={stats['verts']}",
        f"tris={stats['tris']}",
        f"materials={stats['materials']}",
    ]
    lines.extend(extra)
    Path(path).write_text("\n".join(lines) + "\n", encoding="utf-8")


# ---------------------------------------------------------------------------
# Loader (QA / validation)
# ---------------------------------------------------------------------------

_COMP = {5120: "b", 5121: "B", 5122: "h", 5123: "H", 5125: "I", 5126: "f"}
_NCOMP = {"SCALAR": 1, "VEC2": 2, "VEC3": 3, "VEC4": 4}


@dataclass
class LoadedTri:
    v0: VEC3
    v1: VEC3
    v2: VEC3
    n0: VEC3
    n1: VEC3
    n2: VEC3
    color: tuple[float, float, float]
    metallic: float
    roughness: float
    alpha: float
    transmission: float


def load_glb_tris(path: Path) -> tuple[list[LoadedTri], dict]:
    data = Path(path).read_bytes()
    _magic, _ver, length = struct.unpack_from("<4sII", data, 0)
    off = 12
    doc = None
    blob = b""
    while off < length:
        clen, ctype = struct.unpack_from("<I4s", data, off)
        chunk = data[off + 8 : off + 8 + clen]
        off += 8 + clen
        if ctype.startswith(b"JSON"):
            doc = json.loads(chunk)
        else:
            blob = chunk
    assert doc is not None

    def read_acc(index: int) -> list[float] | list[int]:
        acc = doc["accessors"][index]
        view = doc["bufferViews"][acc["bufferView"]]
        start = view.get("byteOffset", 0) + acc.get("byteOffset", 0)
        n = acc["count"] * _NCOMP[acc["type"]]
        fmt = _COMP[acc["componentType"]]
        size = struct.calcsize(fmt)
        vals = list(struct.unpack_from("<" + fmt * n, blob, start))
        return vals

    materials = doc.get("materials", [])
    tris: list[LoadedTri] = []
    nodes = doc.get("nodes", [])
    # single-node fixtures; ignore extra TRS (existing props are identity)
    for mesh in doc.get("meshes", []):
        for prim in mesh.get("primitives", []):
            pos = read_acc(prim["attributes"]["POSITION"])
            nrm = read_acc(prim["attributes"]["NORMAL"]) if "NORMAL" in prim["attributes"] else []
            idx = read_acc(prim["indices"]) if "indices" in prim else list(range(len(pos) // 3))
            mi = prim.get("material", 0)
            mat = materials[mi] if materials else {}
            pbr = mat.get("pbrMetallicRoughness", {})
            col = pbr.get("baseColorFactor", [0.8, 0.8, 0.8, 1])
            metal = float(pbr.get("metallicFactor", 1.0 if "pbrMetallicRoughness" not in mat else 0.0))
            rough = float(pbr.get("roughnessFactor", 1.0))
            trans = 0.0
            ext = mat.get("extensions", {})
            if "KHR_materials_transmission" in ext:
                trans = float(ext["KHR_materials_transmission"].get("transmissionFactor", 0.0))
            alpha = float(col[3]) if len(col) > 3 else 1.0
            rgb = (float(col[0]), float(col[1]), float(col[2]))
            for i in range(0, len(idx), 3):
                ia, ib, ic = int(idx[i]), int(idx[i + 1]), int(idx[i + 2])

                def _p(k: int) -> VEC3:
                    return (float(pos[3 * k]), float(pos[3 * k + 1]), float(pos[3 * k + 2]))

                def _n(k: int) -> VEC3:
                    if nrm:
                        return (float(nrm[3 * k]), float(nrm[3 * k + 1]), float(nrm[3 * k + 2]))
                    return (0.0, 1.0, 0.0)

                tris.append(
                    LoadedTri(
                        _p(ia),
                        _p(ib),
                        _p(ic),
                        _n(ia),
                        _n(ib),
                        _n(ic),
                        rgb,
                        metal,
                        rough,
                        alpha,
                        trans,
                    )
                )
    meta = {
        "materials": [m.get("name", "") for m in materials],
        "nodes": [n.get("name", "") for n in nodes],
    }
    return tris, meta


def xform_tris(
    tris: list[LoadedTri],
    translation: VEC3 = (0.0, 0.0, 0.0),
    yaw_deg: float = 0.0,
) -> list[LoadedTri]:
    yaw = math.radians(yaw_deg)
    c, s = math.cos(yaw), math.sin(yaw)

    def rot(v: VEC3) -> VEC3:
        x, y, z = v
        return (x * c - z * s, y, x * s + z * c)

    out: list[LoadedTri] = []
    for t in tris:
        v0 = _vadd(rot(t.v0), translation)
        v1 = _vadd(rot(t.v1), translation)
        v2 = _vadd(rot(t.v2), translation)
        out.append(
            LoadedTri(
                v0,
                v1,
                v2,
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
