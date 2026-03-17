// =============================================================================
// cavity-fit — Test print for caliper display body cavity fitment
// =============================================================================
// A 20mm-tall cross-section slab of the caliper-test bin's display body
// cavity. Verifies the 72x20mm pocket accepts the HARTE 6-inch caliper
// display body with ~2mm clearance per side.
//
// Parent design: caliper-test (gridfinity-bins/designs/caliper-test/)

include <gridfinity-spec.scad>
include <bambu-x1c.scad>

$fn = 80;

// =============================================================================
// PARAMETERS — derived from parent caliper-test.scad
// =============================================================================

// Caliper dimensions (from measurements.json)
caliper_clearance = 2.0;  // per side

display_body_width     = 68;   // X
display_body_thickness = 16;   // Y

// Pocket dimensions (caliper + clearance) — match parent exactly
display_cavity_x = display_body_width + 2 * caliper_clearance;      // 72
display_cavity_y = display_body_thickness + 2 * caliper_clearance;   // 20

// Wall and corner from parent bin
wall    = GF_WALL_THICKNESS_THICK;   // 1.2
r_outer = GF_BASE_TOP_RADIUS;       // 3.75

// Outer X matches parent bin: gf_bin_width(2) = 83.5
outer_x = gf_bin_width(2);          // 83.5

// Test piece Y: trimmed to show full cavity depth + walls + small margin
// cavity_y (20) + 2*wall (2.4) + extra margin (~2.6) = 25
test_y = 25.0;

// Test piece Z geometry
base_plate_z  = 2.0;   // solid base replacing Gridfinity base
cavity_height = 20.0;  // height of the cavity section
total_z       = base_plate_z + cavity_height;  // 22

// Corner radius for the outer shell — use parent's r_outer on X corners,
// but cap to half the Y extent so the radius is valid
r_shell = min(r_outer, test_y / 2);  // 3.75

// Inner corner radius
r_inner = max(0.1, r_shell - wall);  // 2.55

// Cavity corner radius — same 2mm as parent pocket
r_cavity = 2.0;

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
    rounded_rect(outer_x, test_y, total_z, r_shell);

    // Cavity: starts at base_plate_z, goes up through the top (open top)
    translate([0, 0, base_plate_z - 0.01])
        rounded_rect(display_cavity_x, display_cavity_y,
                     cavity_height + 0.02, r_cavity);
}

// =============================================================================
// DIMENSION REPORTING
// =============================================================================

// Overall test piece
report_dimensions(outer_x, test_y, total_z, "test_piece");

// Cavity opening
report_dimensions(display_cavity_x, display_cavity_y, cavity_height, "cavity_opening");
