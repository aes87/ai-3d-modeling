// Common FDM helper modules
// Include fdm-pla.scad before using these.

include <fdm-pla.scad>

// A hole compensated for FDM shrinkage.
// d = nominal diameter, h = depth, center = center vertically
module fdm_hole(d, h, center=false) {
  cylinder(d=d + FDM_HOLE_COMPENSATION, h=h, center=center, $fn=max(32, ceil(d*4)));
}

// A shaft/pin sized for press fit into a compensated hole.
// d = nominal diameter, h = height
module fdm_shaft(d, h, center=false) {
  cylinder(d=d + FDM_PRESS_FIT * 2, h=h, center=center, $fn=max(32, ceil(d*4)));
}

// Bolt pattern — places children at evenly spaced points on a circle.
// n = number of bolts, r = bolt circle radius
module bolt_pattern(n, r) {
  for (i = [0 : n-1]) {
    angle = i * 360 / n;
    translate([r * cos(angle), r * sin(angle), 0])
      children();
  }
}

// Cylinder with a 45° chamfer on the bottom edge.
// d = diameter, h = height, chamfer = chamfer size
module chamfer_cylinder(d, h, chamfer=0.5) {
  union() {
    // Main body above chamfer
    translate([0, 0, chamfer])
      cylinder(d=d, h=h - chamfer, $fn=max(32, ceil(d*4)));
    // Chamfer cone
    cylinder(d1=d - chamfer*2, d2=d, h=chamfer, $fn=max(32, ceil(d*4)));
  }
}
