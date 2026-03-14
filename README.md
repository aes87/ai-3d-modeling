# AI 3D Modeling

AI-native parametric 3D modeling pipeline. [Claude Code](https://docs.anthropic.com/en/docs/claude-code) designs parts in [OpenSCAD](https://openscad.org/), validates them automatically, and iterates until they pass. The human describes what they need; the AI handles all CAD work, iteration, and validation.

**Printer:** Bambu Lab X1 Carbon — 256 × 256 × 256 mm, 0.4mm nozzle, PLA.

## How It Works

1. Describe the part — dimensions, constraints, how it fits with other components
2. Claude writes `spec.json` (expected dimensions, tolerances) and a parametric `.scad` file using project libraries for FDM/PLA tolerances
3. Pipeline renders STL + PNGs, analyzes the mesh, and compares against spec
4. On failure: Claude reads the structured error report, fixes the `.scad`, re-runs (up to 6 rounds)
5. On pass: Claude reviews rendered PNGs visually — done

All FDM/PLA tolerance constants (press fit, clearance fit, hole compensation, wall minimums, overhang limits) live in [`scad-lib/fdm-pla.scad`](scad-lib/fdm-pla.scad) and are used by every design. Multi-part assemblies can be checked for fit and interference via a separate pipeline using trimesh + PyVista — see [`bin/check-assembly.js`](bin/check-assembly.js).

## Designs

| Design | Preview | Description | STL |
|--------|---------|-------------|-----|
| [Humidity-Output Duct Mount](docs/humidity-output.md) | ![](docs/images/humidity-output/humidity-output-iso.png) | Mounts a 4" flex dryer duct to the same waffle-cutout bin lid. Caulked base plate with Y-branch waffle engagement. Spigot accepts standard flex duct; sealed airtight with EPDM foam tape + releasable zip tie. Ridges auto-position the zip tie over the foam. | [STL](designs/humidity-output/humidity-output.stl) |
| [Fan-Tub Adapter v2.0](docs/fan-tub-adapter-v2.md) | ![](docs/images/fan-tub-adapter-base/fan-tub-adapter-base-iso.png) | Mounts a 119mm waterproof fan into a waffle-cutout HDPE tub lid for mushroom cultivation Martha tents. Two-part tool-free system: base plate caulked permanently to lid, snap-on retention clip with cantilever snap-fit arms and root fillets for fatigue resistance. Zero fasteners. | [Base](designs/fan-tub-adapter-base/fan-tub-adapter-base.stl) · [Clip](designs/fan-tub-adapter-clip/fan-tub-adapter-clip.stl) |
| [Fan-Tub Adapter v1.0](docs/fan-tub-adapter.md) *(frozen)* | ![](docs/images/fan-tub-adapter/fan-tub-adapter-iso.png) | Original single-piece bolt-on version of the fan mount. Notable for Y-branch waffle engagement, anti-rotation hex nut counterbores, and thumbscrew lid attachment. Superseded by v2.0. | [STL](designs/fan-tub-adapter/fan-tub-adapter.stl) |

> Preview images link directly to committed render files — they update automatically whenever a design is revised and pushed.

## Setup

Requires **Node.js 18+**, **OpenSCAD**, and **Xvfb** (headless rendering).

```bash
# Install system dependencies (Debian/Ubuntu)
sudo apt-get install -y openscad xvfb xauth

# Install Node dependencies
npm install

# Run tests
npm test
```

For assembly checking, also run `sudo bash setup.sh` to set up the Python venv (trimesh + PyVista).

## Usage

```bash
# Full validation pipeline (render + analyze + validate)
node bin/validate.js designs/<name>

# Render only
node bin/validate.js designs/<name> --render-only

# Analyze only (existing STL)
node bin/validate.js designs/<name> --analyze-only

# Check a multi-part assembly
node bin/check-assembly.js assemblies/<name>.json
```

## Adding a New Design

1. Create `designs/<name>/` with `spec.json` and `<name>.scad`
2. Include `fdm-pla.scad` and `bambu-x1c.scad`; call `report_dimensions(x, y, z, "label")`
3. Run `node bin/validate.js designs/<name>` and iterate
4. Add a row to the Designs table above with a link to `docs/<name>.md`

See existing designs for the pattern.

## License

MIT
