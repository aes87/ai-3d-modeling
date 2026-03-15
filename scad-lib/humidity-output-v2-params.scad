// Humidity-Output V2 Duct Mount — Parameters
// V2 changes from V1:
//   - Spigot OD reduced: 108 -> 106mm (duct wire rings could not slide over at 108)
//   - Spigot ID follows: 98 -> 96mm (wall stays 5mm)
//   - Lead-in taper at spigot top: OD tapers 106 -> 100mm over 8mm
//   - Internal fins start at z=0 (was z=5), fixing unsupported first layers

// === Waffle Grid (matches bin lid, same as fan-tub-adapter) ===
ho2_square_size  = 63.7;    // mm — waffle square side
ho2_channel_w    = 9.4;     // mm — channel width
ho2_waffle_h     = 4.6;     // mm — waffle square height (sets outer plate thickness)
ho2_cutout       = 2 * ho2_square_size + ho2_channel_w;  // 136.8mm — lid opening
ho2_corner_r     = 4;       // mm — waffle corner radius
ho2_flange_w     = ho2_channel_w / 2;  // 4.7mm
ho2_frame_outer  = ho2_cutout + 2 * ho2_flange_w;  // 146.2mm
ho2_branch_root  = ho2_cutout / 2 + ho2_channel_w / 2;  // 73.1mm — fork center from origin
ho2_branch_w     = 9.0;     // mm — branch arm width
ho2_branch_len   = 25;      // mm — arm engagement into channel from root

// === Base Plate ===
ho2_frame_t_outer = ho2_waffle_h;   // 4.6mm — outer plate, flush with waffle tops
ho2_inner_pad_t   = 5.0;           // mm — inner zone thickness
ho2_inner_pad_size = 130;          // mm — inner pad square side (covers spigot base)
ho2_inner_pad_r   = 8;             // mm — inner pad corner radius

// === Duct Spigot (V2: reduced OD) ===
ho2_spigot_od    = 106;    // mm — spigot outer diameter (reduced from 108 in v1)
ho2_spigot_wall  = 5;      // mm — wall thickness (structural, withstands clamp load)
ho2_spigot_id    = ho2_spigot_od - 2 * ho2_spigot_wall;  // 96mm — airflow bore

// === Lead-In Taper (NEW in V2) ===
ho2_taper_height = 8;      // mm — axial height of taper zone at spigot top
ho2_taper_tip_od = 100;    // mm — OD at top of taper (tip)

// === Fins ===
ho2_fin_count    = 6;      // fins of each type, evenly spaced at 60 deg

ho2_fin_int_t       = 2;   // mm — internal fin tangential thickness
ho2_fin_int_d_base  = 6;   // mm — internal fin radial depth (full depth)
ho2_fin_int_taper_z = 10;  // mm — axial taper zone at top (depth fades 6->0)
ho2_fin_wall_lap    = 1;   // mm — overlap into spigot wall (avoids coincident face)

ho2_fin_ext_t    = 3;      // mm — external shark fin tangential thickness
ho2_fin_ext_r    = 9;      // mm — external shark fin radial protrusion at base

// === Seal Zone Geometry ===
ho2_foam_w       = 19;     // mm — groove axial width (matches 3/4" foam tape)
ho2_foam_groove_d = 2.5;   // mm — groove depth into spigot OD

ho2_lower_ridge_h = 4;     // mm — protrusion above spigot OD surface (was 3; increased for 45° chamfer)
ho2_lower_ridge_w = 5;     // mm — axial width of ridge (was 4; preserves 1mm flat top)
ho2_lower_ridge_od = 114;  // mm — ridge OD (4mm radial protrusion per side over 106mm spigot OD)

// === Vertical Stackup (Z from base plate bottom) ===
ho2_z_spigot_start    = ho2_inner_pad_t;                                      // 5.0
ho2_z_lower_ridge_bot = ho2_z_spigot_start + 15;                              // 20.0
ho2_z_lower_ridge_top = ho2_z_lower_ridge_bot + ho2_lower_ridge_w;            // 25.0
ho2_z_foam_bot        = ho2_z_lower_ridge_top;                                 // 25.0
ho2_z_foam_top        = ho2_z_foam_bot + ho2_foam_w;                           // 44.0
ho2_z_spigot_top      = ho2_z_foam_top + 18;                                  // 62.0
ho2_z_taper_start     = ho2_z_spigot_top - ho2_taper_height;                  // 54.0

// External shark fin height: fills from spigot start up to 2mm below lower ridge bottom.
ho2_fin_ext_h    = ho2_z_lower_ridge_bot - ho2_z_spigot_start - 2;  // 13mm

// Internal fin Z start (V2: starts at z=0, not z=5)
ho2_fin_int_z_start = 0;   // mm — fins start at bed level for full support

// === Bounding Box ===
ho2_bbox_x = 2 * (ho2_branch_root + ho2_branch_len);  // 196.2mm
ho2_bbox_y = ho2_bbox_x;
ho2_bbox_z = ho2_z_spigot_top;                         // 62.0mm
