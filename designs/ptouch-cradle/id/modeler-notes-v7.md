# Modeler Notes — ptouch-cradle — Round 7

**Based on:** round-6 renders. User feedback on commit `1815c23`:
- "You went retard on the front edge of the tray. It doesn't need that top bar, it shouldn't have sharp points. Rework just the tray to be a simpler, more friendly/ergonomic design."

**Brief version:** v3 minimalism direction holds. Round 7 Revisions entry to be added.
**Scope:** **Simplification.** The variable-height front wall from round 6 (corners at z=18, lowered center at z=10, transition arcs between) introduced visual clutter — the "corner bars" at z=18 and the transitions create features that don't earn their keep, and the corners produce sharp points where multiple geometric features intersect. Round 7 collapses the front wall to a single uniform low height with one continuous concave fillet from each side wall down to it.

This is a TRAY-ONLY round. Cradle is untouched (zero edits to cradle.scad).

## Round-6 deltas in one paragraph

Round 6 added a clever variable-height front wall to provide a grab feature without a separate boss. It worked geometrically (closed bin, ramp terminates at lowered center, fangs gone) but introduced new visual problems: the corners at z=18 read as unnecessary "top bars" flanking the central cutout, and the intersections where the transition arcs meet the side-wall fillets produce sharp points. Round 7 simplifies: drop the variable-height profile entirely. Front wall becomes uniform z=10 across the full width. One concave fillet sweep handles the entire side-wall-to-front-wall transition. No corners, no transitions, no intersections, no sharp points.

## Fix list

### Fix 1 — Front wall: collapse to uniform z=10

- **Current state (round 6):** front wall has variable height — corners at z=18 (full height) for ~5mm of X width on each side, lowered center 50mm wide at z=10, concave transition arcs (r=8) between corner and center. Plus a separate r=12 fillet from each side wall (z=30) down to the front-wall corner (z=18). Result: 4 distinct height zones across the front wall (side wall, side fillet, corner, transition arc, lowered center) with intersections that produce visible sharp points.
- **Target state:** front wall is a SINGLE uniform-height wall at z=10 across the entire width. No corners, no transitions, no variable-height profile.
- **Specific direction:**
  - DELETE the variable-height profile machinery from `tray.scad`:
    - Remove `front_wall_corner_h`, `front_wall_center_h`, `front_wall_center_w`, `front_wall_transition_r` and all derived `_center_start`, `_center_end`, `_corner_flat_x_*` variables.
    - Replace with a single `front_wall_h = 10`.
  - Front wall geometry: solid wall material from x=wall_t to x=ext_w-wall_t, y=ext_d-wall_t to y=ext_d, z=0 to z=front_wall_h=10. Wall thickness uniform 1.6mm.
  - The front wall reads as a clean low band across the entire front of the tray.
- **Classification:** simplification.
- **Printability note:** simpler. Face-up print, fully self-supporting.
- **Affects spec?** yes:
  - DELETE: `front_wall_corner_h`, `front_wall_center_h`, `front_wall_center_w`, `front_wall_transition_arc_r`, `front_wall_corner_fillet_r` (12 from round 6 — replaced by Fix 2's r=20 below).
  - ADD: `front_wall_h: 10` (single param replaces the variable-height block).

### Fix 2 — Single concave fillet from side wall (z=30) to front wall (z=10)

- **Current state (round 6):** two separate fillet/transition features per side: (a) r=12 concave quarter-arc from side wall (z=30) to front wall corner (z=18), (b) r=8 concave transition arc from corner (z=18) to lowered center (z=10). Two fillets in series with a flat z=18 corner-section between them. The intersection points between these features produce sharp edges.
- **Target state:** ONE concave quarter-arc fillet per side, sweeping continuously from side wall top (z=30) to front wall top (z=10) over a 20mm height drop. Single curve, single radius, no intermediate flat section.
- **Specific direction:**
  - **Radius:** r=20mm (matches the 20mm height drop from z=30 to z=10).
  - **Geometry:** at each of the two upper outer corners of the front wall (left at x=wall_t, right at x=ext_w-wall_t), sweep a quarter-circle in the X-Z plane (within the front-wall slab thickness y=ext_d-wall_t..ext_d):
    - Left fillet: arc center at `(x=wall_t + r, z=10)` = (21.6, 10). Arc from (1.6, 30) to (21.6, 10), quarter-arc 90° sweep. Concave (curve dips toward the inside of the bin).
    - Right fillet: arc center at `(x=ext_w - wall_t - r, z=10)` = (81.6, 10). Mirror.
  - The fillet sweep encodes the entire transition from the full-height side wall to the low front wall in a single smooth curve. NO flat z=18 corner section. NO intermediate transition arc.
  - Between the two fillets (x=21.6 to x=81.6, that's 60mm of X width), the front wall top is flat at z=10.
- **Classification:** simplification + ergonomics.
- **Printability note:** face-up, self-supporting. Concave fillet sweeps from a higher z to a lower z in the X direction — every layer has support below.
- **Affects spec?** yes:
  - REPLACE: `front_wall_corner_fillet_r: 12` (round 6) with `front_wall_corner_fillet_r: 20`. (Or rename to `front_wall_side_fillet_r` for clarity.)

### Fix 3 — Top-edge fillet: extend the r=2 roll to wrap the front wall top continuously

- **Current state (round 6):** r=2 top-edge fillet rolled inward on the back wall + side walls (above z=ext_h). The front wall's variable-height top profile was deemed too complex for the slab-stack roll, so the front wall top was left without an explicit top fillet (the variable-height arcs were said to provide softening on their own).
- **Target state:** with the front wall now a uniform z=10 height, the r=2 top-edge fillet rolls continuously around all four wall tops — back wall (z=30), side walls (z=30), front wall (z=10). Plus the curved fillet sweep surface from Fix 2 between side wall and front wall.
- **Specific direction:**
  - The slab-stack approach used for back/side wall tops works for the front wall top too — same construction, just at z=10 instead of z=ext_h=30.
  - Apply the r=2 top-edge fillet roll on the front wall: extrude the front wall body to (z=front_wall_h - r) = 8, then stack discs from z=8 to z=10 each progressively inset, following the quarter-circle profile.
  - The fillet sweep surface (Fix 2) between side wall and front wall already has its own curvature; the r=2 top-edge roll naturally blends into the sweep at the boundary. Modeler ensures the mesh transitions cleanly at this boundary (no sharp seam).
  - Continuous r=2 fillet around the entire top perimeter of the tray.
- **Classification:** consistency / completeness.
- **Printability note:** none.
- **Affects spec?** no — `top_edge_fillet_r: 2` already declared. Just applies to a wider scope now (front wall too).

### Fix 4 — Interior ramp unchanged from round 6

- **Current state (round 6):** quadratic curve `z(y) = 1.6 + 8.4 * ((y - 62.6) / 30)²`, tangent to flat floor at the back, terminating at z=10 at the front-wall interior face. Concave from cavity side.
- **Target state:** identical. Round 6's ramp already terminates at z=10 (the lowered-center top), which is now the uniform front-wall top per Fix 1. No change needed.
- **Specific direction:** verify the ramp endpoint still equals `front_wall_h` (now 10, just renamed). Update the spec param name reference (`ramp_front_z = front_wall_h`).
- **Classification:** no-op.
- **Affects spec?** no.

## Items unchanged from round 6

- **Cradle: ENTIRELY UNCHANGED.** No edits to cradle.scad in round 7.
- Tray closed-bin architecture (4 walls).
- Tray interior dimensions 100×91×28.4mm.
- Tray exterior X and Z (103.2 × 30mm). Y unchanged at 94.2.
- Tray-to-slot sliding fit 0.35mm/side.
- Vertical exterior edge fillets r=3.
- Interior floor ramp (quadratic concave curve).
- Floor + back wall + side walls geometry.
- Render quality: draft ($fn=100, top_fillet_steps=24, ramp_arc_steps=32).

## Leave alone

- All round-3, 4, 5, 6 cradle work. Cradle is untouched.
- Tray closed bin + ramp + sliding fit + interior dims.

## Uncertain — flag for round-8 critique (if needed)

- **Front wall uniform height z=10:** if too short (labels jump out, no containment feel), bump to 12. If too tall (looks bin-y rather than tray-y), drop to 8.
- **Side fillet r=20:** controls how dramatic the side-to-front transition is. Larger r = gentler sweep (more side wall material consumed). Smaller r = tighter corner. Modeler may prefer r=15 if r=20 looks too generous.
- **r=2 top-edge fillet on front wall:** the front wall is only 1.6mm thick. r=2 fillet attempts to round the top inward by 2mm — that exceeds the wall thickness. Modeler may need to use r=0.8 (half wall thickness) for the front wall's top fillet to avoid offset collapse, while keeping r=2 on the back/sides. Document any deviation. Alternative: leave the front wall top as a soft chamfer or even-radius bullnose.

## Summary for orchestrator

- **3 substantive fixes** (Fix 4 is no-op). All affect tray.scad. Cradle.scad untouched.
- **Scope:** simplification. tray.scad should SHRINK from round-6 size (less geometry, fewer params).
- **Render quality:** draft.
- **Supports:** none. Face-up print orientation.
- **Render priority:** `tray-user-front` (must show clean uniform low front wall, no points, no bars) and `tray-user-front-threequarter` (must show clean continuous fillet sweep from side walls down to front wall).
- **Recommended next step:** `re-model + re-render + re-critique`. If round 7 lands clean, ship.

## Build-volume sanity check

- Tray: 103.2 × 94.2 × 30mm. Unchanged. PASS.
- Cradle: unchanged. PASS.
