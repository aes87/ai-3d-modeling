---
date: 2026-04-26
project: 3d-printing
type: session-log
---

# 2026-04-26 — ptouch-cradle v3 ship (7-round ID critique arc)

## Quick Reference
**Keywords:** ptouch-cradle, v3 minimalism, owl direction abandoned, ID critique loop, 7 rounds, Muji-Rams, kanban tray, lowered front wall grab feature, interior floor ramp, concave fillet sweep, draft-vs-ship render quality, OpenSCAD CGAL bottleneck, $fn 100 vs 200, top_fillet_steps 24 vs 64, host_object_proxy, use-state render, render-the-use-state lesson, modeler arc-center math, quadratic ramp curve, lip-thickening boss, panda problem, "the horror" round-1 invisibility, label catch tray, PT-P750W
**Project:** 3d-printing
**Outcome:** Shipped ptouch-cradle v3 (commit `31a2e27`) — quiet Muji-Rams desk dock for Brother PT-P750W with closed kanban label-catch tray. 7-round ID critique loop iterated through abandoned owl direction → minimalism pivot → tray rebuild with grab + ramp features. Pipeline speedup convention introduced (draft-quality during iteration, ship-quality at delivery) cut iteration time from 2hrs to ~8min.

## What Was Done

1. **Round 1 (owl, ad-hoc critique on shipped v2):** consolidated owl motif onto back panel, deleted tray face, restored tray scoop lip, added concave printer→shelf fillet, removed feather embosses, softened base. Modeler PASS. User reaction: "the horror" — discovered the facial disc at z=90 was hidden behind the 143mm printer body in actual use. Round-1 design declared broken.
2. **Round 2 (owl, post-mortem fix):** raised back panel 145→205mm so face zone sits visible above the printer; rebuilt face anatomy per real-barn-owl reference (heart-shaped disc, recessed eye sockets, no pupils, asymmetric beak); rebuilt tufts as splayed feather clumps. Added host_object_proxy module + use-state render requirement. Modeler PASS. User feedback: "decent but I don't want it" — abandoned owl direction entirely.
3. **Round 3 (v3 minimalism pivot):** dropped all face/tuft/panel geometry; collapsed back panel to 25mm matching other 3 perimeter walls; symmetric Muji bathtub form. Two-tier fillet schedule (r=3 utility, r=10 hero). Modeler PASS first iteration. cradle.scad shrunk 719→378 lines; cradle Z dropped 221→28mm; volume dropped 32%.
4. **Round 4 (refinements):** cradle shelf width 108→110 for continuous 3mm tray-holder wrap (was 2.05mm thin slot side walls); tray top-edge fillet r=2 + $fn=200 to eliminate facet stepping; first attempt at smooth front scoop (mistakenly built as front-wall-as-curve, ate the closed-bin character).
5. **Round 5 (closed-bin restoration):** rebuilt tray as proper closed kanban bin with short front wall (z=18) + curved interior ramp + grabbable boss+indent on +Y exterior face. Removed feet entirely (silicone aftermarket); removed cable notch (plug above design height); cradle top fillet bumped to 64-step stack + $fn=200 for smooth curves.
6. **Round 6 (variable-height + concave ramp):** lowered center cutout in front wall (corners z=18, center z=10) for natural finger access; ramp re-oriented from convex pan-edge to concave bowl-curve; quadratic curve substituted for circular arc (impossibility proof: no concave-from-cavity arc with above-floor constraint exists for these endpoints).
7. **Round 7 (final simplification):** collapsed variable-height profile to uniform front wall z=10 across full width; ONE concave fillet per side r=20 (replaces round-6's two-fillets-in-series); eliminated corner "top bars" and intersection sharp points. r=2 top fillet → r=0.8 on the 1.6mm-thick front wall (function-driven exception, anticipated).
8. **Pipeline speedup convention introduced** between rounds 5 and 6: split render quality into draft (during iteration: $fn=100, top_fillet_steps=24, ramp_arc_steps=32) vs ship ($fn=200, top_fillet_steps=64, ramp_arc_steps=96 via -D overrides). Modeler agent + shipper agent definitions updated. Verified speedup: cradle STL 15min→68s (~13×), tray STL ~60s→16s (~4×), full pipeline ~2hrs→~8min.
9. **Print review + fit review PASS.** One marginal cross-section measurement artifact (not a real issue), one assembly-spec position bug fixed (tray X position 2.35→3.40 in `assemblies/ptouch-cradle.json`).
10. **Shipped (commit `31a2e27`):** STLs re-rendered at ship quality, docs/ptouch-cradle.md rewritten v2 owl→v3 minimalism with full critique journey in design log, README updated, renders copied to docs/images/.

## Decisions & Trade-offs

| Decision | Rationale |
|----------|-----------|
| Abandon owl direction at round 2/3 boundary | After 2 rounds the creature read shifted from "uncanny mascot" (round 1) to "happy panda/teddy bear" (round 2). User signaled the direction wasn't worth more refinement; minimalism is more honest for a label-printer dock |
| Lowered-center grab feature → uniform low front wall (round 6→7) | Variable-height profile introduced visual clutter (corner "bars" at z=18) and intersection sharp points. Single uniform z=10 front wall + one r=20 concave fillet per side is simpler, friendlier, more ergonomic |
| Quadratic curve substituted for circular arc on interior ramp (round 6) | Modeler proved no circular arc satisfies all three constraints (concave from cavity + connecting endpoints + above-floor) for these dimensions. Quadratic preserves the spirit (monotonic rise, concave from cavity, smoothly tangent to flat floor) |
| Lip-thickening boss behind round-5 grab indent | 2.86mm scoop depth on 1.6mm wall would punch through. Boss extends wall thickness locally so structural wall remains. Sculptural, not decorative — earns its place via function. Removed in round 6 once approach changed to lowered-center cutout |
| Draft-quality during iteration, ship-quality at delivery | Round 5 took 2hrs; most was OpenSCAD/CGAL rendering at $fn=200 + 64-step fillet stacks. Splitting quality knobs cut iteration to ~8min while keeping ship artifacts at full smoothness. Designs declare quality knobs as top-level params; shipper passes -D overrides |
| Render the use-state, not just the part | Round 1's facial disc at z=90 was geometrically perfect but invisible behind the installed printer. Bare-geometry renders hid the failure. Added host_object_proxy module + use-state render requirement to id-designer agent's Cycle 0; codified as a lesson in _id-library/lessons.md |
| Drop feet entirely on cradle | User: "they complicate printing and are useless. I'll put silicone feet on, but make the bottom surface flush to the build plate." Better first-layer adhesion, simpler print, cleaner aesthetic |
| Eliminate cable notch | User: "the plug is above the height of the whole design, so no cutout needed." Original notch was based on incorrect assumption about plug position |

## Key Learnings

1. **Render the USE-STATE, not just the part.** If a design holds, cradles, docks, or interacts with another object, at least one hero render must show that object installed. Bare-geometry renders hide what the host occludes. Round 1 would have shipped an invisible face had the user not caught it on GitHub. Codified as Cycle 0 — Use-state check in `.claude/agents/id-designer.md`.
2. **OpenSCAD/CGAL bottleneck is rendering, not curve expressiveness.** Everything we wanted to build was expressible in OpenSCAD; it was just slow at high $fn + many sequential offset operations + slab-stacks. Two-tier quality convention solved 90% of the friction.
3. **Modeler agents should question ambiguous geometric specs.** Round 5 modeler caught an arc-center math error in my notes. Round 6 modeler proved no circular arc satisfied the constraints and substituted a quadratic. Both interventions were the right call. The modeler agent's tendency to push back on geometrically impossible specs is a feature, not a bug.
4. **ID critique loops can converge in 7 rounds for a 2-part assembly.** Each round was 5min-2hrs (depending on draft vs ship quality). The arc went: explore aesthetic → discover blocking issue → pivot direction → refine → simplify → ship. Worth budgeting 5-7 rounds for any design with a non-trivial aesthetic component.
5. **The "panda problem" pattern.** When trying to land a creature motif via face features, hull-based smoothing produces rounded mammalian-ear/eye shapes. Real owl anatomy needs sharp/pointed feather details. If hulls produce blobs, switch to union with deliberate gaps.
6. **Conversation log + per-round modeler-notes-vN.md is high-value historical record.** The `id/` subdirectory of the design captures the full design rationale and per-round fix lists. Future critiques on this design (or similar designs) can pull from this archive.

## Files Modified

**Design files:**
- `designs/ptouch-cradle/cradle.scad` — rewritten 7 times across rounds; current state (round 7) is 378 lines, $fn=100 draft. Cradle is now a quiet symmetric stepped bathtub with no feet, no cable notch, no decoration.
- `designs/ptouch-cradle/tray.scad` — rewritten 7 times; current state (round 7) is the closed kanban bin with uniform low front wall + concave fillet sweeps + curved interior ramp + r=2 top fillet on back/sides + r=0.8 on thin front wall.
- `designs/ptouch-cradle/spec.json` — large param diffs across all rounds; many delete-and-replace cycles for face/tuft/panel/grab params. Final state has only functional + minimal-aesthetic params.
- `designs/ptouch-cradle/output/cradle.stl`, `tray.stl` — re-rendered each round; final ship-quality versions in `31a2e27`.
- `designs/ptouch-cradle/output/modeling-report.json` — per-round feature inventory.
- `designs/ptouch-cradle/output/cradle-geometry-report.json`, `tray-geometry-report.json` — trimesh + slicer analysis.
- `designs/ptouch-cradle/output/review-printability.md` — round-7 print review (PASS, 1 marginal).
- `designs/ptouch-cradle/output/review-fitment.json` — round-7 fit review (PASS).

**ID critique files (`designs/ptouch-cradle/id/`):**
- `brief.md` — main spec block + form language + per-feature rationale, with Revisions log spanning rounds 1-7.
- `conversation-log.md` — turn-by-turn dialogue across all 7 rounds + the round-1 "horror" pivot moment + abandon-owl decision.
- `modeler-notes-v1.md` through `modeler-notes-v7.md` — per-round executable contracts for the modeler.
- `round-01-renders/` through `round-07-renders/` — 7 PNGs per round in user-frame terms (use-state hero leads from round 5+).

**Pipeline + agent definitions:**
- `.claude/agents/id-designer.md` — added Cycle 0 — Orient (mandatory user-orientation step) + Cycle 0 — Use-state (mandatory host-object check). New brief schema fields: `user_orientation`, `hero_views`, `use_state.host_object`.
- `.claude/agents/modeler.md` — Quality section rewritten with draft/ship convention. Designs declare quality knobs as top-level params.
- `.claude/agents/shipper.md` — new "Re-render at ship quality" step with -D override examples.

**Shared library:**
- `designs/_id-library/lessons.md` — added 2 lessons: "Establish user orientation before critiquing" (round 1 wrong-face critique) and "Render the use-state, not just the part" (round 2 invisible-face discovery).

**Docs:**
- `docs/ptouch-cradle.md` — rewritten v2 owl theme → v3 minimalism with full design log of the 7-round arc.
- `docs/images/ptouch-cradle/` — 7 ship-quality renders.
- `README.md` — ptouch-cradle entry updated to v3 hero image + description.
- `assemblies/ptouch-cradle.json`, `assemblies/ptouch-cradle-resolved.json` — tray X position corrected 2.35→3.40 (was using `slot_x0 - clearance_total` formula instead of `slot_x0 + clearance_per_side`).

**Sessions:**
- `docs/sessions/2026-04-26-06-15-ptouch-cradle-v3-ship.md` — this log.

## Follow-ups

1. **Print v3 STLs and verify in physical world.** Cradle 110×254.9×25mm + tray 103.2×94.2×30mm. PLA, base-down for cradle, face-up for tray, no supports. Apply silicone feet to cradle bottom aftermarket.
2. **Verify the marginal r=20 fillet thin-wall reading in slicer/print.** Print-reviewer flagged 1.026-1.148mm cross-section measurements at the side fillet corners — believed to be measurement artifact, not real thin walls. Confirm in PrusaSlicer/Bambu Studio + actual print.
3. **Verify tray prints clean face-up.** The interior floor ramp + concave side fillets should all be self-supporting per modeler analysis, but worth a slicer auto-orient check.
4. **Revisit the side-wall Y-direction step at front-wall slab boundary** if the user notices it on the printed part. Documented in modeler reports as a minor visual artifact (not a print issue). Round 8 fix would extend the concave fillet to also operate in Y direction.
5. **Migrate ptouch-cradle's draft/ship convention to other designs.** Older designs (`humidity-output`, `fan-tub-adapter`, etc.) still use single-quality settings. If they get revised, adopt the new pattern.
6. **Consider a CADQuery / build123d migration** for designs with heavy fillet or smooth-curve requirements. OpenSCAD got the job done but every fillet was hand-constructed via offset stacks. A modern CAD framework with native smooth curves + true 3D fillets would eliminate ~30% of the boilerplate and run faster.
