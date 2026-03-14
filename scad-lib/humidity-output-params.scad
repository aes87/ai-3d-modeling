// Humidity-Output Duct Mount — Shared Parameters

// === Waffle Grid (matches bin lid, same as fan-tub-adapter) ===
ho_square_size  = 63.7;    // mm — waffle square side
ho_channel_w    = 9.4;     // mm — channel width
ho_waffle_h     = 4.6;     // mm — waffle square height (sets outer plate thickness)
ho_cutout       = 2 * ho_square_size + ho_channel_w;  // 136.8mm — lid opening
ho_corner_r     = 4;       // mm — waffle corner radius
ho_flange_w     = ho_channel_w / 2;  // 4.7mm
ho_frame_outer  = ho_cutout + 2 * ho_flange_w;  // 146.2mm
ho_branch_root  = ho_cutout / 2 + ho_channel_w / 2;  // 73.1mm — fork center from origin
ho_branch_w     = 9.0;     // mm — branch arm width
ho_branch_len   = 25;      // mm — arm engagement into channel from root

// === Base Plate ===
ho_frame_t_outer = ho_waffle_h;   // 4.6mm — outer plate, flush with waffle tops
ho_inner_pad_t   = 5.0;           // mm — inner zone thickness
ho_inner_pad_size = 130;          // mm — inner pad square side (covers spigot base)

// === Duct Spigot ===
// Measured: duct hard-ring ID = 110mm. Spigot OD = 108mm (1mm per-side slip fit).
spigot_od        = 108;    // mm — spigot outer diameter (duct slides over)
spigot_wall      = 5;      // mm — wall thickness (structural, withstands zip-tie load)
spigot_id        = spigot_od - 2 * spigot_wall;  // 98mm — airflow bore

// === Seal Zone Geometry ===
// Foam tape: closed-cell EPDM, 3/4" wide × 1/8" thick (3.2mm).
// Groove depth 2.5mm → foam proud 0.7mm → easy slide-on, seals when zip-tied.
foam_w           = 19;     // mm — groove axial width (matches 3/4" foam tape)
foam_groove_d    = 2.5;    // mm — groove depth into spigot OD

// Lower stop ridge: duct hard-ring cannot pass (ridge OD 114mm > duct ring ID 110mm)
lower_ridge_h    = 3;      // mm — protrusion above spigot OD surface
lower_ridge_w    = 4;      // mm — axial width of ridge

// Upper guide ridge: prevents zip tie migration upward
upper_ridge_h    = 2;      // mm — protrusion above spigot OD
upper_ridge_w    = 3;      // mm — axial width

// === Vertical Stackup (Z from base plate bottom) ===
z_spigot_start   = ho_inner_pad_t;                          // 5.0  — spigot begins at inner pad top
z_lower_ridge_bot = z_spigot_start + 10;                    // 15.0 — 10mm insertion zone below ridge
z_lower_ridge_top = z_lower_ridge_bot + lower_ridge_w;      // 19.0
z_foam_bot       = z_lower_ridge_top;                       // 19.0
z_foam_top       = z_foam_bot + foam_w;                     // 38.0
z_upper_ridge_bot = z_foam_top;                             // 38.0
z_upper_ridge_top = z_upper_ridge_bot + upper_ridge_w;      // 41.0
z_spigot_top     = z_upper_ridge_top + 19;                  // 60.0 — 19mm above-seal grip zone

// === Bounding Box ===
ho_bbox_x = 2 * (ho_branch_root + ho_branch_len);  // 196.2mm
ho_bbox_y = ho_bbox_x;
ho_bbox_z = z_spigot_top;                           // 60.0mm
