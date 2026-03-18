# Printability Review: caliper-test v4

**Verdict: PASS**

## Geometry Summary

| Metric | Value |
|---|---|
| Bounding box | 83.5 x 41.5 x 88.4 mm |
| Volume | 170 cm3 |
| Watertight | Yes |
| Layers (0.2mm) | 442 |
| Overhang faces | 86 (all false positives -- bed face at Z=0) |
| Bridge warnings | 0 |
| Thin walls | 0 |
| Cross-section transitions | 13 |

## Step 1: Overhang Analysis

All 86 flagged overhang faces are at Z=0.0 (90-degree angle). These are the bottom face of the bin that sits on the print bed. No actual unsupported overhangs exist in this model.

- Base profile chamfers: 45-degree, standard Gridfinity FDM-designed. **PASS**
- Stacking lip: expands at exactly 45 degrees per layer (0.2mm outward per side per 0.2mm layer height). **PASS**
- Pocket lead-in chamfer: 45-degree bevel, 1.5mm. At limit but printable. **PASS**

## Step 2: Bridge Analysis

No bridges detected. All horizontal surfaces are fully supported from below:
- Bin floor at Z=7.2: solid base grid material below. **PASS**
- Pocket floor at Z=7.2: same -- rests on base grid solid. **PASS**
- Pocket wall top shelf at Z=71.2: supported by 64mm of solid pocket walls. **PASS**

## Step 3: Wall Thickness

No thin walls detected. All walls meet the 1.2mm minimum:
- Exterior bin walls: 1.2mm (GF_WALL_THICKNESS_THICK). **PASS**
- Pocket walls (X sides): 5.55mm -- well above minimum. **PASS**
- Pocket walls (Y sides): 10.55mm -- well above minimum. **PASS**

## Step 4: Cross-Section Transitions

13 transitions detected, all explained by design features:

| Z (mm) | Type | Change | Feature |
|---|---|---|---|
| 7.3 | Contraction | -36% | Base to pocket walls (interior void begins) |
| 71.3 | Contraction | -85% | Pocket walls end, open interior begins |
| 84.1 | Contraction | -92% | Bin body to stacking lip catch step |
| 84.3-87.9 | Expansion | +13-201% | Stacking lip profile building outward at 45 deg |

All transitions are gradual or at standard Gridfinity interfaces. No sudden unsupported expansions.

## Step 5: Mating Interface Check

- **Baseplate interlock**: Standard Gridfinity base profile (0.8mm/1.8mm/2.15mm steps). 0.25mm per-side clearance built into 41.5mm dimension. **PASS**
- **Stacking lip**: Standard profile (0.7mm/1.8mm/1.9mm steps). Matches baseplate pocket geometry. **PASS**
- **Caliper pocket**: 70x18mm pocket vs 68x16mm caliper = +1mm per side clearance fit. **PASS**
- **Insertion path**: Lip opening 78.3x36.3mm > open interior 81.1x39.1mm > pocket 70x18mm. Display body (68x16mm) passes through all three. **PASS**

## Step 6: Overall Assessment

**PASS** -- No printability issues found. The geometry analyzer's FAIL flag (86 issues) is entirely due to bed-face triangles classified as overhangs, which are false positives. All features are FDM-compatible:

- All overhangs are at or below 45 degrees
- No unsupported bridges
- No thin walls
- Pocket walls are structurally sound (5.55-10.55mm thick)
- Standard Gridfinity base and lip profiles print support-free as designed

### Test Print Recommendations

- **Pocket fit test**: Print a short section (20mm tall) of the pocket walls to verify the 70x18mm pocket accepts the caliper display body (68x16mm) smoothly with +1mm clearance per side.
