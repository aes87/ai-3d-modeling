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

## Printability Review

Run this whenever geometry changes. Think in **print orientation**, not installed orientation.

### Step 1 — State print orientation explicitly
Which face is on the bed? Which direction do features grow?
Document this in the design's `.md` file if it's non-obvious (e.g. "printed upside-down relative to installed orientation").

### Step 2 — List features in print-Z order (bed → tip)
Write them out in sequence. This forces you to think about what comes before what.

### Step 3 — Check every feature-to-feature transition
This is where overhangs hide. Features look fine in isolation — problems live at interfaces.
For each transition from feature A (below) to feature B (above):

> **Does feature B's first layer have its full XY cross-section covered by feature A's last layer?**

If not: is the unsupported extent ≤45° (≤0.2mm horizontal per 0.2mm layer height)?
If not: add a chamfer, fillet, or extend the supporting feature to cover the full cross-section.

**Write the arithmetic.** Don't eyeball. For each transition: state dimensions, compute the overhang distance, compare to the 45° limit. Example: "Ridge steps out 3mm over 4mm height → 3/4 = 0.75 < 1.0 (45° limit) → PASS."

**Protrusions need a dual check** — a feature that steps outward then back inward has two transitions:
1. **Underside** (step outward): does the protrusion's bottom face have support? Chamfer if not.
2. **Top edge** (step inward): does the body above the protrusion's top face have support, or does it overhang the protrusion's inner edge? Chamfer if not.

Both faces must pass independently. A chamfered underside does not fix an overhanging top edge.

**Conflict flag:** If a printability fix (chamfer, fillet, feature removal) changes the part's functional behavior — e.g., a chamfer removes a sealing surface, or removing a feature eliminates a hard stop — **stop and surface the conflict to the user** before making the change. Do not silently resolve functional trade-offs. State: what the fix is, what function it affects, and ask how to proceed.

Do NOT only check each feature independently. Always check the transition.

### Step 4 — Check tips and extremities
Hooks, ledge edges, arm tips, cantilevered tabs: small unsupported steps concentrate here.
For snap-fit hooks specifically, check **both faces**: outer (snap-in ramp) and inner (printability ramp).

### Step 5 — Check all horizontal spans
Any unsupported horizontal surface must bridge ≤10mm. Spans ≤2mm print reliably without support.

### Step 6 — Check mating part clearance
For any protrusion that a mating part must slide over (spigot, rim, guide feature): verify the protrusion OD vs. mating part ID explicitly. Write the numbers.

> **Protrusion OD must be < mating part ID** for slide-over. If OD ≥ ID, the mating part cannot pass — it becomes a hard stop, not a guide.

Slide-over and hard-stop roles are mutually exclusive for a given feature. Confirm which role each protrusion plays and verify its OD accordingly. If a protrusion is intended as a hard stop, confirm the mating part *cannot* pass (OD > ID) and that no other protrusion inadvertently blocks it from reaching the stop.

---

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

## Every Iteration Must Ship

After every design change — whether a validation fix, a user-requested revision, or a new feature — do ALL of the following before moving on:

1. **Run validation** (`node bin/validate.js`) and confirm PASS
2. **Run printability review** (see checklist above) whenever geometry changes — work through all six steps in print orientation, not installed orientation
3. **Re-render** all views including custom angles (top-down, bottom-iso, etc.) relevant to the design
4. **Copy outputs** — updated PNGs to `docs/images/<name>/`, STL to `designs/<name>/`
5. **Update the design's markdown doc** (`docs/<name>.md`) to reflect the current state: feature descriptions, render captions, geometry table, BOM, validation results. The doc must always describe what the part IS, not what it was three iterations ago.
6. **Commit and push to git** with a concise message explaining what changed and why
7. The markdown landing page is the user's primary way of reviewing the design. If it's stale, the user is reviewing the wrong thing.

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

## Assembly Checking

Multi-part assemblies can be checked for interference and fit using the assembly pipeline:

```bash
# Check an assembly (interference + fit specs + visualization)
node bin/check-assembly.js assemblies/fan-tub-adapter-v2.json

# Skip visualization (faster, no PyVista)
node bin/check-assembly.js assemblies/fan-tub-adapter-v2.json --skip-viz
```

Assembly specs live in `assemblies/<name>.json` and define:
- **parts** — list of parts with positions (from `designs/` or reference SCAD)
- **checks.interference** — pairs to check for mesh overlap (with max allowed volume)
- **fitSpecs** — clearance/interference measurements with expected ranges

The pipeline uses Python (trimesh + PyVista) via a project-local `.venv/`. Run `bash setup.sh` to set up.

Reference parts (external components like the fan frame) live in `scad-lib/reference/` and are rendered to STL automatically.

## Key Conventions

- OpenSCAD `ECHO:` lines on stderr are parsed for dimension reporting
- STL analysis via `node-stl` (bbox, volume, watertight check)
- Headless rendering via `xvfb-run` (OpenSCAD needs X11 even in CLI mode)
- Loop control is agent-driven — validation is a pure single-pass tool
- All JavaScript is ESM
- Tests use `node --test` (zero dev dependencies)
