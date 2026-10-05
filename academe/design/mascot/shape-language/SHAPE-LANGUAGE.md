# ACADEMe Shape Language — How we build characters

**Purpose:** A production recipe for **ACADEMe** illustrations and mascots.

**Brand note:** Never copy another app's mascot, colours or character IP. ACADEMe uses **our** palette (Scheme B/D) and our personality.

**Related:** Animation library stays in `design/mascot/flat/ANIMATION-LIBRARY.md` — build character *with this guide first*, then animate.

---

## 1. Why this system exists

The system serves three goals:

| Goal | Meaning for ACADEMe |
|------|---------------------|
| **Quick to produce** | Solo team can ship poses/states without a studio |
| **Clear to understand** | Student knows “celebrate” vs “think” at a glance, even small |
| **Fun to learn with** | Softens homework/exam stress without babyish clutter |

Method: **few geometric shapes, all rounded, clear silhouette, controlled detail count.**

---

## 2. Construction (the core rule)

### Only three primitive shapes

| Primitive | Notes |
|-----------|--------|
| **Rounded rectangle** (“stadium” / soft box) | Used **most** often — body, limbs, props |
| **Circle** (and ellipse) | Heads, eyes, joints, cheeks |
| **Rounded triangle** | Ears, beaks, ribbons, accents — **corners rounded**, never sharp spikes |

**Rules**

1. Every edge is **rounded**. Sharp corners / knife points = **off-brand**.
2. You may **boolean / pathfinder** cut and merge shapes. Resulting pieces must still read as soft geometry.
3. Prefer **whole shapes** stacked over sketchy outlines.
4. Line art is optional; default is **filled shapes**.

```
BUILD ORDER (every character)
1. Silhouette from 1–3 big shapes (must read in solid black)
2. Add mid-size shapes for limbs / signature feature
3. Face: eyes + mouth (+ optional nose) — geometric only
4. Accent color on ONE signature feature
5. Count shapes → stay in the “good” band (§3)
```

---

## 3. Simplicity (shape budget)

Shape budget:

| Shape count (approx.) | Verdict |
|----------------------|---------|
| **~6** | Too abstract — hard to read |
| **~12–18** | **Sweet spot** for a character |
| **~30+** | Too busy — silhouette muddies |

**ACADEMe target for a mascot hero pose:** **10–18 filled shapes** (including eyes/pupils as separate shapes).

**Checklist**

- [ ] Solid black silhouette still recognizable  
- [ ] Under ~18 shapes for idle pose  
- [ ] Works at **48×48** and **128×128**  
- [ ] One signature feature only  

---

## 4. Rhythm

> The rhythm of simple shapes is what makes the illustrations interesting.

**Do**

- Vary **size**: big body, medium limbs, small eyes  
- Vary **placement**: not a perfect mirror mannequin every time  
- Repeat **one** shape family for cohesion (e.g. all limbs = rounded rects)

**Don’t**

- Same-size circles in a grid (boring / logo soup)  
- Ten tiny details of equal weight  

---

## 5. Character kit

### Body

- Build torso/head from **1–3** large rounded rects / circles  
- **Shape repetition** keeps the design cohesive (same corner radius language)  
- Avoid too many body parts — complicated silhouette  

### Eyes (geometric only)

Eye styles to start with:

| Style | Construction | Use |
|-------|--------------|-----|
| **Dots** | 2 small circles | Ultra-simple mascot |
| **Round** | White ellipse + dark pupil circle | Default friendly |
| **Almond** | Rounded triangle / stretched ellipse | Slightly sharper personality |

**Rules**

- Pupils roughly **centered** in the eye  
- Eyes geometric — no realistic lashes  
- Prefer clear contrast (white + dark on primary body)  

### Mouth

- Simple path or rounded shape  
- Smile / open / flat for states (maps to animation catalog)  

### Nose (optional)

- **1–2 rounded rectangles**, optional; many simple mascots skip the nose  

### Signature feature

- **One** accent element in mint `#7CFFB2` (antenna, ribbon, star, glow)  
- Everything else primary blue / neutrals  

---

## 6. ACADEMe color tokens (illustration)

| Role | Dark app (B) | Notes |
|------|----------------|-------|
| Primary body | `#5B6CFF` | Main fill |
| Accent | `#7CFFB2` | Signature only |
| Face / outline detail | `#0B0C0F` | Eyes, mouth |
| Eye white | `#FFFFFF` | |
| Secondary body | `#4A59E6` | Shadow side / spine (optional) |
| Soft shade | `#5B6CFF` at 20% opacity | Soft contact shadow under feet |

**Shadows:** soft, simple; not realistic multi-light. One contact blob is enough.

**Light mode (D):** same character colors; page background `#F6F7FA`.

---

## 7. Personality & placement (product)

Before drawing, write one sentence (Kartik / Ziggle lesson):

> “A [trait] companion who [helps students how] at [peak moment].”

Then:

| Surface | Allowed |
|---------|---------|
| Onboarding, empty, celebrate, think, encourage | Yes |
| Every content card | No |
| Settings hide | Yes |

Voice: peer coach, no guilt spam.

---

## 8. Pipeline (how we create one)

```
1. Personality sentence + signature feature name
2. Black silhouette (3 big shapes max)
3. Build from rounded rect / circle / rounded triangle only
4. Count shapes (10–18)
5. Color: body primary, ONE mint accent
6. Face: geometric eyes + mouth
7. Export SVG master (white bg)
8. Pose variants: wave, think, celebrate… (same construction)
9. Plug into animation library (Rive / WebM)
```

**Tools:** Figma / Illustrator / Affinity / pure SVG (as in examples). Vector only.

---

## 9. Anti-patterns

| Don’t | Why |
|-------|-----|
| Pointy spikes, sharp star points, hard cubes | Off shape language |
| Fur, pores, 3D clay, gradients everywhere | Breaks “quick + clear” |
| 30+ micro shapes | Muddy at small size |
| Copying another app's mascot | Brand conflict |
| New style every screen | Breaks trust |

---

## 10. Quality gate (ship checklist)

- [ ] Built only from rounded rect, circle, rounded triangle  
- [ ] No sharp points  
- [ ] Shape count in range  
- [ ] Black silhouette test pass  
- [ ] Signature feature clear  
- [ ] 48px legible  
- [ ] Uses ACADEMe colors only  
- [ ] Idle + at least 2 emotion poses planned  

---

## 11. Mixing animals + shapes

Animals are **not** drawn realistically. Decode the animal into primitives:

| Animal part | Typical primitive |
|-------------|-------------------|
| Head / body | Circle, ellipse, rounded rect |
| Ears / beak / frills / tufts | **Rounded triangle** |
| Legs / flippers / tentacles | Rounded rect or ellipse |
| Mask / belly / shell plate | Circle or ellipse overlay |
| Hybrid (bird+book, star+cat) | Stack two metaphors; still ≤18 shapes |

**Formula:** `animal silhouette = soft shape stack + one mint signature`

## 12. Examples

| Set | File | Preview |
|-----|------|---------|
| **01–10 pure / object** | `examples/00-10-examples.svg` | `preview-shape-language-examples.html` |
| **11–25 animal × shape** | `examples/11-20-animal-shape-mix.svg` | `preview-animal-shape-mix.html` |
| **V3 redesign cast (current)** | `examples/v3-redesign-cast.svg` | `preview-v3-redesign.html` |

### V3 construction extras

- Pill shadow under every character  
- Offset pupils (not dead-center)  
- Asymmetric mouths  
- Slight pose / tilt  
- Optional floating accent (bookmark, feet, flame)  

---

*Version 2.0 — 2026-07-31 · V3 cast redesign.*
