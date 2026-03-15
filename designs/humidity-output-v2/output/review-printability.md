# Printability Review: humidity-output-v2

## Data Sources
- Geometry report: YES (trimesh mesh analysis — 310 layers, 442 overhang faces*, 4 bridge warnings, 4 transitions, 0 thin walls)
- Slicer report: NO (PrusaSlicer not installed)
- Fallback to SCAD source: YES (for ridge chamfer angle verification)

*All 442 overhang faces are z=0 bed-contact false positives (per-face normal method flags downward-facing bed faces as overhangs).

## Print Orientation
- Bed face: base plate bottom (z=0)
- Growth direction: +Z, spigot tip at z=62mm topmost
- Installed orientation: IDENTICAL to print orientation

## Feature Stack (bed → top)
1. outer_plate (z: 0–4.6) — 146.2mm square flange
2. y_branch_arms (z: 0–4.6) — 4 corner Y-forks, 196.2mm span
3. inner_pad (z: 0–5.0) — 130mm square thickened zone
4. internal_fins (z: 0–62) — 6 radial ribs, full depth to z=52, taper z=52–62
5. spigot_body (z: 5–54) — OD 106mm, ID 96mm, wall 5mm
6. external_shark_fins (z: 5–18) — 6 triangular gussets
7. lower_stop_ridge (z: 20–25) — annular ring OD 114mm, h=4mm, w=5mm
8. foam_groove (z: 25–44) — 2.5mm deep annular channel
9. above_seal_grip (z: 44–54) — plain spigot, full OD
10. lead_in_taper (z: 54–62) — OD 106→100mm cone (NEW in v2)

## Transition Checks

### T1: bed → base plate (z=0)
All features launch from z=0 on the bed. No unsupported first layer.
**PASS**

### T2: outer_plate top → inner_pad only (z=4.6)
- A: base plate + y-branches, 196.2mm, area 15,879mm²
- B: inner_pad only, 130mm, area 9,685mm²
- Contraction — outer plate ends, inner pad continues. No overhang.
**PASS**

### T3: inner_pad top → spigot + shark fins (z=5.0)
- A: inner_pad 130mm (half-side 65mm)
- B: spigot OD 106mm (r=53mm) + shark fin tips at r=62mm
- Spigot r=53 < inner_pad half-side 65mm. Shark fin r=62 < 65mm.
- Both fully within inner_pad footprint. No overhang.
**PASS**

### T4: shark fin slope (z=5–18)
- 9mm radial over 13mm height → ratio 9/13 = 0.69 < 1.0
- Face angle 55.3° from horizontal (limit 45°)
**PASS**

### T5: shark fin tips → plain spigot (z=18)
- Fins taper to zero at spigot OD. Contraction — fully self-supporting.
**PASS**

### T6: spigot → lower_stop_ridge underside (z=20) — DUAL CHECK
**Underside (step outward):**
- Spigot OD 106mm → ridge OD 114mm over height 4mm
- Radial protrusion: (114−106)/2 = 4.0mm
- Chamfer height: 4.0mm
- Overhang ratio: 4.0/4.0 = **1.0** (limit 1.0)
- Face angle: arctan(4/4) = **45.0°** from horizontal (limit 45°)
- **PASS** — chamfer meets 45° limit exactly

**Top edge (step inward):**
- Ridge OD 114mm contracts to foam groove OD 101mm at z=25
- Contraction — no overhang
- **PASS**

### T7: foam groove bottom face (z=25)
- Groove wall (r=48–50.5mm) fully supported by spigot body below
- Contraction from ridge OD to groove wall
**PASS**

### T8: foam groove top → above_seal_grip (z=44)
- OD steps from 101mm (groove) to 106mm (full spigot)
- Horizontal step: 2.5mm per side — annular bridge
- Bridge span: 2.5mm < 10mm limit
- Geometry analyzer confirms: bridge warning at z=44, span=2.5mm, pass=true
**PASS** (bridge span within limit)

### T9: above_seal_grip → lead_in_taper (z=54)
- OD decreases from 106mm to 100mm over 8mm
- Contraction — each taper layer supported by wider layer below
- Taper angle 69.4° from horizontal — well above 45°
**PASS**

### T10: lead_in_taper tip (z=62)
- Tip wall: (100−96)/2 = 2.0mm ≥ 1.2mm minimum
**PASS**

## Tips & Extremities
- Y-branch arm tips: printed flat on bed, no cantilever. **PASS**
- Shark fin tips (z=18): taper to zero at spigot surface. **PASS**
- Lead-in taper tip ring (z=62): 2.0mm wall, supported by cone below. **PASS**
- Internal fin taper (z=52–62): retreats inward, no unsupported extension. **PASS**

## Horizontal Spans
| Span | Z (mm) | Length (mm) | Slicer bridge? | Result |
|---|---|---|---|---|
| Foam groove top edge | 44.0 | 2.5 | N/A (no slicer) | **PASS** |
| Ridge chamfer facets | 20.2–24.8 | 0.2 | N/A | **PASS** |

## Mating Clearances
| Feature | OD (mm) | Mate ID (mm) | Gap (mm) | Role | Result |
|---|---|---|---|---|---|
| Spigot body | 106.0 | 107.6 (duct ring) | +1.6 diametric | Slide-over | **PASS** |
| Lower stop ridge | 114.0 | 107.6 (duct ring) | −6.4 diametric | Hard stop | **PASS** |
| Y-branch arm | 9.0 wide | 9.4 channel | +0.4 (0.2/side) | Locating | **PASS** |

## Slicer Validation
No slicer-report.json available. PrusaSlicer not installed. Recommend slicer pass before printing to verify:
- Ridge chamfer does not trigger auto-support
- Foam groove top edge handled in bridge mode
- Shark fins not support-generated

## Conflicts
None. Previous C1 (ridge chamfer at 36.9°) resolved by increasing `ho2_lower_ridge_h` from 3→4mm and `ho2_lower_ridge_w` from 4→5mm, yielding exactly 45° chamfer with 1mm flat top preserved.

## Pipeline Notes
- Geometry analyzer overhang detection: 442 false positives (all z=0 bed faces). Per-face normal method flags bed-contact faces as overhangs. Recommend adding per-layer contour-expansion rate check for future improvement.
- No slicer validation available — install PrusaSlicer for ground-truth support detection.

## Summary
- Data quality: mesh analysis (geometry-report.json) + SCAD source (for ridge verification)
- Total transitions checked: 10
- PASS: 10
- FAIL: 0
- Slicer agreement: N/A
- Conflicts requiring user decision: 0
- **Part cleared for print.**
