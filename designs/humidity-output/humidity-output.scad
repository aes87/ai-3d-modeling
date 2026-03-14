// Humidity-Output Duct Mount
// Mounts to bin lid via waffle-grid Y-branches (caulked, same architecture as fan-tub-adapter-base).
// Duct spigot accepts standard 4" flex dryer duct.
// Sealed with 3/4" closed-cell EPDM foam tape + releasable clamp.
// Internal fins resist ring buckling under clamp load (wall ribs, bore cuts cleanly through them).
// External shark fins are structural/aesthetic gussets at the spigot base, aligned with internal fins.

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
assert(fin_int_t >= MIN_WALL,
    str("Internal fin thickness ", fin_int_t, " below min ", MIN_WALL));
assert(fin_ext_h / fin_ext_r >= 1.0,
    str("Shark fin slope shallower than 45deg"));

// Report bounding box for pipeline
report_dimensions(ho_bbox_x, ho_bbox_y, ho_bbox_z, "humidityOutput");


// === Modules ===

module ho_rounded_square(size, r) {
    offset(r=r) offset(r=-r) square([size, size], center=true);
}

// Outer plate: full frame at waffle-flush thickness
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

    hull() {
        translate([cx, cy, 0])
            cylinder(d=ho_branch_w, h=ho_frame_t_outer, $fn=32);
        translate([cx + sx * (ho_branch_len - ho_branch_w/2), cy, 0])
            cylinder(d=ho_branch_w, h=ho_frame_t_outer, $fn=32);
    }
    hull() {
        translate([cx, cy, 0])
            cylinder(d=ho_branch_w, h=ho_frame_t_outer, $fn=32);
        translate([cx, cy + sy * (ho_branch_len - ho_branch_w/2), 0])
            cylinder(d=ho_branch_w, h=ho_frame_t_outer, $fn=32);
    }
    translate([cx, cy, 0])
        cylinder(d=ho_branch_w + 2, h=ho_frame_t_outer, $fn=32);
}

// Spigot main body
module spigot_body() {
    translate([0, 0, z_spigot_start])
        cylinder(d=spigot_od, h=z_spigot_top - z_spigot_start);
}

// Lower stop ridge with 45° underside chamfer.
// Ridge OD 114mm > duct ring ID 110mm — duct cannot pass.
module lower_ridge() {
    translate([0, 0, z_lower_ridge_bot])
        union() {
            cylinder(d1=spigot_od, d2=spigot_od + 2*lower_ridge_h, h=lower_ridge_h);
            translate([0, 0, lower_ridge_h])
                cylinder(d=spigot_od + 2*lower_ridge_h, h=lower_ridge_w - lower_ridge_h);
        }
}

// Upper guide ridge with 45° underside chamfer.
module upper_ridge() {
    translate([0, 0, z_upper_ridge_bot])
        union() {
            cylinder(d1=spigot_od, d2=spigot_od + 2*upper_ridge_h, h=upper_ridge_h);
            translate([0, 0, upper_ridge_h])
                cylinder(d=spigot_od + 2*upper_ridge_h, h=upper_ridge_w - upper_ridge_h);
        }
}

// Foam groove: annular channel on spigot OD in the seal zone.
module foam_groove() {
    r_inner = spigot_od / 2 - foam_groove_d;
    r_outer = spigot_od / 2 + 1;
    translate([0, 0, z_foam_bot])
        rotate_extrude($fn=80)
            polygon([
                [r_inner, 0],
                [r_outer, 0],
                [r_outer, foam_w],
                [r_inner, foam_w],
            ]);
}

// Center bore: airflow passage through entire assembly.
// Cuts cleanly through fins in the main union — produces proper manifold surfaces.
module center_bore() {
    translate([0, 0, -1])
        cylinder(d=spigot_id, h=ho_bbox_z + 2);
}

// External shark fins: triangular gussets at spigot-to-pad junction.
// Triangle in the r-z plane, extruded tangentially.
// Stays below z_lower_ridge_bot — 2mm clearance so fins are clear of duct zone.
// Overhang: arctan(fin_ext_h / fin_ext_r) ≈ 55° from horizontal — no support needed.
// Aligned with internal fins (same count, same starting angle).
module external_shark_fins() {
    r_spigot = spigot_od / 2;    // 54mm
    for (i = [0 : fin_count - 1]) {
        rotate([0, 0, i * 360 / fin_count])
            // Rotate the 2D triangle from the XY plane into the r-Z plane,
            // then extrude tangentially (Y direction).
            translate([0, -fin_ext_t/2, 0])
                rotate([90, 0, 0])
                    linear_extrude(fin_ext_t)
                        polygon([
                            [r_spigot,             z_spigot_start],             // inner base
                            [r_spigot + fin_ext_r, z_spigot_start],             // outer base
                            [r_spigot,             z_spigot_start + fin_ext_h], // tip
                        ]);
    }
}

// Internal fins: radial ribs inside the spigot wall.
// Taper from deep (fin_int_d_base) at the spigot base to shallow (fin_int_d_top) at the top.
// Placed inside the main union — the center_bore cuts through them cleanly,
// leaving rib material within the wall zone (r = spigot_id/2 to spigot_od/2).
// Aligned with external shark fins (same count, same starting angle).
// No overhangs: fins are vertical. Print orientation: flat bottom on bed.
module internal_fins() {
    r_bore     = spigot_id / 2;       // 49mm — bore inner surface
    r_wall_out = spigot_od / 2;       // 54mm — spigot outer surface
    for (i = [0 : fin_count - 1]) {
        rotate([0, 0, i * 360 / fin_count])
            hull() {
                // Base: fin tip at (r_bore - fin_int_d_base), outer face at r_wall_out
                translate([r_bore - fin_int_d_base, -fin_int_t/2, z_spigot_start])
                    cube([fin_int_d_base + (r_wall_out - r_bore), fin_int_t, 0.01]);
                // Top: fin tip at (r_bore - fin_int_d_top), outer face at r_wall_out
                translate([r_bore - fin_int_d_top, -fin_int_t/2, z_spigot_top - 0.01])
                    cube([fin_int_d_top + (r_wall_out - r_bore), fin_int_t, 0.01]);
            }
    }
}


// === Assembly ===
// All geometry — including both fin types — is in one union inside one difference.
// The bore cuts cleanly through the internal fins, exposing their radial cross-sections
// on the bore wall surface. No outer union wrapper needed.

difference() {
    union() {
        outer_plate();
        for (i = [0:3])
            y_branch(i);
        inner_pad();
        spigot_body();
        lower_ridge();
        upper_ridge();
        external_shark_fins();
        internal_fins();
    }

    foam_groove();
    center_bore();
}
