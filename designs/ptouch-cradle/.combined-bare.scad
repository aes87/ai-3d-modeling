include <fdm-pla.scad>
include <bambu-x1c.scad>
include <common.scad>

$fn = 100;

use <cradle.scad>
use <tray.scad>

cradle();

translate([3.4, 160.35, 4])
    tray();
