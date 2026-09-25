import rig

_uid = [0]


def _grad(pa):
    _uid[0] += 1
    gid = 'g%d' % _uid[0]
    sx, sy = pa['start']
    ex, ey = pa['end']
    r = ((ex - sx) ** 2 + (ey - sy) ** 2) ** 0.5
    stops = ''.join(
        '<stop offset="%g" stop-color="%s" stop-opacity="%g"/>'
        % (s[0], s[1], s[2] if len(s) > 2 else 1.0) for s in pa['stops'])
    d = ('<radialGradient id="%s" gradientUnits="userSpaceOnUse" cx="%g" cy="%g" r="%g">%s'
         '</radialGradient>' % (gid, sx, sy, r, stops))
    return gid, d


def _path_d(pt):
    ox, oy = pt['ox'], pt['oy']
    x = pt['x'] - ox * pt['w'] + pt['w'] / 2
    y = pt['y'] - oy * pt['h'] + pt['h'] / 2
    if pt['kind'] == 'ellipse':
        rx, ry = pt['w'] / 2, pt['h'] / 2
        return ('M%g,%g a%g,%g 0 1,1 0,%g a%g,%g 0 1,1 0,%g Z'
                % (x, y - ry, rx, ry, 2 * ry, rx, ry, -2 * ry))
    w, h = pt['w'], pt['h']
    x0, y0 = x - w / 2, y - h / 2
    tl, tr, bl, br = pt['tl'], pt['tr'], pt['bl'], pt['br']
    return (f'M{x0+tl},{y0} H{x0+w-tr} A{tr},{tr} 0 0 1 {x0+w},{y0+tr} '
            f'V{y0+h-br} A{br},{br} 0 0 1 {x0+w-br},{y0+h} '
            f'H{x0+bl} A{bl},{bl} 0 0 1 {x0},{y0+h-bl} '
            f'V{y0+tl} A{tl},{tl} 0 0 1 {x0+tl},{y0} Z')


def _xform(o):
    t = 'translate(%g %g)' % (o.get('x', 0), o.get('y', 0))
    if o.get('rot'):
        t += ' rotate(%g)' % o['rot']
    if o.get('sx', 1) != 1 or o.get('sy', 1) != 1:
        t += ' scale(%g %g)' % (o.get('sx', 1), o.get('sy', 1))
    return t


def _paint_attrs(pa, defs):
    if pa['type'] == 'solid':
        return pa['color'], pa.get('alpha', 1.0)
    gid, dd = _grad(pa)
    defs.append(dd)
    return 'url(#%s)' % gid, 1.0


def _shape(p, defs):
    body = []
    for pt in p['paths']:
        d = _path_d(pt)
        tr = ' transform="rotate(%g %g %g)"' % (pt['rot'], pt['x'], pt['y']) if pt['rot'] else ''
        for entry in p['paints']:
            pa = entry['paint']
            col, op = _paint_attrs(pa, defs)
            if entry['kind'] == 'fill':
                body.append('<path d="%s" fill="%s" fill-opacity="%g"%s/>' % (d, col, op, tr))
            else:
                trim = entry.get('trim')
                extra = ''
                if trim:
                    span = max(1e-4, trim['end'] - trim['start'])
                    extra = (' pathLength="1" stroke-dasharray="%g %g" stroke-dashoffset="%g"'
                             % (span, 1 - span, -(trim['start'] + trim.get('offset', 0.0))))
                body.append('<path d="%s" fill="none" stroke="%s" stroke-opacity="%g" '
                            'stroke-width="%g" stroke-linecap="round"%s%s/>'
                            % (d, col, op, entry['thickness'], extra, tr))
    return '<g id="%s" transform="%s" opacity="%g">%s</g>' % (
        p['name'], _xform(p), p.get('opacity', 1.0), ''.join(body))


def svg(parts=None, nodes=None, size=None):
    _uid[0] = 0
    parts = parts if parts is not None else rig.PARTS
    nodes = {n['name']: n for n in (nodes if nodes is not None else rig.NODES)}
    size = size or int(rig.ARTBOARD)
    defs = []
    by_parent = {}
    for p in parts:
        by_parent.setdefault(p['parent'], []).append(p)

    def render(node_name):
        n = nodes[node_name]
        inner = []
        for p in by_parent.get(node_name, []):
            inner.append(_shape(p, defs))
        for child in nodes.values():
            if child['parent'] == node_name:
                inner.append(render(child['name']))
        return '<g id="%s" transform="%s" opacity="%g">%s</g>' % (
            node_name, _xform(n), n.get('opacity', 1.0), ''.join(inner))

    root = render('root')
    return ('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 %d %d" width="%d" height="%d">'
            '<defs>%s</defs>%s</svg>' % (size, size, size, size, ''.join(defs), root))


if __name__ == '__main__':
    import sys
    open(sys.argv[1] if len(sys.argv) > 1 else 'pebby.svg', 'w').write(svg())
    print('ok')
