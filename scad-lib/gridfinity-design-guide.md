# Gridfinity Design Guide

Reference for designing Gridfinity-compatible parts in this pipeline.

## System Overview

Gridfinity is a modular storage system by Zack Freedman. All dimensions derive from a 42mm square grid with 7mm height units. Bins sit on baseplates and stack on each other via interlocking profiles.

## Core Dimensions

| Parameter | Value | Notes |
|---|---|---|
| Grid pitch | 42 mm | Center-to-center |
| Height unit | 7 mm | "1u" |
| Bin clearance | 0.5 mm total (0.25/side) | Bin outer = units × 42 − 0.5 |
| Corner radius (base top) | 3.75 mm | 7.5 mm diameter |
| Corner radius (baseplate outer) | 4.0 mm | 8.0 mm diameter |
| Wall thickness | 0.95 mm (min) | 1.2 mm recommended for strength |
| Divider thickness | 1.2 mm | Internal partitions |
| Internal fillet | 2.8 mm | Bottom corners inside bin |

## Bin Sizes (Outer XY)

| Grid | Outer size |
|---|---|
| 1×1 | 41.5 × 41.5 mm |
| 2×1 | 83.5 × 41.5 mm |
| 3×1 | 125.5 × 41.5 mm |
| 2×2 | 83.5 × 83.5 mm |
| 3×2 | 125.5 × 83.5 mm |
| 4×1 | 167.5 × 41.5 mm |

Formula: `units × 42 − 0.5`

## Height Calculations

| Units | Body height | With stacking lip |
|---|---|---|
| 1u | 7.0 mm | 11.4 mm |
| 2u | 14.0 mm | 18.4 mm |
| 3u | 21.0 mm | 25.4 mm |
| 4u | 28.0 mm | 32.4 mm |
| 5u | 35.0 mm | 39.4 mm |
| 6u | 42.0 mm | 46.4 mm |

Internal usable depth ≈ body height − 7.2 mm (base + floor consumed).

## Three Critical Interface Profiles

### 1. Base Profile (bin bottom → baseplate)

Three-segment stepped profile at the bottom of each bin unit cell:

```
      ←2.95mm→
      ┌───────┐ ↑
     ╱         4.75mm
    │          │
   ╱           ↓
   └──────────┘

Segment 1: 0.8mm at 45° (lower chamfer)
Segment 2: 1.8mm vertical (straight wall)
Segment 3: 2.15mm at 45° (upper chamfer)
```

Corner radius transitions from 0.8mm (bottom) to 3.75mm (top).

### 2. Baseplate Receptacle (pocket that receives bins)

Same structure as base profile but 0.1mm smaller on the first step — this creates the mating clearance:

```
Segment 1: 0.7mm at 45° (vs 0.8mm on bin base)
Segment 2: 1.8mm vertical (same)
Segment 3: 2.15mm at 45° (same)
Total: 2.85mm wide × 4.65mm tall
```

### 3. Stacking Lip (bin top → allows stacking)

Profile at the top of bin walls. Mirrors the baseplate receptacle profile so bins can stack on each other:

```
Segment 1: 0.7mm at 45° outward (the catch/hook)
Segment 2: 1.8mm vertical
Segment 3: 1.9mm at 45° outward (upper chamfer)
Total: 2.6mm deep × 4.4mm tall
Fillet: 0.6mm at top outer edge
Support: 1.2mm tall support structure below lip
```

The stacking lip's catch step (0.7mm) matches the baseplate's first step (0.7mm). When a bin stacks on another, the lower bin's lip acts as a baseplate for the upper bin's base profile.

## Magnet and Screw Holes

Standard magnets: 6mm dia × 2mm tall neodymium discs.

| Feature | Dimension |
|---|---|
| Magnet hole diameter | 6.5 mm |
| Magnet hole depth | 2.4 mm |
| Screw hole diameter | 3.0 mm (M3) |
| Hole position from side | 8.0 mm |
| Crush rib inner diameter | 5.9 mm |
| Number of crush ribs | 8 |

Holes are in all four corners of each grid unit cell.

## Designing Custom Gridfinity Bins

### Using the Module Library

```openscad
include <gridfinity.scad>

// Standard bin shell
gf_bin(grid_x=2, grid_y=1, height_units=3, lip=true);

// Then subtract your custom cavity:
difference() {
    gf_bin(grid_x=2, grid_y=1, height_units=3);
    translate([0, 0, GF_INTERNAL_FLOOR_ELEV])
        your_cavity_shape();
}
```

### Custom Objects That Mate with Gridfinity

For objects that need to sit on a Gridfinity baseplate but aren't standard bins:

```openscad
include <gridfinity.scad>

// Add a Gridfinity base to any shape
union() {
    gf_base_grid(grid_x=2, grid_y=1);

    // Your custom shape starting at z = GF_BASE_HEIGHT
    translate([0, 0, GF_BASE_HEIGHT])
        your_custom_shape();
}
```

### Sizing Objects for Gridfinity

When measuring an object to house in a Gridfinity bin:

1. Measure the object's footprint
2. Add wall thickness (2 × 0.95mm minimum) and clearance
3. Round up to the nearest grid unit: `ceil(total / 42)`
4. Choose height: `ceil(object_height / 7)` units, plus 1u for the base
5. Verify: internal space = `gf_bin_width(units) − 2 × wall` wide, `gf_bin_internal_depth(height_units)` deep

### Print Orientation

Gridfinity bins print upright (base on bed). The base profile is designed for bed-first FDM printing:
- First layer is the smallest footprint (0.8mm radius corners)
- Each subsequent layer expands outward following the 45° chamfers
- No supports needed for standard bin geometry
- The stacking lip at the top involves 45° overhangs — within FDM limits

## Known Variants

- **Reduced lip**: Shortened stacking lip for bins < 1.8u tall
- **No lip**: No stacking lip for bins < 1.2u tall
- **Half-grid**: 21mm pitch for small items
- **Weighted baseplate**: Cutouts in baseplate bottom for weight reduction
- **Skeletonized baseplate**: Minimal-material baseplate

## Source Implementations

Two reference OpenSCAD implementations were studied:

1. **kennetek/gridfinity-rebuilt-openscad** — comprehensive, modular (`src/core/` structure), struct-based bin parameterization. The authoritative source for dimensional constants.
2. **vector76/gridfinity_openscad** — compact, procedural, single-file style. Easier to understand. Uses hull-based construction.

Both agree on all fundamental constants. Minor differences in wall thickness defaults and construction approach.

## Files in This Project

| File | Purpose |
|---|---|
| `scad-lib/gridfinity-spec.scad` | All dimensional constants with source annotations |
| `scad-lib/gridfinity.scad` | Usable OpenSCAD modules (base, lip, bin shell) |
| `scad-lib/gridfinity-design-guide.md` | This document |
