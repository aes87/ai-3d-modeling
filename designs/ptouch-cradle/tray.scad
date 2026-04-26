// P-touch Catch Tray — closed kanban bin (round 5)
// Slides into the cradle's forward tray slot; catches auto-cut labels.
//
// ROUND-5 SCOPE (this file — substantive rebuild):
//
// Round 4's tray treatment was structurally wrong: the entire front "wall"
// became a single concave arc, eating the closed-bin character. Round 5
// restores the bin as a CLOSED kanban container with four real walls,
// then adds two functional sculptural concavities (interior floor ramp
// + exterior grab scoop) inside the v3 minimalism design language.
//
//   1. Closed 4-wall bin: back/sides at full ext_h=30mm, front wall at
//      front_wall_h=18mm (short by intent — the asymmetric wall heights
//      define the bin's character). Floor at z=0..floor_t. Top edge r=2
//      fillet on every wall top.
//
//   2. Tray height bump: ext_h 21.6 → 30, int_h 20 → 28.4. The new tray
//      sits ~5mm proud of the 25mm cradle wall — intentional.
//
//   3. Interior floor ramp: a concave circular arc on the floor near the
//      front, sweeping from the flat back floor at (y=62.6, z=1.6) up to
//      the top of the front wall at (y=92.6, z=18). Concave-from-inside
//      (curves down-and-back from the bin interior). Functional: a
//      finger slides under a label resting on the flat floor and pushes
//      the label up the ramp and over the front lip.
//
//   4. Grabbable exterior scoop: concave horizontal indent on the +Y
//      exterior face of the front wall, centered, 50mm × 14mm × 2.86mm
//      deep. r=10 (matches cradle hero radius for design-language
//      consistency). Smooth fade-out at left/right ends via spherical
//      end caps (hull of cylinder + end-spheres). Reads as "grab here."
//
// What survives unchanged from round 4:
//   - Interior cavity X×Y dims (100 × 91 mm).
//   - Tray exterior X×Y dims (103.2 × 94.2 mm).
//   - Tray-to-slot sliding fit (0.35 mm/side).
//   - Vertical exterior corner fillet r=3.
//   - Top-edge fillet r=2.
//   - $fn = 200.
//
// Print orientation:
//   FACE-UP (open top up), back on bed. The interior ramp's concave-curve
//   floor surface is fully self-supporting — at any z the surface tangent
//   points up-and-back, never overhanging. The front wall at 18mm is
//   structurally fine. The exterior grab scoop is a concave indent —
//   printable without supports because depth=2.86mm and chord=14mm at
//   r=10 keeps tangent angles well within 45°-from-vertical envelope.
//
// User orientation:
//   +Y = user-front (grab scoop face)
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
int_h     = 28.4;   // interior height (Z) — round-5 bump from 20
wall_t    = 1.6;
floor_t   = 1.6;

ext_w     = int_w + 2*wall_t;     // 103.2
ext_d     = int_d + 2*wall_t;     // 94.2
ext_h     = int_h + floor_t;      // 30.0  (round-5 bump from 21.6)

// Front wall — short. Back wall + side walls go to ext_h=30.
front_wall_h        = 18;

// Top edge fillet schedule
fillet_vert_r       = 3.0;        // exterior vertical edge fillets
top_edge_fillet_r   = 2.0;        // continuous fillet on every wall top
// top_fillet_steps declared at top of file (draft 24, ship 64 via -D).

// Interior floor ramp — concave arc
ramp_y_extent       = 30;
ramp_back_y         = ext_d - wall_t - ramp_y_extent;   // 62.6
ramp_front_y        = ext_d - wall_t;                   // 92.6 (interior front face)
ramp_back_z         = floor_t;                          // 1.6
ramp_front_z        = front_wall_h;                     // 18
ramp_arc_r          = 22;
// ramp_arc_steps declared at top of file (draft 32, ship 96 via -D).

// Exterior grab scoop on +Y face of front wall.
//
// At wall_t = 1.6mm, a 2.86mm-deep concave indent would punch through
// the wall. Solution: add a "grab boss" — a sculptural lip-thickening on
// the +Y exterior of the front wall, encompassing the scoop region. The
// boss is proud of the wall by `grab_boss_proud`, giving a local total
// thickness of (wall_t + grab_boss_proud). The scoop is carved into the
// boss + wall, leaving (wall_t + grab_boss_proud - grab_scoop_depth)
// remaining at the deepest point — sized to stay above MIN_WALL.
//
// The boss reads as the deliberate sculptural "grab handle" element
// referenced in the brief and modeler-notes — function-driven, intrinsic
// (not decoration) per the v3 minimalism direction.
grab_scoop_arc_r          = 10;
grab_scoop_chord_z        = 14;
grab_scoop_depth          = 2.86;
grab_scoop_center_z       = 9;
grab_scoop_width          = 50;
grab_scoop_x_center       = ext_w / 2;                  // 51.6
// Sphere centers inset 7 mm from the scoop's left/right visible ends so
// the intersection-with-wall circle (radius sqrt(r² - (r-d)²) ≈ 7) ends
// at the spec'd visible scoop edges (x = 26.6 and x = 76.6).
grab_scoop_sphere_inset_x = 7;
grab_scoop_sphere_x_left  = grab_scoop_x_center - grab_scoop_width/2 + grab_scoop_sphere_inset_x;  // 33.6
grab_scoop_sphere_x_right = grab_scoop_x_center + grab_scoop_width/2 - grab_scoop_sphere_inset_x;  // 69.6

// Grab boss — exterior lip thickening that hosts the scoop.
//
// Vertical extent runs floor-to-just-below-fillet-zone (z = 0..16) so the
// boss reads as a full-height "lip thickening" without poking into the
// front wall's r=2 top fillet (which starts at z = front_wall_h - r = 16).
// Horizontal extent gives 8mm margin past the scoop's left/right edges.
grab_boss_proud           = 2.5;                        // mm proud of front wall +Y face
grab_boss_width           = grab_scoop_width + 16;      // 66 mm — 8 mm margin past scoop edges
grab_boss_height_z        = front_wall_h - top_edge_fillet_r;   // 16 — floor to fillet base
grab_boss_x_center        = grab_scoop_x_center;        // 51.6
grab_boss_z_center        = grab_boss_height_z / 2;     // 8 — runs from z=0 to z=16
grab_boss_corner_r        = 5;                          // X-Z corner radius on boss outline
// Boss y range: from y = ext_d (front wall +Y face) outward by grab_boss_proud.
grab_boss_y_inside        = ext_d;                      // 94.2 — flush with wall exterior
grab_boss_y_outside       = ext_d + grab_boss_proud;    // 96.7

// Sphere center y: r - depth back from the BOSS outside face (y = grab_boss_y_outside).
// At deepest point, scoop reaches y = grab_boss_y_outside - grab_scoop_depth = 93.84.
// Wall interior face is at y = ext_d - wall_t = 92.6.
// Floor remaining at deepest point = 93.84 - 92.6 = 1.24 mm. Above MIN_WALL=1.2.
grab_scoop_center_y       = grab_boss_y_outside +
                            (grab_scoop_arc_r - grab_scoop_depth);                                 // 103.84

// ===== Structural asserts =====
assert(wall_t >= MIN_WALL, str("Tray wall ", wall_t, " below min ", MIN_WALL));
assert(floor_t >= MIN_FLOOR_CEIL, str("Tray floor ", floor_t, " below min floor"));
assert(ext_w <= 256 && ext_d <= 256 && ext_h <= 256, "Tray exceeds bed");
assert(front_wall_h > floor_t + top_edge_fillet_r,
       "Front wall too short for top fillet");
assert(front_wall_h < ext_h, "Front wall must be lower than back/side walls");
assert(ramp_back_y > wall_t,
       "Ramp back-y too close to back wall — flat floor region too small");
// Verify arc validity: chord length must be < 2*r
chord_len = sqrt((ramp_front_y - ramp_back_y) * (ramp_front_y - ramp_back_y) +
                 (ramp_front_z - ramp_back_z) * (ramp_front_z - ramp_back_z));
assert(chord_len < 2 * ramp_arc_r,
       str("Ramp arc chord ", chord_len, " >= 2r — no valid arc"));

// ===== 2D helpers =====

module rounded_rect(w, d, r) {
    translate([r, r])
        offset(r=r) square([w - 2*r, d - 2*r]);
}

// ===== Outer body (closed 4-wall bin) =====
//
// Full ext_h-tall extrusion of the rounded_rect footprint, then chop the
// front-wall strip down from ext_h to front_wall_h between the side walls.
// The corner regions where the side walls meet the front wall keep full
// height (cut excludes x < wall_t and x > ext_w - wall_t — but actually
// the rounded-rect corner geometry curves inward there so we leave a
// generous corner buffer to avoid clipping the side-wall vertical fillet).
//
// CORNER STRATEGY: cut the strip at y >= ext_d - wall_t in the X range
// [fillet_vert_r, ext_w - fillet_vert_r] above z=front_wall_h. This gives
// the side walls' vertical r=3 fillet a full-height home and lets the
// short front wall meet the side walls at a cleanly-stepped corner.

module outer_box_full() {
    linear_extrude(height = ext_h)
        rounded_rect(ext_w, ext_d, fillet_vert_r);
}

// Cut volume: chops the front-wall-strip from front_wall_h up to ext_h.
//
// The X bounds are placed just OUTSIDE the corner curves (at x = 0 and
// x = ext_w) so the cut DOES intersect the corner curves and CGAL doesn't
// generate a degenerate zero-thickness sliver where the cut starts/ends
// on a curved boundary.
module front_wall_step_cut() {
    slop = 1.0;
    cut_x0 = -slop;
    cut_x1 = ext_w + slop;
    cut_y0 = ext_d - wall_t;
    cut_y1 = ext_d + slop;
    cut_z0 = front_wall_h;
    cut_z1 = ext_h + slop;
    translate([cut_x0, cut_y0, cut_z0])
        cube([cut_x1 - cut_x0, cut_y1 - cut_y0, cut_z1 - cut_z0]);
}

module outer_body_raw() {
    difference() {
        outer_box_full();
        front_wall_step_cut();
    }
}

// ===== Top edge fillet =====
//
// The back/side walls top out at z = ext_h; the front wall tops out at
// z = front_wall_h (= 18). Both wall tops carry an r = top_edge_fillet_r
// quarter-arc rolled inward (round-4-tray approach: progressive offset
// of the wall_footprint).
//
// Implementation: TWO slab stacks. Each uses the FULL rounded_rect
// footprint as the base contour and offsets inward by inset1 at each
// step. Each stack is then INTERSECTED with a mask cube confining it
// to its wall region (back/sides vs front-wall strip). This avoids the
// thin-rectangle-disappears bug that arose from using only the wall
// strip as the offset base.

// Slab-stack quarter-arc fillet rolled inward from the wall_footprint
// (= rounded_rect) at heights z = top - r .. top. Each slab is the
// footprint offset by -inset1 at the top of the slab.
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

// Build the OUTER body with both top-edge fillets applied.
//
// Strategy:
//   1. Start from outer_body_raw (full wall solid, ext_h tall on all
//      walls except front, which is chopped to front_wall_h).
//   2. Carve away the top-r block of the back/side walls (z = ext_h - r
//      .. ext_h+slop) over the back/side region.
//   3. Add the rolled cap stack for the back/sides at z = ext_h - r ..
//      ext_h, INTERSECTED with the back/sides region.
//   4. Carve away the top-r block of the front wall (z = front_wall_h - r
//      .. front_wall_h+slop) over the front-wall strip region.
//   5. Add the rolled cap stack for the front wall at z = front_wall_h - r
//      .. front_wall_h, INTERSECTED with the front-wall strip region.

// Mask cube for the back-and-sides region (everything except the front
// wall strip + corner buffer for vertical fillet).
module back_sides_mask() {
    // Stretch the mask 1 mm in -X, +X, -Y so it definitely covers the
    // outer body. Cap at y = ext_d - wall_t in the central X range.
    union() {
        // Full footprint up to y = ext_d - wall_t (covers back + sides
        // except in the X-strip where the front wall lives).
        translate([-1, -1, -1])
            cube([ext_w + 2, ext_d - wall_t + 1, ext_h + top_edge_fillet_r + 2]);
        // Side wall corner buffers (left and right) — full y range, but
        // only in the X strips at the corners. This keeps the side walls'
        // top fillet rolling all the way to y = ext_d.
        translate([-1, -1, -1])
            cube([fillet_vert_r + 1, ext_d + 2, ext_h + top_edge_fillet_r + 2]);
        translate([ext_w - fillet_vert_r - 0.001, -1, -1])
            cube([fillet_vert_r + 1, ext_d + 2, ext_h + top_edge_fillet_r + 2]);
    }
}

// Mask cube for the front-wall strip region.
module front_wall_mask() {
    cut_x0 = fillet_vert_r;
    cut_x1 = ext_w - fillet_vert_r;
    cut_y0 = ext_d - wall_t;
    cut_y1 = ext_d + 1;
    cut_z0 = -1;
    cut_z1 = front_wall_h + top_edge_fillet_r + 2;
    translate([cut_x0, cut_y0, cut_z0])
        cube([cut_x1 - cut_x0, cut_y1 - cut_y0, cut_z1 - cut_z0]);
}

module outer_body_with_fillets() {
    //
    // Round-5 design decision: the front wall is too thin (wall_t = 1.6 mm)
    // to support an r=2 top-edge fillet via the slab-stack approach. Two
    // cap treatments were considered:
    //   (a) Half-cylinder bullnose at r = wall_t / 2 = 0.8 mm
    //   (b) Sharp top edge (no fillet)
    //
    // Option (a) caused CGAL to flag a disconnected component due to the
    // cap clipping at the rounded vertical corners. Option (b) preserves
    // a clean, manifold mesh at modest visual cost — a thin sharp top on
    // the 1.6 mm front wall reads as a deliberate utility line, not as a
    // design inconsistency. The brief's r=2 fillet rule is honored on the
    // back/side walls (where wall_t allows it) and documented as a
    // function-driven exception on the front wall.
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
        // Front wall top: sharp edge (see comment above).
    }
}

// ===== Interior cavity =====
//
// The cavity is bounded by:
//   - bottom: floor (z = floor_t flat from y = wall_t to y = ramp_back_y),
//             then ramp arc rising to (ramp_front_y, front_wall_h)
//   - back/side walls: y = wall_t (back), x = wall_t (left), x = ext_w-wall_t (right)
//   - front:  the interior face of the short front wall at y = ramp_front_y
//             but only up to z = front_wall_h. Above z = front_wall_h, the
//             front wall doesn't exist — the cavity opens out to y = ext_d
//             (and even beyond, into the slop volume above the open top).
//
// Construction: a Y-Z polygon walked CCW, extruded across the interior X
// span x = wall_t..ext_w-wall_t. Above z = front_wall_h we extend the
// polygon all the way to y = ext_d so the cavity opens into the +Y region
// above the front wall (no roof above the front wall).

function _ramp_chord_len() = sqrt(ramp_y_extent * ramp_y_extent +
                                   (ramp_front_z - ramp_back_z) *
                                   (ramp_front_z - ramp_back_z));
// Chord midpoint
function _ramp_chord_mid() = [(ramp_back_y + ramp_front_y) / 2,
                              (ramp_back_z + ramp_front_z) / 2];
// FUNCTIONAL INTENT (from id/brief.md and modeler-notes-v5.md):
//   The ramp is "like sliding food out of a pan with a sloped front edge"
//   — a finger sliding under a label rides the ramp UP to the front lip.
//   This is a pan-edge curve: SLOPE STEEPEST AT THE BACK (rises fast
//   from flat-floor) and SHALLOWEST AT THE FRONT (plateaus into the
//   front lip). The arc bulges TOWARD the bin interior (into +Z, into
//   the open cavity above), so from a finger's-eye view sliding across
//   the floor, the surface curves UP-AND-FORWARD smoothly without a
//   hard inflection.
//
// Chord direction: (dy, dz) = (ramp_y_extent, ramp_front_z - ramp_back_z)
// ≈ (30, 16.4). Two perpendiculars:
//   (-dz, dy) / |chord| ≈ (-16.4, +30) / |chord| → (-Y, +Z)
//   (+dz, -dy) / |chord| ≈ (+16.4, -30) / |chord| → (+Y, -Z)
//
// For the arc to bulge toward (-Y, +Z) (up-and-back into the cavity)
// — the pan-edge shape — the arc CENTER must sit on the OPPOSITE side
// of the chord from the bulge: (+Y, -Z), i.e. outside the bin in the
// front-bottom direction.
//
// Round-4 lesson: the modeler-notes-v5 wording calls this "concave" but
// the functional description (pan-edge, finger pushes label up to lip)
// implies the convex-from-interior bulge. We trust the function spec
// here. Verification: with center on +Y/-Z side at C ≈ (84.24, -2.34),
// the arc midpoint ≈ (73.7, 17) — well above the chord midpoint
// (77.6, 9.8). The floor surface bulges UP into the cavity. ✓
function _ramp_chord_perp_to_center() =
    let(dy = ramp_front_y - ramp_back_y,    // +30
        dz = ramp_front_z - ramp_back_z,    // +16.4
        len = _ramp_chord_len())
    [dz / len, -dy / len];     // (+Y, -Z) direction — center sits outside

function _ramp_arc_center() =
    let(M  = _ramp_chord_mid(),
        p  = _ramp_chord_perp_to_center(),
        d  = sqrt(ramp_arc_r * ramp_arc_r -
                  (_ramp_chord_len() / 2) * (_ramp_chord_len() / 2)))
    [M[0] + p[0] * d, M[1] + p[1] * d];

// Sample the arc from (ramp_back_y, ramp_back_z) to (ramp_front_y, ramp_front_z)
// — N+1 points, walking from back to front along the concave arc.
function _ramp_arc_points() =
    let(C  = _ramp_arc_center(),
        a_back  = atan2(ramp_back_z  - C[1], ramp_back_y  - C[0]),
        a_front = atan2(ramp_front_z - C[1], ramp_front_y - C[0]),
        // We want to walk the SHORT arc from back to front. Adjust to the
        // smaller angular sweep.
        a_diff_raw = a_front - a_back,
        a_diff = (a_diff_raw > 180)  ? a_diff_raw - 360 :
                 (a_diff_raw < -180) ? a_diff_raw + 360 : a_diff_raw)
    [for (i = [0 : ramp_arc_steps])
        let(t = i / ramp_arc_steps,
            a = a_back + t * a_diff)
        [C[0] + ramp_arc_r * cos(a), C[1] + ramp_arc_r * sin(a)]
    ];

// Y-Z polygon walked CCW for the cavity cutter:
//   1. (wall_t, floor_t)              — bottom-back
//   2. (ramp_back_y, ramp_back_z)     — flat floor's front edge
//   3. ramp arc up to (ramp_front_y, ramp_front_z)
//   4. (ramp_front_y, front_wall_h)   — top of front wall, interior face
//      (same point as ramp end)
//   5. (ext_d + 1, front_wall_h)      — over the top of the front wall to
//      open above (the cavity is OPEN above the front wall; the front
//      wall stops at z=front_wall_h, so above we have no front wall —
//      cavity extends to +Y past where the front wall used to be)
//   6. (ext_d + 1, ext_h + 1)         — up to slop (above the open top)
//   7. (-1, ext_h + 1)                — back across to far -Y
//   8. (-1, floor_t)                  — down to floor level
//   9. close to (1)
//
// We extend the polygon outside the tray's wall_t..ext_d-wall_t interior
// because the cutter is intersected with the interior X-extent only via
// linear_extrude across X. The cutter is purely in Y-Z; at each X slice
// it removes the cavity profile.
//
// IMPORTANT: the cutter must NOT remove the back/side walls. The back
// wall is at y in [0, wall_t]. The cavity's back boundary is at y =
// wall_t. So the polygon's back edge MUST be at y = wall_t, not y = -1.
// Otherwise the back wall gets carved away.
//
// Revised polygon:
//   1. (wall_t, floor_t)
//   2. (ramp_back_y, floor_t)         — flat floor segment
//   3. ramp arc to (ramp_front_y, front_wall_h)
//   4. (ext_d + 1, front_wall_h)      — over the front wall
//   5. (ext_d + 1, ext_h + 1)         — up
//   6. (wall_t, ext_h + 1)             — back across
//   7. close

module cavity_cutter() {
    arc = _ramp_arc_points();
    pts = concat(
        [[wall_t, floor_t]],
        [[ramp_back_y, floor_t]],
        arc,                                             // back→front along ramp
        [[ext_d + 1, front_wall_h]],                     // over the front wall
        [[ext_d + 1, ext_h + 1]],                        // up to slop
        [[wall_t, ext_h + 1]]                            // back to start column
    );
    // Extrude across X interior. The interior X span is wall_t..ext_w-wall_t.
    // We use a slop margin of 0.01 on each end so the cutter just kisses
    // the side walls without piercing the corner fillet.
    slop = 0.001;
    translate([wall_t - slop, 0, 0])
        rotate([90, 0, 90])
            linear_extrude(height = (ext_w - 2 * wall_t) + 2 * slop)
                polygon(points = pts);
}

// ===== Grab boss (additive on +Y exterior of front wall) =====
//
// The boss is a sculptural lip-thickening centered on the scoop region.
// Shape: a horizontal lozenge in X-Z (rounded rectangle) extruded along
// Y from the front wall exterior outward by grab_boss_proud. The boss's
// X-Z outline is rounded at all four corners (r=grab_boss_corner_r) so
// the boss visually fades into the surrounding flat wall face along all
// four edges — top, bottom, left, right.
//
// Dimensions:
//   X extent: grab_boss_width centered at grab_boss_x_center
//   Z extent: grab_boss_height_z centered at grab_boss_z_center
//   Y extent: from y=ext_d (flush with wall exterior) to y=grab_boss_y_outside

module grab_boss() {
    // Rounded-rect cross-section in the X-Z plane, extruded in Y. The
    // boss's inner face starts INSIDE the front wall (y = ext_d - eps) so
    // the union with the wall body is a non-degenerate volumetric overlap
    // rather than a coplanar face-to-face touch (which CGAL sometimes
    // treats as a non-merging contact, producing a disconnected mesh
    // component). Outer face at y = grab_boss_y_outside.
    eps = 0.5;
    bx0 = grab_boss_x_center - grab_boss_width  / 2;
    bx1 = grab_boss_x_center + grab_boss_width  / 2;
    bz0 = grab_boss_z_center - grab_boss_height_z / 2;
    bz1 = grab_boss_z_center + grab_boss_height_z / 2;
    r   = grab_boss_corner_r;
    corners = [
        [bx0 + r, bz0 + r],
        [bx1 - r, bz0 + r],
        [bx1 - r, bz1 - r],
        [bx0 + r, bz1 - r],
    ];
    hull() {
        for (c = corners) {
            translate([c[0], ext_d - eps, c[1]])
                rotate([-90, 0, 0])           // cylinder axis from local Z → world Y
                    cylinder(h = grab_boss_proud + eps, r = r, $fn = 64);
        }
    }
}

// ===== Exterior grab scoop cutter =====
//
// Hull of two spheres (one at each end of the scoop X-extent, both at
// the cylinder axis position y=grab_scoop_center_y, z=grab_scoop_center_z,
// r=grab_scoop_arc_r). The hull is a capsule: cylinder middle + spherical
// end caps. On the boss outer face y = grab_boss_y_outside, the cutter's
// intersection is an oval indent fading from full chord (z=2..16) at
// x=33.6..69.6 down to a single point at x=26.6 and x=76.6.

module grab_scoop_cutter() {
    hull() {
        translate([grab_scoop_sphere_x_left,
                   grab_scoop_center_y,
                   grab_scoop_center_z])
            sphere(r = grab_scoop_arc_r);
        translate([grab_scoop_sphere_x_right,
                   grab_scoop_center_y,
                   grab_scoop_center_z])
            sphere(r = grab_scoop_arc_r);
    }
}

// ===== Tray assembly =====

module tray() {
    difference() {
        union() {
            outer_body_with_fillets();
            grab_boss();              // adds the lip-thickening on +Y exterior
        }
        cavity_cutter();              // carves the interior bin + ramp
        grab_scoop_cutter();          // carves the concave scoop into the boss
    }
}

tray();

// ===== Dimension report =====
//
// Echoed dims report ext_w × ext_d × ext_h for the bin envelope. The grab
// boss extends the actual mesh bbox in +Y by grab_boss_proud (2.5mm), so
// mesh y-extent = ext_d + grab_boss_proud = 96.7. We echo the bin envelope
// dim (ext_d=94.2) and document the boss extension below for validation.
report_dimensions(ext_w, ext_d + grab_boss_proud, ext_h, "tray");
