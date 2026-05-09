# Fork Plate + Slot Bridge Sample Requirements

## Parent Design
workout-dumbbell-holder v3.4 — see `designs/workout-dumbbell-holder/requirements.md`

## Modeling Backend
**fusion** — model this in Fusion 360 via the direct TCP protocol used for the parent design. Load parent dimensions from `designs/workout-dumbbell-holder/spec.json` params block; do not hardcode values.

## Purpose
This test print answers two questions:

1. **Bell-rest surface quality:** The fork plate top face (Z=−22 in parent coords, the face the upper dumbbell bell rests on) is printed facing away from the bed in plug-vertical orientation — it receives support marks from the underside. Is the resulting surface flat enough that the bell rests stably without canting? Acceptable: light texture, marks < 0.3 mm. Unacceptable: ridges or lumps > 0.3 mm that would cause the bell to rock or cant the dumbbell.

2. **Slot dimensional accuracy:** Does the R=23 mm saddle arc and the 30°-flared tine arms print to spec? The slot must pass a 46 mm shaft in the Z direction, and the shaft must seat conformally in the arc. The slot opening at the plate +Y edge (nominal 69.1 mm) must be wide enough for easy lateral shaft insertion.

This test does NOT verify fitment — no mating part required. It gates the decision to adjust slicer support settings (interface layer count, offset, material) before committing to the full print.

## Print Orientation for This Test
**INVERTED from the full part:** print with the **fork plate bottom face (Z=−34 parent) toward the bed**, fork plate top face (Z=−22 parent) facing away from bed. This is the worst-case orientation for the bell-rest surface (it is fully supported from below) and directly tests the question. The bottom of the test piece in this orientation is the fork-plate bottom face + base plate (see geometry below).

This inverted orientation differs from the full part's orientation (flange face down). This is intentional — the test isolates the fork plate surface quality question in the orientation that challenges it most.

## Verification Method

### Step 1 — Bell-rest surface inspection (primary)
After printing and support removal, inspect the fork plate top face:
- Run a fingertip across the surface — feel for ridges, lumps, or nubs left by support interface
- Any feature > 0.3 mm that cannot be scraped off with a fingernail is a FAIL
- Take a raking-light photo of the surface

PASS: surface feels smooth or has only fine texture (< 0.3 mm); bell would rest flat.
FAIL: raised ridges or nubs > 0.3 mm that cannot be cleaned off.

### Step 2 — Slot opening measurement
Measure across the slot opening at the +Y plate edge (the wide end):
- Nominal: 69.1 mm
- Acceptable range: 68.0–70.5 mm

### Step 3 — Saddle arc check (qualitative)
Try to insert the actual dumbbell shaft (D=46 mm) into the slot from the +Y open edge, pushing in Z direction. The shaft should:
- Slide into the slot without binding at the arc entry
- Seat at the arc bottom with lateral play < 1 mm (conforming fit; 1 mm play is the full 1 mm clearance that was NOT designed in — if it seats with excessive slop, the arc radius may be printing oversize)
- Withdraw easily

### Step 4 — Buttress arc underside inspection
Inspect the top and bottom buttress arc undersides (the curved concave surfaces). Check for:
- Delamination or lifting at the curved surface
- Support removal scars > 0.5 mm — acceptable for non-mating surfaces but document for the full print expectations

## Geometry

### What to include
Extract a Y-slice of the fork plate + both buttresses from Y=+31.25 to Y=+65.

**Included features at full scale:**
- Fork plate: X=[−39.25, +39.25], Y=[+31.25, +65], Z=[−34, −22] (12 mm thick)
- Slot profile cut through fork plate: R=23 mm arc, tangent arms at ±30°, open at +Y edge. At Y=+65 cross-section, the arc is ~25 mm into the fork from the arc center (which is at Y=+90), so the slot walls at Y=+65 are the straight flared arms (not the arc itself). This is still the critical geometry: tine wall thickness, arm width, and the straight-arm printability are all captured. The arc portion visible at this Y range is at Y=+67 to Y=+90 (arc extends from centerline Y=+90 ± R=23, so arc top is at Y=+90−23=+67). A slice to Y=+65 just misses the arc but captures the tangent arm geometry fully.
  - **Revise Y cutoff to Y=+70 to capture the arc entry.** This adds only 5 mm of depth and ensures the R=23 arc tangent point (at Y=+67) is within the test piece.
- Top buttress arc: this runs from (Y=+31.25, Z=0) tangent to (Y=+53.25, Z=−22). The portion at Y=[+31.25, +53.25] is fully within the Y=+70 cutoff.
- Bottom buttress arc: this runs from (Y=+31.25, Z=−56) tangent to (Y=+53.25, Z=−34). The portion at Y=[+31.25, +53.25] is fully within the Y=+70 cutoff.
- Ribs: may be included or excluded at modeler's discretion — they run from Y=+31.25 to Y=+105 and are within the cutoff, but they are thin fins (3 mm × 12 mm deep) that add minor material. Include them if it simplifies the boolean operations (they're inside the Y cutoff anyway).

**Do NOT include:**
- Plug, flange, or sleeve geometry
- Any material at Y < +31.25
- Any material at Y > +70
- Tine tips (at Y=+110)
- The outer flat plate region beyond Y=+70

### Base plate
The bottom of the test piece in print orientation is the fork plate bottom face (Z=−34 in parent coords). The bottom buttress arc runs below this (down to Z=−56 at Y=+31.25). In inverted print orientation (fork plate bottom toward bed), the piece needs a flat base. The bottom buttress arc lowest point is at Z=−56 (in parent coords), and its footprint at Y=+31.25 is a single point. Add a **3 mm flat base plate** below the lowest geometry (below Z=−56 parent), extending across the full X span ([−39.25, +39.25]) and Y span ([+31.25, +70]). This gives a flat print surface.

### Cut face at Y=+70
The +Y face of the test piece (at Y=+70) is a flat cross-section cut. This will be an open cross-section showing the slot profile. The slot at Y=+70 is just beyond the arc entry — the slot walls are the straight arms at 30° divergence. The tine wall cross-section at this face: X outer edge at ±39.25, slot tangent arm at ±(Y−90)·tan30° at Y=+70 ≈ ±(−20·tan30°) ≈ ±11.5 (approximately, near the tangent point). This face will show the slot geometry clearly.

## Critical Dimensions

| Dimension | Nominal | Tolerance | How to verify |
|---|---|---|---|
| Slot opening at +Y plate edge | 69.1 mm | ±1.5 mm | Calipers |
| Fork plate thickness (Z) | 12.0 mm | ±0.5 mm | Calipers through plate |
| Fork plate top face flatness | 0.0 mm deviation | ≤ 0.3 mm | Fingertip, raking light photo |
| Tine wall thickness at Y=+70 cross-section | ~4.7 mm | ±0.5 mm | Calipers |
| Buttress arc radius | 22.0 mm | ±1.0 mm | Visual / template gauge |
| Total X span | 78.5 mm | ±1.0 mm | Calipers |

## Parameters
Load from parent `designs/workout-dumbbell-holder/spec.json` → `params` block. Key values:
- `fork_plate_x`: 88.5 (but trimmed symmetrically to [−39.25, +39.25] = 78.5 mm effective width per v3.4)
- `fork_thickness_z`: 12
- `fork_offset_below_top`: 20 (→ fork Z = [−34, −22] with origin at Z=0 flange top)
- `saddle_radius`: 23
- `fork_spread_angle_per_arm`: 30
- `fork_top_buttress_radius`: 22, `fork_bottom_buttress_radius`: 22
- `min_wall_cf`: 3.0
- Test-print-specific: y_cutoff = 70, base_plate_thickness = 3

## Constraints
- Minimum material: Y truncated at +70 (not +110)
- Print inverted (fork plate bottom toward bed) — this is the test condition
- Must sit flat on bed — add 3 mm base plate below lowest buttress geometry
- No plug, no sleeve, no flange
- Keep full X span and full Z range of the fork plate region
- Watertight: yes (the Y=+70 cut face closes the geometry)
