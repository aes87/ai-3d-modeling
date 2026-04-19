# Modeler Notes — ptouch-cradle — Round 1

**Based on:** renders in `output/cradle-user-*.png`, `output/tray-user-*.png` at commit `90dd34a` (shipped v2), plus reviewed attachments at `obsidian-vault/vault/projects/3d-printing/attachments/ptouch-cradle-critique-01/`
**Brief version:** `id/brief.md` through Revisions entry 2026-04-19 round 1
**Scope:** full reimagining round. Motif consolidated onto back panel; tray face deleted; scoop lip restored. Expect geometric churn on cradle.scad (back panel + tufts + transition) and tray.scad (face deletion + scoop restoration). Spec params update in this round.

## Fix list

### Fix 1 — Motif consolidation: delete tray face entirely

- **Current state (from render):** `tray-user-front-threequarter.png` shows two eye discs (r=9, 2mm proud), two pupil discs (r=4, 4mm proud), and a downward beak (8×8, 2.5mm proud) on the tray's +Y wall.
- **Target state:** tray +Y wall is clean — no eyes, no pupils, no beak. All owl-face geometry deleted from `tray.scad`.
- **Specific direction:** remove the modules/blocks that generate the eye/pupil/beak protrusions on the tray. Zero out or delete the following spec params: `tray_owl_eye_emboss_radius`, `tray_owl_eye_emboss_raise`, `tray_owl_eye_center_z`, `tray_owl_eye_center_x_offset`, `tray_owl_pupil_radius`, `tray_owl_pupil_additional_raise`, `tray_owl_pupil_total_raise`, `tray_owl_beak_*` (all).
- **Classification:** brief-was-wrong (earlier iteration put the face here; round-1 critique consolidates motif onto back panel).
- **Printability note:** removing proud features only simplifies print — no new concerns.
- **Affects spec?** yes — remove the `tray_owl_*` params from `spec.json`. Route via orchestrator.

### Fix 2 — Ear tufts: invert proportion, tilt outward, 3D sweep, base blend

- **Current state (from render):** `cradle-user-front-threequarter.png` shows two triangular tufts, vertical, taller than wide (h=35, w=25), sharp apex r=2, 2D extrusion with 3mm Y-depth. Textbook cat-ear geometry.
- **Target state:** wider-than-tall tufts, tilted 25-30° outward, 3D-swept forward-to-back along a curved path, with a concave dip in the outer silhouette suggesting feather bunching, blended into the rounded back-panel top with a r=5mm fillet.
- **Specific direction:**
  - Proportion: base width ~35mm, peak-height-above-panel-top ~18mm (inverted from current 25w × 35h).
  - Outward tilt: 25° from vertical for each tuft (left tuft leans −X, right tuft leans +X).
  - 3D sweep: the tuft's centerline is a quadratic arc from base to tip, curving ~8mm forward in +Y between z=0 of the tuft and its apex. Consider `skin()` / `hull()` of 3-5 cross-section profiles along the path, or a `linear_extrude` with `twist` + an extruded-then-rotated hull. Aim for the tip to sit ~8mm forward of the base footprint.
  - Silhouette: the outer edge (away from panel center) should be a 3-segment curve — straight base → concave mid-dip → convex tip. Bezier or piecewise circular arcs both acceptable. The inner edge (toward panel center) is a gentler single convex curve.
  - Base blend: r=5mm fillet where the tuft meets the panel top; the tuft should *emerge* from the panel, not sit on it as a separate prism.
  - Y-depth (thickness): ~6-8mm at the base, tapering to ~3-4mm at the tip. Not the current uniform 3mm slab.
- **Classification:** brief-was-right-modeler-missed (earlier spec described "ear tufts" without geometric discipline, which the modeler reasonably interpreted as a 2D extruded triangle).
- **Printability note:** 25° outward tilt is within the 45° overhang threshold. The 3D forward sweep creates a transient underhang where the tuft curves away from the panel between z~145mm (panel top) and z~158mm; **tree supports permitted per brief**. Expect ~10-20 min added print time.
- **Affects spec?** yes — update spec.json: `ear_tuft_base_width: 25 → 35`, `ear_tuft_peak_height_above_back_panel_top: 35 → 18`, `ear_tuft_peak_z_from_base: 180 → 163`, add `ear_tuft_tilt_outward_deg: 25`, add `ear_tuft_forward_sweep_mm: 8`, add `ear_tuft_base_blend_r: 5`, add `ear_tuft_base_y_depth: 7`, add `ear_tuft_tip_y_depth: 3.5`. Update `cradle_total_h_with_tufts: 180 → 163`.

### Fix 3 — Back panel silhouette: rounded top, softened vertical edges, gently convex +Y face

- **Current state (from render):** `cradle-user-front-threequarter.png` and `cradle-user-front.png` show the back panel as a dead-flat slab, 145×86×3mm, with sharp vertical corners, a hard top edge (r=1.5mm fillet negligible at this scale), and a featureless flat +Y face. Reads as "rectangle stood on edge."
- **Target state:** panel reads as a softened blade with a rounded top carrying the tufts, softened vertical edges, and a gently convex +Y face that "hugs" the printer.
- **Specific direction:**
  - **Rounded top:** the top edge of the back panel is an arc, not a horizontal line. Top-center at z=145mm, top-corners (at ±X panel edges) at z~138mm. Radius of the arc ~160mm (shallow sweep). Tufts grow from the rounded top along this arc.
  - **Softened top fillet:** where the rounded top transitions to the +Y and −Y panel faces, apply r=6mm fillet (hero-tier from brief's fillet schedule). The tuft base blend (r=5, Fix 2) rides on top of this.
  - **Vertical edge fillets:** the two vertical edges of the back panel (where +Y and ±X faces meet) get r=4mm fillets, full-height from base to rounded top. Reads as a softened blade, not a slab edge.
  - **Convex +Y face:** the +Y face is not planar — it bulges outward by 1.5-2mm at its horizontal center, tapering to flat at the ±X vertical edges. Implement as a circular-arc cross-section (chord 86mm, sagitta 2mm → radius ~465mm). Every horizontal slice of the panel has the same convex arc; the panel's Y-depth at X=0 is ~5mm, at X=±43mm is ~3mm.
  - **−Y face:** stays flat (this is the against-wall face, carries the cable notch). No cosmetic work needed.
  - **Base blend:** where the panel meets the shelf/printer-section body, add a r=4mm concave fillet blending the panel-bottom-edge into the body top.
- **Classification:** brief-was-wrong (rigidity was never identified as a concern in earlier briefs; whole-panel form language missing).
- **Printability note:** rounded top + convex +Y face are both printable in the current orientation (base down, panel vertical). Every horizontal slice is fully self-supporting. No supports needed for the panel geometry itself.
- **Affects spec?** yes — add `back_panel_top_arc_radius: 160`, `back_panel_top_center_z: 145`, `back_panel_top_corner_z: 138`, `back_panel_front_convexity_mm: 2`, `back_panel_vertical_edge_fillet_r: 4`, `back_panel_top_fillet_r: 6`, `back_panel_base_concave_fillet_r: 4`. Keep `tall_back_panel_height: 145` as the hero dimension (refers to top-center height).

### Fix 4 — Back-panel facial disc + eyes + beak (new geometry)

- **Current state (from render):** flat +Y face of the back panel carries no facial features. Owl face currently (wrongly) lives on the tray.
- **Target state:** a shallow ovoid facial disc recessed into the +Y face of the back panel at ~62% of panel height, carrying two forward-facing dome-topped eyes and a 3D beak wedge.
- **Specific direction:**
  - **Facial disc:** ovoid recess in the +Y face of the back panel. Width 70mm, height 54mm (slightly taller than wide). Center at z=90mm (62% of 145mm panel height), x=0. Depth 1.5mm at the disc center, tapering to 0mm at the disc perimeter (shallow concave bowl, not a flat-bottomed recess). Rim edge r=2mm (soft, not sharp). The disc is carved through the convex +Y surface — at z=90, x=0 the net Y-depth of the panel is ~5mm (convex) − 1.5mm (disc) = ~3.5mm, within structural tolerance for the 3mm base wall.
  - **Eyes:** two vertically elongated ellipses, each 11mm tall × 9mm wide, forward-facing. Centers at z=95mm, x=±16mm. Protrude 2mm proud of the disc floor (net 0.5mm proud of the surrounding convex panel surface — eyes emerge gently from the disc, not floating on the wall). Dome-topped profile (hemispheroid, not flat cylinder). Gentle rim r=1mm.
  - **Pupils (optional):** small hemispheres, radius 2.5mm, centered on each eye, proud 0.8mm above the eye dome. Dome-topped. If pupils feel too cartoon on first render, delete them — the eyes alone with a soft shadow can carry the forward-facing read.
  - **Beak:** 3D downward-pointing wedge between and below the eyes. Centered at z=80mm, x=0. Base width 9mm, base height 7mm, tip at z=73mm. Protrudes 3.5mm proud of the disc floor, with the tip pokingfurther forward (~4mm proud at apex). Implement as a hull of a flat base polygon on the disc surface and a small rounded apex point 4mm forward. NOT a 2D triangle extrusion. Apex radius r=1mm (rounded, not sharp).
  - **Symmetry:** face is symmetric about x=0.
- **Classification:** brief-was-wrong (earlier brief placed the face on the tray; round 1 relocates).
- **Printability note:** eyes and pupils are dome-topped hemispheroids proud of a curving vertical face — every layer is supported by the layer below. The beak's 3D wedge has a transient underhang from apex to base if the apex is forward of the base footprint; **supports permitted per brief** but should be avoidable with a gentle apex-forward-sweep < 30° from vertical (verify in slicer preview before committing).
- **Affects spec?** yes — add full `back_panel_facial_disc_*`, `back_panel_eye_*`, `back_panel_pupil_*`, `back_panel_beak_*` param block. Remove `tray_owl_*` block (Fix 1).

### Fix 5 — Printer-section → shelf transition: concave fillet replaces 45° chamfer

- **Current state (from render):** hard 45° chamfer cuts over 11mm y-depth, visible mid-body. Reads as "two objects joined by a bevel."
- **Target state:** concave fillet r=8-10mm, swept the full height of the low-wall region (z=0 to z=25mm). Reads as "one form gathering from narrow to wide."
- **Specific direction:**
  - Replace the 45° chamfer geometry with a quarter-circle concave sweep of radius 8mm (hero-tier fillet from brief).
  - Sweep spans full height of the low-wall zone (z=0 to z=25mm for the perimeter walls) on both sides (±X).
  - Above z=25mm the back panel resumes its narrower 86mm-matching footprint (transitioning to the rounded-top + convex-face treatment from Fix 3).
- **Classification:** preference-shift (chamfer was deliberate; overriding for unified curvature language).
- **Printability note:** concave fillet — every layer is larger than the one below. Fully self-supporting, no overhang concerns.
- **Affects spec?** yes — remove `printer_section_to_shelf_chamfer_*` (if present as a param), add `printer_section_to_shelf_concave_fillet_r: 8`.

### Fix 6 — Printer-section side-wall feather embosses: remove

- **Current state (from render):** three half-ellipse arches per side wall, 1mm proud, 20×12mm each, visible as faint stripes in `cradle-user-front-threequarter.png`.
- **Target state:** side walls clean, no applied decoration.
- **Specific direction:** delete the emboss-generating code from `cradle.scad`. Zero out or delete the spec params that drove them.
- **Classification:** preference-shift (feature shipped in v2, removed in round 1 per user feedback + brief's "applied decoration is a last resort").
- **Printability note:** simplification only — no new concerns.
- **Affects spec?** yes — remove `feather_emboss_*` params (count, dims, positions) if present.

### Fix 7 — Tray scoop lip + integrated finger-grip (restoration + evolution)

- **Current state (from render):** `tray-user-front-threequarter.png` shows a simple vertical rectangular +Y wall (h=21.6mm), no scoop, no finger-grip. The scoop lip existed in iter 1 (h=41.6mm tray) but was removed in iter 2 along with the grip scallop.
- **Target state:** 45° scoop across the upper portion of the tray front wall, with a shallow concave dip in the center of the scoop that doubles as a finger-pull for tray removal. Grip and scoop are one integrated feature, not two.
- **Specific direction:**
  - **Scoop proportion:** tray front wall is 21.6mm tall exterior. Lower 7mm stays vertical (structural base). Upper 14mm tilts back at 45° from horizontal (i.e., the face angles from vertical-at-z=7mm backward-and-up to horizontal-at-z=21.6mm, receding into the tray interior by ~14mm of Y).
  - **Integrated finger-grip:** across the central 30mm of the scoop face (x ∈ [−15, +15]), the scoop surface dips inward by an additional 2.5mm depth (concave sweep, Bezier or single-arc). Outside the central 30mm the scoop is the flat 45° face. The dip gives the user a natural finger-pull that doesn't require a separate grip scallop.
  - **Leading edge:** the top edge of the scoop (where the 45° face meets the top edge of the wall at z=21.6mm) gets r=2mm fillet. Soft, not sharp.
  - **Front-face edges:** the vertical edges where the tray front wall meets the ±X side walls get the existing r=3mm tray vertical-edge fillet (unchanged).
  - **No grip scallop as a separate feature.** Do not restore the semicircular top-edge grip scallop from iter 1.
- **Classification:** preference-shift (restoring a deleted feature in evolved form — not identical to iter 1).
- **Printability note:** 45° face prints as overhang at the threshold; has been printable in iter 1 with no supports. The central concave dip is an additional mild overhang but still within the threshold envelope. No supports required; watch surface quality in slicer preview.
- **Affects spec?** yes — restore/update: `tray_scoop_angle_from_horizontal: 45`, `tray_scoop_height: 14` (was 15, rebalanced for 21.6mm wall), `tray_scoop_base_vertical_height: 7`, `tray_scoop_finger_grip_width: 30`, `tray_scoop_finger_grip_depth: 2.5`, `fillet_scoop_lip_leading_edge_r: 2`. Remove `tray_grip_scallop_*` params (not restored as separate feature).

### Fix 8 — Base plate corner + foot-to-plate softening

- **Current state (from render):** base plate corners r=6mm. Feet are flat cylinders meeting the plate at a hard 90° step.
- **Target state:** softened base — plate corners r=8mm, foot-to-plate joints filleted.
- **Specific direction:**
  - Base plate corner fillet: r=6 → r=8 (both top and bottom of plate, on the four corners).
  - Foot-to-plate blend: r=1.5mm concave fillet where the top of each cylindrical foot meets the bottom of the base plate. The foot still prints as a flat cylinder (foot bottom flat on bed); the blend is on the *upper* meeting edge only.
- **Classification:** preference-shift (unified curvature language extended to the base).
- **Printability note:** base-plate corner radius increase — printable. Foot-to-plate upper fillet — printable (the fillet sits above the bed; every layer above it is self-supporting). No supports needed.
- **Affects spec?** yes — `fillet_base_plate_corners_r: 6 → 8`. Add `fillet_foot_to_plate_r: 1.5`.

## Leave alone

These survived round-1 review and must not drift on the next iteration.

- **Two-part architecture (cradle + tray):** unchanged. Cradle body, tray body, tray sliding into a shelf slot on the cradle.
- **Stepped body footprint:** 86mm printer section → 108mm shelf section stays. Only the transition geometry changes (Fix 5, chamfer → concave fillet).
- **Full-perimeter 25mm low base wall:** stays. The four low walls around the printer pocket and tray shelf are unchanged.
- **Printer pocket dimensions and clearances:** 80×154mm interior, 143mm pocket height, 1mm XY / 2mm Z clearance. Do not touch.
- **Tape-exit clearance geometry:** tape exits at printer-front (+Y of the printer pocket), lower-middle. The 25mm front wall clears the tape exit. Do not change.
- **Cable notch:** 25×20mm U-notch in the −Y wall, z=0-20mm. Position and dims unchanged.
- **Tray interior dimensions:** 100×91×40mm interior. Walls 1.6mm. Floor 1.6mm. Kanban catch-basin proportions stay.
- **Tray-to-slot sliding fit:** 0.35mm per-side clearance (exterior 103.2×94.2mm tray vs. interior 103.9×94.9mm slot). Do not change the fit math; if the tray front-wall geometry changes (Fix 7), keep the overall exterior bounding box at 103.2×94.2×21.6.
- **Foot count / spacing / diameter:** 4 cylindrical feet, d=8mm, h=3mm. Only the upper foot-to-plate joint gains a blend (Fix 8).
- **Seam hiding:** user-back (−Y) of panel and underside of base plate. No seams on the +Y panel face or a tuft.
- **Hero dimension:** back panel height 145mm (at center). Reflects to `tall_back_panel_height` in spec.

## Uncertain

Fixes that propose specific dimensions whose visual outcome can't be fully predicted from renders. Flag for re-critique after round 1 renders land.

- **Back-panel convexity depth (Fix 3):** 2mm sagitta over 86mm chord may read as too-subtle at normal viewing distance, or may read as a manufacturing defect. If the convexity is imperceptible in the new renders, consider 3-3.5mm. If it reads as a manufacturing error, reduce to 1-1.5mm.
- **Facial disc depth (Fix 4):** 1.5mm recess depth is at the minimum legibility threshold on an FDM print at typical desk distance. If the disc doesn't read as a framed recess, bump to 2mm.
- **Pupils (Fix 4):** dome-topped hemispheres at r=2.5mm, 0.8mm proud — may tip into "cute button" territory vs. "owl pupil." Marked optional in brief. Render first without pupils, compare to a variant with pupils, let round 2 critique decide.
- **Tuft tip Y-depth taper (Fix 2):** tapering from 7mm base to 3.5mm tip may fight with the outward-sweep geometry — the tapered tip might print poorly or look spindly. If so, hold Y-depth uniform at ~5mm and rely on the silhouette + tilt alone for the feather read.
- **Integrated finger-grip dip depth (Fix 7):** 2.5mm depth across 30mm width may read as "scoop with a ding in it." If it's not clearly a finger-pull in the render, deepen to 3.5mm or widen to 40mm.
- **Printer-section → shelf concave fillet (Fix 5):** r=8mm fillet over 11mm y-delta may leave a small flat region between the narrow and wide widths. If so, increase to r=11 to make the sweep fully tangent on both ends.

## Summary for orchestrator

- **8 fixes**, of which 7 have spec-level implications. Full spec.json rewrite expected (many params add/remove/update).
- **Scope:** largest round this design has seen. Back panel is substantially rebuilt (Fix 3 + Fix 4), tufts are substantially rebuilt (Fix 2), tray face is deleted (Fix 1), tray scoop is restored in evolved form (Fix 7). Transition + embosses + base (Fix 5, 6, 8) are bookkeeping by comparison.
- **Supports:** tree supports enabled for the tray is not needed. Tree supports required for ear tufts (Fix 2). Supports permitted but avoidable for beak apex (Fix 4) — try geometric avoidance first.
- **Recommended next step:** `re-model + re-render + re-critique`. After round 1 renders land, round 2 critique will focus on (a) whether the facial disc + eyes + beak read as an owl, (b) tuft silhouette success, (c) whether convexity reads, (d) whether the integrated finger-grip reads, and (e) any of the Uncertain items above that ask for a second look.
- **Spec-routing:** all `Affects spec?: yes` items route via orchestrator → spec-writer for spec.json update before modeler picks this up. Alternatively, if orchestrator is confident the fixes are self-contained to cradle.scad + tray.scad + spec.json (no requirements.md change), the modeler can do the spec update inline and call it out in the modeling-report.
