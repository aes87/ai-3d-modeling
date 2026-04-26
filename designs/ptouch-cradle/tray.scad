// P-touch Catch Tray — closed kanban bin (round 7, patch v11)
//
// ROUND-7 PATCH v11 (S-curve / cap continuity — corner gap + thin front face fix):
//
//   USER-VISIBLE ISSUE (two slicer-view screenshots in vault/0-inbox/,
//   dated 2026-04-26):
//     1. "odd gap between front of tray adornments and sidewall — should
//        connect smoothly and continuously" — at the front-wall corner the
//        S-curve sweep face starts ~1.6 mm ABOVE where the side-wall cap's
//        outer-edge ends; the two surfaces don't meet, leaving a thin
//        wedge-shaped gap in the slicer view.
//     2. "Discontinuous thin front face on front wall of tray Odd —
//        should be removed when other discontinuity fixed" — at y=92.55
//        (the back_sides_mask boundary) the corner column's top z jumps
//        from 28.4 (cap apex) to 30 (S-curve cutter top), exposing a
//        thin vertical strip of front-wall material.
//
//   ROOT CAUSE: 1.6 mm height mismatch between the S-curve cutter
//   outer-edge top and the side-wall cap outer-edge top, at the corner
//   column (x ∈ [0, wall_t] ∪ [ext_w-wall_t, ext_w]).
//     - Side-wall cap (r = top_edge_fillet_r = wall_t = 1.6, applied where
//       y ≤ ext_d - wall_t - 0.05 = 92.55 via back_sides_mask) ends at
//       outer-edge top z = ext_h - r = 28.4.
//     - Front-wall-slab S-curve cutter outer-edge tangent point was at
//       (x=0, z=ext_h) = (0, 30). 1.6 mm higher.
//   Patch v10's mask clip at y=92.55 (the watertight fix) means the cap
//   doesn't operate in the corner column; the column's outer edge
//   therefore followed the cutter alone (z=30 at x=0), not the cap
//   (z=28.4 at x=0). Both visible artifacts share that one root cause.
//
//   FIX (Option A from the next-steps note): lower the S-curve top tangent
//   point to z = ext_h - top_edge_fillet_r = s_curve_top_z = 28.4 so it
//   matches the cap outer-edge top. The S-curve and cap are then
//   continuous at the corner.
//
//   GEOMETRIC CONSEQUENCE: the S-curve drop is now (28.4 - 10) = 18.4 mm
//   instead of 20 mm. Two equal-radius tangent-continuous quarter-arcs
//   give r_each = 9.2 (was 10) and total horizontal extent per side
//   2 * r_each = 18.4 (was 20). The flat front-wall middle widens
//   slightly (from [20, ext_w-20] to [18.4, ext_w-18.4]). Inflection
//   point per side moves from (10, 20) to (9.2, 19.2) — both X and Z
//   shift because the height drop is centered around the new midpoint.
//
//   The cutter polygon's outer-edge close drops from (ext_w+slop, ext_h)
//   down to (ext_w, s_curve_top_z) = (ext_w, 28.4) via a vertical step at
//   x=ext_w — and symmetrically on the LEFT — so the corner column's
//   outer edge top is carved down from 30 to 28.4, matching the cap apex.
//
//   On the INNER (flatten-arc-to-flat-top) profile, the outer-edge corner
//   vertices that used to be pinned at z=ext_h are now pinned at
//   z=s_curve_top_z=28.4 too, so the outer-side wall faces of the
//   front-wall-slab cutter are still vertical rectangles (not skewed
//   parallelograms) and the inner→outer Y-slab lerp produces a clean
//   ruled surface.
//
//   Bbox is unchanged (103.2 × 94.2 × 30) — the cap apex still reaches
//   z=ext_h=30 at the inner face of the back/side walls; only the
//   front-wall-slab cutter's outer-edge top z drops.
//
// Slides into the cradle's forward tray slot; catches auto-cut labels.
//
// ROUND-7 PATCH v10 (top-edge fillet alignment with cradle — Option C applied):
//
//   The brief frames the cradle and tray as two parts of a whole. The cradle
//   uses fillet_utility_r = 3.0 on a wall_thickness = 3.0 wall — i.e. r=wall_t
//   exactly. That gives a clean rolled cap that goes from the outer face up to
//   a point at the inner face, no clamp needed, no plateau. Patch v9 used
//   top_edge_fillet_r = 2.0 on wall_t = 1.6, which forced the inset clamp
//   (wall_t - 1.0 = 0.6 mm) and produced a small flat plateau at the very top
//   of the cap. Different visual language than the cradle.
//
//   v10 fix: top_edge_fillet_r 2.0 → 1.6 (= wall_t). The cap rolls cleanly
//   from outer face (z = ext_h - r = 28.4) up toward the inner face apex
//   (z = ext_h = 30) over the full wall thickness. Tray and cradle now share
//   the r = wall_t proportion — same design language, different absolute
//   numbers (3.0 mm vs 1.6 mm).
//
//   Option C (mask boundary pulled back 0.05 mm — actual watertight fix):
//   `back_sides_mask` y-extent pulled from `ext_d - wall_t = 92.6` back to
//   `ext_d - wall_t - 0.05 = 92.55`. Earlier patches (Option B, sub-FDM
//   clamp on the cap inset) tried to fix watertightness by adjusting the
//   cap rectangle's pre-clip width; that didn't help because the cap's
//   *clipped* front face is always at the mask boundary, not the
//   unclipped rectangle edge. The actual coincident-plane collision was
//   between the mask boundary at y=92.6 and the front-wall cutter's
//   inner-profile slop slab spanning y ∈ [92.599, 92.6] — three boundaries
//   on the same y-plane (mask edge, slop slab front face, slop slab back
//   face) producing 42–46 non-manifold edges in CGAL output.
//
//   Option C decouples by moving the mask edge to y=92.55. The 0.05 mm
//   strip y ∈ [92.55, 92.6] is INSIDE the cavity y-range (cavity ends at
//   y = ext_d - wall_t = 92.6), so for any z ≤ 31 the cap material that
//   would now extend through that strip gets cut by the cavity cutter
//   anyway. Net visual / material change: zero. Net topology change:
//   coincident planes decoupled, CGAL produces a clean watertight manifold.
//
//   Inset clamp (Option B) reverted: `clamp_inset` defaults to false again
//   (cap is geometrically fine without it now that the mask boundary is
//   the actual fix). The clamp branch survives in source as a dormant
//   defensive backstop — it engages only if a future radius bump pushes
//   raw_inset > wall_t, where it caps at `wall_t - 0.05 = 1.55`. Cap rolls
//   cleanly from outer face up to a point at the inner face apex, no
//   plateau, full r=wall_t proportion preserved.
//
//   Front-wall flat-top fillet at r = 0.8 (= half wall_t) is unchanged. The
//   thin-wall exception still reads cleaner than r = wall_t at 1.6 mm.
//
// ROUND-7 PATCH v9 (post-critique tray fixes — three issues):
//
//   Issue A — Bad fillet (lost design intent at the front-wall-top join).
//     The patch-v8 single quarter-arc r=20 had horizontal tangent at z=ext_h
//     (good — flush with side-wall top) but VERTICAL tangent at z=front_wall_h
//     (bad — meets the horizontal flat front-wall top at a 90° kink). The
//     design intent (round-7 brief) is a smooth, continuous concave sweep
//     tangent to BOTH ends.
//   Fix: replace the single r=20 arc with an S-curve composed of two
//     tangent-continuous quarter-arcs of r=10. For the LEFT side (mirrored
//     for right):
//       - Top arc:    center (0, ext_h - 10)              = (0, 20),  r=10
//                     sweep θ ∈ [0°, 90°]  (CCW from inflection up to outer)
//                     endpoints: (10, 20) → (0, 30)
//                     tangent at (0, 30) is HORIZONTAL (matches side-wall top).
//                     tangent at (10, 20) is VERTICAL  (inflection).
//       - Bottom arc: center (20, front_wall_h + 10)      = (20, 20), r=10
//                     sweep θ ∈ [270°, 180°] (CW from front-wall-top up to
//                     inflection)
//                     endpoints: (20, 10) → (10, 20)
//                     tangent at (20, 10) is HORIZONTAL (matches front-wall top).
//                     tangent at (10, 20) is VERTICAL  (inflection — matches
//                     top arc, so the join is C¹).
//     Total horizontal extent per side: 20 mm (same as the old r=20 arc).
//     Total Z drop per side: 20 mm. The flat front-wall-top middle remains
//     [20, ext_w-20] in x — same as before, so front_top_mask range and
//     ramp endpoint are unchanged.
//
//   Issue B — Triangular blade visible inside the bin at the corners.
//     The patch-v8 cutter was a 2D XZ profile linear-extruded along Y across
//     the full wall thickness. So at x near the corners, where the S-curve
//     reaches z≈ext_h, BOTH the outer face AND the inner face of the front
//     wall reached up to that height — the wall corner column read as a
//     full-height "blade" sticking up into the cavity from inside. That
//     contradicts the brief: from inside, the wall should appear at uniform
//     z=front_wall_h with a clean kanban lip.
//   Fix: the cutter is now built as a stack of thin Y-slabs that interpolate
//     between an INNER profile (flat top at z=front_wall_h, no S-curve) at
//     y = ext_d - wall_t and an OUTER profile (the full S-curve) at y = ext_d.
//     Linear interpolation across the wall thickness, evaluated at each
//     slab's center. Result: the wall-top SURFACE varies smoothly across the
//     wall_t = 1.6 mm depth — outer edge follows S-curve, inner edge stays
//     flat at z = front_wall_h. From inside the bin the front wall reads as
//     a uniform z=10 lip everywhere; the diagonal blade is gone. From outside
//     the S-curve sweep is preserved. The wall-top surface in the corner
//     zones slopes from z=10 (inner) up to z=arc(x) (outer) over 1.6 mm —
//     steepest at x=0 where the slope is (30-10)/1.6 = 12.5 (i.e. atan(1.6/20)
//     ≈ 4.6° from horizontal, well within FDM's 45° overhang limit). Prints
//     face-up with no supports.
//
//   Issue C — Visible slab-step ridges on the cap top + abrupt mating face
//     at y = ext_d - wall_t.
//   Fix (1): bump default top_fillet_steps from 24 → 48. Halves the slab
//     height to ~0.04 mm — invisible at any realistic viewing distance, still
//     cheap to render at draft.
//   Fix (2): with Issue B's fix landing, the corner column no longer has a
//     full-height vertical face inside the bin. The back_sides_mask y-clip
//     (kept from patch v8) ensures the cap-stack does not operate in the
//     front-wall slab at all — the cutter alone shapes the wall top there.
//     The mating boundary at y = ext_d - wall_t is now visually clean:
//     side-wall cap rolls in to z=ext_h-r ≈ 28..30, then the front-wall
//     slab takes over with the sloped wall top descending to z=10 at the
//     inner face. No slivers, no abrupt sharp edge — the slope IS the
//     transition.
//
// PATCH-V9 SCOPE
//
// Three fixes, all in tray.scad. Cradle is untouched.
//
// What survives unchanged from patch v9:
//   - Closed 4-wall bin architecture, interior 100×91×28.4 mm.
//   - Tray exterior 103.2 × 94.2 × 30 mm (X, Y, Z dims unchanged).
//   - Sliding fit, vertical fillet r=3, S-curve front-wall sweep (r=10 each),
//     front-wall top r=0.8, back_sides_mask y-clip at ext_d - wall_t,
//     interpolated front-wall-top cutter (Issue B fix from v9).
//   - Interior parabolic floor ramp.
//   - Print orientation: face-up, back on bed, no supports.
//
// What changed from patch v9:
//   - top_edge_fillet_r: 2.0 → 1.6 (= wall_t). Rolled cap matched to cradle.
//   - Inset clamp in footprint_fillet_stack disengaged by default
//     (clamp_inset = false). Dormant clamp branch retained as defensive
//     backstop at max_inset = wall_t - 0.05 if raw_inset ever exceeds
//     wall_t (impossible at r ≤ wall_t).
//   - back_sides_mask y-extent pulled from `ext_d - wall_t = 92.6` to
//     `ext_d - wall_t - 0.05 = 92.55`. The 0.05 mm gap lies inside the
//     cavity y-range so it has no visible material consequence (the cavity
//     cutter removes anything in that strip below z ≤ ext_h), but it
//     decouples the mask boundary from the front-wall cutter's inner-slop
//     slab and lets CGAL produce a watertight manifold. This was the
//     actual fix for the v10 watertight regression — Option B (sub-FDM
//     clamp) was load-bearing on the wrong cause.
//
// Print orientation:
//   FACE-UP (open top up), back on bed. S-curve side fillet sweeps and
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
//   $fn:                100 draft → 200 ship
//   top_fillet_steps:    48 draft →  96 ship  (was 24 draft / 64 ship — patch v9)
//   ramp_arc_steps:      32 draft →  96 ship
//   front_wall_y_slabs:  16 draft →  32 ship  (NEW — controls Y-slab count
//                                              for the front-wall-top 3D blend)
$fn                = 100;
top_fillet_steps   = 48;
ramp_arc_steps     = 32;
front_wall_y_slabs = 16;

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
front_wall_h                  = 10;     // single uniform height across full width

// Top edge fillet schedule
fillet_vert_r           = 3.0;    // exterior vertical edge fillets
top_edge_fillet_r       = 1.6;    // continuous fillet on back/sides wall tops
                                  //   = wall_t exactly. Mirrors the cradle's
                                  //   r=3 on its 3.0 mm wall (same r=wall_t
                                  //   proportion, different absolute). The
                                  //   cap rolls from the outer face (z =
                                  //   ext_h - r = 28.4) up the full wall
                                  //   thickness to a point at the inner
                                  //   face apex (z = ext_h = 30). No active
                                  //   clamp (clamp_inset defaults false);
                                  //   watertight manifold restored via
                                  //   Option C — back_sides_mask pulled
                                  //   back 0.05 mm — see header comment
                                  //   block + modeler-notes-v10.
front_top_edge_fillet_r = 0.8;    // smaller fillet on front wall top
                                  //   = half wall_t. Function-driven thin-wall
                                  //   exception — keeps the front lip soft
                                  //   without competing with the back/side cap.

// Patch v11: S-curve top tangent point lowered from z=ext_h to
// z = ext_h - top_edge_fillet_r so it MATCHES the side-wall cap's
// outer-edge top (the cap rolls from outer at z = ext_h - r up to the
// inner-face apex at z = ext_h). With the cap and the S-curve cutter
// landing at the same z on the outer edge, the front-wall corner column
// reads as one continuous surface — no gap, no thin front face. See
// header for full root-cause + fix-recipe context.
s_curve_top_z                 = ext_h - top_edge_fillet_r;   // 30 - 1.6 = 28.4

// Patch v9 → v11: the S-curve still uses TWO tangent-continuous quarter-arcs
// per side. With the lower top point the drop is now 18.4 mm and each arc
// radius is 9.2 mm (was 10). Total horizontal extent per side =
// 2 * r_each = 18.4 mm (was 20). The flat front-wall middle widens
// slightly — [front_wall_side_extent, ext_w - front_wall_side_extent]
// becomes [18.4, 84.8] (was [20, 83.2]).
front_wall_side_fillet_r_each = (s_curve_top_z - front_wall_h) / 2;       // 9.2
front_wall_side_extent        = 2 * front_wall_side_fillet_r_each;        // 18.4

// Interior floor ramp — concave (parabolic) curve. Unchanged.
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
assert(2 * front_wall_side_extent <= ext_w,
       "Side fillets overlap — reduce front_wall_side_fillet_r_each");
assert(front_wall_side_fillet_r_each * 2 == (s_curve_top_z - front_wall_h),
       "Patch v11: each S-curve arc r must equal half the (s_curve_top_z - front_wall_h) drop");
assert(s_curve_top_z == ext_h - top_edge_fillet_r,
       "Patch v11: S-curve top must match the side-wall cap outer-edge top (z = ext_h - top_edge_fillet_r)");
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

// ===== Front-wall top cutter — patch v9 → v11 =====
//
// The cutter is built as a stack of thin Y-slabs that interpolate between:
//
//   INNER profile (at y = ext_d - wall_t):
//     Flat top at z = front_wall_h across the full x range. The cutter
//     polygon is a simple rectangle (with the outer-edge corner-column
//     drop-step matching the OUTER profile so per-vertex lerp stays
//     vertical-edge-aligned).
//
//   OUTER profile (at y = ext_d):
//     The S-curve cutter polygon. For each side, two tangent-continuous
//     quarter-arcs of radius r_each = 9.2 (was 10 pre-v11) form the
//     S-curve from the corner-column outer-edge tangent point
//     (x=0 or x=ext_w, z=s_curve_top_z=28.4) down to the front-wall-top
//     inner endpoint (x=2*r_each or x=ext_w-2*r_each, z=front_wall_h=10).
//
//     PATCH v11: the S-curve top z dropped from ext_h (30) to
//     s_curve_top_z (28.4) so it MATCHES the side-wall cap's outer-edge
//     top — the cap and the S-curve are now continuous at the corner.
//     The polygon also now carves a vertical step from z=ext_h down to
//     z=s_curve_top_z at x=ext_w and x=0 (the corner-column outer edge),
//     so the corner column's outer-edge top sits at 28.4 — flush with
//     the cap.
//
//     LEFT S-curve (traversed (2*r_each, front_wall_h) → (r_each,
//                              front_wall_h+r_each) → (0, s_curve_top_z)):
//       bottom arc: center (2*r_each, front_wall_h+r_each)  = (18.4, 19.2)
//                   r=9.2, θ from 270° down to 180° (CW)
//                   endpoints: (18.4, 10) → (9.2, 19.2)
//       top arc:    center (0, s_curve_top_z - r_each)      = (0, 19.2)
//                   r=9.2, θ from 0° up to 90° (CCW)
//                   endpoints: (9.2, 19.2) → (0, 28.4)
//
//     RIGHT S-curve (traversed (ext_w, 28.4) → (ext_w-r_each,
//                               front_wall_h+r_each) → (ext_w-2*r_each,
//                               front_wall_h)):
//       top arc:    center (ext_w, s_curve_top_z - r_each)  = (ext_w, 19.2)
//                   r=9.2, θ from 90° up to 180° (CCW)
//                   endpoints: (ext_w, 28.4) → (ext_w-9.2, 19.2)
//       bottom arc: center (ext_w-2*r_each, front_wall_h+r_each)
//                                                            = (ext_w-18.4, 19.2)
//                   r=9.2, θ from 0° down to -90° (CW)
//                   endpoints: (ext_w-9.2, 19.2) → (ext_w-18.4, 10)
//
// Each slab is a thin linear_extrude across Y of the interpolated polygon.
// Linear interpolation parameter t = (y_center - (ext_d - wall_t)) / wall_t,
// clamped to [0, 1]. At t=0 the polygon is the INNER (flat) profile; at t=1
// the polygon is the OUTER (S-curve) profile. Intermediate t values produce
// a profile where the S-curve sweep is partially "flattened" toward the
// horizontal at z=front_wall_h.
//
// Implementation note: the polygon vertex count is the SAME at both ends.
// On the INNER profile, the arc samples are replaced by their flat-top
// projections (z forced to front_wall_h, x kept the same). The two
// outer-edge corner vertices (first sample of right_top_arc at
// (ext_w, s_curve_top_z); last sample of left_top_arc at (0, s_curve_top_z))
// are PINNED at z=s_curve_top_z on the INNER profile too — so the cutter's
// outer-side wall faces are vertical rectangles (not skewed parallelograms)
// and the inner→outer Y-slab lerp produces a clean ruled surface.
//
// Specifically, both INNER and OUTER profiles are walked in the same
// vertex order:
//   1.  (-slop, ext_h + slop)            top-left of cut region
//   2.  (ext_w + slop, ext_h + slop)     top-right of cut region
//   3.  (ext_w + slop, ext_h)            step down to right outer edge
//   4.  (ext_w, ext_h)                   right corner-column outer-top corner
//   5.  RIGHT top-arc samples            (ext_w, s_curve_top_z) → (ext_w - r_each, front_wall_h + r_each)
//   6.  RIGHT bottom-arc samples         → (ext_w - 2*r_each, front_wall_h)
//   7.  (LEFT bottom-arc samples)        (2*r_each, front_wall_h) → (r_each, front_wall_h + r_each)
//   8.  (LEFT top-arc samples)           → (0, s_curve_top_z)
//   9.  (0, ext_h)                       left corner-column outer-top corner
//  10.  (-slop, ext_h)                   step up to left slop edge
//       (closes back to 1.)
// (The slop margin at the top — between z=ext_h and z=ext_h+slop — clears
// any cap material above the wall top. The vertical edges at x=ext_w and
// x=0 from z=ext_h down to z=s_curve_top_z carve the corner column's
// outer-edge top down to the cap apex.)

function _arc_pts(cx, cz, r, a_start_deg, a_end_deg, n) =
    [for (i = [0 : n])
        let(t = i / n,
            a = a_start_deg + t * (a_end_deg - a_start_deg))
        [cx + r * cos(a), cz + r * sin(a)]
    ];

// Build the OUTER (full S-curve) cutter polygon vertex list.
// Patch v11: arc centers shifted from (·, ext_h - r) to (·, s_curve_top_z - r)
// so the S-curve top tangent point lands at z=s_curve_top_z=28.4 (= cap
// outer-edge top), not z=ext_h=30. Explicit (ext_w, ext_h) and (0, ext_h)
// vertices added to carve the corner column's outer-edge top down from
// ext_h to s_curve_top_z.
function _front_wall_top_cutter_pts_outer() =
    let(slop = 1.0,
        n   = top_fillet_steps,
        r   = front_wall_side_fillet_r_each,
        // RIGHT top arc: center (ext_w, s_curve_top_z - r), θ ∈ [90°, 180°] CCW.
        //   θ=90°:  (ext_w, s_curve_top_z)        — outer edge top, horizontal tangent (matches cap apex)
        //   θ=180°: (ext_w - r, s_curve_top_z - r) — inflection, vertical tangent
        right_top_arc = _arc_pts(
            ext_w, s_curve_top_z - r,
            r, 90, 180, n),
        // RIGHT bottom arc: center (ext_w - 2r, front_wall_h + r), θ ∈ [0°, -90°] CW.
        //   θ=0°:   (ext_w - r, front_wall_h + r)  — inflection, vertical tangent
        //   θ=-90°: (ext_w - 2r, front_wall_h)     — front-wall-top inner endpt, horizontal tangent
        right_bot_arc = _arc_pts(
            ext_w - 2*r, front_wall_h + r,
            r, 0, -90, n),
        // LEFT bottom arc: center (2r, front_wall_h + r), θ ∈ [270°, 180°] CW.
        //   θ=270°: (2r, front_wall_h)             — front-wall-top inner endpt, horizontal tangent
        //   θ=180°: (r, front_wall_h + r)          — inflection, vertical tangent
        left_bot_arc = _arc_pts(
            2*r, front_wall_h + r,
            r, 270, 180, n),
        // LEFT top arc: center (0, s_curve_top_z - r), θ ∈ [0°, 90°] CCW.
        //   θ=0°:  (r, s_curve_top_z - r) — inflection, vertical tangent
        //   θ=90°: (0, s_curve_top_z)     — outer edge top, horizontal tangent (matches cap apex)
        left_top_arc = _arc_pts(
            0, s_curve_top_z - r,
            r, 0, 90, n))
    concat(
        [[-slop, ext_h + slop]],                 // 1.  top-left of cut region
        [[ext_w + slop, ext_h + slop]],          // 2.  top-right of cut region
        [[ext_w + slop, ext_h]],                 // 3.  step down to right outer edge at z=ext_h
        [[ext_w, ext_h]],                        // 4.  right corner-column outer-top corner
        right_top_arc,                            // 5.  (ext_w, s_curve_top_z)→(ext_w-r, s_curve_top_z-r)
        right_bot_arc,                            // 6.  →(ext_w-2r, front_wall_h)
        // implicit straight: (ext_w-2r, front_wall_h) → (2r, front_wall_h)
        left_bot_arc,                             // 7.  (2r, front_wall_h)→(r, front_wall_h+r)
        left_top_arc,                             // 8.  →(0, s_curve_top_z)
        [[0, ext_h]],                             // 9.  left corner-column outer-top corner
        [[-slop, ext_h]]                          // 10. step up toward top-left slop close
        // closes back to 1.
    );

// Build the INNER (flat-top) cutter polygon. Same vertex order/count as
// _outer; arc samples are projected to the flat top at z=front_wall_h
// (their x is kept unchanged so per-vertex linear interpolation produces
// a clean ruled surface across Y).
//
// Patch v11: the two outer-edge corner vertices (first sample of
// right_top_arc at (ext_w, s_curve_top_z); last sample of left_top_arc at
// (0, s_curve_top_z)) are pinned at z = s_curve_top_z on the INNER profile
// — matching the OUTER profile's z value at those vertices — so the
// cutter's vertical outer-edge wall faces are flat rectangles, not skewed
// parallelograms. (Pre-v11 they were pinned at z=ext_h, which matched the
// pre-v11 OUTER value.)
function _flatten_arc_to_flat_top(pts, keep_first_z, keep_last_z) =
    [for (i = [0 : len(pts) - 1])
        let(p = pts[i],
            keep = (i == 0 && keep_first_z) ||
                   (i == len(pts) - 1 && keep_last_z))
        [p[0], keep ? p[1] : front_wall_h]
    ];

function _front_wall_top_cutter_pts_inner() =
    let(slop = 1.0,
        n   = top_fillet_steps,
        r   = front_wall_side_fillet_r_each,
        // Same outer-profile arc samples (we only flatten the Z values).
        right_top_arc = _arc_pts(ext_w, s_curve_top_z - r,
                                 r, 90, 180, n),
        right_bot_arc = _arc_pts(ext_w - 2*r, front_wall_h + r,
                                 r, 0, -90, n),
        left_bot_arc  = _arc_pts(2*r, front_wall_h + r,
                                 r, 270, 180, n),
        left_top_arc  = _arc_pts(0, s_curve_top_z - r,
                                 r, 0, 90, n),
        // Flatten arcs to z=front_wall_h, but pin the outer-edge corner
        // vertices at their natural arc-endpoint z (= s_curve_top_z) so
        // the outer side faces stay vertical.
        right_top_flat = _flatten_arc_to_flat_top(right_top_arc, true,  false),
        right_bot_flat = _flatten_arc_to_flat_top(right_bot_arc, false, false),
        left_bot_flat  = _flatten_arc_to_flat_top(left_bot_arc,  false, false),
        left_top_flat  = _flatten_arc_to_flat_top(left_top_arc,  false, true))
    concat(
        [[-slop, ext_h + slop]],                 // 1.
        [[ext_w + slop, ext_h + slop]],          // 2.
        [[ext_w + slop, ext_h]],                 // 3.
        [[ext_w, ext_h]],                        // 4.  corner-column outer-top corner
        right_top_flat,                          // 5.
        right_bot_flat,                          // 6.
        left_bot_flat,                           // 7.
        left_top_flat,                           // 8.
        [[0, ext_h]],                            // 9.  corner-column outer-top corner
        [[-slop, ext_h]]                         // 10.
    );

// Linearly interpolate two equal-length vertex lists at parameter t ∈ [0, 1].
function _lerp_pts(a, b, t) =
    [for (i = [0 : len(a) - 1])
        [a[i][0] * (1 - t) + b[i][0] * t,
         a[i][1] * (1 - t) + b[i][1] * t]
    ];

// Y-slab extents. We extrude across [ext_d - wall_t, ext_d] split into
// front_wall_y_slabs slabs. A small slop margin extends the inner slab
// inward by 0.001 (cleanly cuts through the inner face boundary) and the
// outer slab outward by 1.0 (cleanly clears the outer face).
//
// Inside each slab i ∈ [0, n_slabs - 1], the polygon is the linear
// interpolation of (inner, outer) at t = (i + 0.5) / n_slabs.
//
// At t = 0.0 (innermost slab): polygon ≈ inner (flat-top profile)
// At t = 1.0 (outermost slab): polygon ≈ outer (full S-curve)
// Intermediate slabs: profile sweeps the wall top from flat to S-curve.

module front_wall_top_cutter() {
    inner_pts = _front_wall_top_cutter_pts_inner();
    outer_pts = _front_wall_top_cutter_pts_outer();
    n_slabs   = front_wall_y_slabs;
    slop_inner = 0.001;
    slop_outer = 1.0;
    y_back  = ext_d - wall_t;       // inner face (cavity side)
    y_front = ext_d;                // outer face

    // Pre-slab: extend the innermost slab back by slop_inner so the cut
    // cleanly clips through the cavity-front face boundary.
    translate([0, y_back - slop_inner, 0])
        rotate([90, 0, 0])
            linear_extrude(height = slop_inner + 0.001)
                polygon(points = inner_pts);

    // Interpolated slabs across the wall thickness.
    for (i = [0 : n_slabs - 1]) {
        t  = (i + 0.5) / n_slabs;
        y0 = y_back + (y_front - y_back) * (i / n_slabs);
        y1 = y_back + (y_front - y_back) * ((i + 1) / n_slabs);
        pts = _lerp_pts(inner_pts, outer_pts, t);
        // rotate([90,0,0]) about origin maps (x,z) → (x,-y'); to translate
        // a slab to start at y=y0 and end at y=y1, use translate([0, y1, 0])
        // because the rotated extrusion grows in -y; equivalently translate
        // to y1 and extrude (y1-y0) downward in the rotated frame.
        translate([0, y1, 0])
            rotate([90, 0, 0])
                linear_extrude(height = y1 - y0 + 0.001)
                    polygon(points = pts);
    }

    // Post-slab: extend the outermost slab forward by slop_outer so the cut
    // cleanly clips through the outer face.
    translate([0, y_front + slop_outer, 0])
        rotate([90, 0, 0])
            linear_extrude(height = slop_outer + 0.001)
                polygon(points = outer_pts);
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
//   (a) r = wall_t = 1.6 on back + side wall tops at z = ext_h, restricted
//       to the back-and-sides region (y < ext_d - wall_t - 0.05 plus
//       side-wall corner buffers, all clipped at the same y bound — Option
//       C, see header). Mirrors the cradle's r = wall_t cap (r=3 on a 3
//       mm wall) — same proportion, different absolute number. Cap rolls
//       from outer face up to a point at the inner face apex.
//   (b) r = 0.8 (= half wall_t) on the front-wall flat top at z =
//       front_wall_h, restricted to the flat segment between the two
//       S-curve sweeps. Function-driven thin-wall exception.
//
// clamp_inset: dormant defensive backstop. Default false — at r ≤ wall_t,
// raw_inset never exceeds wall_t so the clamp does nothing. If a future
// radius bump pushes r > wall_t the clamp engages at max_inset = wall_t -
// 0.05 to preserve a sub-FDM safety margin. Watertight manifold for the
// current r=wall_t configuration is restored via Option C (back_sides_mask
// pulled back 0.05 mm), not via this clamp.

module footprint_fillet_stack(top, r, n, clamp_inset = false) {
    max_inset = clamp_inset ? max(0.001, wall_t - 0.05) : r;
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

// Mask for the back-and-sides region. Excludes the front-wall slab from
// the cap-carve / cap-add stack. Patch-v10 Option C: y-extent pulled from
// `ext_d - wall_t = 92.6` back to `ext_d - wall_t - 0.05 = 92.55` so the
// mask boundary no longer coincides with the front-wall cutter's
// inner-profile slop slab at y ∈ [92.599, 92.6]. The 0.05 mm strip
// y ∈ [92.55, 92.6] is inside the cavity y-range, so any cap material
// continuing through it is removed by the cavity cutter for z ≤ ext_h.
// No visible material change; coincident planes decoupled; CGAL produces
// a watertight manifold.
module back_sides_mask() {
    union() {
        translate([-1, -1, -1])
            cube([ext_w + 2, ext_d - wall_t - 0.05 + 1,
                  ext_h + top_edge_fillet_r + 2]);
        translate([-1, -1, -1])
            cube([fillet_vert_r + 1, ext_d - wall_t - 0.05 + 1,
                  ext_h + top_edge_fillet_r + 2]);
        translate([ext_w - fillet_vert_r - 0.001, -1, -1])
            cube([fillet_vert_r + 1, ext_d - wall_t - 0.05 + 1,
                  ext_h + top_edge_fillet_r + 2]);
    }
}

// Mask for the front-wall flat-top region. Restrict to the X range on
// the FLAT segment between the two S-curve side-fillet sweeps. The
// side-fillet zones are excluded so the r=0.8 roll doesn't fight the
// S-curve curvature.
module front_top_mask() {
    x_left  = wall_t + front_wall_side_extent;
    x_right = ext_w - wall_t - front_wall_side_extent;
    translate([x_left, ext_d - wall_t - 0.001, -1])
        cube([x_right - x_left,
              wall_t + 1.001 + 0.5,
              front_wall_h + front_top_edge_fillet_r + 2]);
}

// Front-wall flat-top fillet stack. r=0.8 < wall_t-1.0, no clamp needed.
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
            slop = 0.5;
            intersection() {
                translate([-1, -1, ext_h - top_edge_fillet_r])
                    cube([ext_w + 2, ext_d + 2, top_edge_fillet_r + slop]);
                back_sides_mask();
            }
            intersection() {
                translate([-1, -1, front_wall_h - front_top_edge_fillet_r])
                    cube([ext_w + 2, ext_d + 2, front_top_edge_fillet_r + slop]);
                front_top_mask();
            }
        }
        intersection() {
            footprint_fillet_stack(ext_h, top_edge_fillet_r, top_fillet_steps);
            back_sides_mask();
        }
        intersection() {
            front_wall_top_fillet_stack();
            front_top_mask();
        }
    }
}

// ===== Interior cavity =====
//
// Y-Z polygon walked CCW, extruded across the interior X span
// (x = wall_t .. ext_w - wall_t). Unchanged.

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
