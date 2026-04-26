// P-touch Catch Tray — closed kanban bin (round 7)
// Slides into the cradle's forward tray slot; catches auto-cut labels.
//
// ROUND-7 SCOPE (this file — tray-only simplification):
//
// Round 6's variable-height front wall (corners at z=18, lowered center at
// z=10, transition arcs between, side fillets r=12) read as visual clutter
// — corner sections looked like unnecessary "top bars" and the multiple
// fillet/arc intersections produced visible sharp points. Round 7 collapses
// the front wall to a single uniform low height with one continuous concave
// fillet sweep from each side wall down to it.
//
//   1. Front wall: uniform height z = 10 across the full width.
//      No corners, no transitions, no variable-height profile.
//      A clean horizontal band on the user-front face.
//
//   2. Side-wall to front-wall: ONE concave quarter-arc per side, r = 20.
//      Sweeps continuously from side wall top (z = 30) to front wall top
//      (z = 10) over the 20 mm height drop. Single curve, single radius,
//      no intermediate flat sections.
//
//   3. Top-edge fillet: r = 2 roll on the back + side wall tops (unchanged
//      construction). Front wall top fillet uses r = 0.8 because the front
//      wall is only 1.6 mm thick — r = 2 would exceed half the wall
//      thickness and collapse the offset. r = 0.8 keeps a soft round on
//      the front lip without offset failure. Documented deviation per
//      modeler-notes-v7 §Uncertain.
//
//   4. Interior floor ramp — UNCHANGED from round 6.
//      Quadratic curve z(y) = 1.6 + 8.4 · ((y - 62.6) / 30)² .
//      Tangent to flat floor at the back; terminates at z = 10 at the
//      front-wall interior face (which is now the uniform front-wall top).
//
// What survives unchanged from round 6:
//   - Closed 4-wall bin architecture.
//   - Interior cavity X×Y dims (100 × 91 mm).
//   - Tray exterior X dim (103.2 mm). Y dim 94.2 mm.
//   - Z dim (30 mm).
//   - Tray-to-slot sliding fit (0.35 mm/side).
//   - Vertical exterior corner fillet r = 3.
//   - Render quality: $fn = 100, top_fillet_steps = 24, ramp_arc_steps = 32.
//
// Print orientation:
//   FACE-UP (open top up), back on bed. Concave side fillet sweeps and
//   parabolic ramp are all self-supporting. No supports.
//
// User orientation:
//   +Y = user-front (low front lip — grab anywhere along its width)
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
ext_d     = int_d + 2*wall_t;     // 94.2
ext_h     = int_h + floor_t;      // 30.0

// Front wall — uniform low height (round-7 simplification).
front_wall_h            = 10;     // single uniform height across full width
front_wall_side_fillet_r = 20;    // concave quarter-arc side wall (z=30) → front wall (z=10)

// Top edge fillet schedule
fillet_vert_r           = 3.0;    // exterior vertical edge fillets
top_edge_fillet_r       = 2.0;    // continuous fillet on back/sides wall tops
front_top_edge_fillet_r = 0.8;    // smaller fillet on front wall top (1.6 mm wall — r=2 collapses)

// Interior floor ramp — concave (parabolic) curve. Unchanged from round 6.
ramp_y_extent       = 30;
ramp_back_y         = ext_d - wall_t - ramp_y_extent;   // 62.6
ramp_front_y        = ext_d - wall_t;                   // 92.6
ramp_back_z         = floor_t;                          // 1.6
ramp_front_z        = front_wall_h;                     // 10

// ===== Structural asserts =====
assert(wall_t >= MIN_WALL, str("Tray wall ", wall_t, " below min ", MIN_WALL));
assert(floor_t >= MIN_FLOOR_CEIL, str("Tray floor ", floor_t, " below min floor"));
assert(ext_w <= 256 && ext_d <= 256 && ext_h <= 256, "Tray exceeds bed");
assert(front_wall_h > floor_t,
       "Front wall height too low — must be above floor");
assert(front_wall_h < ext_h,
       "Front wall height must be lower than back/side walls");
assert(front_wall_side_fillet_r <= (ext_w - 2*wall_t) / 2,
       "Side fillets overlap — reduce front_wall_side_fillet_r");
assert(front_wall_side_fillet_r >= (ext_h - front_wall_h),
       "Side fillet radius too small for the height drop — won't reach front wall top");
assert(front_top_edge_fillet_r < wall_t,
       "Front top edge fillet must be smaller than wall thickness");
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

// ===== Front-wall top cutter =====
//
// Removes the air ABOVE the front-wall top profile in the front-wall slab
// region (y >= ext_d - wall_t). The 2D profile is in the X-Z plane,
// extruded along Y across the front-wall thickness (with a small slop
// margin so the cutter cleanly clips through both wall faces).
//
// Profile (CCW polygon describing the AIR-TO-CUT region above the wall):
//
//   Top edge: horizontal at z = ext_h + slop, full X span.
//
//   Bottom edge (the wall-top profile, walked right→left):
//     1. (ext_w + slop, ext_h)
//     2. (ext_w - wall_t, ext_h)         — top of right side wall material
//     3. RIGHT SIDE FILLET — single quarter arc r=20, center
//        (ext_w - wall_t - r, front_wall_h) = (81.6, 10).
//        Sweeps from (ext_w - wall_t, ext_h) [angle  0°] (= 81.6+20=101.6
//        wait — center is 81.6, radius 20: angle 0 → x=101.6) NO — the
//        endpoint at the side-wall top is (1.6, 30). Re-derive:
//          - We want endpoint A at (ext_w - wall_t, ext_h) = (101.6, 30).
//          - Distance from center (81.6, 10) to A: √(20² + 20²) ≠ r. WRONG.
//        Correct geometry: for a quarter-arc r=20 sweeping from the
//        side-wall top (x = ext_w - wall_t, z = ext_h) DOWN to the front
//        wall top (z = front_wall_h) over horizontal travel of r,
//        the center must be on the LINE z = front_wall_h at horizontal
//        offset r from the side wall, AND on the LINE x = ext_w - wall_t.
//        These are two perpendicular lines; only one center satisfies both
//        simultaneously when (ext_h - front_wall_h) = r. Here that's
//        30 - 10 = 20 = r. ✓
//        So center = (ext_w - wall_t - 0, front_wall_h) = (101.6, 10).
//        WRONG — that puts the arc passing through (101.6, 30) (top of
//        side wall) and (81.6, 10) (front wall top inset by r). Let me
//        re-think which orientation we want.
//
//        OBJECTIVE: from above, looking at the front wall top, we want a
//        smooth curve that BLENDS INWARD. The wall top at the side is
//        z=30 (full height). The wall top in the middle is z=10. The
//        curve sweeps from z=30 at x=ext_w-wall_t INWARD to z=10 at some
//        x = ext_w - wall_t - r. The curve is CONCAVE FROM ABOVE (dips
//        below the chord) — from the user's perspective looking at the
//        front, the transition is a soft scoop, not a hard step.
//
//        For a concave-from-above quarter arc with horizontal endpoint at
//        x_outer (z=ext_h) and "inner" endpoint at x_outer - r (z=front_wall_h),
//        the arc center is at (x_outer, front_wall_h). The arc passes
//        from (x_outer, x_outer + r·cos θ at θ=90°) … let me redo simply:
//
//        Center = (x_outer, front_wall_h). Radius r.
//          - Point A at angle 90°: (x_outer + 0, front_wall_h + r)
//                                = (x_outer, ext_h)  ✓ (since r = ext_h - front_wall_h)
//          - Point B at angle 180°: (x_outer - r, front_wall_h + 0)
//                                = (x_outer - r, front_wall_h)  ✓
//        Sweep from 90° to 180° (CCW) traces a quarter arc passing
//        through (x_outer + r·cos 135°, front_wall_h + r·sin 135°)
//        = (x_outer - r·√2/2, front_wall_h + r·√2/2)
//        = (x_outer - 14.14, front_wall_h + 14.14).
//        For the right side: x_outer = ext_w - wall_t = 101.6, so the
//        midpoint is at (101.6 - 14.14, 10 + 14.14) = (87.46, 24.14).
//        Chord midpoint: ((101.6 + 81.6)/2, (30 + 10)/2) = (91.6, 20).
//        Arc midpoint (87.46, 24.14) is to the LEFT of chord midpoint
//        (87.46 < 91.6) and ABOVE it (24.14 > 20). That's the upper-left
//        side of the chord — i.e., the arc bulges UP-AND-LEFT relative
//        to the chord.
//
//        From the user-front perspective (looking at the front wall in
//        the X-Z plane from -Y), we want the wall TOP profile to scoop
//        gently — the air ABOVE the wall is what we cut. The cutter
//        polygon's bottom edge IS the wall-top profile. Following the
//        bottom edge from right to left in the cutter polygon: at
//        x=101.6 we're at z=30; the arc dips DOWN to z=10 at x=81.6.
//        For "concave from above" (the user perceives a soft scoop),
//        the curve should bulge AWAY from the user — i.e., the wall-top
//        material should bulge UP into the cut region, leaving a
//        concave (saddle) appearance. Equivalently, the arc midpoint
//        should be ABOVE the chord midpoint (more wall material survives).
//
//        With center (x_outer, front_wall_h), arc from 90° to 180°:
//        midpoint is (87.46, 24.14), ABOVE chord midpoint (20). ✓
//        The wall material below this curve forms a bulge that rises
//        smoothly from the front wall top up to the side wall top.
//        Visually: a concave scoop in the air above the wall.
//
//     4. (ext_w - wall_t - r, front_wall_h) = (81.6, 10).
//
//     5. (wall_t + r, front_wall_h) = (21.6, 10).
//
//     6. LEFT SIDE FILLET — mirror of right. Quarter arc r=20, center
//        (wall_t, front_wall_h) = (1.6, 10), arc from 0° to 90° (CCW).
//          - 0°: (1.6 + 20, 10) = (21.6, 10)  ✓
//          - 90°: (1.6, 10 + 20) = (1.6, 30)  ✓
//        Walked from (21.6, 10) up to (1.6, 30). Concave-from-above mirror.
//
//     7. (wall_t, ext_h) = (1.6, 30).
//
//     8. (-slop, ext_h) — slop on left edge.
//
//   Closing left edge: vertical from (-slop, ext_h) to (-slop, ext_h+slop).
//   Closing right edge: vertical from (ext_w+slop, ext_h+slop) to top.

function _arc_pts(cx, cz, r, a_start_deg, a_end_deg, n) =
    [for (i = [0 : n])
        let(t = i / n,
            a = a_start_deg + t * (a_end_deg - a_start_deg))
        [cx + r * cos(a), cz + r * sin(a)]
    ];

function _front_wall_top_cutter_pts() =
    let(slop = 1.0,
        n = top_fillet_steps,
        r = front_wall_side_fillet_r,
        // Right side fillet: center (ext_w - wall_t, front_wall_h),
        // arc 90° → 180° CCW (going up-and-left from front wall top
        // inward to side wall top). Walked right→left in cutter, so
        // start at angle 90° (= side wall top, x=ext_w-wall_t) and
        // sweep TO 180° (= front wall top inner, x=ext_w-wall_t-r).
        // _arc_pts generates from a_start to a_end inclusive in order.
        right_side_fillet = _arc_pts(
            ext_w - wall_t, front_wall_h,
            r, 90, 180, n),
        // Left side fillet: center (wall_t, front_wall_h),
        // arc 0° → 90° CCW. Walked right→left in cutter, so start at
        // angle 0° (x=wall_t+r, front wall top inner) and sweep to
        // 90° (x=wall_t, side wall top).
        left_side_fillet = _arc_pts(
            wall_t, front_wall_h,
            r, 0, 90, n))
    concat(
        [[-slop, ext_h + slop]],                // top-left of cut region
        [[ext_w + slop, ext_h + slop]],         // top-right
        [[ext_w + slop, ext_h]],                // step down to right edge
        right_side_fillet,                      // arc from (101.6, 30) → (81.6, 10)
        // continue along uniform front wall top z=10
        // (right_side_fillet ends at (81.6, 10); left_side_fillet starts
        //  at (21.6, 10) — bottom edge from (81.6,10) to (21.6,10) is
        //  the flat front wall top.)
        left_side_fillet                        // arc from (21.6, 10) → (1.6, 30)
        // closes back to (-slop, ext_h + slop) automatically.
    );

module front_wall_top_cutter() {
    pts = _front_wall_top_cutter_pts();
    slop = 1.0;
    translate([0, ext_d + slop, 0])
        rotate([90, 0, 0])
            linear_extrude(height = wall_t + 2 * slop)
                polygon(points = pts);
}

module outer_body_raw() {
    difference() {
        outer_box_full();
        front_wall_top_cutter();
    }
}

// ===== Top edge fillets =====
//
// Two fillet stacks:
//   (a) r = 2 on back + side wall tops at z = ext_h, restricted to the
//       back-and-sides region (y < ext_d - wall_t plus side-wall corner
//       buffers). Same construction as round 6.
//   (b) r = 0.8 on the front wall top at z = front_wall_h, restricted to
//       the front wall slab (y >= ext_d - wall_t) in the X range that
//       lies on the flat front wall top (x in [wall_t + r_side, ext_w -
//       wall_t - r_side]). The fillet sweep from the side wall (Fix 2)
//       provides its own curvature; the r=0.8 roll lives only on the
//       flat segment between the two side-fillet sweep endpoints.

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

// Mask for the back-and-sides region. Excludes the front-wall slab
// (y >= ext_d - wall_t) above z = front_wall_h, plus side-wall corner
// buffers so the side walls' vertical r=3 edge fillet has a full-height
// home and the side fillet sweep (Fix 2) is undisturbed.
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

// Mask for the front-wall flat-top region. Restrict to the X range on
// the FLAT segment between the two side-fillet sweeps, and restrict to
// the front-wall slab in Y. The side-fillet zones are excluded so the
// r=0.8 roll doesn't fight the r=20 sweep curvature.
module front_top_mask() {
    r_side  = front_wall_side_fillet_r;
    x_left  = wall_t + r_side;
    x_right = ext_w - wall_t - r_side;
    translate([x_left, ext_d - wall_t - 0.001, -1])
        cube([x_right - x_left,
              wall_t + 1.001 + 0.5,
              front_wall_h + front_top_edge_fillet_r + 2]);
}

// Front-wall flat-top fillet stack. Same slab-stack construction as
// the back/sides stack, but at top = front_wall_h with smaller radius
// front_top_edge_fillet_r. Uses a smaller rounded-rect footprint that
// covers only the front wall slab so the inset offset doesn't eat
// into back/side wall material.
module front_wall_top_fillet_stack() {
    r = front_top_edge_fillet_r;
    n = top_fillet_steps;
    top = front_wall_h;
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
            // Carve away the top-r block of the front-wall flat-top for
            // its rolled cap (smaller r=0.8).
            intersection() {
                translate([-1, -1, front_wall_h - front_top_edge_fillet_r])
                    cube([ext_w + 2, ext_d + 2, front_top_edge_fillet_r + slop]);
                front_top_mask();
            }
        }
        // Add the back/sides rolled cap (intersect with back/sides mask).
        intersection() {
            footprint_fillet_stack(ext_h, top_edge_fillet_r, top_fillet_steps);
            back_sides_mask();
        }
        // Add the front-wall flat-top rolled cap (intersect with front mask).
        intersection() {
            front_wall_top_fillet_stack();
            front_top_mask();
        }
    }
}

// ===== Interior cavity =====
//
// Y-Z polygon walked CCW, extruded across the interior X span
// (x = wall_t .. ext_w - wall_t). Unchanged from round 6.

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
