// =============================================================================
// Caliper-Test — Gridfinity 2x1 12u bin for HARTE 6-inch digital caliper
// =============================================================================
// Upright caliper storage with contoured pocket: wide display body cavity
// below, narrow beam slot above. The caliper rests on the transition ledge.

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
caliper_clearance = 2.0;  // per side

display_body_width = 68;       // X - total including beam
display_body_thickness = 16;   // Y
display_body_length = 63;      // Z along beam axis

beam_width = 16;               // X - face width
beam_thickness = 5;            // Y - edge thickness

// Pocket dimensions (caliper + clearance)
display_cavity_x = display_body_width + 2 * caliper_clearance;    // 72
display_cavity_y = display_body_thickness + 2 * caliper_clearance; // 20
display_cavity_z = display_body_length + caliper_clearance;        // 65

beam_slot_x = beam_width + 2 * caliper_clearance;       // 20
beam_slot_y = beam_thickness + 2 * caliper_clearance;    // 9
beam_slot_z = usable_depth - display_cavity_z;           // 11.8

// Beam slot Y offset: beam runs along one face of display body.
// Beam far edge is flush with display body far edge (coplanar).
// Beam center Y = display body center Y + (display_body_thickness/2 - beam_thickness/2)
//               = 0 + (8 - 2.5) = 5.5mm from display cavity center
beam_slot_y_offset = (display_body_thickness - beam_thickness) / 2;  // 5.5

// Finger relief
finger_relief_height = 10;   // vertical
finger_relief_setback = 10;  // horizontal

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
// Single base unit: stepped chamfer profile swept around a rounded rectangle.
// Profile points from gridfinity-spec.scad:
//   [0, 0] -> [0.8, 0.8] -> [0.8, 2.6] -> [2.95, 4.75]
// At each profile point, the size = base_top - 2*(profile_width - point_x)
// where profile_width = 2.95.

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
// Profile points: [0, 0] -> [0.7, 0.7] -> [0.7, 2.5] -> [2.6, 4.4]
// Swept as a ring around the bin perimeter.

module stacking_lip() {
    pw = GF_STACKING_LIP_DEPTH;  // 2.6
    lip_inner_x = outer_x - 2 * pw;
    lip_inner_y = outer_y - 2 * pw;
    r_lip_inner = max(0.1, r_outer - pw);

    difference() {
        // Outer swept profile
        _lip_sweep(outer_x, outer_y, r_outer);

        // Inner cutout
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
// BIN SHELL — walls + floor + base + lip
// =============================================================================

module bin_shell() {
    union() {
        // Base grid
        base_grid();

        // Walls: outer shell minus inner cavity
        difference() {
            rounded_rect(outer_x, outer_y, body_height, r_outer);

            // Internal cavity with bottom fillet
            translate([0, 0, floor_z]) {
                // Main cavity above fillet
                translate([0, 0, r_fillet])
                    rounded_rect(inner_x, inner_y,
                                 body_height - floor_z - r_fillet + 0.01,
                                 r_inner);
                // Fillet transition zone
                hull() {
                    translate([0, 0, r_fillet])
                        rounded_rect(inner_x, inner_y, 0.01, r_inner);
                    rounded_rect(inner_x - 2*r_fillet, inner_y - 2*r_fillet,
                                 0.01, max(0.1, r_inner - r_fillet));
                }
            }
        }

        // Stacking lip at top of body
        translate([0, 0, body_height])
            stacking_lip();
    }
}

// =============================================================================
// POCKET — contoured two-stage cavity for caliper
// =============================================================================
// The pocket is cut from the bin shell. It consists of:
//   1. Display body cavity: wide, from floor to floor+65mm
//   2. Beam slot: narrow, from floor+65mm to body top
//   3. Finger relief chamfer at the display cavity top opening

module pocket() {
    // Pocket is centered in bin XY
    // Display cavity centered at origin
    // Beam slot offset in Y by beam_slot_y_offset

    union() {
        // Display body cavity: from floor to floor + display_cavity_z
        translate([0, 0, floor_z - 0.01])
            rounded_rect(display_cavity_x, display_cavity_y,
                         display_cavity_z + 0.02, 2.0);

        // Beam slot: from display cavity top to body top
        // Offset in Y to center on the beam position
        translate([0, beam_slot_y_offset, floor_z + display_cavity_z - 0.01])
            rounded_rect(beam_slot_x, beam_slot_y,
                         beam_slot_z + 0.02, 1.0);

        // Finger relief chamfer on the display cavity opening
        // The opening is at Z = floor_z + display_cavity_z = 72.2
        // Chamfer goes from Z=72.2 down to Z=62.2 (10mm below opening)
        // At the opening (top), the pocket widens by finger_relief_setback on each side
        // At 10mm below opening (bottom of chamfer), it's the regular cavity size
        finger_relief();
    }
}

module finger_relief() {
    opening_z = floor_z + display_cavity_z;  // 72.2
    chamfer_bottom_z = opening_z - finger_relief_height;  // 62.2

    // Compute relief widening, capping to inner cavity dimensions
    // (prevents eating through the bin walls)
    relief_x = min(display_cavity_x + 2 * finger_relief_setback, inner_x);  // min(92, 81.1) = 81.1
    relief_y = min(display_cavity_y + 2 * finger_relief_setback, inner_y);  // min(40, 39.1) = 39.1

    // Hull from regular cavity size at bottom to widened size at top
    hull() {
        // Bottom of chamfer: regular display cavity size
        translate([0, 0, chamfer_bottom_z])
            rounded_rect(display_cavity_x, display_cavity_y, 0.01, 2.0);

        // Top of chamfer: widened for finger access
        translate([0, 0, opening_z])
            rounded_rect(relief_x, relief_y, 0.01, 3.0);
    }

    // Extend the widened opening up through the beam slot zone to body top
    // so the finger relief blends into the open top
    hull() {
        translate([0, 0, opening_z - 0.01])
            rounded_rect(relief_x, relief_y, 0.01, 3.0);
        translate([0, 0, body_height + 0.01])
            rounded_rect(relief_x, relief_y, 0.01, 3.0);
    }
}

// =============================================================================
// FINAL ASSEMBLY
// =============================================================================

difference() {
    bin_shell();
    pocket();
}

// =============================================================================
// DIMENSION REPORTING
// =============================================================================

// Overall bin dimensions
report_dimensions(outer_x, outer_y, total_height, "bin_outer");

// Body (no lip)
report_dimensions(outer_x, outer_y, body_height, "bin_body");

// Internal usable space
report_dimensions(inner_x, inner_y, usable_depth, "bin_inner");

// Display cavity
report_dimensions(display_cavity_x, display_cavity_y, display_cavity_z, "display_cavity");

// Beam slot
report_dimensions(beam_slot_x, beam_slot_y, beam_slot_z, "beam_slot");
