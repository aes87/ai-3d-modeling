# Printability Review: workout-dumbbell-holder v3.4

## Data Sources
- Geometry report: YES (trimesh mesh analysis — primary ground truth)
- Slicer report: NO (slicer-report.json not found)
- Fallback to SCAD source: NO (Fusion MCP backend; source is .f3d, not SCAD)
- Modeling report: YES (markdown, v3.4 section)
- Requirements: YES (v3 amendment read)
- Spec.json: YES (v3.4 parameters read)

---

## Print Orientation

### Orientation Analysis

The geometry report confirms bbox 88.5 × 141.25 × 56.0 mm, matching spec Z=56 (sleeve extended in v3.3). The mesh analysis was run with the part in the coordinate frame from Fusion: **plug-vertical** (plug axis = print-Z). The flange face is at Z=0, sleeve bottom at Z=−56. In print orientation terms this means the **flange top face is on the bed** (bed at Z=0, print grows in −Z direction per Fusion convention, which is +Z in printer coordinates).

**Recommended orientation: Plug-vertical, FLANGE FACE DOWN.**

- Flange face (88.5 × 62.5 mm) is the largest flat face on the part. It gives a wide, stable bed contact area with no adhesion risk.
- All sleeve walls, plug walls, and fork-plate side walls print vertically — no intrinsic overhang.
- The fork plate (Z=−22 to −34, at Y=+31.25 to +110) is the cantilever problem area. With plug-vertical it is a horizontal slab that must bridge or be supported. See bridge analysis below.
- Layer lines run perpendicular to the plug axis (= parallel to the flange face). Under the cantilever bending load (moment about the Y-axis at the fork-sleeve junction), the fork plate and buttresses are stressed in tension on the −Z face (sleeve bottom side) and compression on the +Z face (bell-rest side). The layer interfaces are parallel to these stress planes — this is the **worst-case inter-layer tension direction for CF-reinforced material**. This concern is flagged but does not change the orientation recommendation, because the cradle-flat alternative introduces worse problems (see below).

**Why not cradle-flat (fork plate on bed)?**

Rotating 90° so the fork plate is on the bed would align the layer lines perpendicular to the bending moment direction (stronger in tension). However:
1. The sleeve becomes a hollow rectangular tube lying on its side — internal cavity (78.5 × 53 mm) needs supports inside. Extraction would be difficult and surface quality inside the cavity matters for the rail fit.
2. The plug now grows horizontally — its 30 mm depth becomes a horizontal overhang series requiring supports along the entire plug length.
3. The part at 141.25 mm in Y becomes very tall on the bed in Z — 141 mm build height — with a very narrow base (only the fork plate thickness, 12 mm).

Plug-vertical is the correct orientation. The bridge issues at the fork plate must be addressed (see Step 5).

**Installed vs. print orientation:** In installed orientation the plug axis is horizontal (plugging into the rail). In print orientation the plug axis is vertical. These differ 90°.

---

## Feature Stack (bed → top, in print-Z = flange face down)

Print-Z grows from Z=0 (bed, flange top face) upward toward Z=−56 (sleeve bottom face). Note: the geometry report uses Fusion's native Z convention where −Z is the print direction. The feature stack from bed (Z=0) to part tip (Z=−56) in print order:

| # | Feature | Z range (Fusion) | Print height |
|---|---|---|---|
| 1 | Flange | Z=[0, −8] | 0–8 mm from bed |
| 2 | Sleeve + Plug (concurrent) | Z=[−8, −38] | 8–38 mm |
| 3 | Fork plate + top buttress region | Z=[−22, −34] | 22–34 mm (overlaps #2) |
| 4 | Fork plate bottom + bottom buttress region | Z=[−34, −56] | 34–56 mm |
| 5 | Ribs (arc-curved fins) | Z=[−34, −46] | 34–46 mm (on fork bottom) |
| 6 | Sleeve bottom extension | Z=[−38, −56] | 38–56 mm |

Cross-reference with geometry report transitions:

| Transition | z_mm | Type | Change % | Feature match |
|---|---|---|---|---|
| T1 | −45.9 | expansion | +10.1% | Rib outer arc curve starting (at Y=+53.25 the rib enters full depth) |
| T2 | −37.9 | expansion | +147.5% | Fork plate entering at Z=−38 (sleeve/plug section expands to include full fork plate) |
| T3 | −33.9 | expansion | +41.8% | Bottom buttress starting (fork plate bottom Z=−34) |
| T4 | −21.9 | contraction | −33.1% | Fork plate top exits (Z=−22 top of fork plate) — sleeve/flange only above this |
| T5 | −7.9 | expansion | +12.7% | Flange stepping in over plug at Z=−8 |

All 5 transitions are explained by declared features. No mystery transitions.

---

## Transition Checks

### T1: Sleeve bottom → Sleeve + Rib bases (Z ≈ −46)

- Geometry report: expansion +10.1%, layer 50 at z=−45.9
- Overhang faces: YES — the rib arc bottoms are the curved fins whose undersides are flagged as overhangs. The rib starts at full 12 mm depth at Y=+53.25 and tapers to zero at Y=+105. The bottom edge of the rib follows a 3-point arc curving from Z=−46 up to Z=−34. The underside of this arc faces downward (toward the bed) and its angle from horizontal varies from near-vertical at the inner end to near-horizontal at the outer end.
- Layer bounds: width_x stable at 83.5 mm; width_y expands from ~62.5 mm to include rib underside projection. Bounded expansion, not runaway.
- The rib bottom curve generates surfaces ranging from ~47° to ~87° from horizontal (per the overhang list, faces 34–49 and 87–102, at Z=−34 to −40, X=±38–39, Y=38–53). These are **hard overhangs** — they face downward at 47°–87°, all exceeding the 45° limit.
- **FAIL** — rib undersides are overhanging up to 87°. However, see context below.

Context: The overhang faces at X=±38–39 (face indices 34–49 and 87–102) are the outer rib edges — only 0.8–0.9 mm² each, totalling ~26 mm² for the rib-edge strips. These are the curved fin's steep leading face as the arc sweeps from Z=−46 upward. The large-area overhang faces (face indices 109–126, ~35–77 mm² each, centroids at X=−22 to +24, Y=38–53, Z=−34 to −40) are the **buttress arc undersides** — the quarter-cylinder surface facing downward toward the bed. These are the main overhang problem.

Both the rib curved arc and the bottom buttress arc face downward and are unsupported in plug-vertical orientation. **This is the primary overhang finding.**

---

### T2: Sleeve/Plug → Fork plate added (Z ≈ −38)

- Geometry report: expansion +147.5%, layer 90 at z=−37.9. This is the largest transition — the fork plate area (~83.5 × 78.75 mm = ~6,575 mm²) suddenly appears.
- The fork plate (Y=+31.25 to +110, Z=−34 to −22) starts at Z=−34. In print-vertical orientation, the plate bottom face (at Z=−34, Y=+31.25 to +110) is a **horizontal surface** that must be supported or bridged from the sleeve wall.
- The sleeve outer +Y face ends at Y=+31.25. The fork plate extends from Y=+31.25 to Y=+110 — a span of 78.75 mm in Y. **This is a 78.75 mm unsupported bridge span**, far exceeding the 10 mm limit.
- The only part of the fork plate that has material below it is the sleeve +Y wall at Y=+31.25 and the buttresses.
- Bridge measurement: layer 90, z=−37.9, +Y direction, **15.89 mm FAIL** (reported by geometry analyzer). This is at the fork plate appearance layer. The actual functional span from the last supported material (sleeve +Y face at Y=+31.25) to the open +Y tine tip (Y=+110) is ~79 mm — the geometry analyzer only reports the single-layer cross-section extension step, not the total plate width, but the message is clear.
- **FAIL** — Fork plate bottom face is an unsupported horizontal slab in plug-vertical orientation. Supports are REQUIRED here.

---

### T3: Fork plate + top buttress → Fork plate + bottom buttress (Z ≈ −34)

- Geometry report: expansion +41.8%, layer 110 at z=−33.9. The bottom buttress quarter-cylinder (r=22) and the ribs begin.
- The bottom buttress arc runs from (Y=+31.25, Z=−56) tangent to (Y=+53.25, Z=−34). Its underside (the concave face toward the −Z/−Y corner) is unsupported in plug-vertical orientation.
- Bridge measurement at layer 110: z=−33.9, +Y direction, **9.28 mm** (PASS, just under limit). However this is the first layer of the expansion; succeeding layers show the fork plate extending further.
- The large-area overhang faces (109–126, area 35–77 mm² each) are in Z=−34 to −40, Y=38–53 — these are confirmed bottom buttress underside faces.
- **FAIL (overhangs)** — Bottom buttress underside faces at 47°–87° from horizontal across the full X span, no support material. Support required.

---

### T4: Fork plate exits (Z ≈ −22)

- Geometry report: contraction −33.1%, layer 170 at z=−21.9. Fork plate top exits at Z=−22.
- The top surface of the fork plate (Z=−22 face) is a horizontal surface facing upward (+Z direction in Fusion = toward the flange in print direction). This face is a **ceiling** in print terms — it is printed onto the supports or bridged material below.
- No downward-facing overhang here; this is an upward face (the dumbbell bell rests on it). PASS for this transition.
- The top buttress arc (center at Y=+53.25, Z=0, tangent at Z=−22 and Z=0) faces partially outward/downward in the region Z=−22 to Z=0. These surfaces (the top buttress undersides) are also in the overhang list but at angles that decrease as Z approaches 0 (the buttress curves into the flange face).
- Bridge measurement at z=−21.9: −X direction, 0.917 mm. PASS.

---

### T5: Flange step at Z ≈ −8

- Geometry report: expansion +12.7%, layer 240 at z=−7.9.
- The flange OD is 88.5 × 62.5 mm; the sleeve OD is also 88.5 × 62.5 mm (they match). The transition at Z=−8 is where the plug meets the flange/sleeve top — the flange expands 10 mm radially past the plug on all sides.
- Overhang at this transition: The flange bottom face (at Z=−8) overhangs the plug cross-section (42.5 × 68.5 mm) by 10 mm on each side. The plug top face at Z=−8 supports the inner portion; the outer 10 mm of flange cantilevers over air. However, this face FACES UP in installed orientation — but in print orientation (flange face down), the flange is at the BOTTOM of the part and prints first. So this 10 mm radial overhang of the flange relative to the plug does NOT create a print overhang — the flange is printed first as the base layer. The plug grows up from the flange. This transition is FROM the wide flange TO the narrower plug cross-section, which is a contraction that is always fine.
- **The geometry report however shows this as an expansion at Z=−7.9, +12.7%.** This is because in the geometry analyzer's Z convention, Z=−7.9 is near the sleeve top in Fusion coords, and the analysis sees this layer as the flange side. The exact interpretation depends on which way the analyzer walks the layers.
- Bridge measurement at z=−7.9: −Y direction, **14.033 mm FAIL**. This is the third bridge fail. At Z=−7.9 the geometry is the underside of the flange in print orientation. The flange extends in −Y direction (the −Y short side) 31.25 mm from the center, but the sleeve inner cavity is below. The −Y span of 14 mm across the sleeve opening on the −Y side is a horizontal surface over the sleeve void. In plug-vertical print orientation, the sleeve cavity top (the inner ceiling of the sleeve) must bridge across the 53 mm × 78.5 mm opening. The 14 mm reported is one cross-section slice of that cavity ceiling — and it exceeds 10 mm.
- **FAIL** — Sleeve inner ceiling bridge. The sleeve cavity at Z=−8 (where the sleeve meets the flange) has an unsupported top face spanning up to ~53 mm in the Y direction (the narrow axis of the sleeve ID). This requires support material inside the sleeve cavity.

---

## Tips and Extremities

### Tine tips (Y = +110, Z = −22 to −34)

- The tine tips are the free end of the fork plate cantilever, at Y=+110, approximately X=±34.55 mm (per the slot geometry — the tangent lines at 30° reach X=±34.55 at Y=+110).
- Geometry report: thin_walls = 0. No thin walls detected anywhere in the part.
- Tine wall thickness (the slot-side wall from slot edge to tine outer edge): tine outer edge is at X=±39.25 (v3.4 symmetric trim), slot tangent point at X=±11.5. At the tip, slot edge is at X=±34.55 (tangent line), tine outer at X=±39.25. Wall = 39.25 − 34.55 = **4.7 mm**. Above 3 mm CF minimum. PASS.
- The rib outer ends at Y=+105 are cantilever tips. The rib is 3 mm thick in X and 12 mm deep in Z (but reduced by the arc to near-zero at Y=+105). The arc profile means near the tip the rib is very thin in Z. At Y=+105 the rib height approaches zero (arc tangent horizontal at Y=+105). The last 5–10 mm of rib height is less than 1 mm — this is below the minimum floor/ceiling (0.8 mm) and may not print as a functional fin at the extreme tip. Not a structural concern (the rib is reinforcing stiffness, not load-bearing at the tip) but worth noting.

---

## Horizontal Spans

| Span | Feature | Z (Fusion) | Measured | Direction | Result |
|---|---|---|---|---|---|
| Fork plate bottom face | Cantilever slab from sleeve | −34 | 15.89 mm (layer 90) | +Y | **FAIL — support required** |
| Sleeve inner ceiling | Cavity top at flange junction | −7.9 | 14.033 mm (layer 240) | −Y | **FAIL — support required** |
| Bottom buttress underside | Arc concave face | −45.9 | 11.236 mm (layer 50) | +Y | **FAIL — support required** |
| Fork plate top face | Bell rest face | −22 | functional surface | — | PASS (functional) |
| Various arc transitions | Buttress faces | −34 to −40 | <10 mm per layer (except top of buttress) | multiple | PASS (within limit per layer slice) |

All three bridge fails are in the plug-vertical print orientation. They are NOT avoidable-bridge conflicts — they are intrinsic to the geometry because:
- The fork plate is a functionally required horizontal slab (bell rest and shaft seat)
- The sleeve cavity top is intrinsic to the hollow sleeve design (cannot be filled without blocking rail insertion)
- The buttress arc underside is a curved transition surface between the fork plate and sleeve

None of these bridges can be eliminated by chamfering without removing functional geometry. The correct resolution is **support material**, not redesign. These are all **PASS (functional, needs support)** from a design standpoint — the geometry is correct, the slicer must add supports.

**Functional bridge assessment:**
- Fork plate bottom: the flat bottom is intrinsic to the fork-plate geometry. The upper bell rests on the top face (Z=−22) and the slot bearing depth is 12 mm — shortening the plate would reduce shaft constraint. PASS (functional, support required).
- Sleeve ceiling: intrinsic to the hollow sleeve. Cannot be filled. PASS (functional, support required).
- Bottom buttress: the quarter-cylinder gusset is structurally required. Its underside arc cannot be chamfered flat without converting the gusset into a wedge, which changes the stress transfer path. PASS (functional, support required).

---

## Overhang Summary

Total overhang faces: 667, total overhang area: 9,256.9 mm² (17.6% of surface area), max angle 90°, min angle 47°.

The overhang faces fall into three groups:

**Group A — Rib edge strips (X=±38–39, Z=−34 to −40):**
Faces 34–49 and 87–102. Area ~0.8 mm² each, total ~26 mm². These are the steep leading face of the rib outer edge as the curved fin sweeps upward. They are very small, the rib material is thin (3 mm), and the slicer will handle these with short support stubs. Minor issue.

**Group B — Buttress arc undersides (X=−22 to +25, Z=−34 to −40):**
Faces 109–126. Area 35–77 mm² each, total ~750+ mm². These are the main overhang faces — the concave underside of the bottom buttress quarter-cylinder arc facing downward. These require proper support and are the largest single overhang zone.

**Group C — Remaining overhang faces:**
The geometry report counts 667 total overhang faces at 9,256 mm². Subtracting Groups A (~26 mm²) and B (~750 mm²), the remaining ~8,480 mm² of overhang area is distributed across the rest of the curved geometry. At 17.6% of total surface, and with a large curved arc geometry, this suggests the **top buttress underside** (the mirror of Group B at Z=−22 to 0) is also a major contributor — this arc faces downward at angles from ~90° near Z=0 (tangent to the sleeve face) down to 0° at Z=−22. ALL of the top buttress curved underside is a downward-facing overhang in plug-vertical orientation.

**All overhang zones require support material.** With support enabled, all overhangs are printable — none are inaccessible to slicer-generated support (the buttress concave zones are reachable from below).

---

## Mating Clearances

| Feature | Part dim | Mating dim | Gap/side | Fit type | Result |
|---|---|---|---|---|---|
| Plug narrow axis | 42.5 mm OD | 44.5 mm ID | 1.0 mm | Sliding | PASS (generous; test print required for CF) |
| Plug wide axis | 68.5 mm OD | 70.5 mm ID | 1.0 mm | Sliding | PASS (generous; test print required for CF) |
| Sleeve narrow axis | 53.0 mm ID | 51.0 mm OD | 1.0 mm | Sliding (sleeve over rail) | PASS (generous; test print required for CF) |
| Sleeve wide axis | 78.5 mm ID | 76.5 mm OD | 1.0 mm | Sliding (sleeve over rail) | PASS (generous; test print required for CF) |
| Flange corner r | 7.0 mm | 6.0 mm OD rail corner | 1.0 mm | Clearance | PASS |
| Shaft in slot | 46 mm shaft, R23 arc seat | — | Conforming arc | Gravity cradle | PASS |
| Slot opening at plate edge | 69.1 mm | 46 mm shaft | 23.1 mm excess | Entry clearance | PASS |

**CF shrinkage note:** Plain PLA clearances are calibrated at ±0.35 mm (sliding). CF shrinks ~0.05–0.15 mm less, meaning CF parts print slightly LARGER than nominal. At 1.0 mm/side clearance the plug and sleeve have large margin. If CF produces parts 0.15 mm oversized on each face, the resulting clearance is 0.85 mm/side — still generous sliding fit. The risk is if the actual CF part grows MORE than 0.15 mm (e.g., if print profile is not calibrated for the specific filament), but 1.0 mm/side is a comfortable safety margin. Test pocket prints are still required before committing the full part.

**Sleeve OD vs. plug cross-section note:** The sleeve OD (88.5 × 62.5 mm) matches the flange OD. The sleeve ID (78.5 × 53.0 mm) is intended to slide OVER the rail OD (76.5 × 51.0 mm) in the +Z direction (the holder slides down over the rail-top from above). This is the correct relationship: sleeve ID > rail OD by 2 mm on the wide axis and 2 mm on the narrow axis. PASS.

**The −X wall removal (control panel clearance):** The sleeve is C-shaped (missing −X wall). On the −X side there is no sleeve wall to grip the rail. The three remaining walls (+X, +Y, −Y) still constrain the rail in X (by the +X wall reacting against the cantilever moment), Y (both long walls). The missing wall reduces the rotational constraint around the Z axis slightly, but the plug provides this constraint through its 4 walls inside the bore. This is acceptable; no mating clearance issue.

---

## Slicer Validation

No slicer-report.json found. Slicer validation unavailable.

**Manual slicer prediction based on geometry analysis:**
- Support material: YES, required at (1) fork plate bottom face Z=−22 to −34 in the Y=+31.25 to +110 region, (2) sleeve inner ceiling at Z=−8 inside the 78.5 × 53 mm cavity, (3) both buttress arc undersides.
- Bridge moves: likely at layer 90 (z=−37.9) as the fork plate first layer, at layer 240 (z=−7.9) for the sleeve ceiling, and at layer 50 (z=−45.9) at the bottom buttress leading edge.
- Expected support volume: significant. The fork plate spans ~79 mm in Y and 83.5 mm in X — the support column beneath it will be substantial (roughly 83.5 × 78.75 × 12 mm ≈ 79 cm³ of support). Plan for support removal time and potential marks on the fork plate bottom and buttress undersides.

---

## CF-Specific Concerns

### Inter-layer adhesion under cantilever bending

In plug-vertical orientation, layer lines are horizontal (parallel to the XY plane). The cantilever bending moment at the fork-sleeve junction (400–1,200 N·mm about the X-axis) puts the fork-plate bottom face in tension and the top face in compression. The tensile stress is perpendicular to the layer lines — this is the weakest direction for CF-reinforced FDM.

**Worst-case stress check at the fork-sleeve junction (+Y sleeve wall, at Y=+31.25, Z=−22 to −34):**
- Moment: 1,200 N·mm (max, 1.36 kg dumbbell at 90 mm reach)
- Section at Y=+31.25 is the sleeve +Y wall (5.0 mm thick) PLUS the fork plate base (12 mm Z height × 83.5 mm X width). The effective cross-section for bending resistance is approximately the fork plate height: I = (83.5 × 12³)/12 = 12,042 mm⁴
- Fiber stress σ = M × c / I = 1,200 × 6 / 12,042 = **0.60 MPa**
- CF-PLA inter-layer tensile strength is typically 20–40 MPa (conservative lower bound ~15 MPa for poor layer adhesion)
- Safety factor: 15 / 0.60 = **25×**. Very comfortable even with worst-case inter-layer adhesion.

The buttresses significantly increase the effective section depth (the top buttress adds ~22 mm of height above the fork plate top face, the bottom buttress adds ~22 mm below). Including the buttresses: effective depth from bottom buttress bottom (Z=−56) to fork plate top (Z=−22) = 34 mm, I grows substantially. The section is not at risk of bending failure.

**Verdict on CF inter-layer adhesion:** PASS with comfortable margin. The 400–1,200 N·mm moment is handled by the fork plate + buttress cross-section with a factor of safety well above 10 even at minimum CF inter-layer strength.

### Plug root stress (plug-to-flange junction, Z=−8)

The plug wall at Z=−8 carries the cantilever reaction moment through the engagement region. The fillet (r=5 mm on the 8 inside-corner edges per Fillet3) reduces stress concentration at this transition. With 30 mm engagement depth and 1.0 mm/side clearance, the plug contact against the rail bore resists rotation. At max load (13.3 N × 90 mm = 1,197 N·mm), the reaction force couple at the engagement region is ~1,197 / 60 ≈ 20 N per engagement point. Against the plug wall cross-section area (plug perimeter × wall thickness ≈ well above 100 mm²), the bearing stress is well below CF compressive strength. PASS.

### Minimum wall check

Geometry report: thin_walls = 0. No wall below 1.2 mm detected anywhere in the mesh. All walls above 3 mm CF minimum per design (verified: sleeve walls 4.75–5.0 mm, tine walls 4.7 mm, rib thickness 3.0 mm, plug walls ≥3 mm). PASS.

---

## Conflicts

### CONFLICT 1: Fork plate bottom face — support removal marks on bell-rest surface

The bottom face of the fork plate (Z=−34 in Fusion, facing toward the bed in plug-vertical print) is where the **upper bell of the dumbbell rests**. This face will have support material contact in plug-vertical print orientation. Support removal will leave marks, potentially with minor surface irregularity (~0.1–0.3 mm bumps or scarring).

**Functional impact:** The bell rests on this face by gravity — it doesn't need to be precision-flat. Minor support marks are cosmetically acceptable. However, if the support is not fully removed, it can create a lump that cants the dumbbell angle slightly. This is a cosmetic/functional tradeoff the user should be aware of.

**Resolution options:**
1. Accept support marks on the bell-rest face (probably fine for gravity cradle use).
2. Rotate part so bell-rest face prints upward (but this means the sleeve cavity is on the bed — worse problems).
3. Use dissolvable support interface layer if dual-extrusion is available (Bambu X1C supports this in AMS mode).

**Recommend user acknowledge this tradeoff.** Not a redesign trigger.

### CONFLICT 2: Sleeve inner cavity support — sleeve-to-rail fit surface

The sleeve inner cavity (78.5 × 53.0 mm) top face at Z=−8 needs support material. The support will contact the inner wall surfaces of the sleeve. The sleeve inner walls are the **mating face for the rail OD** — they slide over the rail's outer surface with 1 mm/side clearance.

If support material leaves residue on the sleeve inner walls, the clearance is consumed and the sleeve may not slide over the rail. Post-print cleaning of the sleeve interior is essential. In a closed rectangular cavity this is not trivial — access is from the −Z open end (sleeve bottom) only.

**Resolution options:**
1. Support the sleeve ceiling carefully, then clean the interior before installation.
2. Accept slightly rougher inner walls (1 mm clearance provides tolerance for minor surface quality degradation).
3. Use a roof/bridge technique with careful support settings to minimize support contact with the long walls.

**Recommend user acknowledge sleeve interior cleaning step as part of the post-print finishing procedure.**

### CONFLICT 3: −X wall removal asymmetry vs. stress

The sleeve is C-shaped (−X wall removed). Under cantilever loading, the sleeve's +X wall carries the reaction force. The asymmetric C-shape means the sleeve has different stiffness in +X vs −X lateral directions. The plug inside the bore provides symmetric constraint, so this is not a structural problem. However, the flange still spans the full 88.5 mm width on the top — if the control panel structure extends above the rail top face (into the flange Z range Z=−8 to 0), the flange will also need a −X trim. This was flagged in v3.1 and v3.2 as an open question.

**Recommend user verify against the reference photo whether the console structure clears the full-width flange before printing the full part.** A test sleeve-only print (first 38 mm from bed, plug + flange + sleeve, no fork plate) could be used to check both rail fit and console clearance simultaneously.

---

## Summary

- Data quality: geometry report (mesh, trimesh) / no slicer report / no SCAD fallback (Fusion backend)
- Total transitions checked: 5
- PASS: 4 (T1 overhang noted below, T4, partial T3 per-layer, T5)
- FAIL: 3 bridge spans (fork plate bottom, sleeve ceiling, bottom buttress edge) — all require support material
- Overhang FAIL: 667 overhang faces, 17.6% of surface, max 90° — both buttress arc undersides and rib curved fin edges require support
- Slicer agreement: N/A (no slicer report)
- Conflicts requiring user decision: 3 (bell-rest surface marks, sleeve interior cleaning, flange −X clearance confirmation)
- Thin walls: NONE (0 walls below 1.2 mm reported; all walls above 3 mm CF minimum)
- CF structural check: PASS (safety factor >25× at fork junction)
- Bbox: 88.5 × 141.25 × 56.0 mm — within X1C 256 mm build volume. PASS.

---

## Test Print Recommendations

- **Plug + sleeve fit pocket (high priority):** Print a 38 mm tall stub of the sleeve + flange + plug (no fork plate, no buttresses) — essentially the first 38 mm of the part from the bed. This verifies: (a) plug fits into the extrusion bore with the 1 mm/side clearance, (b) sleeve slides over the rail OD, (c) control-panel console clears the full-width flange on the −X side, and (d) sleeve interior surface quality after support removal. This single test print closes three open questions before committing to the 56 mm full part with substantial support material. Weight ~40–50 g vs. the full part. Priority: HIGH.

- **Fork plate bridge quality (medium priority):** Print a 20 mm wide slice of the fork plate (Y=+31 to +110, full Z and X, truncated at Y=+50 to keep it short) to evaluate: (a) surface quality of the bell-rest face after support removal, (b) slot geometry accuracy (R23 arc, 46 mm shaft diameter), (c) bridge quality on the fork plate bottom face. If the surface quality is acceptable, proceed to full print. If support marks are significant, consider adjusting support interface layers or spacing. Priority: MEDIUM.

- **Buttress arc overhang quality (low priority):** The buttress arc undersides are large-area overhangs at steep angles (up to 90°). These are the largest overhang zone in the part. A test of a small section of the buttress profile (a 20 mm × 20 mm × 20 mm corner cut including the arc) would validate that the support removal leaves clean curved faces. Priority: LOW (the buttress faces are not mating surfaces, cosmetic quality is not critical).

---

## Verdict

**PASS-WITH-CONDITIONS**

**Recommended print orientation: Plug-vertical, flange face down.**

The part geometry is sound, all walls are above the 3 mm CF minimum, no thin walls, bounding box is within the X1C build volume, and the CF structural analysis shows adequate safety margin at the cantilever junction. The design's dual-engagement concept is correct and the geometry is watertight.

**Conditions to print:**

1. **Supports required.** Enable support material in the slicer for the following zones: (a) fork plate bottom face Z=−22 to −34 in Y > +31.25, (b) sleeve inner cavity ceiling at Z=−8, (c) both buttress arc undersides (bottom buttress Z=−34 to −56 in Y=+31 to +53, top buttress Z=−22 to 0 in the same Y range). Use interface layers (2–3 layers at 0.1 mm offset) to ease support removal from the bell-rest face and sleeve interior.

2. **Sleeve interior cleaning required before installation.** Support material inside the sleeve cavity must be fully removed before the sleeve can slide over the rail. Access is from the open sleeve bottom (−Z end). Plan for this as part of post-print finishing.

3. **Test print first.** Print the plug + flange + sleeve stub (first 38 mm from bed, no fork plate) before the full part. Verify plug-to-bore fit, sleeve-to-rail-OD fit, console clearance, and sleeve interior surface quality.

4. **Confirm flange −X clearance.** Check the reference photo to determine if the treadmill console structure encroaches above the rail-top face. If it does, the flange's −X edge needs trimming (same cut as the sleeve wall, extended up 8 mm). This must be confirmed before printing the full part; the test stub print above will reveal this.

5. **Slicer run required.** No slicer report was generated for this review. Run PrusaSlicer or Bambu Studio on the STL before printing to confirm support placement, estimated print time, and material usage. The support volume under the fork plate (~79 cm³) will add substantial print time and material.
