# Buttress Arc Overhang Sample Requirements

## Parent Design
workout-dumbbell-holder v3.4 — see `designs/workout-dumbbell-holder/requirements.md`

## Modeling Backend
**fusion** — model in Fusion 360 via the direct TCP protocol. Load parent dimensions from `designs/workout-dumbbell-holder/spec.json` params block.

## Priority Note
**LOW — drop this test print if the fork-plate-sample is printed.**

The fork-plate-sample (MEDIUM priority) includes both top and bottom buttress arc undersides at full X span. If that test print is executed, this buttress-arc-sample is redundant. Print this standalone test only if:
- The fork-plate-sample is deferred or skipped, AND
- There is a specific concern about buttress arc delamination or support removal quality as an isolated question

## Purpose
Isolate and validate the printability of the r=22 mm quarter-cylinder buttress arc underside in plug-vertical print orientation. Both the top and bottom buttress arcs face downward (toward the bed) in this orientation at angles ranging from 47° to 90° — all above the 45° unsupported limit and requiring support material.

The buttress arc surfaces are not mating surfaces. They do not contact the rail, the bell, or any other functional part. The test is purely cosmetic and printability: does the slicer's support removal leave the surface in a structurally sound state (no delamination), and is the surface texture acceptable to the user's expectations?

## Verification Method

Visual inspection only — no calipers required.

After printing and support removal:
1. Look at the arc underside (concave face) in good light
2. Check for delamination: any layer lifting or separation at the curved surface is a FAIL
3. Check support removal texture: light scarring acceptable, deep ridges > 0.5 mm should be noted and the slicer support settings adjusted before the full print
4. Check arc profile: the curved surface should be visibly smooth and continuous — no flat faceting visible to the naked eye (the STL has sufficient triangle density)

PASS: arc underside is continuous, no delamination, surface texture is minor.
FAIL: delamination visible, or support scarring > 0.5 mm that would indicate a slicer settings problem.

## Geometry

A 20 mm wide X-slice of the top buttress arc, capturing the arc at X=[−10, +10] (centered on X=0).

**Include:**
- Sleeve +Y face stub: the vertical backing surface of the sleeve at Y=+31.25, Z=[−8, 0], X=[−10, +10], 5 mm wide in Y (from Y=+26.5 to +31.25) — this is the "wall" the buttress connects to at its top tangent
- Fork plate top stub: horizontal face at Z=−22, Y=[+31.25, +53.25], X=[−10, +10] — this is the "floor" the buttress rests on at its bottom tangent
- Top buttress arc: the r=22 quarter-cylinder, center at (Y=+53.25, Z=0), from (Y=+31.25, Z=0) to (Y=+53.25, Z=−22), X=[−10, +10]
- 3 mm flat base plate below the fork plate stub face at Z=−22 (extending down to Z=−25) to allow the piece to sit flat on the bed in plug-vertical orientation (flange face down = Z=0 on bed, piece is a small wedge with the arc facing upward and away from bed)

**Do NOT include:**
- Bottom buttress
- Plug, flange, sleeve
- Ribs
- Fork plate full extent (just the 22 mm Y stub at Z=−22)

**Approximate dimensions of resulting piece:**
- X: 20 mm
- Y: ~22 mm (from Y=+31.25 to +53.25)
- Z: ~25 mm (from base plate bottom at Z=−25 to sleeve stub top at Z=0)

This produces a small wedge ~5 cm³ total volume.

## Critical Dimensions

| Dimension | Nominal | Tolerance | How to verify |
|---|---|---|---|
| Buttress arc radius | 22.0 mm | ±1.0 mm | Visual / template |
| Piece X width | 20.0 mm | ±1.0 mm | Calipers |
| Arc surface delamination | 0 | ZERO tolerance | Visual |

## Parameters
Load from parent `designs/workout-dumbbell-holder/spec.json`. Key values:
- `fork_top_buttress_radius`: 22
- `fork_top_buttress_center`: (Y=+53.25, Z=0)
- Test-print-specific: x_slice_range = [−10, +10], base_plate_thickness = 3

## Constraints
- Minimum material — 20 mm X slice only
- Print in plug-vertical orientation (Z=0 face on bed, same as full part)
- Base plate required for flat bed contact
- No mating geometry needed
- Watertight after adding base plate
- Drop entirely if fork-plate-sample is printed
