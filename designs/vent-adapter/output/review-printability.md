# Printability Review: vent-adapter

**Date:** 2026-03-15
**Printer:** Bambu Lab X1C (0.4 mm nozzle, 0.2 mm layer height, PLA)

---

## Part Summary

A hollow truncated cone (frustum) that adapts between two duct diameters.

| Parameter | Value |
|---|---|
| Bottom OD | 100 mm |
| Bottom ID | 96 mm |
| Top OD | 75 mm |
| Top ID | 71 mm |
| Wall thickness | 2.0 mm |
| Height | 80 mm |

---

## Step 1 -- Print Orientation

**Print orientation: large (100 mm) end on the build plate, small (75 mm) end pointing up.**

This is the natural orientation from the SCAD file: the cylinder is constructed with `r1=bottom_r` (50 mm) at Z=0 and `r2=top_r` (37.5 mm) at Z=80. The large end sits flat on the bed.

Features grow upward from the 100 mm base ring toward the 75 mm top ring, tapering inward as Z increases.

---

## Step 2 -- Features in Print-Z Order (bed to tip)

1. **Bottom annular ring** (Z=0): The first layer is a flat annulus, OD=100 mm, ID=96 mm, wall=2.0 mm.
2. **Tapered conical wall** (Z=0 to Z=80): A smooth cone shell that tapers linearly from OD=100 mm to OD=75 mm. The inner surface tapers from ID=96 mm to ID=71 mm. Wall thickness remains 2.0 mm throughout.
3. **Top annular edge** (Z=80): The final layer is a flat annulus, OD=75 mm, ID=71 mm, wall=2.0 mm.

That is the complete feature list. There are no ribs, fins, clips, ledges, stops, spigots, or other features.

---

## Step 3 -- Feature-to-Feature Transitions

There is only one transition to check, since the part is a single smooth taper with no step changes.

### Transition 1: Bottom annular ring (Z=0) to tapered conical wall (Z=0+)

The wall tapers inward smoothly. Per layer, the radius decreases linearly.

**Outer wall taper angle calculation:**
- Outer radius change: 50 mm - 37.5 mm = 12.5 mm inward over 80 mm height.
- Horizontal step per layer (0.2 mm): 12.5 / (80 / 0.2) = 12.5 / 400 = 0.03125 mm per layer.
- This is a taper inward (each layer is smaller than the one below), so it is fully supported by the layer below. No overhang at all on the outer surface.

**Inner wall taper angle calculation:**
- Inner radius change: 48 mm - 35.5 mm = 12.5 mm inward over 80 mm height.
- The inner surface also tapers inward (gets smaller radius) as Z increases.
- Each inner layer circle is smaller than the one below, meaning the inner opening gets narrower.
- The inner wall's overhang: horizontal step inward per layer = 12.5 / 400 = 0.03125 mm per layer.
- Since the inner wall steps inward (wall moves toward center), the upper layer's inner edge is supported by the wall material of the layer below. No unsupported overhang.

**Result: PASS.** Both inner and outer surfaces taper inward (toward center) as height increases. Every layer is fully contained within (or equal to) the XY footprint of the layer below. Zero overhang.

### No other transitions exist

The part has no step changes, no protrusions, and no sudden diameter changes. The single linear taper from bottom to top is the only geometric transition.

**Transitions checked: 1**
**All transitions: PASS**

---

## Step 4 -- Tips and Extremities

**Top edge (Z=80):** The top of the cone is an open annular ring, 2.0 mm wall. This is not a cantilevered tip; it is the terminal layer of a smoothly tapered wall. The wall thickness (2.0 mm) is well above the minimum (1.2 mm). No hook, tab, ledge, or snap-fit features exist.

**Bottom edge (Z=0):** Flat ring sitting on the bed. No concerns.

**Result: PASS.** No tips or extremities at risk.

---

## Step 5 -- Horizontal Spans

The part has **no horizontal surfaces** at all (aside from the bottom first layer on the bed). There are no bridges, no ceilings, no shelves. The top of the cone is an open hole, not a closed span.

- Bottom first layer: solid annulus on bed. Not a bridge. **PASS.**
- No internal bridges or ceilings anywhere in the geometry.

**Result: PASS.** No unsupported horizontal spans.

---

## Step 6 -- Mating Part Clearance

The spec describes this as an adapter connecting two duct diameters. The SCAD source does not include any spigots, interference ridges, or press-fit features -- the part is a plain smooth-walled cone.

**Bottom end (100 mm OD, 96 mm ID):** A duct would either insert into the bore (duct OD < 96 mm) or slide over the outside (duct ID > 100 mm). With the current plain cone, there is no hard stop or friction feature to retain the duct -- it is a simple slip fit.

**Top end (75 mm OD, 71 mm ID):** Same situation -- plain smooth wall, no retention features.

No protrusion vs. mating-part dimension conflicts exist because no protrusions exist. The fit behavior depends on the actual duct dimensions, which are not specified in the current design.

**Result: PASS (no protrusions to check).** Note: the design currently has no retention features. Whether this is intentional (tape/clamp connection) or an omission is a design decision, not a printability issue.

---

## Additional Checks

### Wall Thickness
- 2.0 mm throughout >= 1.2 mm minimum. **PASS.**

### Build Volume
- Part footprint: 100 mm diameter, 80 mm tall.
- 100 x 100 x 80 mm << 256 x 256 x 256 mm build volume. **PASS.**

### First Layer Adhesion
- Bottom annular ring: OD=100 mm, ID=96 mm, wall=2.0 mm.
- Annular contact area: pi * (50^2 - 48^2) = pi * (2500 - 2304) = pi * 196 = 615.75 mm^2.
- This is adequate for bed adhesion. A brim may still be advisable for a tall thin-walled cone to prevent warping/lifting, but this is a slicer setting, not a geometry issue.

---

## Overall Verdict

**PASS**

This is a geometrically simple part with no printability concerns. The smooth inward taper means every layer is fully supported by the layer below. There are no overhangs, no bridges, no tips, no protrusions, and no step transitions. Wall thickness is well above minimum.

| Check | Result |
|---|---|
| Print orientation | Large end down (natural) |
| Transitions checked | 1 |
| Transitions passed | 1 |
| Tips/extremities | PASS (none at risk) |
| Horizontal spans | PASS (none exist) |
| Mating clearance | PASS (no protrusions) |
| Wall thickness | PASS (2.0 mm >= 1.2 mm) |
| Build volume | PASS (100x100x80 mm) |
| **Overall** | **PASS** |
