# Tray-Slot Fit-Pair Requirements

## Parent Design
ptouch-cradle (round 7 / commit 31a2e27) — see `designs/ptouch-cradle/requirements.md`

## Purpose
Verify that the tray exterior slides smoothly into the cradle slot before committing
to the full ~150 cm³ two-part print (~4+ hours).

The tray exterior is 103.2 mm W × 94.2 mm D × 30 mm H. The cradle slot interior is
103.9 mm W × 94.9 mm D × 22.3 mm deep. This is a 0.35 mm per-side sliding fit in X
and Y. On a Bambu X1C printing PLA, a 103 mm part can accumulate ±0.2–0.3 mm of
dimensional error — close enough to the 0.35 mm clearance that a mis-scaled print
could bind or rattle.

## Verification Method
1. Print both pieces in one bed run (no supports, PLA, standard profile).
2. Hold the mini cradle slot on a flat surface. Insert the mini tray section from the
   front (open Y face) with the flat bottom of the slug facing down.
3. Slide the slug in and out several times. Assess:
   - **PASS — smooth fit:** slides in and out with slight consistent resistance, no binding,
     no rattle. Proceed to full print.
   - **Loose / rattles:** printer or slicer is scaling slightly wide. Enable XY compensation
     in Bambu Studio (Process → Advanced → XY hole/contour compensation) and re-test.
   - **Binds / can't insert:** printer or slicer is scaling slightly narrow. Same
     compensation, opposite direction.
4. After insertion, check that the top of the slug stands above the mini cradle slot
   walls (slug is 30 mm tall, slot walls are 25 mm tall — 5 mm protrusion expected).

## Geometry

### Piece A — Mini Cradle Slot (U-channel)
Extract the tray slot section of the cradle only:
- Two side walls: 3.05 mm thick × 25 mm tall, spanning 110.0 mm outer width
- Back wall: 3 mm thick (closes the U; represents the front-of-printer-section wall)
- Base plate: 4 mm thick (full outer width, same as cradle base_thickness)
- Y depth: 25 mm interior + 3 mm back wall = 28 mm overall
- Open at the front (+Y face) — tray inserts here
- Open at the top (z = 25 mm) — same as the real cradle's open-top slot

Print orientation: base-down (z=0 on bed, same as the real cradle).

### Piece B — Mini Tray Section (solid slug)
Exterior bounding box of the tray, 25 mm deep, no interior:
- Exterior: 103.2 mm W × 30 mm H
- Y depth: 25 mm (enough to fully engage the slot's 22.3 mm depth)
- r=3 vertical edge fillets on all four corners (matches real tray)
- Solid throughout — no interior cavity, no ramp, no front lip feature

Print orientation: face-up / flat on bed (z=0 at bottom, same as the real tray).

### Bed Layout
Place both pieces on the same bed plate with a 10 mm gap between them in X.
Combined footprint ≈ 223 × 28 mm — well within the 256 × 256 mm build volume.

## Critical Dimensions
| Dimension | Nominal | Tolerance | How to verify |
|---|---|---|---|
| Slot interior width | 103.9 mm | ±0.2 mm | Calipers across slot interior |
| Slot interior height (engagement) | 22.3 mm | ±0.2 mm | Calipers inside slot |
| Tray section exterior width | 103.2 mm | ±0.2 mm | Calipers across slug |
| Tray section exterior height | 30.0 mm | ±0.2 mm | Calipers on slug height |
| Per-side clearance (fit) | 0.35 mm | — | Trial fit (sliding feel) |

## Parameters
All dimensions are hardcoded in `tray-slot-fit-pair.scad` from the parent spec.json.
No shared params file exists for ptouch-cradle — parent SCAD files use inline
parameters. Key values:
- `slot_w = 103.9`, `slot_h = 22.3`, `cradle_wall_t = 3.05`
- `tray_ext_w = 103.2`, `tray_ext_h = 30.0`
- `test_y_depth = 25.0`

## Constraints
- Minimize material — this is a test piece. Combined estimated volume < 30 cm³.
- Both pieces must print without supports.
- Keep critical dimensions at full scale — do not scale down either piece.
- Piece B (tray slug) is solid — intentionally omits interior cavity, ramp, and front
  lip. The test answers only the sliding fit question.
