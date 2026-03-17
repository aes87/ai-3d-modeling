// =============================================================================
// cavity-fit — Test print for caliper display body cavity fitment (v2)
// =============================================================================
// A 20mm-tall cross-section slab of the caliper-test bin's display body
// cavity. Verifies the 70x18mm pocket accepts the HARTE 6-inch caliper
// display body with ~1mm clearance per side.
//
// Parent design: caliper-test (gridfinity-bins/designs/caliper-test/)
// v2 change: pocket reduced from 72x20mm (2mm/side) to 70x18mm (1mm/side)

include <gridfinity-spec.scad>
include <bambu-x1c.scad>

$fn = 80;

// =============================================================================
// PARAMETERS — derived from parent caliper-test.scad (v2)
// =============================================================================

// Caliper dimensions (from measurements.json)
caliper_clearance = 1.0;  // per side (v2: reduced from 2.0)

display_body_width     = 68;   // X
display_body_thickness = 16;   // Y

// Pocket dimensions (caliper + clearance) — match parent exactly
display_cavity_x = display_body_width + 2 * caliper_clearance;      // 70
display_cavity_y = display_body_thickness + 2 * caliper_clearance;   // 18

// Wall and corner from parent bin
wall    = GF_WALL_THICKNESS_THICK;   // 1.2
r_outer = GF_BASE_TOP_RADIUS;       // 3.75

// Outer dimensions match parent bin: gf_bin_width(2) x gf_bin_width(1)
outer_x = gf_bin_width(2);          // 83.5
outer_y = gf_bin_width(1);          // 41.5

// Test piece Z geometry
base_plate_z  = 2.0;   // solid base replacing Gridfinity base
cavity_height = 20.0;  // height of the cavity section
total_z       = base_plate_z + cavity_height;  // 22

// Corner radii
r_shell  = r_outer;   // 3.75 — outer shell corners
r_cavity = 2.0;       // inner pocket corner radius

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
// TEST PIECE ASSEMBLY
// =============================================================================

difference() {
    // Outer shell: full height with rounded corners
    rounded_rect(outer_x, outer_y, total_z, r_shell);

    // Cavity: starts at base_plate_z, goes up through the top (open top)
    translate([0, 0, base_plate_z - 0.01])
        rounded_rect(display_cavity_x, display_cavity_y,
                     cavity_height + 0.02, r_cavity);
}

// =============================================================================
// DIMENSION REPORTING
// =============================================================================

// Overall test piece
report_dimensions(outer_x, outer_y, total_z, "test_piece");

// Cavity opening
report_dimensions(display_cavity_x, display_cavity_y, cavity_height, "cavity_opening");
