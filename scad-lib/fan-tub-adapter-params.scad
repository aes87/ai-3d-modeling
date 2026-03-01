// Fan-Tub Adapter v2.0 — Shared Parameters
// Used by both base plate and retention clip designs.

// === Waffle Grid Measurements ===
square_size   = 63.7;    // mm — waffle square (channel edge to channel edge)
channel_w     = 9.4;     // mm — channel width between adjacent squares
waffle_h      = 4.6;     // mm — waffle square height above channel surface

// === Cutout ===
cutout        = 2 * square_size + channel_w;  // 136.8mm

// === Frame Plate ===
frame_t_inner = 5.0;     // mm — inner zone thickness (fan mount)
frame_t_outer = waffle_h; // mm — outer zone (flange + branches, flush with waffle tops)
corner_r      = 4;       // mm — waffle square corner radius

// === Flange ===
flange_w      = channel_w / 2;  // 4.7mm

// === Fan Geometry ===
fan_frame     = 119;     // mm — fan outer dimension (square)
fan_frame_t   = 24.7;    // mm — fan frame thickness (measured)
fan_opening   = 105;     // mm — center airflow diameter
fan_corner_r  = 5;       // mm — fan frame corner radius

// === Locating Rim ===
loc_rim_h     = 4.0;     // mm — height of rim above inner plate (was 1.5 in v1)
loc_rim_wall  = 2;       // mm — rim wall thickness
loc_clearance = 0.5;     // mm — clearance around fan frame (per side)

// === Y-Branch Geometry ===
branch_w      = 9.0;     // mm — branch width (9.4 channel - 0.4 clearance)
branch_len    = 25;      // mm — engagement length into channel from root

// === Clip Mechanism ===
clip_ledge_depth   = 1.0;  // mm — outward protrusion on rim exterior
clip_ledge_h       = 1.5;  // mm — ledge height
clip_arm_w         = 8.0;  // mm — arm width
clip_arm_t         = 1.5;  // mm — arm thickness
clip_arm_len       = 22.05; // mm — arm length (preload-adjusted)
clip_hook_overhang = 0.8;  // mm — hook inward protrusion
clip_hook_h        = 1.5;  // mm — hook height
clip_frame_t       = 2.0;  // mm — clip frame thickness
clip_tab_w         = 3.5;  // mm — outward bridge from frame edge to arm

// === Derived Values ===
frame_outer   = cutout + 2 * flange_w;        // 146.2mm
branch_root   = cutout / 2 + channel_w / 2;   // 73.1mm

loc_inner     = fan_frame + 2 * loc_clearance; // 120mm
loc_outer     = loc_inner + 2 * loc_rim_wall;  // 124mm

// Vertical stackup (Z from base plate bottom)
z_inner_top   = frame_t_inner;                 // 5.0
z_rim_top     = frame_t_inner + loc_rim_h;     // 9.0
z_ledge_bot   = z_rim_top - clip_ledge_h;      // 7.5 (ledge bottom, 1.5mm from rim top)
z_fan_top     = frame_t_inner + fan_frame_t;   // 29.7
z_clip_top    = z_fan_top + clip_frame_t;      // 31.7

// Bounding boxes
base_bbox_x   = 2 * (branch_root + branch_len); // 196.2
base_bbox_y   = base_bbox_x;
base_bbox_z   = z_rim_top;                       // 9.0
