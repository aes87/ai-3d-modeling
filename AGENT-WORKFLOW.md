# Multi-Agent Workflow

This project uses specialized agents to manage context across complex design tasks. Each agent has a focused role, its own context window, and communicates through structured files — not conversation history.

## When to use agents

| Complexity | Criteria | Pipeline |
|---|---|---|
| **Simple** | Single part, ≤5 features, no assembly | `spec-writer` → `modeler` (with inline print check) → `shipper` |
| **Medium** | Single part, >5 features | `spec-writer` → `modeler` → `geometry-analyzer` → `print-reviewer` → `test-print-planner` → `modeler` (test pieces) → `shipper` |
| **Complex** | Multi-part assembly | `spec-writer` → `modeler` (per part, parallel) → `geometry-analyzer` (per part, parallel) → `print-reviewer` + `fit-reviewer` (parallel) → `test-print-planner` → `modeler` (test pieces, parallel) → `shipper` |

## Agent dispatch rules

1. **Spec stage:** Dispatch `spec-writer`. Wait for `requirements.md` + `spec.json` before proceeding.
2. **Model stage:** Dispatch `modeler` with the design directory path. For multi-part assemblies, dispatch one modeler per part in parallel. Wait for all to report PASS.
3. **Geometry stage:** Dispatch `geometry-analyzer` per part (parallel for multi-part). Produces `geometry-report.json` (mesh analysis) and `slicer-report.json` (PrusaSlicer G-code analysis, if slicer is installed). These are ground-truth geometry data for the reviewer.
4. **Review stage:** Dispatch `print-reviewer` and (if multi-part) `fit-reviewer` in parallel. The print-reviewer now reads quantitative geometry data from the analyzer, not SCAD source. Both are read-only. If either reports FAIL, dispatch `modeler` with the specific fix instructions, re-run geometry analysis, then re-review.
5. **Test print stage (optional):** Dispatch `test-print-planner` once all reviews pass. It reads the finalized reports, consumes upstream flags (`spec.json` → `testPrintCandidates`, `review-printability.md` → Test Print Recommendations), and produces `test-prints.json` + stub design directories. Then dispatch `modeler` for each test print (parallel). Test prints go through lightweight validation only (render + dimension check), not the full review pipeline. The orchestrator may skip this stage for simple parts or if the user opts out.
6. **Ship stage:** Dispatch `shipper` once all reviews and test prints are complete.

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
├── spec.json                 ← spec-writer output
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
