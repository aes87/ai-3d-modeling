// =============================================================================
// Caliper-Test v2 — Gridfinity 2x1 12u bin for HARTE 6-inch digital caliper
// =============================================================================
// Upright caliper storage with L-shaped contoured pocket.
//
// Pocket cross-section (looking down into the bin):
//
//   Y (thickness axis)
//   ^
//  18 +--------------------------------------------+
//     |          display body cavity                |
//     |          (70mm x 18mm)                      |
//   7 +--------+                                    |
//     |  beam  |                                    |
//     |  slot  |                                    |
//   0 +--------+------------------------------------+
//     0       18                                   70  -> X (width axis)
//
// The beam slot sits at the min-X, min-Y corner of the display cavity.
// Lower zone (floor to floor+64): full 70x18 display cavity
// Upper zone (floor+64 to body top): only 18x7 beam slot remains open
// No finger relief — user grabs the beam above the bin.

include <gridfinity-spec.scad>
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
outer_x = gf_bin_width(grid_x);          // 83.5
outer_y = gf_bin_width(grid_y);          // 41.5
body_height = height_units * GF_HEIGHT_UNIT; // 84.0
lip_height = GF_STACKING_LIP_HEIGHT;     // 4.4
total_height = body_height + lip_height;  // 88.4

// Wall and floor
wall = GF_WALL_THICKNESS_THICK;          // 1.2
inner_x = outer_x - 2 * wall;            // 81.1
inner_y = outer_y - 2 * wall;            // 39.1
floor_z = GF_INTERNAL_FLOOR_ELEV;        // 7.2
usable_depth = body_height - floor_z;    // 76.8

// Corner radii
r_outer = GF_BASE_TOP_RADIUS;            // 3.75
r_inner = max(0.1, r_outer - wall);      // 2.55
r_fillet = GF_INTERNAL_FILLET;            // 2.8

// Caliper dimensions (from measurements.json)
caliper_clearance = 1.0;  // per side (tighter fit for v2)

display_body_width = 68;       // X - total including beam
display_body_thickness = 16;   // Y
display_body_length = 63;      // Z along beam axis

beam_width = 16;               // X - face width
beam_thickness = 5;            // Y - edge thickness

// Pocket dimensions (caliper + clearance)
display_cavity_x = display_body_width + 2 * caliper_clearance;      // 70
display_cavity_y = display_body_thickness + 2 * caliper_clearance;   // 18
display_cavity_z = display_body_length + caliper_clearance;          // 64

beam_slot_x = beam_width + 2 * caliper_clearance;       // 18
beam_slot_y = beam_thickness + 2 * caliper_clearance;    // 7
beam_slot_z = usable_depth - display_cavity_z;           // 12.8

// =============================================================================
// HELPER: Rounded rectangle centered at origin, bottom at Z=0
// =============================================================================
module rounded_rect(sx, sy, h, r) {
    cr = min(r, min(sx, sy) / 2);
    hull() {
        for (dx = [-1, 1])
            for (dy = [-1, 1])
                translate([dx * (sx/2 - cr), dy * (sy/2 - cr), 0])
                    cylinder(r=cr, h=h);
    }
}

// =============================================================================
// GRIDFINITY BASE PROFILE — built directly from constants
// =============================================================================
module base_unit() {
    pw = GF_BASE_PROFILE_WIDTH;  // 2.95
    bt = GF_BIN_BASE_TOP;        // 41.5
    r_top = GF_BASE_TOP_RADIUS;  // 3.75

    for (i = [0 : len(GF_BASE_PROFILE) - 2]) {
        p0 = GF_BASE_PROFILE[i];
        p1 = GF_BASE_PROFILE[i + 1];

        s0 = bt - 2 * (pw - p0[0]);
        s1 = bt - 2 * (pw - p1[0]);
        r0 = max(0.1, r_top - (pw - p0[0]));
        r1 = max(0.1, r_top - (pw - p1[0]));

        hull() {
            translate([0, 0, p0[1]])
                rounded_rect(s0, s0, 0.01, r0);
            translate([0, 0, p1[1]])
                rounded_rect(s1, s1, 0.01, r1);
        }
    }
}

module base_grid() {
    // Individual base pads
    for (ix = [0 : grid_x - 1])
        for (iy = [0 : grid_y - 1])
            translate([
                (ix - (grid_x - 1) / 2) * GF_GRID_PITCH,
                (iy - (grid_y - 1) / 2) * GF_GRID_PITCH,
                0
            ])
            base_unit();

    // Bridge plate connecting pads: from profile top to base height
    translate([0, 0, GF_BASE_PROFILE_HEIGHT])
        rounded_rect(outer_x, outer_y,
                     GF_BASE_HEIGHT - GF_BASE_PROFILE_HEIGHT,
                     r_outer);
}

// =============================================================================
// STACKING LIP — built directly from constants
// =============================================================================
module stacking_lip() {
    pw = GF_STACKING_LIP_DEPTH;  // 2.6
    lip_inner_x = outer_x - 2 * pw;
    lip_inner_y = outer_y - 2 * pw;
    r_lip_inner = max(0.1, r_outer - pw);

    difference() {
        _lip_sweep(outer_x, outer_y, r_outer);

        translate([0, 0, -0.01])
            rounded_rect(lip_inner_x, lip_inner_y,
                         lip_height + 0.02, r_lip_inner);
    }
}

module _lip_sweep(sx, sy, r) {
    pw = GF_STACKING_LIP_DEPTH;  // 2.6

    for (i = [0 : len(GF_STACKING_LIP) - 2]) {
        p0 = GF_STACKING_LIP[i];
        p1 = GF_STACKING_LIP[i + 1];

        s0x = sx - 2 * (pw - p0[0]);
        s0y = sy - 2 * (pw - p0[0]);
        s1x = sx - 2 * (pw - p1[0]);
        s1y = sy - 2 * (pw - p1[0]);
        r0 = max(0.1, r - (pw - p0[0]));
        r1 = max(0.1, r - (pw - p1[0]));

        hull() {
            translate([0, 0, p0[1]])
                rounded_rect(s0x, s0y, 0.01, r0);
            translate([0, 0, p1[1]])
                rounded_rect(s1x, s1y, 0.01, r1);
        }
    }
}

// =============================================================================
// BIN BODY — solid outer shape (base + block + lip, no interior cavity)
// =============================================================================
// The body is kept solid — the pocket module defines the only interior void.
// This ensures the pocket walls and transition ledge are properly formed.
module bin_body() {
    union() {
        base_grid();
        // Extend 0.01mm above body_height to overlap with lip (avoids
        // coincident faces at block-lip boundary → watertight mesh)
        rounded_rect(outer_x, outer_y, body_height + 0.01, r_outer);
        translate([0, 0, body_height])
            stacking_lip();
    }
}

// =============================================================================
// POCKET — L-shaped contoured cavity (the only interior void)
// =============================================================================
// Subtracted from the solid bin body. Two vertically stacked zones:
//
// 1. Lower zone (floor to floor+64mm): full display body cavity 70x18mm
// 2. Upper zone (floor+64mm to body top + lip): beam slot only 18x7mm
//    at the min-X, min-Y corner of the display cavity
//
// The transition between zones creates the ledge that supports the caliper.
// Display cavity is centered in the bin XY footprint.
// Beam slot is at the min-X, min-Y corner of the display cavity:
//   X: from -35 to -17    Y: from -9 to -2

module pocket() {
    dc_half_x = display_cavity_x / 2;  // 35
    dc_half_y = display_cavity_y / 2;  // 9

    // Beam slot at min-X, min-Y corner of display cavity
    bs_min_x = -dc_half_x;             // -35
    bs_min_y = -dc_half_y;             // -9

    // Lower zone: full display body cavity (70 x 18 x 64)
    translate([-dc_half_x, -dc_half_y, floor_z - 0.01])
        cube([display_cavity_x, display_cavity_y, display_cavity_z + 0.01]);

    // Upper zone: beam slot only (18 x 7)
    // Extends from ledge top through body top and stacking lip to ensure
    // clean opening with no Z-fighting at the lip boundary
    translate([bs_min_x, bs_min_y, floor_z + display_cavity_z - 0.01])
        cube([beam_slot_x, beam_slot_y, beam_slot_z + lip_height + 0.02]);
}

// =============================================================================
// FINAL ASSEMBLY
// =============================================================================

difference() {
    bin_body();
    pocket();
}

// =============================================================================
// DIMENSION REPORTING
// =============================================================================

report_dimensions(outer_x, outer_y, total_height, "bin_outer");
report_dimensions(outer_x, outer_y, body_height, "bin_body");
report_dimensions(inner_x, inner_y, usable_depth, "bin_inner");
report_dimensions(display_cavity_x, display_cavity_y, display_cavity_z, "display_cavity");
report_dimensions(beam_slot_x, beam_slot_y, beam_slot_z, "beam_slot");
