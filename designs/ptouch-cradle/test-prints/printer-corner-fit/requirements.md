# Printer-Corner-Fit Test Print

## Parent Design

`designs/ptouch-cradle/` (cradle.scad) — v3 round-7.

## Purpose

Verify that the cradle's printer-pocket geometry actually accommodates the Brother PT-P750W's corners before printing the full ~130 cm³ cradle. The fit-reviewer confirmed the math (1 mm/side XY clearance, 80 × 154 mm pocket interior vs 78 × 152 mm printer envelope), but FDM dimensional drift on the X1C could still throw it off — especially in the inside corners where two walls meet at 90° and the printer's corners have small radii/chamfers.

## Verification Method

Print the U. Place it on a flat surface — any wall outside-face down (the U is structurally rigid as printed). Slide the printer into the open end (+Y). The printer should bottom out against the closed back wall with both long edges tracking parallel to the side walls.

- **PASS:** uniform ~1 mm gap visible between the printer body and each side wall along the full 152 mm length; printer's back corners seat against the U's interior back-corners without binding.
- **FAIL — too tight:** printer binds, can't seat. Bump `printer_clearance_xy` from 1.0 mm to 1.2 mm in `designs/ptouch-cradle/spec.json` and re-render the cradle.
- **FAIL — too loose:** printer rattles freely. Tighten `printer_clearance_xy` from 1.0 mm to 0.8 mm.
- **FAIL — corner-binding:** printer's rounded corner jams against the U's sharp interior 90°. Add a small inside-corner relief (chamfer or fillet) in cradle.scad's printer-pocket subtraction.

## Geometry

U-shaped: three perpendicular walls reproducing the full pocket footprint at half cradle height.

- Closed back wall (at +Y end): 86 mm × 3 mm × 12.5 mm — spans full outer X.
- Two long side walls: 154 mm × 3 mm × 12.5 mm each — run the full pocket length along Y.
- Open at the front (−Y) so the printer slides in.
- No floor — U is rigid at 12.5 mm tall × 3 mm thick × 154 mm long; printer rests on the desk during the fit test.
- Three reference inside corners: two at the back (left + right) plus the full-length engagement along both side walls.

## Critical Dimensions

| Dim | Value | Source |
|---|---:|---|
| Wall thickness | 3.0 mm | `wall_thickness` in cradle spec |
| Wall height | 12.5 mm | half of cradle `low_wall_h` — pocket profile is constant over the printer's full Z, so a low U is sufficient |
| Pocket interior X | 80 mm | cradle `pocket_w` |
| Pocket interior Y | 154 mm | cradle `pocket_d` |
| Outer envelope | 86 × 157 × 12.5 mm | wall_t both sides + closed back |

## Parameters

Inherited from parent design via constants — no params to tune for this test piece.

## Constraints

- **No supports** — flat-on-bed walls, prints natively.
- **No infill needed** — solid 3 mm walls print as 7-perimeter strips, fast.
- **Print time:** ~15 minutes on standard 0.2 mm profile (half-height of full cradle wall, despite tripling the wall length, because layer count dominates print time on thin walls).
- **Volume:** ~14.8 cm³ (vs ~130 cm³ for the full cradle — ~11% material).
