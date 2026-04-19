// P-touch Catch Tray — removable kanban bin (round 2)
// Slides into the cradle's forward tray slot; catches auto-cut labels.
//
// Round 1 critique changes:
//   - Owl face DELETED from tray +Y wall (eyes, pupils, beak gone).
//     Motif consolidated onto the cradle back panel per id/brief.md.
//   - 45° scoop lip RESTORED across the upper 14mm of the 21.6mm front wall.
//   - Separate top-edge grip scallop NOT restored. Instead, an integrated
//     concave finger-grip is carved into the center of the scoop face
//     (30mm wide × 2.5mm deep). Grip + scoop are one feature, not two.
//
// Coordinate system:
//   Origin at back-left corner of tray floor bottom (exterior).
//   +X = right, +Y = forward (user-front), +Z = up.
//   Front wall exterior face at Y = ext_d (user-facing scoop).

include <fdm-pla.scad>
include <bambu-x1c.scad>
include <common.scad>

$fn = 80;

// ===== Parameters =====
int_w     = 100;    // interior width (X)
int_d     = 91;     // interior depth (Y)
int_h     = 20;     // interior height (Z)
wall_t    = 1.6;
floor_t   = 1.6;

ext_w     = int_w + 2*wall_t;     // 103.2
ext_d     = int_d + 2*wall_t;     // 94.2
ext_h     = int_h + floor_t;      // 21.6

fillet_vert_r = 3.0;   // tray exterior vertical edge fillets

// Scoop lip geometry (integrated with finger-grip)
scoop_base_h   = 7;     // lower 7mm of front wall stays vertical (structural)
scoop_h        = 14;    // upper 14mm tilts back at 45° (7 + 14 = 21.6)
scoop_angle    = 45;    // degrees from horizontal
// 45° from horizontal means the scoop face recedes 14mm in -Y between z=7 and z=21.6

// Integrated finger-grip dip in the center of the scoop
grip_w         = 30;    // width across the scoop face (X)
grip_depth     = 2.5;   // additional material removed at center of scoop
// Leading edge fillet
scoop_leading_edge_r = 2;

// ===== Structural asserts =====
assert(wall_t >= MIN_WALL, str("Tray wall ", wall_t, " below min ", MIN_WALL));
assert(floor_t >= MIN_FLOOR_CEIL, str("Tray floor ", floor_t, " below min floor"));
assert(ext_w <= 256 && ext_d <= 256 && ext_h <= 256, "Tray exceeds bed");
assert(scoop_base_h + scoop_h <= ext_h + 0.001, "Scoop geometry overshoots wall height");

// ===== 2D helpers =====

module rounded_rect(w, d, r) {
    translate([r, r])
        offset(r=r) square([w - 2*r, d - 2*r]);
}

// ===== Modules =====

// Tray shell: rectangular bin open on top, with 45° scoop on the upper portion
// of its +Y (user-front) face, and an integrated concave finger-grip dip in the
// center of the scoop. Back wall (-Y), left and right walls are full-height
// vertical. Front wall lower 7mm is vertical; upper 14mm is the scoop.
module tray_shell() {
    difference() {
        // Outer body: full rounded-rect shell at full height
        linear_extrude(height = ext_h)
            rounded_rect(ext_w, ext_d, fillet_vert_r);
        // Interior: remove the bin cavity
        int_r = max(fillet_vert_r - wall_t, 0.8);
        translate([wall_t, wall_t, floor_t])
            linear_extrude(height = int_h + 0.1)
                rounded_rect(int_w, int_d, int_r);
        // Scoop cutter: removes the upper 14mm of the front wall by slicing it
        // at 45° from horizontal. The cutter is a triangular prism in Y-Z
        // spanning the full tray width in X, placed at the front wall.
        scoop_cutter();
        // Integrated finger-grip dip: a concave trough carved into the scoop
        // face in the central 30mm of the tray width.
        finger_grip_cutter();
    }
}

// Scoop cutter: a wedge-shaped void that removes the top-outer portion of the
// front wall to create a 45° sloped face. Positioned so the lower 7mm of the
// front wall is untouched, the upper 14mm slopes back into the tray at 45°.
// The cut runs the full tray width in X (plus slop for clean boolean).
module scoop_cutter() {
    // Triangular profile in Y-Z:
    //   vertex A: (ext_d,         scoop_base_h)               -- bottom of scoop face, at outer wall
    //   vertex B: (ext_d + 2,     ext_h + 2)                  -- outside & above top (slop)
    //   vertex C: (ext_d - scoop_h, ext_h + 2)                -- inside start of cut at top (=ext_d-14)
    // All extruded in X across the full tray width plus slop.
    translate([-2, 0, 0])
        rotate([90, 0, 90])
            linear_extrude(height = ext_w + 4)
                polygon(points = [
                    [ext_d,                 scoop_base_h],
                    [ext_d + 2,             ext_h + 2],
                    [ext_d - scoop_h,       ext_h + 2],
                ]);
}

// Integrated finger-grip: a concave (cylindrical) dip carved into the scoop
// face in the central 30mm of the tray width. Depth 2.5mm perpendicular to
// the scoop face. Implementation: a cylinder whose axis is perpendicular to
// the scoop face, carving inward.
module finger_grip_cutter() {
    // Scoop face mid-point (in Y-Z plane):
    //   bottom of scoop at (Y=ext_d, Z=scoop_base_h)
    //   top of scoop at (Y=ext_d - scoop_h, Z=scoop_base_h + scoop_h) = (Y=ext_d-14, Z=21.6)
    //   midpoint = (Y=ext_d - scoop_h/2, Z=scoop_base_h + scoop_h/2) = (Y=ext_d-7, Z=14)
    // Face normal (outward): (sin45°, sin45°) = (0.707, 0.707) in Y-Z
    //
    // Carve a cylinder aligned with X-axis, positioned just outside the face
    // so its inner surface dips 2.5mm into the scoop face.
    // Cylinder radius chosen so its arc intersects the scoop face cleanly.
    // A radius of ~50mm gives a shallow concave arc (3mm depth across 30mm
    // chord: R ≈ (15² + 3²)/(2·3) = 39, use 50 for safety).
    //
    // We want chord = 30mm on the face, dip depth = 2.5mm.
    // R = (chord/2)² + depth²) / (2·depth) = (15² + 2.5²) / (2·2.5)
    //   = (225 + 6.25) / 5 = 46.25mm
    R = 46.25;
    // Midpoint of scoop face (Y, Z)
    mid_y = ext_d - scoop_h/2;    // ext_d - 7
    mid_z = scoop_base_h + scoop_h/2;  // 14
    // Outward normal direction from midpoint: (+Y, +Z) normalized, i.e. (0.707, 0.707)
    // Cylinder center is outside the face by (R - depth):
    offset_along_normal = R - grip_depth;
    cx_y = mid_y + offset_along_normal * cos(scoop_angle);   // +Y offset
    cx_z = mid_z + offset_along_normal * sin(scoop_angle);   // +Z offset
    // The cylinder's axis is along X. Its length must cover the grip width
    // (30mm) plus slop. Center the cylinder on the tray centerline (X = ext_w/2)
    // with length grip_w (not longer — so outside the 30mm chord the scoop is
    // untouched).
    translate([ext_w/2 - grip_w/2, cx_y, cx_z])
        rotate([0, 90, 0])
            cylinder(r = R, h = grip_w, $fn = 120);
}

// ===== Assembly =====

module tray() {
    tray_shell();
}

tray();

// ===== Dimension report =====
report_dimensions(ext_w, ext_d, ext_h, "tray");
