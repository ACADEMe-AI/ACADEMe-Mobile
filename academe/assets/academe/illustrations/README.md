# Illustrations

3D objects from **Khagwal 3D** (https://3d.khagwal.com/explorer/), **CC0 public
domain** — free for commercial use, no attribution required.

Theme: **elite** (periwinkle/indigo), chosen because it matches Pebby `#8B8CF5`
and brand `#5B6CFF`. Keep every illustration in this one theme.

Source URL pattern: `https://3d.khagwal.com/explorer/bucket/preview/elite/<name>_front.webp` (1080×1080).
Other angles: `_left`, `_right`, `_top`, `_perspective` under `bucket/thumb/elite/`.

| File | Object | Used on |
|---|---|---|
| `key.webp` | key, recoloured to brand | A5 Log in with email |
| `key_elite_original.webp` | key, as downloaded | source for `key.webp` |

## Recolouring to brand `#5B6CFF`

The `elite` theme sits at ~245° hue / 47% saturation; brand blue is 234° / 64%.
Every illustration gets the same shift so they all match the UI text colour:

```
ffmpeg -i in.webp -vf "scale=720:720:flags=lanczos,format=rgba" tmp.png
ffmpeg -i tmp.png -filter_complex "[0]split[c][a];[c]format=yuv444p,hue=h=-8,eq=saturation=2.4,format=rgba[cc];[a]alphaextract[aa];[cc][aa]alphamerge,format=rgba" out.png
```

Result on the key: 233° / 62%. Recolour the file, not at runtime — a colour
filter is a saveLayer, which AGENTS.md rules out.
