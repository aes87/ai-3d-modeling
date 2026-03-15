# Y-Branch Arm — Waffle Channel Engagement Requirements

## Parent Design
humidity-output-v2 — see `designs/humidity-output-v2/requirements.md`

## Purpose
Verify that the Y-branch arm width (9.0mm) fits into the bin lid waffle grid channels (9.4mm wide) with the designed 0.2mm/side clearance. A too-wide arm prevents installation; too narrow risks poor alignment during caulk cure. This is a mating interface with only 0.4mm total diametric clearance — worth confirming before printing the full 196mm-span part.

## Verification Method
1. **Caliper arm width** at midpoint of each arm — expect 9.0 +/-0.3mm
2. **Trial fit**: insert both arms of the fork into actual waffle channels on the bin lid — arms should slide in without force but have minimal slop
3. **Check engagement length**: verify arms reach the expected 25mm insertion depth into channels

## Geometry
Extract a single corner Y-branch fork from the parent design:

- **Two arms** (one in +X direction, one in +Y direction) at full width (9.0mm) and full engagement length (25mm)
- **Root blob** at the fork junction (standard root geometry from parent)
- **Base plate section**: a minimal portion of the outer plate surrounding the fork root, approximately 30mm x 30mm, at full outer plate thickness (4.6mm). Extend just enough to structurally support the arms and provide bed adhesion
- **Rounded arm tips**: preserve the hull-cylinder tip geometry from the parent (arms use rounded cylinder endpoints)

Do NOT include: spigot, inner pad, other three corners, or any geometry unrelated to the single fork.

The fork root is at (73.1, 73.1) from the parent origin. For the test piece, translate so the root center is near the piece center, with the base plate section providing a flat bed face.

## Critical Dimensions
| Dimension | Nominal | Tolerance | How to verify |
|---|---|---|---|
| Arm width | 9.0 mm | +/-0.3 mm | Calipers at arm midpoint |
| Arm engagement length | 25.0 mm | +/-1.0 mm | Calipers or ruler, root to tip |
| Base plate thickness | 4.6 mm | +/-0.5 mm | Calipers on plate section |

## Parameters
Use parent parameters from `scad-lib/humidity-output-v2-params.scad` — do not hardcode duplicates.
Reference `ho2_branch_w`, `ho2_branch_len`, `ho2_branch_root`, `ho2_frame_t_outer` and other
`ho2_*` parameter names for all dimensions.

## Constraints
- Minimize material — this is a test piece, not the final part
- Must print flat on bed without supports (base plate bottom at z=0)
- Keep critical dimensions at full scale — no scaling
- Estimated print time: ~10 minutes
- Estimated material: ~3-5g PLA
