# Humidity-Output V2 Requirements

## Design Intent

This part mounts a standard 4" flex dryer duct to a waffle-grid HDPE bin lid. It is a
permanent fixture: the base plate is caulked to the lid surface and the four Y-branch arms
lock into waffle channels on the lid underside. A cylindrical spigot rises from the center
of the base; the foil dryer duct slides over the spigot from above, butts up against the
lower stop ridge, and is sealed with a wrap of closed-cell EPDM foam tape in a groove on
the spigot exterior. A releasable zip tie cinches the duct over the foam, creating an
airtight, moisture-resistant connection that can be broken and re-made without tools.

V2 is a corrective redesign addressing three problems found in v1 printing and fitting:
1. Spigot OD was too large — duct wire rings (which define the duct ID) could not slide over.
2. No lead-in taper at the spigot top — duct starting position was hard to locate.
3. Internal fins started at z = 5mm (inner pad top) but the bore opened there too, leaving
   fin bottoms printing on air (unsupported first layers).

The base plate architecture, Y-branch geometry, foam groove, lower ridge, external shark
fins, and overall vertical stackup are carried forward from v1 unchanged except where
explicitly revised below.

---

## Print Orientation

- **Bed face:** Base plate bottom (z = 0) flat on the bed.
- **Growth direction:** +Z. Spigot top at z = 62mm.
- **Rationale:** The base plate is a large flat surface — ideal bed adhesion. Internal fins
  are vertical ribs; extending them to z = 0 means every fin layer prints on top of the
  previous one (no unsupported starts). The spigot taper at the top is a minor overhang
  printed last — no support needed at 20° from vertical.

---

## Dimensions & Sources

| Dimension | Value | Source |
|---|---|---|
| Duct tubing OD (measured) | 110 mm | User-provided (measured) |
| Duct wire ring thickness | ~1.2 mm | User-provided (observed) |
| Effective duct ring ID | 107.6 mm | Computed: 110 − 2 × 1.2 |
| Spigot OD (v2) | 106.0 mm | Computed — see Mating Interfaces |
| Spigot ID (bore) | 96.0 mm | Computed: 106 − 2 × 5 |
| Spigot wall thickness | 5.0 mm | Carried from v1; structural (clamp load) |
| Spigot height above base | 57.0 mm | Computed from stackup (z = 5 to z = 62) |
| Total part height (Z) | 62.0 mm | Carried from v1 stackup |
| Taper zone axial height | 8.0 mm | Specified — see Lead-In Taper |
| Taper tip OD | 100.0 mm | Computed — see Lead-In Taper |
| Taper tip wall thickness | 2.0 mm | Computed: (100 − 96) / 2; ≥ MIN_WALL ✓ |
| Lower stop ridge OD | 114.0 mm | Carried from v1 (114 > 107.6 duct ring ID ✓) |
| Lower stop ridge height (radial) | 3.0 mm | Carried from v1 |
| Lower stop ridge axial width | 4.0 mm | Carried from v1 |
| Lower stop ridge bottom (z) | 20.0 mm | Carried from v1 stackup |
| Foam groove axial width | 19.0 mm | Carried from v1 (matches 3/4" EPDM tape) |
| Foam groove depth | 2.5 mm | Carried from v1 |
| Foam zone bottom (z) | 24.0 mm | Carried from v1 stackup |
| Foam zone top (z) | 43.0 mm | Computed: 24 + 19 |
| Above-seal grip zone | 19.0 mm | Computed: 62 − 43; same as v1 |
| Internal fin count | 6 | Carried from v1 |
| Internal fin thickness (tangential) | 2.0 mm | Carried from v1 |
| Internal fin radial depth | 6.0 mm | Carried from v1 |
| Internal fin taper zone (top) | 10.0 mm | Carried from v1 |
| Internal fin start Z (v2) | 0.0 mm | Changed from v1 (was 5mm) — printability fix |
| External shark fin count | 6 | Carried from v1 |
| External shark fin thickness | 3.0 mm | Carried from v1 |
| External shark fin radial extent | 9.0 mm | Carried from v1 |
| External shark fin height | 13.0 mm | Computed: z_lower_ridge_bot − z_spigot_start − 2 = 20 − 5 − 2 |
| Waffle square size | 63.7 mm | Datasheet / measured from bin lid |
| Waffle channel width | 9.4 mm | Datasheet / measured from bin lid |
| Waffle square height | 4.6 mm | Datasheet / measured from bin lid |
| Waffle cutout (lid opening) | 136.8 mm | Computed: 2 × 63.7 + 9.4 |
| Frame outer size | 146.2 mm | Computed: 136.8 + 2 × 4.7 |
| Inner pad square side | 130.0 mm | Carried from v1 |
| Inner pad thickness (z) | 5.0 mm | Carried from v1 |
| Outer plate thickness | 4.6 mm | Carried from v1 (= waffle height) |
| Y-branch arm width | 9.0 mm | Carried from v1 |
| Y-branch engagement length | 25.0 mm | Carried from v1 |
| Y-branch root from origin | 73.1 mm | Computed: 136.8/2 + 9.4/2 |
| Total footprint X/Y | 196.0 mm | Computed: 2 × (73.1 + 25) ≈ 196.2mm (rounds to 196) |
| Corner radius (waffle) | 4.0 mm | Carried from v1 |
| Inner pad corner radius | 8.0 mm | Carried from v1 |
| Fin-wall overlap into spigot | 1.0 mm | Carried from v1 (avoids coincident face T-junction) |

---

## Features

### 1. Outer Plate
- **Purpose:** Wide flange that sits on top of the bin lid, distributes caulk adhesion area,
  provides visual coverage of the lid opening.
- **Critical dimensions:** 146.2 mm square, 4.6 mm thick. Corner radius 4 mm.
- **Mating interfaces:** Rests flat on bin lid surface. Caulked in place. No tolerance
  requirement beyond flatness (no mechanical fit).

### 2. Y-Branch Arms (4 sets, one per corner)
- **Purpose:** Engage into the waffle grid channels on the lid. Each corner fork sends one
  arm in the +X and one arm in the +Y direction into adjacent channels, locking the plate
  against lateral movement while caulk cures.
- **Critical dimensions:** Arm width 9.0 mm (channel width 9.4 mm, clearance fit:
  9.0 < 9.4 ✓). Engagement length 25 mm into each channel. Branch root center at ±73.1 mm.
- **Mating interfaces:** Slides into 9.4 mm wide waffle channels. Per-side clearance =
  (9.4 − 9.0) / 2 = 0.2 mm. Adequate for caulked installation; not a precision fit.

### 3. Inner Pad
- **Purpose:** Thickened central zone that raises the spigot base above the outer plate
  level, providing structural depth for the spigot junction and covering the bore opening
  in the lid.
- **Critical dimensions:** 130 mm square, 5.0 mm thick. Corner radius 8 mm.
- **Mating interfaces:** None (sits on lid, covered by caulk).

### 4. Spigot Body
- **Purpose:** Cylindrical sleeve that the 4" flex duct slides over. Houses the foam groove
  seal zone. Must be strong enough to survive releasable zip-tie clamping forces.
- **Critical dimensions:**
  - OD = 106.0 mm (see Mating Interfaces for derivation)
  - ID = 96.0 mm (bore)
  - Wall = 5.0 mm
  - Height = 57.0 mm (z = 5 to z = 62)
- **Mating interfaces:** Duct wire rings slide over spigot OD. See Mating Interfaces section.

### 5. Lead-In Taper (NEW in V2)
- **Purpose:** Guides the duct onto the spigot. The outer surface of the top 8 mm of the
  spigot tapers inward so the duct can locate easily without precise alignment.
- **Critical dimensions:**
  - Taper zone axial height: 8.0 mm (from z = 54 to z = 62)
  - OD at taper base (z = 54): 106.0 mm (full spigot OD)
  - OD at taper tip (z = 62, top face): 100.0 mm
  - Wall at taper tip: (100.0 − 96.0) / 2 = 2.0 mm ≥ MIN_WALL (1.2 mm) ✓
  - Taper half-angle: arctan((106 − 100) / 2 / 8) = arctan(3/8) ≈ 20.6° from vertical.
    Well within 45° limit — no support needed.
- **Mating interfaces:** Outer taper surface contacts duct wire rings only during initial
  insertion; no sustained load.

### 6. Lower Stop Ridge
- **Purpose:** Hard stop that prevents the duct from sliding further down the spigot than
  the designed insertion depth. Ridge OD exceeds duct ring ID so wire rings cannot pass.
- **Critical dimensions:**
  - OD = 114.0 mm (= spigot OD + 2 × 3 mm protrusion = 106 + 8 = 114 mm ✓)
  - Underside: 45° chamfer from spigot OD up to ridge OD (self-supporting, no overhang)
  - Top face: flat cylinder at ridge OD, axial width = 4.0 mm total
  - Z position: bottom at z = 20 mm, top at z = 24 mm
- **Mating interfaces:** Duct wire ring seats against ridge at z = 20 mm. Ridge OD 114 mm
  vs. duct ring ID 107.6 mm — 6.4 mm total diametric clearance above ridge face (duct
  stops against bottom of ridge, not constrained radially).

### 7. Foam Groove
- **Purpose:** Annular channel that recesses the EPDM foam tape into the spigot wall so
  the foam is retained in position before the duct is installed and so the foam-filled groove
  presents a flat clamping surface to the zip tie.
- **Critical dimensions:**
  - Depth: 2.5 mm into spigot OD surface
  - Axial width: 19.0 mm (matches 3/4" = 19.05 mm foam tape width)
  - Z position: z = 24 mm (bottom) to z = 43 mm (top)
  - Wall at groove bottom: (106/2 − 2.5) − (96/2) = 53 − 2.5 − 48 = 2.5 mm ≥ MIN_WALL ✓
- **Mating interfaces:** Accepts closed-cell EPDM foam, 3/4" wide × 1/8" (3.2 mm) thick.
  Groove depth 2.5 mm leaves foam proud by ~0.7 mm before zip-tie clamping. Groove bottom
  radius = 50.5 mm; foam compressed OD ≈ 106 mm when clamped.

### 8. External Shark Fins (6×)
- **Purpose:** Triangular gussets at the spigot-to-inner-pad junction. Resist tipping load
  on the spigot and serve as visual alignment markers. One fin per internal fin, same angular
  positions.
- **Critical dimensions:**
  - Tangential thickness: 3.0 mm
  - Radial extent at base: 9.0 mm (from spigot OD surface outward)
  - Height: 13.0 mm (z = 5 to z = 18; stays 2 mm below lower ridge bottom at z = 20)
  - Profile: right triangle in r-z plane; vertical inner edge, sloped hypotenuse
  - Overhang: arctan(13/9) ≈ 55° from horizontal = 35° from vertical — within 45° limit ✓
- **Mating interfaces:** None (structural, no mate).

### 9. Internal Fins (6×) — REVISED Z START
- **Purpose:** Radial ribs projecting inward from the bore wall. Resist bore ovalization
  under zip-tie clamping load. Aligned with external shark fins.
- **Critical dimensions:**
  - Tangential thickness: 2.0 mm ≥ MIN_WALL ✓
  - Radial depth: 6.0 mm (full depth) + 1.0 mm overlap into spigot wall
  - Z start (v2): **z = 0.0 mm** (base plate bottom) — changed from v1's z = 5 mm
  - Z for full-depth: z = 0 to z = 52 mm (z_spigot_top − fin_int_taper_z = 62 − 10 = 52)
  - Taper zone: z = 52 to z = 62 mm — fin depth tapers from 6 mm down to 0 (flush with bore)
  - Each fin layer prints on top of the previous; no unsupported first layer
- **Mating interfaces:** None (structural, no mate).

---

## Mating Interfaces

### Spigot OD → Duct Wire Rings (Primary Fit)

| Parameter | Value | Notes |
|---|---|---|
| Measured duct ring OD | 110.0 mm | User-provided |
| Wire ring thickness | 1.2 mm | User-provided |
| Effective duct ring ID | 107.6 mm | 110 − 2 × 1.2 |
| Fit type | Clearance | Duct slides over; real seal from foam+zip tie |
| FDM clearance offset (per side) | +0.25 mm | FDM_CLEARANCE_FIT constant |
| Computed spigot OD (clearance only) | 107.1 mm | 107.6 − 2 × 0.25 |
| Design choice: additional margin | −1.1 mm diametric | Per user guidance to err toward clearance |
| **Spigot OD (v2 final)** | **106.0 mm** | 107.6 − 1.6 total diametric gap |
| Per-side radial gap | 0.8 mm | (107.6 − 106.0) / 2 |
| Result | Comfortable clearance | Duct slides on without force; foam+zip tie provides seal |

Rationale for 106 mm rather than 107.1 mm: The duct wire ring ID measurement (107.6 mm) is
derived from the OD (110 mm) minus twice the ring thickness — a field measurement subject to
variation. A 0.5 mm total gap (FDM clearance only) risks binding if wire rings vary by even
0.3 mm. At 106 mm, the 1.6 mm total diametric gap absorbs ring-to-ring variation and
FDM dimensional error without risking a tight fit. The seal is entirely provided by the
foam groove + zip tie, not by the spigot-to-duct diameter relationship.

### Lower Ridge → Duct Wire Ring (Hard Stop)

| Parameter | Value | Notes |
|---|---|---|
| Ridge OD | 114.0 mm | 106 + 2 × 4 mm protrusion |
| Duct ring ID | 107.6 mm | Measured |
| Diametric interference | 6.4 mm | Ridge OD − duct ring ID; wire ring cannot pass |
| Function | Physical stop | Duct end seated at z = 20 mm |

### Y-Branch Arms → Waffle Channels (Caulked Engagement)

| Parameter | Value | Notes |
|---|---|---|
| Channel width | 9.4 mm | Measured from bin lid |
| Arm width | 9.0 mm | Design value |
| Per-side gap | 0.2 mm | (9.4 − 9.0) / 2 |
| Fit type | Loose clearance (caulked) | Arms located by caulk, not press fit |

---

## Material & Tolerances

- **Material:** PLA, Bambu Lab X1 Carbon, 0.4 mm nozzle, 0.2 mm layer height.
- **Default dimensional tolerance:** ±2.0 mm on overall footprint (XY). ±1.0 mm on Z height.
- **Bore diameter tolerance:** ±0.5 mm (bore is airflow passage, not a precision fit).
- **Spigot OD tolerance:** ±0.3 mm acceptable (fit is loose-clearance, not precision).
- **Foam groove tolerance:** ±0.2 mm on depth (groove must reliably recess the foam).
- **No critical interference fits** in this design — all mating surfaces are clearance or
  caulked.

---

## Constraints

- Build volume: 256 × 256 × 256 mm. Part footprint 196 × 196 × 62 mm — fits with margin ✓
- Minimum wall thickness: 1.2 mm (3 perimeters). Thinnest wall is taper tip = 2.0 mm ✓
- Minimum floor/ceiling: 0.8 mm (4 layers). Outer plate floor = 4.6 mm ✓
- No supports required (all features self-supporting — verified per feature above).
- Part must be watertight (manifold mesh) for slicing and moisture resistance.

---

## Printability Pre-Screen

| Feature | Check | Result |
|---|---|---|
| Outer plate | Floor thickness 4.6 mm | PASS (≥ 0.8 mm) |
| Y-branch arms | Width 9.0 mm; thin-wall check | PASS (≥ 1.2 mm) |
| Spigot wall | 5.0 mm at thinnest (full height) | PASS |
| Spigot wall at foam groove | 2.5 mm | PASS (≥ 1.2 mm) |
| Spigot taper tip wall | 2.0 mm | PASS (≥ 1.2 mm) |
| Taper half-angle | 20.6° from vertical | PASS (< 45°) |
| External shark fins | 13/9 = 55° from horizontal = 35° from vertical | PASS (< 45°) |
| External shark fins | Thickness 3.0 mm | PASS (≥ 1.2 mm) |
| Internal fin thickness | 2.0 mm | PASS (≥ 1.2 mm) |
| Internal fins Z start | z = 0 (v2) — on build plate | PASS — v1 bug FIXED |
| Internal fin taper | Tapers outward at top; each layer supported by previous | PASS |
| Lower ridge | 45° chamfer on underside | PASS (self-supporting) |
| Foam groove | Recess into spigot OD — supported from below | PASS |
| Bridge spans | No horizontal unsupported spans (all are cylindrical or have walls below) | PASS |
| Overall height 62 mm | Within 256 mm build height | PASS |
| Overall footprint 196 × 196 mm | Within 256 × 256 mm bed | PASS |

No features require support structures. No flags for the print-reviewer beyond noting that
external shark fins at 55° from horizontal are at the steep end of the acceptable range —
the print-reviewer should verify the slicer does not add support there.

---

## V1 → V2 Change Summary

| Item | V1 | V2 | Reason |
|---|---|---|---|
| Spigot OD | 108.0 mm | 106.0 mm | Duct wire rings could not slide over at 108 mm |
| Spigot ID | 98.0 mm | 96.0 mm | Follows from OD change, wall stays 5 mm |
| Lead-in taper | None | 8 mm zone, 106→100 mm OD | Ease of duct installation |
| Internal fin Z start | z = 5.0 mm (inner pad top) | z = 0.0 mm (bed) | Unsupported first layers in v1 |
| Params file | `humidity-output-params.scad` | `humidity-output-v2-params.scad` | New self-contained params |
| Everything else | — | Unchanged | Base plate, Y-branches, foam groove, ridges, shark fins all worked well |
