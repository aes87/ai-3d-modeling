# Modeler Notes — ptouch-cradle — Round 7 patch v11

**Based on:** patch-v10 ship state (commit `87783a1`) + two slicer-view
follow-up screenshots from the user. Tray-only patch; `cradle.scad` is
untouched.

## What the user saw

Two reference images in `/workspace/projects/obsidian-vault/vault/0-inbox/`,
both dated 2026-04-26, both slicer views of the front-left tray corner:

1. `2026-04-26 odd gap between front of tray adornments and sidewall- should connect smoothly and continuously Screenshot 2026-04-26 173354.png`
   — the S-curve sweep face (slicer perimeters, coral) and the side-wall
   face (purple) **do not meet**: a thin wedge of empty space sits
   between them at the corner.
2. `2026-04-26 Discontinuous thin front face on front wall of tray Odd--should be removed when other discontinuity fixed Screenshot 2026-04-26 173546.png`
   — closer angle showing a thin vertical strip of front-wall material
   standing apart from the side wall. User noted explicitly: "should
   be removed when other discontinuity fixed" — recognized both
   artifacts share a root cause.

The full vault next-steps note that triggered this patch:
`/workspace/projects/obsidian-vault/vault/projects/3d-printing/ptouch-cradle-v11-next-steps.md`.

## Root cause (verbatim from the vault note)

1.6 mm height mismatch between the S-curve cutter's outer-edge top z
and the side-wall cap's outer-edge top z, at the front-wall-slab
corner column (x ∈ [0, wall_t]).

- **Side-wall cap** (r = wall_t = 1.6, applied where y < ext_d - wall_t -
  0.05 = 92.55): rolls from outer face (x=0) at z = top - r = **28.4**
  to inner face (x=wall_t=1.6) at z = top = 30. So the OUTER-edge top
  of the side wall is at **z = 28.4**.
- **Front-wall-slab cutter S-curve** (applied where y ∈ [91.6, 95.2]):
  outer-edge tangent point was (x=0, z=top=30). So the OUTER-edge top
  of the front wall slab at the corner was at **z = 30**.

These differed by `wall_t = 1.6 mm`. Patch v10 clipped `back_sides_mask`
to y ≤ 92.55 to decouple coincident CSG planes for clean watertight
CGAL — that clip means the cap doesn't operate in the front-wall-slab
corner column, so the corner column's outer edge followed the cutter
alone (z=30 at x=0), not the cap (z=28.4 at x=0).

Visible consequences both stem from this single mismatch:
- **Gap (image 1):** the S-curve sweep face starts 1.6 mm above where
  the side-wall cap ends. From the corner angle, the two surfaces
  don't connect — there's a thin V-wedge of empty space.
- **Thin front face (image 2):** at y=92.55, top z jumps from 28.4 (cap
  surface) to 30 (full corner column). 1.6 mm × 0.05 mm × 1.6 mm (X)
  thin step face — visually reads as a discontinuous ridge.

## Option A applied (lower the S-curve top to match the cap outer-edge)

Recommended in the vault next-steps note. Change the S-curve top tangent
point from `(0, ext_h)` = `(0, 30)` to `(0, ext_h - top_edge_fillet_r)` =
`(0, 28.4)`. Two equal-radius tangent-continuous quarter-arcs over the new
18.4 mm Z-drop give r_each = 9.2.

Rejected alternatives:
- **Option B** (extend cap into corner column): re-introduces the v10
  CGAL coincident-plane issue at y=92.6.
- **Option C** (3D outer profile in cutter): Significantly more
  machinery for the same visual outcome A achieves with simpler arc
  adjustment.

## Specific changes (this patch)

### `tray.scad`

1. **New derived parameter** (declared after `top_edge_fillet_r`):
   ```openscad
   s_curve_top_z = ext_h - top_edge_fillet_r;   // 30 - 1.6 = 28.4
   ```

2. **`front_wall_side_fillet_r_each`** changed from a literal `10` to
   `(s_curve_top_z - front_wall_h) / 2` = **9.2**. Total horizontal
   extent per side `front_wall_side_extent` becomes 2 * 9.2 = **18.4**
   (was 20).

3. **OUTER cutter polygon arc centers** in
   `_front_wall_top_cutter_pts_outer()`:
   - LEFT top arc: center moved from `(0, ext_h - r)` = `(0, 20)` to
     `(0, s_curve_top_z - r)` = `(0, 19.2)`. Sweep θ ∈ [0°, 90°] CCW;
     endpoints `(9.2, 19.2)` (inflection, vertical tangent) → `(0, 28.4)`
     (outer top, horizontal tangent).
   - LEFT bottom arc: center stays at `(2*r, front_wall_h + r)` =
     `(18.4, 19.2)` (was `(20, 20)`). Sweep θ ∈ [270°, 180°] CW;
     endpoints `(18.4, 10)` (inner endpoint, horizontal tangent) →
     `(9.2, 19.2)` (inflection, vertical tangent).
   - Mirror for RIGHT side. Inflection point per side moves from
     `(10, 20)` to **`(9.2, 19.2)`** — both X and Z shift because the
     height drop is centered around the new midpoint.

4. **OUTER cutter polygon walks an extended vertex list** (CCW):
   ```
   1.  (-slop, ext_h + slop)            top-left of cut region
   2.  (ext_w + slop, ext_h + slop)     top-right of cut region
   3.  (ext_w + slop, ext_h)            step down to right outer edge at z=ext_h
   4.  (ext_w, ext_h)                   right corner-column outer-top corner   ← NEW
   5.  RIGHT top-arc samples            (ext_w, s_curve_top_z) → ...
   6.  RIGHT bottom-arc samples         → (ext_w - 2r, front_wall_h)
   7.  LEFT bottom-arc samples          (2r, front_wall_h) → ...
   8.  LEFT top-arc samples             → (0, s_curve_top_z)
   9.  (0, ext_h)                       left corner-column outer-top corner    ← NEW
   10. (-slop, ext_h)                   step up to left slop close              ← NEW
       (closes back to 1.)
   ```
   The new vertices 4, 9, 10 carve the corner column's outer-edge top
   from z=ext_h=30 down to z=s_curve_top_z=28.4 via a vertical step at
   x=ext_w (and x=0).

5. **INNER cutter polygon** (`_front_wall_top_cutter_pts_inner()`)
   updated symmetrically: same arc centers, same flatten-to-flat-top
   logic, but the two outer-edge corner vertices (first sample of
   right_top_arc; last sample of left_top_arc) are now naturally at
   z = s_curve_top_z (not ext_h) since that's where the new arcs
   start/end. The flatten function pins those vertices via
   `keep_first_z=true` / `keep_last_z=true` flags — the natural
   value is now 28.4, matching the OUTER profile, so the per-vertex
   inner→outer Y-slab lerp produces vertical (not skewed) outer-side
   wall faces.

6. **Asserts updated:**
   ```openscad
   assert(front_wall_side_fillet_r_each * 2 == (s_curve_top_z - front_wall_h),
          "Patch v11: each S-curve arc r must equal half the (s_curve_top_z - front_wall_h) drop");
   assert(s_curve_top_z == ext_h - top_edge_fillet_r,
          "Patch v11: S-curve top must match the side-wall cap outer-edge top (z = ext_h - top_edge_fillet_r)");
   ```
   The `2 * front_wall_side_extent <= ext_w` assertion still holds
   (36.8 ≤ 103.2 ✓).

7. **Header comment block** rewritten with a new "ROUND-7 PATCH v11"
   section documenting the user-visible issue, root cause, fix, and
   geometric consequences. Existing v10 / v9 / v8 history sections
   preserved verbatim.

### Things v11 deliberately does NOT touch

- `top_edge_fillet_r` (= 1.6, = wall_t) — Option-C cap construction
  unchanged.
- `back_sides_mask` y-clip at `ext_d - wall_t - 0.05 = 92.55` — the
  v10 watertight fix is preserved verbatim.
- `front_top_edge_fillet_r` (= 0.8) — front-wall flat-top fillet
  unchanged.
- `front_wall_y_slabs` (= 16) — Y-slab count unchanged (inner→outer
  lerp count is the same).
- Cavity cutter, parabolic ramp, vertical edge fillets — all unchanged.
- `cradle.scad` — completely untouched.

## Verification

| Metric | v10 (pre-patch) | **v11 (this patch)** |
|---|---|---|
| `is_watertight` | true | **true** |
| broken faces | 0 | **0** |
| bbox (mm) | 103.2 × 94.2 × 30 | **103.2 × 94.2 × 30** |
| volume (mm³) | 38241.73 | **38195.84** |
| face count | 26520 | 26100 |
| thin walls | 26 | **24** |
| overall_pass | false | false (thin walls + 1 false-pos bridge) |

**Bbox unchanged** (103.2 × 94.2 × 30) — only the front-wall-slab
cutter's outer-edge top z drops; the cap apex still reaches z=ext_h=30
at the inner face of the back/side walls, so the overall mesh extends
to z=30.

**Watertight TRUE** preserved. Option-C decoupling at y=92.55 from v10
is unchanged and continues to do its job.

**Volume drop ~46 mm³** — the corner column's outer-edge slab, x ∈
[0, wall_t] × y ∈ [92.55, 94.2] × z ∈ [28.4, 30] = 1.6 × 1.65 × 1.6 ×
2 corners ≈ 8 mm³ of material removed per corner. The remaining
~30 mm³ comes from the slightly wider S-curve flat middle (front_wall
slab now spans `[18.4, 84.8]` instead of `[20, 83.2]` — 3.2 mm wider
flat top at z=10 with a 1.6 mm wall thickness, but offset by the v9
3D-blend slope that cuts material in the corner zones).

### Thin-wall delta

| z (mm) | v10 count | **v11 count** |
|---|---|---|
| 10.1 | 2 | 2 |
| 12.1 | 2 | 2 |
| 14.1 | 2 | 2 |
| 16.1 | 2 | 2 |
| 18.1 | 2 | 2 |
| 20.1 | 2 | 2 |
| 22.1 | 2 | 2 |
| 24.1 | 2 | 2 |
| 26.1 | 2 | 2 |
| **28.1** | **2** | **0** ← v11 drops these (corner column outer-edge no longer reaches z=28+) |
| 29.5 | 1 | 1 |
| 29.7 | 1 | 1 |
| 29.9 | 4 | 4 |
| **Total** | **26** | **24** |

The 18 v9-baseline corner-column slivers at z ∈ [10.1, 26.1] persist —
they're inherent to the 3D corner blend's wall-top slope (outer rises
to 28.4, inner stays at 10) over wall_t=1.6 mm. The 6 cap-apex
slivers at z ≥ 29.5 also persist — those are inherent to the
r=wall_t cap rolling to a point at the inner face. **Patch v11
removes the 2 slivers at z=28.1** that came from the old corner
column reaching all the way to z=30. The rest remain accepted as
the same printability tradeoff documented in v9 + v10.

### Visual delta

`tray-iso.png` and `tray-cap-detail.png` re-rendered:
- Cap apex (back/sides, inner-face z=30) unchanged — clean rolled
  curve from outer at z=28.4 to inner at z=30.
- Front-wall S-curve sweep now connects continuously into the cap
  surface at the corner. No gap, no thin step, no V-wedge. The S-curve
  outer top tangent lands exactly at the cap outer-edge top — both at
  z=28.4 — producing one continuous form across the corner.
- Front-wall flat middle slightly wider than v10 (18.4..84.8 vs
  20..83.2). The S-curve sweeps are slightly tighter (r=9.2 vs r=10)
  but visually nearly identical — the curvature change is sub-visual at
  the design's overall scale.

`tray-user-front-threequarter.png` re-rendered with a representative
camera. The corner area shows a smooth continuous transition from
side-wall cap surface into S-curve sweep — exactly what the brief
intends ("connect smoothly and continuously").

The v9-baseline thin corner-column slivers (z ∈ [10.1, 26.1]) and the
r=wall_t cap-apex slivers (z ≥ 29.5) are still present and still
accepted as documented in v9 + v10 modeler-notes. They're inherent
to the 3D-blend + r=wall_t cap construction, not introduced or
worsened by v11.

## Affects spec? no

- Exterior dimensions unchanged (103.2 × 94.2 × 30).
- Wall thickness unchanged (1.6 mm).
- S-curve construction is brief-level prose, not a spec.json
  validation target. The spec's `tray_front_wall_side_fillet_r: 20`
  was an aesthetic-tier value from round 7 (single quarter-arc r=20);
  the patch v9 S-curve already departed from that to `r_each=10` and
  was not respec'd. v11's `r_each=9.2` continues that aesthetic
  expression without a spec change.

## Brief update applied

`brief.md`:
1. Feature-by-feature prose for the S-curve sweep updated to mention
   that the S-curve and cap form one continuous surface at the corner
   (S-curve top tangent at z=ext_h-top_edge_fillet_r, not z=ext_h).
2. No fillet_schedule values changed.

## Files changed

- `designs/ptouch-cradle/tray.scad` — header v11 section, derived
  param `s_curve_top_z`, updated `front_wall_side_fillet_r_each`,
  updated `_front_wall_top_cutter_pts_outer()` and
  `_front_wall_top_cutter_pts_inner()` (arc centers + new corner
  vertices), updated asserts, updated cutter comment block.
- `designs/ptouch-cradle/id/brief.md` — S-curve feature prose updated.
- `docs/ptouch-cradle.md` — caption updates, spec-table row update,
  features paragraph update, design log v11 entry appended.
- `designs/ptouch-cradle/output/tray.stl` — re-rendered.
- `designs/ptouch-cradle/output/tray-geometry-report.json` — refreshed.
- `designs/ptouch-cradle/output/tray-iso.png`,
  `tray-cap-detail.png`, `tray-user-front-threequarter.png` —
  re-rendered.

## Honest assessment for orchestrator

**Visual brief alignment:** YES. The corner gap and the thin front
face are gone. From the iso and user-front-threequarter angles the
S-curve and cap read as one continuous surface — matching the design
intent verbatim.

**Mesh quality:** unchanged or marginally better. Watertight stays
TRUE (Option-C decoupling preserved). Thin-wall count drops 26 → 24
because the 2 z=28.1 corner-column slivers are gone (the corner
column outer-edge no longer extends past z=28.4).

**Cradle:** untouched.

**Surprise:** none. The new arc geometry didn't perturb the
front_top_mask range — the mask uses
`x_left = wall_t + front_wall_side_extent` which now evaluates to
`1.6 + 18.4 = 20.0` (was `1.6 + 20 = 21.6`). The Y-slab stack code
in `front_wall_top_cutter()` is unchanged — it still walks
`front_wall_y_slabs = 16` slabs across `[ext_d - wall_t, ext_d]`
and lerps inner_pts ↔ outer_pts. The vertex count of the polygons
grew by 3 (vertices 4, 9, 10), but inner and outer have the same
count, so per-vertex lerp continues to work uniformly.
