// Fan-Tub Adapter v2.0 — Retention Clip (CLAUDE SHAME EDITION)
//
// This part exists because Claude shipped a sign error in the base plate's
// clip_ledges() module: rotate([90,0,0]) flips the extrusion into −Y, so the
// centering translate needed to be +clip_arm_w/2, not −clip_arm_w/2. Result:
// ledges offset 8mm from center, overlapping arms by a single edge only.
//
// Rather than reprint the base, this clip matches the *wrong* ledge positions
// from the pre-fix base plate. The arms are shifted −clip_arm_w (−8mm) in
// local Y to align with where the ledges actually were.
//
// Fixed base plate: designs/fan-tub-adapter-base/fan-tub-adapter-base.scad
// Fixed clip:       designs/fan-tub-adapter-clip/fan-tub-adapter-clip.scad
// Shame commit:     b33a000
//
// Do not use with the corrected base. This is a monument to the bug.

include <fdm-pla.scad>
include <bambu-x1c.scad>
include <fan-tub-adapter-params.scad>

$fn = 80;

// === Clip geometry ===

clip_frame_outer = fan_frame;
clip_frame_inner = fan_opening;
clip_frame_r     = fan_corner_r;

arm_center_offset = loc_outer / 2 + clip_ledge_depth + clip_arm_t / 2;

tab_len = arm_center_offset + clip_arm_t / 2 - clip_frame_outer / 2;

local_arm_bot   = clip_hook_h;
local_arm_top   = clip_hook_h + clip_arm_len;
local_frame_bot = local_arm_top;
local_frame_top = local_arm_top + clip_frame_t;
total_clip_h    = local_frame_top;

hook_chamfer = min(clip_hook_overhang, clip_hook_h);

fillet_r = 2.0;

clip_bbox_xy = loc_outer + 2 * clip_ledge_depth + 2 * clip_arm_t;

// Shame offset: how far the old buggy ledges were from center in local arm Y.
// rotate([90,0,0]) flips extrude to −Y; translate was −clip_arm_w/2 instead of
// +clip_arm_w/2, netting a −clip_arm_w shift relative to correct position.
shame_offset = -clip_arm_w;  // −8mm

report_dimensions(clip_bbox_xy, clip_bbox_xy, total_clip_h, "clip");


// === Modules ===

module rounded_square_2d(size, r) {
    offset(r=r) offset(r=-r) square(size, center=true);
}

module clip_frame() {
    translate([0, 0, local_frame_bot])
        linear_extrude(clip_frame_t)
            difference() {
                rounded_square_2d(clip_frame_outer, clip_frame_r);
                rounded_square_2d(clip_frame_inner, clip_frame_r - 2);
            }
}

module clip_arm(side) {
    angle = side * 90;

    x_arm_inner  = arm_center_offset - clip_arm_t / 2;
    x_arm_outer  = arm_center_offset + clip_arm_t / 2;
    x_hook_inner = x_arm_inner - clip_hook_overhang;

    rotate([0, 0, angle]) {
        // Shame offset: shifts arm in local −Y to match old buggy ledge positions
        translate([0, shame_offset, 0]) {

            translate([clip_frame_outer/2, -clip_arm_w/2, local_frame_bot])
                cube([tab_len, clip_arm_w, clip_frame_t]);

            translate([x_arm_inner, -clip_arm_w/2, local_arm_bot])
                cube([clip_arm_t, clip_arm_w, local_arm_top - local_arm_bot]);

            rotate([90, 0, 0])
                linear_extrude(clip_arm_w, center=true)
                    polygon([
                        [x_hook_inner,               0                        ],
                        [x_arm_outer - hook_chamfer,  0                        ],
                        [x_arm_outer,                hook_chamfer             ],
                        [x_arm_outer,                clip_hook_h              ],
                        [x_arm_inner,                clip_hook_h              ],
                        [x_hook_inner,               clip_hook_h - hook_chamfer],
                    ]);

            rotate([90, 0, 0])
                linear_extrude(clip_arm_w, center=true)
                    polygon([
                        [x_arm_inner,          local_frame_bot        ],
                        [x_arm_inner - fillet_r, local_frame_bot      ],
                        [x_arm_inner,          local_frame_bot - fillet_r],
                    ]);
        }
    }
}


// === Assembly ===

union() {
    clip_frame();
    for (side = [0:3]) clip_arm(side);
}
