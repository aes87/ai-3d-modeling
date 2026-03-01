// Fan-Tub Adapter — mounts a 119mm fan into a 2×2 waffle-cutout in an HDPE tub lid
// Y-shaped corner branches locate in waffle channels; thumbscrews clamp to lid.
// Flat plate with counterbored nut pockets and a locating rim for the fan.

include <fdm-pla.scad>
include <bambu-x1c.scad>
include <common.scad>

// === Parameters ===

// Cutout hole in lid (2 waffle squares + 1 channel)
cutout        = 136.8;   // mm — 2×63.7 + 9.4
frame_t       = 5;       // mm — plate thickness (accommodates M4 nut counterbore)
flange_w      = 4.5;     // mm — lip overhang beyond cutout (sits on rim)
corner_r      = 4;       // mm — waffle square corner radius

// Fan geometry
fan_frame     = 119;     // mm — fan outer dimension (square)
fan_bolt_cc   = 107;     // mm — bolt pattern center-to-center
fan_bolt_dia  = 4;       // mm — M4 nominal
fan_opening   = 105;     // mm — center airflow diameter
fan_corner_r  = 5;       // mm — fan frame corner radius

// Fan locating rim
loc_rim_h     = 1.5;     // mm — height of locating rim above plate
loc_rim_wall  = 2;       // mm — rim wall thickness
loc_clearance = 0.5;     // mm — clearance around fan frame (per side)

// M4 nut counterbore (bottom face)
nut_af        = 7;       // mm — M4 nut across flats
nut_t         = 3.2;     // mm — M4 nut thickness
nut_clearance = 0.4;     // mm — FDM clearance per side on nut pocket

// Y-branch geometry (waffle channel engagement)
branch_w      = 9.0;     // mm — branch width (9.4 channel - 0.4 clearance)
branch_len    = 25;      // mm — engagement length into channel

// Thumbscrew holes — on branch arms where there's solid material and lid contact
thumb_dia     = 4;       // mm — M4 nominal
thumb_branch_offset = 12; // mm — distance along branch from frame edge

$fn = 80;

// === Derived values ===

frame_outer   = cutout + 2 * flange_w;  // 145.8

// Counterbore derived
nut_pocket_af = nut_af + 2 * nut_clearance;  // 7.8mm across flats
nut_pocket_d  = nut_t + 0.2;                 // 3.4mm depth (slight clearance)

// Locating rim derived
loc_inner     = fan_frame + 2 * loc_clearance;  // 120mm inner dimension

// Bounding box
bbox_x        = 2 * (cutout/2 + branch_len);   // 186.8
bbox_y        = bbox_x;
bbox_z        = frame_t + loc_rim_h;            // 5 + 1.5 = 6.5

// Validate constraints
assert(frame_t >= MIN_WALL, str("Frame thickness ", frame_t, " below min wall ", MIN_WALL));
assert(frame_t - nut_pocket_d >= MIN_FLOOR_CEIL,
    str("Nut pocket floor ", frame_t - nut_pocket_d, "mm below minimum ", MIN_FLOOR_CEIL, "mm"));

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

// Center opening — airflow hole (through plate + locating rim)
module center_opening() {
    translate([0, 0, -1])
        cylinder(d=fan_opening, h=frame_t + loc_rim_h + 2);
}

// Fan locating rim — raised border on top surface matching fan footprint
module fan_locating_rim() {
    translate([0, 0, frame_t]) {
        linear_extrude(loc_rim_h) {
            difference() {
                rounded_square(loc_inner + 2 * loc_rim_wall, fan_corner_r + loc_rim_wall);
                rounded_square(loc_inner, fan_corner_r);
            }
        }
    }
}

// Fan bolt through-holes with hex nut counterbores on the bottom face
module fan_bolt_holes() {
    half_cc = fan_bolt_cc / 2;
    positions = [
        [ half_cc,  half_cc],
        [-half_cc,  half_cc],
        [-half_cc, -half_cc],
        [ half_cc, -half_cc],
    ];

    for (pos = positions) {
        translate([pos[0], pos[1], 0]) {
            // Through-hole (full plate + rim height)
            translate([0, 0, -1])
                fdm_hole(d=fan_bolt_dia, h=frame_t + loc_rim_h + 2);

            // Hex nut counterbore from bottom face
            translate([0, 0, -1])
                cylinder(d=nut_pocket_af / cos(30), h=nut_pocket_d + 1, $fn=6);
        }
    }
}

// One Y-branch fork at a corner — two arms in-plane with the frame
module y_branch(corner_idx) {
    signs = [
        [ 1,  1],
        [-1,  1],
        [-1, -1],
        [ 1, -1],
    ];
    sx = signs[corner_idx][0];
    sy = signs[corner_idx][1];

    cx = sx * cutout / 2;
    cy = sy * cutout / 2;

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

// Thumbscrew holes — positioned on branch arms for solid material and lid contact.
// On the X-arms of two diagonally opposite corners (+X+Y and -X-Y).
module thumbscrew_holes() {
    // Corner 0 (+X,+Y): X-arm extends in +X direction from cutout corner
    tx0 = cutout/2 + thumb_branch_offset;
    ty0 = cutout/2;

    // Corner 2 (-X,-Y): X-arm extends in -X direction from cutout corner
    tx2 = -(cutout/2 + thumb_branch_offset);
    ty2 = -(cutout/2);

    for (pos = [[tx0, ty0], [tx2, ty2]]) {
        translate([pos[0], pos[1], -1])
            fdm_hole(d=thumb_dia, h=frame_t + 2);
    }
}


// === Assembly ===

// Print flat on bed. Branches and plate in same plane. Locating rim on top.
// Nut pockets print as hex recesses on the bottom (first few layers bridge over).

difference() {
    union() {
        frame_plate();

        // Y-branches (4 corners, in-plane)
        for (i = [0:3])
            y_branch(i);

        // Locating rim on top surface
        fan_locating_rim();
    }

    center_opening();
    fan_bolt_holes();
    thumbscrew_holes();
}
