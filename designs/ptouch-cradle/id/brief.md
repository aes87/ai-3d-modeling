# ptouch-cradle ID Brief

## Intent

Quiet desk dock for the Brother PT-P750W. Function and frame, nothing more. Clean smooth lines, generous radii, no decoration. The printer is the visual subject; the cradle is the supporting frame that holds it and catches the labels.

Owl direction abandoned at end of round 2. The previous Revisions entries below preserve the path that got us here.

## Spec

```yaml
user_orientation:
  user_front: "+Y face"
  user_back:  "-Y face"
  user_left:  "-X face"
  user_right: "+X face"
  user_top:   "+Z face"
  use_context: "sits on a desk; printer occupies the pocket; user approaches from +Y"
  hero_face:  "user-front (clean utility frame around the printer body, tray in front)"
  against_surface: "user-back (-Y) carries cable notch only"
use_state:
  host_object: "Brother PT-P750W printer"
  host_envelope_mm: {x: 78, y: 152, z: 143}
  host_installed_position: "in printer pocket: centered with 1mm XY clearance and 2mm Z clearance"
  visible_zone_after_install: "all 4 cradle perimeter walls (25mm low) and tray are visible around the printer base; printer body dominates the silhouette above z=25"
  composition_metaphor: "printer perched in a quiet rectangular tray with a label catch in front. The cradle does not compete with the printer; the printer is the visual subject."
hero_views:
  - name: cradle-user-front-in-use
    rationale: "PRIMARY hero — printer installed, low cradle frame visible around base, tray in front. The 'is it quiet enough?' check."
    requires_proxy: true
  - name: cradle-user-front-threequarter-in-use
    rationale: "marketing shot — printer installed, low frame + tray + foot blend all visible together"
    requires_proxy: true
  - name: cradle-user-front
    rationale: "bare-part record"
    requires_proxy: false
  - name: cradle-user-front-threequarter
    rationale: "bare-part record showing fillet schedule landing"
    requires_proxy: false
  - name: cradle-user-top-threequarter
    rationale: "top-down view — confirms full-perimeter symmetry of the low bathtub"
    requires_proxy: false
  - name: tray-user-front
    rationale: "tray scoop + integrated finger-grip — clean utility face"
    requires_proxy: false
  - name: tray-user-front-threequarter
    rationale: "tray proportion + integrated finger-grip visibility"
    requires_proxy: false
hero_dimension:
  name: low_wall_height
  value_mm: 25
  rationale: "the wall height defines the form. Equal on all four sides. The cradle reads as a quiet symmetric tray. Every other dim should defer to this — there's nothing taller than 25mm of cradle anywhere."
proportions:
  wall_uniformity: "all 4 cradle perimeter walls = 25mm. NO tall back panel. NO asymmetry."
  wall_thickness: "3mm uniform on all perimeter walls; tray walls 1.6mm uniform"
  fillet_consistency: "every transition is a fillet. NO chamfers. NO sharp edges except where structurally required (e.g. interior printer-pocket walls)."
  tray_subordination: "tray reads as a smaller continuation of the same form language as the cradle"
fillet_schedule:
  utility: 3.0   # all top edges, all visible vertical edges, tray edges
  hero: 10.0     # printer-section → shelf transition (concave); base plate corners
features:
  primary:
    - low symmetric perimeter walls (25mm × full perimeter, uniform)
    - generous fillet schedule applied without exception
    - tray scoop lip + integrated finger-grip
  secondary:
    - printer-section → shelf concave fillet (the one sculptural move that earns its keep)
    - base plate corner radius softening the footprint
    - foot-to-plate upper blend (continues curvature down to the desk)
  tertiary: []
decoration_policy:
  - feature: any_face_or_creature_geometry
    mode: REMOVED
    rationale: "owl direction abandoned end of round 2. No face, no eyes, no beak, no tufts. Pure utility-as-form."
  - feature: feather_embosses
    mode: REMOVED
    rationale: "previously removed in round 1; stays removed"
  - feature: convex_panel_face
    mode: REMOVED
    rationale: "no panel exists in v3. Walls are flat planes with filleted edges."
  - feature: tall_back_panel
    mode: REMOVED
    rationale: "back wall drops from 205mm to 25mm to match the other 3 perimeter walls. No retaining-wall function needed; no aesthetic function wanted."
  - feature: tray_scoop_lip
    mode: intrinsic
    rationale: "functional, not decorative — only sculpted feature on the tray"
species_cues: []
anti_brief:
  - not a creature, not a mascot, not cute, not playful
  - not decorated, not embellished, not adorned, not themed
  - not asymmetric: bathtub is full-perimeter symmetric (modulo the cable notch)
  - not slab-sided BUT clean flat planes with generous fillets, NOT tall imposing walls
  - no logo, no text, no emboss, no deboss
  - no convexity, no recess, no surface treatment beyond fillets
  - nothing suggests an animal, a face, or a thematic reference of any kind
supports_permitted: []
print_orientation:
  cradle: "base down, walls vertical. No supports needed (low walls, no overhangs above 45°)."
  tray: "face up (open top), back on bed. Scoop lip 45° face prints as overhang at threshold (printable, no supports)."
  seam_hidden_on: "underside of base plate; user-back (-Y) wall exterior (where the cable notch lives)"
references:
  family_candidate: _id-library/families/quiet-utility.md  # candidate post-ship if this direction lands
```

## Form language

Two rules govern every surface:

**1. Function defines form. Nothing else.** The walls exist to hold the printer in its pocket. The base plate exists to keep the object stable. The feet exist to lift the base off the desk. The tray exists to catch labels with a scoop for retrieval. Each form is exactly the size and shape its function requires — no taller, no thicker, no more sculpted.

**2. Every transition is a fillet, never a chamfer or sharp edge.** Where two surfaces meet, they meet via a continuous curve. The radius schedule has just two values: r=3 for break-edges and utility transitions, r=10 for hero transitions (the printer-section → shelf concave, the base plate corners). Wherever a fillet can be applied without compromising function, apply it. The form language is "soft, smooth, continuous" — like a river-stone version of utility.

**No decoration of any kind.** No embosses, no debosses, no convexity, no recesses, no creature cues, no logos, no text, no surface treatment whatsoever beyond the fillet schedule. If a feature isn't load-bearing for function, it's not there. If a feature isn't fundamental to form (the fillets), it's not there.

**The printer is the subject.** When installed, the printer stands 143mm tall above a 25mm low cradle. The visual mass of the object is the printer itself, in white plastic, with the small Brother logo and tape-out slot. The cradle frames it without competing — it should be barely noticeable in a use-state photo, doing its work invisibly.

## Feature-by-feature rationale

### Low symmetric perimeter walls (primary)

All four cradle perimeter walls = 25mm tall, 3mm thick. No tall back panel. The −Y back wall, +Y front wall (where the wall transitions into the tray slot), and ±X side walls are all the same height. The cradle reads as a clean rectangular tray that the printer drops into.

The cable notch on the −Y back wall remains: 25×20mm U-shape at z=0-20, occupying the bottom 80% of the wall height. This is the only interruption to the wall's smooth top edge.

**Must NOT look like:** a tall back panel. A picture frame. A retaining wall. Anything that wants to be the visual focus.

### Generous fillet schedule (primary)

Two named radii applied without exception:

- **r=3 (utility):** all top edges of the 25mm perimeter walls; all visible vertical wall corners; all tray edges; all break-edges.
- **r=10 (hero):** the printer-section → shelf concave fillet; base-plate corner radius (top and bottom of plate, all four corners).

Wall thickness uniform 3mm on cradle perimeter walls. Tray walls uniform 1.6mm.

**Must NOT look like:** any sharp edges, any chamfered edges, any inconsistent radii. If any visible edge in the model is at a different radius than r=3 or r=10, it should have a documented structural reason (e.g., interior printer-pocket walls stay sharp because they're hidden when the printer is installed and a fillet would reduce pocket clearance).

### Tray scoop lip + integrated finger-grip (primary)

Unchanged from v2. 45° scoop across upper 14mm of front wall, lower 7mm vertical, central 30mm concave finger-grip dip 2.5mm deep. This is the single sculpted move on the tray and it earns its keep functionally. Leading edge r=2mm.

**Must NOT look like:** anything other than what it is now in v2.

### Printer-section → shelf concave fillet (secondary)

r=10 concave fillet sweep on both ±X sides where the 86mm printer section transitions to the 108mm shelf section. The one sculptural move on the cradle proper. (Slight bump from v2's r=8 to align with the new hero-tier radius.)

### Base plate corners (secondary)

r=10 corner fillet on all 4 corners of the base plate (top and bottom). Reads as a softly filleted footprint. (Bump from v2's r=8 to consolidate hero radii at r=10.)

### Foot-to-plate upper blend (secondary)

Foot-to-plate r=1.5mm concave fillet on the upper meeting edge (foot bottom stays flat for first-layer adhesion). Continues the curvature language to the desk surface. Unchanged from v2.

### Removed features (full list — what v3 does NOT have)

- Tall back panel (height 145/205mm) — gone, replaced with 25mm wall.
- Heart-shaped facial disc — gone.
- Recessed eye sockets — gone.
- Asymmetric hooked beak — gone.
- Ear tufts (any construction — swept, hulled, splayed) — gone.
- Convex panel face — gone (no panel exists).
- Feather embosses — already removed in round 1.
- Tray face (eyes/pupils/beak) — already removed in round 1.
- Host_object_proxy module — KEEP as render-only utility (still useful for use-state renders).
- Render-with-host parameter — KEEP for the same reason.

## Modeler notes

See `id/modeler-notes-v3.md` for the concrete fix list. Most fixes are deletion.

**Non-negotiables:**
- All four cradle perimeter walls = 25mm uniform. The −Y wall is NOT taller than the other three.
- No face, no creature features, no decoration of any kind. Anywhere.
- Two-tier fillet schedule (r=3 utility, r=10 hero) applied throughout. No chamfers anywhere. No mid-tier radii.
- The host_object_proxy module survives — use-state renders are still required.

**Seam hiding:** underside of base plate; user-back (-Y) wall exterior (where the cable notch lives).

**Print orientation:** cradle base down, walls vertical. No supports needed at any feature.

## Revisions

### 2026-04-19 — round 1 (ad-hoc critique, pre-modeling)

**Trigger:** User dispatched critique mode ad-hoc on shipped ptouch-cradle v2 (commit `90dd34a`). Initial critique ran on wrong faces due to print-frame vs user-frame orientation gap; agent updated with mandatory Cycle 0 — Orient and brief schema gained `user_orientation` + `hero_views`. Refreshed critique on user-oriented renders surfaced whole-object rigidity + motif incoherence (two half-owls) + hierarchy inversion. User elected harder commit + F6 in scope + radical reimagining permitted + scoop lip restoration required.

**Changes from shipped v2:**
- Motif consolidated: owl moves from tray to back panel. Tray face (eyes, pupils, beak) deleted.
- Back panel: slab → sculptural owl body. Rounded top, softened vertical edges (r=4), gently convex +Y face (1-2mm at center), intrinsic facial disc recess at ~62% height carrying eyes and 3D beak.
- Ear tufts: inverted proportion (w > h), 25-30° outward tilt, 3D sweep, feathery silhouette, r=5 base blend.
- Printer-section → shelf: 45° chamfer replaced with r=8-10 concave fillet.
- Feather embosses on printer-section side walls: removed.
- Tray scoop lip restored, rebalanced for 21.6mm wall (upper 14mm at 45°, lower 7mm vertical), with integrated concave finger-grip in center — grip scallop not restored as separate feature.
- Base plate corner r=6 → r=8, foot-to-plate r=1.5 fillet added.
- `hero_views` declared in user-frame terms; `supports_permitted` list declared for tufts, facial disc rim, beak apex.

**Modeler fix list:** see `id/modeler-notes-v1.md`.

### 2026-04-20 — round 1 post-mortem (brief declared stale)

**Trigger:** Round 1 geometry built and rendered per `modeler-notes-v1.md`. User reviewed renders on GitHub commit `5772f81`. Reaction: **"The horror."** User identified a blocking issue the agent missed: the facial disc at z=90 is **behind the printer** when installed. Printer is 143mm tall; panel is 145mm tall; only ~2mm of panel is visible above the printer. The face that round 1 carved, critiqued, and shipped-as-STL is invisible in actual use.

**Root cause:** all round-1 hero renders were bare-geometry (no printer proxy in the pocket). The agent never rendered or critiqued the use-state, so the occlusion was invisible to the critique.

**Direction correction:** facial features relocate from z=90 to the visible strip above the printer at z=143+. Back panel grows 145 → 205mm. R2 real-owl anatomy (heart-shaped disc, recessed eye sockets, no pupils, asymmetric hooked beak, splayed feather tufts with no forward sweep). New host_object_proxy + use-state render requirement.

**Codified lesson:** `_id-library/lessons.md` — "Render the use-state, not just the part." Cycle 0 of `.claude/agents/id-designer.md` extended with a mandatory use-state check.

### 2026-04-25 — round 2 (direction locked, brief spec block updated)

**Trigger:** User confirmed the post-mortem direction. Brief's main spec block updated to v2 values; Form-language and feature-by-feature sections rewritten for the new face placement and tuft construction.

**Spec-block changes:**
- `hero_dimension`: back_panel_height 145 → 205 mm.
- `proportions`: rebuilt around face zone (z=143-205), tuft outward lean only, hull-of-3-feathers construction.
- `use_state` block added.
- `hero_views`: two new in-use renders (`cradle-user-front-in-use`, `cradle-user-front-threequarter-in-use`).

**Modeler fix list:** see `id/modeler-notes-v2.md`.

### 2026-04-25 — round 2 post-mortem + round 3 pivot (owl direction abandoned)

**Trigger:** Round 2 geometry built per `modeler-notes-v2.md`. User reviewed on GitHub commit `b931983`. Structural fix landed (face is visible above the printer in `cradle-user-front-in-use.png`, round-1 invisibility failure dead). But the creature read shifted from "uncanny owl" to "happy panda / teddy bear":
- Hull-of-3-feathers tufts smoothed into rounded mammalian-ear blobs (smooth-blob risk modeler flagged).
- Eye recess at 1.5mm read as small dark patches rather than deep elongated owl eyes.
- Beak too small to register against the disc.

Agent proposed round 3 (tufts only / tufts+face polish / reshape head silhouette).

**User abandoned the owl direction entirely.** "I want to abandon the owl-embellished branch. This is decent but I don't want it. Please work on a V3 that just strives for minimalism, great functionality, and clean smooth lines and rounds."

**Structural decision (user):** back panel goes LOW. All 4 cradle perimeter walls drop to 25mm — symmetric bathtub. "The printer isn't going to tip, the backwall is not useful."

**v3 direction (this brief above):** quiet Muji-Rams desk dock. No face, no tufts, no decoration of any kind. Two-tier fillet schedule (r=3 utility, r=10 hero) applied without exception. The printer is the visual subject; the cradle is supporting frame.

**Spec-block changes (this brief above replaces v1+v2 main body):**
- `hero_dimension`: back_panel_height 205 → low_wall_height 25mm. Hero is the wall height, not a panel.
- `proportions`: completely rewritten for symmetry + fillet consistency. Owl-specific entries (face zone, eye axis, tuft aspect/tilt/construction) all deleted.
- `fillet_schedule`: collapsed from 3 tiers to 2 (r=3 utility, r=10 hero).
- `features`: primary list rebuilt (low walls + fillet schedule + tray scoop). All owl features deleted.
- `decoration_policy`: every entry now `mode: REMOVED` except tray scoop lip.
- `species_cues`: emptied.
- `anti_brief`: rewritten for minimalism (not creature, not mascot, not cute, not decorated, not themed, not asymmetric).
- `supports_permitted`: emptied (no overhang features remain).
- `composition_metaphor`: changed from "owl head perched above printer body" to "printer perched in a quiet rectangular tray with a label catch in front."

**Form-language and feature-by-feature sections:** fully rewritten for v3 minimalism.

**Unchanged from round 2 (carries forward):**
- Two-part architecture; stepped body (86mm printer section → 108mm shelf section); printer pocket dims and clearances; cable notch on −Y wall at z=0-20; tray interior 100×91×40mm; tray walls 1.6mm; tray exterior 103.2×94.2×21.6mm; tray-to-slot sliding fit 0.35mm/side; 4 cylindrical feet d=8 × h=3 with upper r=1.5 fillet; tray scoop lip + integrated finger-grip (45° upper 14mm + vertical lower 7mm + 30mm concave finger-grip dip); printer→shelf concave fillet (r=8 → r=10); host_object_proxy module + render_with_host parameter.

**Removed in round 3 (everything owl):**
- Tall back panel (205mm height) → replaced with 25mm low wall.
- Heart-shaped facial disc, recessed eye sockets, asymmetric hooked beak — all gone.
- Ear tufts (any construction) — gone.
- Convex panel face — gone (no panel exists).
- All face/tuft spec params (eye_*, beak_*, tuft_*, face_disc_*, panel_convexity, etc.) — gone.

**Modeler fix list:** see `id/modeler-notes-v3.md`.
