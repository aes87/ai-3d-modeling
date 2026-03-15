# Spigot Arc — Duct Fitment & Seal Zone Requirements

## Parent Design
humidity-output-v2 — see `designs/humidity-output-v2/requirements.md`

## Purpose
Verify the three most critical questions before committing to a 4+ hour full print:

1. **Spigot OD fitment**: Does the 106mm spigot OD provide reliable clearance for duct wire rings (107.6mm ID)? V1 failed at 108mm — this is the first print at the corrected diameter.
2. **Foam groove dimensions**: Does the 2.5mm-deep, 19mm-wide groove correctly recess 3/4" closed-cell EPDM foam tape? This is the tightest tolerance in the design (+/-0.2mm on depth).
3. **Ridge chamfer printability**: Does the 45-degree lower stop ridge chamfer (exactly at the overhang limit) print cleanly without drooping or support artifacts?

Secondary checks: lead-in taper OD (100mm at tip), taper tip wall thickness (2.0mm), wall thickness at foam groove bottom (2.5mm).

## Verification Method
1. **Caliper spigot OD** at the arc midpoint (z ~35mm) on the outer surface — expect 106.0 +/-0.3mm
2. **Caliper foam groove depth** — measure from spigot OD surface to groove floor — expect 2.5 +/-0.2mm
3. **Caliper foam groove width** — axial measurement across groove — expect 19.0 +/-0.5mm
4. **Trial fit with duct**: slide an actual duct wire ring over the arc section — the ring should pass over the spigot OD with light clearance and physically stop against the lower ridge
5. **Seat foam tape** in the groove — tape should recess below the spigot OD surface
6. **Visual check**: inspect ridge chamfer underside for droop, stringing, or support scars

## Geometry
Extract a 90-degree arc sector (first quadrant, 0 to 90 degrees) of the spigot cylinder from z=0 to z=62mm. Include:

- **Spigot wall** at full OD (106mm) and wall thickness (5mm)
- **Lead-in taper** at top (z=54–62, OD 106 to 100mm)
- **Lower stop ridge** (z=20–25, OD 114mm, with 45-degree underside chamfer)
- **Foam groove** (z=25–44, 2.5mm deep recess)
- **Above-seal grip zone** (z=44–54, plain spigot at full OD)
- **One internal fin** within the arc sector (for representative wall behavior)
- **Base plate**: 3mm-thick flat rectangular slab at z=0, extending to at least the ridge radius (57mm) in both X and Y, for bed adhesion
- **Chord walls**: 2mm-thick flat walls closing the two cut faces of the arc sector

Do NOT include: outer plate frame, Y-branch arms, inner pad (beyond what's needed for the base), external shark fins, or any features outside the 90-degree sector.

## Critical Dimensions
| Dimension | Nominal | Tolerance | How to verify |
|---|---|---|---|
| Spigot OD | 106.0 mm | +/-0.3 mm | Calipers on arc outer surface |
| Foam groove depth | 2.5 mm | +/-0.2 mm | Calipers: OD surface to groove floor |
| Foam groove width (axial) | 19.0 mm | +/-0.5 mm | Calipers across groove |
| Lower ridge OD | 114.0 mm | +/-0.5 mm | Calipers on ridge outer surface |
| Taper tip OD | 100.0 mm | +/-0.5 mm | Calipers at z=62 |
| Wall at groove bottom | 2.5 mm | +/-0.3 mm | Calipers (groove floor to bore) |
| Taper tip wall | 2.0 mm | +/-0.3 mm | Calipers at z=62 |

## Parameters
Use parent parameters from `scad-lib/humidity-output-v2-params.scad` — do not hardcode duplicates.
All spigot dimensions, z-stackup positions, groove dimensions, ridge dimensions, taper dimensions,
and fin dimensions should reference the `ho2_*` parameter names.

## Constraints
- Minimize material — this is a test piece, not the final part
- Must print flat on bed without supports (base plate at z=0 on bed)
- Keep all critical dimensions at full scale — no scaling
- Arc sector angle: 90 degrees (sufficient for OD caliper measurement and duct ring trial fit)
- Estimated print time: ~30 minutes (vs 4+ hours for full part)
- Estimated material: ~10-15g PLA
