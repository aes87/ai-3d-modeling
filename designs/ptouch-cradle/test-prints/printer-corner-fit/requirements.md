# Printer-Corner-Fit Test Print

## Parent Design

`designs/ptouch-cradle/` (cradle.scad) — v3 round-7.

## Purpose

Verify that the cradle's printer-pocket geometry actually accommodates the Brother PT-P750W's corners and matches the pocket interior dimensions before printing the full ~130 cm³ cradle. The fit-reviewer confirmed the math (1 mm/side XY clearance, 80 × 154 mm pocket interior vs 78 × 152 mm printer envelope), but FDM dimensional drift on the X1C could still throw it off — and the printer's corner radii/chamfers (not modeled in the proxy box) need to clear the cradle's sharp 90° interior corners.

## Verification Method

Print the piece. Place it on a flat surface — any wall outside-face down. Slide the printer into the pocket from the +Y direction (the back wall is at the closed end). The printer should:

- Bottom out flush against the back wall along its full 78 mm width.
- Reveal a uniform ~1 mm gap between the printer body and the right wall along the full 152 mm engagement.
- Reveal a uniform ~1 mm gap to the left stub at the back of the pocket and to the front stub at the right edge of the front.
- Seat without binding in any of the 3 inside corners (back-left, back-right, front-right).

PASS criteria — all of the above with consistent slight resistance, no rattle, no bind.

- **FAIL — too tight:** printer binds, can't seat. Bump `printer_clearance_xy` from 1.0 mm to 1.2 mm in `designs/ptouch-cradle/spec.json` and re-render the cradle.
- **FAIL — too loose:** printer rattles. Tighten `printer_clearance_xy` from 1.0 mm to 0.8 mm.
- **FAIL — corner-binding:** printer's rounded corner jams against a sharp interior 90°. Add a small inside-corner relief (chamfer or fillet) in cradle.scad's printer-pocket subtraction.

## Geometry

A "two full sides + two stubs" frame with one corner intentionally absent.

- **Full back wall** (short side, +Y end): 86 mm × 3 mm × 12.5 mm — spans full outer X.
- **Full right long wall** (+X side): 3 mm × 157 mm × 12.5 mm — runs the full pocket length plus the back-wall thickness so it joins the back wall at the back-right corner.
- **Left stub** on the long wall: 3 mm × 25 mm × 12.5 mm — meets the back wall to form the back-left inside corner.
- **Front stub** on the short wall: 25 mm × 3 mm × 12.5 mm — meets the right wall to form the front-right inside corner.
- **Front-left corner is open** — the printer's front-left edge sits in air during the fit test. The other three corners share identical geometry, so the fourth is covered by transitive verification.
- No floor — the piece is structurally rigid as printed; the printer rests on the desk during the fit test.

## Critical Dimensions

| Dim | Value | Source |
|---|---:|---|
| Wall thickness | 3.0 mm | `wall_thickness` in cradle spec |
| Wall height | 12.5 mm | half of cradle `low_wall_h` (25) — pocket profile is constant over the printer's full Z, so a low piece is sufficient |
| Pocket interior X | 80 mm | cradle `pocket_w` |
| Pocket interior Y | 154 mm | cradle `pocket_d` |
| Stub length | 25 mm | enough to clearly form an inside corner past any printer corner radius |
| Outer envelope | 86 × 157 × 12.5 mm | wall_t both sides + closed back + full-length right wall |

## Parameters

Inherited from parent design via constants — no params to tune for this test piece.

## Constraints

- **No supports** — flat-on-bed walls, prints natively.
- **No infill needed** — solid 3 mm walls print as 7-perimeter strips, fast.
- **Print time:** ~12–15 minutes on standard 0.2 mm profile (half-height of full cradle wall, plus less perimeter than the closed-U variant).
- **Volume:** ~10.9 cm³ (vs ~130 cm³ for the full cradle — ~8% material).
