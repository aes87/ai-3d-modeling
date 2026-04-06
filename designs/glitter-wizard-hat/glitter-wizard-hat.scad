// Glitter Wizard Hat Cap — Replacement for vintage lava lamp
// Parametric for two sizes: "small" (14.5" lamp) and "large" (17" lamp)

include <fdm-pla.scad>
include <bambu-x1c.scad>

/* ── Size selector ─────────────────────────────────────────── */
// Change to "small" for the 14.5" lamp size
SIZE = "large";  // "small" or "large"

/* ── Parameters ────────────────────────────────────────────── */

// Large size (fits 14.5"-17" / 20-32oz lamps)
large_height     = 114.3;
large_base_od    =  52.0;
large_wall       =   1.5;
large_tip_r      =   3.5;
large_lip_depth  =   3.0;
large_lip_height =   5.0;

// Small size (fits 14.5" / 20oz lamps)
small_height     =  95.0;
small_base_od    =  48.0;
small_wall       =   1.5;
small_tip_r      =   3.0;
small_lip_depth  =   3.0;
small_lip_height =   5.0;

// Select active params
height     = (SIZE == "large") ? large_height     : small_height;
base_od    = (SIZE == "large") ? large_base_od    : small_base_od;
wall       = (SIZE == "large") ? large_wall       : small_wall;
tip_r      = (SIZE == "large") ? large_tip_r      : small_tip_r;
lip_depth  = (SIZE == "large") ? large_lip_depth  : small_lip_depth;
lip_height = (SIZE == "large") ? large_lip_height : small_lip_height;

base_id = base_od - 2 * wall;

// Cone geometry: the cone tapers from base_od at z=0 to a small
// diameter at the tip, then a hemisphere caps it.
// The tip of the cone body (before hemisphere) has OD = 2*tip_r
tip_od     = 2 * tip_r + 2 * wall;  // OD where hemisphere begins
cone_h     = height - tip_r;         // height of the straight cone body

// Cutout parameters
star_d       =  6.0;   // star across-points diameter
star_inner   =  0.38;  // inner/outer radius ratio for 5-pointed star
star_pts     =  5;
circle_d     =  3.5;   // circle cutout diameter
crescent_h   =  5.0;   // crescent moon height
crescent_w   =  3.5;   // crescent moon width

// Cutout layout
n_rows = 4;

// Resolution
$fn = 120;

/* ── Helpers ───────────────────────────────────────────────── */

// Outer radius of the cone at height z (z=0 is base, z=cone_h is tip)
function cone_or(z) = base_od/2 + (tip_od/2 - base_od/2) * (z / cone_h);

// Inner radius of the cone at height z
function cone_ir(z) = cone_or(z) - wall;

// 2D five-pointed star centered at origin
module star_2d(outer_r, inner_r, points=5) {
    angles = [for (i = [0:2*points-1])
        i * 180 / points];
    radii = [for (i = [0:2*points-1])
        (i % 2 == 0) ? outer_r : inner_r];
    polygon([for (i = [0:2*points-1])
        [radii[i] * cos(angles[i] - 90),
         radii[i] * sin(angles[i] - 90)]]);
}

// 2D crescent moon centered at origin
module crescent_2d(h, w) {
    r_outer = h / 2;
    r_inner = r_outer * 0.75;
    offset_x = w * 0.35;
    difference() {
        circle(r=r_outer);
        translate([offset_x, 0, 0])
            circle(r=r_inner);
    }
}

// Place a cutout shape on the cone surface at a given height and angle.
// Extrudes the 2D shape radially through the cone wall.
module cone_cutout(z_pos, angle, shape="star") {
    r = cone_or(z_pos);

    // Transform sequence (read innermost-out):
    // 1. 2D shape in XY, rotated -90 so "up" maps to +Z on cone
    // 2. Extrude along Z
    // 3. Rotate 90° around Y → extrusion now along X (radial)
    // 4. Translate to cone surface
    // 5. Move to correct Z height
    // 6. Rotate to angular position
    rotate([0, 0, angle])
    translate([0, 0, z_pos])
    translate([r, 0, 0])
    rotate([0, 90, 0])
    linear_extrude(height=wall * 4, center=true) {
        if (shape == "star") {
            rotate(-90)
                star_2d(star_d/2, star_d/2 * star_inner, star_pts);
        } else if (shape == "circle") {
            circle(d=circle_d);
        } else if (shape == "crescent") {
            rotate(-90)
                crescent_2d(crescent_h, crescent_w);
        }
    }
}

/* ── Main body ─────────────────────────────────────────────── */

module cone_body() {
    // Outer cone (solid)
    cylinder(d1=base_od, d2=tip_od, h=cone_h);
    // Hemisphere tip
    translate([0, 0, cone_h])
        sphere(r=tip_od/2);
}

module cone_bore() {
    bore_tip_od = tip_od - 2*wall;
    // Inner cone (hollow)
    translate([0, 0, -0.1])
        cylinder(d1=base_id, d2=bore_tip_od, h=cone_h + 0.1);
    // Sphere bore for the tip
    translate([0, 0, cone_h])
        sphere(r=bore_tip_od/2);
}

module retention_lip() {
    // Inward step at the base interior to grip the bottle neck
    lip_id = base_id - 2 * lip_depth;
    difference() {
        cylinder(d=base_id + 0.1, h=lip_height);
        translate([0, 0, -0.1])
            cylinder(d=lip_id, h=lip_height + 0.2);
    }
}

/* ── Cutout pattern layout ─────────────────────────────────── */

module all_cutouts() {
    // Distribute cutouts across 4 rows, heights proportional to cone
    // Row positions as fraction of cone height (from base)
    row_fracs = [0.15, 0.35, 0.55, 0.75];

    for (row = [0:n_rows-1]) {
        z = row_fracs[row] * cone_h;
        r_at_z = cone_or(z);
        circumference = 2 * PI * r_at_z;

        // Number of items scales with circumference
        // At least 6, at most 14
        n_items = max(6, min(14, floor(circumference / 8)));

        // Angular spacing
        angle_step = 360 / n_items;

        // Stagger odd rows by half a step
        stagger = (row % 2 == 1) ? angle_step / 2 : 0;

        for (i = [0:n_items-1]) {
            a = i * angle_step + stagger;

            // Pattern: star, circle, circle, crescent, star, circle, circle, ...
            // Repeat pattern index
            pattern_idx = i % 7;
            shape = (pattern_idx == 0 || pattern_idx == 4) ? "star" :
                    (pattern_idx == 3) ? "crescent" : "circle";

            cone_cutout(z, a, shape);
        }
    }
}

/* ── Assembly ──────────────────────────────────────────────── */

module glitter_wizard_hat() {
    difference() {
        // Outer shell
        cone_body();

        // Hollow interior
        cone_bore();

        // Cutout decorations
        all_cutouts();
    }

    // Add retention lip at the base
    retention_lip();
}

/* ── Render ─────────────────────────────────────────────────── */
glitter_wizard_hat();

// Report dimensions
report_dimensions(base_od, base_od, height, "glitterWizardHat");
