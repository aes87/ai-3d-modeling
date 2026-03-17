# Ledge Transition, Beam Slot, and Finger Relief Requirements

## Parent Design
caliper-test — [../../../requirements.md](../../../requirements.md)

## Purpose
Three verification questions answered by one piece:

1. **Beam slot fit:** Does the 20×9mm beam slot accept the caliper beam (16×5mm nominal) with the intended 2mm clearance per side?
2. **Ledge height / pocket depth:** Is the 65mm display cavity deep enough? With the caliper inserted into a reference cavity (or simulated by gauge block), does the display body upper rim land at the transition ledge (z=72.2mm)? If the actual display body is longer than 63mm, it will protrude above the ledge and the caliper won't seat.
3. **Finger relief chamfer quality:** Does the 45° chamfer on the pocket opening print cleanly without drooping, stringing, or layer separation? The chamfer is exactly at the 45° FDM printability limit.

All three questions are answered by a single 21.8mm-tall cross-section of the bin from z=62.2 to z=84.0 — the zone that contains the bottom of the chamfer, the transition ledge, and the full beam slot.

## Verification Method

**Chamfer quality (visual):** Inspect the four chamfer faces on the pocket opening. They should show clean layer lines without drooping material. If there is sagging on the inner face, either the slicer needs cooling adjustments or the chamfer angle should be reduced to 40°.

**Beam slot fit:** Insert the caliper beam (or a 16×5mm rectangular gauge/shim) into the slot from above. It should pass through with visible clearance on all four sides. Measure with calipers: target 20.0 ± 0.2mm (X) and 9.0 ± 0.2mm (Y).

**Ledge height:** Insert the caliper display body into the cavity section (using the cavity-fit test piece placed below, or by measuring directly). The display body upper rim should sit at or slightly below the ledge face. If it protrudes more than ~2mm above the ledge, the display body is longer than 63mm and the pocket depth must increase.

## Geometry

Extract a 21.8mm-tall cross-section from the parent bin at z=62.2 to z=84.0.

**What to include:**
- Full bin width at 83.5mm X — captures both X-side ledges (26mm per side) and full chamfer geometry
- Trimmed to 25mm in Y — shows the 9mm beam slot + Y-side ledge (5.5mm per side) + 1.2mm wall each side + ~1.3mm margin
- 3mm flat base plate at the bottom (represents the solid bin wall below the chamfer zone; provides a stable print base)
- The complete finger relief chamfer from z=62.2 to z=72.2 (the 45° widening from 72×20mm to 81.1×39.1mm — capped to inner dimensions)
- The beam slot from z=72.2 to z=84.0: 20mm X × 9mm Y, offset +5.5mm in Y from center (matching parent beam centering)
- The transition ledge horizontal surface at z=72.2mm (the step where the cavity narrows from 72×20mm to 20×9mm)

**What to omit:**
- Everything below z=62.2mm (base grid, floor, lower display cavity)
- Stacking lip — not relevant to this test

**Y trimming note:** The 25mm Y extent exposes the beam slot and one Y-side ledge cleanly as a cross-section face. The beam slot offset (+5.5mm in Y toward the far Y side) means the slot sits at Y-center + 5.5mm; within a 25mm piece centered on the bin Y-center, this is fully contained.

**Orientation:** Print flat on the 3mm base plate face. No supports needed. The chamfer faces are interior angled surfaces open to the top — they print as self-supporting 45° overhangs.

## Critical Dimensions

| Dimension | Nominal | Tolerance | How to verify |
|---|---|---|---|
| Beam slot width (X) | 20.0 mm | ± 0.2 mm | Calipers across slot |
| Beam slot depth (Y) | 9.0 mm | ± 0.2 mm | Calipers across slot |
| Beam slot Y offset from center | 5.5 mm | ± 0.3 mm | Calipers from piece Y-center to slot near wall |
| Ledge elevation from base plate | 13.0 mm | ± 0.3 mm | Calipers from base plate bottom to ledge face (3mm base + 10mm below ledge) — confirms ledge at correct height |
| Chamfer angle | 45° | ± 2° | Visual / angle gauge — primarily a print quality check |

## Parameters

No separate params file — reference parent `caliper-test.scad` parameter values:

- `display_cavity_x` = 72.0mm, `display_cavity_y` = 20.0mm
- `beam_slot_x` = 20.0mm, `beam_slot_y` = 9.0mm
- `beam_slot_y_offset` = 5.5mm (offset from bin Y-center toward +Y)
- `finger_relief_height` = 10.0mm, `finger_relief_setback` = 10.0mm
- `relief_x` = 81.1mm (capped to inner_x), `relief_y` = 39.1mm (capped to inner_y)
- `outer_x` = 83.5mm, `wall` = 1.2mm
- Ledge at z=72.2mm (= `floor_z` + `display_cavity_z` = 7.2 + 65.0)

The modeler should build the pocket geometry using the same `finger_relief()` and beam-slot logic as the parent, applied to the extracted z-range only.

## Constraints

- Minimize material — this is a test piece, not the final part
- Must print flat on bed without supports
- Keep all pocket dimensions at full scale
- Estimated footprint: 83.5 × 25mm, well within 256×256mm build plate
- Estimated print time: under 20 minutes
