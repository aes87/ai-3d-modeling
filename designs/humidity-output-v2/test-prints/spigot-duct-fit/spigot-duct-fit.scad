// Spigot Duct Fit Test Print
// 90-degree arc section of humidity-output-v2 spigot
// Tests: spigot OD 106mm, foam groove 2.5mm deep x 19mm wide,
//        lower stop ridge OD 114mm with 45-deg chamfer,
//        lead-in taper tip wall 2.0mm
//
// Print flat on bed (base plate at z=0), no supports needed.

include <fdm-pla.scad>
include <bambu-x1c.scad>
include <common.scad>
include <humidity-output-v2-params.scad>

$fn = 80;

// === Arc parameters ===
arc_angle    = 90;    // degrees of spigot to extract
arc_start    = 0;     // starting angle (first quadrant: 0-90)
chord_wall   = 2;     // mm — flat walls closing the arc cut faces
base_plate_t = 3;     // mm — base plate thickness for bed adhesion

// === Derived dimensions ===
ridge_r  = ho2_lower_ridge_od / 2;   // 57mm — widest radial feature
spigot_r = ho2_spigot_od / 2;        // 53mm
bore_r   = ho2_spigot_id / 2;        // 48mm

// Total height uses parent z-coordinates directly.
// Base plate sits at z=0..base_plate_t, spigot starts at z=ho2_z_spigot_start (5mm).
// Between z=3 and z=5, the chord walls and base plate provide solid material.
part_z = ho2_z_spigot_top;  // 62mm

// XY extent: from -chord_wall to ridge_r in each axis = ridge_r + chord_wall
// But base plate extends to ridge_r + chord_wall on the positive side too:
// from -chord_wall to (ridge_r + chord_wall), total = ridge_r + 2*chord_wall
part_xy = ridge_r + 2 * chord_wall;  // 61mm

// === Assertions ===
assert(chord_wall >= MIN_WALL,
    str("Chord wall ", chord_wall, " below min ", MIN_WALL));
assert((ho2_spigot_od/2 - ho2_foam_groove_d) - bore_r >= MIN_WALL,
    str("Wall at foam groove bottom too thin"));
assert((ho2_taper_tip_od - ho2_spigot_id) / 2 >= MIN_WALL,
    str("Taper tip wall too thin"));

// Report dimensions for validation pipeline
report_dimensions(part_xy, part_xy, part_z, "spigotDuctFit");

// === Helper: 2D pie slice for arc extraction ===
module pie_slice_2d(r, start_angle, end_angle) {
    steps = ceil((end_angle - start_angle) / 2);
    points = concat(
        [[0, 0]],
        [for (i = [0 : steps])
            let(a = start_angle + i * (end_angle - start_angle) / steps)
            [r * cos(a), r * sin(a)]
        ]
    );
    polygon(points);
}

// === Helper: 3D pie mask for intersecting with spigot ===
module arc_mask(r, h, start_angle, end_angle) {
    linear_extrude(h)
        pie_slice_2d(r, start_angle, end_angle);
}

// === Spigot body (same as parent) ===
module test_spigot_body() {
    // Main cylinder from spigot start to taper start
    translate([0, 0, ho2_z_spigot_start])
        cylinder(d=ho2_spigot_od,
                 h=ho2_z_taper_start - ho2_z_spigot_start);
    // Lead-in taper
    translate([0, 0, ho2_z_taper_start])
        cylinder(d1=ho2_spigot_od, d2=ho2_taper_tip_od,
                 h=ho2_taper_height);
}

// === Lower stop ridge (same as parent) ===
module test_lower_ridge() {
    translate([0, 0, ho2_z_lower_ridge_bot])
        union() {
            // 45 deg chamfer from spigot OD up to ridge OD
            cylinder(d1=ho2_spigot_od,
                     d2=ho2_lower_ridge_od,
                     h=ho2_lower_ridge_h);
            // Flat top at full ridge OD
            translate([0, 0, ho2_lower_ridge_h])
                cylinder(d=ho2_lower_ridge_od,
                         h=ho2_lower_ridge_w - ho2_lower_ridge_h);
        }
}

// === Foam groove (same as parent) ===
module test_foam_groove() {
    r_inner = ho2_spigot_od / 2 - ho2_foam_groove_d;
    r_outer = ho2_spigot_od / 2 + 1;
    translate([0, 0, ho2_z_foam_bot])
        rotate_extrude($fn=80)
            polygon([
                [r_inner, 0],
                [r_outer, 0],
                [r_outer, ho2_foam_w],
                [r_inner, ho2_foam_w],
            ]);
}

// === Center bore ===
module test_center_bore() {
    translate([0, 0, -1])
        cylinder(d=ho2_spigot_id, h=part_z + 2);
}

// === One internal fin at 45 degrees (midpoint of arc) ===
module test_internal_fin() {
    r_bore = ho2_spigot_id / 2;
    z_full_depth_top = ho2_z_spigot_top - ho2_fin_int_taper_z;

    rotate([0, 0, 45])
        union() {
            // Constant-depth body
            hull() {
                translate([r_bore - ho2_fin_int_d_base, -ho2_fin_int_t/2, ho2_fin_int_z_start])
                    cube([ho2_fin_int_d_base + ho2_fin_wall_lap, ho2_fin_int_t, 0.01]);
                translate([r_bore - ho2_fin_int_d_base, -ho2_fin_int_t/2, z_full_depth_top])
                    cube([ho2_fin_int_d_base + ho2_fin_wall_lap, ho2_fin_int_t, 0.01]);
            }
            // Taper zone
            hull() {
                translate([r_bore - ho2_fin_int_d_base, -ho2_fin_int_t/2, z_full_depth_top])
                    cube([ho2_fin_int_d_base + ho2_fin_wall_lap, ho2_fin_int_t, 0.01]);
                translate([r_bore, -ho2_fin_int_t/2, ho2_z_spigot_top - 0.01])
                    cube([ho2_fin_wall_lap, ho2_fin_int_t, 0.01]);
            }
        }
}

// === Base plate ===
// Rectangular slab at z=0, extends to ridge_r + chord_wall in X and Y.
module test_base_plate() {
    bp_extent = ridge_r + chord_wall;  // positive extent
    translate([-chord_wall, -chord_wall, 0])
        cube([bp_extent + chord_wall, bp_extent + chord_wall, base_plate_t]);
}

// === Chord walls ===
// Two flat walls closing the cut faces of the 90-degree arc.
// Extend from z=0 (bed) through full height so they connect to base plate.
// Each wall runs from center outward past the ridge radius.
module test_chord_walls() {
    // Wall at angle=0 (closing the Y-negative face, along X axis)
    translate([0, -chord_wall, 0])
        cube([ridge_r + chord_wall, chord_wall, part_z]);

    // Wall at angle=90 (closing the X-negative face, along Y axis)
    translate([-chord_wall, 0, 0])
        cube([chord_wall, ridge_r + chord_wall, part_z]);
}

// === Solid fill column under the spigot ===
// The spigot starts at z=5, but chord walls and base plate exist from z=0.
// Between z=base_plate_t (3) and z=ho2_z_spigot_start (5), we need solid
// material connecting the base plate to the spigot section. Use a quarter-
// cylinder fill that matches the spigot OD to bridge this gap.
module test_spigot_base_fill() {
    // Fill from base_plate_t to spigot_start with a sector of solid cylinder
    // matching the spigot OD, so the chord walls have something to bond to.
    if (ho2_z_spigot_start > base_plate_t) {
        intersection() {
            translate([0, 0, base_plate_t])
                cylinder(d=ho2_spigot_od,
                         h=ho2_z_spigot_start - base_plate_t);
            translate([0, 0, base_plate_t - 0.01])
                arc_mask(ridge_r + 1, ho2_z_spigot_start - base_plate_t + 0.02,
                         arc_start, arc_start + arc_angle);
        }
    }
}

// === Main assembly ===
// Strategy: build everything as a single manifold.
// 1. Union all positive geometry (spigot + ridge + chord walls + base + fill)
// 2. Subtract bore and foam groove
// 3. Union internal fin (after bore subtraction, same as parent)

union() {
    difference() {
        union() {
            // Arc section of spigot body + ridge
            intersection() {
                union() {
                    test_spigot_body();
                    test_lower_ridge();
                }
                // Arc mask with generous radius and height
                translate([0, 0, -1])
                    arc_mask(ridge_r + 1, part_z + 2,
                             arc_start, arc_start + arc_angle);
            }

            // Structural: base plate, chord walls, spigot base fill
            test_base_plate();
            test_chord_walls();
            test_spigot_base_fill();
        }

        // Subtractions: foam groove (only within arc sector) and bore
        intersection() {
            test_foam_groove();
            translate([0, 0, -1])
                arc_mask(ridge_r + 2, part_z + 2,
                         arc_start, arc_start + arc_angle);
        }
        test_center_bore();
    }

    // Internal fin (added after bore so bore doesn't cut it)
    intersection() {
        test_internal_fin();
        translate([0, 0, -1])
            arc_mask(spigot_r + 1, part_z + 2,
                     arc_start, arc_start + arc_angle);
    }
}
