# Printability Review: glitter-wizard-hat

## Data Sources
- Geometry report: NO (geometry-report.json not present)
- Slicer report: NO (slicer-report.json not present)
- Fallback to SCAD source: YES — all analysis derived from SCAD arithmetic and rendered images

---

## Print Orientation

**Bed face:** Base opening (wide end, OD = 52 mm) flat on the bed, opening facing down.
**Growth direction:** +Z toward the pointed tip.
**Installed orientation vs. print orientation:** Different. The hat is worn tip-up (installed), but is printed tip-up as well — the growth direction matches the installed orientation. The base (opening) is on the bed.

This orientation is correct and optimal:
- The widest cross-section contacts the bed, maximising adhesion.
- Every subsequent layer is equal to or smaller than the one below it — zero outward overhang on the cone walls.
- All through-wall cutouts slice as vertical gaps in layers, requiring no bridging or support.

---

## Feature Stack (bed → top, large size)

All Z values are in print-Z (z=0 at bed).

1. **Retention lip ring** (z: 0–5 mm) — 3 mm thick radial step inside the base opening, 5 mm tall
2. **Cone body base** (z: 0–5 mm) — the annular base ring begins here (same height range as lip, they are coplanar)
3. **Cone body main taper** (z: 5–110.8 mm) — hollow truncated cone, wall 1.5 mm throughout; cutout rows at z ≈ 16.6, 38.8, 60.9, 83.1 mm
4. **Hemisphere tip** (z: 110.8–114.3 mm) — solid outer hemisphere transitioning from cone apex; inner bore closes concurrently

Derived values (SCAD arithmetic, large size):
- `cone_h` = height − tip_r = 114.3 − 3.5 = **110.8 mm**
- `tip_od` = 2 × tip_r + 2 × wall = 2 × 3.5 + 2 × 1.5 = **10.0 mm**
- `base_id` = base_od − 2 × wall = 52 − 3.0 = **49.0 mm**
- `lip_id` = base_id − 2 × lip_depth = 49 − 6 = **43.0 mm**
- `bore_tip_od` = tip_od − 2 × wall = 10 − 3 = **7.0 mm**

---

## Transition Checks

No geometry-report.json is available; all transitions are analysed from SCAD geometry using manual arithmetic.

---

### Transition 1: Bed → Cone base ring (z = 0)

The first printed layer is a 1.5 mm annular ring: OD = 52 mm, ID = 49 mm.

The retention lip ring (OD = 49.1 mm, ID = 43 mm, h = 5 mm) is coincident with the interior of this first layer, printed as part of the same cross-section.

- First-layer contact area (annular): π/4 × (52² − 43²) = π/4 × (2704 − 1849) = **671 mm²**
  (The retention lip ring outer edge ≈ base_id = 49 mm; with lip subtraction, the effective contact is the cone wall annulus + the lip annulus)
- No overhang; this is the base.

**PASS** — excellent bed contact, wide annular footprint.

---

### Transition 2: Cone base → Retention lip top (z = 5 mm)

The retention lip ring terminates at z = 5 mm. Above this, the interior of the cone has only the tapered bore (ID = 49 mm tapering inward). The top of the retention lip ring creates an inward ledge of 3 mm on each side.

- The top face of the retention lip (the 3 mm wide annular face at z = 5 mm, inner edge at r = 21.5 mm, outer edge at r = 24.5 mm) sits directly below the cone's interior wall above it.
- At z = 5 mm, the cone inner wall radius = cone_ir(5) = cone_or(5) − wall = [26 − 21 × (5/110.8)] − 1.5 = [26 − 0.948] − 1.5 = 23.55 mm.
- The retention lip outer edge is at r = 49.1/2 = 24.55 mm, which is *outside* cone_ir(5) = 23.55 mm.

Wait — by the assembly logic, the retention lip is added *after* the difference, so it fills in above the base inside the cone. At z = 5 mm, the cone bore inner wall is at r ≈ 23.55 mm, and the retention lip outer cylinder is r = 24.55 mm. The lip ring's outer surface is inside (surrounded by) the cone wall — it is not an exposed overhang. Its top annular face is 3 mm wide and is a horizontal surface flush with the inner cone at that height.

The transition from lip top to empty interior above z = 5 mm is entirely on the interior of the part. In print orientation, the inner cone bore is open downward (facing the bed). There is no bridging here: the bottom of the part is open (no floor to bridge), and the retention lip's top face is a horizontal surface that is printed on top of previous layers. The outer cone wall above z = 5 mm is supported by the cone body below it.

**PASS** — retention lip terminates cleanly; no unsupported overhangs at this transition.

---

### Transition 3: Cone taper — continuous taper (z = 0 to 110.8 mm)

The cone tapers from OD = 52 mm at z = 0 to OD = 10 mm at z = 110.8 mm.

**Half-angle from vertical:**
> α = atan((base_od/2 − tip_od/2) / cone_h) = atan((26 − 5) / 110.8) = atan(0.1895) ≈ **10.7°**

**Overhang angle from horizontal:**
> β = 90° − 10.7° = **79.3° from horizontal**

The cone wall surface is 79.3° from horizontal (nearly vertical). The FDM overhang limit is 45° from horizontal.

**PASS** — cone wall overhang angle 79.3° >> 45° limit. Zero risk.

---

### Transition 4: Cone apex → Hemisphere tip (z = 110.8 mm)

At z = cone_h = 110.8 mm, the cone terminates at OD = tip_od = 10.0 mm. The hemisphere outer sphere (r = 5 mm) begins here, centred at z = 110.8 mm.

**Outer surface — upper hemisphere (z > 110.8 mm):**
Each layer above the equator is strictly smaller than the one below. The outer surface overhang angle starts at 90° from horizontal at the equator and approaches 0° at the pole. However, because the sphere is shrinking (not growing), this is an inward overhang — the outer surface is never unsupported. Every layer of the outer hemisphere is supported by the layer beneath it.

**PASS** — outer hemisphere shrinks monotonically.

**Inner bore ceiling — upper hemisphere (z > 110.8 mm):**
The bore sphere (r = 3.5 mm) is also centred at z = 110.8 mm. Above the equator, the bore closes:

| delta (mm above z=110.8) | inner bore radius (mm) | bore diameter (mm) |
|---|---|---|
| 0.0 | 3.50 | 7.00 |
| 0.5 | 3.46 | 6.92 |
| 1.0 | 3.35 | 6.71 |
| 2.0 | 2.87 | 5.74 |
| 3.0 | 1.80 | 3.60 |
| 3.4 | 0.83 | 1.66 |
| 3.5 | 0.00 | closed |

The inner ceiling of the bore is a concave spherical surface. Near the equator (delta ≈ 0), the bore wall is nearly vertical (fast lateral shrinkage, shallow vertical slope) — the overhang angle approaches 90° from horizontal, well within limits. As delta increases, the inner ceiling becomes more horizontal.

At delta = 3.4 mm (z = 114.2 mm), the last open layer of the bore is 1.66 mm diameter — a trivial span well below the 10 mm bridge limit.

The closing inner bore does present progressively increasing overhang of the inner ceiling surface. Near the pole (last 0.5–1 mm of closure), the inner ceiling is nearly horizontal. However:
1. The maximum unsupported span never exceeds 7 mm (at the equator, where the surface is vertical — no bridging at all).
2. By the time the bore is small enough to be nearly horizontal (< 2 mm diameter), it is closing over < 2 mm span — comfortably within the 10 mm bridge limit.
3. The inner cavity is invisible and non-functional; minor drooping of the inner ceiling at the tip is acceptable for a decorative part.

**PASS** — inner bore closure is a tiny self-bridging dome with maximum unsupported span < 7 mm and final closure span < 2 mm.

---

## Tips & Extremities

### Hemisphere tip (z = 110.8–114.3 mm)

- Outer tip: 7 mm diameter sphere dome, 3.5 mm radius. Cross-section shrinks from 10 mm OD to a point.
- Wall thickness at tip equator: 1.5 mm (maintained throughout, per SCAD derivation above).
- The very last layer(s) near the pole: outer sphere cross-section at delta = 3.4 mm is ~7.1 mm OD, at delta = 3.5 mm the outer surface closes to a point. Near closure the wall converges from 1.5 mm to ~0 mm over a smooth curve — this is expected for a hemisphere tip and creates a smooth rounded finish rather than a flat top.
- Layer count in hemisphere: 3.5 mm / 0.2 mm = 17.5 layers → ~17 layers to close.

Risk: the final 2–3 layers of the hemisphere will be very small circles (< 2 mm diameter) and will be printed as tiny perimeter traces. The nozzle may not achieve full wall thickness on these micro-loops. However, the functional goal (a smooth rounded tip) is achievable, and any minor surface roughness at the very apex is cosmetically acceptable for a decorative part.

**Near limit — flag for test print.** See Test Print Recommendations.

### Star cutout points (all rows)

Star geometry: outer_r = 3.0 mm, inner_r = 3.0 × 0.38 = **1.14 mm**

The minimum material web between adjacent star points occurs at the inner circle:
> Web ≈ 2 × inner_r × sin(36°) = 2 × 1.14 × 0.588 = **1.34 mm**

This is the narrowest span of solid material between two adjacent star arms, measured at the inner vertex circle. The spec minimum wall is 1.2 mm.

> 1.34 mm > 1.2 mm minimum — **PASS by 0.14 mm margin.**

However: this 1.34 mm is a measurement in the plane of the 2D star shape, which is oriented perpendicular to the cone wall (it is extruded radially through the 1.5 mm wall). The "web" between star points is printed as a vertical wall segment of 1.34 mm width. At 0.4 mm nozzle / 3 perimeters = 1.2 mm minimum, this web is only 1.12 perimeters wider than the absolute minimum.

**Near limit — flag for test print.** Adequate but narrow margin (0.14 mm over minimum).

### Circle cutouts

Diameter = 3.5 mm through a 1.5 mm wall. The circle is extruded radially. The cone wall adjacent to each circle cutout is the standard 1.5 mm wall — no narrowing occurs at the circle edges (the circle is fully contained within the wall thickness).

**PASS** — no wall thinning, trivial geometry.

### Crescent moon cutouts

Geometry:
- r_outer = crescent_h / 2 = 2.5 mm
- r_inner = 2.5 × 0.75 = 1.875 mm
- offset_x = crescent_w × 0.35 = 3.5 × 0.35 = 1.225 mm

The crescent is formed by subtracting a circle of radius 1.875 mm offset 1.225 mm from the outer circle of radius 2.5 mm. The narrowest horn tips of the crescent occur at the intersection of the two circles.

Solving for intersection angle θ (circles at origin r=2.5 and at (1.225, 0) r=1.875):
> d² + r_inner² − r_outer² = 2 × d × x → x = (1.225² + 1.875² − 2.5²) / (2 × 1.225)
> x = (1.500 + 3.516 − 6.25) / 2.45 = −1.234 / 2.45 = −0.504 mm
> y = sqrt(2.5² − 0.504²) = sqrt(6.25 − 0.254) = sqrt(5.996) = 2.449 mm

The crescent horn tips are at (−0.504, ±2.449). The horn tip is a genuine point (zero width) in the 2D shape. In practice, at 0.4 mm nozzle, the horn tips will resolve to approximately 0.4 mm wide at the narrowest. This is below the 1.2 mm minimum wall threshold, but these are decorative cutout features in a 1.5 mm wall — the concern is not structural wall thickness but whether the slicer can resolve the fine horn tips as a through-hole.

The crescent cutout is extruded radially through the 1.5 mm wall. The slicer will see these as thin slots in the cone surface. The horn tips (< 0.4 mm) will likely not fully resolve as cutouts — they will fill in or be ignored by the slicer's minimum feature threshold. This means the printed crescent will have slightly blunted horn tips rather than sharp ones. Functionally and aesthetically, this is acceptable for a decorative feature.

**PASS (decorative, horn tips will blunt at sub-nozzle scale)** — no structural concern.

---

## Horizontal Spans

No geometry-report.json or slicer-report.json available; spans identified from SCAD analysis.

| Span | Description | Length | Result |
|---|---|---|---|
| Cone wall layers | Tapered cone — each layer is equal or smaller than previous | 0 mm overhang | PASS (functional taper) |
| Retention lip top face | 3 mm wide annular face at z = 5 mm (interior) | 3.0 mm | PASS (functional — lip grip surface) |
| Inner bore closure at hemisphere tip | Self-closing spherical dome, bore shrinks from 7 mm to 0 over 3.5 mm Z | < 7 mm max | PASS (functional — hollow hemisphere) |
| Cutout through-wall holes | Extruded radially through 1.5 mm wall — appear as vertical slots in each layer | 1.5 mm max | PASS (trivial, ≤ 1.5 mm) |

No flat horizontal bridges present. All spans are either tapered/shrinking (self-supporting) or through-wall holes that print as layer-by-layer cutouts.

The retention lip top face at z = 5 mm is a 3 mm wide annular ring on the *interior* of the cone. In print orientation, this face is horizontal, supported by the lip cylinder walls below it. It is not a bridge — it is a solid face printed on top of solid material.

**No avoidable bridges identified.** All horizontal surfaces are either functionally required or structurally supported.

---

## Mating Clearances

The spec.json does not define a mating part; clearance is described in requirements.md as a friction/clearance fit over the bottle neck.

| Feature | Part dim | Bottle neck | Gap | Role | Result |
|---|---|---|---|---|---|
| Base inner diameter | ID = 49.0 mm | ~41.3 mm (1.625" per eBay source) | 49.0 − 41.3 = 7.7 mm | Slide-over | PASS (ample clearance for fitment over globe) |
| Retention lip inner diameter | lip_id = 43.0 mm | ~41.3 mm bottle neck OD | 43.0 − 41.3 = 1.7 mm | Grip step | PASS (1.7 mm step provides light grip) |

Note: the bottle neck diameter is sourced from requirements.md ("1 5/8" ID" in eBay listing — this refers to the *cap* ID, meaning the bottle neck OD ≈ 41.3 mm). The base_id of 49 mm is sized for the globe body, not the bottle neck; the retention lip at 43 mm ID is the grip feature. The gap of 1.7 mm is per the design intent — "subtle step the bottle rim sits in."

No dimensional conflict detected. However, the actual bottle neck diameter is not directly measured (sourced from a third-party listing). If the bottle neck OD is larger than 43 mm, the retention lip would prevent fitting. **User should verify bottle neck OD against lip_id = 43 mm before printing.**

---

## Slicer Validation

Not available — slicer-report.json not present.

---

## Conflicts

No functional conflicts requiring user decision were identified.

The following observations are noted for awareness:
1. **Star point web width (1.34 mm):** Marginally above minimum wall (1.2 mm). No redesign recommended — it is above the threshold and is a decorative feature. Test print will validate.
2. **Crescent horn tips:** Sub-nozzle features will blunt. This matches or improves the expected visual output (sharp metal horn tips do not print well in FDM regardless). No fix needed.
3. **Bottle neck fit uncertainty:** Actual bottle neck OD is inferred, not measured. If the retention lip (ID = 43 mm) is too tight for the bottle neck, the user can adjust `lip_depth` to reduce the inward step. This is a dimensional uncertainty, not a printability conflict.

---

## Summary

- Data quality: SCAD source fallback (no mesh or slicer reports)
- Total transitions checked: 4
- PASS: 4
- FAIL: 0
- Slicer agreement: N/A
- Conflicts requiring user decision: 0

| Check | Result |
|---|---|
| Print orientation | PASS — base-down, optimal adhesion |
| Cone wall overhang (10.7° from vertical) | PASS — 79.3° from horizontal, well under 45° limit |
| Retention lip | PASS — on bed, zero overhang |
| Hemisphere tip (outer) | PASS — shrinking cross-section |
| Hemisphere tip (inner bore closure) | PASS — self-bridging dome, max span < 7 mm, final span < 2 mm |
| Wall thickness (1.5 mm throughout) | PASS — above 1.2 mm minimum |
| Star cutout web (1.34 mm) | PASS — above 1.2 mm minimum, narrow margin |
| Circle cutouts | PASS — trivial geometry |
| Crescent moon cutouts | PASS (decorative) — horn tips blunt at sub-nozzle scale |
| Horizontal spans / bridges | PASS — no avoidable bridges present |
| Build volume | PASS — 52 × 52 × 114.3 mm well within 256 × 256 × 256 mm |
| Mating fit | PASS — pending user verification of bottle neck OD |

**Overall: PASS — ready to slice and print.**

---

## Test Print Recommendations

- **Star cutout web geometry**: The minimum web between star points is 1.34 mm — only 0.14 mm above the 1.2 mm floor. At print scale this may barely resolve as three perimeters. Suggest cutting a 20 mm tall arc section at the Row 1 height (z ≈ 16.6 mm, widest cone diameter) — this gives the lowest row's star, circle, and crescent cutouts on the fullest wall area. Print it as a standalone arc slice (~5 mm arc × 20 mm tall × 1.5 mm wall) to confirm star arm webs print cleanly and circle/crescent holes fully resolve before committing to the full hat.

- **Hemisphere tip closure**: The final 4–5 layers of the rounded tip (z ≈ 112–114.3 mm) consist of very small circular cross-sections (< 3 mm OD). These micro-loops may not close cleanly at 0.4 mm nozzle. Suggest printing just the top 20 mm of the cone (z = 90–114.3 mm) as a standalone tip test piece to verify the hemisphere closes without a gap or blob at the apex.

- **Retention lip fit (functional)**: The retention lip ID = 43 mm should be verified against the actual bottle neck before printing the full hat. This is a quick dimensional check — measure the bottle neck OD with calipers. If > 43 mm, adjust `large_lip_depth` downward accordingly before the production print.
