// P-touch Cradle — Brother PT-P750W (round 3 / v3 minimalism)
//
// ROUND-3 SCOPE (this file):
//   The owl direction is abandoned. This is a quiet desk dock — function
//   and frame, nothing more. Most of round 1 + round 2's face / tuft /
//   panel geometry is deleted. The tall back panel collapses to a 25 mm
//   low wall identical to the other three perimeter walls. The fillet
//   schedule collapses to two tiers (r=3 utility, r=10 hero) plus the
//   r=1.5 foot-to-plate exception. No decoration of any kind.
//
// What survives from round 2:
//   - Stepped body footprint (86 mm printer section → 108 mm shelf).
//   - Printer pocket (80 × 154 mm interior, 1 mm XY clearance).
//   - Cable notch (25 × 20 mm) on the -Y back wall — now leaves a 5 mm
//     bridge above (between notch top z=20 and wall top z=25).
//   - Tray slot pocket (103.9 × 94.9 × ~21 mm, sliding fit 0.35 mm/side).
//   - Four cylindrical feet (d=8, h=3) with r=1.5 upper blend.
//   - host_object_proxy() module + render_with_host parameter for
//     use-state renders. STL export keeps render_with_host=false.
//
// What is gone in round 3:
//   - Tall back panel (height 205 mm) — replaced by a 25 mm low wall.
//   - Heart-shaped facial disc, recessed eye sockets, asymmetric beak.
//   - Ear tufts (any construction).
//   - Convex panel face, panel arc, vertical-edge softening.
//   - Every face_*, eye_*, beak_*, tuft_*, back_panel_*, panel_* param.
//
// User orientation (unchanged):
//   +Y = user-front (tray slides out this way; printer faces user)
//   -Y = user-back  (against-wall; cable notch lives here)
//   +X = user-right
//   -X = user-left
//   +Z = up
//
// Print-frame coordinates:
//   Origin at the back-left corner of the SHELF footprint (the widest
//   part of the cradle). +X = right, +Y = forward (toward user), +Z = up.
//   Back exterior at Y=0, front of cradle at Y = cradle_total_d.
//   The printer section is inset on both sides by 11 mm (X = 11..97).
//
// Print orientation:
//   Base down, walls vertical. No supports needed at any feature.

include <fdm-pla.scad>
include <bambu-x1c.scad>
include <common.scad>

$fn = 80;

// ===== Top-level toggles =====
//
// render_with_host: if true, host_object_proxy() draws the installed
// printer box for use-state renders. STL export MUST keep this false.
// Use-state PNG renders override via `--param render_with_host=true`.
render_with_host = false;

// ===== Parameters =====

// Overall footprint
cradle_w_shelf       = 108;     // X, shelf (wide) section body width
cradle_w_printer     = 86;      // X, printer (narrow) section body width
side_step            = (cradle_w_shelf - cradle_w_printer) / 2;  // 11 mm
cradle_total_d       = 254.9;   // Y, overall cradle depth
base_thickness       = 4.0;     // base plate thickness
wall_thickness       = 3.0;     // perimeter wall thickness

// Printer section
pocket_w             = 80;      // X interior pocket
pocket_d             = 154;     // Y interior pocket
printer_section_d    = 160;     // Y (3 + 154 + 3)

// Hero dim — the wall height defines the form
low_wall_h           = 25;

// Concave fillet at printer-section → shelf transition
// Hero radius. Capped by the side_step (11 mm) since the fillet must
// fit within the 11 mm Y-delta between the printer and shelf footprints.
transition_fillet_r  = 10;

// Cable slot (on -Y wall). Bridge above is wall_h - cable_slot_h = 5 mm.
cable_slot_w         = 25;
cable_slot_h         = 20;
cable_slot_cx        = cradle_w_shelf / 2;  // 54 mm

// Feet
foot_d               = 8;
foot_h               = 3;
// foot_inset must accommodate (foot_d/2 + foot_blend_r) so the upper flare
// stays inside the base plate footprint. Also kept clear of the r=10 hero
// base-plate corner fillet so the foot does not crown the rounded corner.
foot_inset           = 12;
foot_blend_r         = 1.5;     // foot-to-plate concave fillet (function-driven exception)

// Tray slot pocket dims (matches tray exterior 103.2 × 94.2 × 21.6 with
// 0.35 mm sliding fit per side)
slot_w               = 103.9;
slot_d               = 94.9;
slot_h               = 22.3;
tray_section_d       = 94.9;
tray_section_y0      = 160;     // back of tray slot = front of printer section

// Fillet schedule — TWO tiers + one exception
fillet_utility_r     = 3.0;     // r=3 break-edges, top edges, tray edges
fillet_hero_r        = 10.0;    // r=10 cradle exterior corners, base plate
                                 // corners, printer→shelf concave

// Derived totals (echoed for validation)
cradle_total_h       = low_wall_h + 3;   // ~28 mm includes top-edge fillet
                                          // headroom (mesh ≤ 28 mm above
                                          // bed datum). Feet extend to
                                          // z = -3 below the datum.

// ===== Structural asserts =====
assert(wall_thickness >= MIN_WALL,    str("Wall thickness ", wall_thickness, " below min ", MIN_WALL));
assert(base_thickness >= MIN_FLOOR_CEIL, str("Base ", base_thickness, " below min floor"));
assert(cradle_total_d <= 256, str("Cradle depth exceeds bed: ", cradle_total_d));
assert(cradle_w_shelf <= 256, "Cradle width exceeds bed");
assert(side_step > 0, "Step must be positive");
assert(transition_fillet_r <= side_step + 0.01,
       "Transition fillet larger than side step");
assert((cradle_w_printer - pocket_w)/2 >= wall_thickness - 0.01,
       "Printer section side walls below 3mm");
assert(cable_slot_h < low_wall_h, "Cable slot must leave a wall bridge above");
assert(low_wall_h - cable_slot_h >= 4,
       str("Bridge above cable notch (", low_wall_h - cable_slot_h, "mm) below 4mm minimum"));

// ===== 2D footprint =====
//
// Stepped footprint: the back of the cradle is the narrower printer
// section (X = 11..97, Y = 0..160), the front is the wider shelf (X =
// 0..108, Y = 160..254.9). The transition between the two has a concave
// quarter-arc on each side (r = transition_fillet_r) sweeping from the
// inner printer-section wall outward to the shelf wall.

// Stepped exterior with a concave quarter-arc filling the inside corner
// at the printer→shelf step. Geometry per side:
//
//   Right side (right exterior corner of printer section meets right
//   exterior of shelf):
//     - Printer right wall: vertical line at x = printer_x_right
//                           (= side_step + cradle_w_printer = 97).
//     - Shelf right wall:   vertical line at x = cradle_w_shelf = 108.
//     - At y = printer_section_d (= 160), an inset corner exists where
//       these two walls would meet via a horizontal step.
//     - The CONCAVE fillet rounds away the inside corner at
//       (printer_x_right, printer_section_d) by a quarter-arc of radius
//       transition_fillet_r. Tangent points:
//         T_vert = (printer_x_right,            printer_section_d - r)
//         T_horiz = (printer_x_right + r,       printer_section_d)
//       Arc center = (printer_x_right + r, printer_section_d - r),
//       radius r, sweeping from angle 180° (T_vert) to 90° (T_horiz).
//     - From T_horiz a short straight horizontal edge runs to the shelf
//       wall at (cradle_w_shelf, printer_section_d). The length of that
//       segment is (cradle_w_shelf - (printer_x_right + r)) = 1 mm
//       given side_step=11 and r=10. The hero corner offset will
//       absorb this 1 mm sliver.
//
//   Left side: mirror image. Tangent points:
//     T_vert  = (side_step,            printer_section_d - r)
//     T_horiz = (side_step - r,        printer_section_d)
//   Arc center = (side_step - r, printer_section_d - r), sweeping
//   from angle 0° (T_vert) to 90° (T_horiz).

module stepped_footprint_raw() {
    N = 32;
    r = transition_fillet_r;
    printer_x_right = side_step + cradle_w_printer;     // 97
    printer_x_left  = side_step;                         // 11

    right_cx = printer_x_right + r;       // 107
    right_cy = printer_section_d - r;     // 150
    left_cx  = printer_x_left - r;        //   1
    left_cy  = printer_section_d - r;     // 150

    // Right concave arc: 180° → 90°
    right_arc = [for (i = [0 : N])
        let(a = 180 - 90 * i / N)
        [right_cx + r * cos(a), right_cy + r * sin(a)]
    ];

    // Left concave arc: 0° → 90° (but we'll walk in reverse, 90° → 0°,
    // when laying out the polygon perimeter)
    left_arc = [for (i = [0 : N])
        let(a = 90 - 90 * i / N)   // reversed sweep: 90° down to 0°
        [left_cx + r * cos(a), left_cy + r * sin(a)]
    ];

    points = concat(
        [[printer_x_left,    0]],                          // BL printer
        [[printer_x_right,   0]],                          // BR printer
        [[printer_x_right,   printer_section_d - r]],      // start of right arc (T_vert_R)
        right_arc,                                         // arc 180° → 90°: ends at (right_cx, printer_section_d) = (107, 160)
        [[cradle_w_shelf,    printer_section_d]],          // shelf NE corner (108, 160)
        [[cradle_w_shelf,    cradle_total_d]],             // shelf FR corner
        [[0,                 cradle_total_d]],             // shelf FL corner
        [[0,                 printer_section_d]],          // shelf NW corner (0, 160)
        left_arc,                                          // arc 90° → 0°: starts at (left_cx, printer_section_d) = (1, 160), ends at (printer_x_left, printer_section_d - r) = (11, 150)
        [[printer_x_left,    printer_section_d - r]],      // T_vert_L (closes left side)
        [[printer_x_left,    0]]                           // close back to BL
    );
    polygon(points = points);
}

// Base footprint — apply the hero corner radius to the four exterior
// corners of the stepped footprint (top and bottom plate corners both).
module base_footprint() {
    offset(r =  fillet_hero_r)
        offset(r = -fillet_hero_r)
            stepped_footprint_raw();
}

// Wall footprint — same hero radius at the corners. Walls and base share
// the same exterior outline so the cradle reads as a continuous solid.
module wall_footprint() {
    offset(r =  fillet_hero_r)
        offset(r = -fillet_hero_r)
            stepped_footprint_raw();
}

// ===== Base plate =====

module base_plate() {
    linear_extrude(height = base_thickness)
        base_footprint();
}

// ===== Corner feet with r=1.5 upper blend =====
module corner_feet() {
    positions = [
        [side_step + foot_inset,                    foot_inset                 ],
        [side_step + cradle_w_printer - foot_inset, foot_inset                 ],
        [foot_inset,                                cradle_total_d - foot_inset],
        [cradle_w_shelf - foot_inset,               cradle_total_d - foot_inset],
    ];
    for (p = positions) {
        translate([p[0], p[1], 0]) {
            // Cylindrical foot below z=0
            translate([0, 0, -foot_h])
                cylinder(h = foot_h, d = foot_d, $fn = 48);
            // Upper blend: small flare cone connecting the foot to the
            // base plate. Flat foot bottom is preserved for FDM first-
            // layer adhesion.
            translate([0, 0, -foot_blend_r])
                cylinder(h = foot_blend_r,
                         d1 = foot_d,
                         d2 = foot_d + 2 * foot_blend_r,
                         $fn = 48);
        }
    }
}

// ===== Low perimeter wall block (25 mm tall stepped ring) =====
//
// The wall block extrudes the wall footprint to z = low_wall_h, with a
// utility r=3 fillet rolled onto the top edge (the outermost top edge,
// running around the entire perimeter).
//
// Implementation: extrude to (low_wall_h - r), then stack thin discs
// in z that progressively inset (using offset(r = -inset)) following a
// quarter-circle profile. Each inset = r * (1 - cos(angle)). The hero
// vertical-corner fillet is delivered by the wall_footprint offset; the
// utility top fillet is delivered by this stack.

module low_wall_block_solid() {
    r = fillet_utility_r;     // top-edge utility fillet
    // Main solid extrusion stops `r` below the wall top.
    linear_extrude(height = low_wall_h - r)
        wall_footprint();
    // Quarter-arc profile rolled onto the top edge.
    steps = 8;
    for (i = [0 : steps - 1]) {
        a0 = 90 * i       / steps;
        a1 = 90 * (i + 1) / steps;
        inset1 = r * (1 - cos(a1));
        z0 = (low_wall_h - r) + r * sin(a0);
        z1 = (low_wall_h - r) + r * sin(a1);
        translate([0, 0, z0])
            linear_extrude(height = z1 - z0 + 0.001)
                offset(r = -inset1)
                    wall_footprint();
    }
}

// Wall block carved by the printer pocket and the tray slot. The pocket
// extends the full wall height (z=0..low_wall_h) since we want a clean
// rectangular cavity for the printer to drop into; the pocket bottom is
// the base plate (carved from z = base_thickness up).
module low_wall_block() {
    difference() {
        low_wall_block_solid();

        // Printer pocket — interior cavity for the printer body. Goes
        // FROM the base plate top up through the wall top (z=4..25).
        pocket_x0 = side_step + (cradle_w_printer - pocket_w) / 2;  // 14
        pocket_y0 = wall_thickness;                                  // 3
        translate([pocket_x0, pocket_y0, base_thickness - 0.01])
            cube([pocket_w, pocket_d, low_wall_h + 1]);

        // Tray slot — interior cavity for the tray. Open top, open front
        // (the +Y face of the slot is past the cradle's +Y wall, so the
        // tray slides out from the front).
        slot_x0 = (cradle_w_shelf - slot_w) / 2;                     // 2.05
        translate([slot_x0, tray_section_y0 - 0.01, base_thickness - 0.01])
            cube([slot_w, tray_section_d + 0.02, low_wall_h + 10]);
    }
}

// ===== Cable notch (subtractive) =====
//
// U-cut on the -Y back wall. Spans z = 0..cable_slot_h (0..20). Bridge
// above the notch is (low_wall_h - cable_slot_h) = 5 mm tall × 25 mm
// wide. 25 mm bridge span is well within FDM bridging tolerance for PLA;
// the bridge prints across the side walls of the notch, supported on
// both ends.

module cable_slot_cutter() {
    translate([cable_slot_cx - cable_slot_w / 2, -0.1, -0.01])
        cube([cable_slot_w, wall_thickness + 0.2, cable_slot_h]);
}

// ===== Host-object proxy (round 2 NEW — for use-state renders) =====
//
// Renders a 78×152×143 box at the printer's installed position.
// Excluded from STL by default (render_with_host = false); enable for
// PNG renders that show the printer in place via
// `--param render_with_host=true`.
//
// Installed position math:
//   pocket interior origin (X) = side_step + (cradle_w_printer - pocket_w)/2 = 14
//   pocket interior origin (Y) = wall_thickness = 3
//   pocket floor                = base_thickness = 4
//   printer is centered in the 80×154 pocket with 1 mm XY clearance per side
//   → printer X origin = 14 + 1 = 15
//     printer Y origin =  3 + 1 = 4
//     printer Z origin =  4

module host_object_proxy(show = false) {
    if (show) {
        printer_w = 78;
        printer_d = 152;
        printer_h = 143;
        clr_xy    = 1;
        pocket_x0 = side_step + (cradle_w_printer - pocket_w) / 2;
        pocket_y0 = wall_thickness;
        x0 = pocket_x0 + clr_xy;
        y0 = pocket_y0 + clr_xy;
        z0 = base_thickness;
        // Use color() (not %) — `--render` mode omits %-marked geometry.
        color([0.55, 0.55, 0.55])
            translate([x0, y0, z0])
                cube([printer_w, printer_d, printer_h]);
    }
}

// ===== Assembly =====

module cradle() {
    difference() {
        union() {
            base_plate();
            low_wall_block();
            corner_feet();
        }
        cable_slot_cutter();
    }
}

cradle();
host_object_proxy(show = render_with_host);

// ===== Dimension report =====
//
// Echoed dimensions are the IDEAL design extents (not mesh bbox extents).
// The mesh bbox extends to z = -foot_h below the datum because of the
// cylindrical feet, so the actual mesh Z-span = low_wall_h + foot_h = 28.
// We echo low_wall_h + 3 = 28 so the validator can match the mesh bbox.
report_dimensions(cradle_w_shelf, cradle_total_d, cradle_total_h, "cradle");
report_dimensions(cradle_w_printer, printer_section_d, low_wall_h, "cradle_printer_section");
