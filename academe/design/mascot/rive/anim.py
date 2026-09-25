import math
import rig

FPS = 12

ANIMATED = [
    ('motion', 'opacity'),
    ('motion', 'x'), ('motion', 'y'), ('motion', 'rot'), ('motion', 'sx'), ('motion', 'sy'),
    ('head', 'x'), ('head', 'y'), ('head', 'rot'), ('head', 'sx'), ('head', 'sy'),
    ('armL', 'rot'), ('armR', 'rot'),
    ('armLBend', 'rot'), ('armRBend', 'rot'),
    ('tuftL', 'rot'), ('tuftR', 'rot'),
    ('face', 'x'), ('face', 'sx'), ('face', 'sy'),
    ('eyeL', 'x'), ('eyeL', 'y'), ('eyeL', 'sx'), ('eyeL', 'sy'),
    ('eyeR', 'x'), ('eyeR', 'y'), ('eyeR', 'sx'), ('eyeR', 'sy'),
    ('eyeLdot', 'x'), ('eyeLdot', 'y'), ('eyeLdot', 'sx'),
    ('eyeRdot', 'x'), ('eyeRdot', 'y'), ('eyeRdot', 'sx'),
    ('browL', 'x'), ('browL', 'y'), ('browL', 'rot'), ('browL', 'sx'),
    ('browR', 'x'), ('browR', 'y'), ('browR', 'rot'), ('browR', 'sx'),
    ('mouth', 'x'), ('mouth', 'y'), ('mouth', 'sx'), ('mouth', 'sy'),
    ('eyeLFill', 'alpha'), ('eyeLGloss', 'opacity'), ('eyeLStroke', 'alpha'),
    ('eyeLTrim', 'start'), ('eyeLTrim', 'end'),
    ('eyeRFill', 'alpha'), ('eyeRGloss', 'opacity'), ('eyeRStroke', 'alpha'),
    ('eyeRTrim', 'start'), ('eyeRTrim', 'end'),
    ('mouthTrim', 'start'), ('mouthTrim', 'end'), ('mouthTrim', 'offset'),
    ('mouthFill', 'alpha'), ('mouthStroke', 'alpha'), ('mouthStroke', 'thickness'),
    ('tongue', 'sy'),
    ('shadow', 'sx'), ('shadow', 'sy'),
    ('footL', 'y'), ('footR', 'y'),
    ('coverL', 'y'), ('coverL', 'opacity'), ('coverR', 'y'), ('coverR', 'opacity'),
    ('bookCover', 'opacity'), ('bookPages', 'opacity'), ('bookLines', 'opacity'),
    ('bookSpine', 'opacity'), ('bookPawL', 'opacity'), ('bookPawR', 'opacity'),
    ('bookPages', 'sx'), ('bookLines', 'sx'),
    ('laptopGlow', 'opacity'), ('laptopGlow', 'sx'), ('laptopLid', 'opacity'), ('laptopScreen', 'opacity'),
    ('laptopLogo', 'opacity'), ('laptopLogo', 'rot'), ('laptopBase', 'opacity'), ('laptopKeys', 'opacity'),
    ('typePawL', 'opacity'), ('typePawL', 'y'), ('typePawR', 'opacity'), ('typePawR', 'y'),
    *[(z, prop) for z in ('zzzA', 'zzzB', 'zzzC')
      for prop in ('opacity', 'x', 'y', 'sx', 'sy', 'rot')],
]

REST = {}
for _n in rig.NODES:
    REST[_n['name']] = dict(x=_n['x'], y=_n['y'], rot=0.0, sx=1.0, sy=1.0, opacity=1.0)
REST['motion'] = dict(x=0.0, y=0.0, rot=0.0, sx=1.0, sy=1.0, opacity=1.0)
REST['head'] = dict(x=0.0, y=rig.HEAD_Y, rot=0.0, sx=1.0, sy=1.0, opacity=1.0)
REST['root'] = dict(x=rig.ROOT, y=rig.ROOT, rot=0.0, sx=1.0, sy=1.0, opacity=1.0)
for _p in rig.PARTS:
    REST[_p['name']] = dict(x=_p.get('x', 0.0), y=_p.get('y', 0.0), rot=_p.get('rot', 0.0),
                            sx=_p.get('sx', 1.0), sy=_p.get('sy', 1.0),
                            opacity=_p.get('opacity', 1.0))
_mt = next(e['trim'] for p in rig.PARTS if p['name'] == 'mouth'
           for e in p['paints'] if e.get('trim'))
REST['mouthTrim'] = dict(start=_mt['start'], end=_mt['end'], offset=_mt['offset'])
for _side in ('L', 'R'):
    REST['eye%sFill' % _side] = dict(alpha=1.0)
    REST['eye%sGloss' % _side] = dict(opacity=1.0)
    REST['eye%sStroke' % _side] = dict(alpha=0.0)
    REST['eye%sTrim' % _side] = dict(start=0.34, end=0.66)
REST['armLBend'] = dict(rot=0.0)
REST['armRBend'] = dict(rot=0.0)
REST['mouthFill'] = dict(alpha=0.0)
REST['mouthStroke'] = dict(alpha=1.0, thickness=7.5)

EYES = ('eyeL', 'eyeR')
DOTS = ('eyeLdot', 'eyeRdot')
BROWS = ('browL', 'browR')
GAZE = EYES + DOTS


class A:
    def __init__(self, name, seconds=8.0, loop=1):
        self.name = name
        self.dur = int(round(seconds * FPS))
        self.loop = loop
        self.const = {}
        self.keys = {}

    def set(self, part, prop, v):
        self.const[(part, prop)] = float(v)

    def get(self, part, prop):
        return self.const.get((part, prop), REST[part][prop])

    def key(self, part, prop, frames):
        out = []
        for f in frames:
            frame, value = f[0], f[1]
            ease = f[2] if len(f) > 2 else 'smooth'
            out.append((float(frame), float(value), ease))
        self.keys[(part, prop)] = sorted(out)

    def track(self, part, prop):
        return self.keys.get((part, prop))

    def close_loop(self):
        for pp, ks in self.keys.items():
            if self.loop != 1 or not ks:
                continue
            if ks[0][0] > 0:
                ks.insert(0, (0.0, ks[0][1], ks[0][2]))
            if ks[-1][0] < self.dur:
                ks.append((float(self.dur), ks[0][1], ks[-1][2]))
            elif abs(ks[-1][1] - ks[0][1]) > 1e-6:
                ks[-1] = (ks[-1][0], ks[0][1], ks[-1][2])

    def timeline(self):
        self.close_loop()
        out = {}
        for pp in ANIMATED:
            ks = self.keys.get(pp)
            out[pp] = ks if ks else [(0.0, float(self.get(*pp)), 'smooth')]
        return out


def sample(ks, frame):
    if not ks:
        return None
    if frame <= ks[0][0]:
        return ks[0][1]
    if frame >= ks[-1][0]:
        return ks[-1][1]
    for i in range(len(ks) - 1):
        f0, v0, _ = ks[i]
        f1, v1, _ = ks[i + 1]
        if f0 <= frame <= f1:
            t = 0.0 if f1 == f0 else (frame - f0) / (f1 - f0)
            t = t * t * (3 - 2 * t)
            return v0 + (v1 - v0) * t
    return ks[-1][1]


SAMPLES = 48


def layered(dur, harmonics, base=0.0, ease='sine', samples=None):
    """harmonics: [(cycles, amp, phase)]. Coprime cycle counts keep the composite
    from repeating inside the loop while still closing on it exactly."""
    n = samples or SAMPLES
    pts = []
    for i in range(n + 1):
        t = i / n
        v = base + sum(amp * math.sin(2 * math.pi * (cyc * t + ph)) for cyc, amp, ph in harmonics)
        pts.append((dur * t, v, ease))
    return pts


COPRIME = [(3, 1.0, 0.0), (5, 0.34, 0.31), (7, 0.17, 0.62)]


def _mix(scale, phase=0.0, sets=COPRIME):
    return [(c, a * scale, p + phase) for c, a, p in sets]


def breathe(a, amp=0.011, lift=0.45, phase=0.0):
    d = a.dur
    a.key('motion', 'sy', layered(d, _mix(amp, phase), 1.0))
    a.key('motion', 'sx', layered(d, _mix(-amp * lift, phase), 1.0))
    a.key('motion', 'y', layered(d, _mix(-amp * 46, phase), a.get('motion', 'y')))
    a.key('head', 'y', layered(d, _mix(-amp * 30, phase - 0.06), a.get('head', 'y')))
    a.key('tuftL', 'rot', layered(d, _mix(-amp * 210, phase - 0.13), a.get('tuftL', 'rot')))
    a.key('tuftR', 'rot', layered(d, _mix(amp * 240, phase - 0.16), a.get('tuftR', 'rot')))
    a.key('armL', 'rot', layered(d, _mix(amp * 130, phase - 0.11), a.get('armL', 'rot')))
    a.key('armR', 'rot', layered(d, _mix(-amp * 140, phase - 0.09), a.get('armR', 'rot')))


def head_life(a, tilt=1.5, drift=2.0):
    d = a.dur
    a.key('head', 'rot', layered(d, [(2, tilt, 0.11), (3, tilt * 0.42, 0.57), (5, tilt * 0.2, 0.28)],
                                 a.get('head', 'rot')))
    a.key('head', 'x', layered(d, [(2, drift, 0.36), (3, drift * 0.38, 0.05)], a.get('head', 'x')))


def sway(a, deg=2.2):
    d = a.dur
    a.key('motion', 'rot', layered(d, [(2, deg, 0.0), (3, deg * 0.33, 0.44)], 0.0))
    a.key('head', 'rot', layered(d, [(2, deg * 0.5, -0.1), (3, deg * 0.2, 0.34)],
                                 a.get('head', 'rot')))


def action(a, part, prop, start, to, at, anticipation=0.16, over=0.10,
           lead=2, rise=3, settle=4):
    """Anticipation, then the move overshooting past the target, then a settle."""
    delta = to - start
    return [(at - lead, start, 'anticipate'),
            (at, start - delta * anticipation, 'outBack'),
            (at + rise, to + delta * over, 'settle'),
            (at + rise + settle, to, 'smooth')]


BLINK_CLOSE, BLINK_HOLD, BLINK_OPEN = 2, 1, 3


def _blink_at(a, f, depth=0.06):
    """A lid closing is an arc, not a flattened oval: the eye fill fades out and
    the stroke arc fades in across the two closing frames."""
    shut = f + BLINK_CLOSE
    open_ = f + BLINK_CLOSE + BLINK_HOLD + BLINK_OPEN
    hold = f + BLINK_CLOSE + BLINK_HOLD
    out = []
    for side, e in zip('LR', EYES):
        base_sy, base_sx, by = a.get(e, 'sy'), a.get(e, 'sx'), a.get(e, 'y')
        out.append((e, 'sy', [(f, base_sy, 'lidDown'), (shut, max(base_sy * 0.40, 0.30), 'hold'),
                              (hold, max(base_sy * 0.40, 0.30), 'lidUp'),
                              (open_, base_sy, 'smooth')]))
        out.append((e, 'sx', [(f, base_sx, 'lidDown'), (shut, base_sx * 1.02, 'hold'),
                              (hold, base_sx * 1.02, 'lidUp'), (open_, base_sx, 'smooth')]))
        out.append((e, 'y', [(f, by, 'lidDown'), (shut, by + 6, 'hold'),
                             (hold, by + 6, 'lidUp'), (open_, by, 'smooth')]))
        fill_a = a.get('eye%sFill' % side, 'alpha')
        gloss = a.get('eye%sGloss' % side, 'opacity')
        stroke_a = a.get('eye%sStroke' % side, 'alpha')
        out.append(('eye%sFill' % side, 'alpha',
                    [(f, fill_a, 'lidDown'), (shut, 0.0, 'hold'), (hold, 0.0, 'lidUp'),
                     (open_, fill_a, 'smooth')]))
        out.append(('eye%sGloss' % side, 'opacity',
                    [(f, gloss, 'lidDown'), (shut, 0.0, 'hold'), (hold, 0.0, 'lidUp'),
                     (open_, gloss, 'smooth')]))
        out.append(('eye%sStroke' % side, 'alpha',
                    [(f, stroke_a, 'lidDown'), (shut, 1.0, 'hold'), (hold, 1.0, 'lidUp'),
                     (open_, stroke_a, 'smooth')]))
    for dt in DOTS:
        sx = a.get(dt, 'sx')
        out.append((dt, 'sx', [(f, sx, 'lidDown'), (shut, 0.0, 'hold'),
                               (hold, 0.0, 'lidUp'), (open_, sx, 'smooth')]))
    return out


def blinks(a, at):
    merged = {}
    for f in at:
        for part, prop, ks in _blink_at(a, f % a.dur):
            merged.setdefault((part, prop), []).extend(ks)
    for (part, prop), ks in merged.items():
        base = a.get(part, prop)
        pts = [(0.0, base, 'smooth')] + sorted(ks) + [(float(a.dur), base, 'smooth')]
        seen = {}
        for f, v, e in pts:
            if f <= a.dur:
                seen[round(f)] = (v, e)
        a.key(part, prop, [(f, v, e) for f, (v, e) in sorted(seen.items())])


def blink_schedule(dur, seed=0):
    """Irregular, occasionally doubled blinks."""
    out, f = [], 9 + (seed * 5) % 11
    i = 0
    while f < dur - 8:
        out.append(f)
        double = (i + seed) % 3 == 1
        if double and f + 9 < dur - 8:
            out.append(f + 9)
            f += 9
        gap = [26, 34, 22, 41, 29, 37][(i + seed) % 6]
        f += gap
        i += 1
    return out


TREMOR = [0.0, 0.34, -0.22, 0.41, -0.15, 0.28, -0.36, 0.12]


def gaze(a, script, tremor=True):
    """script: [(frame, dx, dy, ease)] — eyes and highlights move together."""
    for i, e in enumerate(GAZE):
        bx, by = a.get(e, 'x'), a.get(e, 'y')
        xs, ys = [], []
        for j, (f, dx, dy, es) in enumerate(script):
            n = TREMOR[(j + i * 3) % len(TREMOR)] if tremor else 0.0
            m = TREMOR[(j + i * 3 + 5) % len(TREMOR)] if tremor else 0.0
            xs.append((f, bx + dx + n, es))
            ys.append((f, by + dy + m * 0.7, es))
        a.key(e, 'x', xs)
        a.key(e, 'y', ys)


SACCADE = 1


def saccades(a, reach=3.4, seed=0):
    """Real eyes jump and fix; they never glide. Two-frame jump, long hold."""
    d = a.dur
    targets = [(0.0, 0.0), (reach, -1.1), (-reach * 0.85, 0.7), (reach * 0.5, 1.5),
               (-reach * 0.45, -0.8), (0.0, 0.0)]
    if seed % 2:
        targets = [(-x, y) for x, y in targets]
    holds = [0.0, 0.14, 0.33, 0.55, 0.72, 0.9]
    script = []
    for (h, (dx, dy)) in zip(holds, targets):
        f = round(d * h)
        if f > 0:
            script.append((f - SACCADE, script[-1][1], script[-1][2], 'hold'))
        script.append((f + SACCADE, dx, dy, 'snap'))
    script.append((d, 0.0, 0.0, 'hold'))
    gaze(a, script)


def look(a, dx, dy):
    for e in GAZE:
        a.set(e, 'x', REST[e]['x'] + dx)
        a.set(e, 'y', a.get(e, 'y') + dy)


ARC_MODES = ('squint', 'closed')


def eyes(a, mode):
    for side, e in zip('LR', EYES):
        if mode == 'squint':
            a.set(e, 'sy', 0.86); a.set(e, 'sx', 1.05); a.set(e, 'y', REST[e]['y'] + 3)
            a.set('eye%sStroke' % side, 'thickness', 7.4)
            a.set('eye%sTrim' % side, 'start', 0.32); a.set('eye%sTrim' % side, 'end', 0.68)
        elif mode == 'closed':
            a.set(e, 'sy', 0.44); a.set(e, 'sx', 1.02); a.set(e, 'y', REST[e]['y'] + 7)
            a.set('eye%sStroke' % side, 'thickness', 6.8)
            a.set('eye%sTrim' % side, 'start', 0.30); a.set('eye%sTrim' % side, 'end', 0.70)
        elif mode == 'wide':
            a.set(e, 'sx', 1.18); a.set(e, 'sy', 1.22)
        elif mode == 'droop':
            a.set(e, 'sy', 0.56); a.set(e, 'y', REST[e]['y'] + 7)
        elif mode == 'narrow':
            a.set(e, 'sy', 0.80)
    if mode in ARC_MODES:
        for side in 'LR':
            a.set('eye%sFill' % side, 'alpha', 0.0)
            a.set('eye%sGloss' % side, 'opacity', 0.0)
            a.set('eye%sStroke' % side, 'alpha', 1.0)
        for dt in DOTS:
            a.set(dt, 'sx', 0.0)


def brows(a, mode):
    for b, sign in (('browL', 1.0), ('browR', -1.0)):
        y, r = REST[b]['y'], REST[b]['rot']
        if mode == 'raise':
            a.set(b, 'y', y - 8)
        elif mode == 'furrow':
            a.set(b, 'y', y + 5); a.set(b, 'rot', r + sign * 20)
        elif mode == 'sad':
            a.set(b, 'y', y - 3); a.set(b, 'rot', r - sign * 24)
        elif mode == 'worry':
            a.set(b, 'y', y - 2); a.set(b, 'rot', r - sign * 14)
        elif mode == 'flat':
            a.set(b, 'rot', 0.0)


MOUTHS = {
    'smile': (0.92, 0.80, 22.0, 0.0, 0.0, 0.355, 0.645, 0.0, 7.5),
    'grin':  (1.06, 0.98, 21.0, 0.0, 0.0, 0.300, 0.700, 0.0, 8.2),
    'small': (0.62, 0.62, 24.0, 0.0, 0.0, 0.400, 0.600, 0.0, 6.6),
    'tiny':  (0.46, 0.46, 25.0, 0.0, 0.0, 0.420, 0.580, 0.0, 6.0),
    'flat':  (0.82, 0.30, 25.0, 0.0, 0.0, 0.390, 0.610, 0.0, 6.8),
    'frown': (0.80, 0.68, 30.0, 0.0, 0.0, 0.355, 0.645, 0.5, 6.8),
    'pout':  (0.56, 0.52, 28.0, 0.0, 0.0, 0.390, 0.610, 0.5, 6.4),
    'open':  (0.86, 0.80, 27.0, 1.0, 1.0, 0.355, 0.645, 0.0, 0.0),
    'wide':  (1.02, 1.12, 28.0, 1.0, 1.0, 0.300, 0.700, 0.0, 0.0),
    'o':     (0.54, 0.92, 27.0, 0.55, 1.0, 0.400, 0.600, 0.0, 0.0),
    'agape': (0.72, 1.22, 29.0, 0.80, 1.0, 0.360, 0.640, 0.0, 0.0),
}


def mouth(a, mode):
    sx, sy, y, tongue, fill, ts, te, off, thick = MOUTHS[mode]
    a.set('mouth', 'sx', sx)
    a.set('mouth', 'sy', sy)
    a.set('mouth', 'y', -rig.HEAD_Y + y)
    a.set('tongue', 'sy', tongue)
    a.set('mouthFill', 'alpha', fill)
    a.set('mouthStroke', 'alpha', 0.0 if fill else 1.0)
    a.set('mouthStroke', 'thickness', thick if thick else 7.5)
    a.set('mouthTrim', 'start', ts)
    a.set('mouthTrim', 'end', te)
    a.set('mouthTrim', 'offset', off)


def mouth_morph(a, frames):
    """frames: [(frame, mode, ease)] — every mouth channel crossfades together."""
    chans = {}
    for f, mode, es in frames:
        sx, sy, y, tongue, fill, ts, te, off, thick = MOUTHS[mode]
        vals = {('mouth', 'sx'): sx, ('mouth', 'sy'): sy, ('mouth', 'y'): -rig.HEAD_Y + y,
                ('tongue', 'sy'): tongue, ('mouthFill', 'alpha'): fill,
                ('mouthStroke', 'alpha'): 0.0 if fill else 1.0,
                ('mouthStroke', 'thickness'): thick if thick else 7.5,
                ('mouthTrim', 'start'): ts, ('mouthTrim', 'end'): te,
                ('mouthTrim', 'offset'): off}
        for k, v in vals.items():
            chans.setdefault(k, []).append((f, v, es))
    for (part, prop), ks in chans.items():
        a.key(part, prop, ks)


def arms(a, left=None, right=None, bend_l=None, bend_r=None):
    if left is not None:
        a.set('armL', 'rot', left)
    if right is not None:
        a.set('armR', 'rot', right)
    if bend_l is not None:
        a.set('armLBend', 'rot', bend_l)
    if bend_r is not None:
        a.set('armRBend', 'rot', bend_r)


def elbow_follow(a, side, gain=0.55, lag=1.4):
    """The forearm trails the shoulder: the elbow is what makes a wave read as
    an arm rather than a rotating stick."""
    src = a.track('arm%s' % side, 'rot')
    if not src:
        return
    base = a.get('arm%sBend' % side, 'rot')
    anchor = src[0][1]
    a.key('arm%sBend' % side, 'rot',
          [(f + lag, base + (v - anchor) * -gain, e) for f, v, e in src])


def face_view(a, mode):
    """Follows our turnaround art: the face slides to the viewer's
    left as he turns away, the body narrows to 0.875 in profile, and both rear
    angles show no face at all."""
    if mode == 'front':
        return
    if mode == 'three_quarter':
        a.set('motion', 'sx', 0.94)
        a.set('head', 'x', -6.0)
        a.set('face', 'x', -25.0); a.set('face', 'sx', 0.89)
        for e in ('eyeL', 'eyeLdot', 'browL'):
            a.set(e, 'x', REST[e]['x'] - 34); a.set(e, 'sx', a.get(e, 'sx') * 0.70)
        for e in ('eyeR', 'eyeRdot', 'browR'):
            a.set(e, 'x', REST[e]['x'] - 22)
        a.set('mouth', 'x', -24.0); a.set('mouth', 'sx', a.get('mouth', 'sx') * 0.92)
        a.set('tuftL', 'rot', 5.0); a.set('tuftR', 'rot', 5.0)
        a.set('armR', 'rot', -16.0)
    elif mode == 'side':
        a.set('motion', 'sx', 0.875)
        a.set('head', 'x', -12.0)
        a.set('face', 'x', -96.0); a.set('face', 'sx', 0.17); a.set('face', 'sy', 0.86)
        for e in ('eyeR', 'eyeRdot', 'browR'):
            a.set(e, 'sx', 0.0)
        a.set('eyeL', 'x', -99.0); a.set('eyeL', 'sx', 0.42)
        a.set('eyeLdot', 'x', -101.0); a.set('eyeLdot', 'sx', 0.42)
        a.set('browL', 'x', -99.0); a.set('browL', 'sx', 0.40)
        a.set('mouth', 'sx', 0.0)
        a.set('tongue', 'sy', 0.0)
        a.set('tuftL', 'rot', 12.0); a.set('tuftR', 'rot', 14.0)
        a.set('armL', 'rot', 26.0); a.set('armR', 'rot', -8.0)
    elif mode == 'three_quarter_back':
        a.set('motion', 'sx', 0.92)
        a.set('face', 'sx', 0.0)
        for e in GAZE + BROWS:
            a.set(e, 'sx', 0.0)
        a.set('mouth', 'sx', 0.0); a.set('tongue', 'sy', 0.0)
        a.set('head', 'x', 7.0)
        a.set('tuftL', 'rot', -9.0); a.set('tuftR', 'rot', -11.0)
        a.set('armL', 'rot', 22.0); a.set('armR', 'rot', -6.0)
    elif mode == 'back':
        a.set('motion', 'sx', 0.93)
        a.set('face', 'sx', 0.0)
        for e in GAZE + BROWS:
            a.set(e, 'sx', 0.0)
        a.set('mouth', 'sx', 0.0); a.set('tongue', 'sy', 0.0)
        a.set('armL', 'rot', 10.0); a.set('armR', 'rot', -10.0)
