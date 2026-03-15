# AI 3D Modeling

AI-native parametric 3D modeling pipeline. [Claude Code](https://docs.anthropic.com/en/docs/claude-code) designs parts in [OpenSCAD](https://openscad.org/), validates them automatically, and iterates until they pass. The human describes what they need; the AI handles all CAD work, iteration, and validation.

**Printer:** Bambu Lab X1 Carbon — 256 × 256 × 256 mm, 0.4mm nozzle, PLA.

## How It Works

1. Describe the part — dimensions, constraints, how it fits with other components
2. Claude writes `spec.json` (expected dimensions, tolerances) and a parametric `.scad` file using project libraries for FDM/PLA tolerances
3. Pipeline renders STL + PNGs, analyzes the mesh, and compares against spec
4. On failure: Claude reads the structured error report, fixes the `.scad`, re-runs (up to 6 rounds)
5. On pass: geometry analyzer produces ground-truth printability data from the mesh
6. Print reviewer evaluates quantitative data and issues a final verdict

All FDM/PLA tolerance constants (press fit, clearance fit, hole compensation, wall minimums, overhang limits) live in [`scad-lib/fdm-pla.scad`](scad-lib/fdm-pla.scad) and are used by every design. Multi-part assemblies can be checked for fit and interference via a separate pipeline using trimesh + PyVista — see [`bin/check-assembly.js`](bin/check-assembly.js).

## Multi-Agent Architecture

Complex designs are handled by specialized agents, each with a focused role and its own context window. Agents communicate through structured files, not conversation history.

```
                          User
                           |
                     Orchestrator
                      (top-level)
                           |
              ┌────────────┼────────────┐
              v            v            v
         spec-writer   (decisions)   shipper
              |                        ^
              v                        |
     requirements.md              (all pass)
        spec.json                      |
              |            ┌───────────┤
              v            v           |
          modeler ──► geometry    fit-reviewer
           (×N)      analyzer      (if multi-
              |       (×N)          part)
              v            |           ^
        <name>.scad        v           |
        modeling-      geometry-       |
        report.json    report.json     |
              |        slicer-         |
              |        report.json     |
              v            |           |
         print-reviewer ◄─┘           |
              |                        |
              v                        |
        review-printability.md ────────┘
```

### Agent Roles

| Agent | Role | Tools | Inputs | Outputs |
|-------|------|-------|--------|---------|
| **spec-writer** | Intake requirements, screen for printability conflicts | Read, Write | User description | `requirements.md`, `spec.json` |
| **modeler** | Write OpenSCAD code, iterate against validation | Read, Write, Edit, Bash | `requirements.md`, `spec.json` | `<name>.scad`, `modeling-report.json` |
| **geometry-analyzer** | Mesh-based printability analysis from ground-truth geometry | Read, Bash | Rendered STL | `geometry-report.json`, `slicer-report.json` |
| **print-reviewer** | Evaluate printability from quantitative data, issue verdict | Read | Geometry + slicer reports | `review-printability.md` |
| **fit-reviewer** | Assembly interference and fit checks | Read, Bash | Multiple STLs, assembly spec | `review-fitment.json` |
| **shipper** | Copy outputs, update docs, commit and push | Read, Write, Edit, Bash | All reports | Committed artifacts |

### Pipeline by Complexity

| Complexity | Criteria | Pipeline |
|---|---|---|
| **Simple** | Single part, ≤5 features | `spec-writer` → `modeler` (inline print check) → `shipper` |
| **Medium** | Single part, >5 features | `spec-writer` → `modeler` → `geometry-analyzer` → `print-reviewer` → `shipper` |
| **Complex** | Multi-part assembly | `spec-writer` → `modeler` (×N parallel) → `geometry-analyzer` (×N parallel) → `print-reviewer` + `fit-reviewer` (parallel) → `shipper` |

### Geometry Analysis Pipeline

The geometry analyzer separates **measuring geometry** from **judging printability**:

1. **Mesh analysis** (`python/geometry_analyze.py`, trimesh) — slices the STL at every layer height, computing per-layer cross-sections, overhang angles, bridge spans, wall thicknesses, and transition detection. This is the ground truth for what the part actually looks like, independent of the SCAD source.

2. **Slicer analysis** (`python/slicer_analyze.py`, PrusaSlicer CLI) — slices with production settings, parses G-code for support requirements, bridge detection, and per-layer extrusion types. Uses the same engine as OrcaSlicer (Slic3r → PrusaSlicer → BambuStudio → OrcaSlicer lineage). Gracefully skipped if PrusaSlicer isn't installed.

The print-reviewer reads quantitative reports, not SCAD source. It falls back to source-code inference only when geometry reports are unavailable.

## Architecture Versions

| Version | Name | Key change |
|---------|------|------------|
| **v1** | Monolithic | Single CLAUDE.md with inline instructions. Validation pipeline renders + analyzes STL, but printability review is manual/inline. |
| **v2** | Multi-agent | Specialized agents (spec-writer, modeler, print-reviewer, fit-reviewer, shipper) with file-based handoff. Print reviewer reads SCAD source and does manual arithmetic. |
| **v3** | Ground-truth geometry | New geometry-analyzer agent produces mesh-based reports (trimesh layer slicing + PrusaSlicer G-code analysis). Print reviewer consumes quantitative data instead of inferring geometry from source. |

## Designs

| Design | Preview | Architecture | Description | STL |
|--------|---------|:------------:|-------------|-----|
| [Humidity-Output Duct Mount](docs/humidity-output.md) | ![](docs/images/humidity-output/humidity-output-iso.png) | v1 | Mounts a 4" flex dryer duct to the same waffle-cutout bin lid. Caulked base plate with Y-branch waffle engagement. Spigot accepts standard flex duct; sealed airtight with EPDM foam tape + releasable zip tie. Ridges auto-position the zip tie over the foam. | [STL](designs/humidity-output/humidity-output.stl) |
| [Fan-Tub Adapter v2.0](docs/fan-tub-adapter-v2.md) | ![](docs/images/fan-tub-adapter-base/fan-tub-adapter-base-iso.png) | v1 | Mounts a 119mm waterproof fan into a waffle-cutout HDPE tub lid for mushroom cultivation Martha tents. Two-part tool-free system: base plate caulked permanently to lid, snap-on retention clip with cantilever snap-fit arms and root fillets for fatigue resistance. Zero fasteners. | [Base](designs/fan-tub-adapter-base/fan-tub-adapter-base.stl) · [Clip](designs/fan-tub-adapter-clip/fan-tub-adapter-clip.stl) |
| [Fan-Tub Adapter v1.0](docs/fan-tub-adapter.md) *(frozen)* | ![](docs/images/fan-tub-adapter/fan-tub-adapter-iso.png) | v1 | Original single-piece bolt-on version of the fan mount. Notable for Y-branch waffle engagement, anti-rotation hex nut counterbores, and thumbscrew lid attachment. Superseded by v2.0. | [STL](designs/fan-tub-adapter/fan-tub-adapter.stl) |

> Preview images link directly to committed render files — they update automatically whenever a design is revised and pushed.

## Setup

Requires **Node.js 18+**, **OpenSCAD**, **Xvfb** (headless rendering), and optionally **PrusaSlicer** (slicer analysis).

```bash
# Install all system dependencies + Python venv (recommended)
sudo bash setup.sh

# Or install manually:
sudo apt-get install -y openscad xvfb prusa-slicer

# Install Node dependencies
npm install

# Run tests
npm test
```

The `setup.sh` script installs OpenSCAD, Xvfb, PrusaSlicer, and sets up a Python virtual environment with trimesh, PyVista, shapely, and manifold3d for mesh analysis.

## Usage

```bash
# Full validation pipeline (render + analyze + validate)
node bin/validate.js designs/<name>

# Render only
node bin/validate.js designs/<name> --render-only

# Analyze only (existing STL)
node bin/validate.js designs/<name> --analyze-only

# Geometry analysis (mesh + slicer, requires rendered STL)
node bin/geometry-analyze.js designs/<name>

# Geometry analysis (mesh only, skip slicer)
node bin/geometry-analyze.js designs/<name> --skip-slicer

# Check a multi-part assembly
node bin/check-assembly.js assemblies/<name>.json
```

## Adding a New Design

1. Create `designs/<name>/` with `spec.json` and `<name>.scad`
2. Include `fdm-pla.scad` and `bambu-x1c.scad`; call `report_dimensions(x, y, z, "label")`
3. Run `node bin/validate.js designs/<name>` and iterate
4. Run `node bin/geometry-analyze.js designs/<name>` for printability data
5. Add a row to the Designs table above with a link to `docs/<name>.md`

See existing designs for the pattern.

## License

MIT
