// Reference Part: 119mm Fan Frame
// Models the external fan frame for assembly fit verification.
// NOT a printed part — this represents the physical fan.

include <fdm-pla.scad>
include <bambu-x1c.scad>
include <fan-tub-adapter-params.scad>

$fn = 80;

// Fan frame: 119x119x24.7mm hollow square with rounded corners
// Center opening: 105mm diameter (airflow)

module fan_frame_119() {
    difference() {
        // Outer shell: rounded square
        linear_extrude(fan_frame_t)
            offset(r=fan_corner_r) offset(r=-fan_corner_r)
                square(fan_frame, center=true);

        // Center airflow opening
        translate([0, 0, -0.1])
            cylinder(d=fan_opening, h=fan_frame_t + 0.2);
    }
}

fan_frame_119();

report_dimensions(fan_frame, fan_frame, fan_frame_t, "fan");
