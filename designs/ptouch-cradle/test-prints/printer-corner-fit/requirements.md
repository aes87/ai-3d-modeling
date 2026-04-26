# Printer-Corner-Fit Test Print

## Parent Design

`designs/ptouch-cradle/` (cradle.scad) — v3 round-7.

## Purpose

Verify that the cradle's printer-pocket geometry actually accommodates the Brother PT-P750W's corner before printing the full ~130 cm³ cradle. The fit-reviewer confirmed the math (1mm/side XY clearance, 80×154mm pocket interior vs 78×152mm printer envelope), but FDM dimensional drift on the X1C could still throw it off — especially in the inside corner where two walls meet at 90° and the printer's corner has a small radius/chamfer.

## Verification Method

Print the L. Place it on a flat surface, outside-of-corner down. Set the printer's corner against the inside-angle of the L. Push the printer in toward the corner.

- **PASS:** printer slides along either axis with consistent slight resistance, ~1mm gap visible between printer body and each L wall, printer's corner seats against the inside-angle without binding.
- **FAIL — too tight:** printer binds, can't seat in the corner. Bump `printer_clearance_xy` from 1.0mm to 1.2mm in `designs/ptouch-cradle/spec.json` and re-render the cradle.
- **FAIL — too loose:** printer rattles freely. Tighten `printer_clearance_xy` from 1.0mm to 0.8mm.
- **FAIL — corner-binding:** printer's rounded corner jams against the L's sharp interior 90°. Add a small inside-corner relief (chamfer or fillet) in the cradle.scad's printer-pocket subtraction.

## Geometry

L-shaped, two perpendicular walls forming ONE inside corner of the printer pocket.

- Long leg: along Y (printer's long-axis side), 100mm long × 3mm thick × 25mm tall
- Short leg: along X (printer's short-axis side), 80mm long × 3mm thick × 25mm tall
- No floor — the L is structurally stable as printed; printer rests on a flat surface (the desk or bed) during the fit test
- 3 reference points: the two open ends of the L + the inside angle

## Critical Dimensions

| Dim | Value | Source |
|---|---:|---|
| Wall thickness | 3.0mm | `wall_thickness` in cradle spec |
| Wall height | 25.0mm | `low_wall_h` in cradle spec — full cradle height |
| Long leg | 100mm | ~2/3 of printer's 152mm long axis |
| Short leg | 80mm | covers full 78mm printer short axis + slack |

## Parameters

Inherited from parent design via constants — no params to tune for this test piece.

## Constraints

- **No supports** — flat-on-bed L, prints natively.
- **No infill needed** — solid 3mm walls print as 7-perimeter strips, fast.
- **Print time:** ~15-20 minutes on standard 0.2mm profile.
- **Volume:** ~13 cm³ (vs ~130 cm³ for the full cradle — ~10% material).
