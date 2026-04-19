# ID Lessons

Short, dated entries. What worked, what didn't, what to check for next time. Extracted from shipped designs during end-of-project review.

---

## 2026-04-18 — [[ptouch-cradle]] — Establish user orientation before critiquing; print-frame ≠ user-frame

**Context:** First run of `id-designer` in critique mode. Agent loaded the default render set (`cradle-front.png`, `cradle-iso.png`, `cradle-rear-iso.png`) and ran the silhouette test on the "front" preset.

**What happened:** `cradle-front.png` pointed at the −Y face — the back-of-appliance / against-the-wall side. `cradle-rear-iso.png` was actually closer to the user-facing three-quarter angle. The agent wrote confident paragraphs about the wrong faces before the user caught the error in inline comments.

**Lesson:** The modeler's OpenSCAD preset names (`front`, `rear`, `iso`, `top`) follow the print-frame coordinate convention. They may or may not align with the user-frame (which face a customer looks at in use). For many designs these coincide; for many they don't. An owl-face tray that slides into the +Y end of a cradle makes +Y the user-front — but OpenSCAD's "front" camera still points at −Y.

**Check for:** Before any aesthetic analysis — design-mode or critique-mode — establish and declare the user orientation explicitly:

- `user_front`: which face the customer looks at in normal use
- `user_back`: often against-the-wall or hidden
- `user_left`, `user_right`, `user_top`: for full frame
- `hero_face`: which face carries the primary visual feature
- `against_surface`: the hidden face, if any

This goes into `id/brief.md` as a `user_orientation` block, and drives a `hero_views` list that the modeler renders with user-oriented filenames (`user-front`, `user-front-threequarter`, not `front`/`iso`).

**If the renders don't match user orientation, stop the critique and request re-renders before proceeding.** Wrong-face analysis costs more time than a render pause.

Codified in `.claude/agents/id-designer.md` as a mandatory Cycle 0 — Orient step in both design and critique modes.
