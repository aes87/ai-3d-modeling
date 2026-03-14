// Humidity-Output Duct Mount
// Mounts to bin lid via waffle-grid Y-branches (caulked, same architecture as fan-tub-adapter-base).
// Duct spigot accepts standard 4" flex dryer duct.
// Sealed with 3/4" closed-cell EPDM foam tape + releasable 16" zip tie.

include <fdm-pla.scad>
include <bambu-x1c.scad>
include <common.scad>
include <humidity-output-params.scad>

$fn = 80;

// Validate critical walls
assert(spigot_wall >= MIN_WALL,
    str("Spigot wall ", spigot_wall, " below min ", MIN_WALL));
assert((spigot_od/2 - foam_groove_d) - spigot_id/2 >= MIN_WALL,
    str("Wall at foam groove bottom too thin"));

// Report bounding box for pipeline
report_dimensions(ho_bbox_x, ho_bbox_y, ho_bbox_z, "humidityOutput");


// === Modules ===

module ho_rounded_square(size, r) {
    offset(r=r) offset(r=-r) square([size, size], center=true);
}

// Outer plate: full frame at waffle-flush thickness, Y-branch roots included
module outer_plate() {
    linear_extrude(ho_frame_t_outer)
        ho_rounded_square(ho_frame_outer, ho_corner_r);
}

// Inner pad: thickened zone that the spigot rises from
module inner_pad() {
    linear_extrude(ho_inner_pad_t)
        ho_rounded_square(ho_inner_pad_size, 8);
}

// Y-branch fork — one per corner, engages into waffle channels
module y_branch(corner_idx) {
    signs = [
        [ 1,  1],
        [-1,  1],
        [-1, -1],
        [ 1, -1],
    ];
    sx = signs[corner_idx][0];
    sy = signs[corner_idx][1];

    cx = sx * ho_branch_root;
    cy = sy * ho_branch_root;

    // Arm along X channel
    hull() {
        translate([cx, cy, 0])
            cylinder(d=ho_branch_w, h=ho_frame_t_outer, $fn=32);
        translate([cx + sx * (ho_branch_len - ho_branch_w/2), cy, 0])
            cylinder(d=ho_branch_w, h=ho_frame_t_outer, $fn=32);
    }
    // Arm along Y channel
    hull() {
        translate([cx, cy, 0])
            cylinder(d=ho_branch_w, h=ho_frame_t_outer, $fn=32);
        translate([cx, cy + sy * (ho_branch_len - ho_branch_w/2), 0])
            cylinder(d=ho_branch_w, h=ho_frame_t_outer, $fn=32);
    }
    // Blend at fork crotch
    translate([cx, cy, 0])
        cylinder(d=ho_branch_w + 2, h=ho_frame_t_outer, $fn=32);
}

// Spigot main body: solid cylinder from inner pad top to spigot top
module spigot_body() {
    translate([0, 0, z_spigot_start])
        cylinder(d=spigot_od, h=z_spigot_top - z_spigot_start);
}

// Lower stop ridge: duct hard-rings (ID 110mm) cannot pass over this (OD 114mm).
// 45° chamfer on underside (chamfer height = protrusion = 3mm) — no unsupported overhang.
module lower_ridge() {
    translate([0, 0, z_lower_ridge_bot])
        union() {
            // Chamfered base: cone from spigot OD to full ridge OD over lower_ridge_h mm
            cylinder(
                d1=spigot_od,
                d2=spigot_od + 2 * lower_ridge_h,
                h=lower_ridge_h
            );
            // Flat top portion (remaining height above chamfer)
            translate([0, 0, lower_ridge_h])
                cylinder(d=spigot_od + 2 * lower_ridge_h, h=lower_ridge_w - lower_ridge_h);
        }
}

// Upper guide ridge: keeps zip tie from riding up out of foam zone.
// 45° chamfer on underside (chamfer height = protrusion = 2mm).
module upper_ridge() {
    translate([0, 0, z_upper_ridge_bot])
        union() {
            cylinder(
                d1=spigot_od,
                d2=spigot_od + 2 * upper_ridge_h,
                h=upper_ridge_h
            );
            translate([0, 0, upper_ridge_h])
                cylinder(d=spigot_od + 2 * upper_ridge_h, h=upper_ridge_w - upper_ridge_h);
        }
}

// Foam groove: annular channel cut into the spigot OD.
// Uses rotate_extrude of a rectangular profile for a clean manifold subtraction.
// Profile spans from groove bottom (r = spigot_od/2 - foam_groove_d) to just past spigot OD.
module foam_groove() {
    r_inner = spigot_od / 2 - foam_groove_d;
    r_outer = spigot_od / 2 + 1;   // 1mm past spigot OD ensures clean cut
    translate([0, 0, z_foam_bot])
        rotate_extrude($fn=80)
            polygon([
                [r_inner, 0],
                [r_outer, 0],
                [r_outer, foam_w],
                [r_inner, foam_w],
            ]);
}

// Center bore: airflow passage through entire assembly
module center_bore() {
    translate([0, 0, -1])
        cylinder(d=spigot_id, h=ho_bbox_z + 2);
}


// === Assembly ===

difference() {
    union() {
        outer_plate();
        for (i = [0:3])
            y_branch(i);
        inner_pad();
        spigot_body();
        lower_ridge();
        upper_ridge();
    }

    foam_groove();
    center_bore();
}
