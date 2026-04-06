# Glitter Wizard Hat Cap — Requirements

## Design Intent

Replacement top cap for vintage Lava Lite "Glitter Wizard" style lava lamps. The cap is
the conical "wizard hat" piece that sits on top of the glass globe, covering the bottle
opening. It features decorative star and circle cutouts that project light patterns on
surrounding surfaces.

The original caps were stamped sheet metal (aluminum or tin-plated steel, ~0.5mm wall).
This 3D-printed PLA replacement uses thicker walls for FDM strength while maintaining the
visual proportions and decorative pattern of the original.

Two sizes are provided as parametric variants:
1. **Small** — fits 14.5" lamps (20 oz globes)
2. **Large** — fits 14.5"–17" lamps (20–32 oz globes) and some 16.3" (52 oz) globes

Both share the same bottle neck opening diameter; the large size is taller with a
proportionally wider base.

---

## Print Orientation

- **Bed face:** Base opening (wide end) flat on the bed, opening facing down.
- **Growth direction:** +Z toward the tip.
- **Rationale:** Wide base gives excellent bed adhesion. Each layer is equal or smaller
  than the previous — zero overhang on the cone walls. The rounded tip is the last
  feature printed. Cutout holes in the cone wall are perpendicular to the layer plane
  and print cleanly without support. No supports required.

---

## Dimensions & Sources

### Small (14.5" lamp)

| Dimension | Value | Source |
|---|---|---|
| Overall height | 95.0 mm (3.74") | Photo analysis + proportional scaling |
| Base outer diameter | 48.0 mm (1.89") | Photo analysis (PPI=88) |
| Base inner diameter | 45.0 mm (1.77") | Computed: OD - 2 x wall |
| Wall thickness | 1.5 mm | Design: 3 perimeters at 0.4mm nozzle |
| Cone half-angle | 14.2° from vertical | Computed: atan((24)/95) |
| Tip radius | 3.0 mm | Design: rounded hemisphere cap |
| Retention lip depth | 3.0 mm | Design: inward step for bottle neck grip |
| Retention lip height | 5.0 mm | Design: short ring at base interior |

### Large (17" lamp)

| Dimension | Value | Source |
|---|---|---|
| Overall height | 114.3 mm (4.50") | Photo analysis + Thingiverse 4.5" model confirmation |
| Base outer diameter | 52.0 mm (2.05") | Photo analysis: 1.91" measured, rounded up for clearance |
| Base inner diameter | 49.0 mm (1.93") | Computed: OD - 2 x wall |
| Wall thickness | 1.5 mm | Design: 3 perimeters at 0.4mm nozzle |
| Cone half-angle | 12.8° from vertical | Computed: atan((26)/114.3) |
| Tip radius | 3.5 mm | Design: rounded hemisphere cap |
| Retention lip depth | 3.0 mm | Design: inward step for bottle neck grip |
| Retention lip height | 5.0 mm | Design: short ring at base interior |

### Common

| Dimension | Value | Source |
|---|---|---|
| Star cutout diameter (across points) | 6.0 mm | Photo analysis: ~5-7mm features |
| Star inner radius ratio | 0.38 | Design: classic 5-pointed star proportion |
| Circle cutout diameter | 3.5 mm | Photo analysis: ~3-4mm dots |
| Crescent moon height | 5.0 mm | Web research: "halfmoon and starlight pin holes" |
| Crescent moon width | 3.5 mm | Design: proportional to height |
| Cutout rows | 4 | Photo analysis: cutouts at 4 height bands |
| Cutout items per row | 8–12 | Design: evenly spaced, staggered between rows |
| Minimum bridge across cutout | None | Cutouts are through-wall holes, no bridging |

---

## Features

### 1. Cone Body
- **Purpose:** Primary structural shell forming the wizard hat shape.
- **Geometry:** Truncated hollow cone. Outer surface tapers linearly from base OD
  to a small diameter near the tip, then transitions to a hemisphere.
- **Critical dimensions:** Wall thickness 1.5 mm throughout. Half-angle ~13° from
  vertical.
- **Mating interfaces:** Base opening sits over the lava lamp bottle neck.

### 2. Base Opening
- **Purpose:** Opening at the wide end that fits over the bottle neck/lip.
- **Critical dimensions:** Inner diameter sized for the bottle neck. The opening
  is the full base inner diameter.
- **Mating interfaces:** Friction fit over bottle neck. Retention lip provides
  grip.

### 3. Retention Lip
- **Purpose:** Inward step at the base interior that grips the bottle neck rim.
- **Critical dimensions:** 3 mm inward from base ID, 5 mm tall. Creates a subtle
  step that the bottle rim sits in.
- **Mating interfaces:** Bottle neck rim. Clearance fit per FDM tolerances.

### 4. Rounded Tip
- **Purpose:** Smooth cap at the cone apex. Avoids a sharp point that would be
  fragile and hard to print.
- **Critical dimensions:** Hemisphere radius 3.0–3.5 mm (size dependent).
- **Mating interfaces:** None (decorative).

### 5. Star Cutouts
- **Purpose:** Decorative through-wall holes in 5-pointed star shape. Allow light
  from the lamp to project star patterns on surrounding surfaces.
- **Critical dimensions:** 6 mm across points. Star points must be thick enough to
  print — inner radius ratio 0.38 ensures minimum 1.0 mm between points (above
  bridge threshold since these are vertical wall features).
- **Pattern:** Distributed across 4 rows, staggered between adjacent rows.

### 6. Circle Cutouts
- **Purpose:** Decorative round through-wall holes. Complement the stars.
- **Critical dimensions:** 3.5 mm diameter. Through the 1.5 mm wall.
- **Pattern:** Interspersed with stars in each row.

### 7. Crescent Moon Cutouts
- **Purpose:** Decorative crescent/half-moon through-wall holes. Classic motif on
  wizard-themed lamps per web research.
- **Critical dimensions:** 5 mm tall, 3.5 mm wide. Through the 1.5 mm wall.
- **Pattern:** One or two per row, placed as accent shapes among stars and circles.

---

## Material & Tolerances

- **Material:** PLA, Bambu Lab X1 Carbon, 0.4 mm nozzle, 0.2 mm layer height.
- **Default dimensional tolerance:** ±1.0 mm on overall height and diameter.
- **Base ID tolerance:** ±0.3 mm (must fit bottle neck).
- **Wall thickness tolerance:** ±0.2 mm (structural minimum 1.2 mm).
- **Cutout size tolerance:** ±0.3 mm (decorative, not critical).

---

## Constraints

- Build volume: 256 x 256 x 256 mm. Both sizes fit easily (max ~52 x 52 x 115 mm).
- Minimum wall thickness: 1.2 mm (3 perimeters). Design wall 1.5 mm. PASS.
- No supports required — cone walls have zero overhang when printed base-down.
- Cutout features are through-wall holes in a sloped wall — print as vertical
  gaps in each layer. No bridging.
- Star point minimum web: ~1.0 mm at narrowest. Acceptable for decorative feature.
- Part should be manifold (watertight mesh).

---

## Printability Pre-Screen

| Feature | Check | Result |
|---|---|---|
| Cone wall | 1.5 mm throughout | PASS (>= 1.2 mm MIN_WALL) |
| Cone overhang | 0° (each layer same or smaller) | PASS |
| Retention lip | 1.5 mm wall + 3 mm step | PASS |
| Tip hemisphere | 3-3.5 mm radius solid | PASS |
| Star cutouts | 6 mm across, 1.0 mm min web | PASS (decorative) |
| Circle cutouts | 3.5 mm diameter | PASS |
| Crescent cutouts | 5 mm tall | PASS |
| Overall height | 114.3 mm max | PASS (<256 mm) |
| Overall footprint | 52 mm max diameter | PASS (<256 mm) |

No features require support structures.

---

## Photo Analysis Summary

Two reference photos analyzed:
1. **Photo 1 (top-down):** Confirms circular base cross-section, ~48-52 mm OD.
2. **Photo 2 (side view):** Ruler-calibrated at 88 PPI. Measured height ~3.86"
   (likely 4.0–4.5" accounting for tip/base detection loss). Base width ~1.91".
   Half-angle ~14° from vertical. Star and circle cutouts visible in 4 bands.

Cross-referenced with Thingiverse "4.5 inch Replacement Wizard Lava Lamp Cap" model
(thing:7307363) confirming the large size at 4.5" total height.

---

## Sources

- Photo measurements (user-provided reference images with ruler)
- [Thingiverse: 4.5" Replacement Wizard Lava Lamp Cap](https://www.thingiverse.com/thing:7307363)
- [Cults3D: Lava Lamp Wizard Glitter Cap](https://cults3d.com/en/3d-model/home/lava-lamp-wizard-glitter-cap)
- [Oozing Goo: Giant replacement cap](https://oozinggoo.ning.com/forum/topics/giant-replacement-cap) — wall thickness 1/16"
- [Lava Library: Removing/Recapping](https://lava-library.com/removing-caps-and-recapping-lava-lamp-bottles/) — 26mm bottle caps
- [eBay 3D Print Caps](https://www.ebay.com/itm/356593745444) — fits 14.5"-17" lamps, 1 5/8" ID
- [RetroMagicOKC: Wizard Model Cap](https://www.retromagicokc.com/product/lava-cap-replacement-14-5-17-inch-lamps/62)
