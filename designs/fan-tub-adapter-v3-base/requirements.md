# Fan-Tub Adapter v3 Base Plate — Requirements

## Design Intent

Revision of the v2.0 base plate for the fan-tub adapter system. The base plate is permanently caulked to the tub lid. The fan drops into the locating rim. V3 changes: ledge count reduced from 4 to 2 (only +X and -X sides, matching the 2-snap v3 cap); guide channels added flanking each ledge to capture and guide the cap arms during installation. Everything else is identical to v2.

The guide channels are U-shaped slots (two parallel vertical walls flanking each ledge). When the user presses the cap down over the fan, the arms find the channels automatically — XY alignment is established before the hook engages the ledge.

## Print Orientation

Bottom face on the bed. Channel walls and rim grow upward from the plate. No supports needed: channel walls are vertical ribs, ledge chamfers are 45° self-supporting, all overhangs are within 45°.

This is the same orientation as v2. The taller bbox_z (15mm vs 9mm) reflects the channel walls, not a print orientation change.

## Dimensions & Sources

| Dimension | Value | Source |
|---|---|---|
| Overall bbox X | 196.2 mm | v2 measured / params: 2×(branch_root + branch_len) = 2×(73.1+25) |
| Overall bbox Y | 196.2 mm | v2 measured / params: same as X (symmetric) |
| Overall bbox Z | 15.0 mm | channel wall top = z=15 (new tallest feature; v2 was z=9) |
| Inner plate thickness | 5.0 mm | v2 params: frame_t_inner |
| Outer plate thickness | 4.6 mm | v2 params: frame_t_outer = waffle_h |
| Center opening diameter | 115 mm | v2 params: fan_opening (matches fan inner circle) |
| Locating rim inner | 120 mm | v2 params: loc_inner = fan_frame + 2×loc_clearance = 119 + 2×0.5 |
| Locating rim outer | 124 mm | v2 params: loc_outer = loc_inner + 2×loc_rim_wall = 120 + 2×2 |
| Locating rim height | 4.0 mm | v2 params: loc_rim_h (z=5 to z=9) |
| Locating rim wall thickness | 2.0 mm | v2 params: loc_rim_wall |
| Fan frame clearance (per side) | 0.5 mm | v2 params: loc_clearance (clearance fit) |
| Fan frame size | 119 mm | v2 measured: fan_frame |
| Fan frame corner radius | 5.0 mm | v2 measured: fan_corner_r |
| Ledge count | 2 | Proposal: only +X and -X sides (matches 2 snap arms) |
| Ledge outward protrusion | 3.0 mm | v2 params: clip_ledge_depth (unchanged) |
| Ledge chamfer height | 3.0 mm | v2 params: = clip_ledge_depth, 45° ramp, self-supporting |
| Ledge flat engagement height | 2.0 mm | v2 params: clip_ledge_flat (hook catches here, z=7–9) |
| Ledge total height | 5.0 mm | v2 params: clip_ledge_h = 3+2 (z=4–9) |
| Ledge width | 8.0 mm | v2 params: clip_arm_w (arm width) |
| Ledge bottom Z | 4.0 mm | v2 derived: z_flat_bot - clip_ledge_depth = 7.0 - 3.0 |
| Ledge flat top Z | 9.0 mm | v2 derived: z_rim_top = frame_t_inner + loc_rim_h = 5+4 |
| Ledge flat bottom Z | 7.0 mm | v2 derived: z_flat_bot = z_rim_top - clip_ledge_flat = 9-2 |
| Channel inner width | 8.7 mm | Proposal: clip_arm_w + 2×sliding_fit = 8.0 + 2×0.35 (sliding fit) |
| Channel wall thickness | 2.0 mm | Proposal |
| Channel outer width | 12.7 mm | Derived: 8.7 + 2×2.0 |
| Channel wall height | 10.0 mm | Proposal: z=5 to z=15 (10mm above inner plate top) |
| Channel wall bottom Z | 5.0 mm | Proposal: = z_inner_top (starts at inner plate top) |
| Channel wall top Z | 15.0 mm | Proposal: 5 + 10 = 15 (6mm of guided travel before hook hits ledge at z=9) |
| Channel radial depth | ~5.0 mm | Proposal: extends from rim outer face to past ledge outer face |
| Waffle square size | 63.7 mm | v2 params: square_size |
| Channel width (waffle) | 9.4 mm | v2 params: channel_w |
| Waffle height | 4.6 mm | v2 params: waffle_h |
| Branch width | 9.0 mm | v2 params: branch_w |
| Branch length | 25.0 mm | v2 params: branch_len |
| Branch root offset | 73.1 mm | v2 params: branch_root = cutout/2 + channel_w/2 |
| Flange width | 4.7 mm | v2 params: flange_w = channel_w/2 |
| Corner radius (waffle) | 4.0 mm | v2 params: corner_r |

## Features

### Inner Plate
- **Purpose**: Fan mount zone; fan frame bottom sits here at z=5.0
- **Critical dimensions**: 5.0mm thick, square rounded to fan_corner_r + loc_rim_wall = 9mm radius
- **Mating interfaces**: Fan frame bottom rests on top face (z=5.0); no clamping, gravity + rim constraint

### Outer Plate
- **Purpose**: Flange and branch zone; flush with waffle grid square tops
- **Critical dimensions**: 4.6mm thick, 196.2mm square, 4mm corner radius
- **Mating interfaces**: Bottom face caulked to tub lid; top flush with waffle square tops

### Center Opening
- **Purpose**: Airflow passage; matches fan inner opening
- **Critical dimensions**: 115mm diameter, through full plate thickness
- **Mating interfaces**: No mating; open passage

### Locating Rim
- **Purpose**: Constrains fan XY position; taller than v1 to provide positive lateral grip
- **Critical dimensions**: 120mm inner (fan enters here), 124mm outer, 4.0mm tall (z=5 to z=9), 2.0mm wall
- **Mating interfaces**: Fan frame outer face (119mm square) slides inside rim (120mm inner). Clearance per side = 0.5mm (clearance fit). Fan cannot rock laterally with this constraint.
  - Fan outer: 119mm. Rim inner: 120mm. Gap per side: 0.5mm. ✓

### Y-Branches (×8, four corners, two arms each)
- **Purpose**: Engage waffle grid channels for XY lock and caulk distribution
- **Critical dimensions**: 9.0mm wide × 25mm long per arm, fork center at 73.1mm from center
- **Mating interfaces**: Waffle channel width 9.4mm; branch width 9.0mm; gap 0.2mm per side (clearance fit)

### Clip Ledges (×2, +X and -X only)
- **Purpose**: Hook engagement points for cap snap arms; provide Z retention
- **Critical dimensions**:
  - Outward protrusion: 3.0mm (from rim outer face at x=62mm, to x=65mm)
  - Total height: 5.0mm (z=4.0 to z=9.0)
  - Chamfer zone: z=4.0 to z=7.0 (45° ramp, self-supporting)
  - Flat engagement zone: z=7.0 to z=9.0 (hook catches under this face)
  - Width: 8.0mm (centered on each face)
- **Mating interfaces**: Cap hook overhang 1.25mm. Hook bottom sits at z=5.0; hook inner face at x_arm_inner - 1.25mm from center. Ledge outer face at x=65mm from center.
  - Hook engagement: hook inner face must clear ledge outer face during snap. Hook overhang = 1.25mm (hook inner face at 65.0 - 1.25 = 63.75mm from center). ✓
- **Note**: V2 had 4 ledges (all cardinal sides); v3 has 2 (only ±X). This matches the 2-arm cap.

### Guide Channels (×2, at each ledge position, ±X sides)
- **Purpose**: Guide cap arms into engagement. U-shaped slot flanking each ledge; arm slides in from above, constrained in Y. Arm finds ledge automatically — no visual alignment needed.
- **Critical dimensions**:
  - Inner clear width: 8.7mm (arm width 8.0mm + 2×0.35mm sliding fit)
  - Wall thickness: 2.0mm each side
  - Outer width: 12.7mm
  - Height: 10.0mm (z=5.0 to z=15.0)
  - Radial depth: ~5.0mm from rim outer face, sufficient to enclose ledge depth (3.0mm) with 1mm margin per side, plus ledge protrudes from rim face
- **Mating interfaces**: Cap arm width 8.0mm, channel inner 8.7mm. Gap per side = 0.35mm (sliding fit). Arm slides freely into channel.
- **Printability note**: Channel walls are vertical ribs 2.0mm thick rising from inner plate. 2.0mm = 5 perimeters at 0.4mm line width — solid. No overhang. Channel top is open (arm enters from above). ✓

## Material & Tolerances

- Material: PLA (Bambu PLA Basic)
- Fan frame to rim: 0.5mm clearance per side (clearance fit — fan must drop in easily)
- Arm to channel: 0.35mm per side (sliding fit — guided travel, not friction)
- Bottom face: flat, no features (caulked to lid)
- Min wall thickness throughout: 2.0mm (channel walls) ✓

## Constraints

- Build volume: 196.2 × 196.2 × 15.0mm — fits Bambu X1C (256mm limit) ✓
- No overhangs >45° in print orientation (bottom-down)
- No supports required
- Channel walls must not interfere with arm during installation travel (sliding fit verified above)
- Ledge flat zone must remain at z=7–9 (unchanged from v2 — sets hook engagement depth)
- Only 2 ledges and 2 channels (+X and -X). The ±Y rim faces have no ledges and no channels — plain rim.

## Printability Pre-Screen

| Feature | Check | Result |
|---|---|---|
| Channel walls (2mm, vertical) | Wall thickness ≥ 1.2mm | PASS (2.0mm = 5 perimeters) |
| Channel walls (10mm tall, 2mm thick) | Slender column risk | ACCEPTABLE — supported at base over full wall footprint; 10mm height with 2mm thickness = 5:1 aspect ratio, fine for PLA |
| Channel top (open) | Bridging needed? | PASS — channel is open-top (arm enters from above), no bridge |
| Ledge chamfer (z=4–7, 45°) | Overhang ≤ 45° | PASS — 3mm horizontal over 3mm vertical = 45° exactly; self-supporting |
| Ledge flat top | Overhang at transition? | PASS — flat top of ledge is at z=9 = rim top; supported by rim below, no overhang |
| Rim (4mm tall, 2mm thick) | Wall ≥ 1.2mm | PASS |
| Y-branches | Bridge between fork arms | PASS — fork arms are coplanar solid extrusions, no bridge |
| Center opening | Circular span = 115mm | FLAG: 115mm diameter circular span. However this prints as a ring (the inner plate has center opening cut through it) — the printer lays concentric perimeters inward with no bridge needed. Validated in v2. ✓ |
| Channel radial depth | Depth ~5mm at z=5–15 | PASS — channels rise from the inner plate surface with full support below |
| Ledge reduced to 2 (was 4) | Any structural concern? | No issue — each ledge is independent |
