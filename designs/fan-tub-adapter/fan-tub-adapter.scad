// Fan-Tub Adapter — mounts a 119mm fan into a 2×2 waffle-cutout in an HDPE tub lid
// Y-shaped corner branches locate in waffle channels; thumbscrews clamp to lid.

include <fdm-pla.scad>
include <bambu-x1c.scad>
include <common.scad>

// === Parameters ===

// Cutout hole in lid (2 waffle squares + 1 channel)
cutout        = 136.8;   // mm — 2×63.7 + 9.4
frame_t       = 3;       // mm — frame plate thickness
flange_w      = 4.5;     // mm — lip overhang beyond cutout (sits on rim)
corner_r      = 4;       // mm — waffle square corner radius

// Fan geometry
fan_frame     = 119;     // mm — fan outer dimension
fan_bolt_cc   = 107;     // mm — bolt pattern center-to-center
fan_bolt_dia  = 4;       // mm — M4 nominal
fan_opening   = 105;     // mm — center airflow diameter
fan_corner_r  = 5;       // mm — fan frame corner radius
standoff_h    = 3;       // mm — standoff height above frame

// Y-branch geometry (waffle channel engagement)
branch_w      = 9.0;     // mm — branch width (9.4 channel - 0.4 clearance)
branch_h      = 4.6;     // mm — waffle square height (sits on lid surface)
branch_len    = 25;      // mm — engagement length into channel
fork_blend_r  = 6;       // mm — fillet radius at fork crotch

// Wire channel
wire_w        = 20;      // mm — wire notch width
wire_d        = 6;       // mm — wire notch depth

// Thumbscrew holes (2× on opposite sides)
thumb_dia     = 4;       // mm — M4 nominal
thumb_offset  = cutout/2 + flange_w/2;  // center of flange

$fn = 80;

// === Derived values ===

// Total frame outer size (cutout + flanges on each side)
frame_outer   = cutout + 2 * flange_w;  // 145.8

// Overall bounding box (frame + branches extending into channels from corners)
// Branch tip cylinder center is at cutout/2 + branch_len - branch_w/2
// (subtract half diameter so the tip edge, not center, is at the target)
// Plus branch_w/2 for the cylinder radius = cutout/2 + branch_len = 93.4
// Total = 2 × 93.4 = 186.8 → ~186
bbox_x        = 2 * (cutout/2 + branch_len);   // 186.8
bbox_y        = bbox_x;
bbox_z        = branch_h + frame_t + standoff_h;  // 4.6 + 3 + 3 = 10.6

// Validate constraints
assert(frame_t >= MIN_WALL, str("Frame thickness ", frame_t, " below min wall ", MIN_WALL));

// Report dimensions for pipeline
report_dimensions(bbox_x, bbox_y, bbox_z, "adapter");


// === Modules ===

// Rounded square (2D) centered at origin
module rounded_square(size, r) {
    offset(r=r) offset(r=-r) square(size, center=true);
}

// Main frame plate — fills the cutout with flange lip
module frame_plate() {
    // Flange (full outer size, frame_t thick, sits on lid rim)
    linear_extrude(frame_t)
        rounded_square(frame_outer, corner_r);
}

// Center opening — airflow hole
module center_opening() {
    translate([0, 0, -1])
        cylinder(d=fan_opening, h=frame_t + standoff_h + 2);
}

// Fan standoffs at bolt pattern corners
module fan_standoffs() {
    half_cc = fan_bolt_cc / 2;
    positions = [
        [ half_cc,  half_cc],
        [-half_cc,  half_cc],
        [-half_cc, -half_cc],
        [ half_cc, -half_cc],
    ];

    for (pos = positions) {
        translate([pos[0], pos[1], frame_t]) {
            // Standoff boss
            difference() {
                // Boss cylinder — large enough for M4 + wall
                cylinder(d=fan_bolt_dia + FDM_HOLE_COMPENSATION + 2*MIN_WALL,
                         h=standoff_h);
                // M4 through-hole
                translate([0, 0, -1])
                    fdm_hole(d=fan_bolt_dia, h=standoff_h + 2);
            }
        }
    }
}

// Single Y-branch arm — a rounded rectangle extruded to branch_h
module branch_arm(length) {
    // Arm cross section: branch_w wide, length long, rounded ends
    linear_extrude(branch_h)
        offset(r=1.5) offset(r=-1.5)
            square([branch_w, length], center=true);
}

// One Y-branch fork at a corner — two arms extending into perpendicular channels
// corner_idx: 0=+X+Y, 1=-X+Y, 2=-X-Y, 3=+X-Y
module y_branch(corner_idx) {
    // Corner position (at cutout edge, not frame edge)
    signs = [
        [ 1,  1],
        [-1,  1],
        [-1, -1],
        [ 1, -1],
    ];
    sx = signs[corner_idx][0];
    sy = signs[corner_idx][1];

    // Corner of the cutout
    cx = sx * cutout / 2;
    cy = sy * cutout / 2;

    // Branch extends below the frame (sits on lid surface)
    translate([0, 0, -branch_h]) {
        // Arm along X-axis channel
        // Tip center offset by branch_w/2 so outer edge is at cutout/2 + branch_len
        hull() {
            // Root blob at corner
            translate([cx, cy, 0])
                cylinder(d=branch_w, h=branch_h, $fn=32);
            // Tip of X-arm (center inset by half width so edge reaches target)
            translate([cx + sx * (branch_len - branch_w/2), cy, 0])
                cylinder(d=branch_w, h=branch_h, $fn=32);
        }

        // Arm along Y-axis channel
        hull() {
            // Root blob at corner (same as above, shared)
            translate([cx, cy, 0])
                cylinder(d=branch_w, h=branch_h, $fn=32);
            // Tip of Y-arm
            translate([cx, cy + sy * (branch_len - branch_w/2), 0])
                cylinder(d=branch_w, h=branch_h, $fn=32);
        }

        // Fill the fork crotch with a smooth blend
        // Use hull between two short arms to create organic fork shape
        translate([cx, cy, 0])
            cylinder(d=branch_w + 2, h=branch_h, $fn=32);
    }
}

// Wire channel notch in one corner of the frame
module wire_channel() {
    // Place at +X edge, centered on Y=0
    translate([frame_outer/2 - wire_d/2, 0, -1])
        cube([wire_d + 1, wire_w, frame_t + 2], center=true);
}

// Thumbscrew holes through flange (2× opposite sides)
module thumbscrew_holes() {
    // On +Y and -Y flanges, centered on X
    for (sy = [1, -1]) {
        translate([0, sy * thumb_offset, -1])
            fdm_hole(d=thumb_dia, h=frame_t + 2);
    }
}


// === Assembly ===

// Orient for printing: branches face up (they're short, no overhang issue)
// Actually, print with frame on bed, branches extending down would need support.
// Better: flip so branches point UP and frame is on the bed.
// The part mounts with frame horizontal, branches going down into waffle.
// For printing: frame on bed (Z=0), standoffs on top, branches...
// Branches extend below frame in use. For printing, we flip: branches on top.
// But branches are only 4.6mm tall, easy either way.
// Let's model in use-orientation (frame at Z=0..frame_t, branches below at Z=-branch_h..0,
// standoffs above at Z=frame_t..frame_t+standoff_h), then translate so Z=0 is bed.

translate([0, 0, branch_h]) {
    difference() {
        union() {
            // Main frame plate
            frame_plate();

            // Fan standoffs
            fan_standoffs();

            // Y-branches (4 corners)
            for (i = [0:3])
                y_branch(i);
        }

        // Subtract center opening
        center_opening();

        // Subtract wire channel
        wire_channel();

        // Subtract thumbscrew holes
        thumbscrew_holes();
    }
}
