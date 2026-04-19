# Multi-Agent Workflow

This project uses specialized agents to manage context across complex design tasks. Each agent has a focused role, its own context window, and communicates through structured files — not conversation history.

## When to use agents

| Complexity | Criteria | Pipeline |
|---|---|---|
| **Simple** | Single part, ≤5 features, no assembly | `spec-writer` → `modeler` (with inline print check) → `shipper` |
| **Medium** | Single part, >5 features | `spec-writer` → [`id-designer`*] → `modeler` → `geometry-analyzer` → `print-reviewer` → `test-print-planner` → `modeler` (test pieces) → `shipper` |
| **Complex** | Multi-part assembly | `spec-writer` → [`id-designer`*] → `modeler` (per part, parallel) → `geometry-analyzer` (per part, parallel) → `print-reviewer` + `fit-reviewer` (parallel) → `test-print-planner` → `modeler` (test pieces, parallel) → `shipper` |

*`id-designer` runs when `spec.json` has `requiresId: true` — i.e. designs with a face, motif, or visible placement. Skipped for utility parts (brackets, adapters, internal components). See rule 2 below.

## Agent dispatch rules

1. **Spec stage:** Dispatch `spec-writer`. Wait for `requirements.md` + `spec.json` before proceeding.
2. **ID stage (conditional):** If `spec.json` has `requiresId: true`, dispatch `id-designer`. **This is the pipeline's only conversational agent** — it runs a multi-turn mockup-dial-in loop with the user and returns when the user locks the brief. Output is `designs/<name>/id/brief.md` + pinned reference images. For multi-part assemblies, one brief covers the family. Skip if `requiresId: false`. See `.claude/agents/id-designer.md` and `designs/_id-library/README.md`.
3. **Model stage:** Dispatch `modeler` with the design directory path. The modeler reads `spec.json` AND `id/brief.md` (if present). The brief is authoritative for aesthetics; the spec is authoritative for function. For multi-part assemblies, dispatch one modeler per part in parallel. Wait for all to report PASS.
4. **Geometry stage:** Dispatch `geometry-analyzer` per part (parallel for multi-part). Produces `geometry-report.json` (mesh analysis) and `slicer-report.json` (PrusaSlicer G-code analysis, if slicer is installed). These are ground-truth geometry data for the reviewer.
5. **Review stage:** Dispatch `print-reviewer` and (if multi-part) `fit-reviewer` in parallel. The print-reviewer now reads quantitative geometry data from the analyzer, not SCAD source. Both are read-only. If either reports FAIL, dispatch `modeler` with the specific fix instructions, re-run geometry analysis, then re-review.
6. **ID critique stage (user-initiated, can repeat):** After render + review — or any time the user looks at renders and wants to iterate aesthetics — dispatch `id-designer` in **critique mode** with the render paths. The agent reads `id/brief.md` + `output/*.png` + `review-printability.md`, runs a critique dialogue, and emits `id/modeler-notes-v<n>.md` plus amendments to the brief's Revisions section. Orchestrator then re-dispatches `modeler` with the fix notes, re-runs geometry + review, and loops. This stage is optional, user-gated, and can run as many rounds as needed. It is also valid **out of flow** — the user can ping `id-designer` directly with render paths to run critique mode without going through the orchestrator.

7. **Test print stage (optional):** Dispatch `test-print-planner` once all reviews pass. It reads the finalized reports, consumes upstream flags (`spec.json` → `testPrintCandidates`, `review-printability.md` → Test Print Recommendations), and produces `test-prints.json` + stub design directories. Then dispatch `modeler` for each test print (parallel). Test prints go through lightweight validation only (render + dimension check), not the full review pipeline. The orchestrator may skip this stage for simple parts or if the user opts out.
8. **Ship stage:** Dispatch `shipper` once all reviews and test prints are complete. For designs that went through the ID stage, the orchestrator should also prompt the user for library-promotion approvals (new family / references / lessons) before shipping — `id-designer` proposes, user decides.

## Orchestrator responsibilities

The top-level conversation (you, reading this) is the **orchestrator**. You:
- Manage the user dialogue — questions, decisions, design intent
- Dispatch agents and read their **summaries** (not full reports)
- Make go/no-go decisions between stages
- Never hold full SCAD source, review arithmetic, or validation output in your context — that's what the agents are for

## Inter-agent communication

Agents communicate through files in `designs/<name>/`:
```
designs/<name>/
├── requirements.md           ← spec-writer output
├── spec.json                 ← spec-writer output (includes requiresId flag)
├── id/                       ← id-designer output (only if requiresId: true)
│   ├── brief.md              ← authoritative aesthetic spec; appended with Revisions as critiques land
│   ├── moodboard/            ← pinned reference images (design mode)
│   ├── mockups/              ← design-mode iteration history
│   ├── modeler-notes-v*.md   ← per-round critique → modeler fix list
│   ├── critique-v*/          ← optional reaction mockups per critique round
│   └── conversation-log.md   ← dialogue snapshot across all modes and rounds
├── <name>.scad               ← modeler output
├── output/
│   ├── modeling-report.json  ← modeler output (dims + feature inventory)
│   ├── geometry-report.json  ← geometry-analyzer output (mesh analysis)
│   ├── slicer-report.json    ← geometry-analyzer output (PrusaSlicer analysis)
│   ├── validation-report.json ← pipeline output
│   ├── review-printability.md ← print-reviewer output (verbose)
│   ├── review-fitment.json   ← fit-reviewer output
│   ├── test-prints.json      ← test-print-planner output (manifest)
│   ├── *.stl, *.png          ← rendered artifacts
│   └── iterations/           ← round-by-round history
├── test-prints/              ← test print designs (planner + modeler output)
│   ├── <id>/
│   │   ├── requirements.md   ← test-print-planner output
│   │   ├── spec.json         ← test-print-planner output
│   │   ├── <id>.scad         ← modeler output
│   │   └── output/           ← rendered test piece artifacts
```
