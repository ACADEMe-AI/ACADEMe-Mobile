import struct

U, S, D, C = 0, 1, 2, 3
B = 4

T_ARTBOARD, T_NODE, T_SHAPE, T_ELLIPSE, T_RECT = 1, 2, 3, 4, 7
T_RADIAL, T_SOLID, T_STOP, T_FILL, T_LINEAR, T_BACKBOARD = 17, 18, 19, 20, 22, 23
T_KEYED_OBJECT, T_KEYED_PROPERTY = 25, 26
T_CUBIC_INTERP, T_KF_DOUBLE, T_LINEAR_ANIM, T_KF_COLOR = 28, 30, 31, 37
T_STATE_MACHINE, T_SM_NUMBER, T_SM_LAYER, T_SM_BOOL = 53, 56, 57, 59
T_ANIMATION_STATE, T_ANY_STATE, T_ENTRY_STATE, T_EXIT_STATE = 61, 62, 63, 64
T_STATE_TRANSITION = 65
T_TRANSITION_NUMBER_COND, T_TRANSITION_BOOL_COND = 70, 71
T_TRIM_PATH, T_STROKE_PAINT = 47, 24
T_POINTS_PATH, T_CUBIC_DETACHED = 16, 6
T_BONE, T_ROOT_BONE, T_SKIN, T_TENDON, T_WEIGHT, T_CUBIC_WEIGHT = 40, 41, 43, 44, 45, 46
T_BLEND_STATE_1D, T_BLEND_ANIM_1D = 76, 75

P_NAME, P_PARENT = 4, 5
P_AB_WIDTH, P_AB_HEIGHT, P_AB_X, P_AB_Y, P_AB_OX, P_AB_OY = 7, 8, 9, 10, 11, 12
P_X, P_Y, P_ROT, P_SX, P_SY, P_OPACITY = 13, 14, 15, 16, 17, 18
P_PATH_W, P_PATH_H, P_PATH_OX, P_PATH_OY = 20, 21, 123, 124
P_CORNER_TL, P_CORNER_TR, P_CORNER_BL, P_CORNER_BR, P_CORNER_LINK = 31, 161, 162, 163, 164
P_SOLID_COLOR, P_STOP_COLOR, P_STOP_POS, P_FILL_RULE = 37, 38, 39, 40
P_STROKE_THICKNESS, P_STROKE_CAP, P_STROKE_JOIN, P_STROKE_AFFECTED = 47, 48, 49, 50
P_TRIM_START, P_TRIM_END, P_TRIM_OFFSET, P_TRIM_MODE = 114, 115, 116, 117
P_KF_COLOR_VALUE = 88
P_BLEND_INPUT_ID, P_BLEND_VALUE, P_BLEND_ANIM_ID = 167, 166, 165
P_VERT_X, P_VERT_Y = 24, 25
P_IN_ROT, P_IN_DIST, P_OUT_ROT, P_OUT_DIST = 84, 85, 86, 87
P_PATH_CLOSED = 32
P_BONE_LENGTH, P_ROOT_X, P_ROOT_Y = 89, 90, 91
P_SKIN_XX, P_SKIN_YX, P_SKIN_XY, P_SKIN_YY, P_SKIN_TX, P_SKIN_TY = 104, 105, 106, 107, 108, 109
P_TEND_BONE, P_TEND_XX, P_TEND_YX, P_TEND_XY, P_TEND_YY, P_TEND_TX, P_TEND_TY = 95, 96, 97, 98, 99, 100, 101
P_W_VALUES, P_W_INDICES = 102, 103
P_W_IN_VALUES, P_W_IN_INDICES, P_W_OUT_VALUES, P_W_OUT_INDICES = 110, 111, 112, 113
P_GRAD_SX, P_GRAD_SY, P_GRAD_EX, P_GRAD_EY, P_GRAD_OPACITY = 42, 33, 34, 35, 46
P_ANIM_NAME, P_FPS, P_DURATION, P_SPEED, P_LOOP = 55, 56, 57, 58, 59
P_CUBIC_X1, P_CUBIC_Y1, P_CUBIC_X2, P_CUBIC_Y2 = 63, 64, 65, 66
P_KF_FRAME, P_KF_INTERP, P_KF_INTERP_ID, P_KF_VALUE = 67, 68, 69, 70
P_KEYED_OBJECT_ID, P_KEYED_PROPERTY_KEY = 51, 53
P_SM_NAME, P_SM_NUMBER_VALUE, P_SM_BOOL_VALUE = 138, 140, 141
P_ANIMATION_ID = 149
P_STATE_TO_ID, P_TRANSITION_FLAGS, P_TRANSITION_DURATION = 151, 152, 158
P_COND_INPUT_ID, P_COND_OP, P_COND_VALUE = 155, 156, 157

INTERP_HOLD, INTERP_LINEAR, INTERP_CUBIC = 0, 1, 2
OP_EQ, OP_NEQ = 0, 1


def varuint(v):
    out = bytearray()
    while True:
        b = v & 0x7F
        v >>= 7
        out.append(b | 0x80 if v else b)
        if not v:
            return bytes(out)


class Builder:
    """Collects core objects; index 0 of the artboard is the artboard itself."""

    def __init__(self):
        self._objs = []
        self._artboard_at = None

    def _add(self, type_key, props):
        self._objs.append((type_key, props))
        return len(self._objs) - 1

    def backboard(self):
        self._add(T_BACKBOARD, [])

    def artboard(self, name, w, h):
        idx = self._add(T_ARTBOARD, [
            (P_NAME, S, name), (P_AB_WIDTH, D, w), (P_AB_HEIGHT, D, h),
            (P_AB_X, D, 0.0), (P_AB_Y, D, 0.0), (P_AB_OX, D, 0.0), (P_AB_OY, D, 0.0),
        ])
        self._artboard_at = idx
        return 0

    def obj(self, type_key, props):
        """Returns the artboard-relative id (what parentId / objectId refer to)."""
        assert self._artboard_at is not None, 'artboard must come first'
        return self._add(type_key, props) - self._artboard_at

    def build(self, file_id=1):
        keys, ftypes = [], {}
        for _, props in self._objs:
            for k, t, _v in props:
                if k not in ftypes:
                    ftypes[k] = U if t == B else t
                    keys.append(k)
        out = bytearray(b'RIVE')
        out += varuint(7) + varuint(0) + varuint(file_id)
        for k in keys:
            out += varuint(k)
        out += varuint(0)
        for i in range(0, len(keys), 4):
            word = 0
            for j, k in enumerate(keys[i:i + 4]):
                word |= (ftypes[k] & 3) << (2 * j)
            out += struct.pack('<I', word)
        for type_key, props in self._objs:
            out += varuint(type_key)
            for k, t, v in props:
                out += varuint(k)
                if t == U:
                    out += varuint(int(v))
                elif t == D:
                    out += struct.pack('<f', float(v))
                elif t == C:
                    out += struct.pack('<I', int(v) & 0xFFFFFFFF)
                elif t == B:
                    out += bytes([1 if v else 0])
                else:
                    b = v.encode('utf-8')
                    out += varuint(len(b)) + b
            out += varuint(0)
        return bytes(out)


def argb(hex_rgb, alpha=1.0):
    h = hex_rgb.lstrip('#')
    return (int(round(alpha * 255)) << 24) | int(h, 16)
