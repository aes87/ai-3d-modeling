# Modeler Notes — ptouch-cradle — Round 2

**Based on:** round-1 renders at `designs/ptouch-cradle/id/round-01-renders/`, round-1 user reaction "the horror" (commit `5772f81`), root-cause analysis in `id/conversation-log.md` turn 6, codified lesson in `_id-library/lessons.md` (2026-04-19).
**Brief version:** `id/brief.md` through Revisions entry 2026-04-25 round 2.
**Scope:** structural relocation of the owl face from a hidden zone (z=90, behind printer) to the visible zone above the printer (z=143-205). Panel height grows. Face anatomy rebuilt per real-barn-owl reference (R2 direction). Tufts thrown out and rebuilt from scratch (the round-1 forward-sweep curled-horn geometry is dead). New host-object proxy for use-state renders.

## Round-1 deltas in one paragraph

Round 1 placed the facial disc at z=90, eyes/beak as small features inside a circular disc, and tufts as 3D forward-swept tapered triangles. Result: face invisible behind printer in actual use; tufts read as wizard-hat curled horns. Round 2 fixes structural placement first (face moves above the printer's occlusion zone), then upgrades face anatomy to real-owl reference (heart-shaped disc, recessed eye sockets, no pupils, asymmetric hooked beak), then rebuilds tufts as splayed feather clumps with outward-only lean.

## Fix list

### Fix 1 — Panel height: 145 → 205 mm (structural placement fix)

- **Current state (from round-1 render):** back panel rises to 145mm. Printer is 143mm. Only 2mm of panel is visible above the printer in actual use.
- **Target state:** panel rises to 205mm at the top arc center (per round-1 rounded-top architecture). Top arc corners (at ±X panel edges) at z≈198. This leaves a 62mm visible strip above the 143mm printer top — the face zone.
- **Specific direction:**
  - `tall_back_panel_height`: 145 → **205**.
  - `back_panel_top_center_z`: 145 → **205**.
  - `back_panel_top_corner_z`: 138 → **198** (preserve the ~7mm dip from center to corner).
  - `back_panel_top_arc_radius`: 160 mm (unchanged — the arc radius math should still produce a top arc that drops the corners ~7mm below center given the new height; verify and adjust radius if needed to maintain that dip).
  - All face-zone features (Fixes 2, 3, 4) anchor relative to the new face zone, not the old z=90 center.
  - Panel base, vertical edges, convex +Y face all preserved from round 1.
- **Classification:** brief-was-wrong (round-1 brief placed the face inside the printer-occluded zone).
- **Printability note:** total cradle Z height with tufts = 205 + ~16 = **~221mm**, well within Bambu X1C's 256mm build volume. Panel still vertical, still self-supporting; no new print concerns.
- **Affects spec?** yes — `tall_back_panel_height: 145 → 205`, `back_panel_top_center_z: 145 → 205`, `back_panel_top_corner_z: 138 → 198`, `cradle_total_h_with_tufts: 163 → ~221` (will recompute exactly with new tuft height from Fix 4). Top-level `dimensions.z` and `echoedDimensions.cradle.z` and `echoedDimensions.cradle_body_no_tufts.z` all update.

### Fix 2 — Heart-shaped (rounded-shield) facial disc

- **Current state (from round-1 render):** circular ovoid disc, 70×54mm, centered at z=90 (behind printer). Visible only on bare-part renders.
- **Target state:** heart-shaped (rounded-shield, barn-owl style) disc. Wider at top, narrowing toward a soft V at the bottom. Located in the face zone (z=143-205), filling most of it.
- **Specific direction:**
  - **Disc shape:** rounded shield / inverted teardrop. Top edge is a single arc ~70mm wide near z=200 (just below the panel top, leaving ~5mm gap to the rounded top). Sides curve inward as Z decreases. Bottom narrows to ~40mm wide near z=148, ending in a soft V-point centered at x=0.
  - **Implementation suggestion:** hull or polygon-extrude a rounded-shield 2D silhouette, then carve into the panel +Y face. Or build via 4-6 sphere/circle primitives composed (one large at the top, two narrowing toward bottom, one at the bottom V). Whichever produces the cleanest mesh.
  - **Disc depth:** 1.5mm at the deepest point (probably mid-height), tapering to 0mm at the perimeter rim. Concave bowl, not flat-bottomed.
  - **Rim:** soft, r=2mm. The disc edge should not be a sharp cut into the convex panel face.
  - **Disc Y-position:** carved INTO the +Y face of the panel. The panel +Y face is convex (sagitta 1.79mm at center per round-1 measurement); the disc carves through that, leaving ~3-3.5mm net panel thickness at the disc center (still above the 1.5mm thin-wall floor).
- **Classification:** brief-was-wrong (round-1 used circular disc; v2 uses real owl anatomy).
- **Printability note:** disc carved INTO a vertical face — fully self-supporting. Rim curves are small and printable. No supports.
- **Affects spec?** yes — replace `back_panel_facial_disc_*` block with new heart-shaped params: `face_disc_top_z: 200`, `face_disc_bottom_z: 148`, `face_disc_top_w: 70`, `face_disc_bottom_w: 40`, `face_disc_depth_max_mm: 1.5`, `face_disc_rim_r: 2`, `face_disc_shape: "rounded-shield"`.

### Fix 3 — Recessed eye sockets (NOT proud domes)

- **Current state (from round-1 render):** eyes were proud dome-topped hemispheroids, 11×9 ellipses, 2mm proud of the disc floor (~0.5mm proud of the panel surface). Pupils were 2.5mm hemispheres on top of the eyes. Combined effect: cartoon mascot face; the user's "horror" reaction.
- **Target state:** eyes are **sunk INTO the disc**, not protruding. Substantially larger than v1. No pupils.
- **Specific direction:**
  - **Eye shape:** vertically elongated ellipses, 16mm wide × 20mm tall (each).
  - **Eye position:** centers at z=180 (within face zone z=143-205, at 0.6 of face zone height — high in the disc per real owl). x=±16mm (center-to-center 32mm).
  - **Eye depth:** recessed **1.5mm** below the disc floor (so total panel-surface-to-eye-back is disc 1.5mm + eye 1.5mm = 3mm at center). Remaining panel material at eye center: panel-Y-thickness (~5mm at center with convexity) − 3mm = ~2mm. Above the 1.6mm thin-wall floor.
  - **Eye geometry:** simple ellipsoidal recess. Bottom of recess can be a partial hemisphere (rounded inward — barn-owl eyes appear as deep dark recesses). Sharp cut at the rim is fine; soft fillet (r=0.5mm) at the rim if mesh allows. Definitely no proud domes, no rim halos, no protruding rings.
  - **No pupils.** Skip them entirely. The dark recess shadow IS the eye.
- **Classification:** brief-was-wrong (round-1 cartoon-mascot construction; v2 real-owl reference).
- **Printability note:** eyes are recesses INTO a vertical face — every layer above is supported. No bridges, no overhangs. Recess depth 1.5mm × ellipse 16×20 is comfortable for FDM at 0.2mm layer (recess walls = 7-8 layers).
- **Affects spec?** yes — replace `back_panel_eye_*` and remove `back_panel_pupil_*` entirely. New params: `face_eye_w: 16`, `face_eye_h: 20`, `face_eye_recess_depth: 1.5`, `face_eye_center_z: 180`, `face_eye_center_x_offset: 16`.

### Fix 4 — Asymmetric hooked beak

- **Current state (from round-1 render):** centered triangular beak, 9mm wide × 7mm tall, 3.5mm proud, with a slight 3D forward apex. Symmetric. Read as small/cartoon.
- **Target state:** larger asymmetric hooked beak suggesting a real raptor beak. Narrow at top, wider at bottom, tip pointing down with slight forward hook curl.
- **Specific direction:**
  - **Beak silhouette (from +Y view):** narrow vertical wedge that bulges and curves slightly. Top width ~4mm, base width ~10mm at z≈158, tip at z≈148-150. Slight asymmetry: tip offset ~1mm toward x=+1 (tiny lean — gives "personality" without breaking symmetry too overtly). Or symmetric is fine if asymmetric proves hard.
  - **Beak Y-profile:** proud 4mm at the tip, tapering to 1mm proud at the top. The tip pokes outward in +Y; the top blends into the disc surface. Slight forward hook: the tip's +Y position is ~5mm forward of the base, so the beak curls forward as it descends. Asymmetric hook = an extra small bulge on the +Y face near the tip suggesting a curved-down hook tip.
  - **Beak position:** center at x=0 (or x=+1 for asymmetric lean), z=160 ± few mm. This is below the eyes (eye centers at z=180, beak top at z=164) and inside the lower V of the heart-shaped disc.
  - **Beak material/treatment:** still printed as panel-color. No texture, no surface treatment.
- **Classification:** brief-was-wrong (round-1 cartoon beak; v2 raptor-beak reference).
- **Printability note:** asymmetric hooked beak with a forward-curling tip creates a transient underhang where the tip projects forward of the base footprint. Per brief, **supports permitted for beak apex**. Try geometric avoidance first — if the forward-curl angle stays under 35° from vertical, no supports needed; if curl exceeds 35°, allow tree supports.
- **Affects spec?** yes — replace `back_panel_beak_*` with: `face_beak_top_w: 4`, `face_beak_base_w: 10`, `face_beak_top_z: 164`, `face_beak_tip_z: 148`, `face_beak_proud_max_mm: 4`, `face_beak_tip_forward_offset_mm: 5`, `face_beak_x_lean_mm: 1` (or 0 if symmetric).

### Fix 5 — Tufts: rebuilt as splayed feather clumps (NOT swept mass)

- **Current state (from round-1 render):** single 3D-swept mass per tuft, base 35mm wide, tip pointing up + curling forward 8mm. Reads as wizard-hat point / curled horn / soft-serve swirl.
- **Target state:** each tuft = 3 hulled feather-shaped protrusions, splayed sideways, round-tipped, NO forward curl, outward lean only.
- **Specific direction:**
  - **Per-tuft construction: 3 feather profiles, hulled together.**
    - Inner feather: ellipsoid (or hulled extruded ellipse), 8mm wide × 14mm tall × 5mm Y-deep, tilted **10° outward** from vertical, round tip at top, base blends into panel top.
    - Middle feather: 10w × 16h × 6mm Y-deep, tilted **20° outward**, round tip, base blends.
    - Outer feather: 8w × 12h × 4mm Y-deep, tilted **30° outward**, round tip, base blends.
    - Hull or union the three together to get a splayed silhouette. Hull is preferable (smooth blend); union is acceptable if hull's mesh quality suffers.
  - **Total tuft footprint at base:** ~30mm wide along ±X axis, ~7mm along ±Y axis (panel Y-thickness + a bit forward).
  - **Total tuft peak height above panel top:** ~16mm. With panel top at z≈205, peaks at z≈221.
  - **Tilt direction: outward only.** Each tuft leans toward its respective ±X direction. Left tuft leans toward −X; right tuft leans toward +X. **NO Y-direction tilt. NO forward sweep. NO curl.** This is the round-1 failure mode and must not return.
  - **Round-tipped:** tip caps are spherical or rounded-cone, not pointed. Apex radius effectively the radius of the feather's top cap.
  - **Base blend:** r=4mm fillet where each feather meets the rounded panel top. The whole tuft should appear to *grow from* the panel top, not sit on it.
  - **Tuft x-position:** mirror across x=0. Tuft centers at x=±25mm (so outer feather edges land near the panel exterior at x=±43, leaving ~5mm panel clear edge above each tuft).
- **Classification:** brief-was-wrong (round-1 forward-sweep construction); strong preference shift from "swept mass" to "splayed feather clumps."
- **Printability note:** per-feather lean angles are 10°, 20°, 30° from vertical — all under the 45° overhang threshold. **Hulled splay should not require supports.** This is a print-cost win compared to round 1 (which required tree supports for the forward-curl underhang). Verify in slicer preview before declaring "no supports needed"; if any feather profile creates a transient underhang from the hull operation, supports remain permitted but should be unnecessary if angles are correct.
- **Affects spec?** yes — replace the round-1 ear_tuft_* block. New params:
  - `tuft_count_per_side: 3`
  - `tuft_inner_w: 8`, `tuft_inner_h: 14`, `tuft_inner_yd: 5`, `tuft_inner_tilt_deg: 10`
  - `tuft_middle_w: 10`, `tuft_middle_h: 16`, `tuft_middle_yd: 6`, `tuft_middle_tilt_deg: 20`
  - `tuft_outer_w: 8`, `tuft_outer_h: 12`, `tuft_outer_yd: 4`, `tuft_outer_tilt_deg: 30`
  - `tuft_center_x: 25` (with mirror)
  - `tuft_base_blend_r: 4`
  - `tuft_construction: "hull-of-3-feathers"`
  - Remove `ear_tuft_forward_sweep_mm`, `ear_tuft_base_y_depth`, `ear_tuft_tip_y_depth`, `ear_tuft_tilt_outward_deg` (the old single-mass approach is dead).

### Fix 6 — Host-object proxy module (new — for use-state renders)

- **Current state:** all round-1 renders are bare-part. There is no SCAD module that renders the printer in place.
- **Target state:** a module `host_object_proxy(show=false)` exists in `cradle.scad` that draws a 78×152×143 box at the printer's installed position. Default `show=false` so STL export excludes it. Renders that need use-state pass `show=true`.
- **Specific direction:**
  - **Module signature:** `module host_object_proxy(show=false) { if (show) { ... } }`
  - **Geometry:** simple `cube([78, 152, 143])` translated to the installed position. Light gray color (`%` modifier or color() if cli-anything-openscad supports it for differentiation).
  - **Installed position:** based on spec, the printer pocket interior is 80×154×145 with 1mm XY clearance and 2mm Z clearance. Printer dimensions 78×152×143 fit centered in that pocket. Compute installed-position translate from spec params:
    - `pocket_interior_w_x_origin` + `printer_clearance_xy/2` for x
    - `pocket_interior_d_y_origin` + `printer_clearance_xy/2` for y
    - `base_thickness` for z (printer sits on the pocket floor)
  - **Toggle from CLI:** add a top-level OpenSCAD parameter `render_with_host = false` that gates the proxy. cli-anything-openscad can override via `--param render_with_host=true` for in-use renders.
- **Classification:** new infrastructure (lesson-derived, post-round-1).
- **Printability note:** N/A — proxy is render-only, never in STL.
- **Affects spec?** yes — add `render_with_host_default: false` to spec. Add a param description for the new flag.

### Fix 7 — Hero render set (use-state added)

- **Current state:** round-1 produced 6 user-frame renders, all bare-part.
- **Target state:** 7 renders. Two new use-state renders are the **primary heroes** (silhouette test runs on `cradle-user-front-in-use.png`). Bare-part renders preserved as record.
- **Specific direction:** produce these renders via `cli-anything-openscad`:
  1. **`cradle-user-front-in-use.png`** — primary hero. Camera at user-front (+Y looking toward −Y), perpendicular to panel +Y face. Render with `render_with_host=true`.
  2. **`cradle-user-front-threequarter-in-use.png`** — marketing hero. User-front-threequarter angle (camera offset ~30° from straight-on, slightly elevated). Render with `render_with_host=true`.
  3. `cradle-user-front.png` — bare-part record.
  4. `cradle-user-front-threequarter.png` — bare-part record.
  5. `cradle-user-left.png` — side profile.
  6. `tray-user-front.png` — tray scoop face.
  7. `tray-user-front-threequarter.png` — tray three-quarter.
  - **Camera-preset note:** as in round 1, cli-anything-openscad presets are suspect for this design's aspect ratio. If `front` preset misrenders (e.g. produces top-down for the cradle), fall back to explicit eye+center cameras. Filenames must be user-frame regardless of preset used.
- **Classification:** infrastructure (lesson-derived).
- **Printability note:** N/A.
- **Affects spec?** yes — `views` list updated (replace round-1 list with the 7 above).

### Fix 8 — Convex panel face: bump to 3mm sagitta (was 2mm in spec, measured 1.79mm)

- **Current state (from round-1 render):** panel +Y face is convex with 1.79mm measured sagitta. Modeler reported "visually subtle"; the convexity registers as a faint shading gradient but doesn't read strongly.
- **Target state:** sagitta bumped to **3mm**. Panel Y-thickness at center grows from 5mm to 6mm; at edges stays at 3mm.
- **Specific direction:**
  - `back_panel_front_convexity_mm: 2 → 3`.
  - Verify that the new disc carve (1.5mm depth at center) leaves enough panel material: 6mm − 1.5mm = 4.5mm, comfortably above any thin-wall threshold.
  - With recessed eyes (1.5mm into disc), eye-center material thickness = 6 − 1.5 − 1.5 = **3mm**. Comfortable. (Round-1 calculation had this at 2mm with the 2mm sagitta; 3mm sagitta makes it safer.)
- **Classification:** preference shift (round-1 modeler flagged 2mm as visually subtle; v2 leans into the curvature read).
- **Printability note:** convex vertical face — every horizontal slice is fully self-supporting. No new print concerns.
- **Affects spec?** yes — `back_panel_front_convexity_mm: 2 → 3`.

## Items carried forward unchanged from round 1

These all still work and should NOT be re-litigated:

- **Fix 1 round-1 (delete tray face)** — already done; tray.scad is clean. Keep deleted.
- **Fix 5 round-1 (printer→shelf concave fillet r=8)** — already in place. Keep.
- **Fix 6 round-1 (feather embosses removed)** — already done. Keep.
- **Fix 7 round-1 (tray scoop + integrated finger-grip)** — already in place. Keep all params: `tray_scoop_angle_from_horizontal: 45`, `tray_scoop_height: 14`, `tray_scoop_base_vertical_height: 7`, `tray_scoop_finger_grip_width: 30`, `tray_scoop_finger_grip_depth: 2.5`, `fillet_scoop_lip_leading_edge_r: 2`.
- **Fix 8 round-1 (base plate r=8 corners + foot blend r=1.5)** — already in place. Keep.
- **Fix 3 round-1 partial (rounded panel top, softened vertical edges, base concave fillet)** — keep architecture; only height changes (Fix 1 above). Vertical edge fillet effective r=1.2, top fillet r=6, base concave fillet ramp — all preserved.
- **Two-part architecture, stepped body, full-perimeter low base, printer pocket 80×154×145, tape-exit clearance, cable notch (25×20 on −Y at z=0-20), tray interior 100×91×40, tray exterior 103.2×94.2×21.6, tray-to-slot sliding fit 0.35mm/side, foot count/spacing/diameter (4× d=8 × h=3).**
- **`hero_dimension`: back_panel_height** — same name, different value (145 → 205). Still the hero.

## Leave alone (round 1 successes preserved)

- Tray architecture: clean utility, no decoration, no attempt at face. The tray was the round-1 success and stays exactly as built.
- Scoop integrated finger-grip: legible, working, no rework.
- Stepped cradle body footprint (86mm printer section → 108mm shelf section): unchanged.
- Foot construction (cylinder feet with upper r=1.5 fillet to plate): unchanged.

## Uncertain — flag for round-3 critique

- **Heart-shaped disc silhouette dimensions** (top width 70mm, bottom width 40mm, V-point at z=148): if the V-point reads as "two ovals jammed together" rather than "single pointed shield," consider a smoother continuous curve from top to bottom (more rounded teardrop, less hard V).
- **Eye recess depth 1.5mm:** if eyes don't read as "deep dark eye sockets" in the use-state render, consider 2mm. If the recess depth makes the eyes look hollow-creepy (which is a real risk with deep recesses on FDM), consider 1.0mm.
- **Beak asymmetric x_lean (1mm):** if the asymmetry reads as "modeling error" rather than "personality," go symmetric (x_lean=0). The forward-hook curl is the more important asymmetric element; the x_lean is a small additional move and can be dropped.
- **Tuft hull vs union:** if hull-of-3-feathers produces a smooth blob rather than three distinct feather profiles, the round-2 silhouette may need explicit gaps between feathers — switch from hull to union with mild base-blend fillets between feathers.
- **Convex panel sagitta 3mm:** if the bump goes too far and reads as "the panel is bulging outward weirdly," dial back to 2.5mm.
- **Face zone vertical proportions:** disc fills ~85% of face zone. If the disc feels cramped against the panel top (tufts very close to disc top), consider reducing disc height by 5-7mm to leave breathing room.

## Summary for orchestrator

- **8 fixes**, all with spec-level implications. All `Affects spec?: yes` items applied inline (orchestrator pre-authorized for this round).
- **Scope:** structural fix (panel grows 60mm), face anatomy fully replaced (shape, eyes, beak), tufts fully replaced. Tray and lower cradle architecture preserved. Net diff: substantial cradle.scad rewrite of the back panel + tufts + face geometry; tray.scad essentially unchanged from round 1; spec.json substantial changes to face/tuft/panel-height blocks.
- **Supports:** likely none required (Fix 5 lean angles ≤ 30°). Beak forward-hook may flirt with 35° overhang; supports remain permitted per brief but should be avoidable.
- **Render priority:** **use-state render is the primary hero.** If `cradle-user-front-in-use.png` doesn't show a legible owl head above the printer body, the round failed regardless of bare-part render quality.
- **Recommended next step:** `re-model + re-render + re-critique`. Round-3 critique will focus on (a) does the use-state render show a coherent owl?, (b) does the face read as real-owl rather than mascot?, (c) do the tufts read as feather clumps or like something unintended?, (d) does the increased panel height alter the proportions in unexpected ways?

## Build-volume sanity check

- Cradle.x = 108mm. Bambu X1C max = 256mm. PASS.
- Cradle.y = 254.9mm. Max = 256mm. **Cuts close** (~1.1mm margin). Same as round 1 — already known to fit.
- Cradle.z = 205 (panel top) + 16 (tuft peak above panel top) = **~221mm**. Max = 256mm. PASS with 35mm margin.
- Tray dimensions unchanged. PASS.
