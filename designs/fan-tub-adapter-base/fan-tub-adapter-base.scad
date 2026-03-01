// Fan-Tub Adapter v2.0 — Base Plate
// Caulked to lid. Fan drops into locating rim.
// Clip ledges on rim exterior for tool-free retention clip.
// No bolt holes or thumbscrew holes — all fastener features removed from v1.

include <fdm-pla.scad>
include <bambu-x1c.scad>
include <common.scad>
include <fan-tub-adapter-params.scad>

$fn = 80;

// Validate constraints
assert(frame_t_outer >= MIN_WALL, str("Outer thickness ", frame_t_outer, " below min wall ", MIN_WALL));
assert(loc_rim_h >= MIN_WALL, str("Rim height ", loc_rim_h, " below min wall ", MIN_WALL));

// Report dimensions for pipeline
report_dimensions(base_bbox_x, base_bbox_y, base_bbox_z, "base");


// === Modules ===

module rounded_square(size, r) {
    offset(r=r) offset(r=-r) square(size, center=true);
}

// Outer plate — full frame at waffle-flush thickness
module outer_plate() {
    linear_extrude(frame_t_outer)
        rounded_square(frame_outer, corner_r);
}

// Inner pad — thickened fan mount zone
module inner_pad() {
    linear_extrude(frame_t_inner)
        rounded_square(loc_outer, fan_corner_r + loc_rim_wall);
}

// Center opening — through entire height
module center_opening() {
    translate([0, 0, -1])
        cylinder(d=fan_opening, h=base_bbox_z + 2);
}

// Fan locating rim — 4.0mm tall (was 1.5mm in v1)
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

// Clip ledges — four 1.0mm outward protrusions on rim exterior
// One centered per side, 8mm wide, at z=6.0 to z=7.5 (z_ledge_bot - clip_ledge_h to z_ledge_bot)
// Actually: ledge at z_ledge_bot (7.5) down by clip_ledge_h (1.5) = z=6.0 to z=7.5
module clip_ledges() {
    ledge_z_bot = z_ledge_bot - clip_ledge_h + clip_ledge_h;  // z_ledge_bot = 7.5
    // Per the plan: z=6.0 to z=7.5
    // z_ledge_bot = 7.5 is the TOP of the ledge (= rim_top - clip_ledge_h... wait)
    // Plan says: z=6.0 to z=7.5, ledge_h=1.5
    // z_rim_top=9.0, clip_ledge_h=1.5
    // z_ledge_bot = z_rim_top - clip_ledge_h = 7.5 — this is ledge bottom per params
    // So ledge runs from z=7.5 to z=7.5+1.5=9.0? No, that's the top of the rim.
    // Re-reading the plan cross-section:
    //   z=7.5 ╠══╗  ledge (1.0mm out, 1.5mm tall)
    //   z=6.0 ╠══╝
    // So ledge is z=6.0 to z=7.5, height = 1.5mm
    ledge_z = frame_t_inner + loc_rim_h - clip_ledge_h - clip_ledge_h;  // 5+4-1.5-1.5 = 6.0
    ledge_h = clip_ledge_h;  // 1.5mm

    half_outer = loc_outer / 2;  // 62mm — rim outer edge from center

    // Four ledges, one centered per side
    for (angle = [0, 90, 180, 270]) {
        rotate([0, 0, angle])
        translate([half_outer, -clip_arm_w/2, ledge_z])
            cube([clip_ledge_depth, clip_arm_w, ledge_h]);
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


// === Assembly ===

difference() {
    union() {
        outer_plate();
        for (i = [0:3])
            y_branch(i);
        inner_pad();
        fan_locating_rim();
        clip_ledges();
    }

    center_opening();
}
