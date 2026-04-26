// Tray-Slot Fit-Pair Test Print
// ptouch-cradle / tray-slot-fit-pair
//
// PURPOSE:
//   Verify the 0.35 mm per-side sliding fit between the tray exterior
//   (103.2 × 94.2 mm) and the cradle slot (103.9 × 94.9 mm) before
//   committing to the full ~150 cm³ two-part print.
//
// TWO PIECES — print both in one run, on the same bed plate:
//
//   (A) MINI CRADLE SLOT — a short Y-slice of the cradle's tray slot,
//       exposed as a U-channel:
//         • Slot interior 103.9 mm W × 22.3 mm deep
//         • Slot walls   3.05 mm thick each side (matches cradle wall_thickness)
//         • Back wall    3.0 mm (closes the U; acts as the cradle's back-wall stub)
//         • Height       25 mm (full cradle wall height, printed base-down)
//         • Y-depth      25 mm interior (enough to exercise the full engagement depth)
//         • Base plate   4 mm thick at z=0 (same as cradle base_thickness)
//         • Open at the front (+Y) so the tray section slides in from the front
//         • Top is OPEN (same open-top slot as the full cradle)
//
//   (B) MINI TRAY SECTION — a short Y-slice of the tray exterior bounding box:
//         • Exterior     103.2 mm W × 30 mm H
//         • Y-depth      25 mm (solid slug — no interior, no ramp, no front lip)
//         • Printed with z=0 on bed, same orientation as the real tray
//         • Includes the r=3 vertical edge fillets (same fillet_vert_r as real tray)
//
// HOW TO USE:
//   1. Print both pieces in one bed run (no supports required).
//   2. After printing, slide the mini tray section into the mini cradle slot
//      from the front (+Y opening). It should slide in and out smoothly.
//   3. Check for:
//      - Smooth insertion with slight consistent resistance → PASS
//      - Loose rattle on all sides → printer running wide; adjust XY compensation
//      - Cannot insert or requires force → printer running narrow; adjust XY comp
//   4. If PASS, proceed to full print. If FAIL, adjust FDM dimensional accuracy
//      (Bambu Studio: Process → Advanced → XY hole/contour compensation).
//
// LAYOUT:
//   Piece A (mini cradle slot) at X=0, Y=0.
//   Piece B (mini tray section) at X = slot_total_w + 10 mm gap.
//   Combined bed footprint ≈ 223 × 28 × 30 mm.

include <fdm-pla.scad>
include <bambu-x1c.scad>
include <common.scad>

// ===== Render quality (draft defaults — shipper bumps if needed) =====
$fn              = 100;

// ===== Parameters inherited from parent design (ptouch-cradle spec.json) =====

// Cradle slot dimensions
slot_w           = 103.9;   // tray_slot_interior_w
slot_h           = 22.3;    // tray_slot_interior_h (engagement depth)
cradle_wall_t    = 3.05;    // slot_wall_thickness_each_side
cradle_base_t    = 4.0;     // base_thickness
cradle_wall_h    = 25.0;    // low_wall_h (total cradle wall height)

// Tray exterior dimensions
tray_ext_w       = 103.2;   // tray_exterior_w
tray_ext_h       = 30.0;    // tray_exterior_h
tray_fillet_r    = 3.0;     // vertical edge fillet (fillet_vert_r in tray.scad)

// Test-piece Y depth — short enough to be fast, long enough to confirm fit feel
test_y_depth     = 25.0;

// Gap between the two pieces on the bed
bed_gap          = 10.0;

// U-channel outer width: slot + two side walls
slot_total_w     = slot_w + 2 * cradle_wall_t;   // 103.9 + 6.1 = 110.0 mm


// ===================================================================
// PIECE A — MINI CRADLE SLOT (U-channel)
//
// Two side walls + a back wall + a base plate.
// Open at the front (+Y face) and open at the top (z = cradle_wall_h).
// Printed base-down (z=0 on bed, same orientation as the real cradle).
//
// Coordinate origin: X=0 at outer left face, Y=0 at back outer face, Z=0 at bed.
// ===================================================================

module mini_cradle_slot() {
    back_wall_t = 3.0;   // match cradle wall_thickness

    outer_w = slot_total_w;               // 110.0 mm
    outer_d = test_y_depth + back_wall_t; // 25 + 3 = 28 mm
    outer_h = cradle_wall_h;              // 25 mm

    difference() {
        // Solid outer envelope
        cube([outer_w, outer_d, outer_h]);

        // Slot cavity:
        //   X: cradle_wall_t in from each side → 3.05 mm side walls remain
        //   Y: starts at back_wall_t → 3 mm back wall remains; extends to open front
        //   Z: starts at cradle_base_t → 4 mm base plate remains; extends above top
        translate([cradle_wall_t,
                   back_wall_t,
                   cradle_base_t - 0.01])
            cube([slot_w,
                  test_y_depth + 0.02,   // +slop so cutter clears the front face
                  slot_h + 1]);          // +1 so cutter exits the top
    }
}


// ===================================================================
// PIECE B — MINI TRAY SECTION (solid slug)
//
// Exterior cross-section of the tray (103.2 mm W × 30 mm H) extruded
// test_y_depth mm in Y. r=3 vertical corner fillets match the real tray.
// Solid throughout — no interior, no ramp, no front lip.
// Printed with z=0 on bed (same orientation as the real tray).
//
// Coordinate origin: X=0 at outer left face, Y=0 at back face, Z=0 at bed.
// ===================================================================

module mini_tray_section() {
    linear_extrude(height = tray_ext_h)
        // Same rounded-rect pattern as tray.scad rounded_rect() module.
        translate([tray_fillet_r, tray_fillet_r])
            offset(r = tray_fillet_r)
                square([tray_ext_w - 2 * tray_fillet_r,
                        test_y_depth - 2 * tray_fillet_r]);
}


// ===================================================================
// BED LAYOUT
// ===================================================================

// Piece A — mini cradle slot at origin
mini_cradle_slot();

// Piece B — mini tray section shifted right
translate([slot_total_w + bed_gap, 0, 0])
    mini_tray_section();


// ===================================================================
// DIMENSION REPORTS
// ===================================================================

back_wall_t_local = 3.0;
slot_outer_d      = test_y_depth + back_wall_t_local;   // 28.0

report_dimensions(slot_total_w, slot_outer_d, cradle_wall_h,  "mini_cradle_slot");
report_dimensions(tray_ext_w,   test_y_depth, tray_ext_h,     "mini_tray_section");

combined_w = slot_total_w + bed_gap + tray_ext_w;   // 223.2
report_dimensions(combined_w,
                  max(slot_outer_d, test_y_depth),
                  max(cradle_wall_h, tray_ext_h),
                  "combined_bed_footprint");
