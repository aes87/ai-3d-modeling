// P-touch Catch Tray — removable kanban bin
// Slides into the cradle's forward tray slot; catches auto-cut labels.
// Owl face motif on front wall: two eye embosses + pupils + beak.
//
// Coordinate system:
//   Origin at back-left corner of the tray floor bottom (exterior).
//   +X = right, +Y = forward (toward the user), +Z = up.
//   Front wall exterior face at Y = ext_d (user-facing owl face).
//
// Revision: shortened from 41.6 mm tall to 21.6 mm tall exterior. Removed
// 45° scoop, top-edge grip scallop, and scoop leading-edge fillet. Owl face
// enlarged to fill the shorter front wall.

include <fdm-pla.scad>
include <bambu-x1c.scad>
include <common.scad>

$fn = 80;

// ===== Parameters =====
int_w     = 100;    // interior width (X)
int_d     = 91;     // interior depth (Y)
int_h     = 20;     // interior height (Z)  — was 40, halved
wall_t    = 1.6;
floor_t   = 1.6;

ext_w     = int_w + 2*wall_t;     // 103.2
ext_d     = int_d + 2*wall_t;     // 94.2
ext_h     = int_h + floor_t;      // 21.6

fillet_vert_r = 3.0;   // tray exterior vertical edge fillets (kept)

// Owl face — scaled up to fit the shorter front wall.
eye_r        = 9;     // up from 8; clamped from 10 for vertical fit on 21.6 mm wall
eye_raise    = 2;     // up from 1.5
eye_cz       = 11;    // ≈ mid-height of 21.6 mm wall (adjusted from 13 to fit r=9)
eye_cx_off   = 22;    // from tray centerline (unchanged)

pupil_r      = 4;     // up from 3
pupil_extra  = 2;     // additional raise beyond eye (total proud = 4)

beak_w       = 8;     // up from 6
beak_h       = 8;     // up from 6
beak_raise   = 2.5;   // up from 2
beak_top_z   = 9;     // top of triangle (below eyes)
beak_apex_z  = 1;     // apex near the floor (beak_top_z - beak_h)

// ===== Structural asserts =====
assert(wall_t >= MIN_WALL, str("Tray wall ", wall_t, " below min ", MIN_WALL));
assert(floor_t >= MIN_FLOOR_CEIL, str("Tray floor ", floor_t, " below min floor"));
assert(ext_w <= 256 && ext_d <= 256 && ext_h <= 256, "Tray exceeds bed");
// Owl face fits within front wall height
assert(eye_cz + eye_r <= ext_h - 0.5, "Eye emboss top overshoots wall top");
assert(eye_cz - eye_r >= 0.5, "Eye emboss bottom undercuts floor line");
assert(beak_top_z <= ext_h - 0.5, "Beak top overshoots wall top");
assert(beak_apex_z >= 0.5, "Beak apex below floor");

// ===== Modules =====

module rounded_rect(w, d, r) {
    translate([r, r])
        offset(r=r) square([w - 2*r, d - 2*r]);
}

// Tray body: rounded rectangular shell, open top. Plain vertical front wall
// (no scoop, no grip scallop).
module tray_shell() {
    difference() {
        linear_extrude(height=ext_h)
            rounded_rect(ext_w, ext_d, fillet_vert_r);
        int_r = max(fillet_vert_r - wall_t, 0.8);
        translate([wall_t, wall_t, floor_t])
            linear_extrude(height=int_h + 0.1)
                rounded_rect(int_w, int_d, int_r);
    }
}

module eye_emboss(x_off) {
    cx = ext_w/2 + x_off;
    translate([cx, ext_d, eye_cz])
        rotate([-90, 0, 0])
            cylinder(r=eye_r, h=eye_raise, $fn=64);
}

module pupil_emboss(x_off) {
    cx = ext_w/2 + x_off;
    translate([cx, ext_d, eye_cz])
        rotate([-90, 0, 0])
            cylinder(r=pupil_r, h=eye_raise + pupil_extra, $fn=48);
}

module beak_emboss() {
    cx = ext_w/2;
    // Build 2D polygon in XY where 2D-y = world Z height, then orient so
    // the prism extrudes OUTWARD in +Y from the front wall exterior.
    //
    // Using rotate([90,0,0]) maps the sketch's 2D-y correctly to world Z
    // (positive up) but extrudes in -Y. Pre-translating the prism by
    // +beak_raise in Y compensates, so the prism spans Y = ext_d ..
    // ext_d + beak_raise (outward of the wall, as intended).
    translate([0, ext_d + beak_raise, 0])
        rotate([90, 0, 0])
            linear_extrude(height=beak_raise)
                polygon(points=[
                    [cx - beak_w/2, beak_top_z],
                    [cx + beak_w/2, beak_top_z],
                    [cx,            beak_apex_z],
                ]);
}

// ===== Assembly =====

module tray() {
    union() {
        tray_shell();
        eye_emboss(-eye_cx_off);
        eye_emboss( eye_cx_off);
        pupil_emboss(-eye_cx_off);
        pupil_emboss( eye_cx_off);
        beak_emboss();
    }
}

tray();

// ===== Dimension report =====
report_dimensions(ext_w, ext_d, ext_h, "tray");
