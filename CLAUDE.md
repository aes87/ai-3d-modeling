# 3D Printing Project

AI-native 3D modeling pipeline using OpenSCAD for parametric model generation.

## Multi-Agent Workflow

This project uses specialized agents to manage context across complex design tasks. Each agent has a focused role, its own context window, and communicates through structured files — not conversation history.

### When to use agents

| Complexity | Criteria | Pipeline |
|---|---|---|
| **Simple** | Single part, ≤5 features, no assembly | `spec-writer` → `modeler` (with inline print check) → `shipper` |
| **Medium** | Single part, >5 features | `spec-writer` → `modeler` → `geometry-analyzer` → `print-reviewer` → `test-print-planner` → `modeler` (test pieces) → `shipper` |
| **Complex** | Multi-part assembly | `spec-writer` → `modeler` (per part, parallel) → `geometry-analyzer` (per part, parallel) → `print-reviewer` + `fit-reviewer` (parallel) → `test-print-planner` → `modeler` (test pieces, parallel) → `shipper` |

### Agent dispatch rules

1. **Spec stage:** Dispatch `spec-writer`. Wait for `requirements.md` + `spec.json` before proceeding.
2. **Model stage:** Dispatch `modeler` with the design directory path. For multi-part assemblies, dispatch one modeler per part in parallel. Wait for all to report PASS.
3. **Geometry stage:** Dispatch `geometry-analyzer` per part (parallel for multi-part). Produces `geometry-report.json` (mesh analysis) and `slicer-report.json` (PrusaSlicer G-code analysis, if slicer is installed). These are ground-truth geometry data for the reviewer.
4. **Review stage:** Dispatch `print-reviewer` and (if multi-part) `fit-reviewer` in parallel. The print-reviewer now reads quantitative geometry data from the analyzer, not SCAD source. Both are read-only. If either reports FAIL, dispatch `modeler` with the specific fix instructions, re-run geometry analysis, then re-review.
5. **Test print stage (optional):** Dispatch `test-print-planner` once all reviews pass. It reads the finalized reports, consumes upstream flags (`spec.json` → `testPrintCandidates`, `review-printability.md` → Test Print Recommendations), and produces `test-prints.json` + stub design directories. Then dispatch `modeler` for each test print (parallel). Test prints go through lightweight validation only (render + dimension check), not the full review pipeline. The orchestrator may skip this stage for simple parts or if the user opts out.
6. **Ship stage:** Dispatch `shipper` once all reviews and test prints are complete.

### Orchestrator responsibilities

The top-level conversation (you, reading this) is the **orchestrator**. You:
- Manage the user dialogue — questions, decisions, design intent
- Dispatch agents and read their **summaries** (not full reports)
- Make go/no-go decisions between stages
- Never hold full SCAD source, review arithmetic, or validation output in your context — that's what the agents are for

### Inter-agent communication

Agents communicate through files in `designs/<name>/`:
```
designs/<name>/
├── requirements.md           ← spec-writer output
├── spec.json                 ← spec-writer output
├── <name>.scad               ← modeler output
├── output/
│   ├── modeling-report.json  ← modeler output (dims + feature inventory)
│   ├── geometry-report.json  ← geometry-analyzer output (mesh analysis)
│   ├── slicer-report.json    ← geometry-analyzer output (PrusaSlicer analysis)
│   ├── validation-report.json ← pipeline output
│   ├── review-printability.md ← print-reviewer output (verbose)
│   ├── review-fitment.json   ← fit-reviewer output
│   ├── test-prints.json      ← test-print-planner output (manifest)
│   ├── *.stl, *.png          ← rendered artifacts
│   └── iterations/           ← round-by-round history
├── test-prints/              ← test print designs (planner + modeler output)
│   ├── <id>/
│   │   ├── requirements.md   ← test-print-planner output
│   │   ├── spec.json         ← test-print-planner output
│   │   ├── <id>.scad         ← modeler output
│   │   └── output/           ← rendered test piece artifacts
```

---

## Printer: Bambu Lab X1 Carbon

| Spec | Value |
|---|---|
| Build volume | 256 × 256 × 256 mm |
| Nozzle diameter | 0.4 mm |
| Layer height | 0.2 mm (default), 0.08–0.28 mm range |
| Default material | PLA |
| First layer width | 0.42 mm |

## FDM/PLA Tolerances

| Fit Type | Offset | Use Case |
|---|---|---|
| Press fit | −0.15 mm | Friction-held joints |
| Clearance fit | +0.25 mm | Easy insert/remove |
| Sliding fit | +0.35 mm | Moving parts |
| Hole compensation | +0.4 mm diameter | Bolt holes, dowel holes |
| Min wall thickness | 1.2 mm (3 perimeters) | Structural walls |
| Max overhang angle | 45° | Unsupported overhangs |
| Max bridge span | 10 mm | Horizontal bridging |

## Commands

```bash
# Setup (requires sudo — run once or rebuild container)
sudo bash setup.sh

# Install deps
npm install

# Run tests
npm test

# Validate a design (full pipeline)
node bin/validate.js designs/<name>

# Render only (no spec check)
node bin/validate.js designs/<name> --render-only

# Analyze only (skip rendering, use existing STL)
node bin/validate.js designs/<name> --analyze-only

# Geometry analysis (mesh + slicer, requires rendered STL)
node bin/geometry-analyze.js designs/<name>

# Geometry analysis (mesh only, skip slicer)
node bin/geometry-analyze.js designs/<name> --skip-slicer

# Check an assembly
node bin/check-assembly.js assemblies/<name>.json

# Skip visualization (faster)
node bin/check-assembly.js assemblies/<name>.json --skip-viz
```

## Design Directory Convention

Each design lives in `designs/<name>/`:
- `requirements.md` — structured requirements from spec-writer agent
- `spec.json` — expected dimensions, tolerances, constraints
- `<name>.scad` — OpenSCAD source (uses `scad-lib/` includes)
- `reference/` — photos, datasheets, existing models
- `output/` — generated artifacts (STL, PNGs, reports — gitignored)

## OpenSCAD Libraries (`scad-lib/`)

- `fdm-pla.scad` — PLA tolerance constants
- `bambu-x1c.scad` — build volume assertions, dimension echo helpers
- `common.scad` — `fdm_hole()`, `fdm_shaft()`, `bolt_pattern()`, `chamfer_cylinder()`

Always include `fdm-pla.scad` and `bambu-x1c.scad` in design files.
Use `report_dimensions()` to echo computed bbox for validation parsing.

## Assembly Checking

Assembly specs live in `assemblies/<name>.json` and define:
- **parts** — list of parts with positions (from `designs/` or reference SCAD)
- **checks.interference** — pairs to check for mesh overlap (with max allowed volume)
- **fitSpecs** — clearance/interference measurements with expected ranges

The pipeline uses Python (trimesh + PyVista + shapely) via a project-local `.venv/`. Run `bash setup.sh` to set up.
Reference parts (external components) live in `scad-lib/reference/`.

## Geometry Analysis Pipeline

The `geometry-analyzer` agent (and `bin/geometry-analyze.js` CLI) provides ground-truth printability data from the actual mesh, replacing source-code inference:

1. **Mesh analysis** (`python/geometry_analyze.py`, trimesh): slices the STL at every layer height, computes per-layer cross-sections, detects overhang faces, bridge spans, thin walls, and cross-section transitions.
2. **Slicer analysis** (`python/slicer_analyze.py`, PrusaSlicer CLI): slices the STL with production slicer settings, parses G-code for support requirements, bridge detection, and layer-by-layer extrusion types.

The print-reviewer agent consumes these reports (`geometry-report.json`, `slicer-report.json`) as primary inputs. It falls back to SCAD source reading only when geometry reports are unavailable.

## Key Conventions

- OpenSCAD `ECHO:` lines on stderr are parsed for dimension reporting
- STL analysis via `node-stl` (bbox, volume, watertight check)
- Mesh geometry analysis via `trimesh` (cross-sections, overhangs, wall thickness)
- Slicer validation via PrusaSlicer CLI (G-code analysis, support detection)
- Headless rendering via `xvfb-run` (OpenSCAD needs X11 even in CLI mode)
- All JavaScript is ESM
- Tests use `node --test` (zero dev dependencies)
