# Pebby as a Rive character

`assets/academe/mascot/animations/pebby.riv` — one artboard, the named rig,
**50 poses**, and the `PebbySM` state machine. Built by the Python generator in
this folder; nothing here was authored in the Rive editor, and `build.py`
reproduces the file byte for byte.

It covers every id the design system pins down at
[academe.cc/design/character](https://www.academe.cc/design/character): the 16
expressions, the 6 study moments, the 5 turnaround angles and the 8 stable
motion state ids. A test asserts that, so the file cannot drift from the spec
without failing.

Open `preview/index.html` to watch it. The same page also has **one clay 3D model** (`preview/pebby.glb`) built from these stills and `pebby_3d_master.png` — orbitable in the viewer at the top of the page. Rebuild with `python3 make_glb.py`.

## What is in the file

| | |
|---|---|
| Artboard | `Pebby`, 440 × 440, clipped, character centred on `root` at (220, 220) |
| State machine | `PebbySM`, two layers: `body` and `appear` |
| Inputs | `pose` (number 0–42), `reduceMotion` (bool), `appear` (number 0–100) |
| Entry state | `wave` |
| Frame rate | **12 fps** for every character loop |
| Animations | 47 clips + `idle_static` + the two `appear` poses; 50 pose ids |
| Size | ~438 KB, about 29,000 keyframes |

Rig, all under `head` → `motion` → `root`:

`body` `face` `eyeL` `eyeR` `eyeLdot` `eyeRdot` `browL` `browR` `mouth`
`tongue` `tuftL` `tuftR` `armL` `armR` `footL` `footR` `shadow`

`head` carries the face plate, brows, eyes, highlights and mouth, so the head
turns and tilts as one piece while the body keeps its own weight. Every
animation writes the same 55 channels, so switching state never leaves a limb
or an eyelid at the previous state's value.

## Pose index

```
 0 idle            13 loved          26 cta            39 peek_right
 1 wave            14 surprised      27 hero           40 dissolve_in
 2 think           15 tired          28 mastery        41 dissolve_out
 3 cheer           16 shy            29 practice       42 summon
 4 sleep           17 focused        30 upload         43 encourage
 5 sad             18 act_achieved   31 studying       44 celebrate_small
 6 wow             19 act_highfive   32 turn_front     45 celebrate_big
 7 determined      20 act_idea       33 turn_back      46 sleepy
 8 confused        21 act_reading    34 turn_side      47 thinking  → think
 9 happy           22 act_solving    35 turn_three_quarter        48 sleeping  → sleep
10 excited         23 act_studying   36 turn_three_quarter_back   49 celebrate → celebrate_big
11 laughing        24 adaptive       37 cheering
12 proud           25 chat           38 peek_left
```

47, 48 and 49 are aliases: the design system spells some ids differently from
the motion state ids, so both spellings resolve to the same clip rather than a
duplicate. `surprised`, `dissolve_in`, `dissolve_out` and `summon` are one-shots;
the rest loop. `cheering` is `cheer`.

`sleepy` and `sleeping` are genuinely different: `sleepy` is drowsy but awake —
it yawns, and the head nods off and catches itself — while `sleeping` is out
cold.

The motion page's own rules are honoured: motion stays subtle in product,
`reduceMotion` is respected, and `celebrate_big` is the one state meant to be
rationed (`PebbyState.isBigMoment` marks it).

## The three arrival moments

**Peeking in from the edge** — `peek_left` / `peek_right`. Pebby slides in from
off-artboard, overshoots, settles braced against the edge with about half of him
still hidden, looks into the screen, blinks, ducks back once and re-emerges.
The artboard clips him, so the widget can sit flush against any screen edge.

**Dissolving into a screen** — `dissolve_in` / `dissolve_out` are choreographed
one-shots: a scale-up from 80%, a settle, a sub-pixel materialise jitter, limbs
that start tucked and open out, and eyes that open once he is most of the way
in. For a fade driven by a page transition, pass `appear` to `PebbyRive`.

### The in-file dissolves never go translucent

Rive fades each shape on its own. If two overlapping parts are translucent at
the same time the overlap carries both their ink, so it reads as a solid patch
floating inside a ghost. The arm behind the body was the worst of it: during a
fade you could see a saturated arm-shaped blob that did not seem to be
disappearing at all.

So the in-file dissolves never hold a partial opacity. `dissolve_out` stays
fully opaque, closes the eyes, swings both arms clear of the body and shrinks to
six percent before opacity steps to zero in one frame. `dissolve_in` and
`summon` step to full opacity while still tiny and grow from there. Opacity uses
hold interpolation in all three, so there is no in-between value to composite
wrongly.

A test renders both dissolves on a transparent ground and checks every frame:
the brightest region may not exceed the body's own alpha by more than six
percent. That is what a single-alpha silhouette looks like, and it fails if any
part ever shows through another.

### Why the fade is a widget, not an input

Rive fades each shape independently. Half-way through an artboard-level fade you
see the arms, tufts and body through one another: Pebby stops reading as one
character and becomes a stack of translucent parts. There is no group
compositing inside the runtime.

So `PebbyRive` fades the composited widget instead, which is one layer and
therefore one silhouette at every opacity. The artboard still carries an
`appear` input (0–100) on its own state machine layer for consumers that cannot
composite, and `dissolve_in` / `dissolve_out` are built to spend almost no time
translucent: opacity lands within three frames on the way in, and on the way out
he shrinks first and only fades over the last 0.3 s.

**Summoning** — `summon`. He drops in from above with anticipation, lands with a
squash, and bounces twice into a grin while the tufts and arms overshoot and
trail behind the body. The contact shadow stretches and snaps with him.

## Using it

```yaml
dependencies:
  rive: ^0.13.20

flutter:
  assets:
    - assets/academe/mascot/animations/
```

Copy `pebby_rive.dart` into `lib/widgets/`, then:

```dart
PebbyRive(state: PebbyState.cheer, size: 180)

// sign-in screen: he materialises, then idles
PebbyRive(state: PebbyState.idle, entrance: PebbyEntrance.dissolve)

// peeking in at the edge of the screen
PebbyRive(state: PebbyState.peekLeft, size: 140)

// fading with a page transition
PebbyRive(state: PebbyState.idle, appear: animation.value)
```

`PebbyState.index` is the `pose` value, so the enum order must stay in step
with the table above.

## The arms are skinned, not rotated

The arms are the one place the character actually deforms. Each is a
`PointsPath` of twelve cubic vertices bound to a two-bone chain by a `Skin`.
The forearm bends
at the elbow and the mesh follows smoothly, so a wave reads as an arm rather
than a rotating stick, and the paw can curve toward the head.

| | |
|---|---|
| Bones | `armLUpper` → `armLFore`, `armRUpper` → `armRFore`, all under `motion` |
| Skinned paths | 4 (the limb and the thumb on each arm) |
| Tendons | 8, two per skin |
| Weights | 48 `CubicWeight`, blended along the limb so the elbow is soft |

Two things to know if you edit it. `pose` angles are still authored the way they
always were, and `build.py` adds the 90 degrees a bone needs because bones point
along +X; the elbow is a separate channel. And a skinned path ignores its
shape's transform, so the shoulder angle has to live on the bone, not on `armL`.

`elbow_follow` derives the forearm track from the shoulder track with a frame
and a half of lag, which is what stops a wave looking mechanical.

The body is deliberately *not* skinned. The design system forbids stretching or
squashing it, so there is nothing for a body mesh to do that the rule allows.

## 12 fps is the keyframe grid, not the playback rate

Worth being explicit, because the GIF previews look choppier than the real
thing. The clips are authored on a 12 fps grid. Rive does not step at that rate: `LinearAnimationInstance`
advances in continuous seconds and `applyInterpolation` samples between the
surrounding keys with the keyframe's own cubic. Measured on the shipped file,
driving the state machine at a fixed rate and reading the head's rotation:

| display rate | frames that changed | repeated frames |
|---|---|---|
| 60 Hz | 119 of 119 | 0 |
| 120 Hz | 239 of 239 | 0 |

So it is smooth on device at whatever the panel refreshes at, and a test in the
suite fails if that ever stops being true. `preview/pebby60_*.mp4` are 60 fps
captures if you want to see it; the GIFs on the same page are 12.5 fps with a
72-colour palette and are the choppy ones.

## The turnaround follows our turnaround art

Measured off `assets/academe/mascot/poses/turn_*.png` rather than guessed,
because the first attempt turned the wrong way:

| angle | face plate width | face centre, as a fraction of body width | eye ink |
|---|---|---|---|
| front | 0.555 of body | centred | yes |
| three quarter | 0.508 | −0.101 | yes |
| side | 0.036 | −0.436 | a sliver |
| three quarter back | none | — | none |
| back | none | — | none |

The face leaves to the **viewer's left**, the side view is a near-total profile
with only the leading edge of the face plate and part of one eye showing, and
both rear angles show no face at all. The body narrows to 0.875 of its front
width in profile. A test asserts the direction and that the rear angles stay
faceless.

One honest limit: the official side view also redraws the body outline in
profile. A flat rig cannot reshape its own silhouette, so this one narrows and
sweeps the tufts back instead. It reads as a profile, but it is not the same
drawing.

## Why it does not read as a loop

The things that make cheap mascots feel robotic, and what this file does
instead.

- **12 fps, not 60.** Animating on twos reads as drawn rather than tweened.
- **Long loops.** `idle` is 203 frames at 12 fps — nearly 17 seconds.
  Ambient states run 10–17 s and no two neighbouring
  states share a period, so nothing marches in step.
- **Coprime harmonics.** Breathing and head drift are the sum of 3, 5 and 7
  cycle sine waves. The composite has no shorter period than the loop itself, so
  the motion never repeats inside it, and it still closes seamlessly. Measured
  autocorrelation of the idle rise never exceeds +0.55 at any lag.
- **Saccades, not glides.** Real eyes jump in two frames and then fix for a
  second or more. Gliding eyes are the single biggest tell of a cheap rig. Each
  fixation also carries a sub-pixel tremor.
- **Irregular blinks, sometimes doubled.** Blinks cluster: gaps of 2.3 s,
  then a double 0.7 s apart, then 1.8 s. A blink closes in 2 frames, holds 1 and opens in 3 — closing is always
  faster than opening.
- **Anticipation, overshoot, settle.** Every action moves slightly the wrong way
  first, passes its target, and comes back. Only appendages overshoot; the body
  eases out without crossing.
- **Follow-through.** Tufts and arms lag the body by one to one and a half
  frames and carry different gains left and right, so the two sides never mirror.
- **Volume-preserving squash.** Bounces widen as they flatten, and the contact
  shadow shrinks as he leaves the ground.
- **A curve per keyframe.** 17 named cubics rather than one shared ease.
- **The body is never squashed.** The illustration page forbids stretching or
  squashing it, so the body eases out without overshooting. Bounces here deform the whole character by at
  most 4%, and the life comes from vertical travel, tuft and arm follow-through
  and the contact shadow instead. A test fails the build if any whole-character
  scale key leaves 0.94–1.07.
- **No seams.** Each part's colour where it meets the body is the body's own
  colour at that exact point, sampled out of the body gradient: the tuft bases,
  the arm shoulders and the foot tops all match. Without that the tufts read as
  separate blobs stuck on the head. The arms carry their own darker gradient
  below the shoulder so they read as limbs in shadow, with the only highlight
  down on the paw, away from the join.

## Look

Flat vector only: rounded rectangles, circles and ellipses, every corner
rounded — the design system's "rounded primitives, simple shape budgets, clear
silhouettes". Depth comes from stacked fills, not bitmaps. He is built to read
at 48 px, and checked against the brand surfaces `#F6F7FA`, `#FFFFFF` and
`#EEF0F5`; light mode is the product default, so the previews are rendered on
it.

```
body highlight #B8B9FF   face  #FFFEFF   mouth  #2A2A40
body mid       #8B8CF5   eye   #1A1B32   tongue #E07A8A
body shadow    #6A6CD0
```

Each part carries more than one paint, which is where the clay look comes from:
the body has a base radial gradient, a bounce-light gradient along the bottom
edge and a tight specular sheen at the top left; the face plate has a soft
ambient darkening at its rim; the eyes have a bounce gradient under the pupil.

The mouth is a **stroked ellipse with a trim path**, not a filled blob. Trim
start and end open and close the smile, `offset` 0.5 flips the same arc into a
frown, and stroke thickness animates with it. For open mouths the stroke fades
to zero and the fill fades in, so one shape covers eleven mouth shapes.

Geometry was measured off `assets/academe/mascot/source/starts/idle.png`:
body box, face plate, eye centres, brow and mouth boxes, tuft lobes, arm reach
and foot split, converted at 0.4093 px per artboard unit.

One honest limitation remains: the arms are drawn behind the body, so a paw
brought across the chest is hidden. With the elbow the thinking and solving
poses now curl the paw up beside the head, which is outside the body outline and
reads as pondering, but a paw actually touching the cheek would need the arm
drawn in front.

## Regenerating

```bash
cd design/mascot/rive
python3 build.py     # writes pebby.riv beside the script
```

Standard library only.

- `rig.py` — geometry, paints and bone chain of every layer, authored back to front
- `skin.py` — cubic vertex generation, weight packing and the bind matrices
- `ease.py` — the 17 cubics
- `anim.py` — rest pose, expression and motion vocabulary
- `states.py` — the 43 states
- `riv.py` — the `.riv` binary writer
- `rivread.py` — the matching reader, used to inspect the built file
- `build.py` — assembles artboard, rig, animations and state machine
- `mksvg.py` — an SVG render of the rest pose, for quick geometry checks

## Format notes

Facts the writer depends on, taken from `rive-0.13.20`'s own reader. Get one
wrong and the file fails to load, or loads wrong and silently.

- Header: `RIVE`, varuint major 7, varuint minor, varuint file id, the property
  key table terminated by 0, then the field-type bitfield. The reader consumes
  **one uint32 per four keys** (2 bits each in the low byte), not per sixteen.
- Field types: 0 uint (varuint), 1 string (varuint length + utf-8), 2 double
  (float32 LE), 3 colour (uint32 LE, ARGB). Bools are one byte, declared uint.
- Object ids are implicit and artboard-relative. **Index 0 is the artboard
  itself.** `parentId`, `objectId` and `interpolatorId` all use those ids.
- **Rive paints the child list back to front**, so the front-most layer is
  emitted first. `rig.py` is authored in draw order and `build.py` reverses it.
- Rotation is radians. Ellipse paths run clockwise from the top, so a trim
  centred on 0.5 is the bottom arc.
- `StateMachine` descends from `Animation`, so its name is property 55, not the
  138 its inputs and layers use. `LayerState` descends from `Core` and has no
  name property at all.
- `AnimationState.animationId` indexes the artboard's animation list,
  `StateTransition.stateToId` indexes its layer's states, and a condition's
  `inputId` indexes the machine's inputs. None of them are object ids.
  `BlendAnimation.animationId` is property 165, and `BlendState1D.inputId` 167.
- **Every layer needs an AnyState**, or the controller asserts on load.
- One `KeyedObject` addresses one object. Stroke thickness and stroke colour
  live on different objects, so they cannot share a group.
- A transition's `duration` is milliseconds unless the percentage flag is set.
- `Shape` builds its own `PathComposer`; do not emit one.

## Verification

`pebby_riv_verify_test.dart` loads the built file with the real runtime and
checks the artboard, that all 20 rig layers are parented through head/motion/
root, that every design-system id is a pose, that the clips still interpolate on
every display frame at 60 and 120 Hz, that the turnaround turns the right way,
the animation names in pose order, 12 fps, that the ambient loops are
at least 12 s and no two share a period, the one-shot loop modes, the three
inputs, that the entry state is `wave`, that every pose renders differently from
`idle`, that `idle` never freezes, that both peeks leave Pebby between a quarter
and three quarters on screen, that `reduceMotion` holds a byte-identical frame
and releasing it resumes, that `appear` really dissolves — 0 renders no ink at
all and 50 is measurably fainter than 100 — and that no state squashes the body
past the brand limit.

It needs `rive` in `dev_dependencies` and one `flutter build macos --debug`
first, because `flutter_tester` does not link the `rive_common` plugin and the
test dlopens it out of the built app. Without that build the tests skip with
that message rather than passing silently.

```bash
cp design/mascot/rive/pebby_riv_verify_test.dart test/
flutter test test/pebby_riv_verify_test.dart
```
