# Printability Review: humidity-output-v2

## Re-review Context
This is a re-review after the v2.1 fix. The foam groove top transition was changed from a
sharp horizontal step (2.5mm annular bridge at z=44) to a 45° chamfer. A new feature
`foam_groove_chamfer` exists at z=44 to z=46.5. The `above_seal_grip` lower bound moved
from z=44 to z=46.5. All other geometry is unchanged from the previous review.

## Data Sources
- Geometry report: YES (geometry-report.json — 310 layers, 522 overhang faces*, 32 bridge
  warnings, 4 transitions, 0 thin walls)
- Slicer report: NO (not available)
- SCAD source: YES (ho2_foam_groove polygon verified)

*All 522 overhang faces have angle_from_horizontal = 90.0 — these are bed-contact downward
faces, confirmed false positives. No genuine overhang violations.

## Print Orientation
- Bed face: base plate bottom (z=0) flat on the bed
- Growth direction: +Z; spigot tip at z=62mm is topmost
- Installed orientation: IDENTICAL to print orientation

## Feature Stack (bed → top)
1. outer_plate (z: 0–4.6) — 146.2mm square flange
2. y_branch_arms (z: 0–4.6) — 4 corner Y-forks, 196.2mm span
3. inner_pad (z: 0–5.0) — 130mm square thickened zone
4. internal_fins (z: 0–62) — 6 radial ribs, full depth to z=52, taper z=52–62
5. spigot_body (z: 5–54) — OD 106mm, ID 96mm, wall 5mm
6. external_shark_fins (z: 5–18) — 6 triangular gussets
7. lower_stop_ridge (z: 20–25) — annular ring OD 114mm, 4mm chamfer + 1mm flat top
8. foam_groove (z: 25–44) — 2.5mm deep annular channel, 19mm wide
9. foam_groove_chamfer (z: 44–46.5) — 45° chamfer returning groove floor to full spigot OD (NEW)
10. above_seal_grip (z: 46.5–54) — plain spigot at full 106mm OD
11. lead_in_taper (z: 54–62) — OD 106→100mm cone

## Transition Checks

### T1: bed → base plate (z=0)
All features launch from z=0. No unsupported first layer.
**PASS**

### T2: outer_plate top → inner_pad only (z=4.6)
- A: 196.2mm span, area ~15,880mm²
- B: 130mm inner pad, area ~9,686mm²
- Contraction — no overhang.
**PASS**

### T3: inner_pad top → spigot + shark fins (z=5.0)
- Spigot r=53mm < inner_pad half-side 65mm
- Shark fin tips r=62mm < inner_pad half-side 65mm
- Both fully within footprint.
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
- Radial protrusion: 4.0mm, chamfer height: 4.0mm
- Overhang ratio: 4.0/4.0 = **1.0** (limit 1.0)
- Face angle: 45.0° from horizontal
- **PASS** — chamfer meets 45° limit exactly

**Top edge (step inward):**
- Ridge OD 114mm contracts to foam groove OD 101mm at z=25
- Contraction — no overhang
- **PASS**

### T7: foam groove bottom face (z=25)
- Groove wall fully supported by spigot body below
- Contraction from ridge OD to groove wall
**PASS**

### T8: foam groove top → foam_groove_chamfer (z=44) — REVISED
Previously a 2.5mm horizontal bridge (v2.0). Now replaced by 45° chamfer (v2.1).

**Chamfer geometry:**
- From (r=50.5, z=44) to (r=53, z=46.5)
- delta_r = 2.5mm, delta_z = 2.5mm
- Overhang ratio: 2.5/2.5 = **1.0** (exactly 45°)
- No horizontal bridge remains at z=44.

Geometry report confirms: transition at z=44.3 is an expansion (+10%), consistent with
chamfer progressively widening cross-section. No bridge_fails recorded.
**PASS** — sharp bridge eliminated; chamfer is self-supporting at 45°

### T9: foam_groove_chamfer top → above_seal_grip (z=46.5)
- Chamfer reaches full spigot OD (r=53mm) at z=46.5
- above_seal_grip continues at same OD — flush continuation, no step
**PASS**

### T10: above_seal_grip → lead_in_taper (z=54)
- OD decreases from 106mm to 100mm over 8mm
- Contraction — each layer supported by wider layer below
- Taper angle 69.4° from horizontal
**PASS**

### T11: lead_in_taper tip (z=62)
- Tip wall: (100−96)/2 = 2.0mm ≥ 1.2mm minimum
**PASS**

## Tips & Extremities
- Y-branch arm tips: printed flat on bed, no cantilever. **PASS**
- Shark fin tips (z=18): taper to zero at spigot surface. **PASS**
- Lead-in taper tip ring (z=62): 2.0mm wall, supported by cone below. **PASS**
- Internal fin taper (z=52–62): retreats inward, no unsupported extension. **PASS**

## Horizontal Spans

Bridge classification per avoidable bridge policy:

| Span | Z (mm) | Span (mm) | Classification | Result |
|---|---|---|---|---|
| Foam groove top (v2.0) | 44.0 | 2.5 | Avoidable — ELIMINATED by v2.1 chamfer | N/A |
| Chamfer facet artifacts | 44.3–45.7 | 0.28 per facet | Trivial (≤1mm) | **PASS** |
| Ridge chamfer facets | 20.2–24.8 | ~0.2 | Trivial (≤1mm) | **PASS** |

The 32 bridge warnings in geometry-report.json (z=44.3–45.7, span=0.28mm each) are
per-facet artifacts of the $fn=80 polygon approximation of the chamfer circle. All trivial.

## Mating Clearances
| Feature | OD (mm) | Mate ID (mm) | Gap (mm) | Role | Result |
|---|---|---|---|---|---|
| Spigot body | 106.0 | 107.6 (duct ring) | +1.6 diametric | Slide-over | **PASS** |
| Lower stop ridge | 114.0 | 107.6 (duct ring) | −6.4 diametric | Hard stop | **PASS** |
| Y-branch arm | 9.0 wide | 9.4 channel | +0.4 (0.2/side) | Locating | **PASS** |

## Slicer Validation
No slicer-report.json available. Recommend slicer pass before printing to confirm the
chamfer zone is handled without auto-support insertion.

## Conflicts
None. The v2.1 chamfer fix is geometrically clean:
- Foam groove floor (z=25–44) is unaffected — foam seating surface unchanged
- above_seal_grip shrinks from 10mm to 7.5mm — ample grip remains
- No functional trade-off

## Test Print Recommendations
- **spigot-duct-fit** (already modeled): Mating interface with 0.8mm/side clearance. The chamfer fix should be incorporated into the test print SCAD for accurate validation.
- **y-branch-channel-fit** (already modeled): 0.2mm/side clearance to waffle channels.

## Pipeline Notes
- Geometry analyzer overall_pass: false is a false negative (522 bed-contact false positives)
- 32 bridge warnings are trivial chamfer facet artifacts (0.28mm each)
- No slicer validation available

## Summary
- Total transitions checked: 11
- PASS: 11
- FAIL: 0
- Avoidable bridges: 1 found in v2.0, eliminated by v2.1 chamfer
- Conflicts requiring user decision: 0
- **Part cleared for print.**
