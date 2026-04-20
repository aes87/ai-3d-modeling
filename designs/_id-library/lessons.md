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

---

## 2026-04-19 — [[ptouch-cradle]] — Render the use-state, not just the part

**Context:** Second run of `id-designer` in critique mode. Round 1 of ptouch-cradle placed the owl face on the back panel at z=90 (62% of the 145mm panel height). The modeler built it correctly, the renders looked correct, the agent critiqued confidently. The user took one look at the GitHub renders and said **"the horror."**

**What happened:** The cradle holds a Brother PT-P750W printer. The printer is 143mm tall. The back panel is 145mm tall. When the printer is installed — which is every second of this object's actual lifetime — **only 2mm of panel sits above the printer.** The facial disc at z=90 is completely behind the printer body. The face that the agent designed, critiqued, and recommended shipping was invisible in actual use. It would have printed correctly and shipped invisible.

Every render the agent worked from was a bare-geometry render (no printer in the pocket). The invisibility-in-use never registered because the host object was never in frame.

**Lesson:** If the design **holds, cradles, docks, carries, or otherwise interacts with another object**, at least one hero render must show that object installed in its use position. The silhouette test, the feature-legibility check, the hierarchy read — they all run against the *use-state* render, not the bare-part render. The bare-part render is a modeling validation artifact; it is not the view a customer experiences.

**What counts as a "host object":** printers, phones, tablets, books, pots/planters, cables, cameras, tools, bottles, USB devices, laptops, anything the user puts IN or ON the printed object. If the spec has a `pocket`, `slot`, `cradle`, `dock`, `holder`, `stand`, `mount`, `sleeve`, or `bracket`, there's a host object.

**Check for:**

1. **At brief time:** inspect the spec for host-object dimensions (`printer_w/d/h`, `phone_*`, etc.). If present, the brief's `hero_views` list must include at least one view with a **proxy block** of the host object's dimensions placed in its installed position. Name it `<part>-user-front-in-use.png` or similar.

2. **At modeler dispatch:** instruct the modeler to render the use-state view explicitly. Give the proxy-block dimensions and installed position. The modeler adds a `host_object_proxy` module to the SCAD that can be toggled via a flag — rendered in PNG, excluded from the STL.

3. **At critique time:** **do the silhouette test on the use-state render first.** If the primary visual feature isn't visible with the host object installed, that's a blocking issue — all feature-level critique must defer until placement is fixed.

4. **For multi-state objects** (tray pushed in vs pulled out; lid open vs closed): render each state as a separate hero view. The user will see all of them in the object's life; the critique must reckon with all of them.

**Blast radius of ignoring this:** the ptouch-cradle round 1 face would have shipped, printed fine, and been invisible for the entire life of the object. The user would have caught it on the first day of use (if not earlier), and the modeling cost of round 1 — the whole consolidation move, the back-panel rebuild, the facial-disc carve, the eye and beak geometry — would have been wasted. Detected at render-time via a use-state view, the cost is zero.

**Codification:** Cycle 0 — Orient in `.claude/agents/id-designer.md` extended to include a use-state check. The orientation step is no longer just "which face is user-front?" — it's also "what object sits in front of / inside / on this part in normal use, and what's still visible then?"
