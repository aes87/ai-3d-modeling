// P-touch Cradle — Brother PT-P750W (round 5 / v3 minimalism)
//
// ROUND-5 SCOPE (this file):
//   Three small refinements to round 4 — all simplifications:
//     1. corner_feet() module deleted entirely. Base plate sits flush on
//        the build plate at z=0. User applies silicone feet aftermarket.
//     2. cable_slot_cutter() module deleted entirely. The -Y back wall is
//        a clean continuous 25mm band — the printer's plug sits above the
//        25mm wall height, so no notch is needed.
//     3. Top-edge fillet rendered smooth: $fn 80→200 and the slab-stack
//        steps 8→64 so the r=3 quarter-arc reads as a true continuous
//        curve (each slab is now ~0.047mm tall, well below FDM resolution
//        and below visual perception).
//
// What survives from round 4 (UNCHANGED):
//   - Stepped body footprint (86 mm printer section → 110 mm shelf).
//   - Continuous tray-holder wrap (slot side walls 3.05 mm).
//   - Printer pocket (80 × 154 mm interior, 1 mm XY clearance).
//   - Tray slot pocket (103.9 × 94.9 × ~22 mm, sliding fit 0.35 mm/side).
//   - host_object_proxy() module + render_with_host parameter for
//     use-state renders. STL export keeps render_with_host=false.
//   - Hero r=10 fillets: cradle exterior corners, base plate corners,
//     printer-section→shelf concave fillet on both ±X sides.
//   - Utility r=3 fillet on top edges.
//
// What is gone in round 5:
//   - corner_feet() module (and foot_d/foot_h/foot_inset/foot_blend_r).
//   - cable_slot_cutter() module (and cable_slot_w/cable_slot_h/etc.).
//   - The cradle_total_h "+3 below" comment (no feet below datum any more).
//
// Mesh Z-span goes from 28mm (was -3..25 with feet) to 25mm (now 0..25).
//
// User orientation (unchanged):
//   +Y = user-front (tray slides out this way; printer faces user)
//   -Y = user-back  (against-wall; cable runs over the top of this wall)
//   +X = user-right
//   -X = user-left
//   +Z = up
//
// Print-frame coordinates:
//   Origin at the back-left corner of the SHELF footprint (the widest
//   part of the cradle). +X = right, +Y = forward (toward user), +Z = up.
//   Back exterior at Y=0, front of cradle at Y = cradle_total_d.
//   The printer section is inset on both sides by 12 mm (X = 12..98).
//
// Print orientation:
//   Base down, walls vertical. No supports needed at any feature.
//   Base plate's full footprint sits flush on the bed at z=0.

include <fdm-pla.scad>
include <bambu-x1c.scad>
include <common.scad>

$fn = 200;

// ===== Top-level toggles =====
//
// render_with_host: if true, host_object_proxy() draws the installed
// printer box for use-state renders. STL export MUST keep this false.
// Use-state PNG renders override via `--param render_with_host=true`.
render_with_host = false;

// ===== Parameters =====

// Overall footprint
//
// Round-4 update: cradle_w_shelf bumped from 108 → 110 so the slot side
// walls grow from 2.05 mm to 3.05 mm (matching wall_thickness=3). The
// tray-holder reads as a continuous U-wrap around the tray's three sides
// at uniform wall thickness. side_step grows 11 → 12, still accommodating
// the r=10 transition fillet.
cradle_w_shelf       = 110;     // X, shelf (wide) section body width
cradle_w_printer     = 86;      // X, printer (narrow) section body width
side_step            = (cradle_w_shelf - cradle_w_printer) / 2;  // 12 mm
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
// Hero radius. Capped by side_step (12 mm); the fillet must fit within
// the Y-delta between the printer and shelf footprints.
transition_fillet_r  = 10;

// Tray slot pocket dims (matches tray exterior 103.2 × 94.2 × 30 with
// 0.35 mm sliding fit per side in X and Y; slot height covers the lower
// portion of the tray since round-5 tray is intentionally taller than
// the 25mm cradle wall).
slot_w               = 103.9;
slot_d               = 94.9;
slot_h               = 22.3;
tray_section_d       = 94.9;
tray_section_y0      = 160;     // back of tray slot = front of printer section

// Fillet schedule — TWO tiers (no foot exception in round 5)
fillet_utility_r     = 3.0;     // r=3 break-edges, top edges, tray edges
fillet_hero_r        = 10.0;    // r=10 cradle exterior corners, base plate
                                 // corners, printer→shelf concave

// Top-edge fillet stack tessellation (round-5 bump 8→64 for smooth curve)
top_fillet_steps     = 64;

// Derived totals (echoed for validation)
//
// Round-5 update: feet are gone. The cradle's mesh extends from z=0 (base
// plate bottom, flush with build plate) to z=low_wall_h=25 (top of wall
// fillet). Total height = 25mm.
cradle_total_h       = low_wall_h;   // 25 mm — flush base, no feet

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

// ===== 2D footprint =====
//
// Stepped footprint: the back of the cradle is the narrower printer
// section (X = 12..98, Y = 0..160), the front is the wider shelf (X =
// 0..110, Y = 160..254.9). The transition between the two has a concave
// quarter-arc on each side (r = transition_fillet_r) sweeping from the
// inner printer-section wall outward to the shelf wall.

module stepped_footprint_raw() {
    N = 32;
    r = transition_fillet_r;
    printer_x_right = side_step + cradle_w_printer;     // 98
    printer_x_left  = side_step;                         // 12

    right_cx = printer_x_right + r;       // 108
    right_cy = printer_section_d - r;     // 150
    left_cx  = printer_x_left - r;        //   2
    left_cy  = printer_section_d - r;     // 150

    // Right concave arc: 180° → 90°
    right_arc = [for (i = [0 : N])
        let(a = 180 - 90 * i / N)
        [right_cx + r * cos(a), right_cy + r * sin(a)]
    ];

    // Left concave arc: 90° → 0° (reversed sweep when walking polygon CCW)
    left_arc = [for (i = [0 : N])
        let(a = 90 - 90 * i / N)
        [left_cx + r * cos(a), left_cy + r * sin(a)]
    ];

    points = concat(
        [[printer_x_left,    0]],                          // BL printer
        [[printer_x_right,   0]],                          // BR printer
        [[printer_x_right,   printer_section_d - r]],      // start of right arc (T_vert_R)
        right_arc,                                         // 180° → 90°
        [[cradle_w_shelf,    printer_section_d]],          // shelf NE
        [[cradle_w_shelf,    cradle_total_d]],             // shelf FR
        [[0,                 cradle_total_d]],             // shelf FL
        [[0,                 printer_section_d]],          // shelf NW
        left_arc,                                          // 90° → 0°
        [[printer_x_left,    printer_section_d - r]],      // T_vert_L
        [[printer_x_left,    0]]                           // close
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

// ===== Low perimeter wall block (25 mm tall stepped ring) =====
//
// The wall block extrudes the wall footprint to z = low_wall_h, with a
// utility r=3 fillet rolled onto the top edge.
//
// Round-5 update: top_fillet_steps bumped 8→64 for a smooth top edge.
// Each slab is now r/64 ≈ 0.047mm tall — invisible at any reasonable
// render zoom and far below FDM layer height.

module low_wall_block_solid() {
    r = fillet_utility_r;     // top-edge utility fillet
    // Main solid extrusion stops `r` below the wall top.
    linear_extrude(height = low_wall_h - r)
        wall_footprint();
    // Quarter-arc profile rolled onto the top edge.
    for (i = [0 : top_fillet_steps - 1]) {
        a0 = 90 * i       / top_fillet_steps;
        a1 = 90 * (i + 1) / top_fillet_steps;
        inset1 = r * (1 - cos(a1));
        z0 = (low_wall_h - r) + r * sin(a0);
        z1 = (low_wall_h - r) + r * sin(a1);
        translate([0, 0, z0])
            linear_extrude(height = z1 - z0 + 0.001)
                offset(r = -inset1)
                    wall_footprint();
    }
}

// Wall block carved by the printer pocket and the tray slot.
module low_wall_block() {
    difference() {
        low_wall_block_solid();

        // Printer pocket — interior cavity for the printer body. Goes
        // FROM the base plate top up through the wall top (z=4..25).
        pocket_x0 = side_step + (cradle_w_printer - pocket_w) / 2;  // 15
        pocket_y0 = wall_thickness;                                  // 3
        translate([pocket_x0, pocket_y0, base_thickness - 0.01])
            cube([pocket_w, pocket_d, low_wall_h + 1]);

        // Tray slot — interior cavity for the tray. Open top, open front
        // (the +Y face of the slot is past the cradle's +Y wall, so the
        // tray slides out from the front).
        slot_x0 = (cradle_w_shelf - slot_w) / 2;                     // 3.05
        translate([slot_x0, tray_section_y0 - 0.01, base_thickness - 0.01])
            cube([slot_w, tray_section_d + 0.02, low_wall_h + 10]);
    }
}

// ===== Host-object proxy (round 2 NEW — for use-state renders) =====
//
// Renders a 78×152×143 box at the printer's installed position.
// Excluded from STL by default (render_with_host = false); enable for
// PNG renders that show the printer in place via
// `--param render_with_host=true`.
//
// Installed position math:
//   pocket interior origin (X) = side_step + (cradle_w_printer - pocket_w)/2 = 15
//   pocket interior origin (Y) = wall_thickness = 3
//   pocket floor                = base_thickness = 4
//   printer is centered in the 80×154 pocket with 1 mm XY clearance per side
//   → printer X origin = 15 + 1 = 16
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
    union() {
        base_plate();
        low_wall_block();
    }
}

cradle();
host_object_proxy(show = render_with_host);

// ===== Dimension report =====
//
// Round-5: feet gone, cable notch gone. Mesh extends z=0..25 (flush base
// to top of wall fillet). Echoed dimensions match mesh bbox exactly.
report_dimensions(cradle_w_shelf, cradle_total_d, cradle_total_h, "cradle");
report_dimensions(cradle_w_printer, printer_section_d, low_wall_h, "cradle_printer_section");
