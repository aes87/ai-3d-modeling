// P-touch Catch Tray — closed kanban bin (round 6)
// Slides into the cradle's forward tray slot; catches auto-cut labels.
//
// ROUND-6 SCOPE (this file — tray-only revision):
//
// Round 5's front-wall treatment is replaced. The boss + scoop indent
// grab feature is fully removed. In its place, the front wall has
// VARIABLE HEIGHT along X: corner sections at full z = 18, lowered
// center 50 mm wide at z = 10. The lowered center IS the grab feature —
// a finger reaches over the 10 mm tall opening and hooks the front lip.
//
//   1. Variable-height front wall.
//      - Corner sections (x = 0..18.6 and x = 84.6..103.2): wall top z = 18.
//      - Lowered center (x = 26.6..76.6): wall top z = 10.
//      - Concave transition arcs (r = 8) between corner-z=18 and center-z=10.
//      - Smooth.
//
//   2. Side-wall to front-wall fillets (no more "fangs").
//      - Concave quarter-arc r = 12 at each upper outer corner of the
//        front wall, sweeping from the side-wall top z = 30 down to the
//        front-wall corner top z = 18. Replaces round 5's hard step.
//
//   3. Concave interior floor ramp (re-orientation from round 5's hump).
//      - Quadratic curve from (y = 62.6, z = 1.6) to (y = 92.6, z = 10).
//      - z(y) = 1.6 + 8.4 · ((y - 62.6) / 30)² .
//      - Tangent to the flat floor at the back (slope = 0 at y = 62.6),
//        gentle near back, steepens monotonically toward the front
//        ("smooth gradual incline like climbing a slide").
//      - Concave-from-cavity-side (curve dips below the chord); fully
//        self-supporting in face-up print orientation.
//      - Terminates at the lowered-center top z = 10 (was z = 18 round 5).
//      - A circular arc with these endpoints + concave-from-cavity-side
//        + above-floor constraint has no real solution (proven during
//        modeling — chord rise too small). Quadratic curve satisfies the
//        spirit of the modeler-notes-v6 fix exactly: monotonic rise,
//        concave from cavity, smoothly tangent to flat floor.
//
//   4. Render quality.
//      - $fn = 100, top_fillet_steps = 24, ramp_arc_steps = 32 (DRAFT).
//      - Shipper bumps to ship quality via -D overrides at delivery.
//
// What survives unchanged from round 5:
//   - Closed 4-wall bin architecture.
//   - Interior cavity X×Y dims (100 × 91 mm).
//   - Tray exterior X dim (103.2 mm). Y dim REVERTS to 94.2 (boss removed).
//   - Z dim (30 mm).
//   - Tray-to-slot sliding fit (0.35 mm/side).
//   - Vertical exterior corner fillet r = 3.
//   - Top-edge fillet r = 2 on the back + side walls (rolled inward).
//
// Print orientation:
//   FACE-UP (open top up), back on bed. Concave ramp surface and front
//   wall variable-height profile are all self-supporting. No supports.
//
// User orientation:
//   +Y = user-front (lowered-center grab face)
//   -Y = user-back  (back wall)
//   +Z = up         (open top)

include <fdm-pla.scad>
include <bambu-x1c.scad>
include <common.scad>

// Render quality. Draft during iteration; shipper bumps via -D for delivery.
//   $fn:              100 draft → 200 ship
//   top_fillet_steps:  24 draft →  64 ship
//   ramp_arc_steps:    32 draft →  96 ship
$fn              = 100;
top_fillet_steps = 24;
ramp_arc_steps   = 32;

// ===== Parameters =====
int_w     = 100;    // interior width (X)
int_d     = 91;     // interior depth (Y)
int_h     = 28.4;   // interior height (Z)
wall_t    = 1.6;
floor_t   = 1.6;

ext_w     = int_w + 2*wall_t;     // 103.2
ext_d     = int_d + 2*wall_t;     // 94.2 (round-6: boss removed, reverted from 96.7)
ext_h     = int_h + floor_t;      // 30.0

// Front wall — variable-height profile.
front_wall_corner_h        = 18;   // corner sections full height
front_wall_center_h        = 10;   // lowered center height (grab feature)
front_wall_center_w        = 50;   // lowered center X-width
front_wall_transition_r    = 8;    // concave arc radius between corner and center
front_wall_corner_fillet_r = 12;   // side-wall to front-wall corner fillet

// Top edge fillet schedule
fillet_vert_r              = 3.0;  // exterior vertical edge fillets
top_edge_fillet_r          = 2.0;  // continuous fillet on back/sides wall tops

// Derived front-wall layout (X-Z plane, looking from -Y toward +Y).
//
// X ranges:
//   [0, wall_t]                                 = side wall material (full ext_h)
//   [wall_t, wall_t + corner_fillet_r]          = side fillet sweep z=30→18, r=12
//   [wall_t + corner_fillet_r, _corner_flat_x_end]  = corner flat at z=18
//   transition_arc r=8 spans corner_flat_end → center_start, z=18→10
//   [center_start, center_end]                  = lowered center at z=10
//   transition_arc r=8 spans center_end → corner_flat_start (right side)
//   etc, mirrored.
//
// Geometry math:
//   center_start = (ext_w - center_w) / 2 = (103.2 - 50)/2 = 26.6
//   center_end   = ext_w - center_start = 76.6
//   corner_flat_x_end_left  = center_start - transition_r = 18.6
//   corner_flat_x_start_right = center_end + transition_r = 84.6
//   corner_flat_x_start_left  = wall_t + corner_fillet_r = 13.6
//   corner_flat_x_end_right   = ext_w - wall_t - corner_fillet_r = 89.6
//
// Self-check: corner_flat_x_end_left (18.6) >= corner_flat_x_start_left (13.6)
// so there's a 5 mm flat segment at z = 18 between the side fillet and the
// transition arc. That's the visible "corner" of the front wall.

_center_start            = (ext_w - front_wall_center_w) / 2;                      // 26.6
_center_end              = ext_w - _center_start;                                   // 76.6
_corner_flat_x_end_left  = _center_start - front_wall_transition_r;                // 18.6
_corner_flat_x_start_right = _center_end + front_wall_transition_r;                // 84.6
_corner_flat_x_start_left  = wall_t + front_wall_corner_fillet_r;                   // 13.6
_corner_flat_x_end_right   = ext_w - wall_t - front_wall_corner_fillet_r;           // 89.6

// Interior floor ramp — concave (parabolic) curve.
ramp_y_extent       = 30;
ramp_back_y         = ext_d - wall_t - ramp_y_extent;   // 62.6
ramp_front_y        = ext_d - wall_t;                   // 92.6
ramp_back_z         = floor_t;                          // 1.6
ramp_front_z        = front_wall_center_h;              // 10 (round-6: was 18)

// ===== Structural asserts =====
assert(wall_t >= MIN_WALL, str("Tray wall ", wall_t, " below min ", MIN_WALL));
assert(floor_t >= MIN_FLOOR_CEIL, str("Tray floor ", floor_t, " below min floor"));
assert(ext_w <= 256 && ext_d <= 256 && ext_h <= 256, "Tray exceeds bed");
assert(front_wall_center_h > floor_t,
       "Lowered center height too low — must be above floor");
assert(front_wall_corner_h < ext_h,
       "Front wall corner must be lower than back/side walls");
assert(_corner_flat_x_end_left > _corner_flat_x_start_left,
       "Corner flat segment vanishes — adjust transition_r or corner_fillet_r");
assert(ramp_back_y > wall_t,
       "Ramp back-y too close to back wall — flat floor region too small");
assert(ramp_front_z > ramp_back_z,
       "Ramp must rise from back to front");

// ===== 2D helpers =====

module rounded_rect(w, d, r) {
    translate([r, r])
        offset(r=r) square([w - 2*r, d - 2*r]);
}

// ===== Outer body (closed 4-wall bin) =====

module outer_box_full() {
    linear_extrude(height = ext_h)
        rounded_rect(ext_w, ext_d, fillet_vert_r);
}

// ===== Front-wall variable-height top cutter =====
//
// Removes the air ABOVE the front-wall top profile in the front-wall slab
// region (y >= ext_d - wall_t). The 2D profile is in the X-Z plane; it is
// extruded along Y across the front-wall thickness (with a small slop
// margin so the cutter cleanly clips through both wall faces).
//
// Profile (CCW polygon describing the AIR-TO-CUT region above the wall):
//
//   Top edge: horizontal at z = ext_h + slop, from x = -slop to x = ext_w + slop.
//
//   Bottom edge (the wall top profile, walked right→left):
//     1. (ext_w+slop, ext_h)
//     2. (ext_w - wall_t, ext_h)        — top of right side wall material
//     3. RIGHT SIDE FILLET (quarter arc r=12, center (ext_w-wall_t-r, ext_h)).
//        Sweeps from (ext_w - wall_t, ext_h) [angle 0°] to
//                    (ext_w - wall_t - r, ext_h - r) [angle 270°/=-90°].
//        Concave from above (curve dips below chord).
//     4. (corner_flat_x_end_right, front_wall_corner_h) — end of right
//        corner flat segment at z = 18.
//     5. (corner_flat_x_start_right, front_wall_corner_h) — start of right
//        corner flat (= 84.6 — one end of right transition arc).
//     6. RIGHT TRANSITION ARC (quarter arc r=8, center (corner_flat_x_start_right,
//        front_wall_corner_h)). Sweeps from (corner_flat_x_start_right,
//        front_wall_corner_h) [angle 270°] to (center_end, front_wall_center_h)
//        [angle 180°]. Wait — let me redo: the arc goes from
//        (84.6, 18) DOWN-AND-LEFT to (76.6, 10). With center (76.6, 18):
//          - (84.6, 18) is at angle 0° from center (right of center)
//          - (76.6, 10) is at angle 270°/=-90° (below center)
//          - Sweep CW (decreasing angle) from 0° to -90° gives the SE quadrant
//            of the circle, which is below-and-right of the center —
//            arc passes through (76.6 + 8cos(-45°), 18 + 8sin(-45°)) =
//            (82.26, 12.34). z=12.34 < chord midpoint z=14, so curve dips
//            below chord — concave from above. ✓
//     7. (center_end, front_wall_center_h) — start of lowered center.
//     8. (center_start, front_wall_center_h) — end of lowered center.
//     9. LEFT TRANSITION ARC mirror.
//    10. (corner_flat_x_end_left, front_wall_corner_h) — end of left corner flat.
//    11. (corner_flat_x_start_left, front_wall_corner_h) — start of left corner
//        flat (= 13.6, one end of left side fillet).
//    12. LEFT SIDE FILLET (mirror of right). Quarter arc r=12, center
//        (corner_flat_x_start_left, ext_h) = (13.6, 30). Sweeps from
//        (13.6, 18) [angle 270°] to (1.6, 30) [angle 180°].
//    13. (wall_t, ext_h) — top of left side wall.
//    14. (-slop, ext_h)
//
//   Closing left edge: vertical from (-slop, ext_h) to (-slop, ext_h+slop).
//   Closing right edge: vertical from (ext_w+slop, ext_h+slop) to top.

function _arc_pts_quarter(cx, cz, r, a_start_deg, a_end_deg, n) =
    [for (i = [0 : n])
        let(t = i / n,
            a = a_start_deg + t * (a_end_deg - a_start_deg))
        [cx + r * cos(a), cz + r * sin(a)]
    ];

function _front_wall_top_cutter_pts() =
    let(slop = 1.0,
        n_fillet = top_fillet_steps,
        // Right side fillet: center (ext_w - wall_t - r12, ext_h), arc from
        // angle 0° to 270° going CW (decreasing → from 0 to -90).
        right_side_fillet = _arc_pts_quarter(
            ext_w - wall_t - front_wall_corner_fillet_r, ext_h,
            front_wall_corner_fillet_r, 0, -90, n_fillet),
        // Right transition arc: center (center_end, corner_h), arc from 0° to -90°.
        right_transition = _arc_pts_quarter(
            _center_end, front_wall_corner_h,
            front_wall_transition_r, 0, -90, n_fillet),
        // Left transition arc: center (center_start, corner_h), arc from -90° to -180°.
        // From (center_start, center_h) up to (corner_flat_x_end_left, corner_h).
        // Center (26.6, 18); (26.6, 10) is at angle -90°; (18.6, 18) is at angle 180°.
        // Sweep CW from -90° to -180° (= 180°): goes through (26.6 + 8cos(-135°),
        // 18 + 8sin(-135°)) = (20.94, 12.34). Below chord (= 14). ✓
        left_transition = _arc_pts_quarter(
            _center_start, front_wall_corner_h,
            front_wall_transition_r, -90, -180, n_fillet),
        // Left side fillet: center (wall_t + r12, ext_h), arc from -90° to -180°.
        // (corner_flat_x_start_left, corner_h) at angle -90°; (wall_t, ext_h)
        // at angle 180°.
        left_side_fillet = _arc_pts_quarter(
            wall_t + front_wall_corner_fillet_r, ext_h,
            front_wall_corner_fillet_r, -90, -180, n_fillet))
    concat(
        [[-slop, ext_h + slop]],                // top-left
        [[ext_w + slop, ext_h + slop]],         // top-right
        [[ext_w + slop, ext_h]],                // step down to right edge
        right_side_fillet,                      // sweep down to corner top z=18
        [[_corner_flat_x_end_right, front_wall_corner_h]],   // right corner flat right end
        // right transition arc walks from corner_flat_x_start_right (84.6, 18)
        // to center_end (76.6, 10). _arc_pts_quarter generated from 0° to -90°
        // around center (76.6, 18) gives points (76.6+8, 18) → (76.6, 10).
        right_transition,
        [[_center_start, front_wall_center_h]],              // end of lowered center (left side)
        // left transition arc from (26.6, 10) to (18.6, 18).
        left_transition,
        [[_corner_flat_x_start_left, front_wall_corner_h]],  // left corner flat right end
        // left side fillet from (13.6, 18) to (1.6, 30).
        left_side_fillet
        // After left_side_fillet ends at (wall_t, ext_h) the polygon closes
        // back to (-slop, ext_h+slop) automatically via OpenSCAD polygon.
    );

// Extrude the 2D X-Z polygon into 3D along the Y axis to form the cutter.
//
// linear_extrude extrudes along local +Z. Polygon vertices are in (X, Z)
// of world frame, fed as (X, Y) of local frame. Extrusion direction is
// local +Z. After rotate([90, 0, 0]):
//   local +X → world +X       (polygon X stays as X)
//   local +Y → world +Z       (polygon Y becomes Z) ✓
//   local +Z → world -Y       (extrude direction now points -Y)
// To make the cutter cover y in [ext_d - wall_t - slop, ext_d + slop], we
// place the slab origin at y = ext_d + slop and extrude into -Y over a
// length of (wall_t + 2*slop).

module front_wall_top_cutter() {
    pts = _front_wall_top_cutter_pts();
    slop = 1.0;
    translate([0, ext_d + slop, 0])
        rotate([90, 0, 0])
            linear_extrude(height = wall_t + 2 * slop)
                polygon(points = pts);
}

// ===== Side-wall to front-wall corner fillet =====
//
// The front_wall_top_cutter already encodes the side-wall fillet sweep
// (r=12) into its 2D profile, applied across the FRONT WALL SLAB region
// (y = ext_d - wall_t .. ext_d). However, the side-wall material itself
// extends from y = 0 to y = ext_d, and the side wall's top edge stays at
// z = ext_h = 30 across that whole Y span. The fillet from z=30 to z=18
// is a sweep that exists only within the front-wall slab — outside that
// slab (at y < ext_d - wall_t), the side wall remains full-height.
//
// To avoid creating a hard cliff at y = ext_d - wall_t (where the side
// wall's top suddenly drops from z = 30 to z = 18 over zero Y distance),
// we ALSO sweep the fillet in the Y-direction. Specifically: at each X
// in the fillet zone (x in [wall_t, wall_t + r12] left, or
// [ext_w - wall_t - r12, ext_w - wall_t] right), the fillet sweeps from
// (z = ext_h, y = ext_d - wall_t) at the inside-wall position, blending
// into z = profile(x) at y = ext_d (the exterior face).
//
// However, this is a DOUBLE-CURVATURE feature (Z-blend in X AND in Y).
// For round 6 simplicity, we accept a Y-direction step at y =
// ext_d - wall_t: the side wall material at y in [0, ext_d - wall_t]
// stays at full height z = ext_h, and the fillet sweep happens only
// within the front-wall slab. The side wall's top edge (in Y) is itself
// already filleted by the existing top-edge r=2 stack (back/sides
// fillet, applied across the full footprint). The "fang" came from a
// 90° Z-step in X (side wall meets front wall corner). The r=12 sweep
// in X eliminates that. The Y-direction step at y = ext_d - wall_t is
// mostly hidden because the side wall top is also rolled inward by the
// r=2 top fillet — so visually, there's a continuous soft top edge.
//
// This is a documented simplification. If round-7 critique flags the
// Y-step at the upper outer corners, the fix is to sculpt the upper
// outer corner with a spherical fillet (r=12 in X plus r=2 in Y).

module outer_body_raw() {
    difference() {
        outer_box_full();
        front_wall_top_cutter();
    }
}

// ===== Top edge fillet (back/sides only) =====
//
// Rolled-inward quarter-arc fillet on the TOP edges of the back wall
// (-Y side) and ±X side walls at z = ext_h. Same construction as round 5.
// The front wall top profile gets its smoothness from the variable-height
// cutter (concave arcs everywhere), so no separate top-edge roll on the
// front wall.

module footprint_fillet_stack(top, r, n) {
    for (i = [0 : n - 1]) {
        a0 = 90 * i / n;
        a1 = 90 * (i + 1) / n;
        inset1 = r * (1 - cos(a1));
        z0 = (top - r) + r * sin(a0);
        z1 = (top - r) + r * sin(a1);
        translate([0, 0, z0])
            linear_extrude(height = z1 - z0 + 0.001)
                offset(r = -inset1)
                    rounded_rect(ext_w, ext_d, fillet_vert_r);
    }
}

// Mask for the back-and-sides region (everything except the front wall slab
// and front-wall outer-corner fillet zones, plus side-wall corner buffers
// so the side walls' vertical r=3 edge fillet has a full-height home).
//
// Specifically EXCLUDE the front-wall slab (y >= ext_d - wall_t) in the
// X range [fillet_vert_r, ext_w - fillet_vert_r] above z = front_wall_corner_h.
// This keeps the back+sides fillet stack from operating on the front-wall
// region (which has its own variable-height top profile already).
module back_sides_mask() {
    union() {
        // Full footprint up to y = ext_d - wall_t.
        translate([-1, -1, -1])
            cube([ext_w + 2, ext_d - wall_t + 1,
                  ext_h + top_edge_fillet_r + 2]);
        // Side wall corner buffers (left and right).
        translate([-1, -1, -1])
            cube([fillet_vert_r + 1, ext_d + 2,
                  ext_h + top_edge_fillet_r + 2]);
        translate([ext_w - fillet_vert_r - 0.001, -1, -1])
            cube([fillet_vert_r + 1, ext_d + 2,
                  ext_h + top_edge_fillet_r + 2]);
    }
}

module outer_body_with_fillets() {
    union() {
        difference() {
            outer_body_raw();
            // Carve away the top-r block of back/sides for the rolled cap.
            slop = 0.5;
            intersection() {
                translate([-1, -1, ext_h - top_edge_fillet_r])
                    cube([ext_w + 2, ext_d + 2, top_edge_fillet_r + slop]);
                back_sides_mask();
            }
        }
        // Add the back/sides rolled cap (intersect with back/sides mask).
        intersection() {
            footprint_fillet_stack(ext_h, top_edge_fillet_r, top_fillet_steps);
            back_sides_mask();
        }
    }
}

// ===== Interior cavity =====
//
// Y-Z polygon walked CCW, extruded across the interior X span
// (x = wall_t .. ext_w - wall_t).
//
// The cavity polygon:
//   1. (wall_t,     floor_t)        bottom-back interior corner
//   2. (ramp_back_y, floor_t)       end of flat back floor
//   3. ramp parabolic curve up to (ramp_front_y, ramp_front_z)
//   4. (ramp_front_y, ext_h + 1)    up the interior face of front wall
//                                    (cavity is open above z = ramp_front_z)
//   5. (wall_t,       ext_h + 1)    back across to the back wall interior
//   6. close to (1)
//
// Extrusion across X = [wall_t, ext_w - wall_t]. The cavity goes up to
// the interior face y = ramp_front_y = ext_d - wall_t, never crossing
// into the front wall material (which lives at y in [ext_d - wall_t,
// ext_d]). The variable-height front-wall cutter handles the top profile
// of the wall material independently.

function _ramp_curve_z(y) =
    let(t = (y - ramp_back_y) / ramp_y_extent)
    ramp_back_z + (ramp_front_z - ramp_back_z) * t * t;

function _ramp_curve_pts() =
    [for (i = [0 : ramp_arc_steps])
        let(t = i / ramp_arc_steps,
            y = ramp_back_y + t * ramp_y_extent)
        [y, _ramp_curve_z(y)]
    ];

module cavity_cutter() {
    ramp = _ramp_curve_pts();
    pts = concat(
        [[wall_t, floor_t]],
        [[ramp_back_y, floor_t]],
        ramp,
        [[ramp_front_y, ext_h + 1]],
        [[wall_t, ext_h + 1]]
    );
    slop = 0.001;
    translate([wall_t - slop, 0, 0])
        rotate([90, 0, 90])
            linear_extrude(height = (ext_w - 2 * wall_t) + 2 * slop)
                polygon(points = pts);
}

// ===== Tray assembly =====

module tray() {
    difference() {
        outer_body_with_fillets();
        cavity_cutter();
    }
}

tray();

// ===== Dimension report =====
report_dimensions(ext_w, ext_d, ext_h, "tray");
