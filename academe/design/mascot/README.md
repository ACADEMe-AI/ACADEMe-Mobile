# Pebby — the academe mascot

**Pebby is generated from code, not drawn in rive.app.** `rive/` is a Python
toolchain that writes the `.riv` binary directly. To change Pebby you edit
Python and rebuild — you never open the Rive editor.

Everything about a mascot called "Mee", an 8-state `MeeSM` machine, or
hand-tracing an SVG was from an earlier round and has been deleted. This is v5.

## Shipping asset

| | |
|---|---|
| File | `assets/academe/mascot/animations/pebby.riv` (437 KB) |
| Artboard | `Pebby` (440×440) |
| State machine | `PebbySM` |
| Inputs | `pose` (number 0–50) · `appear` (number 0–100) · `reduceMotion` (bool) |
| Poses | 49 built + 1 static |
| Catalog | `assets/academe/mascot/catalog.json` |

## The toolchain

| File | Role |
|---|---|
| `rive/rig.py` | the character — node hierarchy, gradients, body / limbs / tufts / feet / face |
| `rive/skin.py` | mesh skinning: ellipses become cubic vertices so paths deform |
| `rive/anim.py` | motion primitives (below) |
| `rive/states.py` | the 48 poses, composed from primitives; `STATES` table is the index map |
| `rive/ease.py` | easing curves |
| `rive/riv.py` | Rive binary writer |
| `rive/build.py` | orchestrates → `pebby.riv` |
| `rive/rivread.py` | reads a `.riv` back, for verification |
| `rive/pebby_riv_verify_test.dart` | Dart-side verification |
| `rive/make_glb.py`, `mksvg.py`, `png.py`, `pngw.py` | export helpers (GLB / SVG / stills) |

Rebuild:

```
cd design/mascot/rive && python3 build.py     # writes pebby.riv
cp pebby.riv ../../../assets/academe/mascot/animations/
```

## Motion primitives (`anim.py`)

`breathe` · `head_life` · `sway` · `saccades` · `blinks` · `blink_schedule` ·
`gaze` · `look` · `eyes` · `brows` · `mouth` · `mouth_morph` · `arms` ·
`elbow_follow` · `face_view` · `action` · `layered` · `sample`

They compose. `alive()` in `states.py` is breathing + head drift + eye saccades
+ blinking layered together — that is how you get "idle-breathing while waving
while glancing at a button" without drawing a new animation.

## Poses

Emotion: `idle` `wave` `think` `cheer` `sleep` `sad` `wow` `determined`
`confused` `happy` `excited` `laughing` `proud` `loved` `surprised` `tired`
`shy` `focused` `sleepy` `encourage`

Action: `act_achieved` `act_highfive` `act_idea` `act_reading` `act_solving`
`act_studying` `studying` `practice` `upload` `mastery` `chat` `cta` `hero`
`adaptive`

Turnaround: `turn_front` `turn_back` `turn_side` `turn_three_quarter`
`turn_three_quarter_back`

Entrance / exit: `dissolve_in` `dissolve_out` `summon` `peek_left` `peek_right`
`celebrate_small` `celebrate_big`

Password: `cover_eyes` (50) — both paws over closed eyes. The arms' layer sits
under the body, so the hands are separate `coverL`/`coverR` parts drawn over the
face, hidden in every other pose.

Reading: `act_reading` (21) — holds an open amber book (`bookCover`, `bookPages`,
`bookLines`, `bookSpine`, `bookPawL/R`, hidden in every other pose) and reads
it line by line. Used on the ASKMe empty state.

Aliases: `thinking`→think · `sleeping`→sleep · `celebrate`→celebrate_big

## Adding a pose

1. Write `_myPose(a)` in `states.py` using the primitives
2. Add `('my_pose', _myPose)` to the `STATES` table
3. `python3 build.py`, copy the `.riv` across
4. New index = position in `STATES`

## What you can and cannot do at runtime

**Can:** switch `pose`, drive `appear` 0–100, set `reduceMotion`, and transform
the whole artboard from Flutter (move / scale / rotate / fade), with Lottie or
Flutter animation layered over it.

**Cannot:** invent a new limb motion live. That is a rebuild.

## Preview

`rive/preview/` has rendered proof — `all_50_states.png` (contact sheet), per-pose
GIFs, 60fps MP4s, `pebby.glb`, and `index.html`. Look there before designing a
screen around a pose.

## Also here

- `rive-celebrations.md` — Flutter motion stack, packages, haptics
- `shape-language/` — illustration construction system for the wider UI
