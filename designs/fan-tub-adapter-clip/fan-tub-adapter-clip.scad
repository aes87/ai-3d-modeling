// Fan-Tub Adapter v2.0 — Retention Clip
// Snaps onto base plate ledges to hold fan in place.
// Modeled in INSTALLED orientation (frame on top, arms hanging down).
// Flip upside-down for printing (frame on bed, arms up).

include <fdm-pla.scad>
include <bambu-x1c.scad>
include <fan-tub-adapter-params.scad>

$fn = 80;

// === Clip geometry ===

// Frame sits on top of fan at z_fan_top, thickness = clip_frame_t
// Frame is a rounded square matching fan frame outer, with center opening
clip_frame_outer = fan_frame;          // 119mm — matches fan frame
clip_frame_inner = fan_opening;        // 105mm — center airflow opening
clip_frame_r     = fan_corner_r;       // 5mm corner radius

// Arm positions: centered per side, on the OUTSIDE of the locating rim
// Arm outer edge aligns with rim outer + ledge_depth
arm_center_offset = loc_outer / 2 + clip_ledge_depth + clip_arm_t / 2;  // 62 + 1.0 + 0.75 = 63.75

// Tab bridges from frame edge to arm center
tab_len = arm_center_offset - clip_frame_outer / 2;  // 63.75 - 59.5 = 4.25mm

// Hook position: catches under ledge at z_ledge_bot
// In installed coords: hook top at z_ledge_bot (7.5), hook bottom at z_ledge_bot - clip_hook_h (6.0)
// Arm bottom = z_fan_top - clip_arm_len = 29.7 - 22.05 = 7.65...
// Actually the arm starts at the bottom of the clip frame (z_fan_top) and goes DOWN
// Arm bottom = z_fan_top - clip_arm_len = 29.7 - 22.05 = 7.65
// Hook is at the bottom of the arm, extending inward

// For modeling, let's use local Z where z=0 is the bottom of the arm tips (hook bottom)
// and z_max is the top of the clip frame.
// Total height = clip_arm_len + clip_frame_t = 22.05 + 2.0 = 24.05

// Local coordinate system (installed orientation):
// z=0: hook bottom (in global: z_fan_top - clip_arm_len - clip_hook_h... let me just model from frame top down)

// Simpler: model in installed absolute Z coordinates, then we know exactly where everything is.
// Frame: z_fan_top to z_clip_top (29.7 to 31.7)
// Arms: z_fan_top down to z_fan_top - clip_arm_len (29.7 to 7.65)
// Hooks: at arm bottom, inward overhang

// But for a standalone part, let's zero at the lowest point.
// Lowest point = arm bottom - hook extension below = 7.65 - 0 = 7.65 (hooks are at arm tip, not below)
// Actually hook bottom = arm bottom - clip_hook_h? No — the hook is the last clip_hook_h of the arm,
// with an inward overhang. The arm length already includes the hook zone.

// Let me re-read the plan:
// Arm length (clip frame bottom to hook top): 29.7 - 7.5 = 22.2mm
// With preload: 22.05mm
// Hook catches UNDER ledge at z=6.0 to z=7.5
// So arm bottom = z_fan_top - clip_arm_len = 29.7 - 22.05 = 7.65
// Hook top = arm bottom = 7.65, hook extends down by clip_hook_h = 1.5 → hook bottom = 6.15
// Hook catches under ledge bottom (z=6.0)... close enough with preload

// Local Z: shift everything so lowest point (hook bottom) = 0
z_offset = z_fan_top - clip_arm_len - clip_hook_h;  // 29.7 - 22.05 - 1.5 = 6.15

// Local coords:
local_hook_bot    = 0;                                    // 0
local_hook_top    = clip_hook_h;                          // 1.5
local_arm_bot     = clip_hook_h;                          // 1.5 (arm starts where hook ends)
local_arm_top     = clip_arm_len + clip_hook_h;           // 23.55
local_frame_bot   = local_arm_top;                        // 23.55
local_frame_top   = local_arm_top + clip_frame_t;         // 25.55
total_clip_h      = local_frame_top;                      // 25.55

// Clip overall outer extent
clip_bbox_xy = loc_outer + 2 * clip_ledge_depth + 2 * clip_arm_t;  // 124 + 2 + 3 = 129mm

// Report dimensions in PRINT orientation (flipped: frame on bed, arms up)
// In print orientation, same bbox just Z = total_clip_h
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

// Single arm assembly (tab + vertical arm + hook)
// side: 0=+X, 1=+Y, 2=-X, 3=-Y
module clip_arm(side) {
    angle = side * 90;

    rotate([0, 0, angle]) {
        // Tab: horizontal bridge from frame edge to arm position
        // Frame edge at x = clip_frame_outer/2 = 59.5
        // Arm center at x = arm_center_offset = 63.75
        translate([clip_frame_outer/2, -clip_arm_w/2, local_frame_bot])
            cube([tab_len, clip_arm_w, clip_frame_t]);

        // Vertical arm: hangs down from tab
        translate([arm_center_offset - clip_arm_t/2, -clip_arm_w/2, local_arm_bot])
            cube([clip_arm_t, clip_arm_w, local_arm_top - local_arm_bot]);

        // Hook: inward overhang at arm bottom
        // Extends inward (toward center, -X direction) by clip_hook_overhang
        translate([arm_center_offset - clip_arm_t/2 - clip_hook_overhang, -clip_arm_w/2, local_hook_bot])
            cube([clip_hook_overhang + clip_arm_t, clip_arm_w, clip_hook_h]);
    }
}

// Fillet at arm-to-tab junction (triangular reinforcement)
module clip_fillet(side) {
    angle = side * 90;
    fillet_r = 2;  // 2mm triangular fillet

    rotate([0, 0, angle]) {
        // Fillet between tab top and arm outer face
        translate([arm_center_offset - clip_arm_t/2, -clip_arm_w/2, local_frame_bot]) {
            // Triangular prism: fills the concave corner between tab underside and arm
            linear_extrude(clip_arm_w)
                rotate([0, 0, 0])
                    // Triangle in XZ plane, extruded along Y
                    // Actually we need it in the right orientation
                    ;
        }
        // Simpler: small cube fillet at the junction
        // Inner fillet (tab bottom to arm inner face)
        translate([arm_center_offset - clip_arm_t/2, -clip_arm_w/2, local_frame_bot - fillet_r])
            rotate([270, 0, 0])
                linear_extrude(clip_arm_w)
                    polygon([[0, 0], [0, fillet_r], [-fillet_r, 0]]);
    }
}


// === Assembly ===

union() {
    clip_frame();

    for (side = [0:3]) {
        clip_arm(side);
        clip_fillet(side);
    }
}
