// P-touch Catch Tray — removable kanban bin
// Slides into the cradle's forward tray slot; catches auto-cut labels.
// Owl face motif on front wall: two eye embosses + pupils + beak.
//
// Coordinate system:
//   Origin at back-left corner of the tray floor bottom (exterior).
//   +X = right, +Y = forward (toward the user), +Z = up.
//   Front wall exterior face at Y = ext_d (user-facing owl face).

include <fdm-pla.scad>
include <bambu-x1c.scad>
include <common.scad>

$fn = 80;

// ===== Parameters =====
int_w     = 100;    // interior width (X)
int_d     = 91;     // interior depth (Y)
int_h     = 40;     // interior height (Z)
wall_t    = 1.6;
floor_t   = 1.6;

ext_w     = int_w + 2*wall_t;     // 103.2
ext_d     = int_d + 2*wall_t;     // 94.2
ext_h     = int_h + floor_t;      // 41.6

fillet_vert_r         = 3.0;   // tray exterior vertical edge fillets
fillet_scoop_edge_r   = 2.0;   // scoop leading edge fillet

scoop_h      = 15;    // angled lip height (bottom 15 mm of front wall)
scoop_angle  = 45;    // degrees from horizontal

grip_w       = 24;    // top-edge scallop width
grip_depth   = 8;     // scallop depth (downward from top)

eye_r        = 8;
eye_raise    = 1.5;
eye_cz       = 28;    // from tray base exterior (z=0)
eye_cx_off   = 22;    // from tray centerline

pupil_r      = 3;
pupil_extra  = 1.5;

beak_w       = 6;
beak_h       = 6;
beak_raise   = 2;
beak_top_z   = 22;

// ===== Structural asserts =====
assert(wall_t >= MIN_WALL, str("Tray wall ", wall_t, " below min ", MIN_WALL));
assert(floor_t >= MIN_FLOOR_CEIL, str("Tray floor ", floor_t, " below min floor"));
assert(ext_w <= 256 && ext_d <= 256 && ext_h <= 256, "Tray exceeds bed");

// ===== Modules =====

module rounded_rect(w, d, r) {
    translate([r, r])
        offset(r=r) square([w - 2*r, d - 2*r]);
}

// Tray body: rounded rectangular shell, open top.
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

// Scoop cutter with a ROUNDED LEADING EDGE at (Y = ext_d - scoop_h, Z = 0).
//
// The scoop cutter removes a wedge from the front-bottom exterior so the
// bottom 15mm of the front wall becomes a 45° sloped face. Without a
// fillet, the edge where the floor bottom meets the scoop face is a sharp
// ~135° convex corner. With a 2mm leading-edge fillet, that corner is
// replaced by a smooth arc tangent to both surfaces.
//
// Implementation: build the cutter's 2D profile (Y-Z) with an arc at the
// leading corner. The cutter polygon is the UNION of the original wedge
// MINUS a small quarter-circle arc that softens the leading edge.
// Equivalently, we use offset(r=-f) offset(r=f) on the wedge to INSET
// the leading corner, keeping the front edges at Y=ext_d+0.5 sharp.
// Simpler: hand-build a polygon with an arc segment at the leading corner.
module scoop_cutter() {
    r = fillet_scoop_edge_r;  // 2 mm
    // Arc center: tangent to Z=0 (floor bottom) and tangent to the 45°
    // scoop face (plane Z = Y - (ext_d - scoop_h)). With Z_c = r and
    //   (Z_c - Y_c + ext_d - scoop_h) / sqrt(2) = r
    // => Y_c = ext_d - scoop_h + r*(1 - sqrt(2))  ≈ ext_d - scoop_h - 0.828
    Yc = ext_d - scoop_h + r*(1 - sqrt(2));
    Zc = r;
    // Tangent point on Z=0 plane: (Yc, 0)
    // Tangent point on scoop face: direction normal to scoop is (-1, 1)/sqrt(2)
    //   so tangent point = center - r * normal (pointing away from body)
    //   body is on the inside of scoop face (where Z > Y - (ext_d - scoop_h))
    //   so outward normal from body is (1, -1)/sqrt(2). Tangent on scoop:
    //   (Yc + r/sqrt(2), Zc - r/sqrt(2)) = (Yc + 1.414, r - 1.414)
    //
    // CUTTER POLYGON (Y-Z): encloses the region to SUBTRACT.
    //   Start at tangent point on floor-bottom:  (Yc, -0.01)
    //   Go forward along Z=0:                    (ext_d + 0.5, -0.01)
    //   Up to just past scoop top:               (ext_d + 0.5, scoop_h + 0.5)
    //   Back along the scoop face direction to tangent point:
    //                                            (Yc + r/sqrt(2), Zc - r/sqrt(2))
    //   Arc back to (Yc, -0.01) via quarter-circle centered at (Yc, Zc)
    //
    // We approximate the arc with N segments.
    N = 24;
    // Points of the polygon
    tail_pts = concat(
        [
            [Yc, -0.01],
            [ext_d + 0.5, -0.01],
            [ext_d + 0.5, scoop_h + 0.5],
            [Yc + r/sqrt(2), Zc - r/sqrt(2)]
        ],
        // Arc from angle -45° to 180°+90°=270°? Let's parametrize:
        // We're going from the scoop-tangent point back to the floor-bottom-tangent
        // point along the OUTSIDE of the arc (the side being cut away).
        // Angles from center (Yc, Zc):
        //   floor tangent point (Yc, 0): angle = atan2(0 - Zc, Yc - Yc) = atan2(-r, 0) = -90°
        //   scoop tangent point (Yc + r/sqrt(2), Zc - r/sqrt(2)): angle = atan2(-r/sqrt(2), r/sqrt(2)) = -45°
        // We want the arc on the OUTSIDE (away from body / toward +Y, -Z):
        //   from -45° going CLOCKWISE (decreasing angle) to -90° — but that's only 45° of arc,
        //   which is indeed the correct quarter of the round-over (between the two tangent points).
        [for (i = [0 : N])
            let(a = -45 - 45 * i / N)
            [Yc + r * cos(a), Zc + r * sin(a)]
        ]
    );
    translate([-0.5, 0, 0])
        rotate([90, 0, 90])
            linear_extrude(height=ext_w + 1)
                polygon(points=tail_pts);
}

// Top-edge grip scallop cutter
module grip_scallop_cutter() {
    cx = ext_w / 2;
    translate([cx, ext_d - wall_t*1.5, ext_h - grip_depth])
        rotate([90, 0, 0])
            cylinder(r=grip_w/2, h=wall_t*3, $fn=64);
    translate([cx - grip_w/2, ext_d - wall_t*1.5, ext_h - 0.01])
        cube([grip_w, wall_t*3, grip_depth + 5]);
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
    translate([0, ext_d, 0])
        rotate([90, 0, 0])
            linear_extrude(height=beak_raise)
                polygon(points=[
                    [cx - beak_w/2, beak_top_z],
                    [cx + beak_w/2, beak_top_z],
                    [cx,            beak_top_z - beak_h],
                ]);
}

// ===== Assembly =====

module tray() {
    difference() {
        union() {
            tray_shell();
            eye_emboss(-eye_cx_off);
            eye_emboss( eye_cx_off);
            pupil_emboss(-eye_cx_off);
            pupil_emboss( eye_cx_off);
            beak_emboss();
        }
        scoop_cutter();
        grip_scallop_cutter();
    }
}

tray();

// ===== Dimension report =====
report_dimensions(ext_w, ext_d, ext_h, "tray");
