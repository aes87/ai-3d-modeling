# Caliper-Test Requirements

## Design Intent

A Gridfinity-compatible 2×1 bin that stores a HARTE 6-inch digital caliper in upright orientation. The caliper stands with its display body seated in a contoured pocket at the bin floor. The beam and jaws extend upward out of the bin, making the caliper immediately grabbable without fumbling. The pocket is shaped to the caliper's cross-section — wide at the bottom for the display body, narrowing to a beam-width slot above — so the caliper rests by gravity on the ledge where the pocket transitions.

This bin integrates into a standard Gridfinity baseplate and stacks with other bins via the standard stacking lip.

## Print Orientation

Base on bed. Standard Gridfinity print orientation. The bin body grows upward from the bed, with the base profile (45° stepped chamfers) printing support-free as designed. The stacking lip at the top prints as a 45° overhang — within FDM limits. The pocket is a vertical through-void cut from the top, which prints cleanly without supports.

## Dimensions & Sources

### Bin (Gridfinity-derived)

| Dimension | Value | Source |
|---|---|---|
| Grid size | 2×1 units | user-specified |
| Outer width (X, long axis) | 83.5 mm | gridfinity-spec.scad: 2 × 42 − 0.5 |
| Outer depth (Y, short axis) | 41.5 mm | gridfinity-spec.scad: 1 × 42 − 0.5 |
| Height units | 12u | user-specified |
| Body height (no lip) | 84.0 mm | 12 × 7 mm |
| Stacking lip height | 4.4 mm | gridfinity-spec.scad: GF_STACKING_LIP_HEIGHT |
| Total height (with lip) | 88.4 mm | 84.0 + 4.4 |
| Internal floor elevation | 7.2 mm | gridfinity-spec.scad: GF_INTERNAL_FLOOR_ELEV |
| Internal usable depth | 76.8 mm | 84.0 − 7.2 |
| Wall thickness | 1.2 mm | GF_WALL_THICKNESS_THICK (3 perimeters at 0.4mm nozzle) |
| Inner width (X) | 81.1 mm | 83.5 − 2 × 1.2 |
| Inner depth (Y) | 39.1 mm | 41.5 − 2 × 1.2 |
| Corner radius (exterior) | 3.75 mm | gridfinity-spec.scad: GF_BASE_TOP_RADIUS |
| Internal fillet radius | 2.8 mm | gridfinity-spec.scad: GF_INTERNAL_FILLET |
| Base profile height | 4.75 mm | gridfinity-spec.scad: GF_BASE_PROFILE_HEIGHT |
| Base grid total height | 7.0 mm | gridfinity-spec.scad: GF_BASE_HEIGHT |

### Caliper (measured from grid photos, ±2 mm)

| Dimension | Value | Source |
|---|---|---|
| Overall length | 235 mm | measurements.json — jaw tip to beam end |
| Beam width (face, long axis) | 16 mm | measurements.json |
| Beam thickness (edge) | 5 mm | measurements.json |
| Display body length along beam | 63 mm | measurements.json |
| Display body total width | 68 mm | measurements.json — including beam |
| Display body extension beyond beam far edge | 52 mm | measurements.json |
| Display body thickness | 16 mm | measurements.json |
| Large jaw length | 40 mm | measurements.json — beam edge to jaw tip |
| Depth rod protrusion | 15 mm | measurements.json — from beam end |

### Pocket (caliper + 1 mm clearance each side, v4)

| Dimension | Value | Source |
|---|---|---|
| Pocket width (along bin X) | 70 mm | 68 + 2 × 1 mm clearance |
| Pocket depth (along bin Y) | 18 mm | 16 + 2 × 1 mm clearance |
| Pocket height | 64 mm | 63 + 1 mm clearance above floor |
| Pocket corner radius | 1.5 mm | aesthetic finish, no clearance impact |
| Pocket mouth chamfer | 1.5 mm at 45° | lead-in bevel for easy insertion |
| Pocket wall thickness (X sides) | 5.55 mm | (81.1 − 70) / 2 — interior wall to pocket |
| Pocket wall thickness (Y sides) | 10.55 mm | (39.1 − 18) / 2 — interior wall to pocket |
| Pocket wall height | 64.2 mm | Z=7.0 to Z=71.2 (base height to pocket top) |
| Open interior above pocket | 81.1 × 39.1 mm | full bin interior from Z=71.2 to Z=84.0 |

## Features

### Feature 1: Gridfinity Base Grid

- **Purpose**: Mechanical interlock with Gridfinity baseplates. Locks the bin in place against lateral sliding. Enables stacking.
- **Critical dimensions**: 2-unit base grid; base profile per GF_BASE_PROFILE (4.75 mm tall stepped chamfer, 2.95 mm horizontal reach); bridge plate at 4.75–7.0 mm elevation; top at Z = 7.0 mm.
- **Mating interfaces**: Gridfinity baseplate receptacle. Clearance fit — 0.1 mm first-step offset between base profile (0.8 mm) and baseplate pocket (0.7 mm) creates the mating gap. Per-side XY clearance: 0.25 mm.

### Feature 2: Bin Shell (thin walls, from gf_bin library)

- **Purpose**: Standard Gridfinity thin-walled shell providing exterior structure, interior cavity, and library-standard geometry (base profile, wall thickness, corner radii, internal fillet).
- **Critical dimensions**: 83.5 × 41.5 mm outer XY; 84.0 mm body height; 1.2 mm wall thickness; 81.1 × 39.1 mm interior; 3.75 mm outer corner radius; 2.8 mm internal fillet.
- **Mating interfaces**: Base mates with baseplate; stacking lip mates with bins above.

### Feature 3: Stacking Lip

- **Purpose**: Allows this bin to receive another Gridfinity bin stacked on top, and to stack onto other bins' stacking lips.
- **Critical dimensions**: 4.4 mm tall; 2.6 mm horizontal depth; profile per GF_STACKING_LIP (0.7 mm catch at 45°, 1.8 mm vertical, 1.9 mm at 45°); 0.6 mm fillet at top outer edge; placed at Z = 84.0 mm (body top).
- **Mating interfaces**: Upper bin's base profile. Catch step 0.7 mm matches baseplate pocket profile — same geometry, same clearance.

### Feature 4: Pocket Walls (v4)

- **Purpose**: Solid fill inside the lower bin interior creating a walled pocket for the caliper display body. The pocket walls rise from the bin floor to Z = 71.2 mm, where they end and the full bin interior (81.1 × 39.1 mm) opens up. This creates a visible shelf/ledge and a two-zone interior: narrow pocket below, wide open space above.
- **Critical dimensions**: Pocket walls fill the interior from Z = 7.0 to Z = 71.2 mm. Wall thickness around pocket: 5.55 mm (X sides), 10.55 mm (Y sides). Pocket opening: 70 × 18 mm with 1.5 mm corner radii. 1.5 mm 45° lead-in chamfer at pocket mouth.
- **Insertion path**: Caliper enters through the stacking lip opening (78.3 × 36.3 mm), passes through the wide open upper interior (81.1 × 39.1 mm), and drops into the narrower 70 × 18 mm pocket below. The chamfered pocket mouth guides insertion.

### Feature 5: Through-Pocket Void (v4)

- **Purpose**: 70 × 18 mm rectangular pocket from floor (Z = 7.2) through the pocket wall top (Z = 71.2). Caliper display body sits in this pocket; beam extends up through the open interior above.
- **Critical dimensions**: 70 mm wide (X) × 18 mm deep (Y) × 64 mm tall. Centered in bin XY. 1.5 mm corner radius for finished appearance.
- **Mating interfaces**: Caliper display body (68 × 16 mm nominal, ±2 mm). Clearance fit: +1 mm each side (+2 mm total per axis).

### Features 6–7: REMOVED (v3+)

- **Beam slot**, **pocket transition ledge**, and **finger relief** from v2 were removed. The L-shaped pocket was not insertable. v4 uses pocket walls with an open upper bin instead.

## Caliper Anatomy Note for Modeler

When the caliper is closed (jaws together), the display body is positioned at the fixed-jaw end of the beam. The beam runs through the display body; the beam's flat face and the display body's flat face are coplanar on one side. The depth rod protrudes from the beam's far end (the end opposite the jaws).

In the holder, the caliper will be placed jaw-end up, depth-rod end down. But the display body is at the jaw end — so when the caliper is placed upright, the display body is at the top of the beam (jaw end) and the depth-rod end of the beam extends down through the slot or vice versa. Re-reading the anatomy: the display body is at the jaw end; the long portion of the beam extends from the display body to the opposite (depth-rod) end.

Orientation in the bin: Display body DOWN (seated in the wide cavity), with the long beam extending UP out of the slot. The jaws are at the SAME end as the display body — so both the jaws and display body are at the bottom of the holder, and the bare beam end (with depth rod) is at the top. The depth rod protrudes from the beam's top end in this orientation (15 mm above the beam end, which will be above the bin rim). The large jaws (40 mm) extend horizontally from the base of the display body; in this upright orientation, the jaws are near the bottom of the display body cavity and clear it because the cavity is wide enough.

The jaw length (40 mm from beam edge) is accommodated within the 70 mm pocket width. The jaw extends in the Y direction (perpendicular to beam axis). With 18 mm Y depth in the pocket, the jaw (which is thin, ~5 mm thick) fits with clearance.

## Material & Tolerances

- Material: PLA
- Gridfinity mating clearance: 0.25 mm per side (built into spec dimensions)
- Caliper pocket clearance: +1 mm per side (v2 — tighter fit than v1's +2 mm)
- No press fits, no snap fits
- No heat-set inserts required

## Constraints

- Build volume: 256 × 256 × 256 mm — bin is 83.5 × 41.5 × 88.4 mm, well within limits
- Minimum wall thickness: 1.2 mm — all walls meet this
- Internal floor fillet: 2.8 mm radius at bottom corners of internal cavity (standard Gridfinity)
- Magnet/screw holes: not required for this bin (storage only, no weight needed)
- Pocket is centered in the bin XY footprint

## Printability Pre-Screen

| Feature | Check | Status |
|---|---|---|
| Base profile chamfers | 45° overhangs | Pass — standard Gridfinity profile, FDM-designed |
| Stacking lip | 45° overhangs | Pass — standard Gridfinity profile |
| Display cavity walls | Vertical | Pass |
| Pocket walls | Vertical | Pass — 5.55mm (X) and 10.55mm (Y) thick |
| Pocket wall top shelf | Horizontal surface at Z=71.2 | Pass — fully supported by pocket walls below |
| Wall thickness (bin walls) | 1.2 mm | Pass — at minimum 3-perimeter threshold |
| Bin total height | 88.4 mm | Pass — within 256 mm build volume |
| Bin total width | 83.5 mm | Pass — within 256 mm build volume |
| Bridge spans | None in design | Pass — no unsupported horizontal spans |
| Large jaw clearance in display cavity | Jaw 40 mm, cavity side clearance 26 mm in X | Pass — jaws fit horizontally within 70 mm X cavity; Y: jaw thickness fits within 18 mm Y cavity |
