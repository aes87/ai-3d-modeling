// Humidity-Output V2 Duct Mount
// V2 corrective redesign:
//   1. Spigot OD reduced from 108mm to 106mm (duct wire rings could not pass at 108)
//   2. Lead-in taper at spigot top: OD tapers 106->100mm over 8mm for easy duct location
//   3. Internal fins start at z=0 (was z=5) — fixes unsupported first layers
//
// Mounts to bin lid via waffle-grid Y-branches (caulked).
// Duct spigot accepts standard 4" flex dryer duct.
// Sealed with 3/4" closed-cell EPDM foam tape + releasable zip tie.

include <fdm-pla.scad>
include <bambu-x1c.scad>
include <common.scad>
include <humidity-output-v2-params.scad>

$fn = 80;

// === Assertions ===
assert(ho2_spigot_wall >= MIN_WALL,
    str("Spigot wall ", ho2_spigot_wall, " below min ", MIN_WALL));
assert((ho2_spigot_od/2 - ho2_foam_groove_d) - ho2_spigot_id/2 >= MIN_WALL,
    str("Wall at foam groove bottom too thin: ",
        (ho2_spigot_od/2 - ho2_foam_groove_d) - ho2_spigot_id/2, " < ", MIN_WALL));
assert(ho2_fin_int_t >= MIN_WALL,
    str("Internal fin thickness ", ho2_fin_int_t, " below min ", MIN_WALL));
assert(ho2_fin_ext_h / ho2_fin_ext_r >= 1.0,
    str("Shark fin slope shallower than 45 deg from horizontal"));
// Taper tip wall must meet MIN_WALL
assert((ho2_taper_tip_od - ho2_spigot_id) / 2 >= MIN_WALL,
    str("Taper tip wall too thin: ", (ho2_taper_tip_od - ho2_spigot_id) / 2));

// Report bounding box for pipeline
report_dimensions(ho2_bbox_x, ho2_bbox_y, ho2_bbox_z, "humidityOutputV2");


// === Modules ===

// Rounded square for base plate shapes
module ho2_rounded_square(size, r) {
    offset(r=r) offset(r=-r) square([size, size], center=true);
}

// Outer plate: full frame at waffle-flush thickness
module ho2_outer_plate() {
    linear_extrude(ho2_frame_t_outer)
        ho2_rounded_square(ho2_frame_outer, ho2_corner_r);
}

// Inner pad: thickened zone that the spigot rises from
module ho2_inner_pad() {
    linear_extrude(ho2_inner_pad_t)
        ho2_rounded_square(ho2_inner_pad_size, ho2_inner_pad_r);
}

// Y-branch fork -- one per corner, engages into waffle channels
module ho2_y_branch(corner_idx) {
    signs = [
        [ 1,  1],
        [-1,  1],
        [-1, -1],
        [ 1, -1],
    ];
    sx = signs[corner_idx][0];
    sy = signs[corner_idx][1];

    cx = sx * ho2_branch_root;
    cy = sy * ho2_branch_root;

    // X-direction arm
    hull() {
        translate([cx, cy, 0])
            cylinder(d=ho2_branch_w, h=ho2_frame_t_outer, $fn=32);
        translate([cx + sx * (ho2_branch_len - ho2_branch_w/2), cy, 0])
            cylinder(d=ho2_branch_w, h=ho2_frame_t_outer, $fn=32);
    }
    // Y-direction arm
    hull() {
        translate([cx, cy, 0])
            cylinder(d=ho2_branch_w, h=ho2_frame_t_outer, $fn=32);
        translate([cx, cy + sy * (ho2_branch_len - ho2_branch_w/2), 0])
            cylinder(d=ho2_branch_w, h=ho2_frame_t_outer, $fn=32);
    }
    // Root blob for smooth junction
    translate([cx, cy, 0])
        cylinder(d=ho2_branch_w + 2, h=ho2_frame_t_outer, $fn=32);
}

// Spigot main body -- cylindrical below taper, conical taper at top
module ho2_spigot_body() {
    // Main cylinder from spigot start to taper start
    translate([0, 0, ho2_z_spigot_start])
        cylinder(d=ho2_spigot_od,
                 h=ho2_z_taper_start - ho2_z_spigot_start);

    // Lead-in taper: cone from full OD to tip OD over taper height
    translate([0, 0, ho2_z_taper_start])
        cylinder(d1=ho2_spigot_od, d2=ho2_taper_tip_od,
                 h=ho2_taper_height);
}

// Lower stop ridge with 45 deg underside chamfer.
// Ridge OD 114mm > duct ring ID 107.6mm -- duct cannot pass.
module ho2_lower_ridge() {
    translate([0, 0, ho2_z_lower_ridge_bot])
        union() {
            // 45 deg chamfer from spigot OD up to ridge OD
            cylinder(d1=ho2_spigot_od,
                     d2=ho2_lower_ridge_od,
                     h=ho2_lower_ridge_h);
            // Flat top ring at full ridge OD
            translate([0, 0, ho2_lower_ridge_h])
                cylinder(d=ho2_lower_ridge_od,
                         h=ho2_lower_ridge_w - ho2_lower_ridge_h);
        }
}

// Foam groove: annular channel on spigot OD in the seal zone.
// V2.1: 45° chamfer at groove top eliminates horizontal bridge at foam_top.
// The subtraction extends chamfer_h above foam_w, tapering from groove floor
// back to spigot OD — exactly 45° (chamfer_h == groove_d == 2.5mm).
module ho2_foam_groove() {
    r_inner = ho2_spigot_od / 2 - ho2_foam_groove_d;
    r_outer = ho2_spigot_od / 2 + 1;  // extend past OD for clean subtraction
    translate([0, 0, ho2_z_foam_bot])
        rotate_extrude($fn=80)
            polygon([
                [r_inner, 0],
                [r_outer, 0],
                [r_outer, ho2_foam_w + ho2_foam_groove_chamfer_h],
                [r_inner, ho2_foam_w],
            ]);
}

// Center bore: airflow passage through entire assembly.
module ho2_center_bore() {
    translate([0, 0, -1])
        cylinder(d=ho2_spigot_id, h=ho2_bbox_z + 2);
}

// External shark fins: triangular gussets at spigot-to-pad junction.
// Triangle in the r-z plane, extruded tangentially.
// Stays 2mm below lower ridge bottom so fins are clear of duct zone.
module ho2_external_shark_fins() {
    r_spigot = ho2_spigot_od / 2;
    for (i = [0 : ho2_fin_count - 1]) {
        rotate([0, 0, i * 360 / ho2_fin_count])
            translate([0, -ho2_fin_ext_t/2, 0])
                rotate([90, 0, 0])
                    linear_extrude(ho2_fin_ext_t)
                        polygon([
                            [r_spigot,                ho2_z_spigot_start],
                            [r_spigot + ho2_fin_ext_r, ho2_z_spigot_start],
                            [r_spigot,                ho2_z_spigot_start + ho2_fin_ext_h],
                        ]);
    }
}

// Internal fins: radial ribs projecting inward from bore wall.
// V2: start at z=0 (bed level) so every layer prints on top of the previous.
// Full depth from z=0 to z_taper_start_fin, then taper to zero over top 10mm.
// Overlap 1mm into spigot wall to avoid coincident face T-junction.
module ho2_internal_fins() {
    r_bore         = ho2_spigot_id / 2;
    z_full_depth_top = ho2_z_spigot_top - ho2_fin_int_taper_z;  // 52mm

    for (i = [0 : ho2_fin_count - 1]) {
        rotate([0, 0, i * 360 / ho2_fin_count])
            union() {
                // Constant-depth body: z=0 to z_full_depth_top
                hull() {
                    translate([r_bore - ho2_fin_int_d_base, -ho2_fin_int_t/2, ho2_fin_int_z_start])
                        cube([ho2_fin_int_d_base + ho2_fin_wall_lap, ho2_fin_int_t, 0.01]);
                    translate([r_bore - ho2_fin_int_d_base, -ho2_fin_int_t/2, z_full_depth_top])
                        cube([ho2_fin_int_d_base + ho2_fin_wall_lap, ho2_fin_int_t, 0.01]);
                }
                // Taper zone: full depth at z_full_depth_top -> flush at spigot top
                hull() {
                    translate([r_bore - ho2_fin_int_d_base, -ho2_fin_int_t/2, z_full_depth_top])
                        cube([ho2_fin_int_d_base + ho2_fin_wall_lap, ho2_fin_int_t, 0.01]);
                    translate([r_bore, -ho2_fin_int_t/2, ho2_z_spigot_top - 0.01])
                        cube([ho2_fin_wall_lap, ho2_fin_int_t, 0.01]);
                }
            }
    }
}


// === Assembly ===
// Main body (plate + spigot + ridges + external fins) differenced with bore + foam groove.
// Internal fins unioned AFTER the difference so the bore does not cut them.
// Fins overlap 1mm into the spigot wall (fin_wall_lap) — no coincident face with bore wall.

union() {
    difference() {
        union() {
            ho2_outer_plate();
            for (i = [0:3])
                ho2_y_branch(i);
            ho2_inner_pad();
            ho2_spigot_body();
            ho2_lower_ridge();
            ho2_external_shark_fins();
        }

        ho2_foam_groove();
        ho2_center_bore();
    }

    ho2_internal_fins();
}
