// =============================================================================
// Caliper-Test v4 — Gridfinity 2x1 12u bin for HARTE 6-inch digital caliper
// =============================================================================
// Standard thin-walled Gridfinity shell with internal pocket walls.
// Lower bin: 70×18mm pocket for display body (5.55mm walls each X side,
// 10.55mm walls each Y side). Upper bin: open at full interior for insertion.
// Caliper enters through wide open top, drops into narrower pocket below.
//
// Side cross-section (looking at Y face):
//
//   Z (mm)
//  88.4 ┌─────────────────────────┐ ← stacking lip top
//       │    lip ring (2.6mm)     │
//  84.0 ├────┐               ┌────┤ ← body top / lip base
//       │    │               │    │
//       │    │  open interior│    │   81.1 × 39.1mm
//       │    │  (thin walls) │    │
//  71.2 │    ├───┐       ┌───┤    │ ← pocket wall top (shelf)
//       │    │///│       │///│    │
//       │    │///│pocket │///│    │   70 × 18mm pocket
//       │    │///│70×18  │///│    │   with 1.5mm corner radii
//       │    │///│       │///│    │
//   7.2 │    │///│ floor │///│    │ ← internal floor
//   7.0 ├────┴───┴───────┴───┴────┤ ← base height
//       │     base grid           │
//   0.0 └─────────────────────────┘ ← bed
//
//   /// = solid pocket wall fill
//
// The display body (68×16×63mm) sits in the pocket.  The beam (16×5mm)
// extends upward through the open interior and out through the lip.

include <gridfinity.scad>
include <bambu-x1c.scad>

$fn = 80;

// =============================================================================
// PARAMETERS
// =============================================================================

// Grid sizing
grid_x = 2;
grid_y = 1;
height_units = 12;

// Derived outer dimensions
outer_x = gf_bin_width(grid_x);             // 83.5
outer_y = gf_bin_width(grid_y);             // 41.5
body_height = height_units * GF_HEIGHT_UNIT; // 84.0
total_height = body_height + GF_STACKING_LIP_HEIGHT; // 88.4

// Wall and floor
wall = GF_WALL_THICKNESS_THICK;             // 1.2
inner_x = outer_x - 2 * wall;               // 81.1
inner_y = outer_y - 2 * wall;               // 39.1
floor_z = GF_INTERNAL_FLOOR_ELEV;           // 7.2
usable_depth = body_height - floor_z;        // 76.8

// Corner radii
r_outer = GF_BASE_TOP_RADIUS;               // 3.75
r_inner = max(0.1, r_outer - wall);          // 2.55

// Caliper dimensions (from measurements.json)
caliper_clearance = 1.0;  // per side

display_body_width     = 68;  // X — total including beam
display_body_thickness = 16;  // Y
display_body_length    = 63;  // Z along beam axis

beam_width     = 16;  // X — face width
beam_thickness =  5;  // Y — edge thickness

// Pocket dimensions (caliper + clearance)
pocket_x = display_body_width + 2 * caliper_clearance;      // 70
pocket_y = display_body_thickness + 2 * caliper_clearance;   // 18
pocket_z = display_body_length + caliper_clearance;          // 64
r_pocket = 1.5;  // pocket corner radius

// Pocket wall geometry
pocket_wall_top    = floor_z + pocket_z;                       // 71.2
pocket_wall_fill_h = pocket_wall_top - GF_BASE_HEIGHT + 0.01; // 64.21

// Pocket wall thicknesses (reference — solid fill around pocket)
pocket_wall_x = (inner_x - pocket_x) / 2;  // 5.55
pocket_wall_y = (inner_y - pocket_y) / 2;   // 10.55

// Lead-in chamfer at pocket mouth
pocket_chamfer = 1.5;  // 45° bevel easing caliper into pocket

// =============================================================================
// ASSEMBLY
// =============================================================================
// 1. gf_bin() creates the standard thin-walled Gridfinity shell.
// 2. Pocket wall fill adds solid material inside the lower bin interior.
// 3. Pocket cut carves the 70×18mm pocket through the fill.
// 4. Chamfer cut bevels the pocket mouth for easy caliper insertion.
//
// Above the pocket walls (Z > 71.2), the full 81.1×39.1mm bin interior
// is open — the caliper's display body enters here and drops into the
// narrower pocket below.

difference() {
    union() {
        // Standard Gridfinity bin shell
        gf_bin(grid_x, grid_y, height_units, lip=true, wall=wall);

        // Pocket walls: fill lower interior with solid material.
        // Slightly oversized (+0.02mm) to overlap bin inner walls
        // and avoid coincident faces at the fill-wall boundary.
        translate([0, 0, GF_BASE_HEIGHT - 0.01])
            _gf_rounded_rect(inner_x + 0.02, inner_y + 0.02,
                             pocket_wall_fill_h, r_inner);
    }

    // Pocket void and lead-in chamfer
    union() {
        // Main pocket: 70×18mm from floor through pocket wall top
        translate([0, 0, floor_z - 0.01])
            _gf_rounded_rect(pocket_x, pocket_y,
                             pocket_z + 0.02, r_pocket);

        // Lead-in chamfer: 45° bevel at pocket mouth
        translate([0, 0, pocket_wall_top - pocket_chamfer])
            hull() {
                _gf_rounded_rect(pocket_x, pocket_y,
                                 0.01, r_pocket);
                translate([0, 0, pocket_chamfer + 0.01])
                    _gf_rounded_rect(
                        pocket_x + 2 * pocket_chamfer,
                        pocket_y + 2 * pocket_chamfer,
                        0.01,
                        r_pocket + pocket_chamfer);
            }
    }
}

// =============================================================================
// DIMENSION REPORTING
// =============================================================================

report_dimensions(outer_x, outer_y, total_height, "bin_outer");
report_dimensions(outer_x, outer_y, body_height, "bin_body");
report_dimensions(inner_x, inner_y, usable_depth, "bin_inner");
report_dimensions(pocket_x, pocket_y, pocket_z, "pocket");
