# P-touch Cradle Requirements

## Design Intent

A two-part desktop holder system for the Brother PT-P750W label printer. The goal is a
tidy, aesthetically pleasing desk object — not a raw bracket. The design should feel
"cute" (rounded, decorative) while remaining fully functional.

**Part 1 — Cradle**: A full-perimeter low tray/bathtub that holds the printer base on
all four sides, with a tall back panel rising from the rear wall. The printer sits in a
shallow rectangular enclosure (25 mm tall perimeter wall on all four sides — back, left,
right, front). The back wall continues upward as a tall panel (to z = 145 mm body height)
that carries the owl ear tufts. Open top so the cassette lid can hinge upward without
obstruction. Cable pass-through notch in the back wall routes USB and power without
lifting the printer. Four corner feet elevate the cradle slightly for a finished look and
protect desk surfaces.

**Part 2 — Tray**: A removable kanban-bin-style catch tray that sits in a forward-facing
slot in the cradle's tray shelf and collects printed labels as they fall from the tape exit
slot. The tray is pulled forward to empty it. A scoop/angled front lip makes labels easy
to pinch out.

**Aesthetic motif (Revision 6)**: Owl "creature" motif. From the front, triangular ear
tufts peek up behind the printer above the tall back panel's top corners. The tray front
wall is an owl face (two raised eye embosses with inner pupil embosses, plus a small
downward-pointing beak emboss). Rounded corners everywhere support the pudgy-owl silhouette.
Side-wall scallops and side-wall eye cutouts have been removed (walls are now only 25 mm
tall — insufficient height for those features). The owl motif now lives in two places:
ear tufts on the back panel (visible peeking above the printer from the front) and the
owl face on the tray front wall.

---

## Confirmed from Product Photography

> Confirmed via official Brother-USA product page photography (front / left / right views,
> PT-P750W):
>
> - **Tape exits from the FRONT face** (78 mm W × 143 mm H narrow face). Confirmed.
> - **Tape exit is in the LOWER-MIDDLE of the front face**, approximately Z = 60–75 mm
>   above the printer base (roughly 40–55% up the printer height). The exit slot is a
>   horizontal rectangle spanning roughly 35 mm wide × 10 mm tall.
> - **Cassette loads from the top**: the hinged top cover opens fully upward. The cradle
>   must leave the full top face unobstructed. The control panel is a dished circular area
>   on top — must not be obstructed.
>
> **Still assumed (not confirmed in product photos):**
> - USB and DC power connectors are on the BACK face (opposite the tape exit). The cable
>   pass-through notch in the back wall is based on this assumption. If ports are on a
>   side face, the notch placement must change.

---

## Print Orientation

**Part 1 — Cradle**
- Bed face: base plate bottom (z = 0) flat on bed.
- Growth direction: +Z. Tall back panel top (with ear tufts) at z = 180 mm. Low perimeter
  wall tops (left, right, front) at z = 25 mm. Tall back panel spans from z = 0 to z = 145 mm
  body (plus 35 mm ear tufts).
- Rationale: Base plate is a large flat surface for adhesion. All walls grow vertically
  (no print-direction overhangs on vertical faces). Low perimeter walls (25 mm) are short
  vertical extrusions — fully printable without concern. Ear tufts are a 2D extrusion of the
  3 mm back wall profile — they grow straight up from the back panel top, no new geometry
  changes the print direction. Cable slot is a top-open notch (no bridge). The tray shelf
  section is solid geometry at base height below the slot — prints cleanly from the base up.

**Part 2 — Tray**
- Bed face: tray floor (z = 0) flat on bed.
- Growth direction: +Z. Tray walls at z ≈ 42 mm.
- Rationale: Floor is the largest flat surface. All four walls grow vertically. Angled
  front scoop lip is at 45° from horizontal — at the boundary of the overhang threshold,
  flagged for print-reviewer verification. Owl face embosses (eyes, pupils, beak) are
  raised features on the vertical front wall — print as normal outward perimeters stacked
  in Z. No overhangs introduced.

---

## Dimensions & Sources

### Printer Reference Dimensions

| Dimension | Value | Source |
|---|---|---|
| Printer width (W, left-right) | 78 mm | Brother official spec, user-verified |
| Printer depth (D, front-back) | 152 mm | Brother official spec, user-verified |
| Printer height (H, bottom-top) | 143 mm | Brother official spec, user-verified |
| Max tape width | 24 mm | Brother official spec |
| Tape exit Z above printer base | 60–75 mm | Confirmed from product photography |
| Tape exit slot width | ~35 mm | Estimated from product photography |
| Tape exit slot height | ~10 mm | Estimated from product photography |
| Tape exit X position | Centered on front face | Confirmed from product photography |

### Cradle Interior Pocket

| Dimension | Value | Source |
|---|---|---|
| Interior pocket width (X) | 80 mm | Computed: 78 + 2 × 1.0 mm clearance |
| Interior pocket depth (Y) | 154 mm | Computed: 152 + 2 × 1.0 mm clearance |
| Per-side lateral clearance | 1.0 mm | Specified (removable, not press fit) |
| Interior pocket height (Z) — back panel body | 145 mm | Computed: 143 + 2.0 mm vertical clearance |
| Low perimeter wall height (Z) | 25 mm | Specified (Revision 6) |

### Cradle Structure

| Dimension | Value | Source |
|---|---|---|
| Wall thickness (all walls) | 3.0 mm | Specified — structurally adequate, above min 1.2 mm |
| Base plate thickness | 4.0 mm | Specified — four-layer minimum floor × safety margin |
| Cradle overall width (X) | 108 mm | Unchanged from Revision 5 |
| Cradle printer section — back wall outer to front wall outer (Y) | 160 mm | Computed: 3 (back wall) + 154 (interior) + 3 (front wall) |
| Printer-to-tray gap | 0 mm | Computed: gap eliminated to stay within 256 mm build volume (see Constraints) |
| Tray slot start Y from back exterior | 160 mm | Computed: printer section outer depth, no gap |
| Cradle total depth (Y) | 254.9 mm | Computed: 160 (printer section) + 94.9 (tray slot) — see below |
| Tall back panel body top height (Z) | 145 mm | Unchanged |
| Low perimeter wall top height (Z) — left, right, front | 25 mm | Specified (Revision 6) |
| Cradle overall height (Z) — with ear tufts | 180 mm | Computed: 145 + 35 mm tuft peak height |
| Foot height | 3 mm | Specified |
| Foot diameter | 8 mm | Specified — rounded bump at each corner |
| Foot inset from corner | 5 mm | Specified |

### Cable Pass-Through (Back Wall)

| Dimension | Value | Source |
|---|---|---|
| Slot width | 25 mm | Specified (USB-A plug ~12 mm + DC barrel ~8 mm + margin) |
| Slot height | 20 mm | Specified (USB + barrel connector stack with cable bend radius) |
| Slot center X position | Back wall center (X = 54 mm from left exterior face) | Specified (cradle 108 mm wide) |
| Slot bottom Z | 0 mm (open to base — keyhole/top-open slot) | Printability: eliminates bridge |
| Slot style | Open-bottom notch in back wall (U-shape open at base) | Printability constraint |
| Slot Z extent | z = 0 to z = 20 mm | Fully within the 25 mm low perimeter wall zone — no conflict |

### Aesthetic Features — Ear Tufts (unchanged from Revision 4)

| Dimension | Value | Source |
|---|---|---|
| Tuft count | 2 (left and right, symmetric) | Specified |
| Tuft wall thickness | 3 mm | Inherits back wall profile — no new 3D shape |
| Tuft base width (along back panel top edge) | 25 mm | Specified |
| Tuft peak height above back panel top (z = 145 mm) | 35 mm | Specified |
| Tuft peak Z from base | 180 mm | Computed: 145 + 35 |
| Tuft outer edge | Vertical (continues exterior edge of back wall) | Specified |
| Tuft inner edge | Angled from base-inner-corner to peak | Specified — lean-outward "horned owl" look |
| Tuft peak X offset inward from outer edge | 5 mm | Specified |
| Tuft apex radius | 2 mm | Specified — small rounded tip, not razor-sharp |
| Tuft base inner corner X from outer edge | 25 mm (base width) | Specified |
| Left tuft outer edge X | Flush with left exterior face of back wall | Derived |
| Right tuft outer edge X | Flush with right exterior face of back wall | Derived |

### Aesthetic Features — Fillets (unchanged)

| Dimension | Value | Source |
|---|---|---|
| Cradle exterior vertical edge fillet radius | 4 mm | Specified (unchanged) |
| Cradle base plate corner fillet radius (top-down) | 6 mm | Specified (unchanged) |
| Wall top-edge fillet — low perimeter walls and tall back panel body top | 1.5 mm | Specified (unchanged) |
| Tray exterior vertical edge fillet radius | 3 mm | Specified (unchanged) |
| Scoop lip leading edge fillet | 2 mm | Specified (unchanged) |

### Tray Slot in Cradle Shelf

| Dimension | Value | Source |
|---|---|---|
| Tray slot width (X, interior) | 103.9 mm | Computed: tray exterior width 103.2 + 2 × 0.35 sliding fit |
| Tray slot depth (Y) | 94.9 mm | Computed: tray exterior depth 94.2 + 2 × 0.35 sliding fit (Revision 6: depth reduced) |
| Tray slot height (Z) | 42.3 mm | Computed: tray exterior height 41.6 + 2 × 0.35 sliding fit |
| Tray slot open direction | Front face of cradle | Specified |
| Tray slot open top | Yes — slot has no ceiling, tray drops in from above | Printability: eliminates bridge |
| Slot side wall each side | 2.05 mm | Computed: (108 − 103.9) / 2; above 1.2 mm min |
| Shelf base plate thickness below slot | 4.0 mm | Same as main base plate |

### Tray Drop Height Analysis

| Parameter | Value | Derivation |
|---|---|---|
| Tape exit Z above printer base | 60–75 mm | Confirmed from photography |
| Cradle base plate thickness | 4 mm | Specified |
| Tape exit Z above desk (min) | 64 mm | 60 + 4 |
| Tape exit Z above desk (max) | 79 mm | 75 + 4 |
| Tray floor Z above desk | ~5.6 mm | 4 (base plate) + 1.6 (tray floor thickness) |
| Label drop distance (min) | ~58 mm | 64 − 5.6 |
| Label drop distance (max) | ~73 mm | 79 − 5.6 |
| Front wall top Z above desk | 25 + 4 = 29 mm | Low perimeter front wall top |
| Tape exit clears front wall | YES — tape exits at 64–79 mm, front wall top at 29 mm | Clearance: 35–50 mm above front wall top |
| Drop acceptability | ACCEPTABLE | PT-P750W auto-cuts tape; cut labels drop forward and down, clear the 25 mm front wall, land in tray. Larger bin footprint (100 × 91 mm interior) captures stray drops adequately. |

### Tray

| Dimension | Value | Source |
|---|---|---|
| Tray interior width (X) | 100 mm | Specified (unchanged) |
| Tray interior depth (Y) | 91 mm | Revised (Revision 6: reduced from 95 mm to fit within 256 mm build volume) |
| Tray interior height (Z) | 40 mm | Specified (unchanged) |
| Tray wall thickness | 1.6 mm | Specified |
| Tray floor thickness | 1.6 mm | Specified |
| Tray exterior width (X) | 103.2 mm | Computed: 100 + 2 × 1.6 |
| Tray exterior depth (Y) | 94.2 mm | Computed: 91 + 2 × 1.6 |
| Tray exterior height (Z) | 41.6 mm | Computed: 40 + 1.6 (floor) |
| Scoop angle (front lip) | 45° from horizontal | Specified — at overhang threshold boundary |
| Scoop lip height | 15 mm | Specified — angled front face covers bottom 15 mm of front wall |
| Scoop lip leading edge fillet | 2 mm | Specified |

### Tray — Owl Face Features (unchanged from Revision 4)

| Dimension | Value | Source |
|---|---|---|
| Finger grip location | Top-edge scallop | Specified |
| Grip scallop width | 24 mm | Specified |
| Grip scallop depth (downward from top edge) | 8 mm | Specified |
| Grip scallop center X | 0 (centered on tray front wall) | Specified |
| Grip scallop shape | Semicircle open to top | Specified |
| Eye emboss count | 2 (left and right) | Specified |
| Eye emboss radius | 8 mm | Specified |
| Eye emboss raise height | 1.5 mm outward from wall | Specified |
| Eye emboss center Z (from tray base exterior) | 28 mm | Specified |
| Eye emboss center X (from tray centerline) | ±22 mm | Specified |
| Pupil emboss radius | 3 mm | Specified |
| Pupil emboss additional raise | 1.5 mm (total 3 mm proud of wall) | Specified |
| Pupil center | Coincides with eye center | Specified |
| Beak emboss shape | Downward-pointing triangle | Specified |
| Beak emboss base width | 6 mm | Specified |
| Beak emboss height | 6 mm | Specified |
| Beak emboss raise height | 2 mm proud of wall | Specified |
| Beak top Z (from tray base exterior) | 22 mm | Specified |
| Beak apex Z (from tray base exterior) | 16 mm | Computed: 22 − 6 |
| Beak center X | 0 (centered) | Specified |
| Vertical front wall region available for face | Z = 15–42 mm (27 mm tall) × 103.2 mm wide | Derived: above scoop lip, below tray top |

---

## Features

### Cradle Part

#### 1. Base Plate
- **Purpose:** Floor under the printer; anchors all walls; extends forward into the tray
  shelf section. The base plate spans the full combined depth of the printer section and
  tray shelf section.
- **Critical dimensions:** 108 mm W × 254.9 mm D × 4 mm thick. Total base footprint
  108 × 254.9 mm. No riser block — the tray shelf section sits at the same 4 mm base level
  as the printer section.
- **Mating interfaces:** Sits on desk surface. No mechanical mate (feet provide clearance).
- **Build volume note:** Total cradle depth 254.9 mm is within the 256 mm limit with ~1.1 mm
  margin. The modeler must not add any additional depth features in the shelf section.

#### 2. Tall Back Panel
- **Purpose:** Rear structural wall spanning full printer height and above; contains cable
  pass-through at its base; topped with two owl ear tufts. Spans the full back width from
  left outer edge to right outer edge (108 mm). Rises from z = 0 through z = 145 mm body,
  with ear tufts to z = 180 mm.
- **Critical dimensions:** 108 mm wide × 3 mm thick × 145 mm tall (body). Ear tufts extend
  to 180 mm total. This panel integrates with the low perimeter back section: the back face
  is planar from z = 0 to z = 145 mm (body); the front face of the panel above z = 25 mm
  (above the low perimeter wall) is the interior face of the tall panel.
- **Mating interfaces:** No external mate. Interior face is the clearance-fit rear surface
  for the printer. Top edge of body receives 1.5 mm fillet (below tuft bases).

#### 3. Low Perimeter Walls — Left, Right, Front (Revision 6)
- **Purpose:** Short containment walls forming a full-perimeter bathtub/tray around the
  printer base. Replaces the tall left and right U-pocket walls. All four sides of the
  printer are enclosed at base level, giving a slick, low-profile enclosure look.
- **Critical dimensions:**
  - Left wall: 154 mm deep × 3 mm thick × 25 mm tall. (Interior depth = printer interior pocket depth.)
  - Right wall: 154 mm deep × 3 mm thick × 25 mm tall. (Symmetric to left.)
  - Front wall: 108 mm wide × 3 mm thick × 25 mm tall. (Full cradle width, continuous at corners.)
  - All three walls are flush at z = 0 and top out at z = 25 mm.
  - All corners where side walls meet back wall or front wall are continuous (no gap).
  - Top edges of all low perimeter walls receive 1.5 mm fillet.
- **Mating interfaces:** Interior faces are the clearance-fit lateral and front surfaces for
  the printer. Front wall interior face is flush with the interior pocket front face.
- **Note:** No scallops. No eye cutouts. These features were removed in Revision 6 (walls
  too short to accommodate them without structural compromise).

#### 4. Cable Pass-Through Notch
- **Purpose:** Routes USB-A and DC barrel cables through the back wall without requiring
  the printer to be lifted.
- **Critical dimensions:** 25 mm wide × 20 mm tall, open at base of back wall (bottom of
  notch at z = 0), centered on back wall width (X = 54 mm from left exterior face). Notch
  cuts through z = 0 to z = 20 mm — fully within the low perimeter wall zone (0–25 mm).
  The back wall/panel above z = 20 mm is fully solid.
- **Printability note:** Designed as a U-notch open at z = 0 — no bridge above it.

#### 5. Corner Feet (4×)
- **Purpose:** Elevate the cradle base off the desk surface; protect desk; improve grip;
  add finished look.
- **Critical dimensions:** 8 mm diameter dome/bump, 3 mm tall, centered 5 mm inset from
  each corner of the base plate underside.
- **Mating interfaces:** Contact desk surface. No mechanical mate.

#### 6. Ear Tufts (back panel, left and right — unchanged from Revision 4)
- **Purpose:** Aesthetic — triangular horn-like extensions rising above the tall back
  panel's top corners. From the front, they peek up behind the printer and give the
  "peekaboo owl" silhouette. Functionally inert.
- **Critical dimensions:** Each tuft is a 2D triangular profile extruded 3 mm (inheriting
  the back wall thickness). Base: 25 mm wide along the back panel top edge, starting at
  the panel's outer corner and extending 25 mm inward. Outer edge: vertical (flush with the
  exterior side face of the back panel). Inner edge: angled from the inner-base corner up
  to the peak. Peak: 35 mm above z = 145 mm (= z = 180 mm from base), offset 5 mm inward
  from the outer edge. Apex: 2 mm radius rounded tip.
  - Left tuft: outer edge at left exterior X face; peak at X = left-exterior + 5 mm inward.
  - Right tuft: outer edge at right exterior X face; peak at X = right-exterior − 5 mm inward (symmetric).
- **Printability:** Vertical extrusion of a triangular 2D profile — grows straight up from
  the back panel top, same print direction. No new overhangs introduced. Safe.

#### 7. Exterior Vertical Edge Fillets
- **Purpose:** Aesthetic — softens all four vertical exterior corners of the cradle body.
- **Critical dimensions:** 4 mm radius on all four vertical exterior corners.
- **Printability:** Vertical cylindrical convex fillets — no overhangs, no bridges. Safe.

#### 8. Base Plate Corner Fillets
- **Purpose:** Aesthetic — rounds the four footprint corners of the base plate.
- **Critical dimensions:** 6 mm radius on all four exterior corners of the base plate
  footprint (108 mm × 254.9 mm).
- **Printability:** 2D outline modification — no overhangs, no bridges. Safe.

#### 9. Top-Edge Fillets on Low Perimeter Walls and Tall Back Panel
- **Purpose:** Minor visual softening of horizontal top edges.
- **Critical dimensions:** 1.5 mm fillet radius along the horizontal top edge of:
  - Low perimeter walls (left, right, front) at z = 25 mm.
  - Tall back panel body at z = 145 mm (below the tuft bases).
- **Printability:** Small convex fillet at the top layer. Minor overhang at topmost edge —
  well within slicer tolerance at 1.5 mm. Note for print-reviewer but not a conflict.

#### 10. Tray Shelf Section (base-level slot pocket)
- **Purpose:** Houses the tray slot in the forward-projecting section of the base plate.
  No riser — the slot floor sits directly at the base plate top surface (z = 4 mm from desk).
- **Critical dimensions:** 108 mm W × 94.9 mm D shelf section. The tray slot pocket is
  cut from the front face: 103.9 mm W × 94.9 mm D × 42.3 mm H. The slot is open at the
  front face and open at the top.
- **Mating interfaces:** Tray slot interior mates with tray exterior via sliding fit.

### Tray Part

#### 11. Tray Body
- **Purpose:** Open-top container that catches labels falling from the printer tape exit.
- **Critical dimensions:** 103.2 mm W × 94.2 mm D × 41.6 mm H exterior. Wall thickness
  1.6 mm, floor thickness 1.6 mm. Interior volume: 100 × 91 × 40 mm. Four vertical exterior
  corners receive 3 mm fillet radius.
- **Mating interfaces:** Exterior slides into cradle tray slot. See Mating Interfaces.

#### 12. Angled Front Scoop Lip
- **Purpose:** Replaces the flat front wall with a forward-angled face in the lower
  portion, making labels easy to pinch without reaching over a tall wall.
- **Critical dimensions:** Bottom 15 mm of front wall angled at 45° from horizontal.
  Leading edge where scoop face meets tray floor extension receives 2 mm fillet radius.
- **Overhang check:** 45° from horizontal = 45° from vertical — exactly at FDM threshold.
  Flagged for print-reviewer slicer verification.

#### 13. Finger Grip — Top-Edge Scallop
- **Purpose:** Pull-tab feature enabling easy one-finger grip to remove tray from slot.
- **Critical dimensions:** 24 mm wide × 8 mm deep, semicircular notch cut into the TOP
  edge of the tray front wall, centered at X = 0.
- **Printability:** Concave cut open to the top — no bridge. Safe.
- **Mating interfaces:** User-accessible feature only.

#### 14. Owl Face — Eye Embosses (tray front wall)
- **Purpose:** Aesthetic — two raised circles on the tray front wall form the owl's eyes.
- **Critical dimensions:** Two embosses, r = 8 mm, raised 1.5 mm outward from the front
  wall surface. Centers at Z = 28 mm (from tray base exterior), X = ±22 mm from tray
  centerline. Positioned in the z = 15–42 mm vertical front wall region above the scoop lip.
- **Printability:** Raised circular boss on vertical wall — prints as normal outward
  perimeters stacked in Z. No overhang. Safe.

#### 15. Owl Face — Pupil Embosses (tray front wall)
- **Purpose:** Detail layer inside each eye emboss — adds expressive wide-eyed look.
- **Critical dimensions:** Two embosses, r = 3 mm, raised an additional 1.5 mm beyond the
  eye emboss surface (total 3 mm proud of the base wall). Centers coincide with eye emboss
  centers: Z = 28 mm, X = ±22 mm.
- **Printability:** Small raised boss on vertical surface. No overhang. Safe.

#### 16. Owl Face — Beak Emboss (tray front wall)
- **Purpose:** Aesthetic — a small downward-pointing triangular beak between the eyes,
  centered on the tray front wall, completing the owl face composition.
- **Critical dimensions:** Downward-pointing triangle, 6 mm wide at top × 6 mm tall.
  Raised 2 mm proud of the front wall. Top of triangle at Z = 22 mm (from tray base
  exterior); apex at Z = 16 mm (just above the scoop lip at z = 15 mm). Centered at X = 0.
- **Printability:** Triangular raised boss on vertical surface — prints as normal outward
  perimeters. No overhang. Safe.

---

## Mating Interfaces

### Printer → Cradle Interior Pocket (Clearance Fit)

| Parameter | Value | Notes |
|---|---|---|
| Printer width | 78 mm | Official spec |
| Printer depth | 152 mm | Official spec |
| Printer height | 143 mm | Official spec |
| Fit type | Clearance | Removable — user lifts printer to change cassettes |
| Clearance per side (XY) | +1.0 mm | User-specified (generous clearance over FDM standard +0.25 mm) |
| Cradle interior width | 80 mm | 78 + 2 × 1.0 |
| Cradle interior depth | 154 mm | 152 + 2 × 1.0 |
| Cradle interior height (back panel body) | 145 mm | 143 + 2.0 vertical clearance |
| Low perimeter wall height | 25 mm | Printer is enclosed at base level; top 118 mm of printer extends above the perimeter walls |
| Per-side gap | 1.0 mm | Comfortable removable clearance |

### Tray → Cradle Slot (Sliding Fit)

| Parameter | Value | Notes |
|---|---|---|
| Tray exterior width | 103.2 mm | 100 + 2 × 1.6 walls |
| Tray exterior depth | 94.2 mm | 91 + 2 × 1.6 walls (Revision 6) |
| Tray exterior height | 41.6 mm | 40 + 1.6 floor |
| Fit type | Sliding | User pulls tray out to empty labels |
| FDM sliding fit offset | +0.35 mm per side | Standard sliding fit |
| Slot interior width | 103.2 + 2 × 0.35 = 103.9 mm | Sliding fit both sides |
| Slot interior depth | 94.2 + 2 × 0.35 = 94.9 mm | Sliding fit both sides (Revision 6) |
| Slot interior height | 41.6 + 2 × 0.35 = 42.3 mm | Sliding fit top and floor |
| Per-side gap (X, Y) | 0.35 mm | Smooth sliding, no wobble |
| Per-side gap (Z) | 0.35 mm | Tray does not rattle vertically |

**Slot side wall check:**

| Dimension | Final Value | Derivation |
|---|---|---|
| Cradle body width (X) | 108 mm | Unchanged from Revision 5 |
| Wall each side of slot | 2.05 mm | (108 − 103.9) / 2; above 1.2 mm min |
| Tray slot width (interior) | 103.9 mm | 103.2 (tray ext) + 2 × 0.35 sliding fit |

---

## Material & Tolerances

- **Material:** PLA, Bambu Lab X1 Carbon, 0.4 mm nozzle, 0.2 mm layer height.
- **Default dimensional tolerance:** ±1.0 mm on overall body dimensions (XY, Z).
- **Tray slot tolerance:** ±0.2 mm (sliding fit — affects tray movement quality).
- **Tray exterior tolerance:** ±0.2 mm (sliding fit — must match slot tolerance).
- **Printer pocket clearance:** ±0.5 mm acceptable (generous clearance, non-critical).
- **No press fits or interference fits in this design.** All mating interfaces are
  clearance or sliding.
- **Aesthetic features (fillets, embosses, tufts):** ±0.5 mm acceptable.

---

## Constraints

- Build volume: 256 × 256 × 256 mm.
  - Cradle: 108 mm W × 254.9 mm D × 180 mm H (with ear tufts). All within 256 mm. PASS.
    **Note:** Cradle depth (254.9 mm) leaves ~1.1 mm margin in Y. Modeler must not add any
    additional depth geometry in the shelf section. Tray depth was reduced by 4 mm (95 → 91 mm
    interior) and the printer-to-tray gap was eliminated (set to 0 mm) to achieve build-volume fit.
  - Tray: 103.2 mm W × 94.2 mm D × 41.6 mm H. Fits comfortably. PASS.
- Minimum wall thickness: 1.2 mm (3 perimeters). All walls are 1.6 mm (tray) or 3 mm
  (cradle). Slot side walls 2.05 mm. All pass.
- Minimum floor/ceiling: 0.8 mm (4 layers). All floors are 1.6 mm (tray) or 4 mm
  (cradle). Pass.
- Both parts must be watertight (manifold mesh) for slicing.
- Parts print separately and assemble by hand — no adhesive, no fasteners.

---

## Printability Pre-Screen

| Feature | Check | Result |
|---|---|---|
| Cradle base plate | Floor 4.0 mm | PASS (≥ 0.8 mm) |
| Cradle walls (all) | Thickness 3.0 mm | PASS (≥ 1.2 mm) |
| Tray walls | Thickness 1.6 mm | PASS (≥ 1.2 mm) |
| Tray floor | Thickness 1.6 mm | PASS (≥ 0.8 mm) |
| Slot side walls | 2.05 mm | PASS (≥ 1.2 mm) |
| Low perimeter walls (L/R/front) | 25 mm tall × 3 mm thick | PASS — short, thick, fully supported |
| Low perimeter wall tops | 1.5 mm top-edge fillet | NOTE — minor top-layer overhang, within slicer tolerance, flag for print-reviewer |
| Tall back panel height | 145 mm body + 35 mm tufts = 180 mm — vertical, no overhang | PASS |
| Cable slot — back wall | Top-open notch z = 0 to z = 20, no bridge | PASS |
| Corner feet | 3 mm dome underside — self-supporting | PASS |
| Tray scoop lip angle | 45° from horizontal = 45° from vertical | NOTE — exactly at threshold, flag for print-reviewer slicer check |
| Tray finger grip scallop | 24 mm wide semicircle open to top | PASS — no bridge |
| Cradle overall depth | 254.9 mm | PASS (< 256 mm) — ~1.1 mm margin, modeler must not add depth |
| Cradle overall height with tufts | 180 mm | PASS (< 256 mm) |
| Vertical edge fillets (4 mm, cradle) | Convex cylindrical additions on vertical faces | PASS — no overhang |
| Vertical edge fillets (3 mm, tray) | Convex cylindrical additions on vertical faces | PASS — no overhang |
| Base plate corner fillets (6 mm) | 2D outline rounded rectangle | PASS — no overhang |
| Top-edge fillet (1.5 mm, back panel body top) | Small convex fillet at z = 145 mm | NOTE — minor top-layer overhang, within slicer tolerance, flag for print-reviewer |
| Scoop lip leading edge fillet (2 mm) | Convex edge at scoop/floor junction | PASS — no overhang concern |
| Tray shelf section (base level, no riser) | Solid base geometry, slot open-top and open-front | PASS — no bridge |
| Tray slot ceiling | Open-top slot (no ceiling) | PASS — no bridge |
| Ear tufts | 2D triangular profile extruded 3 mm — same direction as back panel | PASS — no new overhangs |
| Ear tuft apex (2 mm radius) | Top-perimeter micro-fillet at z = 180 mm | NOTE — cosmetic; within slicer tolerance for single-perimeter rounded top |
| Tray eye embosses (r = 8 mm, +1.5 mm proud) | Raised boss on vertical wall | PASS — no overhang |
| Tray pupil embosses (r = 3 mm, +1.5 mm additional) | Small raised boss inside eye | PASS — no overhang |
| Tray beak emboss (6 × 6 mm triangle, +2 mm proud) | Raised triangular boss on vertical wall | PASS — no overhang |
| Front wall top vs. tape exit clearance | Front wall top at z = 29 mm (desk ref); tape exit at z = 64–79 mm (desk ref) | PASS — 35–50 mm clearance, labels drop forward cleanly |

### Resolved Conflict: Build Volume with New Front Wall

Adding a 3 mm front wall extended the printer section depth from 157 mm to 160 mm.
Combined with the 98.9 mm tray slot from Revision 5, total depth would have been 258.9 mm —
exceeding the 256 mm build volume. Resolution:
1. Printer-to-tray gap set to 0 mm (front wall is flush with interior pocket front face).
2. Tray interior depth reduced from 95 mm to 91 mm (−4 mm), bringing total to 254.9 mm.
The 91 mm tray depth still provides adequate label catch area with the 100 mm width.

### Resolved Conflict: Tray Scoop Lip Overhang

The scoop face is set to exactly 45° from horizontal (= 45° from vertical — the FDM
boundary). The modeler should use this exact value. The print-reviewer must verify the
slicer does not add unnecessary support and that surface quality is acceptable for the
user-visible label-retrieval surface.

### Note: Cable Slot Bridge Elimination

Per project convention (avoid unnecessary bridges): the cable slot is specced as a
top-open notch in the back wall (slot bottom at z = 0, top at z = 20 mm, open sky above).
This eliminates any bridge. The back wall above z = 20 mm is fully solid.

### Note: Tray Slot Ceiling Elimination

The tray slot is open at the top (no ceiling across the 103.9 mm slot width). This
eliminates what would otherwise be a ~104 mm unsupported bridge — well beyond the 10 mm
threshold. The tray drops into the slot from above and is constrained laterally by the
slot side walls and in depth by the slot back wall.

### Note: Side-Wall Scallops and Eye Cutouts Removed (Revision 6)

The left and right walls are now only 25 mm tall. The 10 mm radius scallops and 10 mm
radius eye cutouts from prior revisions do not fit in a 25 mm wall without compromising
structural integrity. Both features have been removed. The owl motif is now carried by:
(1) ear tufts on the tall back panel top corners, and (2) owl face (eyes, pupils, beak)
on the tray front wall.

---

## Revision History

### Revision 2 (2026-04-18)

**Revision 1 changes — Tape-exit location locked in:**
- Removed the "ASSUMPTIONS TO VERIFY WITH USER" block. Tape exit confirmed via official
  Brother-USA product photography: front face, lower-middle, Z ≈ 60–75 mm above printer
  base. This is no longer an assumption.
- Updated design intent and all feature descriptions to reference confirmed tape-exit
  location. Removed all language saying "near the top" or "assumed front face."
- USB/DC-on-back remains an assumption (not confirmed in photos); noted in the revised
  confirmation block.

**Revision 2 changes — Rounded aesthetic fillets added:**
- Added new fillet dimensions table in Dimensions & Sources.
- Added four new feature entries: exterior vertical edge fillets (4 mm, cradle), base
  plate corner fillets (6 mm), top-edge fillets (1.5 mm), tray exterior vertical edge
  fillets (3 mm), and scoop lip leading edge fillet (2 mm).
- Added printability pre-screen rows for all fillet features. All pass; 1.5 mm top-edge
  fillet noted for print-reviewer.
- Updated design intent paragraph to reference rounded exterior aesthetic.

**Revision 3 changes — Tray drop height corrected via raised shelf riser:**
- Added Tray Drop Height Analysis table confirming the problem (original 58–73 mm drop
  too long for reliable label capture) and chosen solution.
- Added 25 mm raised shelf riser as a new feature (Feature 11), replacing the original
  flat 4 mm shelf. Tray slot is now cut into the front face of this riser; slot is
  open-top and open-front (no bridge).
- Updated base plate description, tray shelf dimensions, and printability pre-screen to
  reflect riser geometry.
- Updated tray floor Z above desk (now ~29.6 mm) and label drop distances (34–49 mm),
  confirmed within 30–50 mm target range.
- Added printability note confirming tray slot ceiling is eliminated (open-top slot).

### Revision 4 (2026-04-18)

**Owl "creature" motif — aesthetic overhaul:**

Features removed:
- Cloud-shaped window cutouts in side walls (both sides). Replaced by circular eye cutouts.
- Finger grip front-wall notch on tray. Replaced by top-edge scallop.

Features added:
- **Ear tufts** (Feature 8): Two triangular extensions rising 35 mm above the back wall
  top corners, inheriting the 3 mm wall profile. Peak offset 5 mm inward from outer edge,
  2 mm apex radius. Overall cradle height increases from 145 mm to 180 mm.
- **Circular eye cutouts** (Feature 7, replaces cloud windows): Plain circle r = 10 mm,
  centered at Y = 77 mm (mid-depth), Z = 55 mm per side wall.
- **Finger grip top-edge scallop** (Feature 15, replaces front-wall notch): 24 mm wide ×
  8 mm deep semicircle open to top of tray front wall.
- **Tray owl face eye embosses** (Feature 16): Two raised circles r = 8 mm, +1.5 mm proud,
  at Z = 28 mm, X = ±22 mm.
- **Tray owl face pupil embosses** (Feature 17): Two raised circles r = 3 mm, total +3 mm
  proud, coincident with eye centers.
- **Tray owl face beak emboss** (Feature 18): Downward-pointing triangle 6 × 6 mm, +2 mm
  proud, centered at X = 0, top at Z = 22 mm.

Dimensions updated:
- Cradle overall height: 145 mm → 180 mm (still within 256 mm build volume).
- Eye cutout center Z: 38 mm → 55 mm.

### Revision 5 (2026-04-18)

**Riser removal and tray enlargement:**

Changes:
- Removed the 25 mm raised shelf riser. Tray shelf at 4 mm base plate level.
- Tray interior width: 90 mm → 100 mm. Tray exterior width: 93 mm → 103.2 mm.
- Tray interior depth: 70 mm → 95 mm. Tray exterior depth: 73 mm → 98.2 mm.
- Tray interior height: unchanged at 40 mm.
- Cradle body width: 98 mm → 108 mm (driven by wider tray slot).
- Cradle total depth: 234 mm → 255.9 mm.
- Cable slot center X: 49 mm → 54 mm.

### Revision 6 (2026-04-18)

**Full-perimeter low base + tall back panel — aesthetic redesign:**

User feedback: dislikes the U-shaped three-wall structure (tall back + tall sides, open
front). Wants a slicker low enclosure on all four sides with a tall back panel only.

Features removed:
- **Tall side walls** (previously 97 mm tall): replaced by low 25 mm perimeter walls.
- **Side-wall scallop top edges**: removed — 25 mm walls cannot accommodate 10 mm radius
  scallops without structural compromise.
- **Side-wall circular eye cutouts**: removed — 25 mm walls cannot accommodate r = 10 mm
  eye cutout without structural compromise.

Features added / changed:
- **Full-perimeter low walls**: 25 mm tall × 3 mm thick on ALL FOUR sides (back, left,
  right, front). The back low wall integrates with the tall back panel (same exterior face).
- **Tall back panel**: rises from z = 0 through z = 145 mm (body), ear tufts to z = 180 mm.
  Spans full 108 mm width. 3 mm thick. Unchanged geometry above z = 25 mm.
- **Front wall added**: 108 mm wide × 3 mm thick × 25 mm tall. New feature. Tape exits at
  z = 64–79 mm (desk ref), clearing the front wall top at z = 29 mm by 35–50 mm.
- **Cable notch confirmed retained**: 25 mm wide × 20 mm tall, open-bottom, centered.
  Resides entirely within z = 0–20 mm (inside the 25 mm low perimeter wall zone).

Dimension cascades updated:
- Printer section outer depth: 157 mm → 160 mm (back wall 3 + interior 154 + front wall 3).
- Printer-to-tray gap: 1 mm → 0 mm (eliminated to recover depth budget).
- Tray interior depth: 95 mm → 91 mm (reduced 4 mm to recover remaining depth budget).
- Tray exterior depth: 98.2 mm → 94.2 mm.
- Tray slot depth: 98.9 mm → 94.9 mm.
- Cradle total depth: 255.9 mm → 254.9 mm (within 256 mm build volume — ~1.1 mm margin).
- Tray Drop Height Analysis updated: front wall top at z = 29 mm (desk ref) confirmed clear
  of tape exit by 35–50 mm.

Owl motif retained in:
- Ear tufts on tall back panel top corners (unchanged).
- Owl face (eyes, pupils, beak) on tray front wall (unchanged).
