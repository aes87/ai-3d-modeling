// Vent Adapter — parametric cone adapter between two duct diameters
// Uses scad-lib for FDM tolerances and build volume checks.

include <fdm-pla.scad>
include <bambu-x1c.scad>

// Parameters (overridable via -D flags)
bottom_diameter = 100;  // mm — larger duct opening
top_diameter    = 75;   // mm — smaller duct opening
height          = 80;   // mm — adapter height
wall_thickness  = 2.0;  // mm — wall thickness (>= MIN_WALL)

// Derived values
bottom_r = bottom_diameter / 2;
top_r    = top_diameter / 2;
inner_bottom_r = bottom_r - wall_thickness;
inner_top_r    = top_r - wall_thickness;

$fn = 120;

// Validate wall thickness
assert(wall_thickness >= MIN_WALL,
  str("Wall thickness ", wall_thickness, "mm is below minimum ", MIN_WALL, "mm"));

// Report dimensions for pipeline validation
report_dimensions(bottom_diameter, bottom_diameter, height, "adapter");

// Main geometry
difference() {
  // Outer cone
  cylinder(h=height, r1=bottom_r, r2=top_r);

  // Inner cone (hollow)
  translate([0, 0, -0.1])
    cylinder(h=height + 0.2, r1=inner_bottom_r, r2=inner_top_r);
}
