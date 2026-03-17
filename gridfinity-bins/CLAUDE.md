# Gridfinity Bins Subproject

Custom Gridfinity-compatible storage bins designed from measured objects.

## Workflow

This subproject uses the standard 3d-printing pipeline with an image-intake front end:

1. **Intake**: User provides photos of object(s) on a scale grid + mating requirements
2. **Measurement**: Orchestrator extracts dimensions from grid photos, confirms with user
3. **Spec**: `spec-writer` generates requirements using Gridfinity constants from `scad-lib/gridfinity-spec.scad`
4. **Model → Review → Ship**: Standard pipeline from parent project CLAUDE.md

## Design Directory Convention

Each bin design lives in `gridfinity-bins/designs/<name>/`:

```
gridfinity-bins/designs/<name>/
├── reference/                ← object photos on scale grid
│   ├── top.jpg               ← top-down view on grid
│   ├── front.jpg             ← front view on grid
│   ├── side.jpg              ← side view on grid
│   └── measurements.json     ← extracted dimensions from photos
├── requirements.md           ← spec-writer output
├── spec.json                 ← spec-writer output
├── <name>.scad               ← modeler output
└── output/                   ← generated artifacts
```

## Gridfinity Libraries

All designs should include the shared Gridfinity modules:

```openscad
include <gridfinity.scad>   // includes gridfinity-spec.scad automatically
include <bambu-x1c.scad>
```

Reference docs: `scad-lib/gridfinity-design-guide.md`

## Sizing Rules

When sizing a bin for a measured object:

1. Internal clearance: add 1–2 mm to object dimensions (easy insert/remove)
2. Wall consumption: 2 × 0.95 mm minimum (1.9 mm total from internal to external)
3. Grid units: `ceil((object_dim + clearance + walls) / 42)`
4. Height units: `ceil((object_height + clearance) / 7) + 1` (the +1 accounts for the base)
5. Verify internal depth: `height_units × 7 − 7.2` mm usable

## Validation

Uses the parent project's pipeline tools:

```bash
# From the 3d-printing project root
node bin/validate.js gridfinity-bins/designs/<name>
node bin/geometry-analyze.js gridfinity-bins/designs/<name>
```

## Printer

Same as parent project: Bambu Lab X1 Carbon, 0.4mm nozzle, 0.2mm layers, PLA.
