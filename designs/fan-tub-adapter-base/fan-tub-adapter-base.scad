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

// Clip ledges — four outward protrusions on rim exterior, one per side.
// Each ledge has a 45° chamfer on its underside for printability (no overhang),
// followed by a flat engagement zone at the top where the hook catches.
//
// XZ cross-section (X = radial outward, Z = up):
//
//   z_flat_top  ┌──────────────┐  rim top / ledge top
//               │  flat zone   │  clip_ledge_flat mm tall — hook catches here
//   z_flat_bot  ├──────────────┘
//               │╲  chamfer    |  45°: rises clip_ledge_depth mm over clip_ledge_depth mm
//   z_cham_bot  ╧              |  chamfer start — 0 protrusion, self-supporting from here
//               x_rim          x_ledge
//
module clip_ledges() {
    x_rim    = loc_outer / 2;                    // 62mm — rim outer face
    x_ledge  = x_rim + clip_ledge_depth;         // 65mm — ledge outer face
    z_top    = frame_t_inner + loc_rim_h;        // 9.0mm — rim top
    z_flat_bot = z_top - clip_ledge_flat;        // 7.0mm — flat zone bottom
    z_cham_bot = z_flat_bot - clip_ledge_depth;  // 4.0mm — chamfer start (45°)

    for (angle = [0, 90, 180, 270]) {
        rotate([0, 0, angle])
        translate([0, -clip_arm_w/2, 0])
            rotate([90, 0, 0])
                linear_extrude(clip_arm_w)
                    polygon([
                        [x_rim,   z_cham_bot],  // chamfer base (0 protrusion)
                        [x_ledge, z_flat_bot],  // chamfer top / flat bottom
                        [x_ledge, z_top],       // ledge outer top
                        [x_rim,   z_top],       // ledge inner top
                    ]);
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
