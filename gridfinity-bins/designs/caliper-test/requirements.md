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

### Pocket (caliper + 2 mm clearance each side)

| Dimension | Value | Source |
|---|---|---|
| Display cavity width (along bin X) | 72 mm | 68 + 2 × 2 mm clearance |
| Display cavity depth (along bin Y) | 20 mm | 16 + 2 × 2 mm clearance |
| Display cavity height | 65 mm | 63 + 2 mm clearance above floor |
| Beam slot width (along bin X) | 20 mm | 16 + 2 × 2 mm clearance |
| Beam slot depth (along bin Y) | 9 mm | 5 + 2 × 2 mm clearance |
| Beam slot height | 11.8 mm | internal usable depth 76.8 − display cavity height 65.0 |
| Wall from display cavity edge to bin wall (each side, X) | 4.55 mm | (81.1 − 72) / 2 |
| Wall from beam slot to bin wall (each side, Y) | 15.05 mm | (39.1 − 9) / 2 |
| Ledge depth (display body rests on this) | 5.5 mm | (20 − 9) / 2 each side in Y; (72 − 20) / 2 each side in X |
| Finger relief chamfer height | 10 mm | spec — measured from pocket top opening downward |
| Finger relief chamfer setback | 10 mm | spec — horizontal clearance cut from pocket rim |

## Features

### Feature 1: Gridfinity Base Grid

- **Purpose**: Mechanical interlock with Gridfinity baseplates. Locks the bin in place against lateral sliding. Enables stacking.
- **Critical dimensions**: 2-unit base grid; base profile per GF_BASE_PROFILE (4.75 mm tall stepped chamfer, 2.95 mm horizontal reach); bridge plate at 4.75–7.0 mm elevation; top at Z = 7.0 mm.
- **Mating interfaces**: Gridfinity baseplate receptacle. Clearance fit — 0.1 mm first-step offset between base profile (0.8 mm) and baseplate pocket (0.7 mm) creates the mating gap. Per-side XY clearance: 0.25 mm.

### Feature 2: Bin Walls and Floor

- **Purpose**: Structural shell that contains the pocket and provides the internal usable volume.
- **Critical dimensions**: 83.5 × 41.5 mm outer XY; 84.0 mm body height; 1.2 mm wall thickness; 2.8 mm internal bottom corner fillet radius; floor at Z = 7.2 mm from bin bottom.
- **Mating interfaces**: None — walls are self-contained.

### Feature 3: Stacking Lip

- **Purpose**: Allows this bin to receive another Gridfinity bin stacked on top, and to stack onto other bins' stacking lips.
- **Critical dimensions**: 4.4 mm tall; 2.6 mm horizontal depth; profile per GF_STACKING_LIP (0.7 mm catch at 45°, 1.8 mm vertical, 1.9 mm at 45°); 0.6 mm fillet at top outer edge; placed at Z = 84.0 mm (body top).
- **Mating interfaces**: Upper bin's base profile. Catch step 0.7 mm matches baseplate pocket profile — same geometry, same clearance.

### Feature 4: Display Body Cavity (lower pocket)

- **Purpose**: Houses the caliper's display body. Forms the wide lower portion of the two-stage pocket. The floor of this cavity supports the caliper weight through the ledge transition above.
- **Critical dimensions**: 72 mm wide (X) × 20 mm deep (Y); height from bin floor = 65 mm (Z = 7.2 mm to Z = 72.2 mm). Pocket is centered in the bin's XY.
- **Mating interfaces**: Caliper display body (68 × 16 mm nominal, ±2 mm). Clearance fit: +2 mm each side (+4 mm total per axis). Resulting gap: 2 mm each side in both X and Y. This is generous clearance to accommodate measurement uncertainty.

### Feature 5: Beam Slot (upper pocket)

- **Purpose**: Guides the beam above the display body cavity. The narrowing from display cavity to beam slot creates the support ledge the caliper rests on. The slot continues from the display cavity top to the bin body top.
- **Critical dimensions**: 20 mm wide (X) × 9 mm deep (Y); height from Z = 72.2 mm to Z = 84.0 mm (11.8 mm tall). Centered in the bin's XY, coaxial with the center of the beam as positioned within the display body cavity.
- **Beam centering note**: The beam runs along one face of the display body. The beam's centerline is offset from the display body's centerline. With the display body cavity centered in the bin, the beam's face-center sits at X = 0 (centered) and Y-offset = (display body thickness / 2) − (beam thickness / 2) = 8 − 2.5 = 5.5 mm from display cavity center toward the back. The beam slot must be centered on the beam, not on the display body, to avoid forcing the caliper into a twisted position. Beam slot center in Y = (display body cavity center Y) + 5.5 mm offset. **Modeler must verify beam centering geometry from the cross-section data in measurements.json before implementing.**
- **Mating interfaces**: Caliper beam (16 × 5 mm nominal, ±2 mm). Clearance fit: +2 mm each side.

### Feature 6: Pocket Transition Ledge

- **Purpose**: The horizontal surface where the display body cavity narrows to the beam slot. The caliper's display body upper rim rests on this ledge, supporting the full weight of the caliper. This is the primary load-bearing surface.
- **Critical dimensions**: Ledge width each side in X = (72 − 20) / 2 = 26 mm. Ledge width each side in Y = (20 − 9) / 2 = 5.5 mm. Ledge is at Z = 72.2 mm elevation. Minimum ledge flat area per side: 26 × 5.5 mm on each long side. Ledge thickness = the bin wall/infill above the display body cavity floor at that elevation; this is solid shell material — no minimum thickness concern.
- **Printability**: The ledge is a horizontal surface at Z = 72.2 mm. It is fully supported from below by the solid display body cavity walls. No bridge or overhang issue.

### Feature 7: Finger Relief

- **Purpose**: Allows the user to grip and extract the caliper. Without this, the caliper's display body sits 65 mm deep and the top of the display body is only ~11.8 mm below the bin rim — too tight for fingers.
- **Critical dimensions**: 45° chamfer applied to the top opening of the display body cavity on all four sides (or at minimum the two long sides). Chamfer: 10 mm horizontal setback × 10 mm vertical height, measured from the pocket rim downward at Z = 72.2 mm. The chamfer blends into the full cavity width at the bottom and the full display cavity width + 10 mm at the top of the chamfer zone.
- **Overhang note**: The chamfer is 45° — exactly at the FDM threshold. Acceptable without supports but marginal. The modeler may reduce to 40° (slightly shallower) if preferred for margin.

## Caliper Anatomy Note for Modeler

When the caliper is closed (jaws together), the display body is positioned at the fixed-jaw end of the beam. The beam runs through the display body; the beam's flat face and the display body's flat face are coplanar on one side. The depth rod protrudes from the beam's far end (the end opposite the jaws).

In the holder, the caliper will be placed jaw-end up, depth-rod end down. But the display body is at the jaw end — so when the caliper is placed upright, the display body is at the top of the beam (jaw end) and the depth-rod end of the beam extends down through the slot or vice versa. Re-reading the anatomy: the display body is at the jaw end; the long portion of the beam extends from the display body to the opposite (depth-rod) end.

Orientation in the bin: Display body DOWN (seated in the wide cavity), with the long beam extending UP out of the slot. The jaws are at the SAME end as the display body — so both the jaws and display body are at the bottom of the holder, and the bare beam end (with depth rod) is at the top. The depth rod protrudes from the beam's top end in this orientation (15 mm above the beam end, which will be above the bin rim). The large jaws (40 mm) extend horizontally from the base of the display body; in this upright orientation, the jaws are near the bottom of the display body cavity and clear it because the cavity is wide enough.

The jaw length (40 mm from beam edge) is accommodated within the display cavity width of 72 mm: jaw extends 40 mm from beam edge; beam is centered in the 72 mm cavity, so each side of the beam has (72 − 20) / 2 = 26 mm clearance — more than enough for the 40 mm jaw only if the jaw protrudes only to one side. The jaw extends in the Y direction (perpendicular to beam axis). With 20 mm Y depth in the cavity, the jaw (which is thin, ~5 mm thick) fits in the 20 mm depth with clearance. The modeler should note that jaw clearance is adequate.

## Material & Tolerances

- Material: PLA
- Gridfinity mating clearance: 0.25 mm per side (built into spec dimensions)
- Caliper pocket clearance: +2 mm per side (clearance fit, generous to cover ±2 mm measurement uncertainty)
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
| Finger relief chamfer | 45° overhang | Marginal — exactly at 45° limit. Suggest modeler implement at 40–45°. No supports needed but flag for review. |
| Display cavity walls | Vertical | Pass |
| Beam slot walls | Vertical | Pass |
| Pocket transition ledge | Horizontal surface, fully supported | Pass — solid walls below, no bridge |
| Wall thickness (bin walls) | 1.2 mm | Pass — at minimum 3-perimeter threshold |
| Bin total height | 88.4 mm | Pass — within 256 mm build volume |
| Bin total width | 83.5 mm | Pass — within 256 mm build volume |
| Bridge spans | None in design | Pass — no unsupported horizontal spans |
| Large jaw clearance in display cavity | Jaw 40 mm, cavity side clearance 26 mm in X | Pass — jaws fit horizontally; Y clearance check needed by modeler (jaw protrudes perpendicular to beam, not into the 20 mm Y depth — verify thickness vs. 20 mm slot) |
