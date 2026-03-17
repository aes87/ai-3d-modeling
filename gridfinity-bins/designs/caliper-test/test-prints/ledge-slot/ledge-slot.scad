// =============================================================================
// Ledge-Slot Test Print — Cross-section of caliper bin transition zone
// =============================================================================
// Captures z=62.2 to z=84.0 of the parent caliper-test bin:
//   - Finger relief 45-degree chamfer (10mm tall, from z=62.2 to z=72.2)
//   - Transition ledge at z=72.2 (where display cavity narrows to beam slot)
//   - Beam slot (20x9mm, from z=72.2 to z=84.0)
// Plus a 3mm solid base plate for stable printing.
//
// Print orientation: flat on the 3mm base plate. No supports needed.

include <gridfinity-spec.scad>
include <bambu-x1c.scad>

$fn = 80;

// =============================================================================
// PARAMETERS (from parent caliper-test.scad)
// =============================================================================

// Grid sizing (parent bin is 2x1)
outer_x = gf_bin_width(2);             // 83.5
outer_y = gf_bin_width(1);             // 41.5
wall = GF_WALL_THICKNESS_THICK;        // 1.2
inner_x = outer_x - 2 * wall;          // 81.1
inner_y = outer_y - 2 * wall;          // 39.1
floor_z = GF_INTERNAL_FLOOR_ELEV;      // 7.2

// Caliper clearance
caliper_clearance = 2.0;

// Display body cavity
display_body_width = 68;
display_body_thickness = 16;
display_body_length = 63;

display_cavity_x = display_body_width + 2 * caliper_clearance;      // 72
display_cavity_y = display_body_thickness + 2 * caliper_clearance;   // 20
display_cavity_z = display_body_length + caliper_clearance;          // 65

// Beam slot
beam_width = 16;
beam_thickness = 5;

beam_slot_x = beam_width + 2 * caliper_clearance;      // 20
beam_slot_y = beam_thickness + 2 * caliper_clearance;   // 9
beam_slot_z = 11.8;  // from parent: usable_depth - display_cavity_z
beam_slot_y_offset = (display_body_thickness - beam_thickness) / 2;  // 5.5

// Finger relief
finger_relief_height = 10;
finger_relief_setback = 10;

// Capped relief dimensions (same as parent)
relief_x = min(display_cavity_x + 2 * finger_relief_setback, inner_x);  // 81.1
relief_y = min(display_cavity_y + 2 * finger_relief_setback, inner_y);  // 39.1

// =============================================================================
// TEST PIECE PARAMETERS
// =============================================================================

section_z_start = 62.2;   // bottom of finger relief chamfer
section_z_end   = 84.0;   // top of bin body
section_height  = section_z_end - section_z_start;  // 21.8

base_plate_z = 3.0;       // solid base for stable printing
test_y = 25.0;            // trimmed Y extent
test_z = base_plate_z + section_height;  // 24.8

// Corner radius for display cavity
r_cavity = 2.0;
r_relief = 3.0;
r_beam = 1.0;

// Key parent-space Z coordinates
ledge_z = floor_z + display_cavity_z;  // 72.2
chamfer_bottom_z = ledge_z - finger_relief_height;  // 62.2

// Offset to map parent Z to test piece Z
z_offset = base_plate_z - section_z_start;  // 3.0 - 62.2 = -59.2

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
// TEST PIECE
// =============================================================================
// Build a solid block at test piece dimensions, then subtract the pocket
// geometry. The pocket consists of:
//   1. Display cavity cross-section at the base (72x20mm) — visible on bottom
//   2. Finger relief chamfer widening from 72x20 to 81.1x39.1 over 10mm
//   3. Beam slot (20x9mm) from the ledge to the top
// The transition ledge is the solid material between the wide relief opening
// and the narrow beam slot.

difference() {
    // Outer solid block — full X width, trimmed Y, test piece height
    translate([0, 0, test_z / 2])
        cube([outer_x, test_y, test_z], center=true);

    // All pocket cuts, translated from parent Z to test piece Z
    translate([0, 0, z_offset]) {

        // A. Display body cavity from section start to chamfer bottom
        //    This is the constant-width cavity visible at the base face
        translate([0, 0, section_z_start - 0.01])
            rounded_rect(display_cavity_x, display_cavity_y,
                         chamfer_bottom_z - section_z_start + 0.02, r_cavity);

        // B. Finger relief chamfer (parent z=62.2 to z=72.2)
        //    Hull from cavity size at bottom to relief size at top
        hull() {
            translate([0, 0, chamfer_bottom_z])
                rounded_rect(display_cavity_x, display_cavity_y, 0.01, r_cavity);
            translate([0, 0, ledge_z])
                rounded_rect(relief_x, relief_y, 0.01, r_relief);
        }

        // C. Beam slot from ledge to top (parent z=72.2 to z=84.0)
        //    Offset in +Y matching parent design
        translate([0, beam_slot_y_offset, ledge_z - 0.01])
            rounded_rect(beam_slot_x, beam_slot_y,
                         beam_slot_z + 0.02, r_beam);
    }
}

// =============================================================================
// DIMENSION REPORTING
// =============================================================================

report_dimensions(outer_x, test_y, test_z, "test_piece");
report_dimensions(beam_slot_x, beam_slot_y, beam_slot_z, "beam_slot");
