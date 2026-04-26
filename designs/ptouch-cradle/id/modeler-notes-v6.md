# Modeler Notes — ptouch-cradle — Round 6

**Based on:** round-5 renders at `designs/ptouch-cradle/id/round-05-renders/`. User feedback on commit `45eca15`:
- "The front of the tray has weird little 'fang' features that feel unnecessary and ugly. Make those edges simpler, neater—a curve."
- "The tray scoop should be concave, not convex—it's ergonomically retarded right now."
- "I don't see how the front pull feature will help a person get their finger in to pull it."

**Brief version:** v3 minimalism direction holds. Round 6 Revisions entry to be added.
**Scope:** Three coupled fixes on the tray, all converging on the front-of-tray treatment. The round-5 boss+indent grab feature is dropped — replaced with a lowered center cutout in the front wall that simultaneously provides finger access AND label egress, terminating the interior ramp at the natural exit point. The "fangs" (hard step where side walls meet the short front wall) get filleted. The interior ramp is reoriented from convex (humps up into cavity) to concave (bowl-curve dipping below the chord), so a finger sliding forward gets a smooth incline instead of a speed bump.

This is a render-quality round — first time the modeler operates under the new draft-quality convention ($fn=100, top_fillet_steps=24, ramp_arc_steps=32). Iteration cycles should be 5-10× faster than round 5.

## Fix list

### Fix 1 — Tray front wall: replace boss+indent with lowered-center cutout

- **Current state (round 5):** front wall is uniform 18mm height across the full 103.2mm width. A separate lip-thickening boss (66 × 16 × 2.5mm) sits on the +Y exterior face with an oval indent (50 × 14 × 2.86mm) carved into it. User reports the indent is too shallow to actually grip — a finger barely fits.
- **Target state:** front wall has VARIABLE height. Outer corners (left and right ends) stay at z=18mm. Center 50mm drops to z=10mm. Smooth concave-arc transitions between the corner-full-height and the center-lowered. The lowered center IS the grab feature — user reaches OVER the lowered section (only 10mm tall) and hooks fingers around the front lip from above. No separate boss, no separate indent.
- **Specific direction:**
  - **Front wall profile** (X-Z cross-section, the front face viewed from -Y direction):
    - x=0..wall_t (1.6mm): side wall material — z=30. Not part of the front wall geometry.
    - x=wall_t..center_start: front wall corner — z=0..18. Width approximately 25mm. Exact width = (ext_w - lowered_w) / 2 - arc_x_extent. Modeler computes.
    - x=center_start..center_end: lowered center — z=0..10. Width 50mm.
    - x=center_end..ext_w-wall_t: front wall corner mirror — z=0..18.
    - x=ext_w-wall_t..ext_w: side wall material.
  - **Transitions between corner (z=18) and lowered center (z=10):**
    - Concave arc on each side, span ~12mm in X direction. Quarter-arc shape.
    - Suggested radius: r=8mm (matches the 8mm height difference). Modeler may prefer r=10 for hero-radius consistency; either is fine.
    - The transition is in the X-Z plane, sweeping the top edge of the front wall from z=18 down to z=10 along a smooth curve.
  - **Lowered center top edge:** flat at z=10 across the 50mm center, with continuous r=2 top-edge fillet (matching the existing top-edge fillet on the back/side walls).
  - **Wall material thickness uniform 1.6mm** throughout the front wall (corners, transitions, lowered center). The 1.6mm thickness extends from y=ext_d-wall_t (interior face) to y=ext_d (exterior face).
  - **Implementation:** the front wall is a solid extrusion in Y of a 2D X-Z polygon defining the variable-height profile. Polygon vertices walk the outline:
    - (0, 0) — bottom-left
    - (ext_w, 0) — bottom-right
    - (ext_w, 18) — top-right corner of right corner section
    - (ext_w - wall_t - corner_w, 18) — start of right transition
    - Concave arc from (ext_w - wall_t - corner_w, 18) to (ext_w - wall_t - corner_w - 12, 10) — right transition
    - (center_start, 10) — start of flat lowered center
    - (center_end, 10) — end of flat lowered center
    - Concave arc to (wall_t + corner_w, 18) — left transition (mirror)
    - (0, 18) — top-left corner of left corner section
    - (Back to (0, 0))
    - Note: the polygon also needs the top-edge fillet rolled into it via a slab-stack approach (similar to existing top-edge fillet construction).
  - Alternative implementation: build the front wall as a difference of (full-height wall solid) minus (lowered-center cutter that removes the upper z=10..18 of the center 50mm with concave-arc side cuts).
- **Classification:** preference shift (round-5 boss+indent design is replaced with a more ergonomic alternative).
- **Printability note:** face-up print orientation. The lowered center cutout in the front wall is a "missing material" feature, not an overhang — fully self-supporting. The transition arcs in X-Z are also self-supporting (the wall material below z=10 in the center is solid).
- **Affects spec?** yes:
  - DELETE round-5 boss+indent params: all `grab_*` and `boss_*` from spec.json. Specifically: `grab_scoop_width`, `grab_scoop_arc_radius`, `grab_scoop_chord_z`, `grab_scoop_depth`, `grab_scoop_center_z`, `grab_boss_width`, `grab_boss_height_z`, `grab_boss_thickness`, etc.
  - ADD: `front_wall_corner_h: 18`, `front_wall_center_h: 10`, `front_wall_center_w: 50`, `front_wall_transition_arc_x_extent: 12`, `front_wall_transition_arc_r: 8`.
  - REVERT: `tray.y` and `echoedDimensions.tray.y` and `ext_d` back from 96.7 → 94.2 (no boss extending forward; boss removed entirely).
  - The slot in cradle stays at slot_d=94.9 — fits the now-94.2mm tray with the 0.35mm sliding fit per side. No cradle changes for this fix.

### Fix 2 — Tray side-wall to front-wall transition: smooth concave fillet (no more "fangs")

- **Current state (round 5):** side walls go to z=30, front wall corners are at z=18 (will stay 18 in v6 per Fix 1). The transition between them at x=wall_t and x=ext_w-wall_t is a hard vertical step — visible as small pointed protrusions ("fangs") in the user-front render at the upper corners.
- **Target state:** smooth concave fillet curve transitioning from side-wall-top (z=30) down to front-wall-corner-top (z=18). No hard step, no fang.
- **Specific direction:**
  - **Where:** at the y=ext_d-wall_t..ext_d band (the front wall's Y extent), at the +X and -X ends of the front wall (at x=wall_t and x=ext_w-wall_t). The fillet sweeps in the X direction (and partially in Z), connecting the front wall's corner top (z=18 at x=wall_t) up to the side wall's top (z=30 at x=0..wall_t).
  - **Geometry:** concave quarter-circle fillet of radius **r=12mm** (matches the 12mm height difference between side wall z=30 and front wall corner z=18). The fillet's center of curvature is at (x_inner, z_lower) where x_inner = wall_t + r = 13.6 (left side) or x_inner = ext_w - wall_t - r = 89.6 (right side), and z_lower = 18.
  - **Sweep direction:** the fillet sweeps the wall's TOP edge profile from (x=wall_t, z=30) down to (x=wall_t + r, z=18) along a quarter-arc. Above the fillet, side wall material at full height z=30. To the right of the fillet (toward the center of the front wall), the front wall corner is flat at z=18. To the left (and below, x=0..wall_t), side wall material extends to z=30.
  - **Implementation suggestion:** the side walls + front wall could be unified into a single solid via a 2D outline in the X-Z plane (looking from -Y) that defines the entire tray's "front silhouette" — including the side-wall-to-front-wall fillets, the front-wall corners, the front-wall transitions, and the lowered center. Then the floor and back wall are added separately. This produces a single coherent silhouette without per-feature corner geometry.
- **Classification:** brief-was-right-modeler-missed (the v3 minimalism brief implicitly rules out hard steps; the round-5 build has them at the corners).
- **Printability note:** face-up, fully self-supporting. The fillet sweeps from a higher z to a lower z in the X direction — no overhangs at any layer.
- **Affects spec?** yes — `front_wall_corner_fillet_r: 12` (matches height difference).

### Fix 3 — Interior floor ramp: re-orient to concave (bowl curve), not convex (hump)

- **Current state (round 5):** ramp arc center placed on +Y/-Z (forward and below the chord midpoint). The arc bulges UP into the bin cavity — convex from the cavity side. User reports "ergonomically retarded": a finger sliding forward hits the bulge first and has to climb over a hump.
- **Target state:** arc center moved to the OPPOSITE side of the chord — above the chord midpoint, on the -Y/+Z side relative to chord (or roughly in that direction; modeler picks the exact side based on geometric viability). The arc DIPS BELOW the chord (concave from cavity side). A finger sliding forward gets a smooth gradual incline that steepens monotonically, like climbing a slide.
- **Specific direction:**
  - **Endpoints unchanged:** `(y=ramp_back_y=62.6, z=floor_t=1.6)` (back of ramp at floor level) → `(y=ramp_front_y=92.6, z=ramp_front_z)`. **Note:** in v6, ramp_front_z drops from 18 (round 5 — top of front wall) to **10** (top of lowered center per Fix 1). The ramp terminates at the lowered center's top, not at the corner-section top. This shortens the ramp's vertical rise from 16.4mm to 8.4mm and makes the curve gentler.
  - **Arc orientation:** concave from cavity side. Center of curvature is ABOVE the chord (in the +Z direction relative to chord midpoint). The arc surface curves AWAY from a viewer standing inside the cavity looking down at the floor.
  - **Arc radius:** modeler computes such that the arc:
    - Passes through both endpoints.
    - Stays at or above z=floor_t=1.6 throughout (does NOT dip below the floor surface).
    - Is concave (center on +Z side of chord midpoint).
  - **Suggested radius: r ≥ 30mm.** With the chord from (62.6, 1.6) to (92.6, 10) (length sqrt(30² + 8.4²) ≈ 31.15), a concave arc with center directly above the chord midpoint and r large enough to keep the arc above floor requires r > ~16 (just barely). Pick r=25 for a moderate concavity; modeler verifies the arc-above-floor constraint.
  - **Alternative if direct concave arc placement is geometrically tricky:** use a Bezier curve or compound construction (two arcs) that achieves the same monotonic-rise + concave-from-cavity-side property without dipping below floor. Modeler chooses what produces the cleanest mesh.
  - **Width:** ramp spans the full tray interior width (x=wall_t..ext_w-wall_t). Same as round 5 — no change.
  - **Y extent:** ramp_y_extent stays at 30mm (back-flat-floor occupies y=wall_t..ramp_back_y=62.6; ramp occupies y=62.6..92.6). No change.
- **Classification:** brief-was-right-modeler-misinterpreted-round-5. The brief intent was "smooth ergonomic ramp"; the modeler chose pan-edge convex orientation which works visually but not ergonomically.
- **Printability note:** face-up print. Concave ramp surface is fully self-supporting (curves DOWN from the floor surface — every layer of the ramp surface sits on solid floor material below). No overhangs.
- **Affects spec?** yes:
  - UPDATE: `ramp_front_z: 18 → 10` (now terminates at lowered center top per Fix 1).
  - UPDATE: `ramp_arc_r: 22 → 25` (or whatever the modeler picks for concave orientation; round 5's 22 was for the convex pan-edge geometry).
  - ADD: `ramp_orientation: "concave_from_cavity_side"` documentation comment.
  - REMOVE / replace any documentation comments referring to "pan-edge curve."

### Fix 4 — Adopt draft render quality (first round under the new convention)

- **Current state (round 5):** render quality settings are at top of `tray.scad` and `cradle.scad` from the speedup commit `b2695ec`: `$fn=100`, `top_fillet_steps=24`, `ramp_arc_steps=32`.
- **Target state:** unchanged. Just verify the modeler is rendering at draft quality during iteration. Shipper will bump to ship quality (`$fn=200`, `top_fillet_steps=64`, `ramp_arc_steps=96`) before delivery.
- **Specific direction:** verify the SCAD files declare quality knobs at the top (they do, post-`b2695ec`). When iterating, render with the defaults — no `-D` overrides needed for draft. Document expected render times in the report (cradle should be ~1min, tray ~20-30s for STL; PNGs faster).
- **Classification:** infrastructure adoption.
- **Printability note:** none.
- **Affects spec?** no (already in place).

## Items unchanged from round 5

- **Cradle:** entirely unchanged. No edits to cradle.scad in round 6. All round-3, 4, 5 cradle improvements stay (low symmetric bathtub, continuous tray-holder wrap, smooth top fillet, no feet, no cable notch, $fn=100 draft).
- **Tray architecture:** still a closed kanban bin with 4 walls. Variable-height front wall is still a wall (just sculpted differently).
- **Tray interior dimensions:** 100×91×28.4mm. Unchanged.
- **Tray exterior X and Z dimensions:** 103.2mm × 30mm. Unchanged. Y dimension reverts from 96.7 → 94.2 (boss removed, Fix 1).
- **Tray-to-slot sliding fit:** 0.35mm/side. Unchanged.
- **Tray top-edge fillet:** r=2 on back/sides + transitions. The front wall's variable-height top profile gets the r=2 fillet too (continuous along the entire top edge).
- **Print orientation:** tray face-up, cradle base-down. Both unchanged.

## Leave alone (round 4/5 successes preserved)

- Cradle's tray-holder continuous wrap (round-4 Fix 1).
- Cradle's smooth top edges + flush base + clean back wall (round 4 + 5).
- Tray closed-bin architecture with variable-height front wall (round 5 + 6).
- Curved interior ramp concept (just re-oriented in v6).

## Uncertain — flag for round-7 critique (if needed)

- **Lowered center width 50mm and height 10mm:** if the cutout reads as too small (finger access still cramped), bump width to 60-70mm and/or drop center height to 8mm. If too dramatic (looks like a notch in an otherwise-clean wall), tighten to 40mm width / 12mm height.
- **Front wall transition arc r=8:** controls how soft the corner-to-center transition reads. Larger r = gentler curve, smaller r = tighter step. Modeler may prefer r=10 for hero-radius consistency.
- **Side-wall-to-front-wall fillet r=12:** if the fillet looks too generous (eats too much side wall material), drop to r=8. If hard-step character returns, bump to r=15.
- **Concave ramp curve depth:** if the ramp curve's deepest dip below the chord is too subtle (looks straight), bump arc radius down to 20-22 (within the bounds that keep arc above floor). If too dramatic (curve dips noticeably below chord), bump radius to 30-35 (flatter, closer to a straight slope).
- **Ramp terminating at z=10 vs z=18:** the ramp now ends at the lowered center top (z=10), not the corner top (z=18). Visually the ramp is shorter in z. If this looks abrupt (the ramp doesn't feel like it reaches "all the way up"), consider extending the ramp's Y-extent slightly so the curve has more room to land gently.

## Summary for orchestrator

- **3 substantive fixes + 1 infrastructure adoption** = 4 fixes total. All affect tray.scad; cradle.scad is untouched in round 6.
- **Scope:** medium tray rebuild. Front wall geometry replaced; interior ramp re-oriented; corner transitions added.
- **Render quality:** draft. Should iterate fast.
- **Supports:** none. Face-up print, all features self-supporting.
- **Render priority:** `tray-user-front.png` (head-on showing the lowered-center cutout + smooth corner fillets — no fangs) and `tray-user-front-threequarter.png` (showing the closed bin + the ramp's concave curve from inside + the lowered center). These two views carry the round-6 critique.
- **Recommended next step:** `re-model + re-render + re-critique`. If round 6 lands clean, ship via standard review pipeline.

## Build-volume sanity check

- Cradle: unchanged (110 × 254.9 × 25mm). PASS.
- Tray: 103.2 × 94.2 × 30mm. PASS.
- Boss removed: tray Y reverts 96.7 → 94.2. PASS (no further change).
