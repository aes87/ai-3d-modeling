// FDM PLA Tolerance Constants
// Use these in all designs to ensure proper fit on the Bambu X1C.

// Fit offsets (applied to radius or per-side dimension)
FDM_PRESS_FIT     = -0.15;  // Friction-held joints
FDM_CLEARANCE_FIT =  0.25;  // Easy insert/remove
FDM_SLIDING_FIT   =  0.35;  // Moving parts

// Hole compensation (applied to diameter)
FDM_HOLE_COMPENSATION = 0.4;

// Structural minimums
MIN_WALL = 1.2;       // 3 perimeters at 0.4mm nozzle
MIN_FLOOR_CEIL = 0.8; // 4 layers at 0.2mm

// Overhang and bridging limits
MAX_OVERHANG_ANGLE = 45;  // degrees from vertical
MAX_BRIDGE_SPAN    = 10;  // mm unsupported horizontal span

// Layer and nozzle
NOZZLE_DIA   = 0.4;
LAYER_HEIGHT = 0.2;
