# Gridfinity Bins

Custom Gridfinity-compatible storage bins designed from measured objects. Uses the parent 3d-printing pipeline with an image-intake front end.

## Workflow

1. **Intake**: User provides photos of object(s) on a scale grid + mating requirements
2. **Measurement**: Orchestrator extracts dimensions from grid photos, confirms with user
3. **Spec**: `spec-writer` generates requirements using Gridfinity constants from `scad-lib/gridfinity-spec.scad`
4. **Model → Review → Ship**: Standard pipeline from parent CLAUDE.md

## Gridfinity Libraries

All designs include the shared Gridfinity modules:

```openscad
include <gridfinity.scad>   // includes gridfinity-spec.scad automatically
include <bambu-x1c.scad>
```

Reference docs: `scad-lib/gridfinity-design-guide.md`

## Sizing Rules

When sizing a bin for a measured object:

1. Internal clearance: add 1-2 mm to object dimensions (easy insert/remove)
2. Wall consumption: 2 x 0.95 mm minimum (1.9 mm total from internal to external)
3. Grid units: `ceil((object_dim + clearance + walls) / 42)`
4. Height units: `ceil((object_height + clearance) / 7) + 1` (the +1 accounts for the base)
5. Verify internal depth: `height_units x 7 - 7.2` mm usable

## Validation

```bash
# From the 3d-printing project root
node bin/validate.js gridfinity-bins/designs/<name>
node bin/geometry-analyze.js gridfinity-bins/designs/<name>
```
