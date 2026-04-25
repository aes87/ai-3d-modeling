// P-touch Cradle — Brother PT-P750W (round 3 / R2 critique outputs)
//
// ROUND-2 SCOPE (this file):
//   - Back panel grows 145 → 205 mm. Owl face relocates to the visible
//     strip ABOVE the installed printer (face zone z=143..205).
//   - Facial disc rebuilt as heart-shaped (rounded-shield) carve, NOT a
//     circular mascot disc. Carved INTO the convex panel face.
//   - Eyes are RECESSED (sunk 1.5 mm into the disc), NOT proud domes.
//     16 × 20 mm vertical ellipses. No pupils.
//   - Beak is an asymmetric hooked raptor wedge — narrow top, wider base,
//     tip pointing down with a slight forward hook curl, x-lean +1mm.
//   - Ear tufts thrown out and rebuilt as splayed feather clumps — 3
//     hulled feather profiles per tuft, outward lean only (NO forward
//     curl, NO +Y tilt, NO sweep, NO "soft-serve" geometry).
//   - Convex +Y panel sagitta bumped 2 → 3 mm.
//   - NEW: host_object_proxy() module renders a 78×152×143 printer box at
//     the installed position. Excluded from STL export by default; toggled
//     on for use-state renders via the render_with_host parameter.
//
// User orientation (unchanged):
//   +Y = user-front (tray slides out this way; owl face visible from here)
//   -Y = user-back  (against-wall, cable notch lives here)
//
// Print-frame coordinate system:
//   Origin at the back-left corner of the SHELF footprint (the widest part
//   of the cradle). +X = right, +Y = forward (toward the user), +Z = up.
//   Back exterior at Y=0. Front of cradle at Y=254.9.
//   The printer section is inset on both sides by 11mm (X = 11..97).

include <fdm-pla.scad>
include <bambu-x1c.scad>
include <common.scad>

$fn = 80;

// ===== Top-level toggles =====
//
// render_with_host: if true, host_object_proxy() draws the installed printer
// box for use-state renders. STL export MUST keep this false. Use-state PNG
// renders override via `--param render_with_host=true`.
render_with_host = false;

// ===== Parameters =====

// Overall
cradle_w_shelf       = 108;    // X, shelf (wide) section body width
cradle_w_printer     = 86;     // X, printer (narrow) section body width
side_step            = (cradle_w_shelf - cradle_w_printer) / 2;  // 11 mm
cradle_total_d       = 254.9;  // Y, overall cradle depth
base_thickness       = 4.0;    // base plate thickness
wall_thickness       = 3.0;    // nominal wall thickness

// Printer section
pocket_w             = 80;     // X interior pocket
pocket_d             = 154;    // Y interior pocket
printer_section_d    = 160;    // Y
low_wall_h           = 25;

// Back panel — round 2: panel grows from 145 to 205 mm. The 7mm dip from
// center to corner is preserved by recomputing the top-arc radius (rather
// than holding it at 160mm — at 160mm the dip with the new height drops
// to ~6mm, close enough to the brief's 7mm target, but we recompute to
// keep the dip at a clean 7mm).
back_panel_top_center_z  = 205;
back_panel_top_corner_z  = 198;
// Top-arc radius solving sqrt(R^2 - (cradle_w_printer/2)^2) - (R - dip) = 0
// dip = back_panel_top_center_z - back_panel_top_corner_z = 7
// R = (43^2 + 7^2) / (2 * 7) = (1849 + 49) / 14 = 135.57 mm
back_panel_arc_r         = 135.57;

// Back panel +Y face convexity
panel_convexity      = 3;      // sagitta at X=0 (round 2: 2 → 3)
panel_front_arc_r    = (pow(cradle_w_printer/2, 2) + pow(panel_convexity, 2)) / (2 * panel_convexity);
// With w=86, conv=3: R = (43² + 3²) / 6 = (1849 + 9) / 6 ≈ 309.67 mm

// Back panel fillets
panel_vert_edge_r    = 4;      // vertical edge fillet (applied to X-Y cross-section)
panel_top_fillet_r   = 6;      // top fillet radius
panel_base_concave_r = 4;      // concave fillet where panel meets body at z=25

// Concave fillet at printer-section → shelf transition (replaces 45° chamfer)
transition_fillet_r  = 8;
transition_arc_y_end = printer_section_d;          // 160
transition_arc_y_start = transition_arc_y_end - transition_fillet_r; // 152

// ===== Face zone parameters (z = 143..205) =====
//
// All face anatomy lives in this strip — the only zone visible above the
// installed printer.
face_zone_z_min      = 143;
face_zone_z_max      = 205;

// Heart-shaped (rounded-shield) facial disc
face_disc_top_z      = 200;
face_disc_bottom_z   = 148;
face_disc_top_w      = 70;
face_disc_bottom_w   = 40;
face_disc_depth_max  = 1.5;    // bowl depth at center
face_disc_rim_r      = 2;

// Recessed eye sockets (NOT proud domes)
face_eye_w           = 16;
face_eye_h           = 20;
face_eye_recess_d    = 1.5;
face_eye_cz          = 180;
face_eye_cx_offset   = 16;     // ±X from panel center

// Asymmetric hooked beak (raptor reference, not cartoon triangle)
face_beak_top_w      = 4;
face_beak_base_w     = 10;
face_beak_top_z      = 164;    // top of the beak (joins disc surface)
face_beak_tip_z      = 148;    // bottom tip
face_beak_proud_max  = 4;      // forward proud at the tip
face_beak_tip_fwd    = 5;      // tip is +5mm forward of the base footprint
face_beak_x_lean     = 1;      // +1mm asymmetric lean (rightward)

// ===== Ear tufts — splayed feather clumps =====
//
// Each tuft = 3 hulled feather profiles. Outward lean only — NO forward
// curl, NO Y-tilt, NO sweep. The round-1 wizard-hat / soft-serve geometry
// is dead and stays dead.

// Per-feather geometry (w = X-extent at base, h = total Z-height above
// panel top, yd = Y-depth (panel-perpendicular), tilt = outward lean from
// vertical in degrees)
// Heights are pre-tilt vertical extents. After outward tilt and the
// 2mm base-dip into the panel, the actual peak Z-above-panel-top is:
//   peak_dz = h * cos(tilt_deg) - base_dip
// We need middle peak_dz ≈ 16mm above panel top → h * cos(20°) ≈ 18 →
// h_middle ≈ 19mm. Bumped from notes' 16 to compensate for cos(tilt) loss.
// Tilt-corrected heights: peak_dz = h * cos(tilt) - base_dip ≈ target dz.
// Target peak_dz for the tallest (middle) feather is 16mm above panel-top
// CENTER (z=205) → 21mm above panel-top AT tuft x=±25 (z=202.67), which
// gives mesh peak z=221 to match spec. Solve h*cos(tilt) - base_dip = 18.3
// for middle: h = (18.3 + 2) / cos(20°) = 21.6 → use 22 for safety margin.
// Y-depths reduced from spec slightly so the tuft Y-extent fits cleanly
// inside [0.5, wall+conv-0.5] — no tuft surface touches the seam-hidden
// -Y face of the panel.
tuft_inner_w         = 8;
tuft_inner_h         = 18;
tuft_inner_yd        = 4;
tuft_inner_tilt      = 10;

tuft_middle_w        = 10;
tuft_middle_h        = 22;
tuft_middle_yd       = 5;
tuft_middle_tilt     = 20;

tuft_outer_w         = 8;
tuft_outer_h         = 16;
tuft_outer_yd        = 3.5;
tuft_outer_tilt      = 30;

tuft_center_x_offset = 25;     // ± from panel center, where the middle
                               //   feather of each tuft is anchored
tuft_base_blend_r    = 4;      // base fillet into rounded panel top

// Cable slot (on -Y wall)
cable_slot_w         = 25;
cable_slot_h         = 20;
cable_slot_cx        = 54;

// Feet
foot_d               = 8;
foot_h               = 3;
foot_inset           = 5;
foot_blend_r         = 1.0;    // foot-to-plate concave fillet

// Tray slot pocket (shortened tray: ext_h = 21.6)
slot_w               = 103.9;
slot_d               = 94.9;
slot_h               = 22.3;
tray_section_d       = 94.9;
tray_section_y0      = 160;

// Fillets
fillet_vert_r        = 4.0;    // cradle exterior vertical edges (body walls)
fillet_base_corner_r = 8.0;    // base plate footprint corners (round 2: 6 → 8)
fillet_top_r         = 1.5;

// Derived totals
cradle_body_h        = back_panel_top_center_z;       // 205
cradle_total_h       = back_panel_top_center_z + 16;  // 221 (panel + tuft peak)

// ===== Structural asserts =====
assert(wall_thickness >= MIN_WALL, str("Wall thickness ", wall_thickness, " below min ", MIN_WALL));
assert(base_thickness >= MIN_FLOOR_CEIL, str("Base ", base_thickness, " below min floor"));
assert(cradle_total_d <= 256, str("Cradle depth exceeds bed: ", cradle_total_d));
assert(cradle_w_shelf <= 256, "Cradle width exceeds bed");
assert(cradle_total_h <= 256, str("Cradle height exceeds bed: ", cradle_total_h));
assert(side_step > 0, "Step must be positive");
assert((cradle_w_printer - pocket_w)/2 >= wall_thickness - 0.01,
       "Printer section side walls below 3mm");
assert(transition_fillet_r <= side_step + 0.01,
       "Transition fillet larger than side step");
// Face zone sanity: face features must live above the installed printer top
assert(face_disc_bottom_z >= face_zone_z_min - 0.01,
       str("Facial disc bottom z=", face_disc_bottom_z, " below printer top z=143"));
assert(face_disc_top_z <= face_zone_z_max,
       str("Facial disc top z=", face_disc_top_z, " above panel top z=205"));
assert(face_eye_cz - face_eye_h/2 >= face_zone_z_min,
       "Eye bottom dips below printer top — would be hidden in use");

// ===== 2D footprint =====

// Raw stepped footprint with the printer→shelf transition as a concave arc.
function transition_arc_y_start_x_right() = side_step + cradle_w_printer + transition_fillet_r;
function transition_arc_y_start_x_left()  = side_step - transition_fillet_r;

module stepped_footprint_raw() {
    N = 24;
    right_arc = [for (i = [0 : N])
        let(a = 180 - 90 * i / N)
        [transition_arc_y_start_x_right() + transition_fillet_r * cos(a),
         transition_arc_y_start + transition_fillet_r * sin(a)]
    ];
    left_arc = [for (i = [0 : N])
        let(a = 90 * i / N)
        [transition_arc_y_start_x_left() + transition_fillet_r * cos(a),
         transition_arc_y_start + transition_fillet_r * sin(a)]
    ];

    points = concat(
        [[side_step, 0]],
        [[side_step + cradle_w_printer, 0]],
        [[side_step + cradle_w_printer, transition_arc_y_start]],
        right_arc,
        [[cradle_w_shelf, cradle_total_d]],
        [[0, cradle_total_d]],
        [[0, transition_arc_y_end]],
        [for (i = [0 : N]) left_arc[N - i]],
        [[side_step, 0]]
    );
    polygon(points = points);
}

module base_footprint() {
    offset(r = fillet_base_corner_r)
        offset(r = -fillet_base_corner_r)
            stepped_footprint_raw();
}

module wall_footprint() {
    offset(r = fillet_vert_r)
        offset(r = -fillet_vert_r)
            stepped_footprint_raw();
}

// ===== Base plate =====

module base_plate() {
    linear_extrude(height = base_thickness)
        base_footprint();
}

// ===== Corner feet with r=1.0 upper blend =====
module corner_feet() {
    positions = [
        [side_step + foot_inset,                    foot_inset                 ],
        [side_step + cradle_w_printer - foot_inset, foot_inset                 ],
        [foot_inset,                                cradle_total_d - foot_inset],
        [cradle_w_shelf - foot_inset,               cradle_total_d - foot_inset],
    ];
    for (p = positions) {
        translate([p[0], p[1], 0]) {
            translate([0, 0, -foot_h])
                cylinder(h = foot_h, d = foot_d, $fn = 48);
            translate([0, 0, -foot_blend_r])
                cylinder(h = foot_blend_r,
                         d1 = foot_d,
                         d2 = foot_d + 2 * foot_blend_r,
                         $fn = 48);
        }
    }
}

// ===== Low perimeter wall block (25mm tall stepped ring) =====

module low_wall_block_solid() {
    r = fillet_top_r;
    linear_extrude(height = low_wall_h - r)
        wall_footprint();
    steps = 6;
    for (i = [0 : steps - 1]) {
        a1 = 90 * (i + 1) / steps;
        a0 = 90 * i / steps;
        inset1 = r * (1 - cos(a1));
        z0 = low_wall_h - r + r * sin(a0);
        z1 = low_wall_h - r + r * sin(a1);
        translate([0, 0, z0])
            linear_extrude(height = z1 - z0 + 0.001)
                offset(r = -inset1) wall_footprint();
    }
}

module low_wall_block() {
    difference() {
        low_wall_block_solid();
        // Printer pocket carve
        pocket_x0 = side_step + (cradle_w_printer - pocket_w) / 2;
        translate([pocket_x0, wall_thickness, -0.01])
            cube([pocket_w, pocket_d, low_wall_h + 1]);
        // Tray slot carve
        slot_x0 = (cradle_w_shelf - slot_w) / 2;
        translate([slot_x0, tray_section_y0 - 0.01, base_thickness - 0.01])
            cube([slot_w, tray_section_d + 0.02, slot_h + 10]);
    }
}

// Tray shelf upper walls (z = low_wall_h to z = base_thickness + slot_h)
module tray_shelf_upper_walls() {
    z_bottom = low_wall_h;
    z_top_full = base_thickness + slot_h;
    module shelf_rect() {
        translate([0, tray_section_y0])
            offset(r = fillet_vert_r) offset(r = -fillet_vert_r)
                square([cradle_w_shelf, tray_section_d]);
    }
    difference() {
        translate([0, 0, z_bottom])
            linear_extrude(height = z_top_full - z_bottom)
                shelf_rect();
        slot_x0 = (cradle_w_shelf - slot_w) / 2;
        translate([slot_x0, tray_section_y0 - 0.01, z_bottom - 0.01])
            cube([slot_w, tray_section_d + 0.02, z_top_full - z_bottom + 5]);
    }
}

// ===== Back panel — body =====
//
// Stacked horizontal slices. Each slice (at Z=z) is a 2D X-Y shape (in the
// ground plane) that shows the panel's footprint at that height. Half-width
// narrows near the top per the rounded-top arc; convexity ramps up from
// z=low_wall_h to z=low_wall_h + panel_base_concave_r.

function panel_half_width_at_z(z) =
    (z <= back_panel_top_corner_z)
        ? cradle_w_printer / 2
        : sqrt(max(0, pow(back_panel_arc_r, 2) -
                     pow(z - (back_panel_top_center_z - back_panel_arc_r), 2)));

function panel_convexity_at_z(z) =
    (z <= low_wall_h)
        ? 0
        : (z >= low_wall_h + panel_base_concave_r)
            ? panel_convexity
            : panel_convexity * sin(90 * (z - low_wall_h) / panel_base_concave_r);

module panel_xy_section(half_width, conv) {
    if (half_width > 0.5) {
        if (conv <= 0.01) {
            translate([-half_width, 0])
                square([2 * half_width, wall_thickness + 0.01]);
        } else {
            front_arc_r = (pow(half_width, 2) + pow(conv, 2)) / (2 * conv);
            intersection() {
                translate([-half_width, 0])
                    square([2 * half_width, wall_thickness + conv + 0.01]);
                translate([0, wall_thickness + conv - front_arc_r])
                    circle(r = front_arc_r, $fn = 160);
            }
        }
    }
}

// Vertical edge fillet limited by min thickness in Y at each slice.
module back_panel_body_raw() {
    n_slices = 110;
    slice_h = back_panel_top_center_z / n_slices;
    for (i = [0 : n_slices - 1]) {
        z0 = i * slice_h;
        z_mid = z0 + slice_h / 2;
        hw = panel_half_width_at_z(z_mid);
        conv = panel_convexity_at_z(z_mid);
        if (hw > 0.5) {
            // Safe edge-fillet radius: limited by Y-thickness of the slice.
            // wall_thickness (3) + conv (up to 3) → minimum thickness 3 in
            // worst case → max safe fillet ~1.2.
            safe_r = min(panel_vert_edge_r, 1.2);
            translate([cradle_w_shelf / 2, 0, z0])
                linear_extrude(height = slice_h + 0.02)
                    if (hw >= cradle_w_printer / 2 - 0.01 && hw >= safe_r + 0.5)
                        offset(r = safe_r) offset(r = -safe_r)
                            panel_xy_section(hw, conv);
                    else
                        panel_xy_section(hw, conv);
        }
    }
}

// ===== Heart-shaped (rounded-shield) facial disc =====
//
// 2D silhouette of the disc, in panel-front view (X-Z plane), centered
// at x=0. Top-wide, bottom-V, soft profile. Built as a hull of circles
// to guarantee a smooth single curve from top to bottom (no "two ovals
// jammed together" failure mode).

function face_disc_cz_mid() = (face_disc_top_z + face_disc_bottom_z) / 2;

module face_disc_silhouette_2d() {
    // Top arc circle: large, near the top of the disc, defining its width
    top_r = face_disc_top_w / 2;       // 35
    top_cz = face_disc_top_z - top_r;  // disc top reaches z=200
    // Mid arc circle: medium, between top and bottom
    mid_r = (face_disc_top_w + face_disc_bottom_w) / 4;  // 27.5
    mid_cz = face_disc_cz_mid() + 4;                     // slight bias up
    // Lower side circles (smaller, defining the narrowing toward the V)
    lower_r = face_disc_bottom_w / 2 + 4;                // 24
    lower_cz = face_disc_bottom_z + lower_r * 0.7;
    lower_cx = (face_disc_bottom_w / 2) - lower_r * 0.5;
    // Bottom point: small circle at the V tip
    tip_r = 3;
    tip_cz = face_disc_bottom_z + tip_r;

    hull() {
        translate([0, top_cz]) circle(r = top_r, $fn = 80);
        translate([0, mid_cz]) circle(r = mid_r, $fn = 80);
        translate([ lower_cx, lower_cz]) circle(r = lower_r, $fn = 64);
        translate([-lower_cx, lower_cz]) circle(r = lower_r, $fn = 64);
        translate([0, tip_cz]) circle(r = tip_r, $fn = 32);
    }
}

// 3D facial disc cutter: extrudes the silhouette into a thin slab,
// scaled in Y to produce the bowl depth, oriented so the bowl's depth
// direction lies along +Y (panel-perpendicular). The cutter intersects
// the panel +Y face and removes a heart-shaped recess up to face_disc_depth_max
// at the center, tapering to ~0 at the rim.
//
// Implementation: build a "lens" shape — intersect a thick X-Z extrusion
// with a Y-axis sphere/ellipsoid so the cut depth is greatest at the disc
// center and tapers to zero at the perimeter. This is what produces the
// concave bowl rather than a flat-bottomed stamp.
module facial_disc_cutter() {
    cx = cradle_w_shelf / 2;     // panel center X = 54
    cy_face = wall_thickness + panel_convexity;  // ≈ 6 (panel +Y face at center)
    cz_disc = face_disc_cz_mid();

    // Lens height scaled to disc bbox (top width is the bigger of the two)
    lens_w = face_disc_top_w + 4;
    lens_h = face_disc_top_z - face_disc_bottom_z + 4;

    translate([cx, cy_face, cz_disc])
        intersection() {
            // Heart-shape silhouette extruded into Y, centered on disc center
            // (just a thin slab thicker than disc_depth_max in Y)
            rotate([90, 0, 0])
                linear_extrude(height = face_disc_depth_max * 4, center = true)
                    translate([0, -cz_disc])  // center silhouette at z=cz_disc
                        face_disc_silhouette_2d();
            // Lens in Y: ellipsoid whose Y-extent is face_disc_depth_max*2,
            // and X/Z extents cover the disc footprint. Intersection with the
            // silhouette extrusion gives a lens-shaped (concave bowl) cutter.
            scale([lens_w / 2, face_disc_depth_max, lens_h / 2])
                sphere(r = 1, $fn = 64);
        }
}

// ===== Recessed eye sockets =====
//
// Eyes are SUNK INTO the disc, not proud. Implemented as ellipsoid
// cutters whose +Y center sits at the disc-floor depth, so the recess
// reaches face_disc_depth_max + face_eye_recess_d ≈ 3 mm into the panel
// at the eye center.
module eye_socket_cutter(x_offset) {
    cx = cradle_w_shelf / 2 + x_offset;
    // Disc floor Y at the eye center: panel front at this X minus the
    // local disc depth. For simplicity use the max disc depth (we're in
    // the disc interior).
    panel_front_y = wall_thickness + panel_convexity;  // ≈ 6
    disc_floor_y  = panel_front_y - face_disc_depth_max;  // ≈ 4.5
    // Cutter ellipsoid: center at (cx, disc_floor_y, eye_cz). Y-extent
    // = face_eye_recess_d * 2 so the cutter reaches from disc_floor_y - rec
    // to disc_floor_y + rec. The +Y half is outside the panel (no harm);
    // the -Y half cuts the recess into the panel.
    translate([cx, disc_floor_y, face_eye_cz])
        scale([face_eye_w / 2, face_eye_recess_d, face_eye_h / 2])
            sphere(r = 1, $fn = 64);
}

// ===== Asymmetric hooked beak =====
//
// Hull of 4 control points forming a wedge with:
//   - flat top (two base corners) embedded inside the panel
//   - wider base in X at the top
//   - narrowing toward the tip in X
//   - tip projecting forward in +Y (face_beak_tip_fwd) and down in -Z
//   - slight x-lean (+1mm offset) on the tip for asymmetry
//
// Forward hook curl is suggested by placing the tip's +Y at face_beak_proud_max
// and adding a small "hook" sphere just above the tip on the +Y side.

module beak_emboss() {
    cx = cradle_w_shelf / 2;
    panel_front_y = wall_thickness + panel_convexity;  // ≈ 6
    // Top of the beak embeds INSIDE the panel material PAST the disc
    // recess, so the disc carve doesn't sever the beak from the panel.
    // disc_floor_y = panel_front_y - face_disc_depth_max ≈ 4.5; embed
    // 1mm deeper than that → 3.5.
    top_y_back = panel_front_y - face_disc_depth_max - 1.0;  // ≈ 3.5
    // Narrow top, sitting inside the disc, at top_z
    top_left  = [cx - face_beak_top_w / 2, top_y_back, face_beak_top_z];
    top_right = [cx + face_beak_top_w / 2, top_y_back, face_beak_top_z];
    // Wider band a little below the top (gives the bulged silhouette)
    band_z = face_beak_top_z - (face_beak_top_z - face_beak_tip_z) * 0.4;
    band_y = panel_front_y + 1.5;
    band_left  = [cx - face_beak_base_w / 2, band_y, band_z];
    band_right = [cx + face_beak_base_w / 2, band_y, band_z];
    // Tip: forward and down, with the +1mm asymmetric x-lean
    tip = [cx + face_beak_x_lean, panel_front_y + face_beak_proud_max, face_beak_tip_z];

    hull() {
        translate(top_left)   sphere(r = 0.6, $fn = 24);
        translate(top_right)  sphere(r = 0.6, $fn = 24);
        translate(band_left)  sphere(r = 0.8, $fn = 24);
        translate(band_right) sphere(r = 0.8, $fn = 24);
        translate(tip)        sphere(r = 1.0, $fn = 24);
    }
    // Hook: a small bulge just above and forward of the tip, suggesting
    // the curved-down hook of a raptor beak
    hook_z = face_beak_tip_z + 3;
    hook_y = panel_front_y + face_beak_proud_max - 0.5;
    translate([cx + face_beak_x_lean * 0.5, hook_y, hook_z])
        sphere(r = 1.6, $fn = 24);
}

// ===== Complete back panel =====
//
// Body, with the heart-shaped facial disc carved into the +Y face, and
// the eye sockets carved into the disc floor. Beak protrudes forward.
module back_panel() {
    difference() {
        back_panel_body_raw();
        facial_disc_cutter();
        eye_socket_cutter(-face_eye_cx_offset);
        eye_socket_cutter( face_eye_cx_offset);
    }
    beak_emboss();
}

// ===== Ear tufts — splayed feather clumps =====
//
// Each tuft = 3 hulled feather profiles. Profiles are vertical ellipsoids
// tilted OUTWARD (in +X for right tuft, -X for left), with NO Y-direction
// tilt and NO forward sweep. Each feather's base sits on the rounded panel
// top and dips slightly INTO the panel to produce a smooth base blend.

// Compute the panel-top Z at a given X (relative to panel center x=cradle_w_shelf/2).
function panel_top_z_at_x(dx_from_center) =
    let(arc_cy = back_panel_top_center_z - back_panel_arc_r)
    (abs(dx_from_center) <= cradle_w_printer / 2)
        ? arc_cy + sqrt(max(0, pow(back_panel_arc_r, 2) - pow(dx_from_center, 2)))
        : back_panel_top_corner_z;

// Build a single feather profile — an ellipsoid tilted OUTWARD by `tilt`
// degrees from vertical, anchored so its base sits at z_base (on the panel
// top) and its tip rises h above z_base.
//
// The ellipsoid's local long axis is Z (height); we rotate around the Y
// axis so the tilt is purely in the X-Z plane (outward lean only). The
// feather's center is placed half-h above z_base in its tilted frame so
// the base sits right on the panel top.
//
// w = X-width at base (untilted), h = Z-height (long axis), yd = Y-depth.
module tuft_feather(cx, cy, z_base, w, h, yd, tilt_deg, outer_sign) {
    // Tilt direction in the X-Z plane: rotation about Y means +rot_y tilts
    // the +Z axis toward +X. For a left tuft (outer_sign = -1) we need the
    // top to lean -X, so use -tilt_deg. For right tuft, +tilt_deg.
    rot_y = outer_sign * tilt_deg;
    // Compute the offset that puts the base (-Z end of the local ellipsoid)
    // at z_base. In the local frame, the ellipsoid spans [-h/2, +h/2] along
    // its long axis. After tilt, its base maps to a point shifted in X by
    // (h/2) * sin(tilt) and in Z by -(h/2) * cos(tilt) FROM the center.
    // So the center should sit at:
    //   center_x = cx + (h/2) * sin(rot_y_deg)        (rotation about Y)
    //   center_z = z_base + (h/2) * cos(rot_y_deg)
    // But sign care needed: rotate([0, rot_y, 0]) on a point at +Z maps to
    //   x' = z * sin(rot_y), z' = z * cos(rot_y).
    // With rot_y > 0, +Z rotates toward +X. We want the TIP to lean outward
    // (outer direction). For left tuft (outer = -X), we want the tip at -X
    // → rot_y must be negative for left → outer_sign * tilt_deg with
    // outer_sign = -1 for left. Confirmed above.
    // The base of the ellipsoid is the point at -Z in the local frame.
    // Under rotate Y > 0: -Z maps to (-z * sin(rot_y), 0, -z * cos(rot_y))
    //   = (-(h/2)*sin(rot_y), 0, -(h/2)*cos(rot_y))
    // So to place the base at world (cx, *, z_base):
    //   center_x_world = cx - (-(h/2)*sin(rot_y)) = cx + (h/2)*sin(rot_y)
    //   wait — center is at world (cx_world, *, z_world). After rotation,
    //   the base (local -Z end) lands at center_world + R * (-Z * h/2).
    //   = (cx_world + (h/2)*sin(rot_y)*(-1)*(-1), z_world + (-1)*(h/2)*cos(rot_y))
    //   Cleanest: just compute where we want the center.
    // We want the BASE at world (cx, cy, z_base). The base is the -Z end of
    // the unrotated ellipsoid scaled by (w/2, yd/2, h/2). Pre-rotation the
    // -Z end is at local (0, 0, -h/2). After rotate([0, rot_y, 0]) about
    // origin, the point (0,0,-h/2) goes to (-(h/2)*sin(rot_y), 0, -(h/2)*cos(rot_y)).
    // We translate by (center_x_world, center_y_world, center_z_world). So:
    //   base_world = center_world + (-(h/2)*sin(rot_y), 0, -(h/2)*cos(rot_y))
    //   center_world = base_world - (-(h/2)*sin(rot_y), 0, -(h/2)*cos(rot_y))
    //                = base_world + ((h/2)*sin(rot_y), 0, (h/2)*cos(rot_y))
    // Where base_world = (cx, cy, z_base). We dip the base slightly INTO
    // the panel top so the union with the panel reads as a soft blend
    // (approximates the r=4 base fillet). Dip ≈ 2mm.
    base_dip = 2;
    bx = cx;
    by = cy;
    bz = z_base - base_dip;
    cx_w = bx + (h/2) * sin(rot_y);
    cy_w = by;
    cz_w = bz + (h/2) * cos(rot_y);

    translate([cx_w, cy_w, cz_w])
        rotate([0, rot_y, 0])
            scale([w / 2, yd / 2, h / 2])
                sphere(r = 1, $fn = 32);
}

// One full tuft: 3 feathers, hulled together so the silhouette reads as a
// splayed clump rather than three separate spikes. Per modeler-notes-v2,
// hull is preferred for smooth blend; if the hull blob looks too smooth,
// switch to union (keep this module's flag local).
module ear_tuft(left_side = true) {
    outer_sign = left_side ? -1 : +1;

    // Anchor: middle feather sits at x = ±tuft_center_x_offset from panel
    // center. Inner and outer feathers flank it by ~7mm so the three bases
    // span ~30mm overall (matches tuft_total_footprint_w in the brief).
    panel_cx = cradle_w_shelf / 2;
    middle_cx = panel_cx + outer_sign * tuft_center_x_offset;
    inner_cx  = panel_cx + outer_sign * (tuft_center_x_offset - 7);
    outer_cx  = panel_cx + outer_sign * (tuft_center_x_offset + 7);

    // Y center: tuft sits centered on the panel front-to-back. The panel
    // is wall_thickness + panel_convexity = 6mm thick at the top center.
    // Center the tuft at Y = (wall_thickness + panel_convexity) / 2 = 3,
    // so the feather Y-extent fits inside [0, wall_thickness + panel_convexity]
    // with the Y-half-depth (3mm) just reaching both faces. This keeps the
    // tuft inside the cradle's Y bounding box (no tuft extending past Y=0
    // — the back wall — into the wall plane).
    cy = (wall_thickness + panel_convexity) / 2;  // = 3

    // Per-feather z_base = panel-top Z at that X
    inner_z  = panel_top_z_at_x(inner_cx  - panel_cx);
    middle_z = panel_top_z_at_x(middle_cx - panel_cx);
    outer_z  = panel_top_z_at_x(outer_cx  - panel_cx);

    hull() {
        tuft_feather(inner_cx,  cy, inner_z,  tuft_inner_w,  tuft_inner_h,  tuft_inner_yd,  tuft_inner_tilt,  outer_sign);
        tuft_feather(middle_cx, cy, middle_z, tuft_middle_w, tuft_middle_h, tuft_middle_yd, tuft_middle_tilt, outer_sign);
        tuft_feather(outer_cx,  cy, outer_z,  tuft_outer_w,  tuft_outer_h,  tuft_outer_yd,  tuft_outer_tilt,  outer_sign);
    }
}

// ===== Cable slot cutter =====

module cable_slot_cutter() {
    translate([cable_slot_cx - cable_slot_w / 2, -0.1, -0.01])
        cube([cable_slot_w, wall_thickness + 0.2, cable_slot_h]);
}

// ===== Host-object proxy (round 2 NEW — for use-state renders) =====
//
// Renders a 78×152×143 box at the printer's installed position. Excluded
// from STL by default (render_with_host=false); enable for PNG renders
// that show the printer in place via `--param render_with_host=true`.
//
// Installed position math (derived from spec params):
//   pocket interior origin (X) = side_step + (cradle_w_printer - pocket_w)/2 = 11 + 3 = 14
//   pocket interior origin (Y) = wall_thickness = 3
//   pocket floor                = base_thickness = 4
//   printer is centered in the 80×154 pocket with 1mm XY clearance per side
//   → printer X origin = 14 + 1 = 15
//     printer Y origin = 3  + 1 = 4
//     printer Z origin = 4
module host_object_proxy(show = false) {
    if (show) {
        printer_w = 78;
        printer_d = 152;
        printer_h = 143;
        clr_xy    = 1;  // 1mm clearance per side in pocket
        pocket_x0 = side_step + (cradle_w_printer - pocket_w) / 2;
        pocket_y0 = wall_thickness;
        x0 = pocket_x0 + clr_xy;
        y0 = pocket_y0 + clr_xy;
        z0 = base_thickness;
        // Use color() to render the proxy in a visually distinct gray.
        // Note: % (background) modifier is omitted in --render mode, so we
        // use color() instead. The proxy is excluded from STL export by
        // the render_with_host=false default; STLs MUST keep that default.
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
            tray_shelf_upper_walls();
            back_panel();
            ear_tuft(left_side = true);
            ear_tuft(left_side = false);
            corner_feet();
        }
        cable_slot_cutter();
    }
}

cradle();
host_object_proxy(show = render_with_host);

// ===== Dimension report =====
report_dimensions(cradle_w_shelf, cradle_total_d, cradle_total_h, "cradle");
report_dimensions(cradle_w_shelf, cradle_total_d, cradle_body_h, "cradle_body_no_tufts");
report_dimensions(cradle_w_printer, printer_section_d, low_wall_h, "cradle_printer_section");
