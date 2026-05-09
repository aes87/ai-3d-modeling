# Modeling Report — workout-dumbbell-holder (v3.4)

## v3.3 → v3.4: arc-shaped ribs + recentered cantilever

Two refinements:

### Ribs reshaped to curved fins

Each rib's bottom edge is now an arc instead of a horizontal line. The arc rolls from full rib depth (Z=−46) at the inner-visible end (Y=+53.25, where the bottom buttress ends) up to zero rib depth (Z=−34, flush with fork bottom) at the outer end (Y=+105). The arc has its tangent horizontal at the outer end so it blends smoothly into the fork bottom — no sharp step at the tine tip.

Implementation: cut the "scoop" region under each rib (the region between the desired arc and the original rectangular rib bottom at Z=−46) using a 3-point arc through (Y=+53.25, Z=−46), (Y=+79.125, Z=−36.88), (Y=+105, Z=−34). Cut at each rib's X plane (X=+35.5 for right, X=−38.5 for left), extruded 3 mm in +X to match each rib's width.

The portion of each rib at Y=[+31.25, +53.25] stays rectangular but is hidden inside the bottom buttress so it doesn't show externally.

Rib volume shrunk slightly (about 4.2 cm² × 3 mm × 2 = 2.5 cm³ removed), leaving the rib looking like a slim curved fin.

### Cantilever recentered around X=0

After v3.1's −X wall cut, the fork plate was asymmetric: tine wall thickness was 4.7 mm on the −X side but 9.7 mm on the +X side. Trimmed the +X overhang of the cantilever so both tine walls are symmetric:

- Cut a 5 mm × 78.75 mm × 56 mm column at X=[+39.25, +44.25], Y=[+31.25, +110], Z=[−56, 0]. This removes the +X overhang of:
  - Fork plate (5×78.75×12 ≈ 4.7 cm³)
  - Top buttress (≈0.5 cm³)
  - Bottom buttress (≈0.5 cm³)
- Sleeve is unaffected (cut starts at Y=+31.25, outside the sleeve material).

Result: cantilever and slot are now both symmetric around X=0. Tine walls 4.7 mm on each side.

| | v3.3 | v3.4 |
|---|---|---|
| Volume | 261.8 cm³ | **253.5 cm³** |
| STL triangles | 1 458 | 1 542 |
| Tine wall thickness (sym) | 4.7 / 9.7 mm | **4.7 / 4.7 mm** |
| Rib bottom shape | rectangular | **arc-curved fin** |

Bounding box still 88.5 × 141.25 × 56 (sleeve OD unchanged). Fork-region max +X is now +39.25, matching the −X cut boundary.

---



## v3.2.1 → v3.3: extended sleeve, symmetric bottom buttress, fork shrink, ribs

User asked for four changes to balance and reinforce the cantilever:

1. **Grow sleeve down** to make room for a symmetric fillet on the bottom side. Sleeve was Z=[−38, −8] (30 mm long); extended down to Z=[−56, −8] (48 mm long, +18 mm). The new −18 mm of sleeve also has its −X wall cut (matching v3.1's clearance) so the entire sleeve length is C-shape.

2. **Shrink fork** so it doesn't overhang the buttress on the −X side. The buttress sits at X=[−39.25, +44.25]; the fork plate previously extended to X=−44.25 in the Y > +31.25 region (uncut by the v3.1 wall removal). Cut that overhang: removed material at X=[−44.25, −39.25], Y=[+31.25, +110], Z=[−34, −22]. Fork plate now matches buttress X range cleanly.

3. **Bottom buttress (symmetric to top, r=22).** Mirror of the v3.2 top buttress, reflected about Z=−28 (mid-fork). Profile arc center at (Y=+53.25, Z=−56), tangent at (Y=+31.25, Z=−56) on the new sleeve-bottom edge and at (Y=+53.25, Z=−34) on the fork bottom. Same X span as top buttress (X=[−39.25, +44.25]).

4. **Ribs along fork bottom.** 2 ribs running parallel to Y, one along each tine: at X=±37 (centered on each tine, 3 mm thick in X), Y from +31.25 (sleeve face) to +105 (5 mm before tine tip), 12 mm deep in −Z (Z=[−46, −34]). Inner ends join the sleeve +Y wall and overlap the bottom buttress; outer ends are cantilever tips. Adds bending stiffness via section depth.

| | v3.2.1 | v3.3 |
|---|---|---|
| Sleeve length (Z) | 30 mm | **48 mm** |
| Bbox Z | 38 mm | **56 mm** |
| Bbox Y | 141.25 mm | 141.25 mm |
| Bbox X | 88.5 mm | 88.5 mm |
| Volume | 234.0 cm³ | **261.8 cm³** |
| STL triangles | 1 250 | 1 458 |

Cantilever stiffness improvements: (a) longer sleeve gives the rail-holder reaction couple a 60 mm lever arm now (vs 30 mm originally); (b) bottom buttress carries tension on the −Z side of the fork-sleeve junction in a curved shear path (mirroring the top compression path); (c) ribs add ≈8 mm of effective section depth to each tine.

---



## v3.2 → v3.2.1: re-applied −X wall cut (it was reverted)

The −X wall cut from v3.1 was unintentionally reverted when the buttress was added. Root cause: a test sketch I ran during the buttress-build to probe the YZ-plane sketch coord mapping was deleted via `sk_test.deleteMe()`, and that operation ALSO emptied the −X cut sketch (Sketch6) — its lines disappeared, leaving a sketch with 0 profiles, which silently broke the corresponding cut Extrude. The sleeve sidewall came back without an explicit error.

Fix: re-applied the cut as a fresh sketch+extrude (Sketch10 + cut Extrude7 in the timeline). Sleeve bottom corners at X=−44.25, Y=±31.25 are gone again. Volume drop confirms the cut: 243.4 → 234.0 cm³ (the expected ~9.4 cm³ wall material removed). All remaining X=−44.25 vertices sit on the flange (intact) or the uncut portion of the fork plate (at Y > +31.25 only).

Lesson for next session: don't delete sketches via `deleteMe()` mid-build — use an isolated test in a throwaway document, or compute the YZ-plane mapping algebraically without empirically probing.

## v3.1 → v3.2: r=22 buttress fillet on top of the fork

User asked for a "big fillet on the top of the fork to give it strength — roll that all the way to the top edge of the block." Added a r=22 mm quarter-cylinder gusset that fills the air pocket between the fork's top surface (at Z=−22) and the flange's top edge (at Z=0, Y=+31.25).

Implementation: sketched a closed profile in the YZ plane bounded by the +Y face of the body (vertical line from Y=31.25, Z=0 down to Z=−22), the fork-top face (horizontal line from Y=31.25 out to Y=+53.25 at Z=−22), and a 22 mm-radius arc (center at Y=+53.25, Z=0) from (Y=+53.25, Z=−22) tangent-back to (Y=+31.25, Z=0). Profile area = 1.04 cm². Extruded in +X direction by 83.5 mm to span X = [−39.25, +44.25] (matching the post-cut fork plate's X range — does not extend into the −X clearance cut). Joined to existing body.

Effect: the upper-bell load on the fork now transfers into the sleeve+flange via a curved buttress instead of a sharp 90° step. The cantilever-bending stress is spread over the full 22 mm vertical face of the sleeve+flange rather than concentrating at the single line where fork-top meets sleeve-+Y face.

| | v3.1 | v3.2 |
|---|---|---|
| Volume | 225.4 cm³ | **243.4 cm³** (+18.0) |
| STL triangles | 1 224 | 1 250 |
| File size (STL) | 58 284 B | 62 584 B |

The buttress does not extend into the −X clearance cut (X < −39.25), so the control-panel clearance is preserved. The buttress also shares Y = +31.25 face with the existing flange/sleeve, and Z = −22 face with the existing fork plate top — flush merge, no overhang.

## v3 → v3.1: removed −X short wall of sleeve

User feedback after v3: confirmed the sleeve concept needs to be visible (it is — verified via face count: 6 inner-cavity walls + 5 outer-OD walls + plug perimeter is the second mating surface), and per the reference photo, the **treadmill control panel structure abuts the rail on the −X side** (left, in the photo), so the sleeve's −X short wall would interfere on installation.

v3.1 adds one cut feature on top of v3: a 5 mm × 62.5 mm × 30 mm rectangular cut at X = [−44.25, −39.25], Y = [−31.25, +31.25], Z = [−38, −8]. This removes the −X short wall plus the two −X corners (where the wall met the +Y and −Y long walls). The sleeve now has a clean **C-shape** in cross-section: +X short wall and +Y / −Y long walls, opening on −X.

| | v3 | v3.1 |
|---|---|---|
| Volume | 235.1 cm³ | **225.4 cm³** |
| Sleeve walls | 4 (closed rectangle) | 3 (C, opening on −X) |
| STL triangles | 1 300 | 1 224 (smaller after wall removal) |
| File size (STL) | 65 084 | 58 284 |

The flange is **not** cut — it still spans the full X range [−44.25, +44.25] at Z=[−8, 0]. If the console structure also extends ABOVE the rail-top face (encroaching on the flange Z range), the flange will need a similar −X cut; flag for user review against the photo.

The fork plate is unaffected (it's at +Y direction, far from the −X cut).

---



**Backend:** Fusion 360 via direct add-in TCP protocol (`{"type": "<cmd>", "params": {...}}`) — bypassed the broken `mcp__fusion__*` server in this session.
**Outputs:** `workout-dumbbell-holder.stl` (65 084 bytes, 1 300 triangles), `workout-dumbbell-holder.f3d` (113 961 bytes), `v2-archive/` (preserves v2 outputs).

## v2 → v3 design change

**v2** held the dumbbell on a single flat plate cantilevered from the flange — single-engagement (plug only, internal). User feedback for v3:

1. **Add an external sleeve.** The holder now grips the rail on **both** sides — internal plug + external sleeve — for dual-engagement stiffness against the cantilever moment.
2. **Lower the fork to ~20 mm below the rail-top face.** The dumbbell load is now applied at the *middle* of the engaged region (not at the top), spreading stress across both engagements rather than concentrating at the plug root.
3. **Cradle reach increased 70 → 90 mm.** Necessary so the upper bell (D 111) clears the sleeve's +Y face when the shaft is seated. Tradeoff: longer lever arm in Y, but the rail-holder reaction couple now has 2× the effective lever arm (plug + sleeve in opposition), so each engagement sees less force overall.

Spec.json + requirements.md updated with v3 amendment block.

## Coordinate frame (v3)

- **X** — wide flange axis (lateral, ±44.25)
- **Y** — perpendicular to plug axis = cradle direction. +Y is "outboard" / in front of the rail. Origin at flange center.
- **Z** — plug axis = rail axis = shaft direction. Plug enters in −Z. Rail-mating face (= flange-back = sleeve-top) at Z = −8. Plug at Z = [−38, −8]. Flange at Z = [−8, 0]. Sleeve at Z = [−38, −8] (concentric with plug, surrounding the rail outside). Fork plate at Z = [−34, −22] (saddle centerline at Z = −28, 20 mm below rail-top).

## Feature timeline

| # | Feature | Notes |
|---|---|---|
| 1 | Plane at Z=−38 | construction plane (plug bottom) |
| 2 | Sketch1 + Extrude1 | plug rectangle 68.5(X)×42.5(Y), extrude +Z 30 mm → plug body |
| 3 | Fillet1 | 4 vertical plug edges, r = 2.5 mm |
| 4 | Plane at Z=−8 | construction plane (flange/sleeve top) |
| 5 | Sketch2 + Extrude2 | flange rectangle 88.5×62.5, extrude +Z 8 mm → flange joined |
| 6 | Fillet2 | 4 flange corner vertical edges, r = 7 mm |
| 7 | Sketch3 (sleeve) + Extrude3 | sketch outer 88.5×62.5 + inner 78.5×53 rectangles in same sketch on plane at Z=−38; extrude annulus profile (area 13.71 cm², auto-detected from candidate profiles) by +Z 30 mm → sleeve joined |
| 8 | Plane at Z=−34 | construction plane (fork bottom) |
| 9 | Sketch4 + Extrude4 | fork plate rectangle 88.5(X) × 83.5(Y, from +26.5 to +110), extrude +Z 12 mm → fork plate joined |
| 10 | Sketch5 + Extrude5 (Cut) | slot U-profile in XY (R23 arc tangent to 30°-flared arms, opens at +Y plate edge), cut through full fork plate Z |
| 11 | Fillet3 | plug-flange shoulder, 8 inside-corner edges around plug perimeter at Z=−8, r = 5 mm |
| 12 | Fillet4 | fork-sleeve junction, 2 horizontal X-edges at Y=+31.25 where fork plate top/bottom meet sleeve outer +Y face, r = 3 mm |

Single body (`holder`).

## Sleeve geometry (verified)

| Param | Value | Constraint |
|---|---|---|
| Sleeve OD wide (X) | 88.5 mm | matches flange OD-wide |
| Sleeve OD narrow (Y) | 62.5 mm | matches flange OD-narrow |
| Sleeve ID wide (X) | 78.5 mm | = `extrusion_od_wide` (76.5) + 2 × clearance (1.0) |
| Sleeve ID narrow (Y) | 53.0 mm | = `extrusion_od_narrow` (51.0) + 2 × clearance (1.0) |
| Wall — wide-axis | 5.00 mm | ≥ 3 mm CF minimum ✓ |
| Wall — narrow-axis | 4.75 mm | ≥ 3 mm CF minimum ✓ |
| Length (Z) | 30 mm | matches `plug_depth` |
| Inner corner r | 0 mm | NOTE: inner cavity uses sharp corners (no fillet); rail outer corner r = 6 has 1 mm clearance to wall, no interference. Could fillet inner corner for printability if needed. |

## Fork-plate + slot geometry (verified)

Slot profile in XY plane (cut through fork plate Z):

| Feature | Computed | Notes |
|---|---|---|
| Arc radius | 23 mm | = shaft radius, conforming fit |
| Arc center | (X=0, Y=+90, Z varies) | saddle centerline |
| Arc bottom | (0, +67) | arc center − R |
| Right tangent point | (+11.5, +70.08) | (R·sin30°, Y_saddle − R·cos30°) |
| Right tine tip | (+34.55, +110) | tangent line continued at 30° to plate edge |
| Slot opening at plate edge | 69.1 mm | > shaft 46 mm ✓ |
| Tangent continuity | yes | arc → arm direction (sin30°, cos30°), no V-vertex |

## Bounding box

| Axis | v2 | v3 | Math |
|---|---|---|---|
| X | 88.5 | 88.5 | unchanged — plug_wide + 2×flange_overhang |
| Y | 121.25 | **141.25** | flange_y_back (−31.25) → tine_tip_y (+110) — 20 mm longer because cradle_reach increased 70→90 |
| Z | 42 | **38** | unchanged structure (plug 30 + flange 8) but no plate above flange in v3 |

Internal bbox check: min = (−44.25, −31.25, −38.0) mm, max = (+44.25, +110.0, 0.0) mm. Inside X1C 256 mm build volume.

## Mass / volume

- Volume: **235.1 cm³** (solid)
- PLA mass at 1.25 g/cm³: ~294 g solid
- vs v2 (192.8 cm³): +42 cm³, mostly the sleeve body (41 cm³ for the annular shell) and the fork plate's shifted footprint.

## Operating principle (v3)

1. Holder is placed on the rail: plug enters the rail interior from above; sleeve simultaneously slips over the rail outer surface. Both engage with 1 mm/side clearance — sliding fit. Flange seats on rail-top face as the hard stop.
2. To place the dumbbell: lift it, slide the shaft sideways into the slot from the +Y open end of the fork plate until the shaft seats at the arc bottom (at Y=+90 from rail center).
3. Release. The upper bell rests on the fork-plate top surface (at Z=−22, well below the rail-top at Z=−8). The shaft passes through the slot vertically. The lower bell hangs free at Z ≈ −22 − 200 mm (shaft length) − 30 (lower bell axial height) ≈ Z = −252.
4. Dumbbell hangs **parallel to the rail axis**, in front of (at Y=+90 from) the rail. The upper bell is at Y=[+34.5, +145.5], Z=[−22, +8] — clear of flange/sleeve in Y by ≈3.25 mm.

## Why v3 is structurally better than v2

The dumbbell weight (4.4–13.3 N at the saddle) generates a bending moment about the rail-holder interface. In v2 (plug only, internal) the moment is reacted by the plug's contact with the rail interior across its 30 mm depth — single-sided lever arm.

In v3 (plug + sleeve, opposed) the moment is reacted by the **plug pushing one way** at the top of the engaged region and the **sleeve pushing the opposite way** at the bottom — a couple. The effective lever arm of this reaction couple is roughly `plug_depth + sleeve_length / 2 ≈ 60 mm` (vs ~30 mm in v2), so the reaction force at each engagement is roughly halved.

Additionally, lowering the fork to Z=−22 means the load application point is in the *middle* of the engaged region rather than at the top — stress is distributed more evenly between plug and sleeve rather than concentrated at the plug root.

## Local sleeve beef-up at fork junction

The fork plate's base spans Y = [+26.5, +110] at Z = [−34, −22]. Y=+26.5 is the sleeve's inner +Y face. So the +Y portion of the sleeve wall in this Z range is **fully replaced** by fork-plate material: instead of the standard 4.75 mm sleeve wall on the +Y side, this Z range has 4.75 + 78.75 = 83.5 mm of solid material on the +Y side. This carries the cantilever moment without thickening the rest of the sleeve.

The fork-sleeve junction also has a 3 mm fillet on the two horizontal X-edges where fork plate top/bottom meet the sleeve OD +Y face — softens the stress riser at the corner.

## Deviations from spec

1. **Volume = 235.1 cm³ vs spec target 35–120 cm³.** Same root cause as v1/v2: spec assumed shelled walls, model is fully solid. Plug + flange + sleeve alone (without fork) is 172.5 cm³ — already over the target.
2. **Inner corners of the sleeve cavity not filleted.** The spec doesn't require it; rail outer corner r = 6 mm has 1 mm clearance to the sleeve wall regardless of corner geometry. If the print-reviewer flags inner-corner stress concentration, an inner fillet can be added as a follow-up.
3. **No upper-bell axial height in spec** — collision-checking against the flange/sleeve assumes 30 mm. If actual bell is taller and the upper bell extends above Z=0, it remains in air (no holder material at Z>0 in v3), so no collision.

## Print-orientation tradeoff (preliminary)

- **Plug-vertical** (Z-axis aligned with bed normal, plug pointing down or up): all walls are vertical. Plug, flange, and sleeve walls all print clean. The fork plate is a cantilevered horizontal slab at Z = [−34, −22] — needs supports (or print over the sleeve top using a bridge, which may be too long for a 12 mm thick plate).
- **Cradle-flat** (rotate so fork plate is on the bed, plug pointing horizontally): plate prints flat (good), but the sleeve becomes a horizontal hollow tube — needs supports in the cavity, plus the plug now has overhangs along its length.

Neither orientation is overhang-free. Recommend orientation be chosen based on layer-line vs cantilever-stress alignment — print-reviewer to evaluate.

## Process notes

- The Fusion MCP server (`fusion360-mcp-server v1.27.0`) wedged mid-session: it was sending the wrong message format (`{"command": ...}`) to the add-in, which expects `{"type": "<cmd>", "params": {...}}`. Probed the add-in protocol manually — verified `{"type": "ping"}` returns `{"pong": true}` and that all calls follow the same shape.
- Bypassed the MCP server entirely for v3: used a small Python helper (`/tmp/fusion_call.py`) that opens a TCP connection to `host.docker.internal:9876` and speaks the add-in's native protocol directly. The MCP server's role was just translating between the agent's tool calls and the add-in protocol; doing it directly works fine.
- Files transferred from Windows back to container via base64-over-`execute_code` (last-expression returns `[size, b64]`, decoded in container).
- Outstanding: the broken `mcp__fusion__*` server should be debugged or replaced before the next session — the add-in's current protocol is `type`-keyed but the MCP server is sending `command`-keyed messages. Either the server version drifted from the add-in version, or there's a config flag controlling which dialect it speaks.
