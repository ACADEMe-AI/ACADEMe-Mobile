import math

K_CIRCLE = 4.0 / 3.0


def ellipse_vertices(cx, cy, rx, ry, n=10, rot=0.0):
    """Explicit cubic vertices for an ellipse, so the path can be skinned."""
    k = K_CIRCLE * math.tan(math.pi / (2 * n))
    cr, sr = math.cos(rot), math.sin(rot)
    out = []
    for i in range(n):
        t = 2 * math.pi * i / n
        px, py = rx * math.cos(t), ry * math.sin(t)
        tx, ty = -rx * math.sin(t), ry * math.cos(t)
        x = cx + px * cr - py * sr
        y = cy + px * sr + py * cr
        wx = tx * cr - ty * sr
        wy = tx * sr + ty * cr
        dist = k * math.hypot(wx, wy)
        ang = math.atan2(wy, wx)
        out.append(dict(x=x, y=y, in_rot=ang + math.pi, in_dist=dist,
                        out_rot=ang, out_dist=dist))
    return out


def pack(pairs):
    """Rive packs four bone indices and four 0-255 weights into two ints."""
    idx = val = 0
    for i, (bone, w) in enumerate(pairs[:4]):
        idx |= (bone & 0xFF) << (8 * i)
        val |= (w & 0xFF) << (8 * i)
    return idx, val


def blend(t, bone_a=1, bone_b=2):
    """t = 0 fully on the first bone, 1 fully on the second."""
    t = min(1.0, max(0.0, t))
    wb = int(round(t * 255))
    wa = 255 - wb
    pairs = [p for p in ((bone_a, wa), (bone_b, wb)) if p[1] > 0]
    return pack(pairs)


def rot_mat(deg):
    r = math.radians(deg)
    return math.cos(r), math.sin(r), -math.sin(r), math.cos(r)


def mat_mul(a, b):
    """[xx, xy, yx, yy, tx, ty] composition, a then b applied as a*b."""
    axx, axy, ayx, ayy, atx, aty = a
    bxx, bxy, byx, byy, btx, bty = b
    return (axx * bxx + ayx * bxy,
            axy * bxx + ayy * bxy,
            axx * byx + ayx * byy,
            axy * byx + ayy * byy,
            axx * btx + ayx * bty + atx,
            axy * btx + ayy * bty + aty)


def trs(x, y, deg=0.0):
    xx, xy, yx, yy = rot_mat(deg)
    return (xx, xy, yx, yy, x, y)
