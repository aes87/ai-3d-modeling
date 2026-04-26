# Modeler Notes — ptouch-cradle — Round 5

**Based on:** round-4 renders at `designs/ptouch-cradle/id/round-04-renders/`, user feedback captured in `obsidian-vault/vault/projects/3d-printing/ptouch-cradle-critique-04.md`.
**Brief version:** `id/brief.md` v3 minimalism direction holds. Round-5 Revisions entry to be added.
**Scope:** five fixes within the v3 direction. The most substantive is rebuilding the tray's front-of-bin treatment — round 4's interpretation of "scoop" was structurally wrong (the entire front wall became a curve, eating the closed-bin character). Round 5 restores the bin's four-wall closure with a short front lip + interior floor ramp + grabbable exterior finger scoop.

## Round-4 deltas in one paragraph

Round 4 nailed the cradle's tray-holder wrap (108→110), top-edge fillets, and gray printer proxy — those stay. Round 4's tray scoop revamp was wrong: the brief said "smooth continuous scoop at the front of the tray all the way to the top lip," and the agent built it as a curved front wall (no closed bin). User clarified: closed kanban bin with 4 walls, a SHORT front wall, and an INTERIOR floor ramp from flat-floor up to the top of the front wall (functional: finger slides under a label and pushes it up and over the front lip). Plus a grabbable feature on the front lip exterior. Plus tray gets taller for room. Plus three other items: feet are gone (silicone aftermarket), cable notch is gone (plug is above design height), and the cradle's top-edge fillet stack needs more steps + higher $fn so it reads as a smooth curve, not stair-stepped.

## Fix list

### Fix 1 — Tray: rebuild as closed bin with short front wall + interior floor ramp + grabbable exterior scoop

**This is the biggest change in round 5. Read carefully.**

- **Current state (round 4 build):** tray's entire front "wall" is a single concave circular arc from `(y=ext_d, z=floor_t)` UP to recessed top lip `(y=ext_d-12, z=ext_h)`. The wall is uniform 1.6mm thick, exterior arc and interior arc offset. No closed bin from the front; no front lip; no interior ramp; print orientation forced to back-down.
- **Target state:** closed kanban bin — 4 solid walls + floor. Front wall is restored as a vertical SOLID wall, shorter than back/side walls. Interior of the tray has a curved floor ramp near the front, sweeping up from the flat back floor to the top of the front wall. EXTERIOR of the front wall has a grabbable finger scoop centered horizontally.
- **Specific direction:**

  **Tray height bump:**
  - `int_h: 20 → 28.4` (interior cavity grows in Z).
  - `ext_h: 21.6 → 30` (exterior grows correspondingly).
  - This makes the tray ~5mm taller than the 25mm cradle wall — that's intentional and part of the brief.

  **Wall heights:**
  - Back wall + side walls: full 30mm exterior height. Interior cavity z=floor_t..ext_h = 1.6..30 = 28.4mm tall in those regions.
  - Front wall: short. Exterior height = **18mm** (z=0..18). Wall thickness 1.6mm uniform.
  - Top-edge fillet r=2 wraps continuously around all four wall tops (including the short front wall — the fillet sits at the top of the 18mm front wall just like it sits at the top of the 30mm back wall).

  **Interior floor ramp:**
  - Concave circular arc, NOT linear.
  - Profile (Y-Z cross-section, looking from the side):
    - Back end: flat floor meets the ramp at `(y=ramp_back_y, z=floor_t)` where `ramp_back_y` = `ext_d - wall_t - ramp_y_extent` and `ramp_y_extent = 30mm`. Concretely: `ramp_back_y = 94.2 - 1.6 - 30 = 62.6`.
    - Front end: ramp meets the top of the front wall at `(y=ext_d - wall_t, z=front_wall_top)` = `(92.6, 18)`.
    - Curve: concave from inside the bin (curves down-and-back when viewed from the bin's interior).
    - Arc radius: r ≈ 22mm. Math check: chord from `(62.6, 1.6)` to `(92.6, 18)` has length sqrt(30² + 16.4²) ≈ 34.2mm. r=22 places the arc center on the +Y/+Z exterior side, producing a concave curve. (Modeler verifies the arc center math — round-4 lesson: the agent put the center on the wrong side and the modeler corrected it. Be careful here.)
  - Implementation: subtract a 2D Y-Z polygon (with the concave arc edge) extruded in X across the full interior width (`x=wall_t..ext_w-wall_t`). The polygon shapes the interior's front portion such that the floor rises along the arc.
  - Ramp X extent: full tray interior width (`x=wall_t..ext_w-wall_t` = `x=1.6..101.6`), bounded by the side walls.

  **Grabbable finger scoop on +Y exterior face of front wall:**
  - Concave horizontal indent on the exterior front face. Reads as "grab here."
  - Centered horizontally: at `x=ext_w/2 = 51.6`.
  - Scoop width along X: **50mm** (from `x=26.6` to `x=76.6`).
  - Scoop arc profile (Y-Z cross-section): concave circular arc, **r=10** (matches cradle hero radius for design language consistency).
  - Vertical placement: in the upper portion of the 18mm front wall. Scoop chord on the face ≈ 14mm (use r=10 with arc-center positioned outside the wall to produce a 14mm-tall visible chord with a ~2.86mm depth at center).
    - Specifically: scoop visible at `z=2..16` on the front face (chord 14mm), with deepest point at z=9 receding ~2.86mm into the wall.
  - Smooth left/right tapers: where the scoop ends in X (at `x=26.6` and `x=76.6`), the indent fades smoothly back to the flat exterior face. Implementation: end the cylindrical cutter at those X positions, plus add small concave-fillet end caps so the cutter doesn't leave hard cylindrical end-walls. Or: shape the cutter as a hull of a long cylinder + small end spheres for smooth fade-out.
  - Cutter implementation suggestion: a horizontal cylinder along X at the position computed for the r=10 arc, length=50mm, with end caps slightly tucked back inside the wall thickness so the scoop fades smoothly rather than ending in cylindrical hard walls.
- **Classification:** brief-was-right-modeler-misinterpreted-round-4. Round 4's "smooth continuous scoop" was meant as an interior feature on a closed bin; the agent built it as the front wall itself.
- **Printability note:** print orientation reverts to **face-up** (open top up). The interior ramp's concave-curve face is fully self-supporting (curves down into the floor). Front wall at 18mm is structurally fine. Exterior grab scoop's concave indent is printable without supports if the scoop's deepest curve doesn't exceed 45° from vertical; with depth=2.86mm and chord=14mm at r=10, the local tangent angle is well within tolerance. **Verify in slicer**, but no supports expected.
- **Affects spec?** yes — multiple changes:
  - DELETE: `tray_scoop_top_recess`, `tray_scoop_arc_radius`, `tray_scoop_construction`, `tray_scoop_note` from round 4.
  - UPDATE: `int_h: 20 → 28.4`, `ext_h: 21.6 → 30`.
  - ADD: `front_wall_h: 18`, `ramp_y_extent: 30`, `ramp_arc_radius: 22`, `grab_scoop_width: 50`, `grab_scoop_arc_radius: 10`, `grab_scoop_chord_z: 14`, `grab_scoop_depth: 2.86`, `grab_scoop_center_z: 9`.
  - UPDATE: `print_orientation_tray` from "back down (-Y face on bed)" to "face up (open top up), back on bed." The round-4 back-down orientation is no longer needed.

### Fix 2 — Cradle: delete corner_feet() module and all foot params

- **Current state (round 4):** four cylindrical feet (d=8, h=3) at corner positions, with r=1.5 upper blend to the base plate. Mesh extends to z=-3 below the base plate datum.
- **Target state:** no feet. Base plate sits flush on the build plate at z=0. User will apply silicone feet aftermarket.
- **Specific direction:**
  - **Delete** module `corner_feet()` from `cradle.scad`.
  - **Delete** the `corner_feet()` callsite in `cradle()` assembly (the `union(){base_plate(); low_wall_block(); corner_feet();}` becomes `union(){base_plate(); low_wall_block();}`).
  - **Delete** spec params: `foot_d`, `foot_h`, `foot_inset`, `foot_blend_r`.
  - **Delete** `fillet_foot_to_plate_r` from the fillet schedule (no foot blend remains).
  - **Update** `cradle_total_h`: was `low_wall_h + 3 = 28` (3mm headroom for top fillet) — keep the +3 fillet headroom. **But** the mesh bbox no longer extends below z=0 (no feet sticking down), so the mesh Z-span is now ~28mm (or 25mm if the +3 was for feet — verify in code; should be 25 if feet are gone since the headroom is for top fillet curve, not for feet below).
  - Re-examine the comment in cradle.scad about cradle_total_h: round-3 says `cradle_total_h = low_wall_h + 3` includes "top-edge fillet headroom." The feet were below this datum. Without feet, the mesh Z-span = low_wall_h = 25 (top of fillet) and the bottom is at z=0 (base plate bottom). So `cradle_total_h = 25` and `dimensions.z = 25`.
  - **Update** `dimensions.z: 28 → 25` and `echoedDimensions.cradle.z: 28 → 25`.
- **Classification:** preference shift (functional: feet aren't useful, complicate printing).
- **Printability note:** simpler. Base plate's full footprint sits on the bed (much better first-layer adhesion than 4 small feet circles). No detached feet to worry about.
- **Affects spec?** yes — large param deletion + dim updates.

### Fix 3 — Cradle: delete cable_slot_cutter() and all cable_slot params

- **Current state (round 4):** cable notch on -Y back wall, 25mm wide × 20mm tall, at z=0..20, leaving a 5mm bridge above (z=20..25).
- **Target state:** no notch. The -Y back wall is a clean continuous 25mm tall band. Cable runs over the top of the back wall (the printer's plug is above the 25mm wall height).
- **Specific direction:**
  - **Delete** module `cable_slot_cutter()` from `cradle.scad`.
  - **Delete** the `cable_slot_cutter()` reference from the `difference()` in `cradle()`. The `cradle()` module becomes just `union(){base_plate(); low_wall_block();}` after Fix 2 (no difference needed at the assembly level — both pockets are subtracted inside `low_wall_block()` already).
  - **Delete** spec params: `cable_slot_w`, `cable_slot_h`, `cable_slot_z_bottom`, `cable_slot_z_top`, `cable_slot_center_x_from_left_exterior`, `cable_slot_style`.
  - **Drop** the `cable_slot_h < low_wall_h` and `low_wall_h - cable_slot_h >= 4` asserts.
- **Classification:** preference shift (function-driven: plug is above design height, no notch needed).
- **Printability note:** simpler. The 5mm bridge above the cable notch is gone; back wall prints as a clean continuous extrusion.
- **Affects spec?** yes — param deletion.

### Fix 4 — Cradle: smooth top-edge fillet (64-step stack + $fn=200)

- **Current state (round 4):** cradle uses `$fn=80` and an 8-step slab stack to approximate the r=3 top-edge fillet. With 8 steps × 3mm fillet, each slab is ~0.375mm tall — visible as stair-stepping in close-up renders.
- **Target state:** top-edge fillet reads as a true continuous quarter-circle. No visible stepping in renders.
- **Specific direction:**
  - **Bump cradle `$fn = 80 → 200`** (top of `cradle.scad`).
  - **Bump cradle slab-stack `steps = 8 → 64`** in `low_wall_block_solid()`. Each slab is now `r/64 ≈ 0.047mm` tall — invisible at any reasonable resolution.
  - **Verify tray's top-edge stack** (round-4 implementation) also uses high step count — if it's still at 8 steps, bump to 64. The tray already has $fn=200 from round 4.
  - **Optional refactor:** extract the slab-stack into a parameterized module `top_edge_fillet_stack(footprint_module, height, r, steps)` shared between cradle and tray. Cleaner code; not required.
- **Classification:** render-quality refinement.
- **Printability note:** none. The slab heights at 64 steps are far below FDM resolution.
- **Affects spec?** no (or minor — `cradle_fn: 200` and `cradle_top_fillet_steps: 64` if you want them documented).

### Fix 5 — (Implicit) Update views and rendered set

- **Current state (round 4):** 7 renders.
- **Target state:** same 7 renders, regenerated for round 5 geometry.
- **Specific direction:** produce the same 7-view set as round 4. Verify the user-front-in-use renders show the new tray sticking up above the cradle wall by ~5mm (intentional). The tray-user-front-threequarter render is the headline — must show: (a) closed bin with all 4 walls visible, (b) interior ramp curving up from back-flat-floor to front lip, (c) grabbable exterior scoop on +Y face. The cradle-user-front-in-use render must show: (a) no feet (cradle flush to ground plane), (b) no cable notch (back wall continuous), (c) cradle top edge as a smooth curve (no stair-stepping at any zoom).
- **Affects spec?** no.

## Items unchanged from round 4 (do NOT re-litigate)

- Cradle: stepped body footprint (86 → 110mm shelf), full-perimeter 25mm low base, printer pocket dims (80×154×145mm), 1mm XY clearance, 2mm Z clearance.
- Cradle: tray-holder wrap geometry (Fix 1 from round 4 — slot side walls 3.05mm matching wall_thickness).
- Cradle: hero r=10 corners (cradle exterior + base plate + printer→shelf concave).
- Cradle: utility r=3 top-edge fillet (just smoother now per Fix 4 above).
- Cradle: host_object_proxy module + render_with_host parameter.
- Tray: interior cavity width × depth (100 × 91mm — only height changes per Fix 1).
- Tray: top-edge utility fillet r=2.
- Tray: $fn=200.
- Tray-to-slot sliding fit: 0.35mm per side. Slot width 103.9 (matches new tray exterior width 103.2).

## Leave alone (round 4 successes preserved)

- Cradle's continuous tray-holder wrap (Fix 1 of round 4).
- Cradle's tray slot dimensions and sliding fit math.
- Tray's top-edge fillet r=2 + $fn=200.
- All printer-pocket geometry, clearances, tape-exit clearance.

## Uncertain — flag for round-6 critique (if needed)

- **Front wall height 18mm:** if it reads as too short relative to 30mm back wall, bump to 20-22mm. If too tall (compromises the interior ramp's drama), drop to 15-16mm.
- **Ramp Y extent 30mm:** if the ramp feels cramped (rise too steep over too short a run), bump to 35-40mm. If the back-flat-floor area feels too small for label drop, dial back to 25mm.
- **Ramp arc radius 22mm:** controls how concave the ramp curve is. Larger r = flatter ramp, more linear. Smaller r = more dramatic concavity. Modeler should render and evaluate; tune in 18-26mm range.
- **Grab scoop dimensions:** 50mm wide × ~14mm tall × 2.86mm deep at r=10. If the scoop reads as decoration rather than "grab here," go deeper (3.5-4mm). If too dominant on the 18mm wall, narrow the chord or reduce depth.
- **Tray height 30mm vs cradle wall 25mm (5mm overhang):** if the tray sticks up too far above the cradle, drop tray ext_h to 27-28. If not enough overhang for the lip-grab to feel intentional, bump to 32mm.
- **Print orientation back-down vs face-up:** with the new short-front-wall + interior-ramp design, face-up should work. **Verify in slicer.** If face-up has issues, fall back to back-down (rotate 90° about +X for printing).

## Summary for orchestrator

- **5 fixes**, of which 1 is a substantive rebuild (Fix 1, tray) and 4 are deletions/refinements (Fixes 2-5). All apply inline (orchestrator pre-authorized).
- **Scope:** medium-large diff in tray.scad (rebuild front-wall + ramp + grab scoop), small-to-zero diff in cradle.scad (delete two modules + bump constants), large param diff in spec.json.
- **Supports:** none on either part. Tray reverts to face-up print orientation.
- **Render priority:** tray-user-front-threequarter is the headline test (closed bin? curved interior ramp? grabbable scoop on exterior? smooth design language?). Use-state hero confirms the cradle's flush-bottom + clean-back-wall + smooth-top-fillet improvements.
- **Recommended next step:** `re-model + re-render + re-critique`. If round 5 lands clean, ship via standard review pipeline.

## Build-volume sanity check

- Cradle.x: 110mm. PASS.
- Cradle.y: 254.9mm. PASS (1.1mm margin).
- Cradle.z: 25mm (was 28mm with feet). PASS with huge margin.
- Tray.x: 103.2mm. PASS.
- Tray.y: 94.2mm. PASS.
- Tray.z: 30mm (was 21.6mm). PASS with 226mm margin.
