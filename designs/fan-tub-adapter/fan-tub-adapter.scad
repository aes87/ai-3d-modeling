// Fan-Tub Adapter — mounts a 119mm fan into a 2×2 waffle-cutout in an HDPE tub lid
// Y-shaped corner branches locate in waffle channels; thumbscrews clamp to lid.
// Entire part is one flat plate — branches are in-plane with the frame.

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
fan_bolt_cc   = 107;     // mm — bolt pattern center-to-center
fan_bolt_dia  = 4;       // mm — M4 nominal
fan_opening   = 105;     // mm — center airflow diameter

// Y-branch geometry (waffle channel engagement)
branch_w      = 9.0;     // mm — branch width (9.4 channel - 0.4 clearance)
branch_len    = 25;      // mm — engagement length into channel

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

// Overall bounding box — branches extend from cutout corners into channels
// Branch tip outer edge at cutout/2 + branch_len from center
bbox_x        = 2 * (cutout/2 + branch_len);   // 186.8
bbox_y        = bbox_x;
bbox_z        = frame_t;                        // 3mm — flat plate, no standoffs

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
    linear_extrude(frame_t)
        rounded_square(frame_outer, corner_r);
}

// Center opening — airflow hole
module center_opening() {
    translate([0, 0, -1])
        cylinder(d=fan_opening, h=frame_t + 2);
}

// Fan bolt holes at bolt pattern corners — M4 through-holes, no standoffs
module fan_bolt_holes() {
    half_cc = fan_bolt_cc / 2;
    positions = [
        [ half_cc,  half_cc],
        [-half_cc,  half_cc],
        [-half_cc, -half_cc],
        [ half_cc, -half_cc],
    ];

    for (pos = positions) {
        translate([pos[0], pos[1], -1])
            fdm_hole(d=fan_bolt_dia, h=frame_t + 2);
    }
}

// One Y-branch fork at a corner — two arms in-plane with the frame
// extending into perpendicular waffle channels
// corner_idx: 0=+X+Y, 1=-X+Y, 2=-X-Y, 3=+X-Y
module y_branch(corner_idx) {
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

    // Branches are in-plane with the frame (same thickness, same Z)
    // Arm along X-axis channel
    hull() {
        translate([cx, cy, 0])
            cylinder(d=branch_w, h=frame_t, $fn=32);
        translate([cx + sx * (branch_len - branch_w/2), cy, 0])
            cylinder(d=branch_w, h=frame_t, $fn=32);
    }

    // Arm along Y-axis channel
    hull() {
        translate([cx, cy, 0])
            cylinder(d=branch_w, h=frame_t, $fn=32);
        translate([cx, cy + sy * (branch_len - branch_w/2), 0])
            cylinder(d=branch_w, h=frame_t, $fn=32);
    }

    // Smooth blend at the fork crotch
    translate([cx, cy, 0])
        cylinder(d=branch_w + 2, h=frame_t, $fn=32);
}

// Wire channel notch in one corner of the frame
module wire_channel() {
    translate([frame_outer/2 - wire_d/2, 0, -1])
        cube([wire_d + 1, wire_w, frame_t + 2], center=true);
}

// Thumbscrew holes through flange (2× on opposite sides)
module thumbscrew_holes() {
    for (sy = [1, -1]) {
        translate([0, sy * thumb_offset, -1])
            fdm_hole(d=thumb_dia, h=frame_t + 2);
    }
}


// === Assembly ===

// Flat plate on the bed — print as-is, mount with branches sliding into
// waffle channels and flange resting on the lid rim. Fan bolts directly
// to the top surface.

difference() {
    union() {
        frame_plate();

        // Y-branches (4 corners, in-plane)
        for (i = [0:3])
            y_branch(i);
    }

    center_opening();
    fan_bolt_holes();
    wire_channel();
    thumbscrew_holes();
}
