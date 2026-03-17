// =============================================================================
// Gridfinity Modules — Reusable geometry for Gridfinity-compatible parts
// =============================================================================
//
// Include this file to generate Gridfinity-compatible bins, bases, and lips.
// Constants are in gridfinity-spec.scad (included automatically).
//
// Usage pattern for a custom bin:
//   include <gridfinity.scad>
//   gf_bin(grid_x=2, grid_y=1, height_units=3, lip=true);
//
// Usage pattern for a custom object that mates with Gridfinity:
//   include <gridfinity.scad>
//   gf_base_unit();          // single 42mm base pad
//   gf_stacking_lip_ring();  // ring that receives a base from above
//
// Based on kennetek/gridfinity-rebuilt-openscad and
// vector76/gridfinity_openscad implementations.
// =============================================================================

include <gridfinity-spec.scad>

$fn = $fn > 0 ? $fn : 40;

// =============================================================================
// BASE PROFILE — the bottom of each grid unit that mates with baseplates
// =============================================================================

// 2D cross-section of the base profile (one side).
// Origin at innermost-bottom point. Extends right (+X) and up (+Y).
// Revolve or sweep this around the rounded-rectangle path to create a base pad.
module gf_base_profile_2d() {
    polygon(points=[
        [0, 0],
        [GF_BASE_PROFILE[1][0], GF_BASE_PROFILE[1][1]],  // 0.8, 0.8
        [GF_BASE_PROFILE[2][0], GF_BASE_PROFILE[2][1]],  // 0.8, 2.6
        [GF_BASE_PROFILE[3][0], GF_BASE_PROFILE[3][1]],  // 2.95, 4.75
        [0, GF_BASE_PROFILE_HEIGHT],                       // close top
    ]);
}

// Single base pad for one grid unit.
// Centered at origin in XY. Bottom at Z=0.
// This is the stepped profile that locks into a baseplate pocket.
module gf_base_unit() {
    // Build the base pad as a stack of rounded rectangles matching the profile.
    // Each profile segment gets a hull between two rounded-rect slabs.

    _gf_profile_sweep(
        profile = GF_BASE_PROFILE,
        top_size = GF_BIN_BASE_TOP,
        top_radius = GF_BASE_TOP_RADIUS
    );
}

// Full base grid: array of base pads connected by a bridge plate.
// grid_x, grid_y = number of grid units.
// Centered at origin. Bottom at Z=0, top at Z=GF_BASE_HEIGHT.
module gf_base_grid(grid_x=1, grid_y=1) {
    // Individual base pads
    for (ix = [0 : grid_x - 1])
        for (iy = [0 : grid_y - 1])
            translate([
                (ix - (grid_x - 1) / 2) * GF_GRID_PITCH,
                (iy - (grid_y - 1) / 2) * GF_GRID_PITCH,
                0
            ])
            gf_base_unit();

    // Bridge plate connecting the pads
    // Sits at the top of the profile, extending up to GF_BASE_HEIGHT
    outer_x = grid_x * GF_GRID_PITCH - GF_BIN_GAP_TOTAL;
    outer_y = grid_y * GF_GRID_PITCH - GF_BIN_GAP_TOTAL;

    translate([0, 0, GF_BASE_PROFILE_HEIGHT])
        _gf_rounded_rect(
            outer_x, outer_y,
            GF_BASE_HEIGHT - GF_BASE_PROFILE_HEIGHT,
            GF_BASE_TOP_RADIUS
        );
}


// =============================================================================
// STACKING LIP — top edge profile that allows bins to stack
// =============================================================================

// 2D cross-section of the stacking lip (one side).
// Origin at inner tip. Extends right (+X) and up (+Y).
module gf_stacking_lip_2d() {
    polygon(points=[
        [0, 0],
        [GF_STACKING_LIP[1][0], GF_STACKING_LIP[1][1]],  // 0.7, 0.7
        [GF_STACKING_LIP[2][0], GF_STACKING_LIP[2][1]],  // 0.7, 2.5
        [GF_STACKING_LIP[3][0], GF_STACKING_LIP[3][1]],  // 2.6, 4.4
        [0, GF_STACKING_LIP_HEIGHT],                       // close top
    ]);
}

// Stacking lip ring for a bin of given outer dimensions.
// Sits at Z=0 (translate up to bin top minus lip height).
// outer_x, outer_y = bin outer dimensions.
module gf_stacking_lip_ring(outer_x, outer_y) {
    // The lip is a swept profile around the bin perimeter.
    // It extends outward from the inner wall surface.
    // Inner wall position: outer - 2 * wall_thickness
    wall = GF_WALL_THICKNESS;
    lip_outer_x = outer_x;
    lip_outer_y = outer_y;
    lip_inner_x = outer_x - 2 * GF_STACKING_LIP_DEPTH;
    lip_inner_y = outer_y - 2 * GF_STACKING_LIP_DEPTH;
    r_outer = GF_BASE_TOP_RADIUS;
    r_inner = max(0.1, r_outer - GF_STACKING_LIP_DEPTH);

    // Outer solid
    difference() {
        _gf_profile_sweep(
            profile = GF_STACKING_LIP,
            top_size_x = lip_outer_x,
            top_size_y = lip_outer_y,
            top_radius = r_outer
        );
        // Hollow interior
        translate([0, 0, -0.01])
            _gf_rounded_rect(
                lip_inner_x, lip_inner_y,
                GF_STACKING_LIP_HEIGHT + 0.02,
                r_inner
            );
    }
}


// =============================================================================
// BIN SHELL — complete bin outer shell
// =============================================================================

// Complete bin shell (walls, base, optional stacking lip).
// Centered at origin in XY. Bottom at Z=0.
// grid_x, grid_y = grid units. height_units = 7mm units.
// lip = true to add stacking lip at top.
// wall = wall thickness override.
module gf_bin(grid_x=1, grid_y=1, height_units=3, lip=true,
              wall=GF_WALL_THICKNESS) {

    outer_x = gf_bin_width(grid_x);
    outer_y = gf_bin_width(grid_y);
    body_height = height_units * GF_HEIGHT_UNIT;
    total_height = lip ? body_height + GF_STACKING_LIP_HEIGHT : body_height;
    inner_x = outer_x - 2 * wall;
    inner_y = outer_y - 2 * wall;
    r = GF_BASE_TOP_RADIUS;
    r_inner = max(0.1, r - wall);
    r_internal = GF_INTERNAL_FILLET;

    union() {
        // Base grid
        gf_base_grid(grid_x, grid_y);

        // Walls from base height to body top
        difference() {
            _gf_rounded_rect(outer_x, outer_y, body_height, r);
            translate([0, 0, GF_BASE_HEIGHT])
                _gf_rounded_rect_filleted(
                    inner_x, inner_y,
                    body_height - GF_BASE_HEIGHT + 0.01,
                    r_inner,
                    r_internal
                );
        }

        // Stacking lip
        if (lip) {
            translate([0, 0, body_height])
                gf_stacking_lip_ring(outer_x, outer_y);
        }
    }
}


// =============================================================================
// INTERNAL HELPERS
// =============================================================================

// Rounded rectangle centered at origin, bottom at Z=0.
module _gf_rounded_rect(size_x, size_y, height, radius) {
    r = min(radius, min(size_x, size_y) / 2);
    hull() {
        for (sx = [-1, 1])
            for (sy = [-1, 1])
                translate([
                    sx * (size_x / 2 - r),
                    sy * (size_y / 2 - r),
                    0
                ])
                cylinder(r=r, h=height);
    }
}

// Rounded rectangle with internal bottom fillet (for bin cavities).
module _gf_rounded_rect_filleted(size_x, size_y, height, radius, fillet) {
    r = min(radius, min(size_x, size_y) / 2);
    f = min(fillet, min(size_x, size_y) / 4);

    if (f < 0.1) {
        _gf_rounded_rect(size_x, size_y, height, r);
    } else {
        union() {
            // Main body above fillet
            translate([0, 0, f])
                _gf_rounded_rect(size_x, size_y, height - f, r);
            // Fillet transition
            hull() {
                translate([0, 0, f])
                    _gf_rounded_rect(size_x, size_y, 0.01, r);
                _gf_rounded_rect(size_x - 2*f, size_y - 2*f, 0.01, max(0.1, r - f));
            }
        }
    }
}

// Sweep a Gridfinity-style profile around a rounded rectangle.
// Profile is an array of [horizontal_offset, z_height] points.
// The shape at each profile point is a rounded rect whose size is
// (top_size - 2*(profile_width - point_x)) with appropriate corner radius.
module _gf_profile_sweep(profile, top_size=0, top_size_x=0, top_size_y=0,
                          top_radius=GF_BASE_TOP_RADIUS) {
    sx = top_size_x > 0 ? top_size_x : top_size;
    sy = top_size_y > 0 ? top_size_y : top_size;
    pw = profile[len(profile)-1][0];  // total profile width

    for (i = [0 : len(profile) - 2]) {
        p0 = profile[i];
        p1 = profile[i + 1];

        // Size at each profile point: top_size - 2*(pw - px)
        size0_x = sx - 2 * (pw - p0[0]);
        size0_y = sy - 2 * (pw - p0[1] * 0 - p0[0]);  // use x offset only
        size1_x = sx - 2 * (pw - p1[0]);
        size1_y = sy - 2 * (pw - p1[0]);

        // Radius at each point: top_radius - (pw - px)
        r0 = max(0.1, top_radius - (pw - p0[0]));
        r1 = max(0.1, top_radius - (pw - p1[0]));

        hull() {
            translate([0, 0, p0[1]])
                _gf_rounded_rect(size0_x, size0_y, 0.01, r0);
            translate([0, 0, p1[1]])
                _gf_rounded_rect(size1_x, size1_y, 0.01, r1);
        }
    }
}
