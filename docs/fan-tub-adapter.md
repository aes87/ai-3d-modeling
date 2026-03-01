# Fan-Tub Adapter

A 3D-printed adapter frame that mounts a 119mm waterproof fan into a waffle-pattern HDPE tub lid, replacing the need to jigsaw a hole. Designed for a mushroom cultivation Martha tent, where the fan provides forced-air intake through the tub.

## The Problem

The tub lid has a rigid waffle pattern — a grid of raised squares separated by flat channels. Cutting a clean circular hole for a fan is difficult with hand tools and weakens the lid. We need a way to mount the fan that:

- Doesn't require precision cutting (just remove a 2x2 block of waffle squares)
- Locates and locks into the waffle grid positively
- Can be removed tool-free for cleaning and maintenance
- Maximises airflow through the fan

## Design Approach

Instead of cutting a circle, the user cuts out a **2x2 block of waffle squares** (136.8 x 136.8mm) using a jigsaw along the straight channel lines. The adapter is a flat frame that drops into this rectangular hole and locks into the surrounding waffle grid.

The plate is 5mm thick to accommodate hex nut counterbores on the bottom face, so nothing protrudes below the seating surface. A raised locating rim on top matches the fan's 119mm footprint for drop-in alignment.

### Key Features

**Y-Shaped Corner Branches** — Each of the 4 corners forks into two arms that extend into the perpendicular waffle channels. The waffle squares on either side constrain each arm laterally. 8 engagement points total provide anti-rotation and alignment with zero fasteners. Branches are in-plane with the frame — same 5mm thickness, same Z level.

**Flange Lip** — The frame extends 4.5mm beyond the cutout on all sides, sitting on the flat rim around the hole. Prevents drop-through.

**Fan Locating Rim** — A 1.5mm raised square border on the top surface, sized to the fan's 119mm frame with 0.5mm clearance. Drop the fan into the rim, holes line up, thread bolts. No fiddling.

**Hex Nut Counterbores** — The 4 fan bolt positions have hex pockets recessed into the bottom face (3.4mm deep for M4 nuts). The bottom surface stays flat — nothing prevents the adapter from sitting flush on the lid.

**Tool-Free Removal** — Two M4 thumbscrews at diagonally opposite corner T-junctions — the thickest point on the part where the frame corner, crotch blend, and both branch roots all overlap (~3mm wall around the hole). They clamp the adapter to the lid with wing nuts below. Undo two wing nuts and the whole assembly lifts out.

## Renders

### Top (Isometric)

![Isometric view of the fan-tub-adapter](images/fan-tub-adapter/fan-tub-adapter-iso.png)

The 5mm-thick plate with center airflow opening, locating rim (raised square border), M4 through-holes at each corner of the fan bolt pattern, and Y-branches extending from each corner. Thumbscrew holes are visible at two diagonally opposite corner T-junctions.

### Bottom (Isometric)

![Bottom isometric view of the fan-tub-adapter](images/fan-tub-adapter/fan-tub-adapter-bottom-iso.png)

The underside showing the **hex nut counterbores** at each fan bolt position — recessed pockets that keep M4 nuts flush with the bottom surface. The bottom is completely flat with no protrusions to interfere with seating on the lid.

### Top-Down View

![Top-down view of the fan-tub-adapter](images/fan-tub-adapter/fan-tub-adapter-top-down.png)

Looking straight down. Shows the square frame, locating rim inside, circular center opening, 8 branch arms forking from the 4 corners, 4 fan bolt holes, and 2 thumbscrew holes at diagonally opposite corner T-junctions.

### Bottom-Up View

![Bottom-up view of the fan-tub-adapter](images/fan-tub-adapter/fan-tub-adapter-bottom-up.png)

Looking straight up. The hex counterbore pockets are visible at the 4 fan bolt positions. The bottom surface is flat — no wire channel, no protrusions.

## Cross-Section

How the parts stack when installed:

```
    Fan frame (drops inside locating rim)
  ┌──────────────────────────────────┐   ← locating rim (1.5mm)
  ├══════════════════════════════════┤   ← plate (5mm), nut pockets on bottom
  ──╗                              ╔──   ← waffle squares (4.6mm)
    ║   constrain branches         ║        surround the 5mm-thick branches
    ╚═══════════════╤══════════════╝
  ──────────────────┘                    ← lid surface
```

The plate sits on the channel-level rim. Waffle squares rise 4.6mm around the 5mm-thick branches. Hex nut pockets (3.4mm deep) are recessed into the bottom face so the surface remains flat. The fan drops into the locating rim and bolts through.

## Geometry

| Dimension | Value |
|-----------|-------|
| Cutout hole | 136.8 x 136.8 mm |
| Frame outer (with flange) | 145.8 x 145.8 mm |
| Overall bounding box | 186.8 x 186.8 x 6.5 mm |
| Center opening | 105 mm diameter |
| Fan bolt pattern | 107 x 107 mm (M4) |
| Nut counterbore | 7.8mm AF hex, 3.4mm deep |
| Locating rim | 120mm inner (119 + 0.5 clearance/side), 1.5mm tall, 2mm wall |
| Branch width | 9.0 mm (0.4mm clearance in 9.4mm channels) |
| Branch engagement length | 25 mm per arm |
| Plate thickness | 5.0 mm |
| Corner radius | 4.0 mm |

## Fastener BOM

| Qty | Item | Purpose |
|-----|------|---------|
| 4 | M4 x 12mm socket head bolts | Fan to adapter (through fan frame + plate) |
| 4 | M4 nuts | Recessed in hex counterbores on bottom face |
| 2 | M4 x 16mm thumbscrews | Adapter to lid clamping (at corner T-junctions) |
| 2 | M4 wing nuts | Below-lid, tool-free removal |

## Print Settings

| Setting | Value |
|---------|-------|
| Material | PLA |
| Layer height | 0.2 mm |
| Infill | 100% (thin plate, mostly perimeters) |
| Supports | None needed |
| Orientation | Bottom face on bed (counterbores print as recesses, rim on top) |
| Estimated material | ~70 cm³ |

## Validation Results

```
bbox.x:    186.8 mm  (expected 186 ±2)    PASS
bbox.y:    186.8 mm  (expected 186 ±2)    PASS
bbox.z:    6.5 mm    (expected 6.5 ±0.5)  PASS
watertight: true                           PASS
volume:    70.5 cm³  (expected 10–80)      PASS
fits bed:  186.8 mm  (max 256)             PASS
```

## Source Files

- [`fan-tub-adapter.scad`](../designs/fan-tub-adapter/fan-tub-adapter.scad) — Parametric OpenSCAD source
- [`fan-tub-adapter.stl`](../designs/fan-tub-adapter/fan-tub-adapter.stl) — Ready-to-slice STL
- [`spec.json`](../designs/fan-tub-adapter/spec.json) — Validation spec
