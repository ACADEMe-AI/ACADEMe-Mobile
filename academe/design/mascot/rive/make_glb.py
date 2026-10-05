#!/usr/bin/env python3
"""One-shot 3D Pebby from the Rive preview rig + clay master.

Geometry is the artboard in rig.py (body 209×222.6, face 142×114, tufts,
arms, feet). Look is pebby_3d_master.png: clay, not a photo silhouette.
Wave pose is the official 3D still (screen-left arm up).
"""
from __future__ import annotations

from pathlib import Path

import numpy as np
from skimage import measure
import trimesh
from trimesh.visual.material import PBRMaterial

OUT = Path(__file__).resolve().parent / "preview"
S = 0.01  # artboard px → metres (body ~2.1 units tall)


def smin(a, b, k=0.10):
    h = np.clip(0.5 + 0.5 * (b - a) / k, 0.0, 1.0)
    return a * h + b * (1.0 - h) - k * h * (1.0 - h)


def smax(a, b, k=0.06):
    return -smin(-a, -b, k)


def sd_round_box(p, hx, hy, hz, r):
    q = np.abs(p) - np.array([hx, hy, hz]) + r
    outside = np.linalg.norm(np.maximum(q, 0.0), axis=-1)
    inside = np.minimum(np.maximum(q[..., 0], np.maximum(q[..., 1], q[..., 2])), 0.0)
    return outside + inside - r


def sd_ellipsoid(p, rx, ry, rz):
    q = p / np.array([rx, ry, rz])
    return (np.linalg.norm(q, axis=-1) - 1.0) * min(rx, ry, rz)


def sd_capsule(p, a, b, r):
    pa, ba = p - a, b - a
    h = np.clip((pa * ba).sum(-1) / (ba * ba).sum(), 0.0, 1.0)
    return np.linalg.norm(pa - ba * h[..., None], axis=-1) - r


def hex_rgba(c):
    c = c.lstrip("#")
    r, g, b = (int(c[i : i + 2], 16) / 255.0 for i in (0, 2, 4))
    return np.array([r, g, b, 1.0], dtype=np.float32)


# rig.py palette
MID = hex_rgba("8B8CF5")
HI = hex_rgba("B8B9FF")
LO = hex_rgba("6A6CD0")
FACE = hex_rgba("FFFEFF")
EYE = hex_rgba("1A1B32")
WHITE = hex_rgba("FFFFFF")
MOUTH = hex_rgba("2A2A40")
TONGUE = hex_rgba("E07A8A")
BROW = hex_rgba("1A1B32")


def field(pts):
    """Signed distance. Rive Y-down → 3D Y-up: y3 = -y_rive."""
    x, y, z = pts[..., 0], pts[..., 1], pts[..., 2]
    p = pts

    # Body: rounded box, slightly narrower in Z, softer bottom radius.
    body_c = np.array([0.0, -0.141, 0.0])
    r_body = np.where(y < -0.14, 0.62, 0.80)
    body = sd_round_box(p - body_c, 1.045, 1.113, 0.86, 0.72)
    # Extra roundness so it reads as the clay master, not a crate.
    body = smin(body, sd_ellipsoid(p - body_c, 1.00, 1.08, 0.82), 0.16)

    # Tufts (three lobes), blended into the crown.
    t1 = sd_ellipsoid(p - np.array([-0.22, 1.18, 0.02]), 0.15, 0.26, 0.13)
    t2 = sd_ellipsoid(p - np.array([0.06, 1.28, 0.00]), 0.17, 0.30, 0.14)
    t3 = sd_ellipsoid(p - np.array([0.30, 1.12, 0.04]), 0.13, 0.20, 0.12)
    tufts = smin(smin(t1, t2, 0.08), t3, 0.08)
    d = smin(body, tufts, 0.14)

    # Feet
    foot_l = sd_round_box(p - np.array([-0.47, -1.38, 0.06]), 0.265, 0.165, 0.22, 0.14)
    foot_r = sd_round_box(p - np.array([0.47, -1.38, 0.06]), 0.265, 0.165, 0.22, 0.14)
    d = smin(d, smin(foot_l, foot_r, 0.04), 0.08)

    # Right arm (screen-right, down) — capsule
    arm_r = sd_capsule(
        p,
        np.array([0.92, 0.05, 0.05]),
        np.array([1.18, -0.72, 0.12]),
        0.20,
    )
    paw_r = sd_ellipsoid(p - np.array([1.22, -0.82, 0.14]), 0.16, 0.14, 0.15)
    d = smin(d, smin(arm_r, paw_r, 0.06), 0.10)

    # Left arm (screen-left, WAVE) — raised, matching 01_wave + 3D master
    arm_l = sd_capsule(
        p,
        np.array([-0.90, 0.10, 0.08]),
        np.array([-1.28, 0.95, 0.22]),
        0.19,
    )
    paw_l = sd_ellipsoid(p - np.array([-1.34, 1.10, 0.28]), 0.17, 0.16, 0.16)
    d = smin(d, smin(arm_l, paw_l, 0.06), 0.10)

    # Face is a colour on the body, not a separate box (avoids the shelf).
    # Eyes / mouth / brows sit slightly off the front surface.
    eye_l = sd_ellipsoid(p - np.array([-0.26, 0.22, 0.80]), 0.125, 0.185, 0.07)
    eye_r = sd_ellipsoid(p - np.array([0.26, 0.22, 0.80]), 0.125, 0.185, 0.07)
    d = smin(d, smin(eye_l, eye_r, 0.02), 0.025)
    dot_l = sd_ellipsoid(p - np.array([-0.28, 0.32, 0.86]), 0.045, 0.045, 0.03)
    dot_r = sd_ellipsoid(p - np.array([0.24, 0.32, 0.86]), 0.045, 0.045, 0.03)
    d = smin(d, smin(dot_l, dot_r, 0.01), 0.02)

    mouth = sd_ellipsoid(p - np.array([0.0, -0.12, 0.82]), 0.16, 0.09, 0.07)
    d = smin(d, mouth, 0.03)
    tongue = sd_ellipsoid(p - np.array([0.0, -0.17, 0.84]), 0.08, 0.04, 0.04)
    d = smin(d, tongue, 0.02)

    brow_l = sd_capsule(
        p,
        np.array([-0.34, 0.46, 0.82]),
        np.array([-0.18, 0.48, 0.82]),
        0.028,
    )
    brow_r = sd_capsule(
        p,
        np.array([0.18, 0.48, 0.82]),
        np.array([0.34, 0.46, 0.82]),
        0.028,
    )
    d = smin(d, smin(brow_l, brow_r, 0.02), 0.02)

    return d


def _round_rect(x, y, cx, cy, hw, hh, r):
    """2D signed distance of a rounded rectangle, then inside test."""
    px = np.abs(x - cx) - hw + r
    py = np.abs(y - cy) - hh + r
    outside = np.sqrt(np.maximum(px, 0) ** 2 + np.maximum(py, 0) ** 2)
    inside = np.minimum(np.maximum(px, py), 0.0)
    return (outside + inside - r) < 0.0


def classify(pts):
    """Per-vertex part for colour. Front-most wins."""
    x, y, z = pts[:, 0], pts[:, 1], pts[:, 2]
    part = np.full(len(pts), "body", dtype=object)

    # White face plate = rounded square painted on the front of the body.
    on_face = (z > 0.28) & _round_rect(x, y, 0.0, 0.16, 0.62, 0.50, 0.36)
    part[on_face] = "face"

    for cx in (-0.26, 0.26):
        e = ((x - cx) / 0.14) ** 2 + ((y - 0.22) / 0.20) ** 2 + ((z - 0.80) / 0.12) ** 2
        part[e < 1.05] = "eye"
        h = ((x - cx + 0.02) / 0.05) ** 2 + ((y - 0.32) / 0.05) ** 2 + ((z - 0.86) / 0.05) ** 2
        part[h < 1.0] = "highlight"

    m = (x / 0.17) ** 2 + ((y + 0.12) / 0.10) ** 2 + ((z - 0.82) / 0.10) ** 2
    part[(m < 1.0) & (z > 0.55)] = "mouth"
    t = (x / 0.09) ** 2 + ((y + 0.17) / 0.05) ** 2 + ((z - 0.84) / 0.06) ** 2
    part[(t < 1.0) & (z > 0.55)] = "tongue"

    for cx, cy in ((-0.26, 0.47), (0.26, 0.47)):
        b = ((x - cx) / 0.11) ** 2 + ((y - cy) / 0.04) ** 2 + ((z - 0.82) / 0.06) ** 2
        part[b < 1.0] = "brow"

    return part


COLOR = {
    "body": MID,
    "face": FACE,
    "eye": EYE,
    "highlight": WHITE,
    "mouth": MOUTH,
    "tongue": TONGUE,
    "brow": BROW,
}


def clay_shade(colors, normals):
    """Soft studio key from upper-left, matching the 3D master."""
    key = np.array([-0.35, 0.55, 0.76])
    key = key / np.linalg.norm(key)
    fill = np.array([0.25, 0.15, -0.3])
    fill = fill / np.linalg.norm(fill)
    ndl = np.clip(normals @ key, 0, 1)
    ndf = np.clip(normals @ fill, 0, 1)
    wrap = 0.55 + 0.45 * ndl + 0.12 * ndf
    # Specular sheen top-left like BODY_SHEEN
    half = key + np.array([0, 0, 1.0])
    half = half / np.linalg.norm(half)
    spec = np.clip(normals @ half, 0, 1) ** 18 * 0.18
    out = colors.copy()
    out[:, :3] = np.clip(out[:, :3] * wrap[:, None] + spec[:, None], 0, 1)
    return out


def mesh_from_sdf(n=176, pad=0.15):
    b = 1.85
    xs = np.linspace(-b, b + pad, n)
    ys = np.linspace(-1.75, 1.95, n)
    zs = np.linspace(-1.15, 1.45, n)
    gx, gy, gz = np.meshgrid(xs, ys, zs, indexing="ij")
    pts = np.stack([gx, gy, gz], -1)
    vol = field(pts)
    verts, faces, normals, _ = measure.marching_cubes(
        vol, level=0.0, spacing=(xs[1] - xs[0], ys[1] - ys[0], zs[1] - zs[0])
    )
    verts += np.array([xs[0], ys[0], zs[0]])
    mesh = trimesh.Trimesh(vertices=verts, faces=faces, process=True)
    mesh.remove_unreferenced_vertices()
    trimesh.smoothing.filter_laplacian(mesh, lamb=0.45, iterations=8)
    mesh.fix_normals()
    return mesh


def color_mesh(mesh):
    parts = classify(mesh.vertices)
    rgba = np.zeros((len(mesh.vertices), 4), dtype=np.float32)
    for name, col in COLOR.items():
        rgba[parts == name] = col
    rgba[parts == "body"] = MID
    # Gradient on body: highlight top-left, shadow bottom
    body = parts == "body"
    if body.any():
        y = mesh.vertices[body, 1]
        z = mesh.vertices[body, 2]
        t = np.clip((y + 1.2) / 2.4, 0, 1)
        # mix LO → MID → HI
        lo, mid, hi = LO[:3], MID[:3], HI[:3]
        g = lo * (1 - t)[:, None] * 0.55 + mid * (0.55 + 0.45 * t)[:, None]
        g = g * 0.82 + hi * (0.18 * np.clip((z + 0.4) / 1.4, 0, 1))[:, None]
        rgba[body, :3] = np.clip(g, 0, 1)
        rgba[body, 3] = 1.0
    n = mesh.vertex_normals
    rgba = clay_shade(rgba, n)
    mesh.visual.vertex_colors = (rgba * 255).astype(np.uint8)
    return mesh


def render(mesh, eye, up, size=640, fov=36.0):
    """Z-sorted vertex splat. Fast check against the clay master."""
    v = mesh.vertices.astype(np.float64)
    n = mesh.vertex_normals.astype(np.float64)
    col = mesh.visual.vertex_colors.astype(np.float64) / 255.0
    center = np.array([0.0, 1.05, 0.15])
    forward = center - eye
    forward /= np.linalg.norm(forward)
    right = np.cross(forward, up)
    right /= np.linalg.norm(right)
    upv = np.cross(right, forward)
    cam = v - eye
    x = cam @ right
    y = cam @ upv
    z = cam @ forward
    front = (n @ -forward) > -0.05
    s = np.tan(np.deg2rad(fov) * 0.5)
    px = ((x / (z * s) + 1) * 0.5 * (size - 1)).astype(int)
    py = ((1 - (y / (z * s) + 1) * 0.5) * (size - 1)).astype(int)
    ok = front & (z > 0.2) & (px >= 1) & (px < size - 1) & (py >= 1) & (py < size - 1)
    order = np.argsort(-z[ok])
    img = np.zeros((size, size, 4), dtype=np.float64)
    img[..., 0:3] = 0.043
    img[..., 3] = 1.0
    ys, xs = py[ok][order], px[ok][order]
    rgb = col[ok][order, :3]
    # 3×3 splat so the surface fills
    for dy in (-1, 0, 1):
        for dx in (-1, 0, 1):
            img[ys + dy, xs + dx, :3] = rgb
    return (img * 255).astype(np.uint8)


def main():
    print("sdf…")
    mesh = mesh_from_sdf()
    mesh = color_mesh(mesh)
    mesh.apply_scale(S / 0.01)  # already in ~metre-ish units
    # Recenter on origin, sit on y=0
    mesh.vertices -= [0, mesh.bounds[0, 1], 0]
    out_glb = OUT / "pebby.glb"
    mesh.export(out_glb)
    print(f"wrote {out_glb}  verts={len(mesh.vertices)} faces={len(mesh.faces)}  {out_glb.stat().st_size/1024:.0f} KB")

    from PIL import Image

    views = {
        "glb_front.png": (np.array([0.0, 1.15, 5.4]), np.array([0.0, 1.0, 0.0])),
        "glb_three_quarter.png": (np.array([3.4, 1.3, 4.2]), np.array([0.0, 1.0, 0.0])),
        "glb_side.png": (np.array([5.4, 1.15, 0.4]), np.array([0.0, 1.0, 0.0])),
        "glb_back.png": (np.array([0.0, 1.15, -5.4]), np.array([0.0, 1.0, 0.0])),
    }
    for name, (eye, up) in views.items():
        print("render", name)
        img = render(mesh, eye, up)
        Image.fromarray(img, "RGBA").save(OUT / name)
    print("done")


if __name__ == "__main__":
    main()
