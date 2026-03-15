# 3D Printing Project

AI-native 3D modeling pipeline using OpenSCAD for parametric model generation.

## Multi-Agent Workflow

This project uses specialized agents to manage context across complex design tasks. Each agent has a focused role, its own context window, and communicates through structured files — not conversation history.

### When to use agents

| Complexity | Criteria | Pipeline |
|---|---|---|
| **Simple** | Single part, ≤5 features, no assembly | `spec-writer` → `modeler` (with inline print check) → `shipper` |
| **Medium** | Single part, >5 features | `spec-writer` → `modeler` → `print-reviewer` → `shipper` |
| **Complex** | Multi-part assembly | `spec-writer` → `modeler` (per part, parallel) → `print-reviewer` + `fit-reviewer` (parallel) → `shipper` |

### Agent dispatch rules

1. **Spec stage:** Dispatch `spec-writer`. Wait for `requirements.md` + `spec.json` before proceeding.
2. **Model stage:** Dispatch `modeler` with the design directory path. For multi-part assemblies, dispatch one modeler per part in parallel. Wait for all to report PASS.
3. **Review stage:** Dispatch `print-reviewer` and (if multi-part) `fit-reviewer` in parallel. Both are read-only — they report findings but don't modify code. If either reports FAIL, dispatch `modeler` with the specific fix instructions, then re-review.
4. **Ship stage:** Dispatch `shipper` once all reviews pass.

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
│   ├── validation-report.json ← pipeline output
│   ├── review-printability.md ← print-reviewer output (verbose)
│   ├── review-fitment.json   ← fit-reviewer output
│   ├── *.stl, *.png          ← rendered artifacts
│   └── iterations/           ← round-by-round history
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

The pipeline uses Python (trimesh + PyVista) via a project-local `.venv/`. Run `bash setup.sh` to set up.
Reference parts (external components) live in `scad-lib/reference/`.

## Key Conventions

- OpenSCAD `ECHO:` lines on stderr are parsed for dimension reporting
- STL analysis via `node-stl` (bbox, volume, watertight check)
- Headless rendering via `xvfb-run` (OpenSCAD needs X11 even in CLI mode)
- All JavaScript is ESM
- Tests use `node --test` (zero dev dependencies)
