// Printer-Corner-Fit Test Print
// ptouch-cradle / printer-corner-fit
//
// PURPOSE:
//   Verify the cradle's printer-pocket dimensions accommodate the actual
//   PT-P750W's corner geometry before committing to the full ~130 cm³
//   cradle print. Specifically tests:
//     - 1mm/side XY clearance feel (not binding, not loose)
//     - Inside-corner radius accommodates the printer's corner (printers
//       have small corner radii / chamfers — verify they fit without
//       jamming against the cradle's sharp interior corner)
//     - 3mm wall_thickness prints solid
//
// L-SHAPED TEST: two perpendicular walls forming ONE inside corner of
// the printer pocket. Three reference points: the two open ends of the L
// + the inside angle where the legs meet. The printer's corner seats
// against the inside angle. User can verify XY fit on TWO axes
// simultaneously without printing the full pocket.
//
// COORDINATE SYSTEM:
//   X = printer-short axis (PT-P750W is 78mm here)
//   Y = printer-long axis (PT-P750W is 152mm here)
//   Z = vertical
//   Origin at outer corner of the L.
//   Inside-of-L corner is at (wall_t, wall_t).
//
// HOW TO USE:
//   1. Print on Bambu X1C, PLA, standard 0.2mm profile, no supports.
//   2. After printing, place the L on a flat surface (outside-of-corner
//      down). Place the printer's corner against the inside-angle of
//      the L. The printer should:
//         - Slide along EITHER axis with slight consistent resistance
//         - Reveal a uniform ~1mm gap between printer and each L wall
//         - Not bind in the inside-corner (printer's corner radius
//           clears the L's sharp interior corner)
//   3. If fit is right: proceed to full cradle print.
//      If too tight: bump pocket clearance from 1mm to 1.2mm in cradle.scad.
//      If too loose: tighten to 0.8mm.

include <fdm-pla.scad>
include <bambu-x1c.scad>
include <common.scad>

// ===== Render quality (draft defaults — shipper bumps if needed) =====
$fn              = 100;

// ===== Parameters inherited from parent design (ptouch-cradle spec.json) =====

wall_t           = 3.0;    // cradle wall_thickness
wall_h           = 25.0;   // cradle low_wall_h (full cradle wall height)

// ===== Test-piece-specific parameters =====

// Leg lengths — long enough to verify two axes of fit, short enough to be cheap.
// 80mm captures more than half of the printer's short-axis (78mm),
// 100mm captures ~2/3 of the printer's long-axis (152mm).
long_leg_y       = 100;   // along Y (printer's long axis)
short_leg_x      = 80;    // along X (printer's short axis)


// ===================================================================
// L-SHAPED CORNER TEST
//
// Two perpendicular walls forming the inside-corner of the printer pocket.
// No floor — the L is structurally stable at 25mm tall × 3mm thick × 80-100mm
// long, prints flat on the bed via either leg or both legs touching.
// Printer's corner seats against the inside angle for the fit test.
// ===================================================================

module printer_corner_fit() {
    union() {
        // Long leg (along +Y) — the wall the printer's long edge butts against
        cube([wall_t, long_leg_y, wall_h]);

        // Short leg (along +X) — the wall the printer's short edge butts against
        cube([short_leg_x, wall_t, wall_h]);
    }
}

printer_corner_fit();


// ===================================================================
// DIMENSION REPORT
// ===================================================================

report_dimensions(short_leg_x, long_leg_y, wall_h, "printer-corner-fit");
