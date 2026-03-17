# Display Body Cavity Fit Requirements

## Parent Design
caliper-test — [../../../requirements.md](../../../requirements.md)

## Purpose
Verify that the 72×20mm display body cavity accepts the HARTE 6-inch digital caliper display body with the intended 2mm clearance per side. Caliper dimensions were measured from grid photos with ±2mm uncertainty. This is the highest-priority test: if the cavity fit is wrong, the full 88mm bin is wrong and needs a dimension change before committing material and print time.

## Verification Method
Insert the caliper display body into the cavity from above.

- The display body should slide in smoothly with visible gap on all four sides.
- Expect approximately 2mm gap per side in both X and Y. If it binds, the caliper is larger than measured; if it drops in with more than ~4mm total play per axis, the caliper is smaller and the pocket will need adjustment.
- Measure cavity opening with calipers: target 72.0 ± 0.2mm in X, 20.0 ± 0.2mm in Y.

## Geometry

Extract a 20mm-tall cross-section of the bin starting at the internal floor (z=7.2mm in the parent). This slice captures the full display body cavity cross-section in a minimal piece.

**What to include:**
- Full bin wall section at 83.5mm in X — keeps the cavity walls representative (4.55mm wall on each X side of the cavity)
- Trimmed to 25mm in Y — shows the full 20mm cavity depth with 1.2mm wall on each Y face plus ~1.4mm extra; discards the large empty volume behind the pocket
- 2mm flat base plate at the bottom (replaces the Gridfinity base grid and floor slab)
- Cavity cross-section (72mm X × 20mm Y) centered in X, starting immediately above the base plate, 20mm tall

**What to omit:**
- Gridfinity base profile (z=0 to 7.2mm) — not relevant to cavity fit
- Any bin geometry above z=27.2mm — not relevant to this test
- Bottom corner fillet at bin floor — low priority for fitment; omit for simplicity, or include at modeler's discretion

**Orientation:** Print flat on the base plate face. No supports needed — the cavity is a vertical slot open at the top.

## Critical Dimensions

| Dimension | Nominal | Tolerance | How to verify |
|---|---|---|---|
| Cavity width (X) | 72.0 mm | ± 0.2 mm | Calipers across cavity opening |
| Cavity depth (Y) | 20.0 mm | ± 0.2 mm | Calipers across cavity opening |
| Cavity height (Z) | 20.0 mm | ± 0.2 mm | Calipers — ensures full cross-section is captured |
| Wall thickness X sides | 4.55 mm | ± 0.5 mm | Calipers on wall face |
| Wall thickness Y sides | 1.2 mm | ± 0.3 mm | Calipers on wall face |

## Parameters

No separate params file — the parent design has all parameters inline in `caliper-test.scad`. Reference the parent's parameter values directly:

- `display_cavity_x = display_body_width + 2 * caliper_clearance` = 72mm
- `display_cavity_y = display_body_thickness + 2 * caliper_clearance` = 20mm
- `wall = GF_WALL_THICKNESS_THICK` = 1.2mm
- `outer_x` = 83.5mm

The modeler should reference these expressions (or their computed values from the parent) so that if caliper dimensions are corrected after the test, the bin and test piece stay in sync.

## Constraints

- Minimize material — this is a test piece, not the final part
- Must print flat on bed without supports
- Keep cavity dimensions at full scale — do not shrink
- Piece should fit easily on the build plate; estimated footprint 83.5 × 25mm, well within 256×256mm
- Estimated print time: under 15 minutes
