// =============================================================================
// Ledge-Slot Test Print v2 — L-shaped pocket transition zone
// =============================================================================
// Captures z=62.2 to z=84.0 of the parent caliper-test v2 bin:
//   - Display body cavity cross-section (70x18mm) from z=62.2 to z=71.2
//   - Transition ledge at z=71.2 (where cavity narrows to beam slot)
//   - Beam slot (18x7mm) at min-X, min-Y corner, from z=71.2 to z=84.0
// Plus a 3mm solid base plate for stable printing.
//
// v2 changes from v1:
//   - Tighter pocket (1mm clearance/side, down from 2mm)
//   - L-shaped pocket (beam slot at corner, not centered)
//   - No finger relief chamfer (removed in v2)
//
// Print orientation: flat on the 3mm base plate. No supports needed.

include <gridfinity-spec.scad>
include <bambu-x1c.scad>

$fn = 80;

// =============================================================================
// PARAMETERS (from parent caliper-test v2)
// =============================================================================

// Grid sizing (parent bin is 2x1)
outer_x = gf_bin_width(2);             // 83.5
outer_y = gf_bin_width(1);             // 41.5
wall = GF_WALL_THICKNESS_THICK;        // 1.2
inner_x = outer_x - 2 * wall;          // 81.1
inner_y = outer_y - 2 * wall;          // 39.1
floor_z = GF_INTERNAL_FLOOR_ELEV;      // 7.2

// Caliper clearance (v2: tighter 1mm/side)
caliper_clearance = 1.0;

// Display body cavity
display_body_width = 68;
display_body_thickness = 16;
display_body_length = 63;

display_cavity_x = display_body_width + 2 * caliper_clearance;      // 70
display_cavity_y = display_body_thickness + 2 * caliper_clearance;   // 18
display_cavity_z = display_body_length + caliper_clearance;          // 64

// Beam slot
beam_width = 16;
beam_thickness = 5;

beam_slot_x = beam_width + 2 * caliper_clearance;       // 18
beam_slot_y = beam_thickness + 2 * caliper_clearance;    // 7
beam_slot_z = 12.8;  // usable_depth - display_cavity_z = 76.8 - 64

// =============================================================================
// TEST PIECE PARAMETERS
// =============================================================================

section_z_start = 62.2;   // 9mm below ledge (shows display cavity cross-section)
section_z_end   = 84.0;   // top of bin body
section_height  = section_z_end - section_z_start;  // 21.8

base_plate_z = 3.0;       // solid base for stable printing
test_z = base_plate_z + section_height;  // 24.8

// Key parent-space Z coordinates
ledge_z = floor_z + display_cavity_z;  // 71.2

// Offset to map parent Z to test piece Z
z_offset = base_plate_z - section_z_start;  // 3.0 - 62.2 = -59.2

// Display cavity center in parent bin (centered in bin XY footprint)
dc_half_x = display_cavity_x / 2;  // 35
dc_half_y = display_cavity_y / 2;  // 9

// Beam slot at min-X, min-Y corner of display cavity
bs_min_x = -dc_half_x;             // -35
bs_min_y = -dc_half_y;             // -9

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
//   1. Display cavity cross-section (70x18mm) — visible on bottom face
//   2. Beam slot (18x7mm) at min-X, min-Y corner from ledge to top
// The transition ledge is the solid material surrounding the beam slot
// at the height where the display cavity ends.
//
// L-shaped pocket cross-section (looking down):
//
//   Y
//   ^
//  18 +--------------------------------------------+
//     |          display body cavity                |
//     |          (70mm x 18mm)                      |
//   7 +--------+                                    |
//     |  beam  |                                    |
//     |  slot  |                                    |
//   0 +--------+------------------------------------+
//     0       18                                   70  -> X

difference() {
    // Outer solid block — full bin X and Y width, test piece height
    translate([0, 0, test_z / 2])
        cube([outer_x, outer_y, test_z], center=true);

    // All pocket cuts, translated from parent Z to test piece Z
    translate([0, 0, z_offset]) {

        // A. Display body cavity from section start to ledge
        //    Rectangular cut, centered at bin origin
        translate([
            -dc_half_x,
            -dc_half_y,
            section_z_start - 0.01
        ])
            cube([
                display_cavity_x,
                display_cavity_y,
                ledge_z - section_z_start + 0.02
            ]);

        // B. Beam slot from ledge to top (parent z=71.2 to z=84.0)
        //    At min-X, min-Y corner of display cavity
        translate([
            bs_min_x,
            bs_min_y,
            ledge_z - 0.01
        ])
            cube([
                beam_slot_x,
                beam_slot_y,
                beam_slot_z + 0.02
            ]);
    }
}

// =============================================================================
// DIMENSION REPORTING
// =============================================================================

report_dimensions(outer_x, outer_y, test_z, "test_piece");
report_dimensions(display_cavity_x, display_cavity_y, ledge_z - section_z_start, "display_cavity_section");
report_dimensions(beam_slot_x, beam_slot_y, beam_slot_z, "beam_slot");
