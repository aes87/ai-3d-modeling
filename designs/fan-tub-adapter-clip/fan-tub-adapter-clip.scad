// Fan-Tub Adapter v2.0 — Retention Clip
// Snaps onto base plate ledges to hold fan in place.
// Modeled in INSTALLED orientation (frame on top, arms hanging down).
// Flip upside-down for printing (frame on bed, arms up).
//
// Snap-fit mechanics (Bambu PLA Basic):
//   Nominal root stress: σ = 3Ehδ/2L² = 29 MPa  (E=3500, h=1.5, δ=1.8, L=22.05)
//   Sharp-corner Kt ≈ 2.5  →  σ_peak ≈ 73 MPa ≈ yield  →  low cycle life
//   2mm root fillet:   Kt ≈ 1.2  →  σ_peak ≈ 35 MPa  →  good for repeated cycling

include <fdm-pla.scad>
include <bambu-x1c.scad>
include <fan-tub-adapter-params.scad>

$fn = 80;

// === Clip geometry ===

clip_frame_outer = fan_frame;      // 119mm — matches fan frame outer
clip_frame_inner = fan_opening;    // 105mm — center airflow opening
clip_frame_r     = fan_corner_r;   // 5mm corner radius

// Arm center offset: arm sits just outside the rim ledge
arm_center_offset = loc_outer / 2 + clip_ledge_depth + clip_arm_t / 2;  // 62 + 1.0 + 0.75 = 63.75

// Tab bridge from frame edge to arm outer face.
// Extends to full arm width so the arm base has no overhang in print orientation
// (frame on bed, arms up). Previously stopped at arm center (4.25mm), leaving the
// outer 0.75mm of the arm unsupported at z_print=2.
tab_len = arm_center_offset + clip_arm_t / 2 - clip_frame_outer / 2;  // 64.5 - 59.5 = 5.0mm

// Local Z coordinate system (installed orientation):
//   z = 0              hook bottom  (global: z_fan_top - clip_arm_len - clip_hook_h = 6.15)
//   z = clip_hook_h    arm/hook boundary                                              (1.5)
//   z = local_arm_top  arm top / frame bottom                                        (23.55)
//   z = total_clip_h   frame top                                                     (25.55)
local_arm_bot   = clip_hook_h;                   // 1.5
local_arm_top   = clip_hook_h + clip_arm_len;    // 23.55
local_frame_bot = local_arm_top;                 // 23.55
local_frame_top = local_arm_top + clip_frame_t;  // 25.55
total_clip_h    = local_frame_top;               // 25.55

// Hook entry chamfer — 45° ramp on outer-lower face for smooth snap-in.
// Inner chamfer uses hook_h as limit (not 0.6×) so overhang stays ≤45° in print orientation.
hook_chamfer = min(clip_hook_overhang, clip_hook_h);  // 2.5mm

// Root fillet radius — reduces Kt at arm bending root
fillet_r = 2.0;

// Clip XY bounding box
clip_bbox_xy = loc_outer + 2 * clip_ledge_depth + 2 * clip_arm_t;  // 129mm

report_dimensions(clip_bbox_xy, clip_bbox_xy, total_clip_h, "clip");


// === Modules ===

module rounded_square_2d(size, r) {
    offset(r=r) offset(r=-r) square(size, center=true);
}

// Clip frame — sits on top of fan
module clip_frame() {
    translate([0, 0, local_frame_bot])
        linear_extrude(clip_frame_t)
            difference() {
                rounded_square_2d(clip_frame_outer, clip_frame_r);
                rounded_square_2d(clip_frame_inner, clip_frame_r - 2);
            }
}

// Single arm assembly: tab + arm + hook + root fillet
// side: 0=+X, 1=+Y, 2=-X, 3=-Y
//
// Hook geometry (XZ cross-section):
//
//   x_hook_inner          x_arm_inner  x_arm_outer
//        |                     |            |
//   z=1.5 │                     ╲────────────┤  arm inner face → inner chamfer start
//        │                      ╲           │
//   z=0.8 │                      ╰───────────┤  ← inner chamfer (printability, 45°)
//        │                                  │
//   z=0.7 ├──────────────────────            │  inner face (hook width)
//        │                              ╱   │
//   z=0.0 ╰────────────────────────────╱    │  ← outer chamfer (snap-in, 45°)
//                                      x=63.7
//
// Outer chamfer: guides arm outward during snap-in (snap-in ramp).
// Inner chamfer: eliminates 90° overhang at arm/hook junction in print orientation.
//
// Root fillet geometry:
//   Triangular prism in the concave corner between arm inner face and tab underside.
//   Kt reduced from ~2.5 (sharp) to ~1.2 (2mm fillet) — critical for cycle life.
//
module clip_arm(side) {
    angle = side * 90;

    x_arm_inner  = arm_center_offset - clip_arm_t / 2;  // 63.0
    x_arm_outer  = arm_center_offset + clip_arm_t / 2;  // 64.5
    x_hook_inner = x_arm_inner - clip_hook_overhang;    // 62.2

    rotate([0, 0, angle]) {

        // Tab: horizontal bridge from frame edge to arm
        translate([clip_frame_outer/2, -clip_arm_w/2, local_frame_bot])
            cube([tab_len, clip_arm_w, clip_frame_t]);

        // Arm: vertical column
        translate([x_arm_inner, -clip_arm_w/2, local_arm_bot])
            cube([clip_arm_t, clip_arm_w, local_arm_top - local_arm_bot]);

        // Hook: inward overhang with 45° chamfers on both entry faces.
        // Outer chamfer (snap-in): ramps arm outward smoothly during installation.
        // Inner chamfer (printability): eliminates the 90° overhang at the arm/hook
        //   junction in print orientation (frame on bed, hooks at top). Without it,
        //   the 0.8mm inner step at z=clip_hook_h would print unsupported.
        //   Both chamfers are 45°: hook_chamfer (0.8mm) horizontal over 0.8mm vertical.
        // Profile defined in XZ space, extruded along Y (arm width).
        // rotate([90,0,0]) maps the polygon's XY into world XZ.
        rotate([90, 0, 0])
            linear_extrude(clip_arm_w, center=true)
                polygon([
                    [x_hook_inner,               0                        ],  // inner bottom
                    [x_arm_outer - hook_chamfer,  0                        ],  // outer bottom (chamfer start)
                    [x_arm_outer,                hook_chamfer             ],  // outer chamfer apex
                    [x_arm_outer,                clip_hook_h              ],  // outer top / arm outer face
                    [x_arm_inner,                clip_hook_h              ],  // inner top / arm inner face
                    [x_hook_inner,               clip_hook_h - hook_chamfer],  // inner chamfer apex
                ]);

        // Root fillet: triangular prism filling the concave corner between
        // arm inner face (x = x_arm_inner) and tab underside (z = local_frame_bot).
        rotate([90, 0, 0])
            linear_extrude(clip_arm_w, center=true)
                polygon([
                    [x_arm_inner,          local_frame_bot        ],
                    [x_arm_inner - fillet_r, local_frame_bot      ],
                    [x_arm_inner,          local_frame_bot - fillet_r],
                ]);

    }
}


// === Assembly ===

union() {
    clip_frame();
    for (side = [0:3]) clip_arm(side);
}
