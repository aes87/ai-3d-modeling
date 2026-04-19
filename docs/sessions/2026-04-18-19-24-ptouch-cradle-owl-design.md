---
date: 2026-04-18
project: 3d-printing
type: session-log
---

# 2026-04-18 — ptouch-cradle owl design

## Quick Reference
**Keywords:** ptouch-cradle, Brother PT-P750W, label printer holder, owl motif, kanban tray, industrial design, ID agent TODO, OpenSCAD, multi-agent pipeline, iteration 2, 3D printing, FDM, fillets, feather embosses, ear tufts, base plate overhang, dome feet, cylindrical feet, scoop lip, grip scallop, false positive bridge, ray-cast artifact
**Project:** 3d-printing
**Outcome:** Designed and shipped two revisions of ptouch-cradle — an owl-themed desktop holder for a Brother PT-P750W label printer with a removable kanban-style label catch tray. Full multi-agent pipeline (spec → model → review → ship) exercised twice. User review surfaced the need for a dedicated industrial-design agent in the pipeline; captured as project TODO for future work.

## What Was Done
- Ran the full multi-agent pipeline end-to-end on a new design, twice.
- **Iteration 1 (commit `c4e044d`)**: two-part cradle + owl-face tray, shipped with owl ear tufts, tall back panel, 3 scalloped side walls, cloud window cutouts (later removed), tall tray with scoop lip + top-edge grip scallop.
- **Iteration 2 (commit `90dd34a`)**: user-driven revisions — shortened tray (41.6 → 21.6 mm), removed scoop lip and grip scallop, enlarged owl face (eyes r=9 mm, pupils r=4 mm, 8×8 mm beak), replaced dome feet with cylinders (fixes base-plate overhang), added feather-arch embosses to printer-section side walls, shrunk tray slot to match tray.
- Verified printer dimensions (78 × 152 × 143 mm) from Brother official spec page.
- Downloaded and visually analyzed Brother official product photos (front/left/right) to confirm tape-exit location (front face, lower-middle, Z ≈ 60–75 mm) and printer's rounded aesthetic.
- Established convention: every new design gets a vault note at `vault/projects/3d-printing/<name>.md`, created at spec time and updated through pipeline. Saved as feedback memory.
- Logged user feedback for a future pass: restore scoop lip, add proper face render, rework or remove feather embosses, add an ID agent to the pipeline.

## Decisions & Trade-offs

| Decision | Rationale |
|----------|-----------|
| Owl motif (creature direction) | User chose over restrained / face / themed / pattern options |
| Full-perimeter low base over U-shape | User feedback — "slicker", fully encloses printer; tape exit at z ≈ 60–75 mm clears the 25 mm front wall |
| Remove 25 mm tray pedestal riser | Printer auto-cuts tape so labels drop cleanly; over-engineered with riser |
| Bin oversized (100 × 91 × 40 mm) after riser removal | Longer drop distance (~55–70 mm) needs larger catch area |
| Stepped cradle body (86 mm printer section → 108 mm shelf section) | First modeling pass used constant 108 mm body, giving chunky 14 mm printer-section side walls; user asked for slicker |
| Ear tufts on tall back panel | Only way to get owl "peeking over printer" silhouette given printer is 143 mm tall |
| Removed side-wall scallops + cloud windows in iter 1 reshape | Low 25 mm walls can't support 10 mm features |
| Shortened tray in iter 2 | User feedback — 41.6 mm was "goofy"; 21.6 mm with enlarged face is cleaner |
| Restore scoop lip deferred | User recognized its removal was wrong; holding for ID-agent revision |
| Dome feet → cylinder feet | Dome geometry created huge base-plate overhang (apex-only contact); cylinder is flat-to-flat, prints clean |
| Skip test-print stage | Small aesthetic design; user opted to proceed direct to ship |
| Don't commit vault repo | Vault has many other in-progress changes; user manages that repo separately |

## Key Learnings
- **Product photography is often load-bearing**: the Brother spec page didn't state tape-exit location, but official product photos gave an unambiguous answer. Photo-verified assumptions removed a critical spec risk (which face has the tape exit determines cradle orientation).
- **OpenSCAD render presets can miss the decorative face**: the default `tray-front.png` preset rendered a top-edge sliver rather than the owl face, leading the docs to publish without showing the feature. Custom view angles should be added when a design has a designated "hero face."
- **Ray-cast thin-wall detection false-positives near fillets**: 0.675–1.149 mm readings at x ≈ ±52 mm were ray-cast artifacts from a 4 mm vertical corner fillet deflecting the ray; correctly diagnosed by the print-reviewer rather than triggering unnecessary modeling iterations.
- **"Bridge" analyzer false-positives at open geometry**: the geometry-analyzer flags any horizontal span across an open pocket as a bridge fail; print-reviewer judgment is required to distinguish open-pocket floors (expected, supported by bed) from actual unsupported spans.
- **Dome feet are a trap**: domes with flat bottom on the bed taper to a point at the base plate, creating a ~3 mm unsupported overhang across the entire base-plate bottom. Visually cute, structurally bad.
- **Orchestrator-driven aesthetics don't land**: Multi-turn user interventions (ear tuft shape → feathers → scoop removal → scoop restoration) show a pattern of accumulation-as-applique rather than a coherent ID pass. This is the origin of the ID-agent TODO.

## Solutions & Fixes
- **Shelf-wall fillet collapse** (iter 1 print-review FAIL): modeler suppressed the 1.5 mm top-edge horizontal fillet only on the 2.05 mm shelf-section outer side walls. Full-height 1.5 mm fillets preserved on the thicker printer-section perimeter walls and tall back panel. Inside-slot walls; no aesthetic cost.
- **Printer-section chunky walls** (first modeling pass artifact): modeler initially centered the 80 mm printer pocket in the 108 mm body, giving 14 mm thick walls. Fixed with a stepped footprint — printer section 86 mm wide with 3 mm walls, shelf section 108 mm with 2.05 mm slot flanks, connected by a 45° chamfer over 11 mm per side. Reduced cradle volume 23% (231.7 → 177.7 cm³).
- **Base-plate overhang under dome feet**: replaced `scale([1,1,foot_h/(foot_d/2)]) sphere(d=foot_d)` + intersection with `cylinder(h=foot_h, d=foot_d)`. Flat top merges cleanly with base plate bottom; first layer is a full 8 mm disc per foot.
- **Pre-existing beak rotation bug**: modeler discovered and fixed during iter 2 — triangle was rotating into the tray interior or to z=-9. Fix: pre-translate by +beak_raise in Y before `rotate([90,0,0]) linear_extrude` so prism spans Y = ext_d .. ext_d + beak_raise outward.

## Files Modified

**Created:**
- `designs/ptouch-cradle/requirements.md` (multiple revisions)
- `designs/ptouch-cradle/spec.json` (multiple revisions)
- `designs/ptouch-cradle/cradle.scad`
- `designs/ptouch-cradle/tray.scad`
- `designs/ptouch-cradle/output/cradle.stl`, `tray.stl`
- `designs/ptouch-cradle/output/cradle-geometry-report.json`, `tray-geometry-report.json`
- `designs/ptouch-cradle/output/cradle-slicer-report.json`, `tray-slicer-report.json`
- `designs/ptouch-cradle/output/modeling-report.json`
- `designs/ptouch-cradle/output/review-printability.md`
- `designs/ptouch-cradle/output/review-fitment.json`
- `docs/ptouch-cradle.md`
- `docs/images/ptouch-cradle/*.png` (9 renders)

**Updated:**
- `README.md` — ptouch-cradle row added to designs table
- `/workspace/projects/obsidian-vault/vault/projects/3d-printing/ptouch-cradle.md` — design note created and updated through pipeline (not committed)
- `/workspace/projects/obsidian-vault/vault/projects/3d-printing.md` — log entry + Tasks section for ID agent (not committed)

**Memory:**
- `feedback_vault_design_notes.md` — new feedback memory for vault-note-per-design convention
- `project_id_agent_todo.md` — new project memory for the ID agent initiative
- `MEMORY.md` — index updated

**Commits:** `4ccc2f4` (initial spec), `c4e044d` (iter 1 ship), `90dd34a` (iter 2 ship). All pushed to `origin/main`.

## Follow-ups

### ptouch-cradle design (deferred to future ID-agent revision)
- [ ] Restore tray scoop lip (removing it was a mistake per user)
- [ ] Add dedicated `tray-owl-face.png` front-elevation render — current preset misses the face
- [ ] Rework or remove feather-arch embosses on printer-section side walls — user feedback "don't do much"
- [ ] Consider whether the ear tufts read more as cat/bat than owl — revisit under ID agent
- [ ] Test print the tray to validate new 22.3/21.6 mm slot fit and owl-face surface finish before full production print

### Project-level
- [ ] **Add an Industrial Design (ID) agent to the pipeline.** Sits between `spec-writer` and `modeler`, consumes functional spec, produces aesthetic treatment document (form language, motif coherence, feature-level visual rationale, reference imagery). Optional `id-reviewer` mid-pipeline. See `project_id_agent_todo.md` memory and the Tasks section of `vault/projects/3d-printing.md`.
- [ ] Refresh `bin/validate.js` to support multi-part designs in a single directory — currently assumes one `<design>.scad` per dir, breaks when the design ships `cradle.scad` + `tray.scad`.

## Errors & Workarounds
- **`bin/validate.js` doesn't support multi-part designs**: the modeler had to invoke `cli-anything-openscad` directly and run `trimesh` analysis manually because `bin/validate.js` looks for a single `<design>.scad`. Workaround for this session; logged as project-level follow-up.
- **Default render preset camera angles** didn't capture the owl face on `tray-front.png` — the preset rendered a top-edge sliver. No fix applied this session; captured as design follow-up.
- **OpenSCAD 4 mm vertical fillet on 3 mm tall back panel** was omitted by the modeler (panel thickness narrower than 2× fillet radius). Accepted as cosmetic deviation — the fillet would degenerate geometrically on a sub-8-mm-thick wall.
