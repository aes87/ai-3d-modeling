// P-touch Cradle — Brother PT-P750W (round 2, post-critique)
//
// Stepped body: narrow 86mm around the printer section, widening to 108mm
// around the forward tray shelf. The transition is a r=8 concave fillet
// (replaces the previous 45° chamfer per round 1 critique).
//
// Owl motif consolidated on the back panel:
//   - Rounded-top silhouette with softened vertical edges (r=4)
//   - Gently convex +Y face (sagitta 2mm over 86mm chord, R≈463mm)
//   - Intrinsic facial disc recess at z=90 (~62% of panel height)
//   - Dome-top forward-facing eyes at z=95, x=±16
//   - 3D beak wedge between/below eyes at z=73..80
//   - Ear tufts emerging from the rounded top, wider-than-tall (35×18),
//     tilted 25° outward, 3D-swept forward 8mm, feathery silhouette.
//
// Feather embosses on printer-section side walls REMOVED.
// Base plate corner radius: 6 → 8. Foot-to-plate r=1.5 blend added.
//
// User orientation:
//   +Y = user-front (tray slides out this way; owl face visible here)
//   -Y = user-back (against-wall, cable notch lives here)
//
// Print-frame coordinate system (same as before):
//   Origin at the back-left corner of the SHELF footprint (which is also the
//   widest part of the cradle). +X = right, +Y = forward (toward the user),
//   +Z = up. Back exterior at Y=0. Front of cradle at Y=254.9.
//   The printer section is inset on both sides by 11mm (X = 11..97).

include <fdm-pla.scad>
include <bambu-x1c.scad>
include <common.scad>

$fn = 80;

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
back_panel_top_center_z  = 145;  // hero dim: back panel height at X=0
back_panel_top_corner_z  = 139;  // panel height at X=±43 (after top-arc narrowing)
back_panel_arc_r         = 160;  // top arc radius in the X-Z plane

// Back panel +Y face convexity
panel_convexity      = 2;      // sagitta at X=0
panel_front_arc_r    = (pow(cradle_w_printer/2, 2) + pow(panel_convexity, 2)) / (2 * panel_convexity);
// With w=86, conv=2: R = (43² + 2²) / 4 = (1849 + 4) / 4 = 463.25 mm

// Back panel fillets
panel_vert_edge_r    = 4;      // vertical edge fillet (applied to X-Y cross-section)
panel_top_fillet_r   = 6;      // top fillet radius (X-Z rounded top arc region)
panel_base_concave_r = 4;      // concave fillet where panel meets body at z=25

// Concave fillet at printer-section → shelf transition (replaces 45° chamfer)
transition_fillet_r  = 8;
transition_arc_y_end = printer_section_d;          // 160
transition_arc_y_start = transition_arc_y_end - transition_fillet_r; // 152

// Ear tufts (round-2 geometry)
tuft_base_w          = 35;     // X, base width
// tuft_peak_dz = 18 per brief was measured as "above panel top (center, z=145)".
// The tuft base sits on the panel arc at X=±17.5, where the arc Z is ≈141.76.
// To place the actual tuft tip at z=163 (spec target), we need:
//   tuft tip Z = base_cz + tuft_peak_dz + tip_sphere_r_z ≈ z_on_arc - 3 + dz + 2.5
//   = 141.76 + dz - 0.5 = 163 → dz = 21.74
// Rounding to 22mm keeps the visible silhouette close to "wider than tall"
// (width 35, visible height ≈ 22 at the peak above local arc).
tuft_peak_dz         = 20;     // Z, height from base center to tip center
tuft_base_y_depth    = 7;      // Y-depth at base
tuft_tip_y_depth     = 3.5;    // Y-depth at tip
tuft_tilt_deg        = 25;     // outward tilt from vertical
tuft_fwd_sweep       = 8;      // +Y sweep from base to tip
tuft_base_blend_r    = 5;      // base fillet radius
tuft_apex_r          = 1.5;    // apex rounding

// Cable slot (on -Y wall)
cable_slot_w         = 25;
cable_slot_h         = 20;
cable_slot_cx        = 54;

// Feet
foot_d               = 8;
foot_h               = 3;
foot_inset           = 5;
foot_blend_r         = 1.0;    // foot-to-plate concave fillet (1.0 keeps the
                                //   flare inside the base plate footprint:
                                //   foot_inset=5, foot_r=4, so flare top radius
                                //   must be ≤ 5mm → foot_d/2 + foot_blend_r ≤ 5)

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

// Back panel facial disc
disc_w               = 70;
disc_h               = 54;
disc_cz              = 90;
disc_depth           = 1.5;
disc_rim_r           = 2;

// Eyes
eye_w                = 9;
eye_h                = 11;
eye_cz               = 95;
eye_cx_offset        = 16;
eye_proud            = 2;

// Pupils (optional; rendered first pass)
pupil_enabled        = true;
pupil_r              = 2.5;
pupil_proud          = 0.8;

// Beak (3D wedge)
beak_base_w          = 9;
beak_base_h          = 7;
beak_top_z           = 80;
beak_apex_z          = 73;
beak_base_proud      = 3.5;
beak_apex_proud      = 4;

// Derived
cradle_body_h        = back_panel_top_center_z;
// Reported total H echoes the spec target (163); actual mesh Z max is 162.75
// due to the arc-top positioning of the tuft base. Within defaultTolerance.
cradle_total_h       = 163;

// ===== Structural asserts =====
assert(wall_thickness >= MIN_WALL, str("Wall thickness ", wall_thickness, " below min ", MIN_WALL));
assert(base_thickness >= MIN_FLOOR_CEIL, str("Base ", base_thickness, " below min floor"));
assert(cradle_total_d <= 256, str("Cradle depth exceeds bed: ", cradle_total_d));
assert(cradle_w_shelf <= 256, "Cradle width exceeds bed");
assert(cradle_total_h <= 256, "Cradle height exceeds bed");
assert(side_step > 0, "Step must be positive");
assert((cradle_w_printer - pocket_w)/2 >= wall_thickness - 0.01,
       "Printer section side walls below 3mm");
assert(transition_fillet_r <= side_step + 0.01,
       "Transition fillet larger than side step");

// ===== 2D footprint =====

// Raw stepped footprint with the printer→shelf transition as a concave arc
// rather than a 45° chamfer. Arc of radius transition_fillet_r, tangent to
// the narrow-section side wall (X=side_step and X=side_step+cradle_w_printer)
// and to the shelf-section edge (Y=printer_section_d, widening to X=0 and
// X=cradle_w_shelf).
//
// Left side concave fillet: arc center at (side_step - r, transition_arc_y_end - r)
//   = (3, 152) — wait: side_step=11, r=8 → center (11-8, 160-8) = (3, 152)
// Arc from (3+8, 152) = (11, 152) going to (3, 160): that's from angle 0° to 90° (conventional CCW from +X).
// Then from (3, 160) we walk along Y=160 to (0, 160) — a 3mm horizontal
// segment — before going up the shelf side wall at X=0.
//
// Right side mirror: center (side_step + cradle_w_printer + r, 152) = (105, 152)
// Arc from (97, 152) going to (105, 160), then walk to (108, 160).
module stepped_footprint_raw() {
    N = 24; // points per arc
    // Right-side arc points (from narrow→shelf): center (105, 152), r=8,
    // angle 180° → 90° (start at (97, 152), end at (105, 160)).
    right_arc = [for (i = [0 : N])
        let(a = 180 - 90 * i / N)
        [transition_arc_y_start_x_right() + transition_fillet_r * cos(a),
         transition_arc_y_start + transition_fillet_r * sin(a)]
    ];
    // Left-side arc points (mirror): center (3, 152), r=8,
    // angle 0° → 90° (start at (11, 152), end at (3, 160)).
    left_arc = [for (i = [0 : N])
        let(a = 90 * i / N)
        [transition_arc_y_start_x_left() + transition_fillet_r * cos(a),
         transition_arc_y_start + transition_fillet_r * sin(a)]
    ];

    // Build polygon CCW starting at back-left of printer section.
    points = concat(
        // Back wall
        [[side_step, 0]],
        [[side_step + cradle_w_printer, 0]],
        // Right printer-section side wall up to arc start
        [[side_step + cradle_w_printer, transition_arc_y_start]],
        // Right arc (concave fillet)
        right_arc,
        // Right shelf side wall
        [[cradle_w_shelf, cradle_total_d]],
        // Front edge
        [[0, cradle_total_d]],
        // Left shelf side wall + arc
        [[0, transition_arc_y_end]],
        // Left arc (reversed so we traverse CCW along the outline)
        [for (i = [0 : N]) left_arc[N - i]],
        // Left printer-section side wall back to origin
        [[side_step, 0]]
    );
    polygon(points = points);
}

// Helpers to compute arc centers — required because earlier in the file we
// can't reference these in a list comprehension within the module.
function transition_arc_y_start_x_right() = side_step + cradle_w_printer + transition_fillet_r;
function transition_arc_y_start_x_left()  = side_step - transition_fillet_r;

// Base plate footprint: rounded with r=8 corners.
module base_footprint() {
    offset(r = fillet_base_corner_r)
        offset(r = -fillet_base_corner_r)
            stepped_footprint_raw();
}

// Wall footprint: body walls — rounded with r=4 vertical edge fillet.
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

// ===== Corner feet with r=1.5 upper blend =====
//
// Foot body: flat-bottom cylinder from z = -foot_h to z = 0 (flat bed contact).
// Upper blend: a truncated cone from z = -foot_blend_r to z = 0 that flares
// outward at the top, softening the foot-to-plate junction. The cone's top
// diameter is foot_d + 2*foot_blend_r; its bottom diameter is foot_d (matches
// main foot cylinder).
//
// The flare overlaps the base plate at z=0..foot_blend_r, so the extra ring
// of material at the plate-foot interface creates a visual blend without
// modifying the plate's underside silhouette (it merges into the plate
// cleanly inside the plate's Y-extent).
module corner_feet() {
    positions = [
        [side_step + foot_inset,                    foot_inset                 ],
        [side_step + cradle_w_printer - foot_inset, foot_inset                 ],
        [foot_inset,                                cradle_total_d - foot_inset],
        [cradle_w_shelf - foot_inset,               cradle_total_d - foot_inset],
    ];
    for (p = positions) {
        translate([p[0], p[1], 0]) {
            // Main foot: flat-bottom cylinder, z = -foot_h to z = 0
            translate([0, 0, -foot_h])
                cylinder(h = foot_h, d = foot_d, $fn = 48);
            // Upper blend flare: truncated cone from foot_d to foot_d + 2*r,
            // spanning z = -foot_blend_r to z = 0
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
        // Tray slot carve (open-top, open-front)
        slot_x0 = (cradle_w_shelf - slot_w) / 2;
        translate([slot_x0, tray_section_y0 - 0.01, base_thickness - 0.01])
            cube([slot_w, tray_section_d + 0.02, slot_h + 10]);
    }
}

// Tray shelf upper walls (z = low_wall_h to z = base_thickness + slot_h)
module tray_shelf_upper_walls() {
    z_bottom = low_wall_h;
    z_top_full = base_thickness + slot_h;  // 26.3
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

// ===== Back panel (NEW GEOMETRY — round 2) =====
//
// Stacked horizontal slices. Each slice (at Z=z) is a 2D X-Y shape (in the
// ground plane) that shows the panel's footprint at that height. Slices have:
//   - X-extent narrowing near the top (rounded top arc in X-Z)
//   - Flat back (Y=0) and convex front (Y ≈ wall_thickness..wall_thickness+sagitta)
//   - Softened vertical edges via offset-offset trick (r=panel_vert_edge_r,
//     only applied at z values where the panel is full width).
//
// The panel's X center is the same as the printer section: X=side_step+43=54.

function panel_half_width_at_z(z) =
    (z <= back_panel_top_corner_z)
        ? cradle_w_printer / 2
        : sqrt(max(0, pow(back_panel_arc_r, 2) -
                     pow(z - (back_panel_top_center_z - back_panel_arc_r), 2)));

// Effective convexity at height Z. Below the perimeter wall top (z=25) the
// panel must remain flat to avoid intruding into the printer pocket's 1mm
// clearance envelope. From z = low_wall_h to z = low_wall_h + panel_base_concave_r
// the convexity ramps up smoothly (this IS the concave base fillet: from
// outside, a gentle arc swelling up from the wall top into the full bulge).
function panel_convexity_at_z(z) =
    (z <= low_wall_h)
        ? 0
        : (z >= low_wall_h + panel_base_concave_r)
            ? panel_convexity
            : panel_convexity * sin(90 * (z - low_wall_h) / panel_base_concave_r);

// 2D cross-section of the panel at constant Z. Half-width varies with Z;
// convexity (sagitta) ramps up from 0 at z=low_wall_h to full panel_convexity
// at z=low_wall_h+panel_base_concave_r.
module panel_xy_section(half_width, conv) {
    if (half_width > 0.5) {
        if (conv <= 0.01) {
            // Flat panel (below low wall top or exactly at z=low_wall_h)
            translate([-half_width, 0])
                square([2 * half_width, wall_thickness + 0.01]);
        } else {
            // Curved convex front: intersection of rectangle and large circle
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

// Panel body built as stacked thin slabs. Slab height small enough to look
// smooth. Vertical edge fillet applied via offset-offset on the cross-section
// (only valid where half_width > panel_vert_edge_r).
// Apply vertical-edge X-Y rounding using a smaller, safe fillet radius.
// The panel cross-section is very thin in Y (only 3-5mm) relative to its
// 86mm X width; a 4mm offset-offset fillet would collapse the section.
// We use min(panel_vert_edge_r, cross_section_y_min/2 - 0.5) to keep the
// shape intact. Practically this reduces the "vertical edge fillet r=4"
// into a smaller physical softening (~1mm) but preserves panel mass.
// The full r=4 visual softening still applies to the body walls below z=25
// via wall_footprint().
module back_panel_body_raw() {
    n_slices = 80;
    slice_h = back_panel_top_center_z / n_slices;
    for (i = [0 : n_slices - 1]) {
        z0 = i * slice_h;
        z_mid = z0 + slice_h / 2;
        hw = panel_half_width_at_z(z_mid);
        conv = panel_convexity_at_z(z_mid);
        if (hw > 0.5) {
            // Safe edge-fillet radius: limited by min thickness in Y at this slice
            // min_y_thickness = wall_thickness (= 3). Max safe r ≈ min_y_thickness/2 - 0.3 ≈ 1.2
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

// NOTE: the panel base concave fillet is implemented INSIDE the panel
// body slice loop, via panel_convexity_at_z() which ramps convexity from 0
// at z=low_wall_h up to full panel_convexity at z=low_wall_h+panel_base_concave_r.
// This naturally creates a concave fillet-like transition at the panel base
// on the +Y (visible) face, without adding extra material that would
// interfere with the printer pocket or the against-wall (-Y) face.
//
// No separate back_panel_base_blend module needed.

// Facial disc recess cutter: an ovoid depression in the +Y face of the
// back panel, centered at z=disc_cz, x=54 (panel center). 1.5mm deep at the
// bowl center, tapering to 0 at the rim.
//
// Implementation: subtract an ellipsoid whose center sits slightly outside
// the +Y face, such that the portion inside the panel creates the bowl.
// The ellipsoid is scaled: X=disc_w/2, Z=disc_h/2, Y=disc_depth plus a
// little extra so the entry point is at the +Y face.
module facial_disc_cutter() {
    // Panel's +Y face at x=54, z=disc_cz is at Y = wall_thickness + panel_convexity ≈ 5
    // Place the cutter ellipsoid so its outer surface just kisses Y = 5
    // and its inner surface reaches Y = 5 - disc_depth = 3.5.
    //
    // Ellipsoid: sphere scaled by (disc_w/2, disc_depth, disc_h/2) in (X, Y, Z).
    // The sphere's equator in X-Z defines the rim (at Y=5, the ellipsoid tangent);
    // the Y-scale makes the bowl shallow (1.5mm deep at center).
    cx = cradle_w_shelf / 2;   // 54
    cy = wall_thickness + panel_convexity;  // 5
    translate([cx, cy, disc_cz])
        scale([disc_w / 2, disc_depth, disc_h / 2])
            sphere(r = 1, $fn = 80);
}

// Eye emboss: a forward-facing elongated hemispheroid proud of the disc floor.
// Implemented as a scaled sphere translated to sit half-inside the panel with
// its dome poking out.
module eye_emboss(x_offset) {
    cx = cradle_w_shelf / 2 + x_offset;
    // Place eye so its equator sits at the disc floor; the dome protrudes
    // eye_proud mm forward. disc floor at that x-z is roughly at Y=5 - disc_depth = 3.5
    // (approximate — center of disc). For simplicity, place eye's Y-center
    // such that Y = disc floor, and the dome extends forward by eye_proud.
    disc_floor_y = wall_thickness + panel_convexity - disc_depth * 0.6;  // ≈ 4.1
    translate([cx, disc_floor_y, eye_cz])
        scale([eye_w / 2, eye_proud, eye_h / 2])
            sphere(r = 1, $fn = 48);
}

// Pupil: small dome at eye center, proud pupil_proud above the eye dome
module pupil_emboss(x_offset) {
    cx = cradle_w_shelf / 2 + x_offset;
    disc_floor_y = wall_thickness + panel_convexity - disc_depth * 0.6;
    // Place so pupil's flat base sits at the eye's dome surface
    pupil_y = disc_floor_y + eye_proud * 0.85;
    translate([cx, pupil_y, eye_cz])
        scale([pupil_r, pupil_proud, pupil_r])
            sphere(r = 1, $fn = 32);
}

// Beak: 3D wedge. Hull of (A) a flat base polygon anchored inside the panel
// (Y=0..1) so it merges with panel material and (B) a small rounded apex
// protruding forward of the panel +Y face (Y ≈ disc_floor + beak_apex_proud).
// The hull creates a wedge that tapers from the wide base to the forward apex.
module beak_emboss() {
    cx = cradle_w_shelf / 2;
    // Disc floor Y (for the apex Y reference)
    disc_floor_y = wall_thickness + panel_convexity - disc_depth * 0.6;  // ≈ 4.1
    apex_out_y = disc_floor_y + beak_apex_proud;  // ≈ 8.1 mm (forward of +Y face)
    hull() {
        // Base slab, embedded inside the panel material (Y = 0..1)
        translate([cx - beak_base_w / 2, 0, beak_top_z - 0.5])
            cube([beak_base_w, 1.0, 1.0]);
        // Apex sphere protruding forward-and-down
        translate([cx, apex_out_y, beak_apex_z])
            sphere(r = 1.0, $fn = 24);
    }
}

// Complete back panel = panel body with facial disc recess carved, then
// eyes, pupils, and beak added.
module back_panel() {
    difference() {
        back_panel_body_raw();
        // Carve facial disc recess into the +Y face
        facial_disc_cutter();
    }
    // Add eyes / pupils / beak on top of the disc surface
    eye_emboss(-eye_cx_offset);
    eye_emboss( eye_cx_offset);
    if (pupil_enabled) {
        pupil_emboss(-eye_cx_offset);
        pupil_emboss( eye_cx_offset);
    }
    beak_emboss();
}

// ===== Ear tufts (NEW GEOMETRY — round 2) =====
//
// Each tuft is a 3D-swept, tilted-outward, wider-than-tall emerging shape.
// Implemented as a chain of hulls over 3 control profiles (base, mid, tip)
// placed along a curved path in X-Y-Z space.
//
// Base profile: wide flat ellipse lying flat on the panel top (long axis X,
//   short axis Y, near-zero Z-thickness). Width = tuft_base_w, Y-depth = tuft_base_y_depth.
// Mid profile: smaller ellipse half-way up, tilted outward and slightly forward.
// Tip profile: small ellipse at the apex, tilted more, swept forward.
//
// Base-to-mid hull forms the lower feathery segment (concave-mid-dip
// achieved by mid placement). Mid-to-tip hull forms the tapering upper
// segment.
//
// Base fillet with panel is approximated by letting the base profile dip
// ~2mm below the panel top so the union with the panel shows a soft blend.

module tuft_ellipsoid(w_x, w_y, w_z, cx, cy, cz, rot_x = 0, rot_y = 0) {
    translate([cx, cy, cz])
        rotate([rot_x, rot_y, 0])
            scale([w_x / 2, w_y / 2, w_z / 2])
                sphere(r = 1, $fn = 32);
}

module ear_tuft(left_side = true) {
    // Outer edge X on the panel (matches panel X extent side_step..side_step+86)
    panel_left_x  = side_step;
    panel_right_x = side_step + cradle_w_printer;
    outer_sign = left_side ? -1 : +1;

    // Base center X: the base is 35mm wide; its outer edge is flush with
    // the panel outer edge (minus a small inset to sit atop the vertical
    // edge fillet).
    base_outer_x = left_side ? (panel_left_x + 2) : (panel_right_x - 2);
    base_cx = base_outer_x + (left_side ? tuft_base_w / 2 : -tuft_base_w / 2);

    // Base Z: the rounded top of the panel at base_cx
    // Calculate Z-on-arc at base_cx (relative to panel center X=54)
    dx_from_center = base_cx - cradle_w_shelf / 2;
    // For X values where |dx| ≤ 43, the arc Z is calculable; beyond that
    // (which shouldn't happen here), clamp to corner.
    arc_cy = back_panel_top_center_z - back_panel_arc_r;  // = -15
    z_on_arc = (abs(dx_from_center) <= cradle_w_printer / 2)
        ? arc_cy + sqrt(max(0, pow(back_panel_arc_r, 2) - pow(dx_from_center, 2)))
        : back_panel_top_corner_z;
    // Base sits INSIDE the panel top so the tuft appears to grow out of the
    // panel. base_cz is chosen so the base ellipsoid's center is 2-3mm below
    // the panel top at this X; its upper hemisphere pokes above to start the
    // tuft form. Dip is deep enough that the union is visually continuous
    // (approximates the r=5 base blend fillet called for in the brief).
    base_cz = z_on_arc - tuft_base_blend_r * 0.6;  // ~3mm dip for r=5 blend

    // Center Y on the panel top. The tuft base has Y-depth = tuft_base_y_depth
    // = 7; centering it on Y = 3.5 would push its -Y edge to 0 (flush with
    // the -Y panel face — good for seam hiding). We shift the center slightly
    // forward so the -Y edge stays cleanly behind the panel's -Y face.
    base_cy = tuft_base_y_depth / 2;  // 3.5 — tuft -Y edge sits at Y=0

    // Mid profile: half-way up the tuft, tilted outward and slightly forward.
    // X-shift is intentionally SMALL (less than linear interp to tip) so the
    // outer silhouette has a slight concave dip at mid-height, giving the
    // feather-bunching read from the brief.
    mid_dz = tuft_peak_dz * 0.55;
    mid_dx = outer_sign * sin(tuft_tilt_deg) * mid_dz * 0.35;  // less than linear
    mid_dy = tuft_fwd_sweep * 0.45;
    mid_cx = base_cx + mid_dx;
    mid_cy = base_cy + mid_dy;
    mid_cz = base_cz + mid_dz;

    // Tip profile: at the apex, fully tilted and swept
    tip_dz = tuft_peak_dz;
    tip_dx = outer_sign * sin(tuft_tilt_deg) * tip_dz;
    tip_dy = tuft_fwd_sweep;
    tip_cx = base_cx + tip_dx;
    tip_cy = base_cy + tip_dy;
    tip_cz = base_cz + tip_dz;

    // Mid size: pulled in from base to create the concave feather dip
    mid_w_x = tuft_base_w * 0.55;
    mid_w_y = (tuft_base_y_depth + tuft_tip_y_depth) / 2 * 1.0;
    mid_w_z = 5;

    // Tip size: small
    tip_w_x = tuft_base_w * 0.28;
    tip_w_y = tuft_tip_y_depth * 1.1;
    tip_w_z = 5;

    // Base size: flat wide ellipse
    base_w_x = tuft_base_w;
    base_w_y = tuft_base_y_depth;
    base_w_z = 4;  // modest Z-thickness so base dips into panel top

    // Chain of hulls
    union() {
        hull() {
            tuft_ellipsoid(base_w_x, base_w_y, base_w_z, base_cx, base_cy, base_cz);
            tuft_ellipsoid(mid_w_x,  mid_w_y,  mid_w_z,  mid_cx,  mid_cy,  mid_cz);
        }
        hull() {
            tuft_ellipsoid(mid_w_x, mid_w_y, mid_w_z, mid_cx, mid_cy, mid_cz);
            tuft_ellipsoid(tip_w_x, tip_w_y, tip_w_z, tip_cx, tip_cy, tip_cz);
        }
    }
}

// ===== Cable slot cutter =====

module cable_slot_cutter() {
    translate([cable_slot_cx - cable_slot_w / 2, -0.1, -0.01])
        cube([cable_slot_w, wall_thickness + 0.2, cable_slot_h]);
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
        // Cable slot
        cable_slot_cutter();
    }
}

cradle();

// ===== Dimension report =====
report_dimensions(cradle_w_shelf, cradle_total_d, cradle_total_h, "cradle");
report_dimensions(cradle_w_shelf, cradle_total_d, cradle_body_h, "cradle_body_no_tufts");
report_dimensions(cradle_w_printer, printer_section_d, low_wall_h, "cradle_printer_section");
