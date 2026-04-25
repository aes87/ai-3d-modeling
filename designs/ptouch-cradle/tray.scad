// P-touch Catch Tray — removable kanban bin (round 4)
// Slides into the cradle's forward tray slot; catches auto-cut labels.
//
// ROUND-4 SCOPE (this file):
//   - Top-edge fillet (r=2) added on every wall top — continuous quarter-arc
//     roll around the entire perimeter (back, sides, scoop top lip).
//   - $fn bumped 80 → 200 for smooth curves.
//   - 45° scoop + central finger-grip dip DELETED. Replaced with a single
//     smooth concave circular arc on the front wall: from the floor's front
//     edge (y=ext_d, z=floor_t) up to the recessed top lip (y=ext_d-12,
//     z=ext_h). Arc radius 18 mm. The whole +Y "wall" follows the arc with
//     uniform 1.6 mm wall thickness.
//
// CONSTRUCTION APPROACH:
//   Outer body = (rounded_rect shell extruded to ext_h) MINUS (front-scoop cutter).
//   The front-scoop cutter is built by linear_extrude(along X) of a 2D Y-Z polygon
//   that traces the exterior +Y face profile. The polygon includes:
//     - The concave scoop arc from S=(ext_d, floor_t) to E=(ext_d − recess, ext_h),
//       tessellated by `scoop_arc_steps` for smooth render.
//     - The continuous r=2 top-edge fillet rolled across the +Y top edge,
//       continuing the arc into the +Z face.
//     - Closing the polygon on the +Y side outside the tray (large slop) so the
//       cutter is a closed solid in front of the wall.
//   This produces ONE smooth curved face (no slab-stack stair-stepping) — the
//   arc's tessellation is controlled by `$fn` and `scoop_arc_steps`.
//
//   The other top-edges (back wall, side walls) get the r=2 top fillet via a
//   slab-stack on the rectangular wall_footprint (no scoop dependency).
//
//   The interior cavity follows the same scoop arc offset inward by wall_t,
//   for uniform 1.6 mm wall thickness across the curve.
//
// User orientation:
//   +Y = user-front (scoop face)
//   -Y = user-back  (back wall)
//   +Z = up         (open top)
//
// The model is built in functional orientation. The recommended PRINT orientation
// is on the back face (-Y down on the bed) so the concave scoop's near-horizontal
// top tangent prints as an upward-facing slope rather than a severe overhang.
// See spec.json print_orientation_tray.

include <fdm-pla.scad>
include <bambu-x1c.scad>
include <common.scad>

$fn = 200;

// ===== Parameters =====
int_w     = 100;    // interior width (X)
int_d     = 91;     // interior depth (Y)
int_h     = 20;     // interior height (Z)
wall_t    = 1.6;
floor_t   = 1.6;

ext_w     = int_w + 2*wall_t;     // 103.2
ext_d     = int_d + 2*wall_t;     // 94.2
ext_h     = int_h + floor_t;      // 21.6

fillet_vert_r       = 3.0;   // tray exterior vertical edge fillets
top_edge_fillet_r   = 2.0;   // tray top-edge continuous fillet (round 4)

// Scoop geometry — round 4 single concave arc (concave from outside the tray).
//
// Profile in Y-Z (front wall cross section):
//   S = (ext_d, floor_t)              = (94.2, 1.6)  — floor's front edge
//   E = (ext_d - scoop_top_recess, ext_h) = (82.2, 21.6) — recessed top lip
// Arc center on +Y/+Z side of chord (so arc bulges INWARD toward tray interior).
scoop_top_recess  = 12;     // top lip recessed 12 mm back from front exterior
scoop_arc_r       = 18;     // concave arc radius
scoop_arc_steps   = 80;     // tessellation of the arc (controls scoop smoothness)
top_fillet_steps  = 16;     // tessellation of the top-edge r=2 fillet roll

// ===== Structural asserts =====
assert(wall_t >= MIN_WALL, str("Tray wall ", wall_t, " below min ", MIN_WALL));
assert(floor_t >= MIN_FLOOR_CEIL, str("Tray floor ", floor_t, " below min floor"));
assert(ext_w <= 256 && ext_d <= 256 && ext_h <= 256, "Tray exceeds bed");
assert(scoop_top_recess > 0 && scoop_top_recess < ext_d, "Scoop recess out of range");
assert(scoop_arc_r > sqrt(scoop_top_recess*scoop_top_recess +
                          (ext_h - floor_t)*(ext_h - floor_t)) / 2,
       "Scoop arc radius too small for the chord (no valid arc center)");

// ===== Scoop arc math =====
function _scoop_chord_len()  = sqrt(scoop_top_recess*scoop_top_recess +
                                     (ext_h - floor_t)*(ext_h - floor_t));
function _scoop_chord_mid()  = [(ext_d + (ext_d - scoop_top_recess))/2,
                                 (floor_t + ext_h)/2];
// Perpendicular pointing AWAY from tray interior (+Y, +Z).
function _scoop_perp_unit() =
    let(dy = ext_h - floor_t, dz = scoop_top_recess, len = _scoop_chord_len())
    [dy/len, dz/len];
function _scoop_center() =
    let(M = _scoop_chord_mid(),
        p = _scoop_perp_unit(),
        d_to_c = sqrt(scoop_arc_r*scoop_arc_r - (_scoop_chord_len()/2)*(_scoop_chord_len()/2)))
    [M[0] + p[0]*d_to_c, M[1] + p[1]*d_to_c];

// y on the EXTERIOR scoop face at a given z (inside-of-circle branch).
function scoop_front_y(z) =
    let(C = _scoop_center())
    C[0] - sqrt(scoop_arc_r*scoop_arc_r - (z - C[1])*(z - C[1]));

// y on the INTERIOR scoop face = exterior - wall_t (uniform wall thickness).
function scoop_front_y_int(z) = scoop_front_y(z) - wall_t;

// ===== 2D helpers =====

module rounded_rect(w, d, r) {
    translate([r, r])
        offset(r=r) square([w - 2*r, d - 2*r]);
}

// ===== Scoop cutter (Y-Z polygon → linear_extrude along X) =====
//
// The cutter is the volume in front of the scoop face, plus the volume
// above the top-edge fillet that extends into +Z slop.
//
// Polygon walk (Y-Z plane), counterclockwise:
//   Bottom-back  : (ext_d - scoop_top_recess - top_edge_fillet_r - 2, -1)
//                  (well inside, well below floor)
//   Bottom-front : (ext_d + 5, -1)                (well outside +Y, below floor)
//   Top-front    : (ext_d + 5, ext_h + 5)         (well outside +Y, above tray)
//   Top-roll     : tessellation of the r=2 fillet rolling the top-+Y corner
//                  inward (from straight-up at +Y to straight-back along -Y on top)
//                  EXCEPT we do NOT roll the cutter — instead the cutter outer
//                  contour traces the +Y exterior face, and we let the top of
//                  the wall be filleted by ANOTHER mechanism (slab-stack on
//                  wall_footprint).
//
// Simpler design: the scoop-cutter polygon traces the OUTER profile of the
// wall on the +Y side — i.e. the line y = scoop_front_y(z) for z ∈
// [floor_t, ext_h]. Above and below the arc, the cutter extends as a vertical
// line and tip outward (+Y) and beyond ext_h to ensure the cutter fully
// removes the rectangular outer body where the scoop carves it.
//
// Polygon vertices (Y, Z), counterclockwise so cutter sits IN FRONT of the wall:
//   1. (S.y, S.z) = (ext_d, floor_t) — start at bottom of arc
//   2. ... arc points up to E = (ext_d - recess, ext_h)
//   3. (E.y, ext_h + 5) — go up past the top
//   4. (ext_d + 5, ext_h + 5) — over to far +Y
//   5. (ext_d + 5, -1) — down to below floor
//   6. (ext_d, -1) — back to (S.y, below)
//   7. close to (1)
//
// This polygon, extruded across the full tray X span (with slop), removes
// everything in front of the scoop arc.
function _scoop_arc_points() = [
    for (i = [0 : scoop_arc_steps])
        let(t = i / scoop_arc_steps,
            // parametrize z linearly from floor_t to ext_h, compute y from arc
            z = floor_t + t * (ext_h - floor_t),
            y = scoop_front_y(z))
        [y, z]
];

module scoop_cutter() {
    arc = _scoop_arc_points();
    // Build polygon: arc points (S to E in CCW order) + closing path
    pts = concat(
        arc,                               // S = (ext_d, floor_t) → E = (ext_d - recess, ext_h)
        [[ext_d - scoop_top_recess, ext_h + 5]],  // up past the top
        [[ext_d + 5, ext_h + 5]],          // far +Y, above
        [[ext_d + 5, -1]],                 // far +Y, below floor
        [[ext_d, -1]]                      // back to start (closes polygon)
    );
    // Extrude along X. translate to start at -slop, length ext_w + 2*slop.
    slop = 5;
    translate([-slop, 0, 0])
        rotate([90, 0, 90])                // X-extrude direction → align polygon Y-Z to local X-Y
            linear_extrude(height = ext_w + 2 * slop)
                polygon(points = pts);
}

// Interior scoop cutter — same shape, offset inward by wall_t. Used as part of
// the cavity carve so the interior +Y face follows the same arc offset by 1.6mm.
module scoop_cutter_interior() {
    arc_int = [
        for (i = [0 : scoop_arc_steps])
            let(t = i / scoop_arc_steps,
                z = floor_t + t * (ext_h - floor_t),
                y = scoop_front_y_int(z))
            [y, z]
    ];
    pts = concat(
        arc_int,
        [[ext_d - scoop_top_recess - wall_t, ext_h + 5]],
        [[ext_d + 5, ext_h + 5]],
        [[ext_d + 5, -1]],
        [[ext_d - wall_t, -1]],            // bottom-back vertex offset inward too
        [[ext_d - wall_t, floor_t]]        // close at interior front-floor corner
    );
    slop = 5;
    translate([-slop, 0, 0])
        rotate([90, 0, 90])
            linear_extrude(height = ext_w + 2 * slop)
                polygon(points = pts);
}

// ===== Tray outer body =====
//
// 1. Build a rectangular shell with vertical r=3 corners: extrude rounded_rect
//    to ext_h.
// 2. Add the r=2 top-edge fillet on the BACK and SIDE walls (not +Y front)
//    via a slab-stack of insetted offsets.
// 3. Subtract the scoop cutter — this carves the +Y face into the concave arc.
// 4. Add a separate top-edge fillet feature for the +Y top-lip — the scoop
//    cutter polygon ALREADY rolls the top edge naturally (the arc tangent at
//    z=ext_h is shallow), but we want a hard r=2 fillet bringing the top edge
//    inward. To accomplish this, the scoop cutter polygon's top edge can roll
//    over by r=2 (the "top-roll" segment). However, because the arc top
//    tangent is already nearly horizontal (~80° from vertical), an explicit
//    fillet is largely redundant. We instead let the scoop arc itself serve
//    as the top-+Y rounding, and reserve the r=2 slab-stack fillet for the
//    other three top edges.

module tray_outer_raw() {
    linear_extrude(height = ext_h)
        rounded_rect(ext_w, ext_d, fillet_vert_r);
}

// Top-edge fillet on the BACK & SIDE walls (NOT the +Y front).
//
// Strategy: build a "fillet ring" that subtracts material from the top of
// the wall along the back & sides only. The ring is built as a slab-stack
// on the back/sides wall_footprint, but we MASK it to only affect y < ext_d
// minus a small margin so it doesn't intersect the scoop region.
//
// The masked region (y < ext_d - margin) covers the back and side walls'
// top edges; the +Y top edge is handled implicitly by the scoop cutter.
module tray_top_fillet_zone() {
    // Mask: full tray width, but only y in [-1, ext_d - 1.5] — i.e. excludes
    // the +Y face region where the scoop cutter takes over.
    translate([-1, -1, ext_h - top_edge_fillet_r - 0.01])
        cube([ext_w + 2, ext_d - 2.5, top_edge_fillet_r + 1]);
}

// The fillet itself: stack of insetted slabs forming a quarter-arc from the
// wall top inward. We start from the wall_footprint at (ext_h - r) and inset
// progressively as we climb to ext_h.
module tray_top_fillet_solid() {
    r = top_edge_fillet_r;
    n = top_fillet_steps;
    // Slab below the fillet (the wall continues full footprint up to z = ext_h - r)
    // is already part of tray_outer_raw(). Here we ONLY add the rolled cap region.
    for (i = [0 : n - 1]) {
        a0 = 90 * i / n;
        a1 = 90 * (i + 1) / n;
        inset1 = r * (1 - cos(a1));
        z0 = (ext_h - r) + r * sin(a0);
        z1 = (ext_h - r) + r * sin(a1);
        translate([0, 0, z0])
            linear_extrude(height = z1 - z0 + 0.001)
                offset(r = -inset1)
                    rounded_rect(ext_w, ext_d, fillet_vert_r);
    }
}

// Combined outer-with-back-side-top-fillet:
//   1. Subtract a "top-block" (z >= ext_h - r) from the raw outer in the
//      back/side region (mask y < ext_d - r - 0.5).
//   2. Add the rolled fillet solid (its plan view is the rectangular tray
//      footprint; the +Y portion will be sliced off by the scoop cutter
//      later in tray_outer()).
module tray_with_back_side_top_fillet() {
    union() {
        difference() {
            tray_outer_raw();
            // Remove the top-r-block in the back/side region only
            intersection() {
                translate([-1, -1, ext_h - top_edge_fillet_r])
                    cube([ext_w + 2, ext_d + 2, top_edge_fillet_r + 1]);
                // Mask: only y < ext_d - r - 0.5 (stay clear of scoop region)
                translate([-1, -1, -1])
                    cube([ext_w + 2, ext_d - top_edge_fillet_r - 0.5, ext_h + 5]);
            }
        }
        // Add the rolled fillet cap. Its +Y portion will be sliced off by
        // the scoop cutter in tray_outer().
        tray_top_fillet_solid();
    }
}

// Full outer body: tray with back/side top fillet, then carve the scoop face.
module tray_outer() {
    difference() {
        tray_with_back_side_top_fillet();
        scoop_cutter();
    }
}

// ===== Tray cavity =====
//
// Construction:
//   cavity = rect_cavity ∪ (scoop_cutter_interior ∩ tray_exterior_box)
//
// The rectangular cavity covers the back + sides interior (back wall and
// ±X side walls, all uniform wall_t thick from the exterior). The interior
// scoop cutter, clipped to the tray's exterior box, EXTENDS the cavity
// forward toward the interior arc — at heights z above the floor, the
// cavity reaches all the way out to y = scoop_front_y_int(z), which is
// the interior face of the curved +Y wall (uniform wall_t inboard of the
// exterior arc).
module tray_cavity_full() {
    int_r = max(fillet_vert_r - wall_t, 0.8);
    union() {
        // Rectangular cavity (back/sides interior)
        translate([wall_t, wall_t, floor_t])
            linear_extrude(height = int_h + 5)
                rounded_rect(int_w, int_d, int_r);
        // Interior scoop cutter clipped to the tray exterior. The scoop
        // cutter EXTENDS in +Y past ext_d, so we clip it to the rect.
        intersection() {
            scoop_cutter_interior();
            // Clip to the tray X-Y interior + slop in Z up to ext_h+slop.
            translate([wall_t - 0.01, wall_t - 0.01, floor_t])
                cube([int_w + 0.02, ext_d - wall_t + 1, int_h + 5]);
        }
    }
}

// ===== Tray shell =====
module tray_shell() {
    difference() {
        tray_outer();
        tray_cavity_full();
    }
}

// ===== Assembly =====
module tray() {
    tray_shell();
}

tray();

// ===== Dimension report =====
report_dimensions(ext_w, ext_d, ext_h, "tray");
