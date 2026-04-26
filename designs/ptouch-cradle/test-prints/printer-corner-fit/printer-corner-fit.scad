// Printer-Corner-Fit Test Print
// ptouch-cradle / printer-corner-fit
//
// PURPOSE:
//   Verify the cradle's printer-pocket dimensions accommodate the actual
//   PT-P750W's corner geometry before committing to the full ~130 cm³
//   cradle print. Specifically tests:
//     - 1 mm/side XY clearance feel (not binding, not loose) on BOTH
//       inside corners along the long axis + the back-edge short axis
//     - Inside-corner radius accommodates the printer's corner (printers
//       have small corner radii / chamfers — verify they fit without
//       jamming against the cradle's sharp interior corners)
//     - 3 mm wall_thickness prints solid
//
// U-SHAPED TEST: three walls forming the back + both long sides of the
// printer pocket. Three inside corners: two at the back of the pocket,
// plus the full-length engagement along both long-axis walls. Open at
// the front so the printer slides in from the +Y end. Height is halved
// vs the full cradle (12.5 mm vs 25 mm) — the printer's outline is a
// constant cross-section, so a low U validates the pocket profile with
// less filament and ~half the print time.
//
// COORDINATE SYSTEM:
//   X = printer-short axis (PT-P750W is 78 mm; pocket interior 80 mm)
//   Y = printer-long axis  (PT-P750W is 152 mm; pocket interior 154 mm)
//   Z = vertical
//   Origin at outer-back-left corner of the U.
//   Pocket interior occupies x ∈ [wall_t, wall_t + pocket_int_x],
//                              y ∈ [0, pocket_int_y].
//   Closed back wall sits at y ∈ [pocket_int_y, pocket_int_y + wall_t].
//   Open front is at y = 0.
//
// HOW TO USE:
//   1. Print on Bambu X1C, PLA, standard 0.2 mm profile, no supports.
//   2. Place the U on a flat surface (any wall outside-face down — the
//      U is rigid as printed). Slide the printer into the open end (+Y).
//      The printer should:
//         - Bottom-out against the closed back wall with both long edges
//           tracking parallel to the side walls
//         - Reveal a uniform ~1 mm gap between the printer and each
//           side wall along the full 152 mm length
//         - Not bind in either back-corner (printer's corner radii
//           clear the U's sharp interior corners)
//   3. If fit is right: proceed to full cradle print.
//      If too tight: bump pocket clearance from 1 mm to 1.2 mm in cradle.scad.
//      If too loose: tighten to 0.8 mm.

include <fdm-pla.scad>
include <bambu-x1c.scad>
include <common.scad>

// ===== Render quality (draft defaults — shipper bumps if needed) =====
$fn              = 100;

// ===== Parameters inherited from parent design (ptouch-cradle spec.json) =====

wall_t           = 3.0;    // cradle wall_thickness
wall_h           = 12.5;   // half of cradle low_wall_h (25) — pocket profile
                           // is constant over the printer's full Z, so a low
                           // U validates fit with ~half the filament/time.

// ===== Test-piece-specific parameters (mirror parent pocket geometry) =====

pocket_int_x     = 80;     // cradle pocket_w — printer-short axis interior
pocket_int_y     = 154;    // cradle pocket_d — printer-long axis interior


// ===================================================================
// U-SHAPED POCKET TEST
//
// Three walls (closed back + both long sides) reproducing the full
// printer-pocket footprint at half height. Open at the front so the
// printer slides in from +Y. No floor — the U is structurally stable
// printed on its side walls; the printer rests on the desk during fit.
// ===================================================================

module printer_corner_fit() {
    union() {
        // Closed back wall (the −Y end becomes the back when the printer
        // slides in from +Y open face) — spans full outer X.
        translate([0, pocket_int_y, 0])
            cube([wall_t * 2 + pocket_int_x, wall_t, wall_h]);

        // Left long side wall — runs full pocket length along Y.
        cube([wall_t, pocket_int_y, wall_h]);

        // Right long side wall — runs full pocket length along Y.
        translate([wall_t + pocket_int_x, 0, 0])
            cube([wall_t, pocket_int_y, wall_h]);
    }
}

printer_corner_fit();


// ===================================================================
// DIMENSION REPORT
// ===================================================================

outer_x = wall_t * 2 + pocket_int_x;
outer_y = pocket_int_y + wall_t;
report_dimensions(outer_x, outer_y, wall_h, "printer-corner-fit");
