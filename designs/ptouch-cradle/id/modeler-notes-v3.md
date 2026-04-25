# Modeler Notes — ptouch-cradle — Round 3

**Based on:** round-2 renders at `designs/ptouch-cradle/id/round-02-renders/`, user reaction on commit `b931983` ("decent but I don't want it; abandon owl direction"), brief revision 2026-04-25 (owl abandoned, v3 minimalism direction locked).
**Brief version:** `id/brief.md` through Revisions entry 2026-04-25 round 3.
**Scope:** Major reduction. The owl direction is abandoned entirely. Most of round 1 + round 2 face/tuft/panel geometry is deleted. Tall back panel becomes a 25mm low wall matching the other 3 perimeter walls. Fillet schedule collapses to 2 tiers (r=3 utility, r=10 hero). Tray and lower cradle infrastructure stay as they are.

## Round-2 deltas in one paragraph

Round 2 fixed the structural placement (face visible above printer) but the creature read shifted from uncanny owl to happy panda/teddy bear because hull-of-3-feathers tufts smoothed into rounded mammalian-ear blobs and face features felt small. User abandoned the owl direction outright. Round 3 is a pivot, not an iteration: drop the entire creature motif, collapse the back panel to a low symmetric wall, apply a clean two-tier fillet schedule everywhere. The printer becomes the visual subject; the cradle is a quiet frame.

## Fix list

### Fix 1 — Tall back panel: collapse to 25mm low wall

- **Current state (round 2 build):** back panel rises to 205mm at center, 198mm at corners, with a top arc, convex +Y face (3mm sagitta), softened vertical edges (r=1.2 effective), top fillet (r=6), base concave fillet ramp, and all face/tuft geometry attached.
- **Target state:** the back panel as a distinct element is gone. The −Y wall of the cradle is a 25mm low wall, identical in height to the +Y front wall and the ±X side walls. Wall thickness uniform 3mm. Top edge filleted r=3.
- **Specific direction:**
  - Delete the entire `back_panel` module (or whatever organizes the panel geometry in `cradle.scad`).
  - The −Y wall is now part of the same full-perimeter low-wall block that wraps the printer pocket. If the existing geometry constructs the perimeter walls separately from the back panel, merge them — there's no longer a distinction.
  - Top edge of the −Y wall: r=3 fillet, matching the other 3 perimeter walls.
  - Vertical exterior edges of the −Y wall: r=10 fillet at the corners (where −Y wall meets ±X walls), continuous with the existing perimeter corner softening (Fix 4 below). Effectively the cradle exterior corners are all r=10.
  - The cable notch at z=0-20mm in the −Y wall stays. It now occupies 80% of the wall's height (20/25); the remaining 5mm of wall above the notch is a thin bridge — verify printability (5mm wall over 25mm-wide notch, supported by side walls — should print fine, but flag to print-reviewer).
  - Wall thickness: 3mm (matches `wall_thickness` spec). Interior of the −Y wall stays flat (sharp interior edge with the base — interior pocket walls are exempt from the fillet schedule).
- **Classification:** preference shift (owl direction abandoned; tall panel was carrying the owl, no longer needed).
- **Printability note:** simpler than before. No supports needed anywhere. The 5mm wall bridge above the cable notch is the only feature requiring a brief printability check.
- **Affects spec?** yes. Delete: `tall_back_panel_height`, `back_panel_top_center_z`, `back_panel_top_corner_z`, `back_panel_arc_r` (or `back_panel_top_arc_radius`), `back_panel_top_fillet_r`, `back_panel_vertical_edge_fillet_r`, `back_panel_front_convexity_mm`, `back_panel_base_concave_fillet_r`, `panel_convexity`, `cradle_total_h_with_tufts`. Update top-level `dimensions.z` and `echoedDimensions.cradle.z` to **~28** (25mm wall + small fillet allowance over). `cradle_body_no_tufts.z`: drop entirely (no longer meaningful concept). Keep `low_perimeter_wall_height: 25` as the hero dim.

### Fix 2 — Delete all owl/face/tuft geometry

- **Current state (round 2 build):** cradle.scad contains modules for facial disc carve, ellipsoid eye recesses, asymmetric beak hull, tuft hull-of-3-feathers per side. spec.json has dozens of owl-specific params.
- **Target state:** none of this exists in v3. Modules deleted from cradle.scad; params deleted from spec.json.
- **Specific direction:**
  - Delete from `cradle.scad`: `facial_disc()`, `eye_recess()`, `beak_hook()` (or whatever they're named), `tuft_left()`, `tuft_right()`, `tuft_feather()` — every face/tuft module. Also delete any callsite (`difference()` carving the disc, `union()` adding the tufts, etc.).
  - Delete the panel rounded-top arc geometry, panel convexity construction, panel vertical edge softening — superseded by Fix 1.
  - Delete from `spec.json`: every param starting with `face_`, `eye_`, `pupil_`, `beak_`, `tuft_`, `back_panel_`, `panel_convexity`, `ear_tuft_*`, anything named after creature anatomy. Comprehensive list — strip everything not in the "Items unchanged from round 2" section below.
- **Classification:** preference shift (owl direction abandoned).
- **Printability note:** simplification only.
- **Affects spec?** yes — large param deletion. Estimate ~25-30 params removed.

### Fix 3 — Fillet schedule: collapse to 2 tiers (r=3 utility, r=10 hero)

- **Current state (round 2 build):** mixed schedule — r=1.0 (foot blend), r=1.5 (now mostly gone), r=2 (disc rim), r=3 (tray vertical), r=4 (panel base concave), r=6 (panel top), r=8 (printer→shelf, base plate corners), plus the 1.2 effective for panel vertical edges.
- **Target state:** every visible exterior edge in the model has either r=3 (utility) or r=10 (hero) fillet. No other radii except the foot-to-plate r=1.5 (a function-driven exception).
- **Specific direction:**
  - **r=3 (utility) on:**
    - All top edges of the 25mm perimeter walls (all 4 sides).
    - All exterior vertical edges of the perimeter walls EXCEPT the four corners (which are r=10 — see below). Specifically the vertical edges where one face meets another at a corner; on the 25mm bathtub there are 4 exterior vertical corner edges, plus where the printer-section walls meet the shelf-section walls (which becomes the r=10 hero fillet — see Fix 4).
    - All edges of the tray exterior — top edges of the tray walls, vertical corner edges.
    - All break-edges where surfaces meet at angles other than the hero transitions.
    - Tray scoop leading edge: stays at r=2 (slightly tighter than utility because it has to stay sharp-ish to look intentional). Document this exception in spec.
  - **r=10 (hero) on:**
    - The four exterior corner vertical edges of the cradle perimeter walls (where ±X walls meet ±Y walls). Generous corner radius reads as a "soft footprint."
    - Base plate corners (top and bottom, all 4 corners). Bumped from v2's r=8 to consolidate.
    - Printer-section → shelf transition concave fillet on both ±X sides. Bumped from v2's r=8 to r=10.
  - **r=1.5 (function-driven exception) on:**
    - Foot-to-plate upper meeting edge. Foot bottom stays flat for FDM first-layer adhesion; the upper blend continues curvature.
  - **NO chamfers anywhere** — if the round-2 build still has any chamfered edges (e.g. the printer-section→shelf was a chamfer in v0/v1 before becoming a fillet in round 1; verify this didn't regress), they all become fillets.
- **Classification:** preference shift (consolidating the schedule for visual consistency).
- **Printability note:** all fillets are concave-or-equivalent at the print orientation. Self-supporting. No supports.
- **Affects spec?** yes — replace the `fillet_*` block with: `fillet_utility_r: 3`, `fillet_hero_r: 10`, `fillet_foot_to_plate_r: 1.5`, `fillet_scoop_lip_leading_edge_r: 2`. Delete: `fillet_cradle_vertical_edges_r` (now subsumed by hero r=10 at corners), `fillet_base_plate_corners_r` (replaced by hero r=10), `fillet_top_edges_r` (replaced by utility r=3), `fillet_tray_vertical_edges_r` (replaced by utility r=3 since it's already 3).

### Fix 4 — Cradle exterior corner radius: r=10 hero (was effectively r=4 cradle vertical edges)

- **Current state (round 2):** the ±X cradle walls meet the ±Y walls at corners with a small fillet effective r=4 from the v2 spec. With v3's 25mm uniform low walls, those exterior corners need to be more generous to read as "soft footprint."
- **Target state:** all four exterior vertical corner edges of the cradle (where ±X walls meet ±Y walls) have a r=10 fillet, full-height of the 25mm wall.
- **Specific direction:** apply r=10 fillet to the four cradle perimeter exterior corners. The fillet is along the vertical axis (z-direction). At the top edge of the wall, the r=10 vertical fillet meets the r=3 horizontal top edge fillet — at this triple corner, use a small spherical blend (r=3 sphere) to round both edges together rather than computing an exact 3-way fillet. (The visual difference between an exact fillet and a sphere-blend is negligible at this scale.)
- **Classification:** form-language consolidation.
- **Printability note:** generous vertical fillets are self-supporting. No issues.
- **Affects spec?** yes — `fillet_cradle_corner_vertical_r: 10`, deleting the v2 `fillet_cradle_vertical_edges_r: 4`.

### Fix 5 — Printer→shelf fillet: bump r=8 → r=10

- **Current state (round 2):** r=8 concave fillet sweep on ±X sides where 86mm printer section transitions to 108mm shelf section.
- **Target state:** r=10 (consolidates with the new hero radius tier).
- **Specific direction:** change `printer_section_to_shelf_concave_fillet_r` from 8 to 10. Verify the geometry sweep still fits in the 11mm y-delta of the transition zone — at r=10 the fillet may need slightly more y-extent than r=8; if so, extend the transition zone by ~3mm in y. If extending y conflicts with `cradle_total_d`, drop r back to 9 to fit.
- **Classification:** consolidation.
- **Printability note:** concave fillet, fully self-supporting.
- **Affects spec?** yes — `printer_section_to_shelf_concave_fillet_r: 8 → 10` (or 9 if 10 doesn't fit).

### Fix 6 — Base plate corners: bump r=8 → r=10

- **Current state (round 2):** r=8 corner fillet, top and bottom of base plate.
- **Target state:** r=10 (hero radius consolidation).
- **Specific direction:** `fillet_base_plate_corners_r: 8 → 10`. Apply on both top and bottom of the base plate at all 4 corners.
- **Classification:** consolidation.
- **Printability note:** simple. The bottom-of-plate fillet may slightly reduce first-layer surface area but the impact is minimal at r=10 over 108×255 footprint.
- **Affects spec?** yes — `fillet_base_plate_corners_r: 8 → 10` (also subsumed under the new `fillet_hero_r: 10`).

### Fix 7 — Tray: unchanged from round 2

- **Current state (round 2):** tray.scad has scoop lip + integrated finger-grip; all owl-face geometry already deleted in round 1; clean utility shape.
- **Target state:** identical. Do not modify `tray.scad` in v3.
- **Specific direction:** verify tray.scad has no leftover face/owl geometry. If clean, leave it alone. Tray spec params stay as-is (`tray_scoop_*`, `tray_*` interior/exterior dims, etc.).
- **Classification:** unchanged.
- **Printability note:** N/A.
- **Affects spec?** no.

### Fix 8 — Host_object_proxy + render_with_host: keep as-is

- **Current state (round 2):** module `host_object_proxy(show=false)` exists; `render_with_host` parameter gates inclusion in renders; STL export excludes it.
- **Target state:** keep both. Use-state renders are still required (the "is the cradle quiet enough alongside the printer?" check still needs the proxy).
- **Specific direction:** no change. The proxy module survives the v3 reduction.
- **Affects spec?** no.

### Fix 9 — Render set: simplified (7 → 7, but content shifts)

- **Current state (round 2):** 7 user-frame renders including 2 use-state in-use heroes.
- **Target state:** 7 renders, similar split. Use-state renders are still primary heroes — they confirm the cradle is "quiet" alongside the printer rather than competing.
- **Specific direction:** produce these renders:
  1. `cradle-user-front-in-use.png` — primary hero. Printer proxy ON.
  2. `cradle-user-front-threequarter-in-use.png` — marketing hero. Printer proxy ON.
  3. `cradle-user-front.png` — bare-part record.
  4. `cradle-user-front-threequarter.png` — bare-part record.
  5. `cradle-user-top-threequarter.png` — top-down view confirming full-perimeter symmetry. (Replaces the round-2 user-left view since the side profile of v3 is uninformative — just a rectangle.)
  6. `tray-user-front.png` — unchanged.
  7. `tray-user-front-threequarter.png` — unchanged.
- **Camera-preset note:** `cli-anything-openscad` presets remain unusable for this design (round-1 + round-2 lessons confirmed). Continue using direct `openscad` calls with explicit 6-tuple cameras. Filenames stay user-frame.
- **Affects spec?** yes — `views` list updated.

## Items unchanged from round 2 (do NOT re-litigate)

- **Two-part architecture** (cradle + tray).
- **Stepped body footprint:** 86mm printer section → 108mm shelf section. Only the transition radius bumps r=8 → r=10.
- **Printer pocket dimensions:** 80×154×145mm interior, 1mm XY clearance, 2mm Z clearance.
- **Tape-exit clearance geometry:** unchanged. Tape exits at z=64-79mm desk-ref, clears the 25mm front wall by 35-50mm.
- **Cable notch:** 25×20mm U-shape at z=0-20mm in the −Y wall. Position and dims unchanged.
- **Tray interior:** 100×91×40mm. Walls 1.6mm. Floor 1.6mm.
- **Tray exterior bounding box:** 103.2×94.2×21.6mm.
- **Tray-to-slot sliding fit:** 0.35mm per-side clearance.
- **Foot count/spacing/diameter:** 4 cylindrical feet, d=8, h=3, with upper r=1.5 fillet.
- **Tray scoop lip + integrated finger-grip:** unchanged. All `tray_scoop_*` params stay.
- **Host_object_proxy module:** kept (Fix 8).
- **Seam hiding:** underside of base plate; user-back (-Y) wall exterior.
- **Print orientation:** cradle base down, walls vertical; tray face up, back on bed.

## Leave alone (round 2 successes preserved)

- Tray architecture and scoop geometry.
- Stepped body footprint and shelf section.
- Foot construction.
- Host_object_proxy + render_with_host machinery.

## Uncertain — flag for round-4 critique (if needed)

- **r=10 cradle exterior corner fillet:** may read as "too generous" against a low 25mm wall. If the rounded corners look bulbous/cartoony, dial back to r=6.
- **r=10 hero everywhere:** the visual consistency of one hero radius applied to corners + base plate + printer→shelf transition might be too uniform. If the corners and the printer→shelf transition feel like the same move (when they're functionally different), differentiate by dropping cradle corners to r=6.
- **Bridge above cable notch (5mm wall bridging 25mm gap):** structurally fine but verify slicer doesn't add unnecessary supports under it. If it does, file a print-reviewer note.
- **Top edge fillet r=3 vs r=2:** r=3 might read as overly soft on a 25mm wall (radius is 12% of wall height). If it looks "rolled," drop to r=2.

## Summary for orchestrator

- **9 fixes**, of which 6 are pure deletion (Fix 1, 2) or trivial parameter bumps (Fix 5, 6). Fix 3 (fillet schedule) is the substantive consolidation. Fix 4 (cradle corner r=10) is the one new geometric move.
- **Scope:** large diff in cradle.scad (most of the panel + face + tuft code is deleted), large diff in spec.json (~25-30 params deleted), zero diff in tray.scad. Net cradle volume drop: from ~206 cm³ (round 2) to estimated ~80-100 cm³ (round 3) — substantial print-time + filament savings.
- **Supports:** none required. v3 has zero supports-permitted features.
- **Render priority:** use-state renders still primary. The "is the cradle quiet next to the printer?" question replaces the "is the face legible?" question.
- **Recommended next step:** `re-model + re-render + re-critique` once. If the v3 minimalism reads clean and the printer is the visual focus when installed, ship after standard review pipeline (geometry-analyzer, print-reviewer, fit-reviewer). If anything reads off (the corner radii, the bridge over the cable notch, the proportion of the tray-to-cradle base), one more critique round.

## Build-volume sanity check

- Cradle.x = 108mm. Bambu X1C max = 256mm. PASS.
- Cradle.y = 254.9mm. Max = 256mm. Cuts close (~1.1mm margin) — same as previous rounds. PASS.
- Cradle.z = ~28mm (was 221mm). PASS with huge margin.
- Tray dimensions unchanged. PASS.
