# <Design Name> Requirements

## Design Intent

<What this part does, why it exists, how it's used in the real world.>

## Print Orientation

- **Bed face:** <which face sits on the print bed>
- **Print-Z direction:** <what grows upward during printing>
- **Rationale:** <why this orientation — largest flat face, avoids supports, etc.>

## Dimensions & Sources

Every dimension must have a source. If the source is missing, ask the user.

| Dimension | Value (mm) | Source | Notes |
|---|---|---|---|
| Overall X | | user-provided / datasheet / measured | |
| Overall Y | | | |
| Overall Z | | | |
| <feature dimension> | | | |

## Features

### <Feature 1 Name>

- **Purpose:** <functional role>
- **Critical dimensions:** <with tolerances>
- **Location:** <where on the part, z-range if known>

### <Feature 2 Name>

...

## Mating Interfaces

For each interface where this part meets another part or object:

### <Interface Name>

- **Mates with:** <part name or object>
- **Fit type:** press / clearance / sliding
- **This part dimension:** <OD/ID/width in mm>
- **Mating dimension:** <OD/ID/width in mm>
- **Resulting gap/interference:** <computed value in mm>
- **Role:** slide-over guide / hard stop / seal surface

## Material & Tolerances

- **Material:** PLA (default) / <other>
- **Required fit types:** <list which FDM tolerance offsets are needed>
- **Special requirements:** <heat resistance, flexibility, etc.>

## Constraints

- **Build volume:** 256 x 256 x 256 mm (Bambu X1C)
- **Min wall thickness:** 1.2 mm
- **Min floor/ceiling:** 0.8 mm
- **<Other constraints>:** <values>

## Printability Pre-Screen

Flags for features that may need design attention:

| Feature | Concern | Severity | Notes |
|---|---|---|---|
| <name> | overhang >45° / bridge >10mm / thin wall | warning / blocker | |

## Assembly Context

- **Single part** or **multi-part assembly**
- If multi-part: list other parts and their roles
- Assembly spec file: `assemblies/<name>.json` (if exists)
