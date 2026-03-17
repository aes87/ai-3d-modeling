// Waffle Caulk Spudger
// A handheld tool for spreading silicone caulk into waffle-grid channels.
// Convex tip profiles a smooth bead in 9.4mm wide HDPE channels.
//
// Print orientation: flat on bed (bottom face = XY plane).
// Tool extends along X, Y is width, Z is height.

include <fdm-pla.scad>
include <bambu-x1c.scad>
include <common.scad>

$fn = 80;

// === Parameters ===

// Tip
tip_width       = 8.8;
tip_arc_radius  = 4.4;
tip_arc_sag     = 4.2;
tip_base_height = 1.2;
tip_total_height = tip_base_height + tip_arc_sag; // 5.4
tip_length      = 25.0;

// Taper
taper_length = 15.0;

// Handle
handle_length      = 120.0;
handle_width       = 18.0;
handle_height      = 10.0;
handle_fillet      = 3.0;
handle_tail_radius = handle_width / 2; // 9.0

// Overall
overall_x = 145.0;
overall_y = handle_width;
overall_z = handle_height;

// Arc center Z: where the convex arc circle is centered
arc_center_z = tip_base_height + tip_arc_sag - tip_arc_radius; // 1.0

// === Build with hull-based approach ===
// Strategy: build the tool as a union of hull pairs between adjacent
// cross-section slabs. Each slab is a thin 3D shape (linear_extrude
// of a 2D profile) placed at a specific X position.
//
// OpenSCAD linear_extrude creates geometry along +Z from a 2D XY shape.
// To place a cross-section in the YZ plane at position x:
//   1. Create 2D shape where 2D-X = Y-axis, 2D-Y = Z-axis
//   2. linear_extrude a thin slab (along Z, which will become X after rotation)
//   3. rotate so extrude direction (Z) points along X
//   4. translate to position x
//
// Rotation to map (2D-X -> 3D-Y, 2D-Y -> 3D-Z, extrude-Z -> 3D-X):
// rotate([0, 90, 0]) maps Z -> X, X -> -Z. Then we'd need 2D-X to end
// up as Y. So we also rotate around new axis.
//
// Easier: just use rotate([0, 90, 0]) which maps Z->X, X->-Z, Y->Y.
// Then the 2D shape has 2D-X mapping to -3D-Z and 2D-Y mapping to 3D-Y.
// But we want 2D-X -> 3D-Y and 2D-Y -> 3D-Z.
//
// So we first rotate the 2D by 90 degrees: swap 2D axes.
// With rotate([0,90,0]): Z->X, X->-Z, Y->Y
// If our 2D shape has width along Y (2D-X=Y, 2D-Y=height):
//   After linear_extrude along Z then rotate([0,90,0]):
//   2D-X -> -3D-Z (nope)
//
// OK let me just directly construct 3D cross-sections using cubes and
// cylinder intersections, avoiding the 2D rotation mess entirely.

module waffle_caulk_spudger() {
    union() {
        // --- TIP SECTION: X = [0, tip_length] ---
        tip_section();

        // --- TAPER SECTION: X = [tip_length, tip_length + taper_length] ---
        taper_section();

        // --- HANDLE SECTION: X = [tip_length + taper_length, overall_x] ---
        handle_section();
    }
}

// === TIP ===
// Cross-section: 8.8mm wide (Y) x 5.4mm tall (Z)
// Shape: flat bottom (1.2mm), convex arc on top (R=4.4, sag=4.2)
// Leading edge: rounded nose

module tip_section() {
    // Tip body: the tip cross-section is the intersection of
    // a box and a cylinder (for the arc), extruded along X.

    // The convex arc in the YZ plane:
    // A cylinder along X with radius tip_arc_radius, centered at
    // Y=0, Z=arc_center_z (1.0mm).

    nose_r = tip_arc_radius; // 4.4mm nose rounding radius

    difference() {
        union() {
            // Main tip body from X=0 to X=tip_length
            intersection() {
                // Bounding box for the tip
                translate([0, -tip_width/2, 0])
                    cube([tip_length, tip_width, tip_total_height]);

                union() {
                    // Flat base slab
                    translate([0, -tip_width/2, 0])
                        cube([tip_length, tip_width, tip_base_height + 0.001]);

                    // Convex arc: cylinder along X
                    translate([0, 0, arc_center_z])
                        rotate([0, 90, 0])
                            cylinder(r = tip_arc_radius, h = tip_length);
                }
            }
        }

        // Cut the nose rounding: remove material in front of a sphere
        // centered at X = nose_r to create a smooth rounded leading edge.
        // Everything at X < nose_r that is outside the sphere gets removed.
        translate([nose_r, 0, arc_center_z])
            difference() {
                // Block covering the nose region
                translate([-nose_r - 0.01, -tip_width/2 - 0.01, -tip_total_height])
                    cube([nose_r + 0.01, tip_width + 0.02, tip_total_height * 2]);

                // Sphere to keep (nose shape)
                scale([1, (tip_width/2) / nose_r, 1])
                    sphere(r = nose_r);
            }
    }
}

// === TAPER ===
// Linear transition from tip cross-section to handle cross-section
// over taper_length (15mm).
// Width: 8.8 -> 18.0, Height: 5.4 -> 10.0
// Bottom stays at Z=0. Top rises. Sides widen symmetrically about Y=0.

module taper_section() {
    taper_start = tip_length;
    steps = 40;

    for (i = [0 : steps - 1]) {
        t1 = i / steps;
        t2 = (i + 1) / steps;

        w1 = tip_width + t1 * (handle_width - tip_width);
        w2 = tip_width + t2 * (handle_width - tip_width);
        h1 = tip_total_height + t1 * (handle_height - tip_total_height);
        h2 = tip_total_height + t2 * (handle_height - tip_total_height);
        f1 = t1 * handle_fillet;
        f2 = t2 * handle_fillet;
        x1 = taper_start + t1 * taper_length;
        x2 = taper_start + t2 * taper_length;

        hull() {
            // Slab at x1
            translate([x1, 0, 0])
                taper_slab(w1, h1, f1);
            // Slab at x2
            translate([x2, 0, 0])
                taper_slab(w2, h2, f2);
        }
    }
}

// A thin (0.01mm) 3D cross-section slab in the YZ plane.
// Centered on Y, bottom at Z=0. Width w, height h, fillet f.
module taper_slab(w, h, f) {
    slab_t = 0.01;

    if (f < 0.1) {
        // No meaningful fillet: plain rectangle slab
        translate([-slab_t/2, -w/2, 0])
            cube([slab_t, w, h]);
    } else {
        // Rounded rectangle cross-section via minkowski of thin slab
        // with a sphere of radius f... but that changes dimensions.
        // Instead, use intersection of a cube with cylinders at corners.

        // Filleted rectangle: offset approach in 3D
        // Use hull of four cylinders at the filleted corners
        translate([-slab_t/2, 0, 0])
        hull() {
            // Bottom-left corner (no fillet at bottom — flat on bed)
            translate([0, -w/2, 0])
                cube([slab_t, f, 0.01]);
            // Bottom-right corner
            translate([0, w/2 - f, 0])
                cube([slab_t, f, 0.01]);
            // Top-left corner with fillet
            translate([slab_t/2, -w/2 + f, h - f])
                rotate([0, 90, 0])
                    cylinder(r = f, h = slab_t, center = true);
            // Top-right corner with fillet
            translate([slab_t/2, w/2 - f, h - f])
                rotate([0, 90, 0])
                    cylinder(r = f, h = slab_t, center = true);
        }
    }
}

// === HANDLE ===
// Straight extrusion of handle cross-section with rounded tail.

module handle_section() {
    body_start = tip_length + taper_length;
    tail_center = overall_x - handle_tail_radius;
    body_len = tail_center - body_start;

    // Handle body (straight section)
    if (body_len > 0) {
        translate([body_start, 0, 0])
            handle_extrusion(body_len);
    }

    // Handle tail (rounded end)
    handle_tail(tail_center);
}

// Extrude the handle cross-section along X for given length.
// The handle cross-section is a filleted rectangle in YZ, centered Y, Z>=0.
module handle_extrusion(length) {
    // Build the handle cross-section as a hull of corner features
    hull() {
        // Bottom-left edge
        translate([0, -handle_width/2, 0])
            cube([length, handle_fillet, 0.01]);
        // Bottom-right edge
        translate([0, handle_width/2 - handle_fillet, 0])
            cube([length, handle_fillet, 0.01]);
        // Top-left filleted edge
        translate([0, -handle_width/2 + handle_fillet, handle_height - handle_fillet])
            rotate([0, 90, 0])
                cylinder(r = handle_fillet, h = length, $fn = 40);
        // Top-right filleted edge
        translate([0, handle_width/2 - handle_fillet, handle_height - handle_fillet])
            rotate([0, 90, 0])
                cylinder(r = handle_fillet, h = length, $fn = 40);
    }
}

// Rounded tail: intersection of handle extrusion with a cylinder
module handle_tail(center_x) {
    intersection() {
        translate([center_x, 0, 0])
            handle_extrusion(handle_tail_radius + 0.01);

        // Cylinder for XY rounding of the tail
        translate([center_x, 0, -0.01])
            cylinder(r = handle_tail_radius, h = handle_height + 0.02);
    }
}

// === Instantiate ===
waffle_caulk_spudger();

// === Dimension reporting ===
report_dimensions(overall_x, overall_y, overall_z, "overall");

echo(str("DIMENSION:tip:x=", tip_length));
echo(str("DIMENSION:tip:y=", tip_width));
echo(str("DIMENSION:tip:z=", tip_total_height));
echo(str("DIMENSION:handle:x=", handle_length));
echo(str("DIMENSION:handle:y=", handle_width));
echo(str("DIMENSION:handle:z=", handle_height));
