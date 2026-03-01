// Fan-Tub Adapter — mounts a 119mm fan into a 2×2 waffle-cutout in an HDPE tub lid
// Y-shaped corner branches locate in waffle channels; thumbscrews clamp to lid.
// Stepped plate: thick inner zone for counterbores, outer zone flush with waffle squares.

include <fdm-pla.scad>
include <bambu-x1c.scad>
include <common.scad>

// === Parameters ===

// Waffle grid measurements
square_size   = 63.7;    // mm — waffle square (channel edge to channel edge)
channel_w     = 9.4;     // mm — channel width between adjacent squares
waffle_h      = 4.6;     // mm — waffle square height above channel surface

// Cutout hole in lid (2 squares + 1 channel between them)
cutout        = 2 * square_size + channel_w;  // 136.8mm

// Frame plate — two thicknesses
frame_t_inner = 5;       // mm — inner zone (fan mount, counterbores)
frame_t_outer = waffle_h; // mm — outer zone (flange + branches, flush with waffle tops)
corner_r      = 4;       // mm — waffle square corner radius

// Flange extends from cutout edge to channel center
flange_w      = channel_w / 2;  // 4.7mm

// Fan geometry
fan_frame     = 119;     // mm — fan outer dimension (square)
fan_bolt_cc   = 107;     // mm — bolt pattern center-to-center
fan_bolt_dia  = 4;       // mm — M4 nominal
fan_opening   = 105;     // mm — center airflow diameter
fan_corner_r  = 5;       // mm — fan frame corner radius

// Fan locating rim
loc_rim_h     = 1.5;     // mm — height of locating rim above inner plate
loc_rim_wall  = 2;       // mm — rim wall thickness
loc_clearance = 0.5;     // mm — clearance around fan frame (per side)

// M4 nut counterbore (bottom face)
nut_af        = 7;       // mm — M4 nut across flats
nut_t         = 3.2;     // mm — M4 nut thickness
nut_clearance = 0.4;     // mm — FDM clearance per side

// Y-branch geometry
branch_w      = 9.0;     // mm — branch width (9.4 channel - 0.4 clearance)
branch_len    = 25;      // mm — engagement length into channel from root

// Thumbscrew holes
thumb_dia     = 4;       // mm — M4 nominal

$fn = 80;

// === Derived values ===

frame_outer   = cutout + 2 * flange_w;  // 146.2

// Branch root at channel intersection center
branch_root   = cutout / 2 + channel_w / 2;  // 73.1

// Counterbore
nut_pocket_d   = nut_t + 0.2;                   // 3.4mm depth
nut_pocket_dia = nut_af + 2 * nut_clearance;     // 7.8mm diameter

// Locating rim
loc_inner     = fan_frame + 2 * loc_clearance;   // 120mm inner
loc_outer     = loc_inner + 2 * loc_rim_wall;    // 124mm outer — defines inner zone boundary

// Step height between inner and outer zones
step_h        = frame_t_inner - frame_t_outer;   // 0.4mm

// Bounding box
bbox_x        = 2 * (branch_root + branch_len);  // 196.2
bbox_y        = bbox_x;
bbox_z        = frame_t_inner + loc_rim_h;        // 6.5

// Validate constraints
assert(frame_t_outer >= MIN_WALL, str("Outer thickness ", frame_t_outer, " below min wall ", MIN_WALL));
assert(frame_t_inner - nut_pocket_d >= MIN_FLOOR_CEIL,
    str("Nut pocket floor ", frame_t_inner - nut_pocket_d, "mm below minimum ", MIN_FLOOR_CEIL, "mm"));
// Taper zone height (hex pocket ceiling to bolt hole)
taper_h = frame_t_inner - nut_pocket_d;  // 1.6mm

// Report dimensions for pipeline
report_dimensions(bbox_x, bbox_y, bbox_z, "adapter");


// === Modules ===

module rounded_square(size, r) {
    offset(r=r) offset(r=-r) square(size, center=true);
}

// Outer plate — full frame at waffle-flush thickness
module outer_plate() {
    linear_extrude(frame_t_outer)
        rounded_square(frame_outer, corner_r);
}

// Inner pad — thickens the fan mount zone to full depth for counterbores
// Bounded by the locating rim outer footprint
module inner_pad() {
    linear_extrude(frame_t_inner)
        rounded_square(loc_outer, fan_corner_r + loc_rim_wall);
}

// Center opening
module center_opening() {
    translate([0, 0, -1])
        cylinder(d=fan_opening, h=frame_t_inner + loc_rim_h + 2);
}

// Fan locating rim — on top of inner pad
module fan_locating_rim() {
    translate([0, 0, frame_t_inner]) {
        linear_extrude(loc_rim_h) {
            difference() {
                rounded_square(loc_outer, fan_corner_r + loc_rim_wall);
                rounded_square(loc_inner, fan_corner_r);
            }
        }
    }
}

// Fan bolt holes with hex counterbores and tapered lead-in
module fan_bolt_holes() {
    half_cc = fan_bolt_cc / 2;
    positions = [
        [ half_cc,  half_cc],
        [-half_cc,  half_cc],
        [-half_cc, -half_cc],
        [ half_cc, -half_cc],
    ];

    comp_dia = nut_pocket_dia + FDM_HOLE_COMPENSATION;  // 8.2mm hex AF with compensation

    for (pos = positions) {
        translate([pos[0], pos[1], 0]) {
            // Through bolt hole
            translate([0, 0, -1])
                fdm_hole(d=fan_bolt_dia, h=frame_t_inner + loc_rim_h + 2);

            // Hex nut pocket ($fn=6 for hex)
            translate([0, 0, -1])
                cylinder(d=comp_dia, h=nut_pocket_d + 1, $fn=6);

            // Tapered lead-in: hull from hex at pocket ceiling to circle at bolt hole floor
            hull() {
                // Hex slice at top of nut pocket
                translate([0, 0, nut_pocket_d])
                    cylinder(d=comp_dia, h=0.01, $fn=6);
                // Circle slice at top of taper (bolt hole diameter)
                translate([0, 0, frame_t_inner])
                    cylinder(d=fan_bolt_dia + FDM_HOLE_COMPENSATION, h=0.01);
            }
        }
    }
}

// Y-branch fork at a corner — outer zone thickness
module y_branch(corner_idx) {
    signs = [
        [ 1,  1],
        [-1,  1],
        [-1, -1],
        [ 1, -1],
    ];
    sx = signs[corner_idx][0];
    sy = signs[corner_idx][1];

    cx = sx * branch_root;
    cy = sy * branch_root;

    // Arm along X-axis channel
    hull() {
        translate([cx, cy, 0])
            cylinder(d=branch_w, h=frame_t_outer, $fn=32);
        translate([cx + sx * (branch_len - branch_w/2), cy, 0])
            cylinder(d=branch_w, h=frame_t_outer, $fn=32);
    }

    // Arm along Y-axis channel
    hull() {
        translate([cx, cy, 0])
            cylinder(d=branch_w, h=frame_t_outer, $fn=32);
        translate([cx, cy + sy * (branch_len - branch_w/2), 0])
            cylinder(d=branch_w, h=frame_t_outer, $fn=32);
    }

    // Smooth blend at fork crotch
    translate([cx, cy, 0])
        cylinder(d=branch_w + 2, h=frame_t_outer, $fn=32);
}

// Thumbscrew holes at T-junction corners
module thumbscrew_holes() {
    for (s = [[1, 1], [-1, -1]]) {
        translate([s[0] * branch_root, s[1] * branch_root, -1])
            fdm_hole(d=thumb_dia, h=frame_t_outer + 2);
    }
}


// === Assembly ===

difference() {
    union() {
        // Outer zone: frame + branches at waffle-flush thickness
        outer_plate();
        for (i = [0:3])
            y_branch(i);

        // Inner zone: thickened pad for fan mount + counterbores
        inner_pad();

        // Locating rim on top of inner pad
        fan_locating_rim();
    }

    center_opening();
    fan_bolt_holes();
    thumbscrew_holes();
}
