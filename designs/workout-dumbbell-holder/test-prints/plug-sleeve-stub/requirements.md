# Plug + Sleeve Fit Stub Requirements

## Parent Design
workout-dumbbell-holder v3.4 — see `designs/workout-dumbbell-holder/requirements.md`

## Modeling Backend
**fusion** — model this in Fusion 360 via the direct TCP protocol used for the parent design. Do NOT attempt to rewrite in OpenSCAD. Load parent dimensions from `designs/workout-dumbbell-holder/spec.json` params block; do not hardcode values.

## Purpose
Gate print: **must pass before the full v3.4 part is printed.**

This test print answers three questions simultaneously:

1. **Plug clearance (inside rail):** Does the plug OD (68.5 × 42.5 mm with 2.5 mm corner radius) slide cleanly into the rail bore (ID 70.5 × 44.5 mm) with the specified 1 mm/side clearance in CF-reinforced filament? CF shrinks less than plain PLA — the 1 mm/side margin was chosen to absorb this uncertainty, but it must be confirmed before committing to the full 56 mm part.

2. **Sleeve clearance (outside rail):** Does the sleeve ID (78.5 × 53.0 mm with 7 mm inner corner radius) slide over the rail OD (76.5 × 51.0 mm) with 1 mm/side clearance? The sleeve inner ceiling requires support material; surface quality after support removal is critical because residue could partially consume the 1 mm gap.

3. **C-shape orientation:** Does the sleeve's −X wall removal (console clearance cut) face the correct direction and allow the sleeve to clear the treadmill console structure on the −X side?

The spec-writer's structural hand-test (testPrintCandidates[1]: plug-wall minimum cross-section at cantilever root) is also satisfied by this stub — after printing and trial-fitting the rail, hand-load the stub laterally to feel for flex or delamination at the plug-to-flange transition.

## Verification Method

**Trial fit on the actual treadmill rail — this is the primary test, calipers are secondary.**

### Step 1 — Slide plug into bore
Insert the plug end down into the rail bore opening. The plug should:
- Slide in smoothly with light hand pressure (no mallet)
- Have audible play when shaken laterally (rattle is expected at 1 mm/side nominal)
- Withdraw with one-finger upward pull

PASS: slides in and out freely, lateral rattle when shaken.
FAIL: any binding at any point during insertion or withdrawal.

### Step 2 — Slide sleeve over rail OD simultaneously
With the plug engaged, lower the sleeve portion over the rail outer surface. The sleeve should:
- Clear the rail OD on all three retained walls (+X, +Y, −Y)
- The −X opening should face toward the treadmill console
- Slide to the point where the flange seats on the rail-top face

PASS: flange seats flush, no binding on any of the three sleeve walls.
FAIL: sleeve catches on rail OD edge, or flange cannot seat (sleeve stuck partway).

### Step 3 — Inspect sleeve inner walls
Remove the stub and inspect the sleeve inner surfaces with a flashlight through the open sleeve bottom. Check for:
- Support material residue ridges > ~0.3 mm (anything you can feel with a fingernail)
- Delamination on the inner ceiling (Z=−8 face inside the cavity)
- Surface roughness that would catch on rail OD during installation

PASS: surfaces feel smooth enough to slide over rail; minor texture is acceptable.
FAIL: ridges or bumps that could not be scraped clean with a stiff tool.

### Step 4 — Hand structural test
With plug engaged in bore, apply moderate lateral load (1–2 kg equivalent) by hand in the +Y direction at the flange. Feel for:
- Flex at the plug root (plug bending inside bore)
- Any creak or delamination sound

PASS: stiff, no audible creak, spring-back is immediate.
FAIL: audible creak, visible crack, or non-recovering deformation.

### Step 5 — Caliper record (optional but recommended)
Measure plug OD on both axes at mid-depth with digital calipers. Record actual vs. nominal (68.5 and 42.5 mm). This calibrates the CF dimensional offset for future designs using this filament.

## Geometry

### What to keep (full scale)
- Full plug body: OD 68.5 mm (X) × 42.5 mm (Y), 2.5 mm corner radius, depth 30 mm (Z=[−38, −8])
- Full seating flange: OD 88.5 mm (X) × 62.5 mm (Y), 7 mm corner radius, 8 mm thick (Z=[−8, 0])
- Plug-to-flange shoulder fillet: r=5 mm on all 8 inside-corner edges at Z=−8 (Fillet3 in parent)
- Sleeve: OD 88.5 × 62.5 mm, ID 78.5 × 53.0 mm, 7 mm inner+outer corner radius, **shortened to 25 mm** (Z=[−8, −33] instead of parent's Z=[−8, −56])
- Sleeve −X wall removal (C-shape): cut at X=[−44.25, −39.25], Y=[−31.25, +31.25] for the full sleeve Z range [−8, −33] — open on −X short side, two −X corners also removed

### What to drop
- Everything at Y > +31.25: entire fork plate, both buttress arcs, both ribs, all tine geometry
- Sleeve Z below −33 (saves ~8 mm of sleeve depth, reduces print time without affecting fit test validity)

### Plug body — hollow to save material
The parent plug body is fully solid. For this test print, shell the plug to 3 mm walls (CF minimum), open at the plug bottom face (Z=−38). This is a rectangular shell with 3 mm wall on all four sides and open bottom. The external OD and corner geometry are IDENTICAL to the parent — the hollowing is purely internal. Estimated solid → hollow volume reduction: ~40 cm³.

Wall targets for hollow plug (all ≥ 3 mm):
- Wide-axis walls (X faces): 3 mm
- Narrow-axis walls (Y faces): 3 mm
- Plug top face (Z=−8 interface with flange): retain as solid 8 mm flange — no hollowing into flange

### Base / print orientation
The test piece prints in the same orientation as the full part: **flange face down on bed** (Z=0 face on bed, plug and sleeve extending upward toward Z=−33 in print height). The flange face (88.5 × 62.5 mm) is the bed contact surface — same as the full part. No additional base plate needed.

Sleeve inner ceiling (the Z=−8 face inside the 78.5 × 53.0 mm cavity) will require support material — this is intentional and is part of what is being tested. Enable support in slicer for the sleeve inner ceiling.

## Critical Dimensions

| Dimension | Nominal | Tolerance | How to verify |
|---|---|---|---|
| Plug OD wide (X) | 68.5 mm | ±1.0 mm | Calipers across widest face |
| Plug OD narrow (Y) | 42.5 mm | ±1.0 mm | Calipers across narrow face |
| Sleeve ID wide (X) | 78.5 mm | ±1.0 mm | Calipers inside cavity (wide axis) |
| Sleeve ID narrow (Y) | 53.0 mm | ±1.0 mm | Calipers inside cavity (narrow axis) |
| Plug depth (Z) | 30.0 mm | ±0.5 mm | Calipers plug length |
| Sleeve length (Z) | 25.0 mm | ±1.0 mm | Calipers sleeve length |
| Flange thickness (Z) | 8.0 mm | ±0.5 mm | Calipers flange |
| Plug corner radius | 2.5 mm | ±0.5 mm | Visual / go-no-go with r2.5 gauge |
| Sleeve inner corner radius | 7.0 mm | ±1.0 mm | Visual — must clear rail OD corner r=6 |

## Parameters
Load from parent `designs/workout-dumbbell-holder/spec.json` → `params` block. Key values:
- `plug_wide`: 68.5, `plug_narrow`: 42.5, `plug_depth`: 30, `plug_corner_radius`: 2.5
- `clearance_per_side`: 1.0
- `flange_thickness`: 8, `flange_overhang`: 10
- `sleeve_id_wide`: 78.5, `sleeve_id_narrow`: 53.0
- `sleeve_od_wide`: 88.5, `sleeve_od_narrow`: 62.5
- `sleeve_inner_corner_r`: 7.0, `sleeve_outer_corner_r`: 7.0
- `sleeve_wall_wide_axis`: 5.0, `sleeve_wall_narrow_axis`: 4.75
- `sleeve_minus_x_wall_removed`: true
- Test-print-specific: sleeve_length = 25 (shortened from parent 48)

## Constraints
- Minimize material — hollow the plug to 3 mm walls, shorten sleeve to 25 mm
- Print in same orientation as full part (flange face down)
- Keep all mating geometry at full scale — no scaling
- Must be watertight (closed shell with hollow interior is fine; open bottom of hollow plug is fine)
- Sleeve −X wall must be open (C-shape) — same as parent
- Do NOT include any fork plate, buttress, rib, or tine geometry
