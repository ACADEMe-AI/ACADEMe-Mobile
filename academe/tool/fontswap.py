import re
import sys
from pathlib import Path

PUBSPEC = Path(__file__).resolve().parent.parent / 'pubspec.yaml'
BLOCK = re.compile(r'(^  fonts:\n)((?:^ {4}.*\n|^\s*\n(?=^ {4}))*)', re.M)


def families(text):
    m = BLOCK.search(text)
    if not m:
        raise SystemExit('no fonts: block in pubspec.yaml')
    out, name = {}, None
    for line in m.group(2).splitlines():
        fam = re.match(r'^    - family:\s*(\S+)', line)
        if fam:
            name = fam.group(1)
            out[name] = []
        asset = re.match(r'^\s+- asset:\s*(\S+)', line)
        if asset and name:
            out[name].append(asset.group(1))
    return out


def swap(text, family, asset):
    m = BLOCK.search(text)
    lines = m.group(2).splitlines(keepends=True)
    inside, done = False, False
    for i, line in enumerate(lines):
        fam = re.match(r'^    - family:\s*(\S+)', line)
        if fam:
            inside = fam.group(1) == family
            continue
        if inside and re.match(r'^\s+- asset:', line) and not done:
            lines[i] = re.sub(r'(- asset:\s*)\S+', r'\g<1>' + asset, line)
            done = True
    if not done:
        raise SystemExit(f'family {family!r} not found; have {sorted(families(text))}')
    return text[:m.start(2)] + ''.join(lines) + text[m.end(2):]


def main():
    text = PUBSPEC.read_text()
    if len(sys.argv) == 1 or sys.argv[1] == '--show':
        for fam, assets in families(text).items():
            print(f'{fam}: {", ".join(assets)}')
        return
    if len(sys.argv) != 3:
        raise SystemExit('usage: fontswap.py [--show] <family> <asset-path>')
    family, asset = sys.argv[1], sys.argv[2]
    if not (PUBSPEC.parent / asset).exists():
        raise SystemExit(f'no such file: {asset}')
    PUBSPEC.write_text(swap(text, family, asset))
    print(f'{family} -> {asset}')


if __name__ == '__main__':
    main()
