// Printer-Corner-Fit Test Print
// ptouch-cradle / printer-corner-fit
//
// PURPOSE:
//   Verify the cradle's printer-pocket dimensions accommodate the actual
//   PT-P750W's corner geometry before committing to the full ~130 cm³
//   cradle print. Specifically tests:
//     - 1 mm/side XY clearance feel (not binding, not loose)
//     - X interior dimension (80 mm) — verified by the back wall +
//       opposite-end stubs constraining the printer at both back and
//       front edges
//     - Y interior dimension (154 mm) — verified by the full right
//       wall + the back wall + the front-right stub
//     - Inside-corner radius accommodates the printer's corner radii /
//       chamfers (verified at 3 of 4 corners; the fourth corner shares
//       identical geometry so it's covered by transitive geometry)
//     - 3 mm wall_thickness prints solid
//
// SHAPE: TWO FULL SIDES + STUBS FORMING THREE INSIDE CORNERS.
//   Full sides: back (short, +Y end) + right (long, +X side).
//   Stubs:      a left-long-wall stub at the back end (forms the
//               back-left corner with the back wall); a front-short-wall
//               stub at the right end (forms the front-right corner
//               with the right wall).
//   Three inside corners total: back-left, back-right, front-right.
//   Front-left corner is the only one not present — the printer's
//   front-left edge sits in open air during the fit test.
//
//   Key dimensions captured:
//     - X (pocket interior 80 mm): pinned by the back wall on the
//       back edge AND by both side walls (full right + left stub) on
//       the back portion of the pocket.
//     - Y (pocket interior 154 mm): pinned by the full right wall
//       (front edge to back edge) plus the back wall closing it.
//     - Both back corners + front-right corner: 3 of 4 inside corners
//       for printer's corners to seat against.
//
// COORDINATE SYSTEM:
//   X = printer-short axis (PT-P750W is 78 mm; pocket interior 80 mm)
//   Y = printer-long axis  (PT-P750W is 152 mm; pocket interior 154 mm)
//   Z = vertical
//   Origin at outer-front-left corner.
//   Pocket interior occupies x ∈ [wall_t, wall_t + pocket_int_x],
//                              y ∈ [0, pocket_int_y].
//   Back wall sits at y ∈ [pocket_int_y, pocket_int_y + wall_t].
//   Front edge is at y = 0 (open at the front-left corner only).
//
// HOW TO USE:
//   1. Print on Bambu X1C, PLA, standard 0.2 mm profile, no supports.
//   2. Place the piece on a flat surface (any wall outside-face down —
//      it's rigid as printed). Slide the printer into the pocket from
//      the +Y direction; the printer should bottom out against the back
//      wall with its right edge tracking parallel to the right wall.
//      The printer should:
//         - Have ~1 mm uniform gap to the right wall along the full
//           152 mm engagement
//         - Have ~1 mm uniform gap to the left stub at the back
//         - Have ~1 mm uniform gap to the front stub at the right
//         - Bottom out against the back wall along its full 78 mm width
//         - Not bind in any of the 3 inside corners (back-left,
//           back-right, front-right)
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
                           // piece validates fit with ~half the print time.

// ===== Test-piece-specific parameters =====

pocket_int_x     = 80;     // cradle pocket_w — printer-short axis interior
pocket_int_y     = 154;    // cradle pocket_d — printer-long axis interior

// Stub length — enough to form a clean inside corner that the printer's
// corner radius can seat against. 25 mm is well past any plausible printer
// corner radius (typically 2–5 mm) while keeping the stubs cheap.
stub_len         = 25;


// ===================================================================
// FRAME WITH ONE OPEN CORNER
//
// Full back + full right wall + two stubs forming back-left and
// front-right inside corners. Validates X (pocket width) and Y
// (pocket depth) dimensions plus 3 of 4 corner geometries.
// ===================================================================

module printer_corner_fit() {
    union() {
        // Full back wall — spans the whole outer X at the +Y end.
        translate([0, pocket_int_y, 0])
            cube([wall_t * 2 + pocket_int_x, wall_t, wall_h]);

        // Full right long wall — runs the full pocket length plus the
        // back-wall thickness so it joins the back at the back-right corner.
        translate([wall_t + pocket_int_x, 0, 0])
            cube([wall_t, pocket_int_y + wall_t, wall_h]);

        // Left stub on the long wall — meets the back wall to form
        // the back-left inside corner. Length includes wall_t overlap
        // with the back wall to guarantee a solid union.
        translate([0, pocket_int_y - stub_len, 0])
            cube([wall_t, stub_len + wall_t, wall_h]);

        // Front stub on the short wall — meets the right wall to form
        // the front-right inside corner. Length includes wall_t overlap
        // with the right wall.
        translate([pocket_int_x + wall_t - stub_len, 0, 0])
            cube([stub_len + wall_t, wall_t, wall_h]);
    }
}

printer_corner_fit();


// ===================================================================
// DIMENSION REPORT
// ===================================================================

outer_x = wall_t * 2 + pocket_int_x;
outer_y = pocket_int_y + wall_t;
report_dimensions(outer_x, outer_y, wall_h, "printer-corner-fit");
