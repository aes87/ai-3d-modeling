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
├── bin/
│   └── validate.js          # CLI entry point
├── designs/
│   └── fan-tub-adapter/     # Each design in its own directory
│       ├── spec.json         #   Expected dimensions & tolerances
│       ├── fan-tub-adapter.scad  #   Parametric OpenSCAD source
│       ├── output/           #   Generated STL + PNGs (gitignored)
│       └── reference/        #   Photos, datasheets
├── docs/
│   └── images/              # Render images for documentation
├── lib/
│   ├── loop.js              # Single-pass validation runner
│   ├── openscad.js          # OpenSCAD rendering (STL + PNG)
│   ├── render-views.js      # 4-view PNG rendering
│   ├── stl-analyze.js       # STL analysis via node-stl
│   └── validate.js          # Spec validation logic
├── scad-lib/
│   ├── fdm-pla.scad         # FDM/PLA tolerance constants
│   ├── bambu-x1c.scad       # Build volume checks + dimension reporting
│   └── common.scad          # Reusable modules (fdm_hole, bolt_pattern, etc.)
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

| Design | Description | Doc |
|--------|-------------|-----|
| [fan-tub-adapter](designs/fan-tub-adapter/) | Adapter frame to mount a 119mm fan into a waffle-pattern tub lid | [Design Doc](docs/fan-tub-adapter.md) |

## Adding a New Design

1. Create `designs/<name>/` with `spec.json` and `<name>.scad`
2. Include `fdm-pla.scad` and `bambu-x1c.scad` in your `.scad` file
3. Call `report_dimensions(x, y, z, "label")` to emit dimensions for validation
4. Run `node bin/validate.js designs/<name>` and iterate

See existing designs for the pattern.

## License

MIT
