# Fan-Tub Adapter v3 Shroud Cap — Requirements

## Design Intent

Replacement for the v2.0 thin-ring retention clip. The v3 cap is a rigid box cap that drops over the fan top and wraps down around all four fan sides. This gives the cap structural rigidity (no more floppy ring) and self-centering behavior (inner wall face rides against fan frame). Two cantilever snap arms on the ±X sides extend below the cap wall bottom and hook under the base plate ledges to retain the fan with Z lift-off resistance.

The cap is installed by pressing it down over the fan. Cap walls self-center on the fan frame. Arms enter the base plate guide channels (which constrain Y displacement), and hooks snap under the ledge flat zone at z=7–9 with an audible click. Removal: pull straight up — hooks flex out of engagement.

## Print Orientation

Top plate on the bed, walls and arms extending upward. This is opposite to installed orientation (which has the top plate at the top and arms hanging down).

Print orientation rationale:
- Top plate provides a large, flat first layer — excellent bed adhesion
- Walls rise vertically from plate edges — no overhang at any layer transition
- Arms are integral to the walls (embedded, share wall material) and continue past the wall tops — no unsupported arm base
- Hooks are at the top of the print where they can be checked post-print
- No supports needed

In print local coordinates: z=0 = top plate bottom (on bed), z increases upward. In installed global coordinates: z=0 = base plate bottom; cap top plate at z=29.7–31.7, hooks at z=5.0–7.0.

## Dimensions & Sources

| Dimension | Value | Source |
|---|---|---|
| Cap top plate thickness | 2.0 mm | Proposal (= clip_frame_t, unchanged) |
| Cap wall depth (D) | 12.0 mm | Proposal (locked-in decision) |
| Cap wall thickness | 2.0 mm | Proposal |
| Cap inner XY (per side) | 120.0 mm | Derived: fan_frame + 2×loc_clearance = 119 + 2×0.5 |
| Cap outer XY (wall sides) | 124.0 mm | Derived: 120 + 2×2 (wall thickness) |
| Cap inner corner radius | 5.0 mm | = fan_corner_r (fan frame corner radius) |
| Cap outer corner radius | 7.0 mm | = fan_corner_r + cap_wall_t = 5 + 2 |
| Fan frame clearance (per side) | 0.5 mm | Params: loc_clearance (clearance fit) |
| Overall bbox X | 133.0 mm | Arm outer face: arm_center_offset + arm_t/2 = 65.75+0.75 = 66.5mm × 2 |
| Overall bbox Y | 124.0 mm | Wall only on ±Y (no arms); cap_outer = 124mm |
| Overall bbox Z (local) | 26.7 mm | Hook bottom (installed z=5.0) to plate top (installed z=31.7); 31.7−5.0 |
| Arm count | 2 | Proposal: ±X sides only |
| Arm width | 8.0 mm | Proposal: unchanged from v2 (= clip_arm_w) |
| Arm thickness | 1.5 mm | Proposal: unchanged from v2 (= clip_arm_t) |
| Arm root Z (installed global) | 22.0 mm | Proposal: inside wall zone; 7.7mm above wall bottom (17.7), 9.7mm below plate top (29.7) |
| Arm root Z (print local) | 9.7 mm | Derived: 31.7 − 22.0 = 9.7mm from bed |
| Arm length | 15.0 mm | Proposal: z=22 to z=7 (installed global) |
| Arm bottom Z (installed global) | 7.0 mm | Derived: arm_root − arm_length = 22 − 15 |
| Arm bottom Z (print local) | 24.7 mm | Derived: 31.7 − 7.0 |
| Hook overhang | 1.25 mm | User decision (midpoint of 1.0–1.5mm range) |
| Hook height | 2.0 mm | Proposal |
| Hook bottom Z (installed global) | 5.0 mm | Derived: arm_bottom − hook_height = 7.0 − 2.0 |
| Hook bottom Z (print local) | 26.7 mm | Derived: 31.7 − 5.0 (= total print height) |
| Hook outer chamfer | 1.25 mm @ 45° | Derived: = hook_overhang; snap-in ramp |
| Hook inner chamfer | 1.25 mm @ 45° | Derived: min(hook_overhang, hook_height) = min(1.25, 2.0) = 1.25mm; printability ramp |
| Arm center offset (from center) | 65.75 mm | Derived: loc_outer/2 + clip_ledge_depth + arm_t/2 = 62+3+0.75 |
| Arm inner face offset (from center) | 65.0 mm | Derived: arm_center_offset − arm_t/2 = 65.75 − 0.75 |
| Arm outer face offset (from center) | 66.5 mm | Derived: arm_center_offset + arm_t/2 = 65.75 + 0.75 |
| Hook inner face offset (from center) | 63.75 mm | Derived: arm_inner_face − hook_overhang = 65.0 − 1.25 |
| Root fillet radius | 2.0 mm | Matches v2 (Kt 2.5 → 1.2); triangular prism at arm root on wall inner face |
| Fan frame size | 119.0 mm | Params: fan_frame |
| Fan top Z (installed global) | 29.7 mm | Params: z_fan_top = frame_t_inner + fan_frame_t = 5.0 + 24.7 |
| Cap top plate top Z (installed global) | 31.7 mm | Params: z_clip_top = z_fan_top + cap_top_plate_t = 29.7 + 2.0 |
| Cap wall bottom Z (installed global) | 17.7 mm | Derived: z_fan_top − D = 29.7 − 12.0 |
| Center opening diameter | 115.0 mm | Params: fan_opening (cap top plate has center opening matching fan airflow) |

## Stress Check

Snap arm cantilever stress with final locked-in parameters:

```
σ = 3Ehδ / 2L²
  E = 3500 MPa (PLA modulus)
  h = 1.5 mm   (arm thickness)
  δ = 1.25 mm  (hook overhang = snap deflection)
  L = 15.0 mm  (arm length)

σ = 3 × 3500 × 1.5 × 1.25 / (2 × 15²)
  = 19687.5 / 450
  ≈ 43.75 MPa

With Kt = 1.2 (2mm root fillet):
  σ_peak ≈ 43.75 × 1.2 ≈ 52.5 MPa

PLA yield: ~65 MPa
Safety factor: 65 / 52.5 ≈ 1.24
```

SF 1.24 is acceptable for a seasonal-use snap that will be cycled a few times per year (not high-cycle fatigue). The guide channels prevent off-axis loading, which keeps actual peak stress close to the calculated value.

## Features

### Top Plate
- **Purpose**: Rigid cap lid; sits on fan top face; provides structural continuity between walls; has center opening for airflow
- **Critical dimensions**: 124mm × 124mm outer (rounded corners r=7mm), 2.0mm thick; center opening 115mm diameter
- **Mating interfaces**: Bottom face rests on fan top (z=29.7 installed). No clamping — gravity and snap arms hold Z position.

### Side Walls (×4, continuous)
- **Purpose**: Cap rigidity; self-centering on fan frame; aesthetic housing
- **Critical dimensions**: 12.0mm tall (installed z=17.7 to z=29.7), 2.0mm thick, inner face at 120mm/2=60mm from center per side
- **Mating interfaces**: Inner face slides over fan frame outer face (119mm). Gap per side = (120−119)/2 = 0.5mm (clearance fit). Fan enters cap with easy sliding clearance.
  - Cap inner: 120mm. Fan outer: 119mm. Gap per side: 0.5mm. ✓
- **Printability**: Walls rise from the plate in print orientation — fully supported at every layer. No overhang. ✓

### Snap Arms (×2, ±X sides, embedded in walls)
- **Purpose**: Z retention snap-fit; hooks under base plate ledge flat zone at z=7.0–9.0
- **Critical dimensions**:
  - Width: 8.0mm (centered on ±X face, same as ledge width)
  - Thickness: 1.5mm
  - Length: 15.0mm (z=22 to z=7 installed; z=9.7 to z=24.7 print-local)
  - Arm root embedded in wall at installed z=22 (print-local z=9.7mm from bed, i.e., 2.3mm above wall bottom in installed, or 4.3mm below wall top in print local)
  - Arm continues past wall bottom (installed z=17.7) to arm tip at installed z=7.0
- **Mating interfaces**: Cap arm width 8.0mm enters channel inner 8.7mm. Gap per side = 0.35mm (sliding fit). ✓

### Hooks (×2, at arm tips)
- **Purpose**: Snap-fit engagement; hook catches under ledge flat zone bottom (installed z=7.0)
- **Critical dimensions**:
  - Overhang: 1.25mm inward from arm inner face
  - Height: 2.0mm (arm bottom at z=7.0 to hook bottom at z=5.0)
  - Outer chamfer: 1.25mm × 45° on outer-lower face (snap-in ramp; allows hook to pass ledge by deflecting arm outward)
  - Inner chamfer: 1.25mm × 45° on inner-upper face (printability; eliminates overhang at arm/hook junction in print orientation)
- **Mating interfaces**: Hook inner face at 63.75mm from center. Ledge outer face at 65.0mm from center. Snap requires arm to deflect 1.25mm outward during installation (hook_overhang). Hook catches under ledge flat zone (z=7.0–9.0).
  - Ledge outer face: loc_outer/2 + clip_ledge_depth = 62 + 3 = 65mm ✓
  - Hook inner face snapped home: 65.0 − 1.25 = 63.75mm — sits 1.25mm inside ledge outer face ✓
- **Printability**: Inner chamfer (1.25mm × 45°) eliminates the otherwise-90° overhang at the arm/hook junction in print orientation. Outer chamfer is a ramp on the hook face. Both computed at 45° — no unsupported overhangs. ✓

### Root Fillet (×2, at arm roots)
- **Purpose**: Reduces stress concentration at arm/wall junction from Kt≈2.5 to Kt≈1.2
- **Critical dimensions**: 2.0mm triangular-prism fillet in concave corner between arm inner face (x=65.0mm from center) and wall inner face at arm root Z

### Center Opening (in top plate)
- **Purpose**: Airflow passage; matches fan inner circle and base plate center opening
- **Critical dimensions**: 115mm diameter through 2mm plate
- **Printability**: 115mm circular bridge at print z=2mm (just above bed). This is a circular opening printed over the top plate in print orientation. In print orientation this is a CEILING at z=2 (the plate is 2mm, opening is in it). Actually: the top plate is the first 2mm printed (on bed). The center opening is a void in that plate. With the plate on the bed, the center opening prints as a bridged hole in the first 2mm. 115mm span is large. However this prints exactly the same as the v2 clip's center opening (same dimensions), and per v2 validation it prints without issue — the printer fills the plate area as concentric perimeters inward with the last remaining ring, not as a bridge. ✓ (Validated in v2.)

## Snap Arm Embedded in Wall — Construction Detail

The arm is not a tab bridging out from the frame (as in v2). Instead it is integral to the wall on ±X sides. In the XZ cross-section of the ±X wall face:

```
print local Z (bed = 0):

z=0.0   [top plate bottom on bed]
z=2.0   [top plate top / wall starts]
z=9.7   [arm root: arm begins inside wall zone]
         arm occupies the outer 1.5mm of wall thickness from here down
z=14.0  [wall ends — arm continues unsupported past wall bottom]
z=24.7  [arm bottom / hook top]
z=26.7  [hook bottom = print apex = total height]
```

The arm is flush with the wall outer face at and below the root, then continues past the wall bottom as a freestanding cantilever. The root fillet sits on the wall inner face at z_root.

## Material & Tolerances

- Material: PLA (Bambu PLA Basic)
- Cap inner to fan frame: 0.5mm per side (clearance fit — easy slide-on)
- Arm to base channel: 0.35mm per side (sliding fit — guided entry)
- Hook overhang: 1.25mm (controlled snap; channel constrains Y so snap force is purely axial)
- Min wall thickness: 2.0mm (walls, arm thickness 1.5mm is acceptable for cantilever arm — matches v2) ✓

## Constraints

- Build volume: 133 × 124 × 26.7mm — fits Bambu X1C (256mm limit) ✓
- No overhangs >45° in print orientation (top-plate-down)
- No supports required
- Arms must not contact channel walls during assembly travel — sliding fit verified above
- Hook must clear ledge outer face during snap (arm deflects 1.25mm outward — within elastic range per stress check)
- Cap must not contact base plate top during assembly (cap wall bottom at z=17.7 installed; base plate z=15.0 tallest point (channel wall top); clearance = 17.7−15.0 = 2.7mm ✓)

## Printability Pre-Screen

| Feature | Check | Result |
|---|---|---|
| Top plate on bed (first layer) | Large flat surface | PASS — excellent bed adhesion |
| Side walls (2mm thick, 12mm tall rising from plate edges) | Overhang at plate/wall junction? | PASS — wall base fully supported by plate (concave 90° inner corner, convex outer — the outer corner is a convex edge, zero overhang) |
| Arm root (inside wall at print z=9.7mm) | Overhang at arm-root-to-wall transition | PASS — arm is flush with wall outer face; wall supports the arm's outer face; arm inner face is open air but arm rises vertically — no overhang |
| Arm shaft (z=9.7 to z=26.7 print local) | Vertical cantilever, 1.5mm thick | PASS — arm rises vertically; all cross-section at each layer is fully covered by layer below |
| Hook outer chamfer (1.25mm @ 45°) | Overhang | PASS — 1.25mm horizontal over 1.25mm vertical = 45° exactly; self-supporting |
| Hook inner chamfer (1.25mm @ 45°) | Overhang at arm/hook junction (print top) | PASS — inner chamfer eliminates 90° step; 1.25mm horizontal over 1.25mm vertical = 45° exactly |
| Center opening (115mm diameter in top plate) | Bridge span | PASS — same as v2 (prints as ring perimeters, not bridge); validated in v2 |
| Arm width 8.0mm < 10mm bridge threshold | Arm itself forms no bridge | PASS — arm is a solid vertical column, not a bridge |
| Cap wall bottom (installed z=17.7) vs base channel top (z=15.0) | Clearance to avoid collision | PASS — 2.7mm clearance ✓ |
| Hook bottom at z=5.0 vs base inner plate at z=5.0 | Hook must not bottom out | FLAG: Hook bottom = z=5.0 = inner plate top. Hook bottom will just touch the inner plate when fully engaged. This may need a 0.5mm reduction in arm length or confirm that hook engagement (z=7.0) bottoms out before hook reaches plate. Arm bottom is at z=7.0 — the 2.0mm hook hangs from there to z=5.0. Inner plate top is at z=5.0. Tight but zero interference in nominal geometry. Tolerance ±0.5mm; watch for this during assembly validation. |
| Arm section 1.5mm < min wall 1.2mm threshold | Arm thickness check | PASS — 1.5mm > 1.2mm minimum; same as v2 ✓ |
