# ID Library

Shared industrial-design reference material. The `id-designer` agent reads from this library at the start of a project (to find relevant precedents) and proposes additions at the end (for user review). You and the agent maintain it collaboratively — the agent never writes here without explicit user approval.

## Structure

```
_id-library/
├── README.md          ← this file
├── families/          ← aesthetic families, one .md per family
├── references/        ← individual reference images, each with a sidecar .md
└── lessons.md         ← running log of what worked / what didn't
```

### `families/`

A file per coherent aesthetic family (e.g. `muji-restrained.md`, `owl-creature.md`, `teenage-engineering-playful.md`). Each file contains:

- Short description of the language
- Defining moves (form, fillet, surface, color, motif rules)
- Pinned reference images (by path into `references/`)
- Anti-brief (what this family is NOT)
- Designs that have used this family (linked)

### `references/`

One subdirectory per reference, slug-named:

```
references/
└── <slug>/
    ├── image.<ext>
    └── meta.md        ← source, tags, why it's here, designs that used it
```

`meta.md` format:

```markdown
---
source: "Midjourney / user photo / product page URL / etc."
tags: [muji, soft-rectangle, matte-polymer]
families: [muji-restrained]
used-in: [ptouch-cradle]
---

Why this reference is in the library: <one paragraph>
```

### `lessons.md`

A dated, single-file log of ID lessons extracted from projects. Short entries, Rams-checklist-adjacent. See the file itself for current format.

## Maintenance rules

- **User approves every promotion.** The agent proposes; the user says yes/no/amend.
- **Per-project context stays per-project** unless it's genuinely reusable. Don't promote every moodboard image.
- **Promote at project-end, not during.** The dial-in loop for an active design uses `designs/<name>/id/`. Promotion happens after ship, when we know what actually held up.
- **Prune on contradiction.** If a lesson turns out to be wrong, remove or amend — don't accumulate.
- **Keep references under 1MB each** when possible — compress PNGs, scale down. The library should be lightweight enough to stay in git.
