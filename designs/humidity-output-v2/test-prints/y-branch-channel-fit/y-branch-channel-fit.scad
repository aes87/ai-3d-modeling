// Y-Branch Channel Fit Test Print
// Minimal-material test piece: single corner Y-branch fork from humidity-output-v2.
// Verifies that 9.0mm arm width fits into 9.4mm waffle grid channels (0.2mm/side clearance).

include <fdm-pla.scad>
include <bambu-x1c.scad>
include <common.scad>
include <humidity-output-v2-params.scad>

$fn = 80;

// === Test piece sizing ===
// We extract corner 0 (+X, +Y) fork from the parent design.
// The root is at (ho2_branch_root, ho2_branch_root) in parent coordinates.
// We clip a section of the outer plate around the root for structural support
// and bed adhesion, then include both arms at full length.

// How far the base plate extends inward from the root center in each axis.
// The outer frame edge is at ho2_frame_outer/2 = 73.1mm from parent origin,
// which coincides with the root center. So the plate extends inward.
base_clip = 33;  // mm of base plate inward from root

// Arm tip position relative to root center (endpoint of hull cylinder center)
arm_tip_offset = ho2_branch_len - ho2_branch_w / 2;  // 20.5mm

// Bounding box calculation:
// X direction: base extends base_clip inward from root, arm extends
//   arm_tip_offset + branch_w/2 outward from root
// Same for Y direction.
test_extent_inward = base_clip;
test_extent_outward = arm_tip_offset + ho2_branch_w / 2;  // 25mm

test_x = test_extent_inward + test_extent_outward;  // 55mm
test_y = test_x;  // symmetric
test_z = ho2_frame_t_outer;  // 4.6mm

// We translate the parent geometry so the root center is at
// (test_extent_inward, test_extent_inward) in the test piece coordinates.
// That way the piece runs from (0,0) to (test_x, test_y).
translate_offset = test_extent_inward - ho2_branch_root;

// Report dimensions -- arms plus base plate clip
// The actual bbox is driven by the arm tips and the plate clip extent
report_x = test_x;
report_y = test_y;
report_z = test_z;

report_dimensions(report_x, report_y, report_z, "yBranchChannelFit");

// === Geometry ===
// Build the fork + plate clip, then intersect with a bounding box to trim
// the plate to only the region we want.

intersection() {
    // Bounding box for the test piece
    translate([translate_offset + ho2_branch_root - test_extent_inward,
               translate_offset + ho2_branch_root - test_extent_inward, 0])
        cube([test_x, test_y, test_z + 1]);

    // Full geometry from parent, translated so root is at the right place
    translate([translate_offset, translate_offset, 0]) {
        union() {
            // Outer plate (clipped by intersection)
            linear_extrude(ho2_frame_t_outer)
                offset(r=ho2_corner_r) offset(r=-ho2_corner_r)
                    square([ho2_frame_outer, ho2_frame_outer], center=true);

            // Y-branch fork for corner 0 (+X, +Y)
            // X-direction arm
            hull() {
                translate([ho2_branch_root, ho2_branch_root, 0])
                    cylinder(d=ho2_branch_w, h=ho2_frame_t_outer, $fn=32);
                translate([ho2_branch_root + arm_tip_offset, ho2_branch_root, 0])
                    cylinder(d=ho2_branch_w, h=ho2_frame_t_outer, $fn=32);
            }
            // Y-direction arm
            hull() {
                translate([ho2_branch_root, ho2_branch_root, 0])
                    cylinder(d=ho2_branch_w, h=ho2_frame_t_outer, $fn=32);
                translate([ho2_branch_root, ho2_branch_root + arm_tip_offset, 0])
                    cylinder(d=ho2_branch_w, h=ho2_frame_t_outer, $fn=32);
            }
            // Root blob
            translate([ho2_branch_root, ho2_branch_root, 0])
                cylinder(d=ho2_branch_w + 2, h=ho2_frame_t_outer, $fn=32);
        }
    }
}
