import json, struct, sys

N = json.load(open('rive_names.json'))
TYPES = {int(k): v for k, v in N['types'].items()}
PROPS = {int(k): v for k, v in N['props'].items()}
FT = {int(k): v for k, v in N['ftypes'].items()}
IDX2FT = ['uint', 'string', 'double', 'color']


class R:
    def __init__(self, data):
        self.d, self.i = data, 0

    def u8(self):
        v = self.d[self.i]; self.i += 1; return v

    def varuint(self):
        v, s = 0, 0
        while True:
            b = self.d[self.i]; self.i += 1
            v |= (b & 0x7F) << s
            if not b & 0x80: return v
            s += 7

    def f32(self):
        v = struct.unpack_from('<f', self.d, self.i)[0]; self.i += 4; return v

    def u32(self):
        v = struct.unpack_from('<I', self.d, self.i)[0]; self.i += 4; return v

    def string(self):
        n = self.varuint()
        s = self.d[self.i:self.i + n].decode('utf-8', 'replace'); self.i += n; return s

    def eof(self):
        return self.i >= len(self.d)


def load(path):
    r = R(open(path, 'rb').read())
    assert r.d[:4] == b'RIVE'
    r.i = 4
    major, minor = r.varuint(), r.varuint()
    if major == 6: r.varuint()
    file_id = r.varuint()
    keys = []
    while True:
        k = r.varuint()
        if k == 0: break
        keys.append(k)
    toc = {}
    cur, bit = 0, 8
    for k in keys:
        if bit == 8:
            cur, bit = r.u32(), 0
        toc[k] = IDX2FT[(cur >> bit) & 3]
        bit += 2
    objs = []
    while not r.eof():
        t = r.varuint()
        o = {'type': TYPES.get(t, f'type{t}'), 'typeKey': t, 'p': {}}
        while True:
            k = r.varuint()
            if k == 0: break
            ft = FT.get(k) or toc.get(k)
            if ft is None:
                raise ValueError(f'unknown property {k}')
            if ft in ('uint', 'bool'):
                v = r.u8() if ft == 'bool' else r.varuint()
            elif ft == 'double':
                v = round(r.f32(), 4)
            elif ft == 'color':
                v = '#%08X' % r.u32()
            else:
                v = r.string()
            o['p'][PROPS.get(k, str(k))] = v
        objs.append(o)
    return dict(version=f'{major}.{minor}', fileId=file_id, objects=objs)


if __name__ == '__main__':
    f = load(sys.argv[1])
    print(f"{sys.argv[1]}  v{f['version']}  {len(f['objects'])} objects")
    from collections import Counter
    c = Counter(o['type'] for o in f['objects'])
    for k, v in c.most_common(30):
        print(f'  {v:6d}  {k}')
