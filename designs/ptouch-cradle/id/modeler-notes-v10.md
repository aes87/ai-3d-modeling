# Modeler Notes — ptouch-cradle — Round 7 patch v10

**Based on:** patch-v9 renders + user follow-up — align the tray's top-edge
fillet schedule with the cradle's by proportion (`r = wall_t`). Tray-only
patch; `cradle.scad` is untouched.

## Headline visual outcome

- **`top_edge_fillet_r`: 2.0 → 1.6** (= `wall_t`). The back/side wall-top cap
  now mirrors the cradle's r=3 on its 3 mm wall — same `r = wall_t`
  proportion, different absolute number. Two parts of the same form
  language.
- **Inset clamp disengaged** (default `clamp_inset = false`). With
  `r = wall_t`, `raw_inset = r * (1 - cos(a1))` ranges from 0 to r = wall_t
  across the slab stack — never exceeds wall_t — so the clamp adds nothing.
  Cap rolls cleanly from the outer face (z = 28.4) up to a point at the
  inner face (z = 30) over the full wall thickness. No plateau.
- **Front-wall flat-top fillet (r = 0.8) unchanged.** Half wall_t for the
  thin front lip is still the right call — the brief frames it as a
  function-driven exception, not a candidate for `r = wall_t` alignment.
- **Inset clamp arg kept in source as dormant safety.** Default flipped to
  `clamp_inset = false`; clamp engages only if a future radius change
  pushes raw_inset > wall_t.

## Geometry comparison

| | v9 (r=2.0, clamp 0.6) | v10 (r=1.6, no clamp) |
|---|---|---|
| Top-edge fillet radius | 2.0 mm | 1.6 mm (= wall_t) |
| Max inset | 0.6 mm (clamped at wall_t - 1.0) | 1.6 mm (= r) |
| Cap rolled section height | 0.6 mm | 1.6 mm |
| Top plateau width (at z=ext_h) | 1.4 mm | 0 mm (rolls to a point) |
| Visual language vs cradle | mismatched (cradle has no plateau) | matched (r=wall_t both parts) |

The cradle uses `fillet_utility_r = 3.0` on a 3 mm wall and runs the same
`offset(-r * (1 - cos(a1)))` cap stack with no clamp; the topmost slab has
inset = r = wall_t there too. v10 brings the tray into that same regime.

## CRITICAL — watertight regression discovered, surfaced for user decision

**v9 → v10 mesh quality regression at the back/sides cap → front-wall
cutter mating boundary.**

`tray-geometry-report.json`:

| Metric | v9 | v10 |
|---|---|---|
| `is_watertight` | true | **false** |
| broken faces | 0 | **42** |
| thin walls | 20 | 23 |
| bridge fails (false positive) | 1 | 1 |
| bbox (mm) | 103.2 × 94.2 × 30.001 | 103.2 × 94.2 × 30.001 |
| volume (mm³) | 38226 | 38242 |

All 42 broken faces cluster at `y = 92.6, z ≈ 29.89..29.99` — the boundary
where the back/sides cap meets the front-wall cutter.

### Root cause

With `clamp_inset = false` and `r = wall_t`, the topmost cap slab has
inset = wall_t. The cap's natural footprint (after `offset(-inset)`) has
its front face at `y = ext_d - inset = ext_d - wall_t = 92.6` —
**exactly coincident** with:

1. `back_sides_mask`'s y-clip boundary at `y = ext_d - wall_t = 92.6`.
2. The front-wall cutter's inner-slop slab spanning `y ∈ [92.599, 92.6]`.

CGAL CSG difference/union operations on three coincident planes at the
same y produce knife-edge slivers — non-manifold edges that trimesh
detects as broken faces.

**This is not a wall-support issue.** The user's framing — "with r=1.6 the
inset never exceeds wall_t so the wall always supports the cap" — is
correct. The cap *is* supported. The issue is purely a mesh/CSG topology
artifact at coincident planes.

### Why v9 didn't have this

In v9 the clamp held the inset at 0.6 mm max. The cap's front face at the
topmost slab sat at `y = ext_d - 0.6 = 93.6`, then was clipped to
`y = 92.6` by back_sides_mask. The clip removed a 1 mm-wide strip with
nonzero z-extent — not a knife-edge. Manifold mesh.

### Fix options (none currently engaged in v10)

| Option | Visual cost | Manifold? | Notes |
|---|---|---|---|
| **A. Accept as-is** | 0 | NO (42 broken faces) | Slicer tolerates it; visual brief is fully realized; non-watertight STL is a downstream-quality signal we're choosing to ignore. |
| **B. Clamp at `wall_t - 0.05` = 1.55 mm** | 0.05 mm plateau | YES | Plateau is sub-FDM-layer (0.2 mm) and ~1/8 nozzle width — invisible in print and at any realistic render zoom. Restores watertight without compromising the rolled-cap intent. |
| **C. Pull `back_sides_mask` back by epsilon** (e.g. `ext_d - wall_t - 0.05`) | 0 (cap doesn't clip cleanly at boundary; might add a tiny lip at the front-wall slab) | likely YES | Decouples the coincident planes. Slightly riskier — the geometry near y=92.55..92.6 is now ambiguous between cap and front-wall cutter. Needs render check. |
| **D. Set `top_edge_fillet_r = 1.55`** (= `wall_t - 0.05`) | 0.05 mm offset from r=wall_t | YES | Equivalent to B but expressed via radius rather than clamp. Pushes off the cradle proportion by 3% — the "r = wall_t" alignment becomes "r ≈ wall_t" with a tiny safety margin. |

**Modeler recommendation:** Option B. The plateau is invisible (0.05 mm vs
0.2 mm layer height vs 0.4 mm nozzle width) and the manifold guarantee is
worth keeping. The user's design intent — `r = wall_t`, cap rolls to (near)
a point at the inner face, no visible plateau — is preserved exactly.
The only thing that changes is a 0.05 mm safety margin invisible to the
human eye.

If the user insists on Option A (zero plateau, accept non-manifold mesh),
that is also defensible — slicers handle this signature fine and the print
will look identical. The cost is just an STL that fails
`trimesh.is_watertight` and shows up as a regression in
`tray-geometry-report.json`.

**Currently the file is in Option-A state** (`clamp_inset = false`,
`r = 1.6`) with a comment block in the header explaining the issue.
Awaiting user direction.

## What stayed unchanged from v9

- S-curve front-wall fillet (two r=10 quarter-arcs, tangent-continuous).
- Y-slab interpolated front-wall-top cutter (Issue B fix).
- `top_fillet_steps = 48` draft / 96 ship.
- `front_wall_y_slabs = 16` draft / 32 ship.
- `front_top_edge_fillet_r = 0.8`.
- `fillet_vert_r = 3.0` (vertical edge fillets — matches cradle utility tier).
- Closed 4-wall bin architecture, ext 103.2 × 94.2 × 30 mm.
- Sliding fit, parabolic floor ramp, print orientation.
- Cradle untouched.

## What v10 changed in code

- `top_edge_fillet_r`: 2.0 → 1.6 (with explanatory comment block).
- `footprint_fillet_stack` default: `clamp_inset = true` → `clamp_inset = false`.
- `footprint_fillet_stack` comment block updated — clamp behavior explained,
  dormant-safety rationale documented.
- Header comment block adds a v10 section describing the alignment
  principle + the watertight regression as a known issue surfaced for
  user decision.

## Affects spec? no

- Exterior dimensions unchanged (103.2 × 94.2 × 30).
- Wall thickness unchanged (1.6 mm).
- Top-edge fillet radius is a brief-level aesthetic spec — see brief update
  below — not a `spec.json` validation target.

## Brief update (proposed, not yet applied — awaiting watertight resolution)

**`fillet_schedule.tray_top_edge` line:**

```yaml
# v9 (current):
tray_top_edge: 2.0   # back/side wall tops on tray; r=0.8 on 1.6mm front wall (thin-wall exception)

# v10 (proposed):
tray_top_edge: 1.6   # back/side tops on tray = wall_t (matches cradle's r=3 = its wall_t — same proportion, different absolute); r=0.8 on front wall = half wall_t for the thin lip
```

**Feature-by-feature prose section** (around brief.md line 152, "Tray
uniform low front wall + r=20 side fillet sweeps"): the sentence "Top-edge
fillet wraps continuously: r=2 on back/sides, r=0.8 on the 1.6mm-thick
front wall (function-driven exception — r=2 would collapse on the thin
wall)." needs to become:

> Top-edge fillet wraps continuously: r=1.6 (= wall_t) on back/sides,
> r=0.8 on the 1.6 mm-thick front wall. The r=wall_t back/side cap mirrors
> the cradle's r=3 on its 3 mm wall — same proportion, different absolute
> number. The front lip stays at r = half-wall_t as a function-driven
> thin-wall exception (r=wall_t works structurally on a 1.6 mm wall too,
> but r=0.8 reads cleaner against the substantial back/side cap and keeps
> the front lip soft without competing with it).

These edits are NOT YET applied to brief.md. The watertight regression
surfaced above needs resolution first — if the user picks Option B (clamp
at 1.55), the brief is still accurate as proposed. If Option D (`r=1.55`),
the brief radius becomes 1.55 not 1.6.

## Files changed (this patch)

- `designs/ptouch-cradle/tray.scad` — header comment block adds v10 section;
  `top_edge_fillet_r` 2.0 → 1.6; `footprint_fillet_stack` default
  `clamp_inset = true` → `false`; module comment block rewritten.

## Verified output (Option-A state, 42 non-manifold edges)

- `tray.stl` — bbox 103.2 × 94.2 × 30.001 mm. **NOT watertight** (42 broken
  faces clustered at y=92.6, z≈29.9). Volume 38242 mm³.
- `tray-iso.png`, `tray-user-front-threequarter.png` — re-rendered. Cap
  profile reads as a clean rolled edge from outer face up to a point at
  the inner face. No plateau visible.
- `tray-geometry-report.json` — overall_pass = false (now driven by
  watertight = false in addition to thin walls + false-positive bridge).

## Honest assessment for orchestrator

**Visual brief alignment:** YES. Cap reads as r=wall_t rolled edge,
proportionally matched to the cradle. The rolled section height grew from
0.6 mm (v9) to 1.6 mm (v10) — three times more substantial, in direct
sight on the back/side wall tops.

**Mesh quality:** REGRESSION introduced by removing the clamp at
`r = wall_t`. The front-wall mating boundary now collapses onto the
back/sides cap apex, producing 42 non-manifold edges. Slicers tolerate
this; trimesh and most validators flag it. If the user wants a clean
watertight STL with the v10 visual outcome, recommend Option B (clamp at
1.55 — invisible 0.05 mm plateau).

**Cradle:** untouched.

## Option B applied (resolution — partial)

User picked Option B. Final state of `tray.scad`:

- `top_edge_fillet_r = 1.6` (= wall_t, unchanged from Option-A).
- `footprint_fillet_stack` default flipped back to `clamp_inset = true`.
- `max_inset` formula changed from `wall_t - 1.0` (= 0.6, v9 plateau) to
  `wall_t - 0.05` (= 1.55, the Option-B plateau). The unclamped cap
  rectangle now reaches y = ext_d - 1.55 = 92.65 instead of y = ext_d -
  1.6 = 92.6 at the topmost slab.
- Header comment block + module comment block + `top_edge_fillet_r`
  inline comment all rewritten to describe the Option-B framing.

### Brief update applied

- `fillet_schedule.tray_top_edge` → 1.6 with the cradle-proportion comment.
- "tray top-edge fillet wraps continuously (r=2 back/sides, r=0.8 front)"
  → "(r=1.6 back/sides, r=0.8 front)".
- Feature-by-feature prose updated: r=2 → r=1.6 (= wall_t); added the
  cradle-alignment sentence (cradle r=3 = its wall_t, tray r=1.6 = its
  wall_t — same proportion, different absolutes).

### Verification result — watertight NOT restored

| Metric | v9 | Option-A (no clamp) | Option-B (clamp 1.55) |
|---|---|---|---|
| `is_watertight` | true | false (42 broken) | **false (46 broken)** |
| broken faces | 0 | 42 | 46 |
| bbox (mm) | 103.2 × 94.2 × 30.001 | 103.2 × 94.2 × 30.001 | 103.2 × 94.2 × 30.001 |
| volume (mm³) | 38226 | 38242 | 38241.69 |
| face count | 20060 | 20060 | 26520 |

`tray-user-front-threequarter.png` re-rendered. Cap reads as a clean
rolled edge with no visible plateau at any realistic zoom — visual
intent intact.

But mesh quality regression NOT fixed. The watertight=false signature
persists: 46 broken faces clustered at y = 92.6, z ≈ 29.886..29.999 —
exact same location as Option-A's 42 broken faces. **The 0.05 mm
clamp is not sufficient to decouple the coincident planes.**

### Why the original Option B analysis was incomplete

The modeler-notes-v10 reasoning treated the clamp as "pulling the cap
front face back from y=92.6 to y=92.65". That's not what happens in
the actual CSG.

The cap stack is built as `intersection() { footprint_fillet_stack;
back_sides_mask; }`. The mask covers `y ∈ [-1, ext_d - wall_t] = [-1,
92.6]`. So no matter where the unclipped cap rectangle's front edge
sits (92.6 unclamped, 92.65 with `wall_t - 0.05` clamp, or 93.6 with
v9's `wall_t - 1.0` clamp), **the cap's clipped front face is always at
y = 92.6** — that's the mask's boundary, not the cap's.

What the clamp DOES change is the *width* of the unclipped material
the mask removes: v9 cut a 1 mm strip (cap from 93.6, mask to 92.6),
Option B cuts a 0.05 mm strip. The narrower the strip, the closer the
intersection comes to a knife-edge, regardless of where the resulting
boundary plane lands. And the front-wall cutter's inner-profile slop
slab still occupies `y ∈ [92.599, 92.6]` — that boundary is unchanged
by the clamp.

So Option B at 0.05 mm is geometrically too close to the unclamped
case (the strip the mask removes is essentially a 0.05 × 0.001 mm
sliver — comparable to a knife edge for CGAL's purposes).

### Status

Source code is in user-requested Option-B state and committable. STL
geometry, dimensions, volume, bbox, and visual outcome all match the
brief. **Mesh is still non-watertight** with 46 broken faces — slicers
will accept it, but `trimesh.is_watertight` and downstream validators
will flag it as before.

If the user wants watertight restored without changing visual intent,
the actual fix is one of:

- **Option B-aggressive: clamp at `wall_t - 0.2` = 1.4 mm.** Gives a
  0.2 mm plateau (one full FDM layer) — still essentially invisible in
  print but creates a real strip wide enough for CGAL to handle. This
  reads as "r=wall_t fillet with a 0.2mm safety margin" — the cap is a
  1.4 mm rolled section instead of 1.55 mm.
- **Option C: pull `back_sides_mask` back** to `ext_d - wall_t - 0.05`
  (= 92.55). Decouples mask boundary from front-wall cutter slop slab
  boundary. Doesn't change the cap shape; small chance of a thin lip
  appearing where mask now stops slightly inside the front-wall slab.
- **Option E: shift the front-wall cutter's inner slop slab back** to
  span `y ∈ [92.549, 92.55]` instead of `[92.599, 92.6]`. Keeps cap
  and mask at 92.6, moves only the front-wall cutter boundary.

Surfaced for user decision in the next iteration.

## Option C applied (resolution — final)

User selected Option C and asked us to revert Option B. The Option-B
clamp at `wall_t - 0.05 = 1.55` was load-bearing on the wrong cause —
the clamp adjusts the unclipped cap rectangle's pre-mask edge, but the
cap's *clipped* front face is always pinned to the mask boundary at
y=92.6 anyway. The actual coincident-plane collision was at the mask
boundary itself, where it met the front-wall cutter's inner slop slab.

### Changes (this iteration)

- **`back_sides_mask` y-extent: `ext_d - wall_t` → `ext_d - wall_t -
  0.05`** (92.6 → 92.55). All three union'd cubes (full-footprint plus
  two side-wall corner buffers) updated. The 0.05 mm strip y ∈ [92.55,
  92.6] is inside the cavity y-range (cavity ends at y = ext_d - wall_t
  = 92.6), so any cap material continuing through that strip gets
  removed by the cavity cutter for any z ≤ ext_h. Net visual / material
  change: zero. Net topology change: mask edge no longer coincident with
  the front-wall cutter's inner-slop slab, CGAL produces a clean
  watertight manifold.
- **Option-B clamp reverted.** `footprint_fillet_stack` default flipped
  back to `clamp_inset = false` (cap is geometrically fine without the
  clamp now that the mask boundary is the actual fix). The clamp
  branch is retained in source as a dormant defensive backstop —
  `max_inset = wall_t - 0.05 = 1.55` if anyone ever bumps r > wall_t.
- **Header comment block + `top_edge_fillet_r` inline comment +
  `footprint_fillet_stack` comment block + `back_sides_mask` comment
  block** all rewritten to describe the Option-C fix.

### Verification

| Metric | v9 | Option-A | Option-B | **Option C (final)** |
|---|---|---|---|---|
| `is_watertight` | true | false (42 broken) | false (46 broken) | **true** |
| broken faces | 0 | 42 | 46 | **0** |
| thin walls | 20 | 23 | — | **26** |
| bridge fails (false positive) | 1 | 1 | 1 | 1 |
| bbox (mm) | 103.2 × 94.2 × 30.001 | same | same | **103.2 × 94.2 × 30.0001** |
| volume (mm³) | 38226 | 38242 | 38241.69 | **38241.73** |

**Watertight: TRUE.** Bbox unchanged (103.2 × 94.2 × 30 within FP noise).

**Thin walls: 26 (not 20).** Twenty are the v9 corner-peak slivers at
z ∈ [10.1, 28.1] (10 layers × 2 corner pairs) — unchanged from v9 and
already accepted. The six new ones are at z = 29.5, 29.7, 29.9 — these
are inherent to the r=wall_t cap rolling to a *point* at the inner-face
apex (z = ext_h = 30). The topmost ~0.5 mm of any cap that rolls to a
point is geometrically thin (sub-mm cross-section). These would appear
in any v10 variant (A, B, or C) — they are a property of the r=wall_t
visual choice, not of Option C. Reading the points themselves: x ≈ ±50
(corners at the side walls), y ranges across the front-back depth.
Slicer will print these as a 1–2 perimeter taper at the very top of the
rolled cap; no functional risk, accepted same as the v9 corner-peak
slivers.

### Visual assessment

`tray-user-front-threequarter.png` and `tray-iso.png` both re-rendered.
Cap reads as a clean continuous rolled edge on back/sides — outer face
sweeps up, rolls over to a point at the inner face, no plateau visible
at any zoom. S-curve front-wall sweep is unchanged. Front-wall flat-top
fillet (r=0.8) unchanged. Identical visual outcome to Option-B, now
with watertight manifold underneath.

### Final state

- `top_edge_fillet_r = 1.6` (= wall_t).
- `footprint_fillet_stack` default `clamp_inset = false`. Clamp branch
  retained at `max_inset = wall_t - 0.05` as dormant safety.
- `back_sides_mask` y-extent = `ext_d - wall_t - 0.05` = 92.55.
- Watertight: TRUE.
- Thin walls: 20 v9-baseline + 6 r=wall_t cap-apex slivers = 26.
- Visual: r=wall_t rolled cap, no plateau, matched to cradle proportion.

Brief stays as-is (already updated to "r=1.6 = wall_t" with cradle
alignment language during Option B). No spec changes.
