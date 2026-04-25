# Modeler Notes — ptouch-cradle — Round 4

**Based on:** round-3 renders at `designs/ptouch-cradle/id/round-03-renders/`, user reaction on commit `bc1f3da` ("pretty good") with three specific refinements.
**Brief version:** `id/brief.md` through Revisions entry 2026-04-25 round 4.
**Scope:** Three refinements within the v3 minimalism direction. NOT a pivot. v3's quiet desk dock direction stays — no decoration, two-tier fillet schedule, low symmetric bathtub, printer is the visual subject.

## Round-3 deltas in one paragraph

Round 3 nailed the form: low symmetric bathtub, no decoration, fillet schedule applied, printer dominates the silhouette when installed. Three follow-up refinements: (1) the cradle's tray-slot side walls are 2.05mm thick — too thin, creating a visual gap where they meet the 3mm divider wall behind the tray. The holder doesn't read as continuously wrapping around 3 sides of the tray. (2) The tray's top edges are sharp 90° cuts, plus `$fn=80` is causing visible facet stepping on rounded edges. (3) The existing 45° scoop + central finger-grip dip reads as "wall with notch" rather than "scoop." User wants a single smooth concave curve from floor to top lip.

## Fix list

### Fix 1 — Cradle: bump shelf width 108 → 110 for continuous tray-holder wrap

- **Current state (round 3 build):** `cradle_w_shelf = 108`, `slot_w = 103.9`. Slot side wall thickness = (108 - 103.9) / 2 = **2.05mm per side**. Divider wall (between printer pocket and tray slot, at y=157..160) is **3mm** thick. The thickness mismatch is visible in the render — the slot's back-corner geometry shows a step where the thin 2.05mm side wall meets the thicker 3mm divider.
- **Target state:** all walls around the tray slot uniform thickness 3mm. The holder reads as a continuous U-shape wrapping 3 sides of the tray (left, back, right) at consistent wall thickness.
- **Specific direction:**
  - `cradle_w_shelf: 108 → 110`. Slot side walls become (110 - 103.9) / 2 = **3.05mm**. Close to the 3mm `wall_thickness` rule with a tiny margin.
  - `side_step` recomputes: (110 - 86) / 2 = **12mm** (was 11mm). The printer-section→shelf concave fillet `transition_fillet_r=10` still fits (10mm fillet inside 12mm side_step).
  - Update `cradle_total_d` if the shelf section depth depends on cradle_w_shelf — it shouldn't (depth is a separate dim), but verify.
  - Confirm the tray slot's back-corner internal geometry now reads as a clean continuous U-wrap. The slot side walls should visually feel like the same wall material as the divider, not a thinner extension.
  - Keep `wall_thickness = 3.0`. The slot side walls at 3.05mm satisfy this with 0.05mm margin.
- **Classification:** brief-was-wrong (round 3 spec implicitly allowed thin slot side walls at 2.05mm; the wall_thickness=3 rule should apply uniformly).
- **Printability note:** wider shelf footprint adds ~2mm in X direction. Total cradle X grows from 108 to 110, still under 256mm Bambu X1C. No new print concerns.
- **Affects spec?** yes — `cradle_w_shelf: 108 → 110`. `side_step` derived (now 12). Update `dimensions.x: 108 → 110` and `echoedDimensions.cradle.x: 108 → 110` and `echoedDimensions.cradle_printer_section.x` stays 86.

### Fix 2 — Tray: continuous top-edge fillet + higher $fn for smooth render

- **Current state (round 3 build):** tray walls have a vertical edge fillet (`fillet_vert_r=3` via `rounded_rect`) but **no top-edge fillet** — wall tops are sharp 90° cuts where vertical face meets horizontal top. Plus `$fn=80` on the `rounded_rect` produces visible faceting on the rounded vertical corners; this faceting is most pronounced on the upper portion of the curved corners.
- **Target state:** all tray top edges have a continuous **r=2** fillet (slightly tighter than the vertical r=3 so the wall character is preserved). All curved geometry rendered with `$fn=200` for smoothness. No visible faceting in renders.
- **Specific direction:**
  - **Top-edge fillet construction (similar pattern as cradle's `low_wall_block_solid` from round 3):**
    - Main wall extrusion stops at z = ext_h - r (where r = top_edge_fillet_r = 2).
    - Stack 8-10 thin discs in z, each progressively inset using `offset(r = -inset_at_z)` following a quarter-circle profile. Each inset = r * (1 - cos(angle_at_step)).
    - This produces a smooth quarter-circle roll on the top outer edge of every tray wall.
  - **Apply to ALL tray top edges:** front scoop (Fix 3), back wall, ±X side walls. The fillet wraps continuously around the tray's top perimeter.
  - **The interior of the wall stays sharp at the top** (the fillet only rolls on the OUTSIDE — the concave interior corner remains a hard 90° because filleting it would require subtractive geometry at the interior, which complicates Fix 3's smooth scoop).
  - **`$fn` bump:** change `$fn = 80` to `$fn = 200` at the tray.scad top level. Apply to all curve operations (rounded_rect, scoop curve approximation, top-edge fillet stack disc count). Where modules use explicit `$fn=120` (e.g. the old `finger_grip_cutter` cylinder), update to 200.
- **Classification:** preference shift (visual quality refinement).
- **Printability note:** r=2 top-edge fillet on a 1.6mm wall is fine — the fillet curves the outer edge inward over 2mm of z, preserving the wall's structural section. Higher $fn means more triangles in the STL (~2× tessellation increase) but still well under any practical limit.
- **Affects spec?** yes — `tray_top_edge_fillet_r: 2.0` (new), `tray_fn: 200` (new, or just hardcode in tray.scad without spec param). Document the exception in spec params: top-edge fillet at r=2 is intentionally distinct from the cradle's r=3 utility tier — the smaller radius reads better on the smaller tray scale.

### Fix 3 — Tray: smooth continuous concave scoop replacing 45° scoop + finger-grip

- **Current state (round 3 build):** tray.scad has `scoop_cutter()` and `finger_grip_cutter()` modules. The scoop carves a 45° wedge from z=7 to z=21.6 of the front wall (upper 14mm angled at 45°, lower 7mm vertical). The finger-grip carves a cylindrical concave dip 30mm wide × 2.5mm deep into the center of the scoop face. Visible artifacts: hard kink at z=7 where vertical meets 45°, stepped notch in the scoop center where the finger-grip transitions into and out of the cylindrical carve.
- **Target state:** front wall has a single smooth concave curve from the floor's front edge UP to the top lip. No kinks, no notches, no stepped transitions. The whole front wall reads as a sculpted scoop.
- **Specific direction:**
  - **Delete** modules `scoop_cutter()` and `finger_grip_cutter()` from tray.scad. Delete their callsites in `tray_shell()`. Delete spec params `scoop_base_h`, `scoop_h`, `scoop_angle`, `grip_w`, `grip_depth`, `scoop_leading_edge_r`.
  - **New scoop construction** — single concave-curved cutter on the front wall:
    - **Profile (Y-Z cross-section):** concave circular arc.
      - Start point: `(y = ext_d, z = floor_t)` = `(94.2, 1.6)` — the floor's front-exterior edge. The scoop face begins at floor level at the very front of the tray.
      - End point: `(y = ext_d - scoop_top_recess, z = ext_h)` = `(82.2, 21.6)` if `scoop_top_recess = 12`. The scoop face ends at the top of the wall, recessed 12mm back from the front exterior. This becomes the new "top lip" position.
      - Arc shape: concave circular arc connecting the two points. Center on the tray-interior side (negative Y from the chord midpoint).
    - **Arc center math:**
      - Chord from S = (94.2, 1.6) to E = (82.2, 21.6).
      - Chord length: sqrt(12² + 20²) = sqrt(544) ≈ 23.32mm.
      - Chord midpoint: M = (88.2, 11.6).
      - Choose arc radius r_scoop such that the arc bulges INTO the tray interior. r_scoop = 18mm (slightly larger than half-chord-length, gives a moderately deep concave curve).
      - Arc center = M + perpendicular-to-chord-vector × sqrt(r_scoop² - (chord/2)²)
      - perpendicular-to-chord direction (pointing into tray interior, i.e., −Y, −Z combined): the chord goes (−12, +20), perpendicular into tray is (−20, −12) normalized = (−0.857, −0.514).
      - Distance from M to center: sqrt(18² - 11.66²) = sqrt(324 - 136) = sqrt(188) ≈ 13.7mm.
      - Center C = (88.2 + 13.7 × (−0.857), 11.6 + 13.7 × (−0.514)) = (88.2 − 11.74, 11.6 − 7.04) = **(76.46, 4.56)**.
      - Sanity check: distance from C to S = sqrt((94.2 − 76.46)² + (1.6 − 4.56)²) = sqrt(17.74² + 2.96²) = sqrt(314.7 + 8.76) ≈ sqrt(323.5) ≈ 18.0mm ✓
      - Distance from C to E = sqrt((82.2 − 76.46)² + (21.6 − 4.56)²) = sqrt(5.74² + 17.04²) = sqrt(32.9 + 290.4) ≈ sqrt(323.3) ≈ 17.99mm ✓
    - **Approximate as a polygon** with N=40 points along the arc from S to E. The polygon defines the scoop CUTTER profile. Plus extra points to close the polygon outside the tray (to make it a proper cutter shape).
    - **Cutter geometry:** linear_extrude the polygon along X to span the full tray width (`ext_w` plus slop). Subtract from `tray_shell()`.
  - **Finger-grip is gone.** The user can grab the tray's top lip (now at y=82.2, z=21.6, soft-rounded by the Fix 2 top-edge fillet) for removal. The recessed top lip provides natural finger purchase without requiring a separate dip.
  - **Top lip position:** the new top lip is at y=82.2 (12mm back from the front exterior). The tray's front wall ABOVE the scoop face has thickness 12mm at the top → too thick visually. Solution: make the scoop's CUTTER ALSO carve through the wall top — the tray's outer +Y face is vertical at y=ext_d only up to where the scoop curve starts. Above that, the scoop cutter removes everything in front of the scoop arc, including any wall material above the arc. The result: front "wall" between z=1.6 and z=21.6 is just the wall material BEHIND the scoop arc — minimum 1.6mm thick at the floor (between scoop arc and exterior y=ext_d face), growing as z increases (the scoop arc curves inward toward the tray interior, leaving more wall material behind it).
    - Simpler: the +Y exterior face is NOT vertical at y=ext_d above the scoop top. Instead, the +Y exterior face follows the scoop arc inward. So the front of the tray has:
      - At z=1.6: front edge at y=94.2 (floor extends fully forward)
      - At z=10: front edge at y= some_intermediate (following the arc curve)
      - At z=21.6: front edge at y=82.2 (top lip recessed)
    - The wall thickness is uniform 1.6mm — exterior arc and interior arc are offset by 1.6mm. Both follow the same concave curve.
    - This is the cleanest interpretation: the entire front wall is a curved 1.6mm-thick shell following the scoop profile.
  - **Concrete construction:**
    - In `tray_shell()`, the OUTER body is no longer a simple `linear_extrude(rounded_rect)`. The front wall section needs a custom profile.
    - Implementation option A (preferred): construct the tray as a sweep along a 2D Y-Z profile that defines wall thickness vs. height, with the front wall using the concave scoop profile while the back and side walls remain vertical.
    - Implementation option B (simpler): keep the rounded_rect outer body, then SUBTRACT a large concave cutter that removes the front-upper portion of the wall to reveal the scoop curve. The cutter must extend in +Y past the tray's exterior, then sweep concavely back into the tray. Plus extend in −Y past the floor to fully cut.
    - Use whichever approach produces clean mesh + correct uniform 1.6mm wall thickness on the scoop face.
  - **Top-edge fillet on the scoop top lip:** the Fix-2 top-edge fillet (r=2) wraps continuously around all tray top edges, INCLUDING the scoop top lip at y=82.2. The lip is a soft rounded edge.
- **Classification:** brief-was-right-modeler-missed (the brief intended a smooth continuous scoop; round 1's implementation introduced kinks and a separate finger-grip that the user has now flagged).
- **Printability note:** the scoop face is concave (curving away from the printer's print direction). At any height z ∈ [floor_t, ext_h], the local print angle is the tangent of the scoop arc at that z. At the steepest point (near z=21.6, top of the arc), the tangent is most horizontal — close to 90° from vertical. **This is potentially an overhang concern.**
  - Compute steepness: at z=21.6 (end point E), the arc tangent direction is perpendicular to the radius vector from C=(76.46, 4.56) to E=(82.2, 21.6). Radius vector: (5.74, 17.04), normalized. Tangent perpendicular (counterclockwise): (−17.04, 5.74), normalized. Tangent angle from vertical (Z-axis): atan2(17.04, 5.74) ≈ 71.4° from vertical = 18.6° from horizontal. **That's a SEVERE overhang** — the scoop's top portion is nearly horizontal at the print direction.
  - **Print orientation needs to change:** instead of printing the tray with the open-top up (Z-axis = open direction), tilt the tray so the scoop print orientation works. Options:
    - Print the tray on its back (rotate tray 90° so the −Y face is down on the bed). Now the open top is in +Y direction, and the scoop faces +Z when printing. The scoop's overhangs become facing-upward features (not overhangs at all).
    - Print tray as-is (open top up) but enable supports for the scoop (defeats the no-supports rule).
  - **Recommendation: print tray on its back.** Update spec `tray.print_orientation` to "back-down (−Y face on bed), open top facing +Y". Verify all walls print clean in this orientation:
    - −Y back wall (now down on bed): single layer flat face, prints fine.
    - Floor (now vertical): prints with appropriate wall settings, no overhang since it's vertical.
    - Side walls (now vertical): same.
    - Front scoop (now an upward-facing slope): prints as a series of vertical layers each slightly inset, like a normal fillet. No overhang issues.
    - Open top (now in +Y direction, sideways): prints as a vertical face during printing.
  - This is a function-driven exception worth documenting.
  - **Alternative: simpler scoop curve.** If the user-specified concave scoop profile creates print-orientation complications, dial back the scoop's depth. A SHALLOWER concave arc (e.g. scoop_top_recess = 6 instead of 12, with smaller arc) would have a less severe top tangent. But the user explicitly asked for a smooth scoop "all the way to the top lip" — so depth should reach the top.
  - **My recommendation: implement the deep scoop with print-on-back orientation.** The user prioritized scoop visual continuity; print orientation can adapt.
- **Affects spec?** yes — multiple changes:
  - DELETE: `tray_scoop_angle_from_horizontal`, `tray_scoop_height`, `tray_scoop_base_vertical_height`, `tray_scoop_finger_grip_width`, `tray_scoop_finger_grip_depth`, `fillet_scoop_lip_leading_edge_r`.
  - ADD: `tray_scoop_top_recess: 12`, `tray_scoop_arc_radius: 18`, `tray_scoop_construction: "concave-arc-floor-to-top-lip"`.
  - UPDATE: `tray.print_orientation` description from "face up (open top), back on bed" to "back down (-Y face on bed), open top facing +Y. Tilted print orientation accommodates the smooth scoop curve which would otherwise create severe overhangs."

## Items unchanged from round 3

- Cradle: stepped body (now 86 → 110 with side_step=12), full-perimeter 25mm low base, printer pocket 80×154×145mm, cable notch 25×20 at z=0-20 in -Y wall, cradle exterior corners r=10, base plate corners r=10, foot count/dimensions.
- Cradle: host_object_proxy module, render_with_host parameter.
- Cradle: top-edge fillet on the perimeter walls (r=3 utility from round 3).
- Cradle: printer→shelf concave fillet r=10.
- Tray: interior dimensions 100×91×40mm. Exterior bounding box stays 103.2×94.2×21.6mm (the scoop profile lives WITHIN this envelope, not extending past it).
- Tray-to-slot sliding fit: 0.35mm per-side. With cradle_w_shelf=110 and slot_w=103.9, the tray exterior 103.2mm fits with 0.35mm clearance per side as before.
- All round-3 brief Form-language rules still apply: no decoration, two-tier fillet schedule, surface continuity.

## Leave alone

- Cradle: every aspect of the round-3 cradle structure not explicitly touched by Fix 1.
- Tray: interior cavity dimensions, sliding fit, wall thickness 1.6mm.

## Uncertain — flag for round-5 critique

- **Scoop top recess at 12mm:** if the front-of-tray feels "too cut away" (top lip too far back), reduce to 8-10mm. If the curve still reads as "wall with subtle bend" rather than "smooth scoop," go deeper to 14-16mm.
- **Scoop arc radius 18mm:** controls how concave the curve looks. Larger r = flatter, less dramatic. Smaller r = more pronounced concavity. If the curve reads as straight, reduce r to 15-16mm.
- **Tray top-edge fillet r=2:** if r=2 visually competes with the cradle's r=3 top-edge fillet (creating a noticeable mismatch in the use-state render), consider unifying both at r=2.5 or both at r=3.
- **Print orientation flip:** verify in slicer preview that print-on-back works cleanly. If it produces ugly seams on the user-front face (now the top of the print), reconsider scoop depth or accept the seam location.

## Summary for orchestrator

- **3 fixes**, all with spec-level implications. All apply inline (orchestrator pre-authorized).
- **Scope:** small geometric refinement. Cradle changes one parameter (cradle_w_shelf 108→110) plus derived recompute. Tray gets top-edge fillet stack + new scoop curve construction + module deletions. Fillet schedule + minimalism direction unchanged.
- **Supports:** none on cradle. Tray scoop face needs print-on-back orientation to avoid severe overhangs (function-driven exception, not "supports permitted").
- **Render priority:** use-state hero remains primary. Add a `tray-user-front-threequarter-from-above` view if useful to show the new scoop curve from a flattering angle. Existing 7-view set otherwise unchanged.
- **Recommended next step:** `re-model + re-render + re-critique`. Round-5 will check (a) tray holder reads as continuous wrap, (b) tray top edges read smoothly without facet stepping, (c) front scoop reads as a single smooth curve.

## Build-volume sanity check

- Cradle.x: 108 → 110mm. Bambu X1C max = 256mm. PASS.
- Cradle.y: 254.9mm. PASS (1.1mm margin, unchanged).
- Cradle.z: ~28mm. PASS.
- Tray dimensions unchanged. PASS.
