---
date: 2026-04-19
project: 3d-printing
type: session-log
---

# 2026-04-19 — ID agent build + ptouch-cradle critique field test

## Quick Reference
**Keywords:** id-designer, industrial-design agent, conversational agent, critique mode, design mode, mockup-first loop, Flux Kontext, Vizcom, Kindchenschema, Dieter Rams, aesthetic brief, id/brief.md, modeler-notes, _id-library, user_orientation, hero_views, print-frame vs user-frame, cli-anything-openscad, camera presets, ptouch-cradle, owl tufts, cat-ear failure, feather embosses, tray owl face, supports-permitted policy, inline commenting, Obsidian vault review, OpenSCAD custom cameras
**Project:** 3d-printing
**Outcome:** Designed, defined, wired, and field-tested an industrial-design (`id-designer`) agent with two modes (design pre-modeling, critique post-render) + shared reference library. Field-test critique on [[ptouch-cradle]] exposed a pipeline-level orientation gap (OpenSCAD print-frame ≠ user-frame) that was fixed by adding a mandatory Cycle 0 — Orient step and `user_orientation` / `hero_views` brief schema additions. Session ended mid-critique round 1, paused on a still-dialing-in tray head-on render.

## What Was Done

### Research and proposal (morning)
- Ran two parallel research agents: (1) AI-assisted industrial-design tooling survey (Vizcom, Flux Kontext, Midjourney, Meshy/Tripo/Hunyuan3D/Trellis, Zoo.dev, Plasticity, CSM), (2) ID craft principles (proportion, fillet schedule, Kindchenschema, Dieter Rams, character-motif discipline, FDM constraints).
- Drafted proposal at `vault/projects/3d-printing/id-agent-proposal.md`: conversational mockup-first ID agent between `spec-writer` and `modeler`, human-in-the-loop image gen for v1, structured brief as handoff, pipeline integration, open questions.

### Agent definition and pipeline wiring
- Created `.claude/agents/id-designer.md` (sonnet, Read/Write/Edit/Glob/Grep tools) with explicit conversational role, 4-cycle design loop (mood → moodboard → silhouette → mockup dial-in → brief), craft checklist (hero dim/ratios, silhouette test, fillet schedule ≤3, feature hierarchy, intrinsic vs applied, Kindchenschema, owl≠cat, anti-brief, FDM ornament constraints), brief schema, library collaboration rules ("agent proposes, user approves every promotion"), pushback rules, and return format.
- Scaffolded shared library at `designs/_id-library/` with README (structure + maintenance rules), empty `families/`, `references/`, `lessons.md` skeleton.
- Wired pipeline: added `requiresId` field to `spec-writer.md`, updated `AGENT-WORKFLOW.md` with the ID stage for Medium/Complex designs, updated `modeler.md` to treat `id/brief.md` as authoritative for aesthetics, updated project `CLAUDE.md` quick-ref and conventions.
- Extended agent with critique mode (second major edit): auto-detects mode from inputs, 5-cycle critique loop (triage → localize → propose → optional reaction mockups → handoff), outputs `modeler-notes-v<n>.md` with classified fixes + "Leave alone" section + uncertainty flags + spec-routing markers, brief gained Revisions section. Also added AGENT-WORKFLOW stage 6 (user-gated ID-critique loop between review and ship, supports out-of-flow dispatch).

### Field test on [[ptouch-cradle]]
- Dispatched critique mode ad-hoc (no prior brief). Loaded `output/*.png` renders + `modeling-report.json` + `review-printability.md`. Ran silent craft checklist: silhouette FAIL, hierarchy inverted, head:body 1:4 (should be 1:1 for cute), owl tufts h=35 w=25 vertical = cat-ear geometry, all features applied, feather embosses "don't do much" per user.
- Surfaced review as an inline-commentable Obsidian note at `vault/projects/3d-printing/ptouch-cradle-critique-01.md` with 9 embedded renders + walkthrough + feature-level critiques F1-F6 + 3 open questions.
- User inline-annotated: caught that `cradle-front.png` was pointing at user-back (wall-facing side) not user-front — "that's the fucking bottom of the thing." Also flagged supports-permitted policy needed, rigidity applies to whole design, 3D-swept tufts required, renders must show key features.
- Fixed in agent: added mandatory **Cycle 0 — Orient** step to both design and critique modes; brief schema gained `user_orientation` block + `hero_views` list; agent instructed to stop critique if renders don't match user orientation.
- Dispatched modeler subagent to re-render; failed on 2000px image-context limit. Fell back to direct `cli-anything-openscad` Bash calls; produced 6 user-oriented views for cradle + tray. Discovered cli-anything-openscad's `back` preset (`0,0,0,0,0,180,0`) has a rotation-math issue — for the cradle it worked (front-elevation) but for the tray it rendered top-down. Tray head-on still dialing in (multiple attempts with 7-tuple and eye-center formats — face visible but embosses not legible at auto-fit distance).
- Wrote lesson entry at `_id-library/lessons.md` (2026-04-18 — establish user orientation before critiquing; print-frame ≠ user-frame).

## Decisions & Trade-offs
| Decision | Rationale |
|---|---|
| Single `id-designer` agent with two modes vs. separate `id-designer` + `id-reviewer` | User wants one agent usable in-flow and out-of-flow; mode detection from inputs is clean; can split later if critique mode grows its own concerns. |
| Human-in-the-loop image gen for v1, no API integration | Ships today; user picks their preferred tool (MJ, Vizcom, Krea); upgrade to Flux Kontext API is v2 once UX is proven. |
| Library collaboration: agent proposes, user approves every promotion | Preserves user taste; prevents library drift; library maintained at project-end, not during. |
| Brief is authoritative for aesthetics, spec for function | Clean role boundary; modeler reads both; conflicts route back to orchestrator instead of silent adaptation. |
| Supports-permitted policy via brief declaration (not default-on) | Keeps print-reviewer strict by default; opt-in per-feature via `supports_permitted` list; test-print-planner surfaces slicer setup. |
| Rendering fallback to direct Bash over modeler subagent | Modeler subagent hit image-context limit; direct `cli-anything-openscad` calls are faster and don't pollute a subagent's context. |
| Preserve wrong-face critique in the vault note (with `> [!error]` callouts) instead of deleting | Transparency about the failure mode; becomes teaching material for the next critique. |
| Field-test critique on already-shipped design | Zero-cost validation of the agent loop; doesn't commit to re-modeling until user decides. |

## Key Learnings

- **Print-frame ≠ user-frame.** OpenSCAD render preset names (`front`, `rear`, `iso`) follow the mesh coordinate convention, not how the object is used. A cradle whose tray slides out the +Y side has its user-front on +Y, but OpenSCAD's "front" preset points at −Y. ID agent must establish user orientation as step zero of any critique or design work. Codified in the agent + lessons.md.
- **cli-anything-openscad's preset tuples are suspect.** The `back` preset (`0,0,0,0,0,180,0`) is mathematically a top-view with 180° roll, not a back-elevation. It happened to produce a legible front-elevation for the cradle (tall/complex shape dominates the projection) but a top-down for the tray (wide/flat). Followup: file issue upstream or build a per-design override in spec.json.
- **Conversational agent cannot be a subagent in the current architecture.** Subagents get one prompt → one result; they can't stream a multi-turn dialogue with the actual user. The `id-designer` must be embodied in the main orchestrator conversation or the pipeline needs a different dispatch primitive for long-running user-facing agents.
- **Wrong-face critique is a real failure mode.** The agent spent paragraphs analyzing the back-of-appliance face with confident language before the user caught it. The lesson isn't "be less confident" — it's "verify orientation before you start." Procedural fix beats tone adjustment.
- **Kindchenschema head:body = 1:1 is the cute-creature target**, not golden-ratio mysticism. Owl tufts must be wider than tall (current cradle inverts this). Eye axis at 60-65% of head height.
- **Hero render specification is load-bearing.** The ptouch-cradle shipped with its primary feature (the tray's owl face) not visible in any rendered view. If `requiresId: true`, `hero_views` in brief must be explicit and shipper must verify before shipping.

## Solutions & Fixes

- **Agent orientation discipline** → Added mandatory Cycle 0 — Orient to `.claude/agents/id-designer.md` for both design and critique modes. Brief schema gained `user_orientation` block + `hero_views` list with rationale per view.
- **Modeler subagent 2000px image-context failure** → Fell back to direct Bash invocation of `cli-anything-openscad`. Worked fine; no need to go through a subagent for render-only work.
- **Tray head-on render quirk** → Tried 7-tuple `0,0,0,90,0,180,0`, eye-center 6-tuple `51.6,344,10.8,51.6,94.2,10.8` — face appears but embosses too small at auto-fit distance. Three-quarter view (`iso-back` preset) renders the owl face correctly so critique proceeded on that. Proper head-on framing deferred as a followup.
- **Critique note integrity after orientation discovery** → Did not delete the wrong-face walkthrough; wrapped each wrong section in `> [!error]` callouts with notes on what was wrong. Added refreshed walkthrough with the 6 new user-frame renders below it. Preserves teaching value.

## Files Modified

**New files:**
- `/workspace/projects/3d-printing/.claude/agents/id-designer.md` — agent definition (two modes)
- `/workspace/projects/3d-printing/designs/_id-library/README.md` — library structure + rules
- `/workspace/projects/3d-printing/designs/_id-library/lessons.md` — lessons index (first entry: user-orientation)
- `/workspace/projects/3d-printing/designs/_id-library/families/.gitkeep`
- `/workspace/projects/3d-printing/designs/_id-library/references/.gitkeep`
- `/workspace/projects/3d-printing/designs/ptouch-cradle/id/conversation-log.md` — critique round 1 dialogue
- `/workspace/projects/3d-printing/designs/ptouch-cradle/output/cradle-user-{front,front-threequarter,left,top-threequarter}.png` — user-frame renders
- `/workspace/projects/3d-printing/designs/ptouch-cradle/output/tray-user-{front,front-threequarter}.png` — user-frame renders
- `/workspace/projects/obsidian-vault/vault/projects/3d-printing/id-agent-proposal.md` — research + proposal
- `/workspace/projects/obsidian-vault/vault/projects/3d-printing/ptouch-cradle-critique-01.md` — inline-commentable review note
- `/workspace/projects/obsidian-vault/vault/projects/3d-printing/attachments/ptouch-cradle-critique-01/*.png` — review attachments (original + user-frame renders)

**Updated:**
- `/workspace/projects/3d-printing/.claude/agents/spec-writer.md` — added `requiresId` field + triggers
- `/workspace/projects/3d-printing/.claude/agents/modeler.md` — reads `id/brief.md` and `id/modeler-notes-v<n>.md`
- `/workspace/projects/3d-printing/AGENT-WORKFLOW.md` — ID stage + user-gated critique stage + output dir schema
- `/workspace/projects/3d-printing/CLAUDE.md` — quick-ref + conventions for id/ dir and library
- `/workspace/projects/obsidian-vault/vault/projects/3d-printing.md` — log entries + next-action update

## Follow-ups

- [ ] Fix tray head-on render camera — currently face is visible but owl embosses too small to read. Try explicit eye-center camera with fixed distance + tight aspect ratio (e.g. 1400x500), or investigate cli-anything-openscad preset math upstream.
- [ ] Resume critique round 1 on [[ptouch-cradle]] — user still needs to answer Q1 (subtle vs harder commit), Q2 (any fixes to cut/flip), Q3 (is F6 owl-face in this round's scope). Once answered, write `id/brief.md` (minimal in-session brief) + `id/modeler-notes-v1.md` (concrete fix list).
- [ ] Propose `quietly-playful-soft` as the first aesthetic family for the library once ptouch-cradle re-modeling lands.
- [ ] File issue or patch upstream: `cli-anything-openscad` preset `back` rotation is mathematically wrong for some geometry aspect ratios (behaves differently for cradle vs tray).
- [ ] Project-level P1: implement `hero_views` in spec.json + shipper verification so designs can't ship without their intentional face rendered.
- [ ] Project-level P2: implement `supports_permitted` signal in brief → print-reviewer downgrades FAIL to INFO for listed features; test-print-planner surfaces slicer setup.
- [ ] Consider splitting id-designer into `id-designer` + `id-reviewer` (read-only machine checklist) if the critique mode outgrows the single-agent design.
- [ ] Dispatch primitive question: the pipeline currently assumes fire-and-forget subagents. The conversational id-designer can't ride that — it had to be embodied in the main conversation. Think about whether the pipeline needs a "long-running user-facing agent" primitive or whether main-conversation-embodiment is the right pattern.

## Errors & Workarounds

- **Modeler subagent failed with "image in conversation exceeds 2000px dimension limit"** after 23 minutes of running. Root cause: subagent ingested existing renders while trying to work out camera angles. Workaround: skipped subagent, called `cli-anything-openscad` directly via Bash. Took ~30s vs 23+ min. For render-only tasks, don't dispatch a subagent.
- **cli-anything-openscad preset inconsistency:** `back` (`0,0,0,0,0,180,0`) produced a correct front-elevation for the 108×255×180 cradle but a top-down for the 103×94×22 tray. Hypothesis: auto-fit distance behavior differs with extreme aspect ratios. Workaround for tray: used 7-tuple `0,0,0,90,0,180,0` and then 6-tuple eye-center; both showed the +Y face head-on but at auto-fit distance the owl embosses are too small to read. Deferred as followup; three-quarter view carries the face analysis for now.
- **AskUserQuestion max 4 options** — initial call failed with 5+ options. Rewrote the question to 3 bundled options.
- **Initial Edit on id-designer brief schema failed** — tried to match on triple-backtick YAML block but the file uses spaced-backtick ` ` ` to prevent nested rendering. Resolved by grepping for the anchor string and matching on the actual encoding.

## Raw Session Log

(Raw conversation archive omitted to keep this log tight; full transcript available in the session; key turns and tool calls are captured in the structured sections above. Re-hydrate context via /resume if needed.)
