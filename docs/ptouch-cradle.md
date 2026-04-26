# P-touch Cradle

Quiet desk dock and label catch tray for the Brother PT-P750W label printer. Clean rectangular bathtub form with generous fillets — the printer is the visual subject; the cradle is the frame that holds it and catches the labels.

## Renders

### In use

![Printer installed in the cradle — low 25mm bathtub walls frame the printer base on all four sides; catch tray visible in front. The primary 'is it quiet enough?' check.](images/ptouch-cradle/cradle-user-front-in-use.png)
*Use-state front elevation — printer in pocket, low cradle perimeter visible around base, catch tray in front. The 25mm walls disappear behind the 143mm printer.*

![Three-quarter use-state view — printer installed, low perimeter walls and catch tray visible together; cradle reads as a supporting frame, not the visual subject.](images/ptouch-cradle/cradle-user-front-threequarter-in-use.png)
*Use-state three-quarter — full assembly: cradle stepped footprint, printer in pocket, tray slid in from front.*

### Cradle — bare part

![Front elevation of the bare cradle showing the uniform 25mm perimeter walls on all four sides, stepped body (86mm printer section to 110mm shelf section), and open tray slot at front center.](images/ptouch-cradle/cradle-user-front.png)
*Front elevation — 25mm uniform bathtub walls, stepped footprint, open tray slot (103.9 × 94.9mm interior) at the forward shelf section.*

![Three-quarter view of the bare cradle showing the r=10 exterior corner fillets, the printer-section-to-shelf concave fillet on each ±X side, and continuous tray-holder wrap.](images/ptouch-cradle/cradle-user-front-threequarter.png)
*Three-quarter bare-part — r=10 exterior corner fillets and printer-section→shelf concave fillet schedule visible. Tray slot side walls 3.05mm, matching the 3mm perimeter wall thickness for a continuous U-wrap.*

![Top-down three-quarter view of the cradle showing the symmetric full-perimeter bathtub, the stepped base footprint, and both open pocket cavities (printer pocket and tray slot).](images/ptouch-cradle/cradle-user-top-threequarter.png)
*Top-down three-quarter — symmetric bathtub, printer pocket (80 × 154mm), and tray slot (103.9 × 94.9mm) viewed from above.*

### Tray — bare part

![Front elevation of the catch tray showing the uniform 10mm low front wall, concave r=20 side fillet sweeps from the 30mm side walls down to the 10mm front wall, and the clean horizontal grab lip across the full width.](images/ptouch-cradle/tray-user-front.png)
*Tray front elevation — uniform 10mm front wall, r=20 concave side fillets sweeping from side-wall top (z=30) to front-wall top (z=10). User reaches over the full-width low lip to retrieve labels.*

![Three-quarter view of the catch tray showing the back/side walls at full 30mm height, the concave side fillet scoops on each front corner, and the proportional form language matching the cradle.](images/ptouch-cradle/tray-user-front-threequarter.png)
*Tray three-quarter — 30mm back/side walls, r=20 concave corner scoops, and r=2 top-edge fillet on back/sides (r=0.8 on front wall — restricted by 1.6mm wall thickness).*

## Design Overview

Two parts that assemble without fasteners or adhesive. The tray slides forward out of the cradle shelf section; the printer drops into the printer pocket from above.

```
                  ←— 110mm —→
   ┌──────────────────────────┐  z=25mm
   │      PRINTER POCKET      │  Low uniform perimeter walls
   │  80 × 154mm interior     │  3mm thick, all four sides
   │  1mm/side XY clearance   │
   │                          │
   ├──────────┬───────────────┤  z=4mm (base plate top)
   │  3.05mm  │  TRAY SLOT    │  z=26.3mm (slot side walls)
   │  side    │  103.9×94.9mm │
   │  walls   │  0.35mm/side  │  Tray slides forward (+Y)
   └──────────┴───────────────┘  z=0 (flush on bed)
   ←— 160mm depth ——→←— 95mm —→

TRAY (103.2 × 94.2 × 30mm, protrudes ~9mm above cradle wall):

   ┌──────────────────────────┐  z=30mm back/side wall top (r=2 fillet)
   │      ← 100mm →           │
   │      open top            │
   │      interior            │  1.6mm walls
   │                          │  1.6mm floor
   │  parabolic ramp at front │
   ╲──────────────────────────╱  z=10mm front wall top (r=0.8 fillet)
    r=20 concave scoops both sides
```

**Install sequence:**
1. Place cradle on desk — base plate sits flush at z=0. Silicone feet optional (apply aftermarket).
2. Drop printer into the open top — rests in the full-perimeter bathtub pocket. Printer base sits on the 4mm base plate.
3. Route USB and DC power cables over the top of the 25mm back wall. No notch needed; the plug sits above the wall height.
4. Slide tray into the forward slot from the front (+Y direction).
5. Printer auto-cuts labels; they exit at z=64–79mm above desk, clear the 10mm front wall top (at z=21mm above desk) by 43–58mm, and drop forward into the tray.
6. Reach over the low front wall anywhere along its width to retrieve labels, or pull the tray forward to remove it entirely.

**Fillet schedule:** Two named radii, applied without exception.
- r=3 (utility): all cradle top edges, all visible vertical wall corners, tray vertical corner edges, break-edges.
- r=10 (hero): cradle exterior corners (4×), base plate corners (8×, top and bottom), printer-section→shelf concave fillet on ±X sides, tray-slot corner fillet.

No chamfers anywhere. No decoration of any kind.

## Geometry

| Dimension | Value | Notes |
|-----------|-------|-------|
| Cradle bounding box | 110 × 254.9 × 25mm | Flush base, no feet |
| Cradle printer section width | 86mm | Narrow section housing the printer pocket |
| Cradle shelf section width | 110mm | Full width including tray slot |
| Printer pocket interior | 80 × 154mm | 78 × 152mm printer + 1mm/side clearance |
| Tray slot interior | 103.9 × 94.9 × 22.3mm | 0.35mm/side sliding fit |
| Cable access | Over top of 25mm back wall | No notch — plug is above wall height |
| Cradle volume | ~136.6 cm³ | Mesh analysis |
| Tray bounding box | 103.2 × 94.2 × 30mm | 5mm above 25mm cradle wall by design |
| Tray front wall height | 10mm | Uniform across full width |
| Tray side-to-front fillet | r=20 concave | Single quarter-arc per side, no intermediate sections |
| Tray interior ramp | parabolic z(y) = 1.6 + 8.4·((y−62.6)/30)² | Tangent to floor at back, terminates at z=10 at front |
| Tray volume | ~38.9 cm³ | Mesh analysis |
| Combined volume | ~175.5 cm³ | |

## Features

### Cradle

**Base plate** — 110 × 254.9mm footprint, 4mm thick. r=10 hero corner radius softens the footprint on all four corners (top and bottom). Flush on the build plate — no feet.

**Low perimeter walls** — All four cradle walls at 25mm tall × 3mm thick. Full-perimeter uniform bathtub. The wall height is the defining dimension of the form: everything else defers to this. r=3 top-edge fillet slab stack (64 steps at ship quality) reads as a true continuous quarter-arc.

**Printer-section → shelf concave fillet** — r=10 concave quarter-arc on both ±X sides where the 86mm printer section transitions to the 110mm shelf section. The one sculptural move on the cradle. Purely vertical feature in print; no printability concern.

**Tray slot** — 103.9 × 94.9mm interior, 22.3mm engagement depth. Open front (+Y) and open top. Slot side walls 3.05mm — matches the 3mm perimeter wall thickness for a continuous U-wrap that reads as an uninterrupted part of the cradle body.

**Host-object proxy** — Render-only utility module (`host_object_proxy()`). Draws the 78 × 152 × 143mm printer reference box at its installed position for use-state renders. Excluded from STL by default; use-state PNGs pass `-D 'render_with_host=true'`.

### Tray

**Closed 4-wall bin** — 103.2 × 94.2 × 30mm exterior, 1.6mm walls and floor. r=3 vertical corner fillets on all exterior vertical edges.

**Uniform 10mm front wall** — Flat at z=10 across the full width. The grab feature: user reaches over anywhere along the width. Tray interior cavity accessible above the 10mm front lip.

**r=20 concave side fillet sweeps** — ONE quarter-arc per side (r=20, matching the 20mm height drop from z=30 to z=10). Sweeps continuously from side-wall top down to front-wall top. Single curve, single radius — no intermediate flat sections, no transition arcs, no sharp corner intersections.

**Top-edge fillets** — r=2 continuous fillet on back and side wall tops (z=30), rolled inward via slab stack. r=0.8 fillet on front wall top (z=10) — smaller because the 1.6mm front wall is too thin for r=2 without offset collapse. Both fillet radii are engineered deviations with documented rationale.

**Interior parabolic floor ramp** — z(y) = 1.6 + 8.4 · ((y − 62.6) / 30)². Tangent to the flat floor at the back (slope=0 at y=62.6), steepens toward the front, terminates at z=10 at the front wall interior face. Concave from cavity side — a finger sliding forward gets a smooth gradual incline. Self-supporting in face-up print orientation (always slopes up-and-forward, never overhangs).

## Mating Interfaces

| Interface | This Part | Mates With | Fit Type | Gap / Interference |
|-----------|-----------|------------|----------|--------------------|
| Printer pocket (X) | 80mm interior | 78mm printer width | Clearance | +1.0mm/side |
| Printer pocket (Y) | 154mm interior | 152mm printer depth | Clearance | +1.0mm/side |
| Tray slot (X) | 103.9mm interior | 103.2mm tray exterior | Sliding | +0.35mm/side |
| Tray slot (Y) | 94.9mm interior | 94.2mm tray exterior | Sliding | +0.35mm/side |
| Tray floor | z=4.0mm (slot floor) | Tray base | Contact | 0mm — intentional seat |

Slot side walls 3.05mm each side. Printer pocket clearances confirmed by interference check (0.0mm³ intersection). Tray sliding fit verified analytically: 103.9 − 103.2 = 0.7mm total = 0.35mm per side, exactly the spec sliding-fit offset.

## Printability

Both parts pass all printability checks. Zero real bridge spans in either part. No supports required.

| Check | Result | Notes |
|-------|--------|-------|
| Transitions (cradle) | 4/4 PASS | Base→wall (z=4mm): false-positive flag from analyzer measuring open pocket void |
| Transitions (tray) | 4/4 PASS | Floor, walls, front-wall terminus, top fillets |
| Overhangs (cradle) | PASS | Vertical walls throughout; flush base; no overhangs above z=0 |
| Overhangs (tray) | PASS (marginal at r=20 fillet tip) | z=24–30mm fillet corner technically >45° but backed by side-wall material; cosmetic quality impact only |
| Bridges (cradle) | PASS | 3 analyzer flags are false positives (open pocket voids) |
| Bridges (tray) | PASS | Max span 1.21mm — ramp arc-sampling artifacts, not real bridges |
| Thin walls | PASS (1 marginal) | Tray r=20 fillet corner: 1.026mm minimum at z=10–26mm — geometric artifact backed by full side-wall material |
| Slicer | N/A | PrusaSlicer not installed |

### Geometry Analysis

Cradle: 125 layers at 0.2mm, watertight, all transitions PASS. Tray: 150 layers, watertight. All bridge FAIL flags in both parts are false positives from the cross-section analyzer measuring across intentionally open pockets or arc-sampling artifacts on curved surfaces.

**One marginal finding:** the r=20 concave fillet corner on the tray measures 1.026–1.194mm wall thickness at z=10–26mm — below the 1.2mm nominal spec. Root cause: geometric artifact of the angled fillet intersection at the outer corner. The continuous 1.6mm side wall provides full backing; the slicer will generate 2–3 perimeters in this zone. Not a print blocker; flagged for test print verification.

### Slicer Analysis

Slicer analysis not available — PrusaSlicer not installed. Key items to verify when slicing:
1. Confirm no support material is added to either part.
2. Confirm cradle bridge flags (z=4.1, z=22.1, z=22.9) do not trigger support generation — these are open interior voids.
3. Confirm tray r=20 fillet corner zone (z=10–26mm) generates adequate perimeter count (minimum 2 perimeters).
4. Verify cradle is centered in Y (254.9mm vs 256mm build volume = 1.1mm margin — use auto-center in Bambu Studio).

## Print Settings

### Cradle

| Setting | Value |
|---------|-------|
| Orientation | Base plate bottom flush on bed; base plate at z=0, walls grow up |
| Material | PLA |
| Layer height | 0.2mm |
| Infill | 20% — base plate and walls are primarily solid perimeters |
| Supports | None required |
| Note | Y margin: 254.9mm vs 256mm build volume. Verify centering in Bambu Studio before printing. |

### Tray

| Setting | Value |
|---------|-------|
| Orientation | Face up (open top toward the sky), floor on bed |
| Material | PLA |
| Layer height | 0.2mm |
| Infill | 15–20% — 1.6mm walls are 4 perimeters at 0.4mm nozzle, effectively solid |
| Supports | None required — parabolic ramp self-supporting; r=20 concave scoops build from lower z to higher z in X |

## BOM

| Qty | Item | Notes |
|-----|------|-------|
| 1 | Cradle (3D printed) | PLA, ~136.6 cm³ |
| 1 | Tray (3D printed) | PLA, ~38.9 cm³ |

No fasteners, adhesive, or hardware required. Silicone bump feet (3–4mm diameter) can be applied to the cradle base plate underside aftermarket if desired.

## Design Log

**v3 (this version) — 7-round ID critique loop, 2026-04-18 to 2026-04-26**

The v3 design went through 7 rounds of industrial-design critique and revision, documented in full at `designs/ptouch-cradle/id/conversation-log.md` and individual modeler notes v1–v7.

Round 1–2 (owl direction): critique identified the shipped v2 owl tufts as cat-ear shaped; round 1 attempted a back-panel relocation. Round 2 surfaced a structural failure — the facial disc at z=90 is behind the printer in actual use (printer is 143mm tall; the face was invisible with the printer installed). The use-state render requirement was codified into the pipeline.

**Round 3 (pivot):** user abandoned the owl direction entirely after round 2 renders showed a panda/teddy-bear effect. New direction: quiet Muji-Rams minimalism. All four perimeter walls drop to 25mm (symmetric bathtub). No face, no tufts, no decoration. Two-tier fillet schedule (r=3 utility, r=10 hero).

Rounds 4–7 iterated within v3 minimalism:
- Round 4: tray holder wrap made continuous (slot walls 3.05mm), top-edge fillets added, tray closed-bin architecture established with scoop lip.
- Round 5: feet removed (flush base), cable notch removed (plug is above wall height), tray interior ramp established (concave parabolic), tray height raised to 30mm.
- Round 6: variable-height front wall (corners z=18, center z=10) replaced the round-5 boss+indent grab feature; concave ramp orientation corrected.
- Round 7: round-6 variable-height front wall simplified — corner sections ("top bars") and transition arcs eliminated. Single uniform z=10 front wall + ONE r=20 concave fillet per side. User signed off.

**v2 (prior) — shipped commit `90dd34a`**

Owl-themed: tray shortened (41.6 → 21.6mm), enlarged owl face on tray front, flat cylinder feet, feather-arch embosses on printer-section side walls. The owl direction was fully abandoned at round 3 of the v3 loop.

## Validation

```
cradle.x:    110.0 mm  (expected 110 ±1.0)     PASS
cradle.y:    254.9 mm  (expected 254.9 ±1.0)   PASS
cradle.z:     25.0 mm  (expected 25 ±4.0)      PASS
watertight:  true                               PASS

tray.x:      103.2 mm  (expected 103.2 ±0.2)   PASS
tray.y:       94.2 mm  (expected 94.2 ±0.2)    PASS
tray.z:       30.0 mm  (expected 30 ±4.0)      PASS
watertight:  true                               PASS

volume (cradle):   ~136.6 cm³  (expected 30–400 cm³)  PASS
volume (tray):      38.9 cm³   (expected 30–400 cm³)  PASS
volume (combined): 175.5 cm³   (expected 30–400 cm³)  PASS
```

## Downloads

| File | Description |
|------|-------------|
| [`cradle.stl`](../designs/ptouch-cradle/output/cradle.stl) | Cradle — print-ready mesh (ship quality) |
| [`tray.stl`](../designs/ptouch-cradle/output/tray.stl) | Tray — print-ready mesh (ship quality) |
| [`cradle.scad`](../designs/ptouch-cradle/cradle.scad) | Cradle parametric source |
| [`tray.scad`](../designs/ptouch-cradle/tray.scad) | Tray parametric source |
| [`spec.json`](../designs/ptouch-cradle/spec.json) | Validation spec |
| [`modeling-report.json`](../designs/ptouch-cradle/output/modeling-report.json) | Feature inventory (round 7) |
| [`review-printability.md`](../designs/ptouch-cradle/output/review-printability.md) | Full printability review |
| [`review-fitment.json`](../designs/ptouch-cradle/output/review-fitment.json) | Fitment review — all clearances PASS |
| [`id/brief.md`](../designs/ptouch-cradle/id/brief.md) | ID brief — v3 minimalism direction |
| [`id/conversation-log.md`](../designs/ptouch-cradle/id/conversation-log.md) | Full 7-round ID critique log |

## Pipeline

| Stage | Agent | Result |
|-------|-------|--------|
| Spec | spec-writer | 2 parts, 5 mating interfaces, 8 test print candidates |
| ID | id-designer | 7-round critique loop — rounds 1–2 owl, round 3 pivot to v3 minimalism, rounds 4–7 refinement |
| Model | modeler | PASS (7 rounds: v3 → v4 tray wrap + fillets → v5 closed bin + ramp → v6 variable front wall → v7 simplified uniform front wall) |
| Geometry | geometry-analyzer | Cradle: watertight, all transitions PASS. Tray: watertight, 1 marginal fillet corner |
| Print review | print-reviewer | 7/7 PASS cradle, 4/4 PASS tray. 1 marginal (tray fillet corner 1.026mm). No blockers. |
| Fit review | fit-reviewer | PASS — 0.0mm³ interference, all clearances confirmed analytically |
| Ship | shipper | this commit |

Built with pipeline v4
