// P-touch Cradle — Brother PT-P750W
// Stepped body: narrow 86 mm around the printer section, widening to 108 mm
// around the forward tray shelf via a 45° chamfer transition at Y=149..160.
// Full-perimeter 25 mm low bathtub + tall back panel + forward tray slot.
// Owl motif: ear tufts peek above the back panel top corners.
//
// Coordinate system:
//   Origin at the back-left corner of the SHELF footprint (which is also the
//   widest part of the cradle). +X = right, +Y = forward (toward the user),
//   +Z = up. Back exterior at Y=0. Front of cradle at Y=254.9.
//   The printer section is inset on both sides by 11 mm (X = 11 .. 97).

include <fdm-pla.scad>
include <bambu-x1c.scad>
include <common.scad>

$fn = 80;

// ===== Parameters =====
// Overall
cradle_w_shelf       = 108;    // X, shelf (wide) section body width
cradle_w_printer     = 86;     // X, printer (narrow) section body width
side_step            = (cradle_w_shelf - cradle_w_printer) / 2;  // 11 mm per side
cradle_total_d       = 254.9;  // Y, overall cradle depth
base_thickness       = 4.0;    // base plate thickness
wall_thickness       = 3.0;    // nominal wall thickness

// Printer section
pocket_w             = 80;     // X interior pocket (78 printer + 2*1.0 clearance)
pocket_d             = 154;    // Y interior pocket (152 + 2*1.0 clearance)
printer_section_d    = 160;    // Y (3 back wall + 154 pocket + 3 front wall)
low_wall_h           = 25;     // perimeter wall height
back_panel_h         = 145;    // tall back panel body top

// Step transition (chamfer)
chamfer_len          = side_step;  // 11 mm — 45° means same in X and Y
chamfer_y_start      = printer_section_d - chamfer_len;  // 149
chamfer_y_end        = printer_section_d;                // 160

// Ear tufts
tuft_base_w          = 25;
tuft_peak_dz         = 35;
tuft_peak_inset_x    = 5;
tuft_apex_r          = 2;
tuft_thickness       = 3;

// Cable slot
cable_slot_w         = 25;
cable_slot_h         = 20;
cable_slot_cx        = 54;     // center X from shelf-origin left (X=0)

// Feet
foot_d               = 8;
foot_h               = 3;
foot_inset           = 5;

// Tray slot pocket (in the shelf section)
slot_w               = 103.9;
slot_d               = 94.9;
slot_h               = 42.3;
tray_section_d       = 94.9;
tray_section_y0      = 160;

// Fillets
fillet_vert_r        = 4.0;    // cradle exterior vertical edges (walls)
fillet_base_corner_r = 6.0;    // base plate footprint corners (top-down)
fillet_top_r         = 1.5;    // wall-top horizontal edge fillet

// Cradle body height (for asserts)
cradle_body_h        = back_panel_h;
cradle_total_h       = back_panel_h + tuft_peak_dz;

// ===== Structural asserts =====
assert(wall_thickness >= MIN_WALL, str("Wall thickness ", wall_thickness, " below min ", MIN_WALL));
assert(base_thickness >= MIN_FLOOR_CEIL, str("Base ", base_thickness, " below min floor"));
assert(cradle_total_d <= 256, str("Cradle depth exceeds bed: ", cradle_total_d));
assert(cradle_w_shelf <= 256, "Cradle width exceeds bed");
assert(cradle_total_h <= 256, "Cradle height exceeds bed");
assert(side_step > 0, "Step must be positive");
// Printer-section side walls = side_step in X: (86 - 80)/2 = 3mm. Check.
assert((cradle_w_printer - pocket_w)/2 >= wall_thickness - 0.01,
       str("Printer section side walls below 3mm"));

// ===== Modules =====

// 2D footprint polygon — stepped with 45° chamfers at Y=149..160 on both
// sides. All 8 vertices are listed CCW. The four OUTER corners (back-L,
// back-R, front-L, front-R) will be rounded with fillet_base_corner_r via
// offset() — the chamfer-end vertices will also receive some rounding,
// which produces a clean visible 45° chamfer segment with small tangent
// transitions at each end. Visual result reads as a clean taper.
module stepped_footprint_raw() {
    polygon(points=[
        [side_step,                 0],                   // back-left  (X=11, Y=0)
        [side_step + cradle_w_printer, 0],                // back-right (X=97, Y=0)
        [side_step + cradle_w_printer, chamfer_y_start],  // (97, 149)
        [cradle_w_shelf,            chamfer_y_end],       // (108, 160)
        [cradle_w_shelf,            cradle_total_d],      // (108, 254.9)
        [0,                         cradle_total_d],      // (0, 254.9)
        [0,                         chamfer_y_end],       // (0, 160)
        [side_step,                 chamfer_y_start],     // (11, 149)
    ]);
}

// Outer footprint for the BASE PLATE: stepped polygon, corners rounded with
// fillet_base_corner_r. The 45° chamfer endpoints also pick up the same
// radius but since the chamfer segment is 15.5 mm long (11*sqrt(2)),
// there is ~3.5 mm of clean straight 45° visible after rounding endpoints.
module base_footprint() {
    offset(r=fillet_base_corner_r)
        offset(r=-fillet_base_corner_r)
            stepped_footprint_raw();
}

// Outer footprint for the WALLS (slightly tighter corner fillet so walls
// sit inset of the base plate edge — a 2 mm step all around).
module wall_footprint() {
    offset(r=fillet_vert_r)
        offset(r=-fillet_vert_r)
            stepped_footprint_raw();
}

// Base plate — extruded stepped polygon.
module base_plate() {
    linear_extrude(height=base_thickness)
        base_footprint();
}

// Corner feet (4x) — placed at the FOUR OUTER corners of the stepped
// footprint. These are: back-left (inset from X=11,Y=0), back-right
// (inset from X=97,Y=0), front-left (inset from X=0,Y=254.9), front-right
// (inset from X=108,Y=254.9).
module corner_feet() {
    positions = [
        [side_step + foot_inset,                 foot_inset                 ],
        [side_step + cradle_w_printer - foot_inset, foot_inset              ],
        [foot_inset,                             cradle_total_d - foot_inset],
        [cradle_w_shelf - foot_inset,            cradle_total_d - foot_inset],
    ];
    for (p = positions) {
        translate([p[0], p[1], -foot_h])
            intersection() {
                scale([1, 1, foot_h / (foot_d/2)])
                    sphere(d=foot_d);
                translate([-foot_d, -foot_d, 0])
                    cube([2*foot_d, 2*foot_d, foot_h + 0.01]);
            }
    }
}

// Low perimeter wall block — 25 mm tall stepped ring with 80 x 154 pocket
// carved in the printer section, and a 103.9 x 94.9 open-front / open-top
// slot carved in the shelf section. Top outer edge receives a 1.5 mm
// rounded fillet via a minkowski hemisphere.
//
// We model this as two z-zones:
//   Main body: z = 0 .. (low_wall_h - fillet_top_r)      -- full wall ring
//   Top cap:   z = (low_wall_h - fillet_top_r) .. low_wall_h -- rounded
module low_wall_block_solid() {
    // Solid block (before pocket/slot carve). Outer footprint uses the
    // WALL fillet radius (4 mm). Top edge is rounded via stacked slices:
    // this is a cheap approximation of a quarter-round that avoids the
    // minkowski-with-holes pitfall.
    r = fillet_top_r;
    // Main straight-wall body
    linear_extrude(height=low_wall_h - r)
        wall_footprint();
    // Rounded top: 6 stacked slices approximating a quarter-round
    steps = 6;
    for (i = [0 : steps - 1]) {
        t0 = i / steps;
        t1 = (i + 1) / steps;
        a0 = 90 * t0;
        a1 = 90 * t1;
        inset0 = r * (1 - cos(a0));
        inset1 = r * (1 - cos(a1));
        z0 = low_wall_h - r + r * sin(a0);
        z1 = low_wall_h - r + r * sin(a1);
        // Use the larger inset (inset1) for the slice to guarantee
        // monotonic narrowing and no non-manifold overlap.
        translate([0, 0, z0])
            linear_extrude(height=z1 - z0 + 0.001)
                offset(r=-inset1) wall_footprint();
    }
}

module low_wall_block() {
    difference() {
        low_wall_block_solid();
        // Printer-section pocket carve: X = side_step + (cradle_w_printer - pocket_w)/2 .. +pocket_w
        pocket_x0 = side_step + (cradle_w_printer - pocket_w) / 2;
        translate([pocket_x0, wall_thickness, -0.01])
            cube([pocket_w, pocket_d, low_wall_h + 1]);
        // Shelf-section tray slot carve: X centered on 108-wide shelf.
        slot_x0 = (cradle_w_shelf - slot_w) / 2;
        translate([slot_x0, tray_section_y0 - 0.01, base_thickness - 0.01])
            cube([slot_w, tray_section_d + 0.02, slot_h + 10]);
    }
}

// Tray shelf tall walls (above low_wall_h). The tray slot interior height
// is 42.3 mm measured from the shelf floor (z=base_thickness=4). So the
// tray-slot upper walls extend from z=low_wall_h up to z = base_thickness +
// slot_h = 46.3 mm. These live only in the shelf section (Y >= 160).
//
// NOTE: The shelf section's side walls are only 2.05 mm thick (flanking
// the tray slot at x=0..2.05 and x=105.95..108). A 1.5 mm top-edge
// horizontal fillet here would intersect the 4 mm vertical corner fillet
// and reduce wall cross-section to ~0.55 mm at the top two layers — below
// FDM min wall. We therefore leave the top edge of these walls as a
// sharp 90° corner (print-safe; slicer adds a tiny break-edge). The
// 1.5 mm top fillet IS still applied on the low perimeter walls (z=25,
// ≥3 mm thick) and the tall back panel top (z=145, 3 mm thick — fillet
// clamped there already).
module tray_shelf_upper_walls() {
    z_bottom = low_wall_h;
    z_top_full = base_thickness + slot_h;  // 46.3
    module shelf_rect() {
        translate([0, tray_section_y0])
            offset(r=fillet_vert_r) offset(r=-fillet_vert_r)
                square([cradle_w_shelf, tray_section_d]);
    }
    difference() {
        // Straight body — no top-edge rounding to preserve the full
        // 2.05 mm wall cross-section at the top two layers.
        translate([0, 0, z_bottom])
            linear_extrude(height=z_top_full - z_bottom)
                shelf_rect();
        // Carve the tray slot (open top + open front). Extend slightly
        // above z_top_full and past the front face to guarantee open top/front.
        slot_x0 = (cradle_w_shelf - slot_w) / 2;
        translate([slot_x0, tray_section_y0 - 0.01, z_bottom - 0.01])
            cube([slot_w, tray_section_d + 0.02, z_top_full - z_bottom + 5]);
    }
}

// Tall back panel body — 86 wide × 3 thick × 145 tall, sitting on top of
// the printer section back wall (which is X = 11..97, Y = 0..3, z = 0..25).
// Above the low wall zone it is the sole back wall.
//
// Note: vertical edge fillets (4 mm) are NOT applied to the back panel's
// left/right vertical edges because the panel is only 3 mm thick, which
// is narrower than 2 * 4 mm. Those edges are inherently sharp. The
// printer-section walls (which share the panel's base at z=0..25) get
// their 4 mm vertical fillet via the wall_footprint() offset trick — so
// visually the filet is applied where material thickness permits.
//
// The top edge (z = 145) receives a 1.5 mm horizontal round-over on the
// front and back faces (the two long top edges, each 86 mm long). The
// 2 mm apex tufts sit atop these edges and overlap down into the
// rounded zone so there is no visible seam.
module tall_back_panel_body() {
    r = fillet_top_r;
    // Straight body (z = 0 .. back_panel_h - r)
    translate([side_step, 0, 0])
        linear_extrude(height=back_panel_h - r)
            square([cradle_w_printer, wall_thickness]);
    // Rounded top via stacked slices: shrink Y (panel-thin direction) so
    // the top rounds along the front and back long edges.
    steps = 5;  // fewer steps so we don't collapse to a knife edge
    for (i = [0 : steps - 1]) {
        t0 = i / steps;
        t1 = (i + 1) / steps;
        a0 = 90 * t0;
        a1 = 90 * t1;
        // Cap the inset so we never exceed wall_thickness/2 - 0.1
        inset_raw = r * (1 - cos(a1));
        max_inset = wall_thickness / 2 - 0.1;  // keep >= 0.2mm final thickness
        inset1 = min(inset_raw, max_inset);
        z0 = back_panel_h - r + r * sin(a0);
        z1 = back_panel_h - r + r * sin(a1);
        y_shrink = inset1;
        translate([side_step, y_shrink, z0])
            linear_extrude(height=z1 - z0 + 0.001)
                square([cradle_w_printer, wall_thickness - 2*y_shrink]);
    }
}

// Ear tuft — 2D triangular profile in the X-Z plane, extruded in Y.
// left_side=true => outer edge at X = side_step (left exterior of back panel).
module ear_tuft(left_side=true) {
    // Outer X of tuft equals outer X of back panel.
    outer_x = left_side ? side_step : (side_step + cradle_w_printer);
    dir     = left_side ? 1 : -1;

    // Tuft base extends slightly below back_panel_h to overlap the top
    // fillet rounding of the back panel (ensures no gap).
    tuft_base_z = back_panel_h - 1.0;  // overlap 1 mm into rounded zone

    translate([outer_x, 0, 0])
    rotate([90, 0, 0])
    translate([0, 0, -tuft_thickness])
    linear_extrude(height=tuft_thickness)
        scale([dir, 1])
            intersection() {
                offset(r=tuft_apex_r)
                    polygon(points=[
                        [tuft_apex_r,                         back_panel_h + tuft_apex_r*0.5],
                        [tuft_base_w - tuft_apex_r,           back_panel_h + tuft_apex_r*0.5],
                        [tuft_peak_inset_x,                   back_panel_h + tuft_peak_dz - tuft_apex_r],
                    ]);
                translate([-10, tuft_base_z])
                    square([tuft_base_w + 20, tuft_peak_dz + tuft_apex_r*2 + 2]);
            }
}

// Cable slot cutter: U-notch in the back wall (which is at X = 11..97,
// Y = 0..3). Cut is centered at X = cradle_w_shelf/2 = 54 — which equals
// side_step + cradle_w_printer/2 = 11 + 43 = 54 — exactly centered on
// the 86 mm back panel as well.
module cable_slot_cutter() {
    translate([cable_slot_cx - cable_slot_w/2, -0.1, -0.01])
        cube([cable_slot_w, wall_thickness + 0.2, cable_slot_h]);
}

// ===== Assembly =====

module cradle() {
    difference() {
        union() {
            // 1. Base plate (z=0..4) — stepped 108/86 footprint
            base_plate();
            // 2. Low perimeter walls (z=0..25) — stepped ring, printer
            //    pocket carved, tray-slot carved
            low_wall_block();
            // 3. Tall back panel (z=0..145) — 86 wide, centered
            tall_back_panel_body();
            // 4. Ear tufts (z ≈ 144..180)
            ear_tuft(left_side=true);
            ear_tuft(left_side=false);
            // 5. Tray shelf upper walls (z=25..46.3) — only in shelf zone
            tray_shelf_upper_walls();
            // 6. Corner feet (z=-3..0)
            corner_feet();
        }
        // Cable pass-through notch
        cable_slot_cutter();
    }
}

// Build
cradle();

// ===== Dimension report =====
report_dimensions(cradle_w_shelf, cradle_total_d, cradle_total_h, "cradle");
report_dimensions(cradle_w_shelf, cradle_total_d, cradle_body_h, "cradle_body_no_tufts");
report_dimensions(cradle_w_printer, printer_section_d, low_wall_h, "cradle_printer_section");
