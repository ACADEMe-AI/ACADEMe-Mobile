import math
import rig
import anim
from anim import (A, FPS, GAZE, REST, eyes, brows, mouth, mouth_morph, look, face_view, arms,
                  elbow_follow,
                  breathe, head_life, sway, saccades, blinks, blink_schedule,
                  action, layered, _mix, gaze)

ARM_UP_L, ARM_UP_R = 150.0, -150.0
ARM_HIGH_L = 168.0
ARM_OUT_L = 96.0
ARM_HOLD_L, ARM_HOLD_R = 42.0, -42.0
ARM_PONDER_L = 156.0
ARM_TUCK_L, ARM_TUCK_R = 16.0, -16.0


def alive(a, seed=0, breath=0.011, tilt=1.5, reach=3.4, blink=True):
    breathe(a, breath, phase=seed * 0.07)
    head_life(a, tilt=tilt, drift=tilt * 1.3)
    saccades(a, reach=reach, seed=seed)
    if blink:
        blinks(a, blink_schedule(a.dur, seed))


def bounce(a, height, hits, squash=0.032, seed=0):
    d, n = a.dur, hits
    ys, sxs, sys_, sh = [], [], [], []
    for i in range(n):
        t0 = d * i / n
        span = d / n
        ys += [(t0, 0, 'in'), (t0 + span * 0.30, -height, 'outSoft'),
               (t0 + span * 0.62, 0, 'snap'), (t0 + span * 0.74, 0, 'outBackSoft')]
        sys_ += [(t0, 1 - squash * 0.5, 'out'), (t0 + span * 0.30, 1 + squash, 'in'),
                 (t0 + span * 0.62, 1 - squash, 'outBackSoft'),
                 (t0 + span * 0.80, 1.0, 'smooth')]
        sxs += [(t0, 1 + squash * 0.35, 'out'), (t0 + span * 0.30, 1 - squash * 0.6, 'in'),
                (t0 + span * 0.62, 1 + squash * 0.7, 'outBackSoft'),
                (t0 + span * 0.80, 1.0, 'smooth')]
        sh += [(t0, 1.0, 'out'), (t0 + span * 0.30, 0.74, 'in'),
               (t0 + span * 0.62, 1.04, 'outBackSoft'), (t0 + span * 0.80, 1.0, 'smooth')]
    a.key('motion', 'y', ys)
    a.key('motion', 'sy', sys_)
    a.key('motion', 'sx', sxs)
    a.key('shadow', 'sx', sh)
    a.key('shadow', 'sy', [(f, 1 - (1 - v) * 0.6, e) for f, v, e in sh])
    a.key('head', 'y', [(f, a.get('head', 'y') + v * 0.16, e) for f, v, e in ys])
    for part, gain in (('tuftL', -0.34), ('tuftR', 0.38)):
        base = a.get(part, 'rot')
        a.key(part, 'rot', [(f + 1.2, base + v * gain, e) for f, v, e in ys])
    for part, gain in (('armL', 0.20), ('armR', -0.22)):
        base = a.get(part, 'rot')
        a.key(part, 'rot', [(f + 1.5, base + v * gain, e) for f, v, e in ys])


def arm_wave(a, part='armL', base=ARM_UP_L, swing=17.0, beats=5, seed=0):
    d = a.dur
    pts = [(0, base - swing * 0.2, 'out')]
    for i in range(beats * 2 + 1):
        f = d * 0.10 + (d * 0.80) * i / (beats * 2)
        amp = swing * (1.0 if i % 2 else -1.0) * (0.82 + 0.18 * ((i % 3) / 2))
        pts.append((f, base + amp, 'sine'))
    pts.append((d, base - swing * 0.2, 'out'))
    a.key(part, 'rot', pts)


def _idle(a):
    a.dur = 17 * FPS
    mouth(a, 'smile'); alive(a, 0)


def _wave(a):
    a.dur = 9 * FPS
    mouth(a, 'open'); eyes(a, 'squint'); arms(a, left=ARM_UP_L)
    alive(a, 1, breath=0.009, blink=False)
    sway(a, 2.0)
    arm_wave(a, 'armL', ARM_UP_L, 18, 5)
    elbow_follow(a, 'L', gain=0.62, lag=1.5)
    a.set('armRBend', 'rot', -14.0)


def _think(a):
    a.dur = 11 * FPS
    mouth(a, 'flat'); brows(a, 'raise'); look(a, 4, -6)
    arms(a, left=128.0, bend_l=58.0, right=-18.0, bend_r=-22.0)
    alive(a, 2, breath=0.008, tilt=2.2, reach=2.2)
    sway(a, 2.0)


def _cheer(a):
    a.dur = 6 * FPS
    mouth(a, 'wide'); eyes(a, 'squint'); arms(a, left=ARM_UP_L, right=ARM_UP_R)
    bounce(a, 21, 3)
    head_life(a, tilt=2.4)


SLEEP_BREATH = 30


def _breaths(a, part, prop, rest, full, peak=0.42, lag=0):
    d, n = a.dur, a.dur // SLEEP_BREATH
    keys = []
    for c in range(n):
        t0 = c * SLEEP_BREATH + lag
        keys += [(t0, rest, 'sine'), (t0 + SLEEP_BREATH * peak, full, 'sine')]
    a.key(part, prop, [k for k in keys if k[0] < d] + [(d, rest, 'sine')])


def _zzz(a, name, offset, cycle=2 * SLEEP_BREATH):
    d = a.dur
    tracks = {p: [] for p in ('opacity', 'x', 'y', 'sx', 'sy', 'rot')}
    for f in range(0, d + 1, 2):
        p = ((f - offset) % cycle) / cycle
        fade = min(1.0, p / 0.14, (1.0 - p) / 0.3)
        tracks['opacity'].append((f, max(0.0, fade), 'smooth'))
        tracks['x'].append((f, 64 + 44 * p + 7 * math.sin(p * 3 * math.pi), 'smooth'))
        tracks['y'].append((f, -92 - 92 * p, 'smooth'))
        tracks['sx'].append((f, 0.45 + 0.7 * p, 'smooth'))
        tracks['sy'].append((f, 0.45 + 0.7 * p, 'smooth'))
        tracks['rot'].append((f, -14 + 22 * p, 'smooth'))
    for prop, keys in tracks.items():
        a.key(name, prop, keys)


def _sleep(a):
    a.dur = 4 * SLEEP_BREATH
    mouth(a, 'small'); eyes(a, 'closed'); brows(a, 'flat')
    arms(a, left=ARM_TUCK_L, right=ARM_TUCK_R)
    look(a, 0, 4)
    a.set('head', 'x', 5.0)
    _breaths(a, 'motion', 'sy', 1.0, 1.075)
    _breaths(a, 'motion', 'sx', 1.0, 0.968)
    _breaths(a, 'motion', 'y', 9.0, 2.0)
    _breaths(a, 'motion', 'rot', 4.5, 2.0, lag=2)
    _breaths(a, 'head', 'rot', 15.0, 7.0, lag=3)
    _breaths(a, 'head', 'y', rig.HEAD_Y + 5, rig.HEAD_Y - 3, lag=2)
    _breaths(a, 'armL', 'rot', ARM_TUCK_L - 2, ARM_TUCK_L + 8, lag=1)
    _breaths(a, 'armR', 'rot', ARM_TUCK_R + 2, ARM_TUCK_R - 8, lag=1)
    elbow_follow(a, 'L', gain=0.5)
    elbow_follow(a, 'R', gain=0.5)
    _breaths(a, 'tuftL', 'rot', a.get('tuftL', 'rot') - 16, a.get('tuftL', 'rot') + 6, lag=4)
    _breaths(a, 'tuftR', 'rot', a.get('tuftR', 'rot') + 18, a.get('tuftR', 'rot') - 6, lag=5)
    _breaths(a, 'shadow', 'sx', 1.0, 0.93)
    _breaths(a, 'mouth', 'sy', 0.9, 0.5, peak=0.4, lag=1)
    _breaths(a, 'mouth', 'sx', 0.5, 0.62, peak=0.4, lag=1)
    for name, offset in (('zzzA', 0), ('zzzB', SLEEP_BREATH * 2 // 3), ('zzzC', SLEEP_BREATH * 4 // 3)):
        _zzz(a, name, offset)


def _sad(a):
    a.dur = 13 * FPS
    mouth(a, 'frown'); brows(a, 'sad'); look(a, 0, 5)
    a.set('motion', 'y', 5.0); a.set('head', 'rot', 1.2)
    alive(a, 3, breath=0.007, tilt=0.9, reach=1.8)
    sway(a, 1.3)


def _wow(a):
    a.dur = 7 * FPS
    mouth(a, 'o'); eyes(a, 'wide'); brows(a, 'raise')
    for e in anim.EYES:
        a.set(e, 'sx', 1.24); a.set(e, 'sy', 1.34)
    arms(a, left=118.0, right=-118.0)
    d = a.dur
    a.key('motion', 'sx', [(0, 1, 'anticipate'), (2, 0.972, 'outBack'), (5, 1.042, 'settle'),
                           (9, 1.0, 'smooth'), (d, 1.0, 'smooth')])
    a.key('motion', 'sy', [(0, 1, 'anticipate'), (2, 0.966, 'outBack'), (5, 1.05, 'settle'),
                           (9, 1.0, 'smooth'), (d, 1.0, 'smooth')])
    a.key('motion', 'y', [(0, 0, 'anticipate'), (2, 8, 'outBack'), (5, -19, 'settle'),
                          (10, 0, 'smooth'), (d, 0, 'smooth')])
    head_life(a, tilt=1.4)
    blinks(a, [int(d * 0.72)])


def _determined(a):
    a.dur = 8 * FPS
    mouth(a, 'flat'); brows(a, 'furrow')
    d = a.dur
    a.key('motion', 'y', layered(d, [(2, 3.2, 0.0), (3, 1.0, 0.4)], 0.0))
    a.key('head', 'rot', layered(d, [(2, 2.4, 0.06), (5, 0.7, 0.3)], 0.0))
    breathe(a, 0.010)
    blinks(a, blink_schedule(d, 4))


def _confused(a):
    a.dur = 10 * FPS
    mouth(a, 'pout'); brows(a, 'worry')
    a.set('head', 'rot', 5.0)
    alive(a, 5, breath=0.008, tilt=3.4, reach=5.0)
    sway(a, 2.6)


def _happy(a):
    a.dur = 12 * FPS
    mouth(a, 'open'); brows(a, 'raise')
    alive(a, 6, breath=0.017, tilt=1.8)


def _excited(a):
    a.dur = 4 * FPS
    mouth(a, 'wide'); eyes(a, 'wide'); arms(a, left=ARM_UP_L, right=ARM_UP_R)
    bounce(a, 25, 3, squash=0.04)


def _laughing(a):
    a.dur = 5 * FPS
    mouth(a, 'agape'); eyes(a, 'squint')
    a.set('head', 'rot', -4.0)
    bounce(a, 14, 4, squash=0.03)
    a.key('head', 'rot', layered(a.dur, [(4, 3.0, 0.0), (7, 1.0, 0.3)], -4.0))


def _proud(a):
    a.dur = 11 * FPS
    mouth(a, 'grin'); brows(a, 'raise'); look(a, 0, -3)
    arms(a, left=22.0, right=-22.0)
    a.set('motion', 'y', -4.0); a.set('motion', 'sx', 1.03); a.set('head', 'y', -3.0)
    alive(a, 7, breath=0.013, tilt=1.2)


def _loved(a):
    a.dur = 7 * FPS
    mouth(a, 'grin'); eyes(a, 'squint')
    bounce(a, 12, 3, squash=0.028)
    head_life(a, tilt=2.6)


def _surprised(a):
    a.loop = 0
    a.dur = 4 * FPS
    mouth(a, 'o'); eyes(a, 'wide'); brows(a, 'raise')
    for e in anim.EYES:
        a.set(e, 'sx', 1.30); a.set(e, 'sy', 1.42)
    arms(a, left=126.0, right=-126.0)
    d = a.dur
    a.key('motion', 'sx', [(0, 1, 'anticipate'), (2, 0.965, 'outBack'), (5, 1.05, 'settle'),
                           (11, 1.0, 'smooth'), (d, 1.0, 'smooth')])
    a.key('motion', 'sy', [(0, 1, 'anticipate'), (2, 0.958, 'outBack'), (5, 1.06, 'settle'),
                           (11, 1.0, 'smooth'), (d, 1.0, 'smooth')])
    a.key('motion', 'y', [(0, 0, 'anticipate'), (2, 9, 'outBack'), (5, -22, 'settle'),
                          (12, 0, 'smooth'), (d, 0, 'smooth')])
    for p, s in (('tuftL', -1), ('tuftR', 1)):
        b = a.get(p, 'rot')
        a.key(p, 'rot', [(0, b, 'anticipate'), (3, b + s * 6, 'outBack'),
                         (7, b + s * 22, 'settle'), (14, b, 'smooth'), (d, b, 'smooth')])


def _tired(a):
    a.dur = 15 * FPS
    mouth(a, 'flat'); eyes(a, 'droop'); brows(a, 'worry')
    breathe(a, 0.020, lift=0.35)
    sway(a, 1.9)
    head_life(a, tilt=1.3, drift=1.4)
    blinks(a, [22, 30, 96, 104, 150])


def _shy(a):
    a.dur = 12 * FPS
    mouth(a, 'tiny'); eyes(a, 'narrow'); look(a, -3, 6); brows(a, 'worry')
    arms(a, left=ARM_TUCK_L, right=ARM_TUCK_R)
    a.set('motion', 'x', -5.0); a.set('motion', 'rot', -3.0); a.set('head', 'rot', -3.5)
    alive(a, 8, breath=0.009, tilt=1.1, reach=2.4)


def _focused(a):
    a.dur = 10 * FPS
    mouth(a, 'flat'); brows(a, 'furrow')
    breathe(a, 0.008)
    head_life(a, tilt=0.7, drift=0.8)
    blinks(a, blink_schedule(a.dur, 9))


def _act_achieved(a):
    a.dur = 6 * FPS
    mouth(a, 'wide'); eyes(a, 'squint'); arms(a, left=ARM_UP_L, right=ARM_UP_R)
    bounce(a, 19, 3)


def _act_highfive(a):
    a.dur = 7 * FPS
    mouth(a, 'open'); eyes(a, 'squint'); arms(a, left=ARM_HIGH_L)
    a.set('motion', 'rot', 4.0)
    alive(a, 10, breath=0.010, blink=False)
    d = a.dur
    a.key('armL', 'rot', [(0, ARM_HIGH_L, 'anticipate')] +
          [(d * 0.18, ARM_HIGH_L - 14, 'outBack'), (d * 0.30, ARM_HIGH_L + 9, 'settle'),
           (d * 0.46, ARM_HIGH_L, 'smooth'), (d, ARM_HIGH_L, 'smooth')])
    a.key('armLBend', 'rot', [(0, 26.0, 'anticipate'), (d * 0.18, 34.0, 'outBack'),
                              (d * 0.32, -12.0, 'settle'), (d * 0.50, 0.0, 'smooth'),
                              (d, 26.0, 'smooth')])


def _act_idea(a):
    a.dur = 8 * FPS
    mouth(a, 'open'); brows(a, 'raise'); look(a, 3, -7)
    arms(a, left=ARM_HIGH_L)
    sway(a, 2.2)
    head_life(a, tilt=1.8)
    d = a.dur
    a.key('armL', 'rot', layered(d, [(2, 7, 0.0), (3, 2.5, 0.4)], ARM_HIGH_L))


BOOK = ('bookCover', 'bookPages', 'bookLines', 'bookSpine', 'bookPawL', 'bookPawR')


def _act_reading(a):
    a.dur = 8 * FPS
    d = a.dur
    mouth(a, 'smile'); brows(a, 'raise')
    arms(a, left=-14.0, right=14.0)
    for part in BOOK:
        a.set(part, 'opacity', 1.0)
    a.set('head', 'rot', 2.0)
    breathe(a, 0.010)
    head_life(a, tilt=1.2, drift=1.0)
    lines = []
    for i, row in enumerate((5.0, 7.0, 9.0)):
        t0 = d * (0.05 + i * 0.28)
        lines += [(t0, -6.0, row, 'snap'), (t0 + d * 0.22, 6.0, row, 'smooth')]
    for e in GAZE:
        base_x, base_y = REST[e]['x'], a.get(e, 'y')
        a.key(e, 'x', [(f, base_x + dx, ease) for f, dx, _, ease in lines])
        a.key(e, 'y', [(f, base_y + dy, ease) for f, _, dy, ease in lines])
    blinks(a, blink_schedule(d, 21))
    a.key('head', 'rot', [(0, 2.0, 'smooth'), (d * 0.5, 3.2, 'smooth'), (d, 2.0, 'smooth')])


def _act_solving(a):
    a.dur = 11 * FPS
    mouth(a, 'flat'); brows(a, 'furrow'); look(a, 4, -4)
    arms(a, left=70.0)
    sway(a, 2.0)
    head_life(a, tilt=2.0)
    blinks(a, blink_schedule(a.dur, 12))


def _act_studying(a):
    a.dur = 12 * FPS
    mouth(a, 'smile'); look(a, 0, 7); brows(a, 'worry')
    arms(a, left=ARM_HOLD_L, right=-24.0)
    a.set('motion', 'rot', 5.0); a.set('head', 'rot', 3.0)
    alive(a, 13, breath=0.012, tilt=1.0, reach=2.2)


def _adaptive(a):
    a.dur = 14 * FPS
    mouth(a, 'smile'); alive(a, 14)


def _chat(a):
    a.dur = 9 * FPS
    d = a.dur
    alive(a, 15, breath=0.010, blink=False)
    beats = [(0, 'smile'), (0.06, 'open'), (0.12, 'small'), (0.18, 'wide'), (0.25, 'open'),
             (0.31, 'small'), (0.38, 'open'), (0.46, 'wide'), (0.52, 'small'), (0.58, 'open'),
             (0.66, 'smile'), (0.74, 'open'), (0.80, 'small'), (0.87, 'open'), (1.0, 'smile')]
    mouth_morph(a, [(round(d * t), m, 'out') for t, m in beats])
    blinks(a, blink_schedule(d, 16))


def _cta(a):
    a.dur = 8 * FPS
    mouth(a, 'grin'); eyes(a, 'squint')
    arms(a, left=ARM_OUT_L, bend_l=-40.0, right=-20.0, bend_r=-18.0)
    alive(a, 17, breath=0.014, blink=False)
    d = a.dur
    a.key('armL', 'rot', layered(d, [(2, 9, 0.0), (3, 3, 0.35)], ARM_OUT_L))
    elbow_follow(a, 'L', gain=0.7, lag=1.4)


def _hero(a):
    a.dur = 13 * FPS
    mouth(a, 'grin'); arms(a, left=30.0, right=-30.0)
    a.set('motion', 'sx', 1.05)
    alive(a, 18, breath=0.016, tilt=1.3)


def _mastery(a):
    a.dur = 12 * FPS
    mouth(a, 'grin'); eyes(a, 'squint'); brows(a, 'raise')
    arms(a, left=26.0, right=-26.0)
    a.set('motion', 'y', -5.0)
    alive(a, 19, breath=0.013, tilt=1.4, blink=False)


def _practice(a):
    a.dur = 11 * FPS
    mouth(a, 'flat'); brows(a, 'furrow'); look(a, 0, 5)
    arms(a, left=46.0, right=-46.0)
    alive(a, 20, breath=0.011, tilt=1.1, reach=2.0)


def _upload(a):
    a.dur = 8 * FPS
    mouth(a, 'open'); brows(a, 'raise'); look(a, 2, -6)
    arms(a, left=172.0)
    alive(a, 21, breath=0.012, blink=False)
    d = a.dur
    a.key('armL', 'rot', layered(d, [(3, 6, 0.0), (5, 2, 0.3)], 172.0))


def _studying(a):
    a.dur = 12 * FPS
    mouth(a, 'smile'); look(a, 0, 6); brows(a, 'worry')
    arms(a, left=ARM_HOLD_L, right=-28.0)
    a.set('motion', 'rot', 4.0); a.set('head', 'rot', 2.4)
    alive(a, 22, breath=0.011, tilt=1.0, reach=2.2)


def _turn(mode, seed):
    def f(a):
        a.dur = 12 * FPS
        mouth(a, 'smile')
        face_view(a, mode)
        breathe(a, 0.013)
        head_life(a, tilt=1.2, drift=1.4)
        if mode not in ('back', 'three_quarter_back'):
            saccades(a, reach=2.6, seed=seed)
            blinks(a, blink_schedule(a.dur, seed))
    return f


def _peek(side):
    sign = -1.0 if side == 'left' else 1.0
    lean = -sign

    def f(a):
        a.dur = 11 * FPS
        d = a.dur
        mouth(a, 'grin'); eyes(a, 'squint')
        arms(a, left=30.0, right=-30.0)
        gone = sign * 306.0
        out = sign * 214.0
        deep = sign * 236.0
        a.key('motion', 'x', [
            (0, gone, 'hold'), (3, gone, 'outExpo'), (11, out - sign * 11, 'settle'),
            (16, out, 'smooth'), (d * 0.42, out, 'smooth'), (d * 0.50, deep, 'in'),
            (d * 0.58, deep, 'hold'), (d * 0.66, out - sign * 8, 'outBackSoft'),
            (d * 0.72, out, 'smooth'), (d * 0.90, out, 'in'), (d, gone, 'smooth')])
        a.key('motion', 'rot', [
            (0, lean * 4, 'out'), (11, lean * 15, 'settle'), (18, lean * 11, 'smooth'),
            (d * 0.42, lean * 11, 'sine'), (d * 0.50, lean * 3, 'in'),
            (d * 0.66, lean * 14, 'outBackSoft'), (d * 0.74, lean * 11, 'smooth'),
            (d * 0.90, lean * 11, 'in'), (d, lean * 4, 'smooth')])
        a.key('head', 'rot', [
            (0, lean * 2, 'out'), (14, lean * 9, 'settle'), (22, lean * 6, 'smooth'),
            (d * 0.34, lean * 8, 'sine'), (d * 0.50, lean * 1, 'in'),
            (d * 0.68, lean * 8, 'outBackSoft'), (d, lean * 6, 'smooth')])
        a.key('head', 'x', [(0, 0, 'out'), (14, lean * 5, 'settle'), (24, lean * 3, 'smooth'),
                            (d * 0.5, lean * 1, 'sine'), (d, lean * 3, 'smooth')])
        gaze(a, [(0, lean * 2, 0, 'hold'), (13, lean * 6.5, 0.4, 'snap'),
                 (d * 0.26, lean * 6.5, 0.4, 'hold'), (d * 0.30, lean * 3.0, -1.6, 'snap'),
                 (d * 0.40, lean * 3.0, -1.6, 'hold'), (d * 0.46, lean * 6.5, 0.4, 'snap'),
                 (d * 0.58, lean * 6.5, 0.4, 'hold'), (d * 0.64, lean * 5.0, 1.4, 'snap'),
                 (d * 0.80, lean * 5.0, 1.4, 'hold'), (d * 0.86, lean * 6.5, 0.2, 'snap'),
                 (d, lean * 2, 0, 'hold')])
        breathe(a, 0.013, phase=0.2)
        blinks(a, [int(d * 0.22), int(d * 0.29), int(d * 0.62), int(d * 0.83)])
        for p, sgn in (('tuftL', -1), ('tuftR', 1)):
            b = a.get(p, 'rot')
            a.key(p, 'rot', [(0, b + sgn * lean * 22, 'out'), (14, b - sgn * lean * 9, 'settle'),
                             (26, b, 'smooth'), (d * 0.50, b + sgn * lean * 12, 'in'),
                             (d * 0.68, b - sgn * lean * 6, 'outBackSoft'),
                             (d * 0.78, b, 'smooth'), (d, b + sgn * lean * 22, 'in')])
        near = 'armR' if side == 'left' else 'armL'
        nb = a.get(near, 'rot')
        a.key(near, 'rot', [(0, nb, 'out'), (16, nb - lean * 16, 'settle'),
                            (28, nb - lean * 11, 'smooth'), (d * 0.5, nb - lean * 5, 'sine'),
                            (d * 0.7, nb - lean * 13, 'outBackSoft'), (d, nb, 'smooth')])
    return f


def _dissolve_in(a):
    a.loop = 0
    a.dur = 1.2 * FPS
    d = a.dur
    mouth(a, 'smile')
    jx = [0, 1.8, -1.3, 1.0, -0.6, 0.25, 0]
    jy = [0, -1.2, 1.4, -0.8, 0.4, -0.2, 0]
    span = d * 0.55
    hy = a.get('head', 'y')
    a.key('motion', 'opacity', [(0, 0.0, 'hold'), (d * 0.12, 1.0, 'hold'), (d, 1.0, 'hold')])
    a.key('motion', 'sx', [(0, 0.10, 'out'), (d * 0.12, 0.30, 'outExpo'),
                           (d * 0.58, 1.05, 'settle'), (d, 1.0, 'smooth')])
    a.key('motion', 'sy', [(0, 0.10, 'out'), (d * 0.12, 0.30, 'outExpo'),
                           (d * 0.58, 1.06, 'settle'), (d, 1.0, 'smooth')])
    a.key('motion', 'y', [(0, 24, 'outExpo'), (d * 0.55, -6, 'settle'), (d, 0, 'smooth')])
    a.key('motion', 'x', [(round(span * i / (len(jx) - 1)), v, 'linear')
                          for i, v in enumerate(jx)] + [(d, 0.0, 'smooth')])
    a.key('head', 'y', [(round(span * i / (len(jy) - 1)), hy + v, 'linear')
                        for i, v in enumerate(jy)] + [(d, hy, 'smooth')])
    a.key('shadow', 'sx', [(0, 0.10, 'outExpo'), (d * 0.58, 1.07, 'settle'), (d, 1.0, 'smooth')])
    a.key('shadow', 'sy', [(0, 0.10, 'outExpo'), (d, 1.0, 'smooth')])
    for p, sgn in (('armL', 1), ('armR', -1)):
        b = a.get(p, 'rot')
        a.key(p, 'rot', [(0, b - sgn * 22, 'outExpo'), (d * 0.58, b + sgn * 7, 'settle'),
                         (d, b, 'smooth')])
    for p, sgn in (('tuftL', -1), ('tuftR', 1)):
        b = a.get(p, 'rot')
        a.key(p, 'rot', [(0, b + sgn * 30, 'outExpo'), (d * 0.60, b - sgn * 10, 'settle'),
                         (d, b, 'smooth')])
    for e in anim.EYES:
        b = a.get(e, 'sy')
        a.key(e, 'sy', [(0, b * 0.08, 'hold'), (d * 0.40, b * 0.08, 'lidUp'),
                        (d * 0.68, b * 1.06, 'settle'), (d, b, 'smooth')])
    for dt in anim.DOTS:
        sdot = a.get(dt, 'sx')
        a.key(dt, 'sx', [(0, 0.0, 'hold'), (d * 0.46, 0.0, 'lidUp'), (d * 0.74, sdot, 'smooth')])


def _dissolve_out(a):
    a.loop = 0
    a.dur = 1.0 * FPS
    d = a.dur
    mouth(a, 'smile')
    a.key('motion', 'opacity', [(0, 1.0, 'hold'), (d * 0.96, 1.0, 'hold'), (d, 0.0, 'hold')])
    a.key('motion', 'sx', [(0, 1.0, 'anticipate'), (d * 0.18, 1.06, 'inExpo'),
                           (d * 0.72, 0.55, 'in'), (d, 0.06, 'smooth')])
    a.key('motion', 'sy', [(0, 1.0, 'anticipate'), (d * 0.18, 1.07, 'inExpo'),
                           (d * 0.72, 0.55, 'in'), (d, 0.06, 'smooth')])
    a.key('motion', 'y', [(0, 0, 'anticipate'), (d * 0.18, -7, 'inExpo'), (d, 30, 'smooth')])
    a.key('shadow', 'sx', [(0, 1.0, 'in'), (d, 0.18, 'smooth')])
    a.key('shadow', 'sy', [(0, 1.0, 'in'), (d, 0.18, 'smooth')])
    for p, sgn in (('armL', 1), ('armR', -1)):
        b = a.get(p, 'rot')
        a.key(p, 'rot', [(0, b, 'anticipate'), (d * 0.16, b - sgn * 6, 'outSoft'),
                         (d * 0.62, b + sgn * 62, 'settle'), (d, b + sgn * 74, 'smooth')])
        a.key('arm%sBend' % ('L' if sgn > 0 else 'R'), 'rot',
              [(0, a.get('arm%sBend' % ('L' if sgn > 0 else 'R'), 'rot'), 'out'),
               (d * 0.62, -sgn * 26, 'settle'), (d, -sgn * 34, 'smooth')])
    for p, sgn in (('tuftL', -1), ('tuftR', 1)):
        b = a.get(p, 'rot')
        a.key(p, 'rot', [(0, b, 'anticipate'), (d * 0.22, b - sgn * 9, 'in'),
                         (d, b + sgn * 34, 'smooth')])
    for f, sgn in (('footL', -1), ('footR', 1)):
        fy = a.get(f, 'y')
        a.key(f, 'y', [(0, fy, 'in'), (d, fy - 16, 'smooth')])
    for e in anim.EYES:
        b = a.get(e, 'sy')
        a.key(e, 'sy', [(0, b, 'lidDown'), (d * 0.46, b * 0.40, 'hold'), (d, b * 0.40, 'hold')])
    for side in 'LR':
        a.key('eye%sFill' % side, 'alpha', [(0, 1.0, 'lidDown'), (d * 0.46, 0.0, 'hold'),
                                            (d, 0.0, 'hold')])
        a.key('eye%sGloss' % side, 'opacity', [(0, 1.0, 'lidDown'), (d * 0.46, 0.0, 'hold'),
                                               (d, 0.0, 'hold')])
        a.key('eye%sStroke' % side, 'alpha', [(0, 0.0, 'lidDown'), (d * 0.46, 1.0, 'hold'),
                                              (d, 1.0, 'hold')])
    for dt in anim.DOTS:
        a.key(dt, 'sx', [(0, a.get(dt, 'sx'), 'lidDown'), (d * 0.40, 0.0, 'hold'), (d, 0.0, 'hold')])


def _summon(a):
    a.loop = 0
    a.dur = 1.9 * FPS
    d = a.dur
    mouth_morph(a, [(0, 'tiny', 'out'), (round(d * 0.46), 'o', 'outBack'),
                    (round(d * 0.62), 'wide', 'settle'), (round(d * 0.86), 'grin', 'smooth'),
                    (d, 'grin', 'smooth')])
    brows(a, 'raise')
    a.key('motion', 'opacity', [(0, 0.0, 'hold'), (d * 0.14, 1.0, 'hold'), (d, 1.0, 'hold')])
    a.key('motion', 'y', [(0, -96, 'in'), (d * 0.34, 14, 'outBackSoft'), (d * 0.46, -22, 'outSoft'),
                          (d * 0.58, 6, 'outBackSoft'), (d * 0.70, -7, 'outSoft'),
                          (d * 0.82, 0, 'settle'), (d, 0, 'smooth')])
    a.key('motion', 'sy', [(0, 1.22, 'in'), (d * 0.30, 0.78, 'outBack'), (d * 0.42, 1.14, 'outSoft'),
                           (d * 0.56, 0.93, 'outBackSoft'), (d * 0.72, 1.03, 'settle'),
                           (d, 1.0, 'smooth')])
    a.key('motion', 'sx', [(0, 0.82, 'in'), (d * 0.30, 1.20, 'outBack'), (d * 0.42, 0.90, 'outSoft'),
                           (d * 0.56, 1.05, 'outBackSoft'), (d * 0.72, 0.98, 'settle'),
                           (d, 1.0, 'smooth')])
    a.key('shadow', 'sx', [(0, 0.2, 'out'), (d * 0.30, 1.22, 'outSoft'), (d * 0.46, 0.76, 'outSoft'),
                           (d * 0.62, 1.08, 'settle'), (d, 1.0, 'smooth')])
    a.key('shadow', 'sy', [(0, 0.2, 'out'), (d * 0.30, 1.14, 'outSoft'), (d * 0.46, 0.84, 'outSoft'),
                           (d, 1.0, 'smooth')])
    for p, s in (('tuftL', -1), ('tuftR', 1)):
        b = a.get(p, 'rot')
        a.key(p, 'rot', [(0, b + s * 34, 'in'), (d * 0.34, b - s * 26, 'outBack'),
                         (d * 0.50, b + s * 15, 'outSoft'), (d * 0.66, b - s * 6, 'settle'),
                         (d, b, 'smooth')])
    for p, s in (('armL', 1), ('armR', -1)):
        b = a.get(p, 'rot')
        a.key(p, 'rot', [(0, b + s * 40, 'in'), (d * 0.34, b - s * 22, 'outBack'),
                         (d * 0.52, b + s * 11, 'outSoft'), (d * 0.70, b, 'settle'),
                         (d, b, 'smooth')])
    for e in anim.EYES:
        b = a.get(e, 'sy')
        a.key(e, 'sy', [(0, b * 0.1, 'hold'), (d * 0.26, b * 0.1, 'lidUp'),
                        (d * 0.40, b * 1.22, 'settle'), (d * 0.60, b, 'smooth'), (d, b, 'smooth')])


def _encourage(a):
    a.dur = 7 * FPS
    d = a.dur
    mouth(a, 'grin'); brows(a, 'raise')
    arms(a, left=ARM_OUT_L * 0.72, right=-22.0, bend_l=-34.0, bend_r=-16.0)
    breathe(a, 0.013, phase=0.1)
    head_life(a, tilt=1.4, drift=1.6)
    saccades(a, reach=2.4, seed=30)
    blinks(a, [int(d * 0.30), int(d * 0.78)])
    beat = d / 2
    nods = []
    for i in range(2):
        t0 = beat * i
        nods += [(t0, 0, 'in'), (t0 + beat * 0.16, 5.0, 'outSoft'),
                 (t0 + beat * 0.34, -1.5, 'outBackSoft'), (t0 + beat * 0.52, 0, 'smooth')]
    a.key('motion', 'y', nods)
    base = a.get('armL', 'rot')
    waves = []
    for i in range(2):
        t0 = beat * i
        waves += [(t0, base, 'in'), (t0 + beat * 0.18, base - 15, 'outSoft'),
                  (t0 + beat * 0.38, base + 5, 'outBackSoft'), (t0 + beat * 0.58, base, 'smooth')]
    a.key('armL', 'rot', waves)
    elbow_follow(a, 'L', gain=0.9, lag=1.6)


def _celebrate_small(a):
    a.dur = 3 * FPS
    mouth(a, 'grin'); eyes(a, 'squint')
    arms(a, left=64.0, right=-64.0)
    bounce(a, 14, 2, squash=0.026)
    head_life(a, tilt=2.0)


def _celebrate_big(a):
    a.dur = 4 * FPS
    d = a.dur
    mouth(a, 'wide'); eyes(a, 'squint'); brows(a, 'raise')
    arms(a, left=ARM_UP_L, right=ARM_UP_R)
    bounce(a, 34, 2, squash=0.038)
    a.key('head', 'rot', layered(d, [(2, 3.4, 0.05), (3, 1.2, 0.42)], 0.0))
    for p, sgn in (('armL', 1), ('armR', -1)):
        b = a.get(p, 'rot')
        a.key(p, 'rot', [(0, b - sgn * 12, 'in'), (d * 0.22, b + sgn * 14, 'outSoft'),
                         (d * 0.46, b - sgn * 8, 'outBackSoft'), (d * 0.62, b + sgn * 12, 'outSoft'),
                         (d * 0.84, b, 'settle'), (d, b - sgn * 12, 'smooth')])
    elbow_follow(a, 'L', gain=0.75, lag=1.5)
    elbow_follow(a, 'R', gain=0.75, lag=1.5)


def _sleepy(a):
    a.dur = 13 * FPS
    d = a.dur
    eyes(a, 'droop'); brows(a, 'worry')
    arms(a, left=ARM_TUCK_L, right=ARM_TUCK_R)
    breathe(a, 0.024, lift=0.3)
    sway(a, 1.7)
    mouth_morph(a, [(0, 'tiny', 'smooth'), (round(d * 0.20), 'tiny', 'out'),
                    (round(d * 0.27), 'agape', 'outSoft'), (round(d * 0.36), 'agape', 'in'),
                    (round(d * 0.44), 'flat', 'smooth'), (round(d * 0.70), 'tiny', 'smooth'),
                    (d, 'tiny', 'smooth')])
    for e in anim.EYES:
        b = a.get(e, 'sy')
        a.key(e, 'sy', [(0, b, 'lidDown'), (d * 0.26, b * 0.10, 'hold'),
                        (d * 0.38, b * 0.10, 'lidUp'), (d * 0.46, b, 'smooth'),
                        (d * 0.66, b, 'lidDown'), (d * 0.74, b * 0.55, 'lidUp'),
                        (d * 0.80, b, 'smooth'), (d, b, 'smooth')])
    for dt in anim.DOTS:
        sdot = a.get(dt, 'sx')
        a.key(dt, 'sx', [(0, sdot, 'lidDown'), (d * 0.26, 0.0, 'hold'),
                         (d * 0.38, 0.0, 'lidUp'), (d * 0.46, sdot, 'smooth'), (d, sdot, 'smooth')])
    a.key('head', 'rot', [(0, 1.0, 'sine'), (d * 0.28, 4.0, 'in'), (d * 0.44, 1.0, 'smooth'),
                          (d * 0.60, 2.0, 'in'), (d * 0.70, 7.5, 'in'),
                          (d * 0.745, 0.0, 'outBack'), (d * 0.80, 2.2, 'settle'),
                          (d, 1.0, 'smooth')])
    a.key('head', 'y', [(0, a.get('head', 'y'), 'sine'), (d * 0.70, a.get('head', 'y') + 6, 'in'),
                        (d * 0.745, a.get('head', 'y') - 2, 'outBack'),
                        (d, a.get('head', 'y'), 'smooth')])



# Paws over the eyes, for the password field. The real arms swing in behind
# the body (their layer sits under it) while the cover paws, drawn over the
# face, rise onto the eyes.
def _cover_eyes(a):
    a.dur = 10 * FPS
    mouth(a, 'tiny'); eyes(a, 'closed'); brows(a, 'worry')
    arms(a, left=-52.0, right=52.0, bend_l=-100.0, bend_r=100.0)
    for side, x in (('L', -33), ('R', 33)):
        a.set('cover' + side, 'opacity', 1.0)
        a.set('cover' + side, 'y', rig.H + 4)
    a.set('motion', 'sy', 0.97)
    breathe(a, 0.008)
    head_life(a, tilt=0.6, drift=0.6)

LAPTOP = ('laptopGlow', 'laptopLid', 'laptopScreen', 'laptopLogo', 'laptopBase', 'laptopKeys',
          'typePawL', 'typePawR')


def _act_laptop(a):
    a.dur = 4 * FPS
    d = a.dur
    mouth(a, 'small'); brows(a, 'furrow')
    arms(a, left=-14.0, right=14.0)
    for part in LAPTOP:
        a.set(part, 'opacity', 1.0)
    breathe(a, 0.008)
    head_life(a, tilt=0.8, drift=0.8)
    for e in GAZE:
        base_x, base_y = REST[e]['x'], a.get(e, 'y')
        a.key(e, 'y', [(0, base_y + 6, 'hold')])
        a.key(e, 'x', [(0, base_x - 5, 'smooth'), (d * 0.3, base_x + 5, 'smooth'),
                       (d * 0.55, base_x - 2, 'snap'), (d * 0.8, base_x + 4, 'smooth'), (d, base_x - 5, 'smooth')])
    taps = []
    for i in range(8):
        f = d * i / 8
        taps += [(f, 0.0, 'snap'), (f + d / 32, 4.0, 'snap')]
    y_l, y_r = REST['typePawL']['y'], REST['typePawR']['y']
    a.key('typePawL', 'y', [(f, y_l + (v if i % 4 < 2 else 0), e) for i, (f, v, e) in enumerate(taps)])
    a.key('typePawR', 'y', [(f, y_r + (v if i % 4 >= 2 else 0), e) for i, (f, v, e) in enumerate(taps)])
    a.key('laptopLogo', 'rot', [(0, 45.0, 'smooth'), (d, 405.0, 'linear')])
    a.key('laptopGlow', 'sx', [(0, 0.9, 'sine'), (d * 0.5, 1.1, 'sine'), (d, 0.9, 'sine')])
    blinks(a, blink_schedule(d, 51))


def _wake_up(a):
    a.dur = 35
    a.loop = 0
    d = a.dur
    brows(a, 'flat')
    head_y = a.get('head', 'y')
    a.key('motion', 'y', [(0, 8, 'sine'), (5, 8, 'out'), (13, -8, 'outSoft'), (18, -8, 'in'),
                          (21, 2, 'outBack'), (23, 4, 'anticipate'), (26, -24, 'outSoft'),
                          (29, 0, 'snap'), (31, 3, 'outBackSoft'), (d, 0, 'smooth')])
    a.key('motion', 'sy', [(0, 0.98, 'sine'), (5, 0.98, 'out'), (13, 1.09, 'outSoft'), (18, 1.08, 'in'),
                           (21, 0.97, 'outBack'), (23, 0.93, 'anticipate'), (26, 1.06, 'outSoft'),
                           (29, 0.94, 'snap'), (31, 1.02, 'outBackSoft'), (d, 1.0, 'smooth')])
    a.key('motion', 'sx', [(0, 1.01, 'sine'), (5, 1.01, 'out'), (13, 0.95, 'outSoft'), (18, 0.95, 'in'),
                           (21, 1.02, 'outBack'), (23, 1.05, 'anticipate'), (26, 0.96, 'outSoft'),
                           (29, 1.05, 'snap'), (31, 0.99, 'outBackSoft'), (d, 1.0, 'smooth')])
    a.key('motion', 'rot', [(0, 4, 'sine'), (5, 4, 'out'), (13, -2, 'outSoft'), (16, 2, 'sine'),
                            (18, -1, 'in'), (21, 0, 'smooth'), (d, 0, 'smooth')])
    a.key('head', 'rot', [(0, 12, 'sine'), (5, 12, 'out'), (13, -6, 'outSoft'), (18, -5, 'in'),
                          (21, 3, 'outBack'), (26, -4, 'outSoft'), (30, 2, 'settle'), (d, 0, 'smooth')])
    a.key('head', 'y', [(0, head_y + 6, 'sine'), (5, head_y + 6, 'out'), (13, head_y - 4, 'outSoft'),
                        (21, head_y, 'outBack'), (d, head_y, 'smooth')])
    a.key('armL', 'rot', [(0, ARM_TUCK_L, 'sine'), (5, ARM_TUCK_L, 'out'), (13, ARM_HIGH_L, 'outSoft'),
                          (16, ARM_HIGH_L - 8, 'sine'), (18, ARM_HIGH_L, 'in'), (21, ARM_OUT_L, 'outBack'),
                          (23, ARM_TUCK_L + 20, 'anticipate'), (26, ARM_UP_L, 'outBack'),
                          (d, ARM_UP_L - 6, 'smooth')])
    a.key('armR', 'rot', [(0, ARM_TUCK_R, 'sine'), (5, ARM_TUCK_R, 'out'), (13, -ARM_HIGH_L, 'outSoft'),
                          (16, -ARM_HIGH_L + 8, 'sine'), (18, -ARM_HIGH_L, 'in'), (21, -ARM_OUT_L, 'outBack'),
                          (23, ARM_TUCK_R - 20, 'anticipate'), (26, ARM_UP_R, 'outBack'),
                          (28, ARM_UP_R + 22, 'sine'), (30, ARM_UP_R - 4, 'sine'), (32, ARM_UP_R + 22, 'sine'),
                          (d, ARM_UP_R, 'smooth')])
    elbow_follow(a, 'L', gain=0.45)
    elbow_follow(a, 'R', gain=0.45)
    tl, tr = a.get('tuftL', 'rot'), a.get('tuftR', 'rot')
    a.key('tuftL', 'rot', [(0, tl - 18, 'sine'), (5, tl - 18, 'out'), (13, tl + 8, 'outSoft'),
                           (21, tl - 6, 'outBack'), (26, tl + 12, 'outSoft'), (30, tl - 4, 'settle'),
                           (d, tl, 'smooth')])
    a.key('tuftR', 'rot', [(0, tr + 20, 'sine'), (5, tr + 20, 'out'), (13, tr - 8, 'outSoft'),
                           (21, tr + 6, 'outBack'), (26, tr - 12, 'outSoft'), (30, tr + 4, 'settle'),
                           (d, tr, 'smooth')])
    a.key('shadow', 'sx', [(0, 1.0, 'sine'), (23, 1.04, 'anticipate'), (26, 0.78, 'outSoft'),
                           (29, 1.06, 'snap'), (d, 1.0, 'smooth')])
    mouth_morph(a, [(0, 'tiny', 'smooth'), (6, 'tiny', 'out'), (11, 'agape', 'outSoft'),
                    (17, 'agape', 'in'), (20, 'small', 'smooth'), (22, 'o', 'outBack'),
                    (25, 'grin', 'outSoft'), (d, 'grin', 'smooth')])
    for e in anim.EYES:
        b = a.get(e, 'sy')
        a.key(e, 'sy', [(0, b * 0.1, 'hold'), (18, b * 0.1, 'lidUp'), (20, b * 1.2, 'outBack'),
                        (22, b, 'smooth'), (25, b * 0.86, 'smooth'), (d, b * 0.86, 'smooth')])
    for dt in anim.DOTS:
        sdot = a.get(dt, 'sx')
        a.key(dt, 'sx', [(0, 0.0, 'hold'), (18, 0.0, 'lidUp'), (20, sdot, 'smooth'), (d, sdot, 'smooth')])
    for side, sign in (('L', -1), ('R', 1)):
        b = 'brow' + side
        y = a.get(b, 'y')
        a.key(b, 'y', [(0, y, 'sine'), (18, y, 'out'), (20, y - 9, 'outBack'), (24, y - 5, 'smooth'),
                       (d, y - 5, 'smooth')])
    for track, keys in a.keys.items():
        a.keys[track] = sorted({round(f * 0.8): (round(f * 0.8), v, e) for f, v, e in keys}.values())
    a.dur = 28


STATES = [
    ('idle', _idle), ('wave', _wave), ('think', _think), ('cheer', _cheer),
    ('sleep', _sleep), ('sad', _sad), ('wow', _wow), ('determined', _determined),
    ('confused', _confused), ('happy', _happy), ('excited', _excited),
    ('laughing', _laughing), ('proud', _proud), ('loved', _loved),
    ('surprised', _surprised), ('tired', _tired), ('shy', _shy), ('focused', _focused),
    ('act_achieved', _act_achieved), ('act_highfive', _act_highfive),
    ('act_idea', _act_idea), ('act_reading', _act_reading),
    ('act_solving', _act_solving), ('act_studying', _act_studying),
    ('adaptive', _adaptive), ('chat', _chat), ('cta', _cta), ('hero', _hero),
    ('mastery', _mastery), ('practice', _practice), ('upload', _upload),
    ('studying', _studying),
    ('turn_front', _turn('front', 23)), ('turn_back', _turn('back', 24)),
    ('turn_side', _turn('side', 25)),
    ('turn_three_quarter', _turn('three_quarter', 26)),
    ('turn_three_quarter_back', _turn('three_quarter_back', 27)),
    ('cheering', _cheer),
    ('peek_left', _peek('left')), ('peek_right', _peek('right')),
    ('dissolve_in', _dissolve_in), ('dissolve_out', _dissolve_out), ('summon', _summon),
    ('encourage', _encourage), ('celebrate_small', _celebrate_small),
    ('celebrate_big', _celebrate_big), ('sleepy', _sleepy),
    ('thinking', 'think'), ('sleeping', 'sleep'), ('celebrate', 'celebrate_big'),
    ('cover_eyes', _cover_eyes),
    ('act_laptop', _act_laptop),
    ('wake_up', _wake_up),
]

STATIC_NAME = 'idle_static'


ALIASES = {name: target for name, target in STATES if isinstance(target, str)}
POSE_INDEX = {name: i for i, (name, _t) in enumerate(STATES)}


def build_all():
    out = []
    for name, fn in STATES:
        if isinstance(fn, str):
            continue
        a = A(name)
        fn(a)
        a.dur = int(round(a.dur))
        out.append(a)
    static = A(STATIC_NAME, seconds=1 / FPS)
    static.dur = 1
    mouth(static, 'smile')
    out.append(static)
    return out
