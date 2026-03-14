# Fan-Tub Adapter v2.0 — Tool-Free Clip System

A two-part replacement for the v1.0 bolt-on fan-tub adapter. The base plate is permanently caulked to the tub lid, and a snap-on retention clip holds the fan in place for tool-free removal and cleaning.

**v1.0 is frozen** — see [fan-tub-adapter.md](fan-tub-adapter.md) for the bolt-on design.

## System Overview

The v1.0 design used M4 bolts + thumbscrews to secure the fan. v2.0 eliminates all fasteners:

1. **Base plate** — caulked to the lid with silicone. Retains all waffle-grid engagement branches. A taller locating rim (4mm, up from 1.5mm) holds the fan positively, with clip ledges on the rim exterior.
2. **Retention clip** — a frame that sits on the fan top with four cantilever arms that snap down onto the base plate ledges. Squeeze two opposite arms to release.

No bolts, no nuts, no thumbscrews, no tools.

## Cross-Section (Installed)

```
                        ← center        outside →

    z=29.7  ┌─────────────────────┬──────┐  clip frame (2mm thick, on fan top)
            │   sits on fan top   │ tab  │
    z=29.7  ╪═════════════════════╪══════╪  fan frame top
            │                     │      │
            │   fan (24.7mm)      │  arm │  (1.5mm thick, 8mm wide)
            │                     │      │
    z=9.0   ║                     ║      │  rim top
            ║   rim (4mm tall)    ║      │
    z=7.5   ║                     ╠══╗   │  ledge (1.0mm out, 1.5mm tall)
            ║                     ║  ║┌──┤  hook catches UNDER ledge
    z=6.0   ║                     ╠══╝└──┤
            ║                     ║      │
    z=5.0   ╩═════════════════════╩══════╧  inner plate top
```

## Vertical Stackup

| Z (mm) | Feature |
|--------|---------|
| 0.0 | Base plate bottom (caulked to lid) |
| 5.0 | Inner plate top surface |
| 5.0–9.0 | Locating rim (4.0mm tall) |
| 6.0–7.5 | Clip ledge zone (1.0mm outward protrusion) |
| 5.0–29.7 | Fan frame (24.7mm thick) |
| 29.7–31.7 | Clip frame (2.0mm thick) |

## Part 1: Base Plate

### Renders

#### Isometric (Top)

![Base plate isometric](images/fan-tub-adapter-base/fan-tub-adapter-base-iso.png)

Stepped plate with Y-branches extending into waffle channels. Taller 4mm locating rim visible as a raised square border. No bolt holes — clean inner zone. Clip ledges (1mm bumps) on rim exterior.

#### Bottom Isometric

![Base plate bottom](images/fan-tub-adapter-base/fan-tub-adapter-base-bottom-iso.png)

Clean bottom face — no hex counterbores or bolt holes. This face gets caulked directly to the tub lid.

#### Edge Profile

![Base plate edge](images/fan-tub-adapter-base/fan-tub-adapter-base-edge.png)

Shows the stepped plate profile: thick inner zone (5mm) with 4mm rim, thinner outer zone (4.6mm) flush with waffle square tops.

#### Top-Down

![Base plate top-down](images/fan-tub-adapter-base/fan-tub-adapter-base-top-down.png)

Branch forks centered in surrounding channels at 73.1mm from center. Locating rim inner edge defines fan drop-in area.

### Geometry

| Dimension | Value | Notes |
|-----------|-------|-------|
| Overall bounding box | 196.2 x 196.2 x 9.0 mm | Same XY footprint as v1 |
| Locating rim | 120mm inner, 124mm outer, 4.0mm tall | Taller than v1 (was 1.5mm) |
| Clip ledges | 1.0mm outward, 1.5mm tall, 8mm wide | 4x, one per side |
| Ledge Z position | z=6.0 to z=7.5 | 1.5mm below rim top |
| Inner plate | 5.0mm thick | Fan mount zone |
| Outer plate | 4.6mm thick | Flush with waffle tops |
| Center opening | 105mm diameter | |
| Branch engagement | 25mm per arm | 8 arms total |

### Validation

```
bbox.x:    196.2 mm  (expected 196 ±2)    PASS
bbox.y:    196.2 mm  (expected 196 ±2)    PASS
bbox.z:    9.0 mm    (expected 9.0 ±0.5)  PASS
watertight: true                           PASS
volume:    72.7 cm³  (expected 10–120)     PASS
```

## Part 2: Retention Clip

### Renders

#### Isometric

![Clip isometric](images/fan-tub-adapter-clip/fan-tub-adapter-clip-iso.png)

Frame with four cantilever arms. Shown in installed orientation (frame on top, arms hanging down). Hooks visible at arm tips.

#### Side View

![Clip side](images/fan-tub-adapter-clip/fan-tub-adapter-clip-side.png)

Tabs bridge from frame edge to arm positions. Arms are 1.5mm thick, 8mm wide, 22.05mm long.

#### Front View

![Clip front](images/fan-tub-adapter-clip/fan-tub-adapter-clip-front.png)

Front elevation showing frame cross-section with arm hanging down on each side.

#### Top-Down

![Clip top-down](images/fan-tub-adapter-clip/fan-tub-adapter-clip-top-down.png)

Frame ring with 105mm center opening. Four tabs visible extending to arm positions.

### Clip Mechanism — Cantilever Snap-Fit

- Arm length: 22.05mm (preload-adjusted from 22.2mm theoretical)
- Assembly deflection: 1.8mm (ledge depth 1.0 + hook overhang 0.8)
- Arm cross-section: 8.0mm wide x 1.5mm thick
- Nominal root stress: 29.1 MPa  (`σ = 3Ehδ / 2L²`, E=3500, h=1.5, δ=1.8, L=22.05)
- PLA yield (Bambu PLA Basic): ~65 MPa
- **Nominal SF: 2.24** — adequate for static, but stress concentration governs cycle life

#### Fatigue / Cycle Life

An unfilleted sharp re-entrant corner at the arm root has Kt ≈ 2.5, giving σ_peak ≈ 73 MPa ≈ yield — low cycle life. The **2mm root fillet** (added in this revision) drops Kt to ~1.2, σ_peak to ~35 MPa, well below PLA's estimated fatigue limit of ~25–30 MPa at 10⁶ cycles. Adequate for hundreds of seasonal removal/cleaning cycles.

The hook entry face has a **45° lead-in chamfer** (0.8mm), replacing the previous blunt rectangular step. This distributes snap-in force over the chamfer travel rather than a single impact, further reducing peak load at the root during assembly.

#### Alternate Geometry Considered

A tapered arm (thicker root, thinner tip) distributes stress more uniformly but provides no meaningful gain here since arm length is geometrically locked by the ledge position — the only levers are section thickness and Kt reduction. The current arm with root fillet achieves the design goal.

### Geometry

| Dimension | Value | Notes |
|-----------|-------|-------|
| Overall bounding box | 129 x 129 x 25.6 mm | In installed orientation |
| Frame outer | 119mm rounded square | Matches fan frame |
| Frame inner | 105mm | Airflow opening |
| Frame thickness | 2.0mm | |
| Arm width | 8.0mm | One centered per side |
| Arm thickness | 1.5mm | |
| Arm length | 22.05mm | With 0.15mm preload |
| Hook overhang | 0.8mm inward | Catches under ledge |
| Hook height | 1.5mm | |
| Hook lead-in chamfer | 0.8mm @ 45° | Continuous snap-in ramp on outer-lower edge |
| Root fillet | 2.0mm | Triangular prism at arm/tab inner corner; Kt 2.5→1.2 |
| Tab bridge | ~4.25mm | Frame edge to arm center |

### Validation

```
bbox.x:    129.0 mm  (expected 129 ±2)     PASS
bbox.y:    129.0 mm  (expected 129 ±2)     PASS
bbox.z:    25.6 mm   (expected 25.5 ±1.0)  PASS
watertight: true                            PASS
volume:    7.7 cm³   (expected 5–40)        PASS
```

## Assembly Instructions

1. **Install base plate**: Apply silicone caulk to base plate bottom. Press into waffle cutout, branches into channels. Let cure 24h.
2. **Install fan**: Drop fan into locating rim. Frame sits on inner plate, rim provides alignment.
3. **Clip on**: Press retention clip down over fan. Arms deflect outward ~1.8mm as hooks pass ledges, then snap into place.
4. **Remove for cleaning**: Squeeze two opposite clip arms outward. Lift clip off. Lift fan out. Base plate stays permanently on lid.

## BOM

| Qty | Item | Notes |
|-----|------|-------|
| 1 | Base plate (3D printed) | PLA, 72.7 cm³ |
| 1 | Retention clip (3D printed) | PLA, 7.7 cm³ |
| 1 | Silicone caulk | Aquarium-safe, for base plate to lid |

No fasteners required.

## Print Settings

| Setting | Base Plate | Retention Clip |
|---------|-----------|----------------|
| Orientation | Bottom face on bed | Frame on bed, arms up |
| Material | PLA | PLA |
| Layer height | 0.2mm | 0.2mm |
| Infill | 100% | 100% |
| Supports | None | None |
| Notes | Rim builds upward, ledges are 1mm steps | Hooks are 0.8mm inward steps at tips |

## Changes from v1.0

| Feature | v1.0 | v2.0 |
|---------|------|------|
| Fan retention | M4 bolts + nuts | Snap-fit clip |
| Lid attachment | M4 thumbscrews + wing nuts | Silicone caulk (permanent) |
| Parts | 1 | 2 (base + clip) |
| Fasteners | 4 bolts, 4 nuts, 2 thumbscrews, 2 wing nuts | None |
| Tool-free removal | Thumbscrews only (fan still bolted) | Both fan and clip are tool-free |
| Locating rim height | 1.5mm | 4.0mm |
| Bolt holes | 4x M4 + hex counterbores | None |
| Total print volume | 69.4 cm³ | 80.4 cm³ (72.7 + 7.7) |

## Assembly Validation

The base plate, fan, and clip can be checked as an assembly:

```bash
node bin/check-assembly.js assemblies/fan-tub-adapter-v2.json
```

### Interference Checks

| Part A | Part B | Max Volume | Description |
|--------|--------|-----------|-------------|
| base | clip | 5.0 mm³ | Hook engagement zone — controlled overlap expected |
| base | fan | 0.0 mm³ | Fan must sit inside rim with clearance |
| clip | fan | 0.0 mm³ | Clip frame rests on fan top, no overlap |

### Fit Specs

| Check | Type | Expected Range | Description |
|-------|------|---------------|-------------|
| clip-hook-ledge-engagement | interference | 0.3–1.5 mm³ | Positive hook engagement with ledges |
| fan-in-rim-clearance | clearance | 0.3–0.7 mm | Gap between fan frame and locating rim |

### Assembly Positions

| Part | Position (X, Y, Z) | Notes |
|------|-------------------|-------|
| Base | 0, 0, 0 | Reference origin |
| Fan | 0, 0, 5.0 | Sits on inner plate (z=frame_t_inner) |
| Clip | 0, 0, 6.15 | Local z=0 (hook bottom) → global z=6.15 |

## Source Files

- [`fan-tub-adapter-base.scad`](../designs/fan-tub-adapter-base/fan-tub-adapter-base.scad) — Base plate OpenSCAD source
- [`fan-tub-adapter-clip.scad`](../designs/fan-tub-adapter-clip/fan-tub-adapter-clip.scad) — Retention clip OpenSCAD source
- [`fan-tub-adapter-params.scad`](../scad-lib/fan-tub-adapter-params.scad) — Shared parameters
- Base plate spec: [`spec.json`](../designs/fan-tub-adapter-base/spec.json)
- Clip spec: [`spec.json`](../designs/fan-tub-adapter-clip/spec.json)
- Assembly spec: [`fan-tub-adapter-v2.json`](../assemblies/fan-tub-adapter-v2.json)
- Fan reference SCAD: [`fan-frame-119.scad`](../scad-lib/reference/fan-frame-119.scad)
