// Glitter Wizard Hat Cap — Large (fits 14.5"-17" / 20-32oz lamps)
// V2: Single row of alternating stars and moons near the base.

include <fdm-pla.scad>
include <bambu-x1c.scad>

/* ── Parameters ────────────────────────────────────────────── */
height     = 114.3;   // total height including tip
base_od    =  52.0;   // base outer diameter
wall       =   1.5;   // wall thickness (3 perimeters)
tip_r      =   1.5;   // nearly pointed tip
lip_depth  =   3.0;   // retention lip inward step
lip_height =   5.0;   // retention lip height

base_id = base_od - 2 * wall;

// Cone geometry
tip_od = 2 * tip_r + 2 * wall;   // OD at hemisphere transition
cone_h = height - tip_r;          // straight cone portion

// Cutout parameters
star_d       = 6.0;    // star across-points diameter
star_inner   = 0.38;   // inner/outer radius ratio
moon_h       = 5.0;    // crescent moon height
moon_w       = 3.5;    // crescent moon width
n_cutouts    = 12;     // total shapes around circumference
cutout_z_pct = 0.10;   // row position: 10% from base

// Resolution
$fn = 120;

/* ── Helpers ───────────────────────────────────────────────── */

function cone_or(z) = base_od/2 + (tip_od/2 - base_od/2) * (z / cone_h);

// 2D five-pointed star centered at origin, one point up
module star_2d(outer_r, inner_r) {
    points = 5;
    polygon([for (i = [0:2*points-1])
        let(a = i * 180 / points - 90,
            r = (i % 2 == 0) ? outer_r : inner_r)
        [r * cos(a), r * sin(a)]]);
}

// 2D crescent moon centered at origin, horns pointing right
module crescent_2d(h, w) {
    r_outer = h / 2;
    r_inner = r_outer * 0.7;
    offset_x = w * 0.4;
    difference() {
        circle(r=r_outer, $fn=64);
        translate([offset_x, 0])
            circle(r=r_inner, $fn=64);
    }
}

// Cut a shape through the cone wall at height z, angle a
module cone_cutout(z_pos, angle, shape) {
    r = cone_or(z_pos);

    rotate([0, 0, angle])
    translate([0, 0, z_pos])
    translate([r, 0, 0])
    rotate([0, 90, 0])
    linear_extrude(height=wall * 4, center=true) {
        if (shape == "star") {
            star_2d(star_d/2, star_d/2 * star_inner);
        } else {
            crescent_2d(moon_h, moon_w);
        }
    }
}

/* ── Body ──────────────────────────────────────────────────── */

module cone_body() {
    cylinder(d1=base_od, d2=tip_od, h=cone_h);
    translate([0, 0, cone_h])
        sphere(r=tip_od/2);
}

module cone_bore() {
    bore_tip = tip_od - 2*wall;
    translate([0, 0, -0.1])
        cylinder(d1=base_id, d2=bore_tip, h=cone_h + 0.1);
    translate([0, 0, cone_h])
        sphere(r=bore_tip/2);
}

module retention_lip() {
    lip_id = base_id - 2 * lip_depth;
    difference() {
        cylinder(d=base_id + 0.1, h=lip_height);
        translate([0, 0, -0.1])
            cylinder(d=lip_id, h=lip_height + 0.2);
    }
}

/* ── Cutout ring ───────────────────────────────────────────── */

module cutout_ring() {
    z = cutout_z_pct * cone_h;
    step = 360 / n_cutouts;

    for (i = [0:n_cutouts-1]) {
        a = i * step;
        shape = (i % 2 == 0) ? "star" : "moon";
        cone_cutout(z, a, shape);
    }
}

/* ── Assembly ──────────────────────────────────────────────── */

module glitter_wizard_hat_large() {
    difference() {
        cone_body();
        cone_bore();
        cutout_ring();
    }
    retention_lip();
}

glitter_wizard_hat_large();
report_dimensions(base_od, base_od, height, "glitterWizardHatLarge");
