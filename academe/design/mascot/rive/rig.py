C = dict(
    hi='#B8B9FF', mid='#8B8CF5', lo='#6A6CD0', face='#FFFEFF',
    eye='#1A1B32', mouth='#2A2A40', tongue='#E07A8A', white='#FFFFFF',
)

ARTBOARD = 440.0
ROOT = 220.0
HEAD_Y = 58.0


def rad(start, end, stops):
    return dict(type='radial', start=start, end=end, stops=stops)


def solid(c, a=1.0):
    return dict(type='solid', color=c, alpha=a)


BODY_BASE = rad((-66, -92), (120, 128), [
    (0.00, C['hi']), (0.14, '#A5A7FC'), (0.32, C['mid']), (0.55, '#7A7CE2'), (0.78, C['lo']), (1.00, '#565AB6')])
BODY_SHEEN = rad((-54, -84), (-12, -46), [
    (0.00, '#FFFFFF', 0.14), (0.55, '#FFFFFF', 0.04), (1.00, '#FFFFFF', 0.0)])
BODY_BOUNCE = rad((-8, 112), (58, 112), [
    (0.00, '#AEB0FF', 0.16), (0.60, '#AEB0FF', 0.05), (1.00, '#AEB0FF', 0.0)])

LIMB_L_BASE = rad((-14, 0), (-14, 104), [
    (0.00, '#898AF3'), (0.30, '#8183EA'), (0.68, '#7477DC'), (1.00, '#6467C9')])
LIMB_R_BASE = rad((14, 0), (14, 104), [
    (0.00, '#7274D9'), (0.30, '#6D70D3'), (0.68, '#6366C8'), (1.00, '#585BB8')])
PAW_SHEEN_L = rad((-30, 70), (-8, 92), [
    (0.00, '#FFFFFF', 0.16), (1.00, '#FFFFFF', 0.0)])
PAW_SHEEN_R = rad((30, 70), (8, 92), [
    (0.00, '#FFFFFF', 0.11), (1.00, '#FFFFFF', 0.0)])

TUFT_L_BASE = rad((2, -50), (2, 6), [
    (0.00, '#CBCCFF'), (0.42, C['hi']), (0.78, '#ACAEFD'), (1.00, '#A2A4FB')])
TUFT_R_BASE = rad((0, -32), (0, 6), [
    (0.00, '#B7B8FE'), (0.50, '#A0A2F9'), (1.00, '#8A8CF2')])
TUFT_SHEEN = rad((-6, -40), (2, -26), [(0.00, '#FFFFFF', 0.22), (1.00, '#FFFFFF', 0.0)])

# Cover paws: same limb tones, lit from the top-left like the body.
COVER_BASE = rad((-12, -22), (8, 30), [
    (0.00, '#A2A4FB'), (0.40, C['mid']), (1.00, '#6E71D6')])
COVER_SHEEN = rad((-12, -16), (-2, -4), [(0.00, '#FFFFFF', 0.20), (1.00, '#FFFFFF', 0.0)])

BOOK_COVER = rad((-40, -40), (90, 60), [
    (0.00, '#FFD266'), (0.45, '#F5A800'), (1.00, '#D98E00')])
BOOK_PAGE = rad((0, -40), (0, 50), [
    (0.00, '#FFFFFF'), (0.70, '#FFFCF3'), (1.00, '#F2EBDA')])
BOOK_LINE = solid('#D8D4E8')
BOOK_SPINE = solid('#C98200')

LAPTOP_BODY = rad((-60, -30), (80, 40), [
    (0.00, '#5B5F73'), (0.55, '#3E4152'), (1.00, '#2A2C38')])
LAPTOP_SCREEN = rad((-20, -30), (60, 40), [
    (0.00, '#9FA3FF'), (0.60, '#6E72E8'), (1.00, '#5054C8')])
LAPTOP_KEYS = solid('#CFD2DE')
LAPTOP_GLOW = rad((0, 0), (90, 0), [(0.0, '#B8B9FF', 0.35), (1.0, '#B8B9FF', 0.0)])

FOOT_L_BASE = rad((0, -17), (0, 17), [(0.00, '#7072D7'), (0.45, '#6669CB'), (1.00, '#585BB6')])
FOOT_R_BASE = rad((0, -17), (0, 17), [(0.00, '#696BCF'), (0.45, '#6063C4'), (1.00, '#5356B0')])

FACE_BASE = solid(C['face'])
FACE_AO = rad((0, -14), (0, 74), [
    (0.00, '#FFFFFF', 0.0), (0.70, '#F1EFF8', 0.0), (0.92, '#E4E1F1', 0.30), (1.00, '#DAD6EC', 0.52)])

EYE_BASE = solid(C['eye'])
EYE_BOUNCE = rad((0, 14), (0, 30), [
    (0.00, '#343858', 0.55), (0.50, '#24273F', 0.22), (1.00, '#1A1B32', 0.0)])

SHADOW_GRAD = rad((0, 0), (84, 0), [(0.0, '#000000', 0.26), (0.5, '#000000', 0.13), (1.0, '#000000', 0.0)])


def fill(paint, handle=None):
    return dict(kind='fill', paint=paint, handle=handle)


def stroke(paint, thickness, handle=None, trim=None):
    return dict(kind='stroke', paint=paint, thickness=thickness, cap=1, join=1,
                handle=handle, trim=trim)


def rect(w, h, r, x=0, y=0, rot=0, ox=0.5, oy=0.5):
    tl, tr, bl, br = (r, r, r, r) if isinstance(r, (int, float)) else r
    return dict(kind='rect', x=x, y=y, rot=rot, w=w, h=h, ox=ox, oy=oy, tl=tl, tr=tr, bl=bl, br=br)


def ell(w, h, x=0, y=0, rot=0, ox=0.5, oy=0.5):
    return dict(kind='ellipse', x=x, y=y, rot=rot, w=w, h=h, ox=ox, oy=oy)


H = -HEAD_Y

# Forearm, palm, then three finger pads (drawn in that order, palm over arm).
# The forearm runs down from under the palm to the body's lower edge, elbow down,
# so the hand reads as one limb instead of a paw pasted on the face. Paw-local
# coordinates; the part itself is rotated 18 degrees, hence the odd angles.
# Without the pads the paws read as blobs rather than hands.
def _cover_paw(side):
    m = -1 if side == 'L' else 1
    return [rect(104, 34, 17, x=m * 28, y=33, rot=m * 47.0),
            ell(58, 48, y=4), ell(17, 20, x=-17, y=-19), ell(18, 22, x=0, y=-23),
            ell(17, 20, x=17, y=-19)]

PARTS = [
    dict(name='shadow', parent='motion', x=0, y=150, paints=[fill(SHADOW_GRAD)], paths=[ell(168, 28)]),
    dict(name='footL', parent='motion', x=-47, y=135, paints=[fill(FOOT_L_BASE)], paths=[rect(53, 33, 16)]),
    dict(name='footR', parent='motion', x=47, y=135, paints=[fill(FOOT_R_BASE)], paths=[rect(53, 33, 16)]),
    dict(name='armL', parent='motion', x=-95, y=11, rot=4,
         paints=[fill(LIMB_L_BASE), fill(PAW_SHEEN_L)],
         skin=dict(upper='armLUpper', fore='armLFore', seg=50.0, span=(4.0, 96.0)),
         paths=[ell(42, 100, x=-16.4, oy=0.0), ell(20, 26, x=-33, y=66, rot=-24)]),
    dict(name='armR', parent='motion', x=95, y=11, rot=-4,
         paints=[fill(LIMB_R_BASE), fill(PAW_SHEEN_R)],
         skin=dict(upper='armRUpper', fore='armRFore', seg=50.0, span=(4.0, 96.0)),
         paths=[ell(42, 100, x=16.4, oy=0.0), ell(20, 26, x=33, y=66, rot=24)]),
    dict(name='tuftL', parent='motion', x=-14, y=-93, paints=[fill(TUFT_L_BASE), fill(TUFT_SHEEN)],
         paths=[ell(28, 41, x=-11, y=-16, rot=-16), ell(33, 51, x=18, y=-25, rot=4)]),
    dict(name='tuftR', parent='motion', x=38, y=-93, paints=[fill(TUFT_R_BASE)],
         paths=[ell(26, 33, x=-1, y=-13, rot=46)]),
    dict(name='body', parent='motion', x=0, y=14.1, paints=[fill(BODY_BASE), fill(BODY_BOUNCE), fill(BODY_SHEEN)],
         paths=[rect(209, 222.6, (80, 80, 57, 57))]),
    dict(name='face', parent='head', x=0, y=H - 7, paints=[fill(FACE_BASE), fill(FACE_AO)], paths=[rect(149, 118, 44)]),
    dict(name='browL', parent='head', x=-32, y=H - 42, rot=-8, paints=[fill(solid(C['eye']))],
         paths=[rect(21, 7.4, 3.7)]),
    dict(name='browR', parent='head', x=32, y=H - 42, rot=8, paints=[fill(solid(C['eye']))],
         paths=[rect(21, 7.4, 3.7)]),
    dict(name='eyeL', parent='head', x=-31, y=H - 3.5,
         paints=[fill(EYE_BASE, handle='eyeLFill'), fill(EYE_BOUNCE, handle='eyeLGloss'),
                 stroke(solid(C['eye'], 0.0), 7.0, handle='eyeLStroke',
                        trim=dict(start=0.34, end=0.66, offset=0.5, mode=1, handle='eyeLTrim'))],
         paths=[ell(26.5, 40.5)]),
    dict(name='eyeR', parent='head', x=31, y=H - 3.5,
         paints=[fill(EYE_BASE, handle='eyeRFill'), fill(EYE_BOUNCE, handle='eyeRGloss'),
                 stroke(solid(C['eye'], 0.0), 7.0, handle='eyeRStroke',
                        trim=dict(start=0.34, end=0.66, offset=0.5, mode=1, handle='eyeRTrim'))],
         paths=[ell(26.5, 40.5)]),
    dict(name='eyeLdot', parent='head', x=-33, y=H - 14, paints=[fill(solid(C['white']))], paths=[ell(11, 11)]),
    dict(name='eyeRdot', parent='head', x=29, y=H - 14, paints=[fill(solid(C['white']))], paths=[ell(11, 11)]),
    dict(name='mouth', parent='head', x=0, y=H + 25, sx=1.0, sy=1.0,
         paints=[fill(solid(C['mouth'], 0.0), handle='mouthFill'),
                 stroke(solid(C['mouth'], 1.0), 7.5, handle='mouthStroke',
                        trim=dict(start=0.36, end=0.64, offset=0.0, mode=1, handle='mouthTrim'))],
         paths=[ell(46, 34)]),
    dict(name='tongue', parent='head', x=0, y=H + 31, sx=1.0, sy=0.0, paints=[fill(solid(C['tongue']))],
         paths=[ell(22, 11)]),
    dict(name='bookCover', parent='motion', x=0, y=86, opacity=0.0, paints=[fill(BOOK_COVER)],
         paths=[rect(108, 88, 14, x=-51, rot=-9), rect(108, 88, 14, x=51, rot=9)]),
    dict(name='bookPages', parent='motion', x=0, y=82, opacity=0.0, paints=[fill(BOOK_PAGE)],
         paths=[rect(96, 76, 10, x=-47, rot=-9), rect(96, 76, 10, x=47, rot=9)]),
    dict(name='bookLines', parent='motion', x=0, y=82, opacity=0.0, paints=[fill(BOOK_LINE)],
         paths=[rect(58, 5, 2.5, x=-50, y=y + 7.5, rot=-9) for y in (-26, -12, 2)]
         + [rect(40, 5, 2.5, x=-58, y=23, rot=-9)]
         + [rect(58, 5, 2.5, x=50, y=y + 7.5, rot=9) for y in (-26, -12, 2)]
         + [rect(40, 5, 2.5, x=42, y=23, rot=9)]),
    dict(name='bookSpine', parent='motion', x=0, y=84, opacity=0.0, paints=[fill(BOOK_SPINE)],
         paths=[rect(8, 84, 4)]),
    dict(name='bookPawL', parent='motion', x=-100, y=84, rot=-20, opacity=0.0,
         paints=[fill(COVER_BASE), fill(COVER_SHEEN)], paths=[ell(38, 46), ell(15, 17, x=10, y=-18)]),
    dict(name='bookPawR', parent='motion', x=100, y=84, rot=20, opacity=0.0,
         paints=[fill(COVER_BASE), fill(COVER_SHEEN)], paths=[ell(38, 46), ell(15, 17, x=-10, y=-18)]),
    dict(name='laptopGlow', parent='motion', x=0, y=40, opacity=0.0, paints=[fill(LAPTOP_GLOW)],
         paths=[ell(200, 90)]),
    dict(name='laptopLid', parent='motion', x=0, y=84, opacity=0.0, paints=[fill(LAPTOP_BODY)],
         paths=[rect(176, 92, 14)]),
    dict(name='laptopScreen', parent='motion', x=0, y=82, opacity=0.0, paints=[fill(LAPTOP_SCREEN)],
         paths=[rect(158, 74, 9)]),
    dict(name='laptopLogo', parent='motion', x=0, y=82, opacity=0.0, paints=[fill(solid('#FFFFFF', 0.85))],
         paths=[rect(22, 22, 6, rot=45), rect(10, 10, 3, rot=45)]),
    dict(name='laptopBase', parent='motion', x=0, y=132, opacity=0.0, paints=[fill(LAPTOP_BODY)],
         paths=[rect(212, 16, 8)]),
    dict(name='laptopKeys', parent='motion', x=0, y=131, opacity=0.0, paints=[fill(LAPTOP_KEYS)],
         paths=[rect(150, 5, 2.5)]),
    dict(name='typePawL', parent='motion', x=-70, y=126, rot=-10, opacity=0.0,
         paints=[fill(COVER_BASE), fill(COVER_SHEEN)], paths=[ell(40, 30)]),
    dict(name='typePawR', parent='motion', x=70, y=126, rot=10, opacity=0.0,
         paints=[fill(COVER_BASE), fill(COVER_SHEEN)], paths=[ell(40, 30)]),
    *[dict(name=name, parent='root', x=70, y=-96, sx=scale, sy=scale, opacity=0.0,
           paints=[fill(solid(C['mid']))],
           paths=[rect(26, 6, 3, y=-11), rect(26, 6, 3, y=11), rect(34, 6, 3, rot=-40)])
      for name, scale in (('zzzA', 0.9), ('zzzB', 0.9), ('zzzC', 0.9))],
    # Last in the list, so drawn over the face. Parked below it at opacity 0;
    # cover_eyes lifts them onto the eyes and the pose blend reads as a reach.
    dict(name='coverL', parent='head', x=-35, y=H + 74, rot=18, opacity=0.0,
         paints=[fill(COVER_BASE), fill(COVER_SHEEN)], paths=_cover_paw('L')),
    dict(name='coverR', parent='head', x=35, y=H + 74, rot=-18, opacity=0.0,
         paints=[fill(COVER_BASE), fill(COVER_SHEEN)], paths=_cover_paw('R')),
]

NODES = [
    dict(name='root', parent=None, x=ROOT, y=ROOT),
    dict(name='motion', parent='root', x=0.0, y=0.0),
    dict(name='head', parent='motion', x=0.0, y=HEAD_Y),
]

BONES = [
    dict(name='armLUpper', parent='motion', root=(-95.0, 11.0), rot=94.0, length=50.0),
    dict(name='armLFore', parent='armLUpper', rot=0.0, length=52.0),
    dict(name='armRUpper', parent='motion', root=(95.0, 11.0), rot=86.0, length=50.0),
    dict(name='armRFore', parent='armRUpper', rot=0.0, length=52.0),
]

NAMES = [p['name'] for p in PARTS]
