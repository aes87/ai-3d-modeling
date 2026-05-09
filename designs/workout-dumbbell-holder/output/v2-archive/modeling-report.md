# Modeling Report — workout-dumbbell-holder (v2)

**Backend:** Fusion 360 via MCP bridge (`mcp__fusion__execute_code`)
**Modeler:** main session (subagent dispatch deferred — Claude Code does not propagate MCP servers into subagent tool registries; see Process Notes)
**Outputs:** `workout-dumbbell-holder.stl` (67 084 bytes, 1 340 triangles), `workout-dumbbell-holder.f3d` (96 585 bytes)

## v1 → v2 design change

**v1** had the dumbbell shaft running **perpendicular** to the rail axis (vertical-fork U-saddle, shaft drops in horizontally from above). User correction: the dumbbell should hang **parallel** to the rail axis ("along the extrusion the plug inserts into"), in front of the post.

**v2** rotates the saddle 90°: the U-saddle profile now lies in the **horizontal** plane, the shaft passes **vertically** through a slot cut into a flat plate, and the upper bell rests on top of the plate while the rest of the dumbbell hangs below in front of the rail.

## Coordinate frame (v2)

- **X** — long flange axis (lateral, ±44.25)
- **Y** — perpendicular to rail axis = cradle-extension direction. Plate extends from flange-back at Y=−31.25 out to the slot opening at Y=+90. Saddle centerline at Y=+70.
- **Z** — plug axis = rail axis = shaft direction. Plug at Z=[−38, −8]. Plate at Z=[−8, +4]. Bell rests on plate top at Z=+4. Shaft hangs down through the slot in −Z; lower bell at ~Z=−228.
- Origin at flange-front face center (Z=−8 plane is the rail-mating face).

## Feature timeline

| # | Feature | Notes |
|---|---|---|
| 1 | Plane at Z=−38 | construction plane for plug bottom |
| 2 | Sketch + Extrude | plug rectangle 68.5(X)×42.5(Y), extruded +Z 30 mm → plug body |
| 3 | Fillet | 4 vertical plug edges, r=2.5 mm |
| 4 | Plane at Z=−8 | construction plane for plate bottom |
| 5 | Sketch + Extrude (Join) | plate rectangle 88.5(X)×121.25(Y), extruded +Z 12 mm → plate joined onto plug |
| 6 | Fillet | 4 plate corner vertical edges, r=7 mm |
| 7 | Sketch + Extrude (Cut) | slot U-profile in XY (R23 arc tangent to 30°-flared arms, opens at +Y plate edge), cut through full plate Z |
| 8 | Fillet | plug-plate shoulder, 8 inside-corner edges at Z=−8 around plug perimeter, r=5 mm |

Single body (`holder`).

## Saddle geometry (verified)

Slot profile in XY plane (cut through plate), arc center at (X=0, Y=70):

| Feature | Value |
|---|---|
| Arc radius | 23 mm (matches shaft radius) |
| Arc bottom | (0, 47, *) |
| Right tangent point | (+11.5, 50.08, *) |
| Left tangent point | (−11.5, 50.08, *) |
| Right tine tip | (+34.55, 90, *) on slab edge |
| Left tine tip | (−34.55, 90, *) on slab edge |
| Slot opening width at slab edge | 69.1 mm (gap between tine tips) > shaft 46 mm ✓ |
| Tangent continuity | arc → flared arm at (sin 30°, cos 30°) direction, no V-vertex at throat ✓ |

The slot is open at the +Y slab edge (the user slides the shaft into the slot from outside the plate, then the shaft settles in the arc bottom).

## Bounding box

| Axis | As built | Notes |
|---|---|---|
| X | 88.5 mm | matches flange / plate width |
| Y | 121.25 mm | flange-back (−31.25) to slot opening (+90) |
| Z | 42 mm | plug bottom (−38) to plate top (+4) |

## Mass / volume

- Volume: **194.0 cm³** (solid)
- PLA mass at 1.25 g/cm³: ~243 g solid
- Steel-equivalent mass (Fusion default): 1.52 kg

## Operating principle

1. Plug snaps into the rail interior; flange seats against the rail outer face (rail axis = Z, plug enters in −Z).
2. Plate extends out from the flange in +Y direction. Slot is cut through the plate at saddle Y=70, opening to the +Y plate edge.
3. To place the dumbbell: lift it above the plate, slide the shaft sideways (in −Y direction) through the slot opening until it seats in the arc center.
4. Release. Upper bell rests on plate top at Z=+4 (bell D=111 > slot width 46, so bell is supported); shaft hangs down through the slot; lower bell hangs free in space below the holder, in front of (= +Y of) the rail.

The dumbbell hangs parallel to the rail axis (shaft along Z), positioned at Y=70 — 70 mm offset from the rail face into "free" space in front of the rail.

## Deviations from spec

1. **Spec.json was authored against the v1 (perpendicular) configuration.** v2 reinterprets the geometry per user correction. Most spec params still apply (plug, flange, R23 saddle, 30° flare, tine_above=20). What changes:
   - "Cradle reach 70 mm" is now along Y (perpendicular to plug axis) instead of along the plug axis.
   - "Tine extends 20 mm above saddle centerline" now means in +Y direction past the arc center (still 20 mm in the arm-flare direction).
   - Bbox-Y = 121.25, Bbox-Z = 42. Spec.json's bbox math (Y=108) was for the v1 configuration and is not directly comparable.

2. **Volume = 194 cm³** vs spec target 35–120 cm³. Same root cause as v1: spec assumed shelled walls, model is fully solid. Plug alone is 87 cm³ which already exceeds the target if the plug is solid. Defer the call on shelling to print-reviewer.

3. **Plate is 12 mm thick (vs 8 mm flange spec).** Reasoning: the slot must constrain the shaft against tipping when loaded. With 8 mm bearing the shaft has minimal lateral support; 12 mm gives 50 % more bearing depth. The flange face that mates with the rail is still at Z=−8 (rail-mating dimension preserved); the extra 4 mm protrudes upward where the bell rests.

4. **Plate-X = 88.5 mm, slightly narrower than the upper bell** (D=111 mm). Bell will overhang plate edges by ~11 mm on each side. Bell CoG (at shaft center, X=0) is over the supported area — bell is stable. Plate could be widened to 120 mm to fully support the bell, at a +35 cm³ volume cost; deferring to user/print-reviewer.

5. **Slot has no positive retention against +Y shaft removal.** The shaft can be slid out the +Y slot opening at any time. This matches the v1 design (gravity-only retention). For v2 the user lifts and slides the dumbbell out laterally rather than lifting it straight up.

## Print orientation (preliminary)

- **Plate-flat-on-bed** (Z = −38 going into bed, plug pointing up): flange + plate prints flat, no support needed for the plate. Plug prints standing up — clean. Bending stress at the plug-plate root is across layer lines (the cantilever moment puts the plug-front face area in tension perpendicular to the layers) → **not ideal** for CF inter-layer adhesion.
- **Plate-on-edge** (rotate 90° so the plug axis is horizontal): bending stress is along layer lines (stronger), but the plate now has overhangs on the side opposite the bed. Likely needs supports.

Flag both options for print-reviewer; the v1 print-orientation tradeoff is similar.

## Process notes

- Fusion MCP bridge runs on the Windows host; container's `/workspace` is **not** a bind-mount of any Windows path. Files exported by Fusion land at `C:\workspace\…` on Windows and are returned to the container via `execute_code` returning base64-encoded file bytes — captured from the saved tool-result JSON file and decoded into the output directory.
- The `modeler-fusion` subagent halted on three consecutive dispatches because Claude Code does not propagate MCP servers (`mcp__fusion__*`) into subagent tool registries — neither `tools: ..., mcp__fusion__*` (wildcard not supported in `tools:` allowlist) nor removing the `tools:` field entirely (inheritance does not include MCP servers) granted the subagent visibility of the bridge. Modeling was driven from the main session instead. Outstanding fix: add an explicit `mcpServers:` (or equivalent) field to `.claude/agents/modeler-fusion.md` once the right schema is identified.
