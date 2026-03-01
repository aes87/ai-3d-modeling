# AI 3D Modeling

An AI-native 3D printing pipeline where [Claude Code](https://docs.anthropic.com/en/docs/claude-code) writes parametric [OpenSCAD](https://openscad.org/) models, validates them automatically, and iterates until they pass.

## How It Works

The pipeline follows a loop we call **the Ralph Wiggum Loop**:

1. **Describe** the part you need — dimensions, constraints, how it fits with other components.
2. **Claude writes** a `spec.json` (expected dimensions, tolerances, validation targets) and a parametric `.scad` file using project libraries for FDM/PLA tolerances.
3. **Run validation** — the pipeline renders STL + 4-view PNGs via OpenSCAD, analyzes the STL (bounding box, volume, watertight check), and compares against the spec.
4. **If it fails**, Claude reads the structured error report, fixes the `.scad`, and re-runs. Up to 6 rounds.
5. **If it passes**, Claude reviews the rendered PNGs visually. Done.

The human role is describing what they need and reviewing the final output. The AI handles all the CAD work, iteration, and validation.

## Target Printer

**Bambu Lab X1 Carbon** — 256 x 256 x 256 mm build volume, 0.4mm nozzle, PLA.

All tolerance constants (press fit, clearance fit, hole compensation, min wall thickness, overhang limits) are codified in [`scad-lib/fdm-pla.scad`](scad-lib/fdm-pla.scad) and used by every design.

## Project Structure

```
.
├── assemblies/              # Multi-part assembly specs
├── bin/
│   ├── validate.js          # Per-design validation CLI
│   └── check-assembly.js    # Assembly checking CLI
├── designs/
│   ├── fan-tub-adapter/          # v1.0 bolt-on adapter (frozen)
│   ├── fan-tub-adapter-base/     # v2.0 base plate (caulked to lid)
│   ├── fan-tub-adapter-clip/     # v2.0 retention clip (snap-fit)
│   └── vent-adapter/             # Vent duct adapter (placeholder)
│       ├── spec.json             #   Expected dimensions & tolerances
│       ├── <name>.scad           #   Parametric OpenSCAD source
│       ├── output/               #   Generated STL + PNGs (gitignored)
│       └── reference/            #   Photos, datasheets
├── docs/
│   └── images/              # Render images for documentation
├── lib/
│   ├── assembly.js          # Assembly check orchestrator
│   ├── loop.js              # Single-pass validation runner
│   ├── openscad.js          # OpenSCAD rendering (STL + PNG)
│   ├── python-bridge.js     # Node→Python subprocess bridge
│   ├── render-views.js      # 4-view PNG rendering
│   ├── stl-analyze.js       # STL analysis via node-stl
│   └── validate.js          # Spec validation logic
├── python/
│   ├── interference.py      # Mesh intersection checker (trimesh)
│   ├── fit_check.py         # Clearance/interference measurement
│   └── assembly_render.py   # Multi-part visualization (PyVista)
├── scad-lib/
│   ├── fdm-pla.scad         # FDM/PLA tolerance constants
│   ├── bambu-x1c.scad       # Build volume checks + dimension reporting
│   ├── common.scad          # Reusable modules (fdm_hole, bolt_pattern, etc.)
│   └── fan-tub-adapter-params.scad  # Shared params for v2.0 base + clip
└── test/
    ├── stl-analyze.test.js
    └── validate.test.js
```

## Setup

Requires **Node.js 18+**, **OpenSCAD**, and **Xvfb** (for headless rendering).

```bash
# Install system dependencies (Debian/Ubuntu)
sudo apt-get install -y openscad xvfb xauth

# Install Node dependencies
npm install

# Run tests
npm test
```

## Usage

```bash
# Full validation pipeline (render + analyze + validate)
node bin/validate.js designs/fan-tub-adapter

# Render only (STL + PNGs, skip spec validation)
node bin/validate.js designs/fan-tub-adapter --render-only

# Analyze only (use existing STL, skip rendering)
node bin/validate.js designs/fan-tub-adapter --analyze-only
```

## Validation Pipeline

The pipeline checks:

| Check | What it does |
|-------|-------------|
| **Bounding box** | STL dimensions match `spec.json` within tolerance |
| **Echoed dimensions** | Values from OpenSCAD `report_dimensions()` match spec |
| **Watertight** | Mesh is closed (no holes — required for slicing) |
| **Max dimensions** | Part fits on the build plate |
| **Volume** | Material volume within expected range |

## Designs

### Fan-Tub Adapter

Mounts a 119mm waterproof fan into a 2x2 waffle-cutout in an HDPE tub lid for a mushroom cultivation Martha tent. Y-shaped corner branches lock into the surrounding waffle channels for positive location. Center opening maximises airflow.

#### v1.0 — Bolt-On (Frozen)

Single-piece adapter secured with M4 bolts and thumbscrews.

![v1.0 isometric](docs/images/fan-tub-adapter/fan-tub-adapter-iso.png)

- **Retention**: 4x M4 bolts + hex nut counterbores (anti-rotation) through fan and plate
- **Lid attachment**: 2x M4 thumbscrews + wing nuts at diagonal corner T-junctions
- **Locating rim**: 1.5mm tall, drop-in fan alignment
- **Dimensions**: 196.2 x 196.2 x 6.5mm, 69.4 cm³
- **Print**: Single piece, bottom face on bed, no supports

| Qty | Fastener | Purpose |
|-----|----------|---------|
| 4 | M4 x 12mm socket head bolts | Fan to adapter |
| 4 | M4 nuts | Hex counterbores on bottom face |
| 2 | M4 x 16mm thumbscrews | Adapter to lid |
| 2 | M4 wing nuts | Below-lid clamping |

[Full Design Doc](docs/fan-tub-adapter.md) · [Source](designs/fan-tub-adapter/fan-tub-adapter.scad) · [Spec](designs/fan-tub-adapter/spec.json)

#### v2.0 — Tool-Free Clip System

Two-part design: permanently-caulked base plate + snap-on retention clip. No fasteners at all.

| | Base Plate | Retention Clip |
|---|---|---|
| ![Base plate](docs/images/fan-tub-adapter-base/fan-tub-adapter-base-iso.png) | ![Clip](docs/images/fan-tub-adapter-clip/fan-tub-adapter-clip-iso.png) | |

**Base plate** — Same waffle-grid branches as v1, but all bolt/thumbscrew holes removed. Locating rim increased to 4.0mm (from 1.5mm). Four clip ledges (1mm outward protrusions) on the rim exterior provide catch points for the clip. Attached to lid with silicone caulk — permanent, no tools.

**Retention clip** — A frame that sits on the fan top with four cantilever snap-fit arms. Each arm has a hook at the tip that catches under a base plate ledge. Press down to install, squeeze two opposite arms to release. Safety factor 2.06 (29 MPa stress vs 60 MPa PLA yield).

| Part | Dimensions | Volume | Print Orientation |
|------|-----------|--------|-------------------|
| Base plate | 196.2 x 196.2 x 9.0mm | 72.7 cm³ | Bottom face on bed |
| Clip | 129 x 129 x 25.6mm | 7.7 cm³ | Frame on bed, arms up |

**No fasteners. No tools for fan removal.**

[Full Design Doc](docs/fan-tub-adapter-v2.md) · [Base Source](designs/fan-tub-adapter-base/fan-tub-adapter-base.scad) · [Clip Source](designs/fan-tub-adapter-clip/fan-tub-adapter-clip.scad) · [Shared Params](scad-lib/fan-tub-adapter-params.scad)

#### v1.0 vs v2.0

| | v1.0 (Bolt-On) | v2.0 (Clip System) |
|---|---|---|
| Parts | 1 | 2 (base + clip) |
| Fasteners | 8 (bolts, nuts, thumbscrews, wing nuts) | 0 |
| Lid attachment | Thumbscrews (removable) | Silicone caulk (permanent) |
| Fan removal | Unbolt 4x M4 | Squeeze clip, lift |
| Tools needed | Hex key + fingers | Fingers only |
| Locating rim | 1.5mm | 4.0mm |
| Total print volume | 69.4 cm³ | 80.4 cm³ |

## Assembly Validation

Multi-part designs can be checked for assembly fit using the assembly pipeline. This uses Python (trimesh, PyVista) for mesh boolean operations and visualization.

```bash
# Setup Python environment (one-time, requires network)
sudo bash setup.sh

# Check an assembly
node bin/check-assembly.js assemblies/fan-tub-adapter-v2.json

# Skip visualization (faster)
node bin/check-assembly.js assemblies/fan-tub-adapter-v2.json --skip-viz
```

### Assembly Spec Format

Assembly specs live in `assemblies/<name>.json`:

```json
{
  "name": "my-assembly",
  "parts": [
    { "name": "base", "designDir": "designs/my-base", "position": [0, 0, 0] },
    { "name": "ref-part", "scadRef": "scad-lib/reference/part.scad", "position": [0, 0, 5], "reference": true }
  ],
  "checks": {
    "interference": [
      { "partA": "base", "partB": "ref-part", "maxVolume": 0.0 }
    ]
  },
  "fitSpecs": [
    { "name": "clearance-check", "partA": "base", "partB": "ref-part", "type": "clearance", "expected": { "min": 0.3, "max": 0.7 } }
  ]
}
```

### Pipeline Steps

| Step | Tool | What it does |
|------|------|-------------|
| **verify-parts** | Node.js | Check all STLs exist, render reference SCAD to STL |
| **interference** | trimesh (Python) | Boolean intersection volume between mesh pairs |
| **fit-spec** | trimesh (Python) | Clearance distances and interference measurements |
| **visualize** | PyVista (Python) | Assembly renders: iso, exploded, cross-section |

### Project Structure (Assembly)

```
assemblies/
├── fan-tub-adapter-v2.json    # Assembly spec
├── fan-tub-adapter-v2/
│   └── output/                # Generated assembly renders (gitignored)
└── reference-stls/            # Auto-rendered reference part STLs
python/
├── interference.py            # Mesh intersection checker
├── fit_check.py               # Clearance/interference measurement
└── assembly_render.py         # Multi-part visualization
scad-lib/reference/
└── fan-frame-119.scad         # 119mm fan frame (reference part)
```

## Adding a New Design

1. Create `designs/<name>/` with `spec.json` and `<name>.scad`
2. Include `fdm-pla.scad` and `bambu-x1c.scad` in your `.scad` file
3. Call `report_dimensions(x, y, z, "label")` to emit dimensions for validation
4. Run `node bin/validate.js designs/<name>` and iterate

See existing designs for the pattern.

## License

MIT
