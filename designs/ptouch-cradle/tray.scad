// P-touch Catch Tray — closed kanban bin (round 7, patch v8)
// Slides into the cradle's forward tray slot; catches auto-cut labels.
//
// ROUND-7 PATCH v8 (post-critique fixes on tray only):
//
//   Issue 1 — Corner "tabs" at the top of the front-wall scoop. The round-7
//   side-fillet arc started at the side-wall INNER face (x=wall_t), leaving a
//   wall_t × wall_t column of material at full z=ext_h between the outer
//   edge (x=0) and where the arc began. From the front, that read as a
//   sharp little tab. Fix: extend each arc to start at the OUTER edge
//   (x=0 / x=ext_w), with arc center on the outer edge at z=front_wall_h.
//   The arc's tangent at z=ext_h is now horizontal — same as the side-wall
//   top — so the join is smooth with no tab.
//
//   Issue 2 — Sub-mm slivers at z≈29.9 near the front corners. Two compounding
//   causes: (a) the back/sides cap-carve was removing z=28..30.5 across the
//   full corner-buffer y-extent (including through the front-wall slab),
//   even though the cap-stack inset at the top can't reach the outer edge
//   to restore it; (b) more fundamental — the cap radius (r=2) exceeds the
//   wall thickness (wall_t=1.6), so the cap-stack inset eventually pulls
//   PAST the wall material, leaving a thin "hat" floating over the cavity.
//
//   Two-part fix:
//     1. Restrict back_sides_mask's side-wall corner buffers to
//        y ≤ ext_d - wall_t so neither cap-carve nor cap-stack operates in
//        the front-wall slab corner column. The arc cutter alone shapes the
//        wall top there; the vertical r=3 corner fillet handles the outer
//        profile.
//     2. Clamp footprint_fillet_stack's inset to wall_t - 1.0 = 0.6 mm.
//        Above this, the wall material would be < 1.0 mm thick. The cap
//        reads as ~r=0.6 effective curvature near the very top with a small
//        flat plateau — invisible at any realistic viewing distance — and
//        wall thickness stays ≥ 1.0 mm everywhere on the cap.
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
assert(front_wall_side_fillet_r <= ext_w / 2,
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
// PATCH-v8 GEOMETRY: arcs now start at the OUTER edge of the tray (x=0
// and x=ext_w) so the arc's tangent at z=ext_h is horizontal — flush with
// the side-wall top — instead of starting at x=wall_t (which left a tab).
//
//   Right arc: center (ext_w, front_wall_h), radius r=20.
//     Sweep angle 90° → 180° (CCW).
//       - 90°:  (ext_w, ext_h)            — outer edge top, tangent horizontal
//       - 180°: (ext_w - r, front_wall_h) — front wall top inner endpoint
//
//   Left arc: center (0, front_wall_h), radius r=20.
//     Sweep angle 0° → 90° (CCW).
//       - 0°:  (r, front_wall_h)          — front wall top inner endpoint
//       - 90°: (0, ext_h)                  — outer edge top, tangent horizontal
//
//   Cutter polygon (CCW air-region above wall):
//     1. (-slop, ext_h + slop)             top-left
//     2. (ext_w + slop, ext_h + slop)      top-right
//     3. (ext_w + slop, ext_h)             step down to right outer edge
//     4. right arc 90°→180° from (ext_w, ext_h) to (ext_w-r, front_wall_h)
//     5. flat front-wall-top segment to (r, front_wall_h)
//     6. left arc 0°→90° from (r, front_wall_h) to (0, ext_h)
//     7. (0, ext_h) → close back to (-slop, ext_h + slop)

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
        // Right side fillet (patch v8): center (ext_w, front_wall_h),
        // arc 90° → 180° CCW. Tangent at z=ext_h is horizontal.
        //   90°:  (ext_w, ext_h)
        //   180°: (ext_w - r, front_wall_h)
        right_side_fillet = _arc_pts(
            ext_w, front_wall_h,
            r, 90, 180, n),
        // Left side fillet (patch v8): center (0, front_wall_h),
        // arc 0° → 90° CCW. Tangent at z=ext_h is horizontal.
        //   0°:  (r, front_wall_h)
        //   90°: (0, ext_h)
        left_side_fillet = _arc_pts(
            0, front_wall_h,
            r, 0, 90, n))
    concat(
        [[-slop, ext_h + slop]],                // top-left of cut region
        [[ext_w + slop, ext_h + slop]],         // top-right
        [[ext_w + slop, ext_h]],                // step down to right outer edge
        right_side_fillet,                      // arc (ext_w, ext_h) → (ext_w-r, front_wall_h)
        // flat front wall top from (ext_w-r, front_wall_h) to (r, front_wall_h)
        // (implicit straight segment between arc endpoints)
        left_side_fillet                        // arc (r, front_wall_h) → (0, ext_h)
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

// PATCH-v8: clamp inset1 so it never exceeds wall_t - 1.0. Without this
// clamp, when the cap radius (r=2) exceeds the wall thickness (wall_t=1.6),
// the cap-stack footprint at the highest slabs insets past the wall — the
// outer surface of the cap moves INSIDE the cavity-cutter's interior. The
// result is the wall material vanishes (or thins to <0.4mm), and trimesh's
// slicer reports sub-mm "thin wall" slivers at z near the cap top.
// Clamping inset to wall_t - 1.0 = 0.6 keeps the wall ≥ 1.0 mm thick
// everywhere on the cap. The cap visibly tops out with a small flat plateau
// (the last ~0.6 mm of "cap radius" becomes a flat top), but this is
// invisible at any realistic viewing distance and resolves all sub-mm
// slivers at z>29. The clamp is gated by `clamp_inset` so the front-wall
// fillet stack (where r=0.8 < wall_t-1.0 already) can opt out if needed.
module footprint_fillet_stack(top, r, n, clamp_inset = true) {
    max_inset = clamp_inset ? max(0.001, wall_t - 1.0) : r;
    for (i = [0 : n - 1]) {
        a0 = 90 * i / n;
        a1 = 90 * (i + 1) / n;
        raw_inset = r * (1 - cos(a1));
        inset1 = min(raw_inset, max_inset);
        z0 = (top - r) + r * sin(a0);
        z1 = (top - r) + r * sin(a1);
        translate([0, 0, z0])
            linear_extrude(height = z1 - z0 + 0.001)
                offset(r = -inset1)
                    rounded_rect(ext_w, ext_d, fillet_vert_r);
    }
}

// Mask for the back-and-sides region. Excludes the front-wall slab
// (y >= ext_d - wall_t) entirely from the cap-carve / cap-add stack —
// including the side-wall corner columns inside the front-wall slab.
//
// PATCH-v8 (Issue 2 fix): corner buffers are now clipped to
// y ≤ ext_d - wall_t. Previously they extended through the full y range
// (to y = ext_d), which caused the cap-carve to remove material at z=28..30
// in the front-corner column. The cap-stack at the top slab insets ~2mm
// inward and so does NOT reach the outer edge in the front-wall slab,
// leaving a sub-mm sliver of unsupported material right where the cutter's
// arc said material should exist up to z=ext_h. Clipping the buffers to
// the back/sides region ensures the cap-carve doesn't operate in the
// front-wall slab at all — the arc cutter alone shapes the wall top there,
// and the vertical r=3 corner fillet handles the outer profile.
module back_sides_mask() {
    union() {
        // Full footprint up to y = ext_d - wall_t.
        translate([-1, -1, -1])
            cube([ext_w + 2, ext_d - wall_t + 1,
                  ext_h + top_edge_fillet_r + 2]);
        // Side wall corner buffers (left and right) — also clipped at
        // y = ext_d - wall_t so they don't extend into the front-wall slab.
        // (Redundant with the full-footprint cube above for y range, but
        // kept explicit for symmetry with future edits.)
        translate([-1, -1, -1])
            cube([fillet_vert_r + 1, ext_d - wall_t + 1,
                  ext_h + top_edge_fillet_r + 2]);
        translate([ext_w - fillet_vert_r - 0.001, -1, -1])
            cube([fillet_vert_r + 1, ext_d - wall_t + 1,
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
    r = front_top_edge_fillet_r;       // 0.8 — already < wall_t (no clamp needed)
    n = top_fillet_steps;
    top = front_wall_h;
    for (i = [0 : n - 1]) {
        a0 = 90 * i / n;
        a1 = 90 * (i + 1) / n;
        inset1 = r * (1 - cos(a1));    // unclamped: r=0.8 < wall_t=1.6 always
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
