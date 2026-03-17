// =============================================================================
// Gridfinity Modular Storage System — Dimensional Specification
// =============================================================================
//
// Reference implementation for designing Gridfinity-compatible parts.
// Created by Zack Freedman (2022). Dimensions reverse-engineered from original
// models and cross-referenced against multiple community sources.
//
// Sources (in order of authority):
//   1. Zack Freedman's original STLs (Thangs)
//   2. kennetek/gridfinity-rebuilt-openscad (ground-truth OpenSCAD port)
//   3. gridfinity.xyz/specification/ (community spec, work in progress)
//   4. Stu142/Gridfinity-Documentation (technical drawings)
//   5. michaelgale/cq-gridfinity (CadQuery implementation)
//   6. grizzie17 "Gridfinity Specification" (Printables #417152)
//   7. Onshape forum discussion (cross-checks and noted discrepancies)
//
// Where sources disagree, discrepancies are noted in comments.
//
// =============================================================================


// =============================================================================
// 1. GRID SYSTEM FUNDAMENTALS
// =============================================================================

// The Gridfinity system is built on a 42mm square grid with 7mm height units.
// Both 42 and 7 are multiples of 7 — the system's fundamental quantum.

GF_GRID_PITCH        = 42;     // mm — center-to-center distance between grid cells
GF_GRID_PITCH_HALF   = 21;     // mm — half-grid for smaller items
GF_HEIGHT_UNIT       = 7;      // mm — one vertical unit ("1u")

// Bins are undersized relative to the grid pitch to provide clearance.
// The gap is split equally on all sides.
GF_BIN_BASE_TOP      = 41.5;   // mm — top of bin base (per grid unit)
GF_BIN_GAP_TOTAL     = 0.5;    // mm — total gap per grid cell (42 - 41.5)
GF_BIN_GAP_PER_SIDE  = 0.25;   // mm — clearance on each side


// =============================================================================
// 2. BASE PROFILE (bottom of bins — mates with baseplate)
// =============================================================================
//
// The base profile is a stepped/chamfered cross-section at the bottom of each
// bin unit. It creates the mechanical interlock with the baseplate receptacle.
//
// Profile cross-section (looking at one edge, from inside bottom to outside top):
//
//     ┌─────────────────── 41.5mm (BASE_TOP) ──────────────────┐
//     │                                                         │
//     │  ╱  2.15mm @ 45°                                        │
//     │ ╱                                                       │
//     │ │  1.8mm vertical                                       │
//     │ ╱  0.8mm @ 45°                                          │
//     └─────────────────── (bottom) ────────────────────────────┘
//
// Defined as a polyline from innermost-bottom to outermost-top:
//   Point 0: [0,    0   ]  — innermost bottom point
//   Point 1: [0.8,  0.8 ]  — 45° chamfer outward
//   Point 2: [0.8,  2.6 ]  — vertical wall (1.8mm tall)
//   Point 3: [2.95, 4.75]  — 45° chamfer outward (2.15mm run)
//
// Total horizontal extent: 2.95mm (0.8 + 0 + 2.15)
// Total vertical extent:   4.75mm (0.8 + 1.8 + 2.15)

GF_BASE_PROFILE = [
    [0,    0   ],   // innermost bottom point
    [0.8,  0.8 ],   // up and out at 45°
    [0.8,  2.6 ],   // straight up (vertical wall segment)
    [2.95, 4.75],   // up and out at 45°
];

GF_BASE_PROFILE_HEIGHT  = 4.75;  // mm — total height of stepped profile
GF_BASE_PROFILE_WIDTH   = 2.95;  // mm — total horizontal extent of profile

// The flat bridge section above the profile connects adjacent base units.
GF_BASE_HEIGHT          = 7;     // mm — total base height including bridge
GF_BASE_BRIDGE_HEIGHT   = 2.25;  // mm — flat section above profile (7 - 4.75)

// Corner radii
GF_BASE_TOP_RADIUS      = 3.75;  // mm — corner radius at top of base (7.5mm dia / 2)
GF_BASE_BOTTOM_RADIUS   = 0.8;   // mm — corner radius at bottom (top_radius - profile_width)
                                  //       3.75 - 2.95 = 0.80

// NOTE: The cq-gridfinity library uses GR_BASE_HEIGHT = 4.75mm for just the
// profile portion, with GR_BASE_CLR = 0.25mm clearance above. The kennetek
// implementation uses BASE_HEIGHT = 7mm for the full base including bridge.

// Bottom dimensions of a single base unit
// base_bottom = BASE_TOP - 2 * profile_width
//             = 41.5 - 2 * 2.95 = 35.6mm
GF_BASE_BOTTOM_DIM      = 35.6;  // mm — bottom footprint per grid unit


// =============================================================================
// 3. BASEPLATE RECEPTACLE (pocket that receives bins)
// =============================================================================
//
// The baseplate has a pocket/socket for each grid cell. The pocket profile is
// a mirror of the base profile but sized to receive it.
//
// Pocket profile (from innermost-bottom to outermost-top):
//   Point 0: [0,    0   ]  — innermost bottom point
//   Point 1: [0.7,  0.7 ]  — 45° chamfer outward
//   Point 2: [0.7,  2.5 ]  — vertical wall (1.8mm tall)
//   Point 3: [2.85, 4.65]  — 45° chamfer outward (2.15mm run)

GF_BASEPLATE_PROFILE = [
    [0,    0   ],   // innermost bottom point
    [0.7,  0.7 ],   // up and out at 45°
    [0.7,  2.5 ],   // straight up (vertical wall)
    [2.85, 4.65],   // up and out at 45°
];

GF_BASEPLATE_PROFILE_HEIGHT = 4.65;  // mm
GF_BASEPLATE_PROFILE_WIDTH  = 2.85;  // mm

GF_BASEPLATE_DIMENSIONS     = [42, 42];  // mm — one baseplate cell
GF_BASEPLATE_HEIGHT         = 5;         // mm — minimum baseplate height
GF_BASEPLATE_OUTER_RADIUS   = 4;         // mm — corner radius (8mm dia / 2)
GF_BASEPLATE_INNER_RADIUS   = 1.15;      // mm — inner corner (outer - profile_width)
                                          //       4.0 - 2.85 = 1.15

// IMPORTANT: The base profile and baseplate profile differ slightly.
// The base uses [0.8, 0.8+1.8, 0.8+1.8+2.15] = [0.8, 2.6, 4.75]
// The baseplate uses [0.7, 0.7+1.8, 0.7+1.8+2.15] = [0.7, 2.5, 4.65]
// This 0.1mm difference on the first step creates the mating clearance.
// The vertical wall segments are the same 1.8mm on both profiles.
// The upper 45° chamfer is the same 2.15mm on both profiles.


// =============================================================================
// 4. STACKING LIP PROFILE (top of bins — allows stacking)
// =============================================================================
//
// The stacking lip is the most critical interface. It sits at the top of bin
// walls and allows bins to stack on each other or receive lids.
//
// Cross-section (looking at one edge, from inner tip outward):
//
//   Inner wall
//       │
//       │     ╲  1.9mm @ 45° (outward slope)
//       │      ╲
//       │      │  1.8mm vertical
//       │      ╱  0.7mm @ 45° (inward slope — the catch)
//       │     ╱
//       └─── inner tip
//
// Defined as a polyline from inner tip upward:
//   Point 0: [0,    0   ]  — inner tip (bottom of lip)
//   Point 1: [0.7,  0.7 ]  — outward at 45° (the catch/hook)
//   Point 2: [0.7,  2.5 ]  — vertical rise (1.8mm)
//   Point 3: [2.6,  4.4 ]  — outward at 45° (1.9mm, upper chamfer)
//
// The lip adds 4.4mm to overall bin height.
// Horizontal depth: 2.6mm (0.7 + 0 + 1.9)

GF_STACKING_LIP = [
    [0,    0   ],   // inner tip
    [0.7,  0.7 ],   // out 45° — the catch that locks stacking
    [0.7,  2.5 ],   // vertical (1.8mm wall)
    [2.6,  4.4 ],   // out 45° — upper chamfer (1.9mm)
];

GF_STACKING_LIP_HEIGHT   = 4.4;   // mm — total height added by stacking lip
GF_STACKING_LIP_DEPTH    = 2.6;   // mm — total horizontal extent

// The stacking lip fillet prevents a sharp point at the outer top edge.
GF_STACKING_LIP_FILLET   = 0.6;   // mm — fillet radius at top of lip

// Support structure below the lip (prevents floating geometry when
// wall thickness is less than lip depth).
GF_STACKING_LIP_SUPPORT_HEIGHT = 1.2;  // mm

// NOTE: The stacking lip profile intentionally matches the baseplate
// receptacle profile. When bins stack, the lower bin's stacking lip
// acts as the "baseplate" for the upper bin's base profile.
// The 0.7mm catch step on the lip matches the 0.7mm first step
// of the baseplate profile.


// =============================================================================
// 5. BIN OUTER DIMENSIONS
// =============================================================================
//
// Bin XY dimensions follow: units * 42mm - 0.5mm
// The 0.5mm is the total clearance gap (0.25mm per side).
//
// Bin height follows: units * 7mm (base body, no lip)
//   With stacking lip: units * 7mm + 4.4mm (lip) - 7mm (base sits in lip below)
//   Total stackable: units * 7mm
//   The lip and base interlock, so stacked height = units * 7mm per bin.

// Width/Depth formulas:
//   outer_width  = grid_units_x * 42 - 0.5
//   outer_depth  = grid_units_y * 42 - 0.5

// Common bin footprints (outer XY):
//   1x1: 41.5  x 41.5  mm
//   2x1: 83.5  x 41.5  mm
//   3x1: 125.5 x 41.5  mm
//   2x2: 83.5  x 83.5  mm
//   3x2: 125.5 x 83.5  mm
//   4x1: 167.5 x 41.5  mm

// Height formulas:
//   Total height (no lip)   = height_units * 7
//   Total height (with lip) = height_units * 7 + 4.4
//   Internal usable height  = total_height - base_height - floor_thickness
//
// Example 1x1x3 bin (3 height units):
//   Without lip: 41.5 x 41.5 x 21.0 mm
//   With lip:    41.5 x 41.5 x 25.4 mm

// Height examples (with stacking lip):
//   1u:  7.0 + 4.4 = 11.4 mm (rarely useful — very shallow)
//   2u: 14.0 + 4.4 = 18.4 mm
//   3u: 21.0 + 4.4 = 25.4 mm
//   4u: 28.0 + 4.4 = 32.4 mm
//   5u: 35.0 + 4.4 = 39.4 mm
//   6u: 42.0 + 4.4 = 46.4 mm (standard "full height")


// =============================================================================
// 6. WALL AND FLOOR SPECIFICATIONS
// =============================================================================

GF_WALL_THICKNESS       = 0.95;  // mm — minimum exterior wall thickness
                                  //       (kennetek default; 3 perimeters at 0.4mm nozzle
                                  //        would be 1.2mm — some implementations use that)
GF_WALL_THICKNESS_THICK = 1.2;   // mm — common thicker wall option
GF_DIVIDER_THICKNESS    = 1.2;   // mm — internal divider wall thickness

GF_INTERNAL_FILLET      = 2.8;   // mm — internal corner fillet radius (r_f2)

// Floor thickness above the base:
// The base profile is 4.75mm tall, leaving 2.25mm of the first 7mm unit
// as bridge/floor. Typical usable floor: 0.7mm minimum above cutouts.
GF_FLOOR_THICKNESS_MIN  = 0.7;   // mm — minimum floor above base cutouts

// Internal floor elevation (from bottom of bin):
// base_height (7mm) + floor = 7.0mm + varies
// The cq-gridfinity library uses 7.2mm as internal floor elevation.
GF_INTERNAL_FLOOR_ELEV  = 7.2;   // mm — floor surface height from bin bottom
                                  //       (per cq-gridfinity; some implementations
                                  //        compute this dynamically)


// =============================================================================
// 7. CORNER RADII
// =============================================================================

// External corner radius at the top of the bin (where stacking lip sits):
GF_OUTER_RADIUS         = 4.0;   // mm — exterior corner fillet radius
                                  //       (8mm diameter; sources agree on this)

// NOTE: The Onshape forum (wai_tsang926) reports Zack's original models
// may use 8mm diameter (4.0mm radius) corners, while the gridfinity.xyz
// spec lists 7.5mm diameter (3.75mm radius). The kennetek implementation
// uses BASE_TOP_RADIUS = 3.75mm for the base and references outer_radius
// as the baseplate outer = 4.0mm. These are different features:
//   - Base top corners: 3.75mm radius (7.5mm dia)
//   - Baseplate outer corners: 4.0mm radius (8.0mm dia)
//   - Bin outer corners (at wall top): typically matches base top = 3.75mm


// =============================================================================
// 8. MAGNET AND SCREW HOLES
// =============================================================================

// Standard magnets: 6mm diameter x 2mm tall (neodymium disc magnets)
GF_MAGNET_DIA           = 6.0;   // mm
GF_MAGNET_HEIGHT        = 2.0;   // mm
GF_MAGNET_HOLE_DIA      = 6.5;   // mm — hole oversized for fit (6.5mm per kennetek)
GF_MAGNET_HOLE_DEPTH    = 2.4;   // mm — magnet height + 2 layer heights (0.2mm each)

// Crush ribs for press-fit magnet retention:
GF_MAGNET_CRUSH_RIB_ID  = 5.9;   // mm — inner diameter of crush ribs
GF_MAGNET_CRUSH_RIB_N   = 8;     // number of crush ribs

// Chamfer at top of magnet/screw holes:
GF_HOLE_CHAMFER_EXTRA_R = 0.8;   // mm — additional radius for chamfer
GF_HOLE_CHAMFER_ANGLE   = 45;    // degrees

// Standard screws: M3
GF_SCREW_DIA            = 3.0;   // mm
GF_SCREW_HOLE_DIA       = 3.0;   // mm — (some implementations add clearance)

// Hole positioning:
// Holes are in all four corners of each grid unit.
// Distance from the bottom edge of the base profile to hole center:
GF_HOLE_FROM_BOTTOM_EDGE = 4.8;  // mm — per gridfinity.xyz spec
GF_HOLE_FROM_SIDE        = 8.0;  // mm — from side of bin (d_hole_from_side)

// Heat-set insert option:
GF_HEAT_INSERT_HOLE_DIA  = 4.2;  // mm — widened hole for M3 heat-set inserts

// Baseplate screw countersink:
GF_BP_COUNTERSINK_DIA    = 10.0; // mm — countersink diameter
GF_BP_COUNTERBORE_DIA    = 5.5;  // mm — counterbore radius * 2
GF_BP_COUNTERBORE_DEPTH  = 3.0;  // mm

// Gridfinity Refined thumbscrew (optional):
GF_THUMBSCREW_OD         = 15.0; // mm — ISO metric M15x1.5
GF_THUMBSCREW_PITCH      = 1.5;  // mm


// =============================================================================
// 9. WEIGHTED BASEPLATE (bottom cutouts for weight/cost reduction)
// =============================================================================

GF_BP_BOTTOM_HEIGHT      = 6.4;  // mm — height of bottom section
GF_BP_CUT_SIZE           = 21.4; // mm — cutout rectangle size
GF_BP_CUT_DEPTH          = 4.0;  // mm — cutout rectangle depth
GF_BP_RCUT_WIDTH         = 8.5;  // mm — rounded cutout width
GF_BP_RCUT_LENGTH        = 4.25; // mm — rounded cutout length
GF_BP_RCUT_DEPTH         = 2.0;  // mm — rounded cutout depth

// Skeletonized baseplate:
GF_SKEL_RADIUS           = 2.0;  // mm — skeleton cutout corner radius
GF_SKEL_MIN_THICKNESS    = 1.0;  // mm — minimum remaining material


// =============================================================================
// 10. TOLERANCES AND CLEARANCES
// =============================================================================

// Bin-to-baseplate clearance (XY plane):
//   Total gap = 0.5mm per grid cell, split as 0.25mm per side.
//   This is built into the 41.5mm base top dimension (42 - 0.5).

// Bin-to-baseplate clearance (Z / mating profile):
//   The base profile first step is 0.8mm vs baseplate's 0.7mm.
//   This 0.1mm difference creates vertical mating clearance on the lower chamfer.
//   The vertical walls and upper chamfer use identical dimensions (1.8mm and 2.15mm),
//   so clearance is primarily from the first step difference.
//   NOTE: The Onshape forum reports measured clearance of ~0.427mm in some
//   implementations, vs the 0.25mm the spec implies. The extra clearance
//   may be intentional to accommodate FDM tolerances.

// Bin-to-bin clearance when adjacent on a baseplate:
//   Each bin is 0.25mm smaller than the grid cell on each side.
//   Two adjacent bins have 0.5mm total gap between them (0.25 + 0.25).

// Stacking clearance (bin-on-bin):
//   The stacking lip of the lower bin acts as a baseplate for the upper bin's
//   base. The lip profile matches the baseplate profile (both use 0.7mm first
//   step), while the bin base uses 0.8mm first step. Same clearance geometry.

// FDM printing tolerance:
//   The 0.25mm per side clearance is designed for typical FDM printers.
//   Well-calibrated printers may produce slightly loose fits.
//   Poorly calibrated printers may produce tight fits.
//   ABS/ASA may need ~1% scale compensation for shrinkage.

GF_TOLERANCE             = 0.02;  // mm — modeling epsilon (not physical tolerance)


// =============================================================================
// 11. DERIVED DIMENSION HELPER FUNCTIONS
// =============================================================================

// Bin outer width for a given number of grid units
function gf_bin_width(units) = units * GF_GRID_PITCH - GF_BIN_GAP_TOTAL;

// Bin total height (without stacking lip)
function gf_bin_height_no_lip(height_units) = height_units * GF_HEIGHT_UNIT;

// Bin total height (with stacking lip)
function gf_bin_height_with_lip(height_units) =
    height_units * GF_HEIGHT_UNIT + GF_STACKING_LIP_HEIGHT;

// Internal usable depth (approximate — depends on floor implementation)
function gf_bin_internal_depth(height_units) =
    height_units * GF_HEIGHT_UNIT - GF_INTERNAL_FLOOR_ELEV;

// Snap height to nearest multiple of 7mm
function gf_snap_height(h) = h % 7 == 0 ? h : h + 7 - h % 7;


// =============================================================================
// 12. KNOWN DISCREPANCIES BETWEEN SOURCES
// =============================================================================
//
// 1. Corner radii:
//    - gridfinity.xyz spec: 7.5mm diameter (3.75mm radius) for base top corners
//    - Onshape forum report: 8mm diameter (4.0mm radius) measured from originals
//    - Baseplate outer: consistently 8mm diameter (4.0mm radius) across sources
//    - Resolution: Base top = 3.75mm, baseplate outer = 4.0mm (different features)
//
// 2. Base profile first step:
//    - kennetek (bin base): 0.8mm chamfer
//    - kennetek (baseplate pocket): 0.7mm chamfer
//    - This 0.1mm difference is intentional mating clearance
//
// 3. Stacking lip angle:
//    - Spec assumes 45° on all angled segments
//    - Onshape forum (wai_tsang926) reports "the slope of the stacking lip
//      isn't 45 degrees" in original models
//    - Most implementations use 45° and achieve good compatibility
//
// 4. Stacking lip bottom face width:
//    - gridfinity.xyz spec implies 2.1mm
//    - Onshape forum measures 2.4mm from original models
//    - kennetek uses the spec-derived value
//
// 5. Wall thickness:
//    - Zack's originals: varies (not parametric)
//    - kennetek default: 0.95mm
//    - cq-gridfinity default: 1.0mm
//    - Common community choice: 1.2mm (3 perimeters at 0.4mm nozzle)
//    - gridfinity-extended: dynamic (0.95/1.2/1.6 based on height)
//
// 6. Internal floor elevation:
//    - cq-gridfinity: 7.2mm from bin bottom
//    - kennetek: computed from BASE_HEIGHT (7mm) + floor material
//    - Some sources report 4.75mm consumed by base, leaving 2.25mm in first unit
//
// =============================================================================
