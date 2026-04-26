include <fdm-pla.scad>
include <bambu-x1c.scad>
include <common.scad>

$fn = 100;

use <cradle.scad>
use <tray.scad>

show_proxy = true;

cradle();
host_object_proxy(show = show_proxy);

translate([3.4, 160.35, 4])
    tray();
