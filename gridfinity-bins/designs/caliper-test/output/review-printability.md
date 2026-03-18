# Printability Review: caliper-test

## Data Sources
- Geometry report: YES (ground-truth mesh analysis — trimesh, 442 layers, 13 transitions)
- Slicer report: NO (PrusaSlicer not installed in this environment)
- Fallback to SCAD source: YES (supplementary — used to verify chamfer angles; geometry report is primary)

## Print Orientation

Per `modeling-report.json` printOrientation:
- **Bed face:** bin base — bottom of Gridfinity base profile (Z=0)
- **Print-Z direction:** upward from base to stacking lip tip
- **Installed orientation:** identical to print orientation — this bin installs base-down into a Gridfinity baseplate, the same face that contacts the print bed

No rotation required. The part prints in its functional, installed orientation.

## Feature Stack (bed to top)

1. **gridfinity_base_grid** (z: 0 to 7.0 mm) — 2x1 stepped chamfer base profile; bridge plate connecting the two base units at Z=4.75-7.0 mm
2. **bin_body_solid** (z: 7.0 to 84.0 mm) — solid outer block; pocket is the only interior void; pocket walls 5.55 mm X-sides, 10.55 mm Y-sides
3. **through_pocket** (z: 7.2 to 88.4 mm) — 70x18 mm rectangular slot with 1.5 mm corner radii; 1.5 mm 45-deg lead-in chamfer at pocket mouth (Z=69.7-71.2 mm)
4. **stacking_lip** (z: 84.0 to 88.4 mm) — standard Gridfinity stacking lip; 45-deg catch step then 45-deg outward ramp

Cross-reference geometry report transitions with declared features:

| Geometry transition | Z (mm) | Declared feature boundary | Match |
|---|---|---|---|
| Contraction -36.4% | 7.3 | base grid top / bin interior floor opens | YES |
| Contraction -85.2% | 71.3 | pocket wall fill top (71.2 mm) | YES (within 0.1 mm layer resolution) |
| Contraction -92.1% | 84.1 | bin body top / stacking lip catch (84.0 mm) | YES (within 0.1 mm layer resolution) |
| 9x sequential expansion steps | 84.3-87.9 | stacking lip chamfer ramp | YES |

All 13 geometry transitions align with declared features. No unexplained transitions.

## Transition Checks

### Gridfinity Base Grid to Bin Body Interior (Z ~ 7.0-7.3 mm)

- **Geometry report:** contraction -36.4% at layer 36, Z=7.3 mm; prev area 3453 mm2 to curr area 2195 mm2; contours 1 to 2
- **Layer bounds:** 83.5x41.5 mm at Z=7.1 (layer 35) to 83.5x41.5 mm at Z=7.3 (layer 36); outer footprint unchanged
- **Analysis:** The bin interior floor appears at Z=7.2 mm, opening the pocket void in the cross-section. The outer shell walls remain the same footprint — purely vertical, no outward growth. The floor at Z=7.2 mm is supported from below by the full-width base grid. The area reduction reflects the hollow interior opening, not material overhanging outward.
- **Overhang faces in Z range:** None (all 86 flagged overhangs are at Z=0.0)
- **PASS** — vertical outer walls; supported internal floor

### Pocket Lead-In Chamfer (Z=69.7-71.2 mm)

- **SCAD source:** `pocket_chamfer = 1.5 mm`; hull from pocket_x=70 mm at Z=69.7 to pocket_x+3=73 mm at Z=71.2 (1.5 mm per side over 1.5 mm height)
- **Angle:** 1.5 mm horizontal / 1.5 mm vertical = 1:1 = exactly 45 deg
- **Direction:** chamfer widens the pocket mouth — the chamfer faces slope inward over the pocket void. They overhang the open pocket, but are attached to and supported by the surrounding solid pocket wall material on all sides. This is structurally identical to a 45-deg chamfer on a through-hole, which prints without support.
- **Overhang faces in range:** None above Z=0 in geometry report
- **PASS** — at 45 deg limit; interior chamfer supported by surrounding solid walls

### Pocket Wall Top to Open Upper Bin (Z ~ 71.2-71.3 mm)

- **Geometry report:** contraction -85.2% at layer 356, Z=71.3 mm; prev area 1948 mm2 to curr area 288 mm2; outer bounds unchanged at 83.5x41.5
- **Analysis:** Pocket wall fill ends. Above Z=71.2 mm only the thin bin outer shell remains (288 mm2 = outer shell walls only). The pocket wall top is a horizontal shelf surface — this is the caliper rest ledge. It is not a bridge: it is fully supported from below by 64 mm of solid pocket fill material (Z=7.0 to Z=71.2). The printer builds this as a normal top surface with infill/perimeters below.
- **Overhang faces in range:** None above Z=0 in geometry report
- **PASS** — supported horizontal top surface; no unsupported span; outer walls remain vertical

### Bin Body Top to Stacking Lip Catch Notch (Z ~ 84.0-84.1 mm)

- **Geometry report:** contraction -92.1% at layer 420, Z=84.1 mm; prev area 288 mm2 to curr area 23 mm2
- **Layer bounds:** 83.5x41.5 at Z=83.9 (layer 419) to 78.5x36.5 at Z=84.1 (layer 420); 2.5 mm inward per side
- **Analysis:** The stacking lip catch notch forms. Material steps 2.5 mm inward on all sides — a contraction. The new layer is entirely contained within the footprint of the layer below it, so it is fully supported. No material overhangs outward.
- **PASS** — inward contraction; fully supported by layer below

### Stacking Lip Chamfer Ramp (Z=84.1-88.4 mm)

- **Geometry report:** 9 sequential expansion transitions at layers 421-439; each step expands width by 0.4 mm (0.2 mm per side) per 0.2 mm layer height
- **Expansion angle per step:** 0.2 mm outward per side / 0.2 mm height = 1:1 = exactly 45 deg on every step
- **Quantitative layer data:**

| Layer | Z (mm) | Width X (mm) | Gain from prev (mm) | Angle |
|---|---|---|---|---|
| 420 | 84.1 | 78.5 | — (catch contraction) | — |
| 421 | 84.3 | 78.9 | +0.4 (0.2/side) | 45 deg |
| 422 | 84.5 | 79.3 | +0.4 | 45 deg |
| 423 | 84.7 | 79.7 | +0.4 | 45 deg |
| 424-432 | 84.9-86.5 | 79.7 (stable) | 0 (vertical wall phase) | 90 deg |
| 433 | 86.7 | 80.1 | +0.4 | 45 deg |
| 434-439 | 86.9-87.9 | 80.5-82.5 | +0.4 each | 45 deg |

- **Overhang faces in range:** None above Z=0 in geometry report
- **PASS** — all expansion steps at exactly 45 deg; standard Gridfinity stacking lip profile

## Tips and Extremities

**Stacking lip top edge (Z=88.4 mm):**
- Terminates as a continuous perimeter ring, not a point or cantilevered tip
- Last measured layer Z=88.3: 83.3x41.3 mm — symmetric closed ring
- `thin_walls: 0` from geometry report; no thin wall flags anywhere
- **PASS**

**Pocket mouth edges (Z=71.2 mm):**
- Pocket wall top is a fully-supported horizontal ledge (caliper rest surface)
- Chamfered at 45 deg for the 1.5 mm above, easing any print imperfections at the pocket mouth
- No cantilevered tabs or hooks
- **PASS**

**Build volume check:**
- Part: 83.5 x 41.5 x 88.4 mm vs build volume 256 x 256 x 256 mm
- Clearance: 172 mm X, 214 mm Y, 168 mm Z
- **PASS** — well within all axes

**Thin wall summary:**
- Geometry report: `thin_walls: 0`
- Bin outer walls: 1.2 mm = exactly 3x nozzle diameter (minimum threshold)
- Pocket walls X-sides: 5.55 mm — well above minimum
- Pocket walls Y-sides: 10.55 mm — well above minimum
- **PASS**

## Horizontal Spans

| Span | Location | Length | Bridge? | Result |
|---|---|---|---|---|
| Pocket floor | Z=7.2 mm interior | N/A — supported from below by base grid | No | PASS |
| Pocket wall top / caliper shelf | Z=71.2 mm interior | N/A — supported from below by 64 mm solid fill | No | PASS |
| Base bridge plate | Z=4.75-7.0 mm | N/A — solid base profile, no span | No | PASS |

Geometry report `bridges: []` — zero bridge spans detected. No unsupported horizontal surfaces anywhere in the model.

## Mating Clearances

| Feature | This part | Mating part | Gap per side | Role | Result |
|---|---|---|---|---|---|
| Pocket width X | 70.0 mm ID | Caliper display body 68 mm | +1.0 mm | Clearance — drop-in storage | PASS |
| Pocket depth Y | 18.0 mm ID | Caliper display body 16 mm | +1.0 mm | Clearance — drop-in storage | PASS |
| Gridfinity base OD | 83.5 mm | Baseplate receptacle (per GF spec, 0.25 mm/side) | 0.25 mm | Slide into baseplate | PASS |
| Stacking lip | per GF stacking spec | Upper bin base profile | 0.25 mm | Stacking interlock | PASS |

**Pocket clearance note:** +1 mm per side (2 mm total per axis) is a loose clearance fit — the caliper drops in freely. FDM print variation of +/-0.2 mm still leaves 0.8 mm minimum clearance. The caliper is retained by gravity in the pocket, not by friction. Appropriate for a grab-and-go storage application.

**Jaw clearance:** Caliper large jaws (40 mm from beam edge, ~5 mm thick) extend in the Y direction. The 70 mm X pocket width accommodates the full jaw span. The 18 mm Y depth accommodates the jaw thickness (~5 mm). **PASS.**

## Slicer Validation

Slicer report: NOT AVAILABLE — PrusaSlicer not installed in this environment.

Manual assessment: This design has no features that would trigger support generation. The Gridfinity base profile (45-deg stepped chamfers), stacking lip (45-deg ramp), and pocket lead-in chamfer (45-deg) are all within the no-support threshold. Zero bridge spans detected by mesh analysis. A slicer would not add support material to this model.

## Geometry Analyzer `overall_pass: false` — Root Cause

The geometry report flags `overall_pass: false` with `total_issues: 86` and `overhangs.count: 86`.

All 86 overhang faces have centroid Z=0.0 — they are the downward-facing bottom triangles of the part's bed face. The analyzer correctly identifies these as facing away from the build direction (90-deg overhang) but does not model bed support. This is a known false-positive pattern for any solid part's bed face.

**Conclusion:** The `overall_pass: false` is a false alarm. Zero real overhang violations exist.

## Conflicts

None. No printability fix conflicts with functional design intent.

## Summary

| Metric | Value |
|---|---|
| Transitions checked | 6 |
| PASS | 6 |
| FAIL | 0 |
| Bridge violations | 0 |
| Thin wall violations | 0 |
| Conflicts | 0 |

**Overall verdict: PASS — print without support material.**

## Test Print Recommendations

- **Pocket fit (cavity-fit):** HIGH priority. The 70x18 mm pocket with +1 mm per-side clearance is the primary fitment risk. Caliper measurement uncertainty is +/-2 mm. Print the existing `test-prints/cavity-fit` piece to confirm fit before the full bin.
- **Stacking lip (ledge-slot):** MEDIUM priority. The 45-deg stacking lip is standard Gridfinity but worth confirming on this printer/filament. Print the existing `test-prints/ledge-slot` piece.

Both test print designs already exist in `test-prints/`.
