import math
import anim
import ease
import rig
import skin as skinlib
import states
from riv import *

DEG = math.pi / 180.0
XFORM = {'x': P_X, 'y': P_Y, 'rot': P_ROT, 'sx': P_SX, 'sy': P_SY, 'opacity': P_OPACITY}
TRIM = {'start': 114, 'end': 115, 'offset': 116}
BLEND_MS = 180
SLOW_BLEND = {'sleep': 420, 'sad': 400, 'tired': 420, 'shy': 320, 'think': 260,
              'focused': 300, 'cover_eyes': 280, 'act_reading': 300, 'studying': 300, 'act_studying': 300}
FAST_BLEND = {'excited': 120, 'surprised': 110, 'wow': 120, 'laughing': 130, 'cheer': 140,
              'cheering': 140, 'act_achieved': 140, 'dissolve_in': 0, 'dissolve_out': 0,
              'summon': 0, 'peek_left': 150, 'peek_right': 150}
MOUTH_RGB = rig.C['mouth']


def _order_children(parent, nodes, parts):
    out, seen = [], set()
    for p in parts:
        chain, cur = [], p['parent']
        while cur is not None and cur != parent:
            chain.append(cur)
            cur = nodes[cur]['parent'] if cur in nodes else None
        if cur != parent:
            continue
        pick = chain[-1] if chain else p['name']
        if pick not in seen:
            seen.add(pick)
            out.append(pick)
    return out


def build():
    b = Builder()
    b.backboard()
    b.artboard('Pebby', rig.ARTBOARD, rig.ARTBOARD)

    nodes = {n['name']: n for n in rig.NODES}
    ids, handles = {}, {}

    def emit_node(name):
        n = nodes[name]
        props = [(P_NAME, S, name), (P_X, D, n['x']), (P_Y, D, n['y']),
                 (P_SX, D, 1.0), (P_SY, D, 1.0), (P_ROT, D, 0.0), (P_OPACITY, D, 1.0)]
        if n['parent']:
            props.insert(1, (P_PARENT, U, ids[n['parent']]))
        ids[name] = b.obj(T_NODE, props)

    def emit_skinned_paths(p, sid):
        spec = p['skin']
        shape_world = skinlib.mat_mul(
            skinlib.trs(rig.ROOT, rig.ROOT),
            skinlib.trs(p['x'], p['y'], p.get('rot', 0.0)))
        seg, lo, hi = spec['seg'], spec['span'][0], spec['span'][1]
        for pt in p['paths']:
            cx = pt['x'] - pt['ox'] * pt['w'] + pt['w'] / 2
            cy = pt['y'] - pt['oy'] * pt['h'] + pt['h'] / 2
            verts = skinlib.ellipse_vertices(cx, cy, pt['w'] / 2, pt['h'] / 2,
                                             n=12, rot=math.radians(pt['rot']))
            path_id = b.obj(T_POINTS_PATH, [(P_PARENT, U, sid), (P_PATH_CLOSED, B, True),
                                            (P_X, D, 0.0), (P_Y, D, 0.0), (P_ROT, D, 0.0),
                                            (P_SX, D, 1.0), (P_SY, D, 1.0)])
            for v in verts:
                vid = b.obj(T_CUBIC_DETACHED, [
                    (P_PARENT, U, path_id), (P_VERT_X, D, v['x']), (P_VERT_Y, D, v['y']),
                    (P_IN_ROT, D, v['in_rot']), (P_IN_DIST, D, v['in_dist']),
                    (P_OUT_ROT, D, v['out_rot']), (P_OUT_DIST, D, v['out_dist'])])
                t = (v['y'] - lo) / max(1e-6, hi - lo)
                idx, val = skinlib.blend(t)
                b.obj(T_CUBIC_WEIGHT, [
                    (P_PARENT, U, vid), (P_W_INDICES, U, idx), (P_W_VALUES, U, val),
                    (P_W_IN_INDICES, U, idx), (P_W_IN_VALUES, U, val),
                    (P_W_OUT_INDICES, U, idx), (P_W_OUT_VALUES, U, val)])
            sk = b.obj(T_SKIN, [
                (P_PARENT, U, path_id),
                (P_SKIN_XX, D, shape_world[0]), (P_SKIN_XY, D, shape_world[1]),
                (P_SKIN_YX, D, shape_world[2]), (P_SKIN_YY, D, shape_world[3]),
                (P_SKIN_TX, D, shape_world[4]), (P_SKIN_TY, D, shape_world[5])])
            for bone_name in (spec['upper'], spec['fore']):
                w = bone_world[bone_name]
                b.obj(T_TENDON, [
                    (P_PARENT, U, sk), (P_TEND_BONE, U, ids[bone_name]),
                    (P_TEND_XX, D, w[0]), (P_TEND_XY, D, w[1]),
                    (P_TEND_YX, D, w[2]), (P_TEND_YY, D, w[3]),
                    (P_TEND_TX, D, w[4]), (P_TEND_TY, D, w[5])])

    def emit_shape(p):
        sid = b.obj(T_SHAPE, [
            (P_NAME, S, p['name']), (P_PARENT, U, ids[p['parent']]),
            (P_X, D, p.get('x', 0.0)), (P_Y, D, p.get('y', 0.0)),
            (P_ROT, D, p.get('rot', 0.0) * DEG),
            (P_SX, D, p.get('sx', 1.0)), (P_SY, D, p.get('sy', 1.0)),
            (P_OPACITY, D, p.get('opacity', 1.0))])
        ids[p['name']] = sid
        for entry in p['paints']:
            pa = entry['paint']
            if entry['kind'] == 'fill':
                pid = b.obj(T_FILL, [(P_PARENT, U, sid), (P_FILL_RULE, U, 0)])
            else:
                pid = b.obj(T_STROKE_PAINT, [(P_PARENT, U, sid), (P_STROKE_THICKNESS, D, entry['thickness']),
                                       (P_STROKE_CAP, U, entry['cap']), (P_STROKE_JOIN, U, entry['join']),
                                       (P_STROKE_AFFECTED, B, True)])
            if entry.get('handle'):
                handles[entry['handle']] = dict(paint=pid)
            if pa['type'] == 'solid':
                cid = b.obj(T_SOLID, [(P_PARENT, U, pid),
                                      (P_SOLID_COLOR, C, argb(pa['color'], pa.get('alpha', 1.0)))])
                if entry.get('handle'):
                    handles[entry['handle']]['color'] = cid
            else:
                sx, sy = pa['start']
                ex, ey = pa['end']
                g = b.obj(T_RADIAL, [(P_PARENT, U, pid), (P_GRAD_SX, D, sx), (P_GRAD_SY, D, sy),
                                     (P_GRAD_EX, D, ex), (P_GRAD_EY, D, ey), (P_GRAD_OPACITY, D, 1.0)])
                if entry.get('handle'):
                    handles[entry['handle']]['gradient'] = g
                for st in pa['stops']:
                    b.obj(T_STOP, [(P_PARENT, U, g),
                                   (P_STOP_COLOR, C, argb(st[1], st[2] if len(st) > 2 else 1.0)),
                                   (P_STOP_POS, D, st[0])])
            tr = entry.get('trim')
            if tr:
                tid = b.obj(T_TRIM_PATH, [(P_PARENT, U, pid), (P_TRIM_START, D, tr['start']),
                                          (P_TRIM_END, D, tr['end']), (P_TRIM_OFFSET, D, tr['offset']),
                                          (P_TRIM_MODE, U, tr['mode'])])
                handles[tr['handle']] = dict(trim=tid)
        if p.get('skin'):
            emit_skinned_paths(p, sid)
            return
        for pt in p['paths']:
            common = [(P_PARENT, U, sid), (P_X, D, pt['x']), (P_Y, D, pt['y']),
                      (P_ROT, D, pt['rot'] * DEG), (P_PATH_W, D, pt['w']), (P_PATH_H, D, pt['h']),
                      (P_PATH_OX, D, pt['ox']), (P_PATH_OY, D, pt['oy'])]
            if pt['kind'] == 'ellipse':
                b.obj(T_ELLIPSE, common)
            else:
                b.obj(T_RECT, common + [(P_CORNER_LINK, B, False),
                                        (P_CORNER_TL, D, pt['tl']), (P_CORNER_TR, D, pt['tr']),
                                        (P_CORNER_BL, D, pt['bl']), (P_CORNER_BR, D, pt['br'])])

    by_name = {p['name']: p for p in rig.PARTS}

    def emit_bones():
        for bn in rig.BONES:
            props = [(P_NAME, S, bn['name']), (P_PARENT, U, ids[bn['parent']]),
                     (P_ROT, D, math.radians(bn['rot'])), (P_SX, D, 1.0), (P_SY, D, 1.0),
                     (P_BONE_LENGTH, D, bn['length'])]
            if 'root' in bn:
                props += [(P_ROOT_X, D, bn['root'][0]), (P_ROOT_Y, D, bn['root'][1])]
                ids[bn['name']] = b.obj(T_ROOT_BONE, props)
            else:
                ids[bn['name']] = b.obj(T_BONE, props)

    def emit_tree(node):
        emit_node(node)
        if node == 'motion':
            emit_bones()
        order = _order_children(node, nodes, rig.PARTS)
        for child in reversed(order):
            if child in by_name:
                emit_shape(by_name[child])
            else:
                emit_tree(child)

    bone_world = {}
    for bn in rig.BONES:
        parent_world = (skinlib.trs(rig.ROOT, rig.ROOT) if bn['parent'] == 'motion'
                        else bone_world[bn['parent']])
        if 'root' in bn:
            local = skinlib.trs(bn['root'][0], bn['root'][1], bn['rot'])
        else:
            parent_len = next(x['length'] for x in rig.BONES if x['name'] == bn['parent'])
            local = skinlib.trs(parent_len, 0.0, bn['rot'])
        bone_world[bn['name']] = skinlib.mat_mul(parent_world, local)

    emit_tree('root')

    interp = {}
    for name, (x1, y1, x2, y2) in ease.CURVES.items():
        interp[name] = b.obj(T_CUBIC_INTERP, [(P_CUBIC_X1, D, x1), (P_CUBIC_Y1, D, y1),
                                              (P_CUBIC_X2, D, x2), (P_CUBIC_Y2, D, y2)])

    INK = {'mouthFill': rig.C['mouth'], 'mouthStroke': rig.C['mouth'],
           'eyeLFill': rig.C['eye'], 'eyeLStroke': rig.C['eye'],
           'eyeRFill': rig.C['eye'], 'eyeRStroke': rig.C['eye']}

    BONE_OF = {'armL': ('armLUpper', 90.0), 'armR': ('armRUpper', 90.0),
               'armLBend': ('armLFore', 0.0), 'armRBend': ('armRFore', 0.0)}

    def target(part, prop):
        if part in BONE_OF and prop == 'rot':
            bone, offset = BONE_OF[part]
            return ids[bone], P_ROT, ('deg', offset)
        if part.endswith('Trim'):
            return handles[part]['trim'], TRIM[prop], 'double'
        if part.endswith('Gloss'):
            return handles[part]['gradient'], P_GRAD_OPACITY, 'double'
        if part in INK:
            if prop == 'thickness':
                return handles[part]['paint'], P_STROKE_THICKNESS, 'double'
            return handles[part]['color'], P_SOLID_COLOR, ('alpha', INK[part])
        return ids[part], XFORM[prop], 'double'

    def emit_anim(a):
        b.obj(T_LINEAR_ANIM, [(P_ANIM_NAME, S, a.name), (P_FPS, U, anim.FPS),
                              (P_DURATION, U, int(a.dur)), (P_SPEED, D, 1.0), (P_LOOP, U, a.loop)])
        tl = a.timeline()
        groups = {}
        for (part, prop), ks in tl.items():
            oid, pkey, kind = target(part, prop)
            groups.setdefault(oid, []).append((part, prop, pkey, kind, ks))
        for oid, props in groups.items():
            b.obj(T_KEYED_OBJECT, [(P_KEYED_OBJECT_ID, U, oid)])
            for part, prop, pkey, kind, ks in props:
                b.obj(T_KEYED_PROPERTY, [(P_KEYED_PROPERTY_KEY, U, pkey)])
                seen = {}
                for f, v, es in ks:
                    seen[int(round(f))] = (v, es)
                for frame, (value, es) in sorted(seen.items()):
                    if es == 'hold':
                        head = [(P_KF_FRAME, U, frame), (P_KF_INTERP, U, INTERP_HOLD)]
                    else:
                        head = [(P_KF_FRAME, U, frame), (P_KF_INTERP, U, INTERP_CUBIC),
                                (P_KF_INTERP_ID, U, interp.get(es, interp['smooth']))]
                    if isinstance(kind, tuple) and kind[0] == 'deg':
                        b.obj(T_KF_DOUBLE, head + [(P_KF_VALUE, D, (value + kind[1]) * DEG)])
                    elif isinstance(kind, tuple):
                        b.obj(T_KF_COLOR, head + [(P_KF_COLOR_VALUE, C, argb(kind[1], value))])
                    else:
                        val = value * DEG if prop == 'rot' else value
                        b.obj(T_KF_DOUBLE, head + [(P_KF_VALUE, D, val)])

    anims = states.build_all()
    for a in anims:
        emit_anim(a)

    hidden = anim.A('appear_hidden', seconds=1 / anim.FPS)
    hidden.dur = 1
    shown = anim.A('appear_shown', seconds=1 / anim.FPS)
    shown.dur = 1
    for lvl, an in ((0.0, hidden), (1.0, shown)):
        b.obj(T_LINEAR_ANIM, [(P_ANIM_NAME, S, an.name), (P_FPS, U, anim.FPS),
                              (P_DURATION, U, 1), (P_SPEED, D, 1.0), (P_LOOP, U, 1)])
        b.obj(T_KEYED_OBJECT, [(P_KEYED_OBJECT_ID, U, ids['root'])])
        b.obj(T_KEYED_PROPERTY, [(P_KEYED_PROPERTY_KEY, U, P_OPACITY)])
        b.obj(T_KF_DOUBLE, [(P_KF_FRAME, U, 0), (P_KF_INTERP, U, INTERP_LINEAR), (P_KF_VALUE, D, lvl)])

    n_anim = len(anims)
    idx = {a.name: i for i, a in enumerate(anims)}
    idx['appear_hidden'] = n_anim
    idx['appear_shown'] = n_anim + 1

    b.obj(T_STATE_MACHINE, [(P_ANIM_NAME, S, 'PebbySM')])
    b.obj(T_SM_NUMBER, [(P_SM_NAME, S, 'pose'), (P_SM_NUMBER_VALUE, D, 1.0)])
    b.obj(T_SM_BOOL, [(P_SM_NAME, S, 'reduceMotion'), (P_SM_BOOL_VALUE, B, False)])
    b.obj(T_SM_NUMBER, [(P_SM_NAME, S, 'appear'), (P_SM_NUMBER_VALUE, D, 100.0)])
    IN_POSE, IN_REDUCE, IN_APPEAR = 0, 1, 2

    def transition(to, ms, conds):
        b.obj(T_STATE_TRANSITION, [(P_STATE_TO_ID, U, to), (P_TRANSITION_FLAGS, U, 0),
                                   (P_TRANSITION_DURATION, U, ms)])
        for t, props in conds:
            b.obj(t, props)

    def pose_is(i):
        return (T_TRANSITION_NUMBER_COND, [(P_COND_INPUT_ID, U, IN_POSE), (P_COND_OP, U, OP_EQ),
                                           (P_COND_VALUE, D, float(i))])

    def reduce_is(on):
        return (T_TRANSITION_BOOL_COND, [(P_COND_INPUT_ID, U, IN_REDUCE),
                                         (P_COND_OP, U, OP_EQ if on else OP_NEQ)])

    b.obj(T_SM_LAYER, [(P_SM_NAME, S, 'body')])
    n_pose = len(states.STATES)
    first = 2
    static_state = first + n_pose
    b.obj(T_ENTRY_STATE, [])
    transition(first + 1, 0, [])
    b.obj(T_ANY_STATE, [])
    for i, (name, _fn) in enumerate(states.STATES):
        target = states.ALIASES.get(name, name)
        ms = FAST_BLEND.get(target, SLOW_BLEND.get(target, BLEND_MS))
        transition(first + i, ms, [pose_is(i), reduce_is(False)])
    transition(static_state, 260, [reduce_is(True)])
    for name, _fn in states.STATES:
        b.obj(T_ANIMATION_STATE, [(P_ANIMATION_ID, U, idx[states.ALIASES.get(name, name)])])
    b.obj(T_ANIMATION_STATE, [(P_ANIMATION_ID, U, idx[states.STATIC_NAME])])
    b.obj(T_EXIT_STATE, [])

    b.obj(T_SM_LAYER, [(P_SM_NAME, S, 'appear')])
    b.obj(T_ENTRY_STATE, [])
    transition(1, 0, [])
    b.obj(T_BLEND_STATE_1D, [(P_BLEND_INPUT_ID, U, IN_APPEAR)])
    b.obj(T_BLEND_ANIM_1D, [(P_BLEND_ANIM_ID, U, idx['appear_hidden']), (P_BLEND_VALUE, D, 0.0)])
    b.obj(T_BLEND_ANIM_1D, [(P_BLEND_ANIM_ID, U, idx['appear_shown']), (P_BLEND_VALUE, D, 100.0)])
    b.obj(T_ANY_STATE, [])
    b.obj(T_EXIT_STATE, [])

    return b.build(file_id=20260919)


if __name__ == '__main__':
    data = build()
    open('pebby.riv', 'wb').write(data)
    print(f'pebby.riv  {len(data)} bytes')
