# 3D Printing Project

AI-native 3D modeling pipeline using OpenSCAD for parametric model generation.

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

## Workflow: The Ralph Wiggum Loop

1. User describes part → Claude writes `spec.json` + initial `.scad`
2. Run `node bin/validate.js designs/<name>`
3. Pipeline: OpenSCAD → STL + PNGs → `node-stl` analysis → spec validation
4. If FAIL: Claude reads structured error report, fixes `.scad`, re-runs (max 6 rounds)
5. If PASS: Claude reviews PNGs visually → Done

## Commands

```bash
# Setup (requires sudo — run once or rebuild container)
sudo bash setup.sh

# Install deps
npm install

# Run tests
npm test

# Validate a design (full pipeline)
node bin/validate.js designs/vent-adapter

# Render only (no spec check)
node bin/validate.js designs/vent-adapter --render-only

# Analyze only (skip rendering, use existing STL)
node bin/validate.js designs/vent-adapter --analyze-only
```

## Design Directory Convention

Each design lives in `designs/<name>/`:
- `spec.json` — expected dimensions, tolerances, constraints
- `<name>.scad` — OpenSCAD source (uses `scad-lib/` includes)
- `reference/` — photos, datasheets, existing models
- `output/` — generated STL + PNGs + validation report (gitignored)
- `iterations/` — round-by-round history (gitignored)

## OpenSCAD Libraries (`scad-lib/`)

- `fdm-pla.scad` — PLA tolerance constants
- `bambu-x1c.scad` — build volume assertions, dimension echo helpers
- `common.scad` — `fdm_hole()`, `fdm_shaft()`, `bolt_pattern()`, `chamfer_cylinder()`

Always include `fdm-pla.scad` and `bambu-x1c.scad` in design files.
Use `report_dimensions()` to echo computed bbox for validation parsing.

## Key Conventions

- OpenSCAD `ECHO:` lines on stderr are parsed for dimension reporting
- STL analysis via `node-stl` (bbox, volume, watertight check)
- Headless rendering via `xvfb-run` (OpenSCAD needs X11 even in CLI mode)
- Loop control is agent-driven — validation is a pure single-pass tool
- All JavaScript is ESM
- Tests use `node --test` (zero dev dependencies)
