import zlib, struct

def load(path):
    d = open(path,'rb').read()
    assert d[:8] == b'\x89PNG\r\n\x1a\n'
    pos, idat, pal, trns = 8, b'', None, None
    while pos < len(d):
        ln, typ = struct.unpack('>I4s', d[pos:pos+8])
        body = d[pos+8:pos+8+ln]
        if typ == b'IHDR':
            w, h, bd, ct, comp, filt, il = struct.unpack('>IIBBBBB', body)
            assert bd == 8 and il == 0, (bd, il)
        elif typ == b'IDAT': idat += body
        elif typ == b'PLTE': pal = body
        elif typ == b'tRNS': trns = body
        elif typ == b'IEND': break
        pos += 12 + ln
    ch = {0:1, 2:3, 3:1, 4:2, 6:4}[ct]
    raw = zlib.decompress(idat)
    stride = w * ch
    out = bytearray(h * stride)
    prev = bytearray(stride)
    p = 0
    for y in range(h):
        f = raw[p]; p += 1
        line = bytearray(raw[p:p+stride]); p += stride
        if f == 1:
            for i in range(ch, stride): line[i] = (line[i] + line[i-ch]) & 255
        elif f == 2:
            for i in range(stride): line[i] = (line[i] + prev[i]) & 255
        elif f == 3:
            for i in range(stride):
                a = line[i-ch] if i >= ch else 0
                line[i] = (line[i] + ((a + prev[i]) >> 1)) & 255
        elif f == 4:
            for i in range(stride):
                a = line[i-ch] if i >= ch else 0
                c = prev[i-ch] if i >= ch else 0
                b = prev[i]
                pp = a + b - c
                pa, pb, pc = abs(pp-a), abs(pp-b), abs(pp-c)
                pr = a if (pa <= pb and pa <= pc) else (b if pb <= pc else c)
                line[i] = (line[i] + pr) & 255
        out[y*stride:(y+1)*stride] = line
        prev = line
    return w, h, ch, ct, bytes(out), pal, trns

class Img:
    def __init__(self, path):
        self.w, self.h, self.ch, self.ct, self.px, self.pal, self.trns = load(path)
    def rgba(self, x, y):
        i = (y*self.w + x)*self.ch
        p = self.px
        if self.ct == 6: return p[i], p[i+1], p[i+2], p[i+3]
        if self.ct == 2: return p[i], p[i+1], p[i+2], 255
        if self.ct == 3:
            k = p[i]; pl = self.pal
            a = self.trns[k] if self.trns and k < len(self.trns) else 255
            return pl[k*3], pl[k*3+1], pl[k*3+2], a
        if self.ct == 0: return p[i], p[i], p[i], 255
        if self.ct == 4: return p[i], p[i], p[i], p[i+1]
    def hexat(self, x, y):
        r,g,b,a = self.rgba(x,y)
        return '#%02X%02X%02X a=%d' % (r,g,b,a)
