# ptouch-cradle ID Brief

## Intent

Quiet desk companion. One owl, not two. Minimal where it can be, sculptural where it earns its keep. Muji-adjacent restraint with a small intrinsic creature cue, composed — not applied — so the object reads as deliberate rather than decorated.

## Spec

```yaml
user_orientation:
  user_front: "+Y face"
  user_back:  "-Y face"
  user_left:  "-X face"
  user_right: "+X face"
  user_top:   "+Z face"
  use_context: "sits on a desk, user-back is typically against a wall, user approaches from +Y"
  hero_face:  "user-front (panel face above printer + tufts)"
  against_surface: "user-back (-Y) with cable notch"
use_state:
  host_object: "Brother PT-P750W printer"
  host_envelope_mm: {x: 78, y: 152, z: 143}
  host_installed_position: "in printer pocket: x_center=15+39=54 from left exterior, y from pocket back; z=0..143"
  visible_zone_after_install: "back panel above z=143 (face zone), tufts above panel top, tray, base plate, low perimeter walls"
  composition_metaphor: "owl head perched above printer body — printer is not hidden behind a facade; it's part of the owl's silhouette as the body"
hero_views:
  - name: cradle-user-front-in-use
    rationale: "PRIMARY hero — silhouette test runs against this view; owl head visible above installed printer"
    requires_proxy: true
  - name: cradle-user-front-threequarter-in-use
    rationale: "marketing shot with printer installed — face anatomy + tuft splay + tray legible together"
    requires_proxy: true
  - name: cradle-user-front
    rationale: "bare-part record (modeling validation)"
    requires_proxy: false
  - name: cradle-user-front-threequarter
    rationale: "bare-part record (modeling validation)"
    requires_proxy: false
  - name: cradle-user-left
    rationale: "side profile, confirms vertical softening + face-zone above printer position"
    requires_proxy: false
  - name: tray-user-front
    rationale: "tray scoop + integrated finger-grip — clean utility face"
    requires_proxy: false
  - name: tray-user-front-threequarter
    rationale: "tray proportion + integrated finger-grip visibility"
    requires_proxy: false
hero_dimension:
  name: back_panel_height
  value_mm: 205
  rationale: "panel height set so that ~62mm sits visible above the 143mm printer — the face zone. Hero dim is the panel because it carries the owl read; everything else should feel like a share of it."
proportions:
  face_zone: "z=143..205 — the visible-above-printer strip where all face anatomy lives"
  face_zone_aspect: "62mm tall × 86mm wide (panel width) — wider-than-tall, suits a barn-owl facial disc"
  face_disc_to_face_zone: "~85% width × ~85% height — disc fills most of the visible panel without cramping"
  eye_axis_height_within_face_zone: "0.62 of face zone height — eyes high in the disc per real owl anatomy"
  beak_axis_height_within_face_zone: "0.27 of face zone height — beak below the eyes, tucked toward the bottom V"
  tuft_aspect: "w:h = 2:1 (wider than tall, per round-1 lesson)"
  tuft_tilt: "25-30° outward from vertical, NO forward curl (round-1 forward-sweep failed)"
  tuft_construction: "splayed feather clumps — 3 hulled feather profiles per tuft, NOT a single swept mass"
  tray_to_cradle_body: "clean utility subordinate to the panel; no decorative parity"
fillet_schedule:
  micro: 1.0     # break-edges only — all exposed outer edges get at least this
  secondary: 4.0 # vertical edges of back panel, cradle body corners, base plate corners
  hero: 8.0      # back-panel top (where tufts emerge), printer-section → shelf transition
features:
  primary:
    - back-panel owl face (facial disc recess + eyes + beak) as intrinsic carving
    - back-panel silhouette itself (rounded top, softened edges, gently convex +Y face)
  secondary:
    - ear tufts (wider than tall, tilted outward, 3D-swept, emerging from rounded panel top)
    - printer-section → shelf transition as concave fillet (replaces 45° chamfer)
    - tray scoop lip + integrated finger-grip (functional hero on the tray)
  tertiary:
    - base-plate corner softening
    - foot-to-plate transition fillet
decoration_policy:
  - feature: facial_disc
    mode: intrinsic
    rationale: "shallow ovoid recess carved into the +Y face of the back panel — facial features sit INSIDE it, framed"
  - feature: back_panel_silhouette
    mode: intrinsic
    rationale: "the panel's own outline + convex face does the body-carrying work, not applied decoration"
  - feature: ear_tufts
    mode: applied-but-emergent
    rationale: "justified: the owl cue requires them, but they must grow from the panel with a base fillet, not stamp on"
  - feature: feather_embosses
    mode: REMOVED
    rationale: "applied decoration that didn't read as feathers; removed in favor of a unified surface language"
  - feature: tray_face
    mode: REMOVED
    rationale: "motif consolidated onto back panel — tray becomes clean utility to avoid two-creature problem"
  - feature: tray_scoop_lip
    mode: intrinsic
    rationale: "functional, not decorative — the one reason the tray front face is sculpted"
species_cues:
  - forward-facing eyes (slightly vertically elongated ellipses, not perfect circles)
  - beak between and below eyes, 3D wedge not 2D triangle
  - shallow facial disc framing the eye/beak cluster
  - ear tufts wider-than-tall, tilted outward, feather-like silhouette (not triangular ear)
anti_brief:
  - not cat, not bat, not Halloween
  - not slab-sided, not flat-faced, not dead-rectangular
  - not two-creature: tray carries no face, no eyes, no tufts
  - not applique: no stamped-on arch embosses, no decorative accents that don't compose with the form
  - not over-cute: Kindchenschema informs proportion, not kitsch
  - no fake wood, no pseudo-leather, no logos, no text
supports_permitted:
  - feature: ear_tufts
    reason: "3D forward/back sweep creates a transient underhang as tuft curves away from panel; tree supports acceptable"
  - feature: back_panel_facial_disc_rim
    reason: "if rim has undercut beyond 45°, supports allowed; prefer geometric avoidance first"
  - feature: beak_3d_wedge
    reason: "dome-top wedge may exceed 45° at apex; supports OK if needed"
print_orientation:
  cradle: "base down, back panel vertical (as currently). Tufts print top-last; supports under tuft curves."
  tray: "face up (open top), back on bed. Scoop lip angle prints as overhang; 45° is at the FDM threshold and has been printable before."
  seam_hidden_on: "user-back (-Y) of back panel; underside of base plate"
references:
  family_candidate: _id-library/families/quietly-playful-soft.md  # proposed post-ship if this round lands
  critique_attachments: obsidian-vault/vault/projects/3d-printing/attachments/ptouch-cradle-critique-01/
```

## Form language

Two rules govern every surface on this object:

**1. Everything curves toward the user.** The +Y face of the back panel is gently convex — not flat. The printer-section → shelf transition is concave, not chamfered. The base plate corners and foot-to-plate steps are filleted. The tufts sweep forward-and-out, not straight up. If a surface is straight, it's because it has to be (print-frame bottom, interior printer pocket walls, tray interior).

**2. Nothing is applied unless it's earned.** The removed feather embosses, the deleted tray face, the gone-now grip scallop — they were all accumulated-as-applique, each a fix for the previous iteration's flatness. The correct fix is intrinsic: carve *into* the form (facial disc recess, convex panel face, scoop lip) and grow *out of* the form (tufts with base fillets). Applied decoration is a last resort, justified only if it's the only way to communicate the object's intent.

**The owl lives on the back panel, not on the tray.** The panel's silhouette (rounded top, softened vertical edges, gently convex front face) carries the head; the facial disc recessed into the panel frames eyes and beak at ~62% of panel height; the ear tufts emerge from the rounded top as if they grew there. The tray is the printer's utility accessory — a well-proportioned catch basin with one earned feature (the 45° scoop lip for label retrieval) and no decorative parity with the panel. One creature, one point of view, one voice.

**Kindchenschema governs proportion, not kitsch.** Head:body on the panel is ~1:1 (tuft+facial zone occupies upper 50% of panel height). Eye axis lands at 62% of panel height. Tufts are wider than tall, asymmetric, feather-like. These are the moves that make a form read as a creature without tipping into cartoon.

## Feature-by-feature rationale

### Back-panel owl face (primary)

The panel rises 205mm. The printer is 143mm. That leaves a **62mm visible strip above the printer** — the face zone — where the owl's head lives. This is the only canvas where the face is visible in actual use; round 1's centered-disc-at-z=90 was invisible behind the printer and is the round-1 failure case.

The face is built per **R2 real-owl reference**, not the round-1 cartoon-mascot construction:

- **Heart-shaped (rounded-shield) facial disc.** Wider at top (~70mm wide near z=200), narrowing toward a soft V at the bottom around the beak (~40mm wide near z=148). NOT a circular disc. Real barn-owl facial disc is the move; the v1 round disc + small features read as cartoon.
- **Recessed eye sockets, NOT proud domes.** Eyes are sunk INTO the disc by ~1.5mm. Real owl eyes are deeply set in the facial disc; shadow does the work, not protrusion. Vertically elongated ellipses, ~16×20mm, occupying a substantial fraction of the disc width.
- **No pupils.** Barn-owl eyes read as uniform dark recesses; pupils-as-buttons are what made round 1 cartoon. Skip them.
- **Asymmetric hooked beak.** Narrow at top, wider at bottom, tip pointing down with a slight forward hook. Asymmetric, not centered-symmetric triangle. Larger than v1 — ~10×12mm, ~4mm proud.
- **Disc carved into the convex panel face.** Disc depth 1.5mm at center tapering to flat at perimeter. Rim soft (r=2mm).

**Must NOT look like:** v1's mascot face (small features in big circular disc). A cartoon owl. A pair of googly eyes. Two dots and a triangle.

**Must be visible** with the printer installed. The use-state render is the primary hero view; if the face doesn't read in `cradle-user-front-in-use.png`, the round failed.

### Back-panel silhouette (primary)

The panel currently reads as "rectangle stood on edge" from every angle. The fix is a silhouette that registers as a creature body even without the face: rounded top (carrying the tufts), gently convex +Y face (hugs the printer rather than standing behind it as a wall), softened vertical edges (r=4mm fillets make the panel read as a softened blade, not a slab edge), and a base that blends into the cradle body rather than meeting it at a hard step.

**Must NOT look like:** a slab, a wall, a tombstone, a billboard. A thing something else was mounted to.

### Ear tufts (secondary)

Round 1 failed: forward-curling sweep produced wizard-hat / soft-serve / curled-horn geometry. **The sweep is gone.**

Round 2 construction — splayed feather clumps:

- Each tuft = 3 separate feather-shaped protrusions hulled together. NOT a single swept mass.
- Feather profiles per tuft (proposal):
  - Inner feather: ~8w × 14h, tilted 10° outward, round tip.
  - Middle feather: ~10w × 16h, tilted 20° outward, round tip.
  - Outer feather: ~8w × 12h, tilted 30° outward, round tip.
- Total tuft footprint at base: ~30mm wide.
- Total tuft height above panel top: ~16mm (peaks at z≈221).
- **Outward lean only — no forward (+Y) curl, no forward sweep.** Tufts splay sideways to ±X, period.
- Round-tipped, not pointed. Feather tips are blunt.
- Base blend: r=4mm fillet into the rounded panel top.

**Must NOT look like:** wizard-hat points, curled horns, soft-serve swirls, cat ears, bat ears, devil horns, triangular flags.

### Printer-section → shelf transition (secondary)

Current: hard 45° chamfer over 11mm y-depth, signals "two objects joined." Target: concave fillet r=8-10mm swept the full height of the low-wall region, reads as "one form gathering from narrow to wide." Prints cleanly (concave curve — every layer fully supported by the layer below).

### Tray scoop lip + integrated finger-grip (secondary)

Restored from iteration 1 (its removal in iter 2 was a mistake). Rebalanced for the current 21.6mm wall height: 45° scoop across the full front wall face, spanning the upper ~14mm of the 21.6mm wall height (lower ~7mm stays vertical as the structural base, upper ~14mm tilts back at 45°). The center ~30mm of the scoop face carries a subtle concave dip 2-3mm deep that doubles as a finger-pull for tray removal — grip and scoop are one feature, not two. Leading edge r=2mm.

**Must NOT look like:** a separate grip scallop + a separate scoop lip. A decorative pattern. A logo plaque.

### Feather embosses (REMOVED)

Per user: "don't do much." Three applied half-ellipse arches on each printer-section side wall. Not feathery, not compositional, visual-noise-only. Gone. If side walls need visual weight later, the move is a continuous surface language (matching the panel's convex front), not discrete applied arches.

### Tray owl face (REMOVED via consolidation)

Eyes, pupils, beak on the tray front wall are deleted. The tray becomes a clean utility catch basin: flat vertical walls inside/outside, scoop lip on the +Y face, no decoration. The motif now lives once — on the back panel — and the tray supports the object's printer-accessory identity without competing for the owl read.

### Base plate / feet (tertiary)

Softening continues down: base-plate corner radius r=6 → r=8. Foot-to-plate transition gets a r=1.5mm fillet (cylinder top meets plate bottom with a soft blend, not a hard cylindrical step). Not load-bearing for the ID read; included because the unified curvature language shouldn't stop at ankle height.

## Modeler notes

See `id/modeler-notes-v1.md` for the concrete fix list, dimensions, and scope.

**Print orientation reminder:** cradle prints with base down and back panel vertical. Tufts are at the top of the print — supports will be needed under the forward-curving tuft sweep. Tray prints face-up (open top) with the back wall on the bed; the scoop lip's 45° face prints as an overhang at the threshold and has been verified printable in iteration 1.

**Non-negotiables:**
- User orientation is +Y = user-front. Every `hero_views` render must be in user-frame terms, not print-frame.
- The facial disc + eyes + beak live on the back panel's +Y face, **not** on the tray. The tray face is deleted. If the modeler finds itself considering how to soften the tray face, it has misread the brief.
- Ear tufts must be wider than tall and tilted outward. If the built geometry has h > w or vertical tilt, the round failed regardless of what else is right.
- The back panel's +Y face must be convex (not flat). Even 1-2mm of convexity is load-bearing for the "hugs the printer" read.

**Seam hiding:** user-back (−Y) of panel, underside of base plate. Do not let a seam land on the +Y face or a tuft.

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

**Unchanged (explicitly):**
- Overall cradle architecture: two-part (cradle + tray), stepped body (86mm printer section → 108mm shelf section), full-perimeter 25mm low base, 143mm printer pocket, kanban-style tray slot.
- Printer pocket dimensions, clearances, tape-exit clearance, cable notch position.
- Back panel height 145mm (hero dim).
- Foot count, spacing, and diameter (8mm d × 3mm h cylinders).
- Part-to-part sliding fit (0.35mm per-side clearance).

**Modeler fix list:** see `id/modeler-notes-v1.md`.

### 2026-04-20 — round 1 post-mortem (brief declared stale)

**Trigger:** Round 1 geometry built and rendered per `modeler-notes-v1.md`. User reviewed renders on GitHub commit `5772f81`. Reaction: **"The horror."** User identified a blocking issue the agent missed: the facial disc at z=90 is **behind the printer** when installed. Printer is 143mm tall; panel is 145mm tall; only ~2mm of panel is visible above the printer. The face that round 1 carved, critiqued, and shipped-as-STL is invisible in actual use.

**Root cause:** all round-1 hero renders were bare-geometry (no printer proxy in the pocket). The agent never rendered or critiqued the use-state, so the occlusion was invisible to the critique. Design would have printed correctly and shipped an invisible face.

**Changes (direction only — specific numbers pending):**

- Facial features (disc, eyes, beak) relocate from z=90 to the visible strip above the printer at z=143+.
- Back panel height 145mm → ~200-210mm (adds ~57-67mm of visible panel above the 143mm printer top).
- Composition metaphor: "owl head perched above printer body" — the printer stays visible as part of the object's silhouette; the owl head lives above it, not behind a facade.
- Face anatomy upgraded to **R2 real-owl reference**: heart-shaped facial disc (barn-owl, not circular mascot), recessed eye sockets (sunk, not proud domes), asymmetric hooked beak, no pupils (or re-evaluate scale). Scaled to the new ~57mm vertical face zone.
- Ear tufts rebuilt from scratch: splayed feather clumps, round-tipped, wider-than-tall, outward lean only (no forward curl), 2-3 offset feather profiles hulled per tuft instead of a single swept mass. The round-1 curled-wizard-hat geometry is discarded.
- `hero_views` must now include a use-state render (`cradle-user-front-in-use.png`) with a proxy block of printer dimensions {78, 152, 143} in the installed position. Silhouette test and feature legibility check run on the use-state render first.

**Unchanged (carries forward to v2):**

- Motif consolidation: owl on back panel / tufts, tray as clean utility — still right.
- Tray scoop lip + integrated finger-grip (Fix 7) — still right.
- Printer→shelf concave fillet (Fix 5) — still right.
- Feather embosses removed (Fix 6) — still right.
- Softened vertical edges, base plate corner softening, foot-to-plate blend — still right.
- User orientation block and two-part architecture — still right.

**Status:** brief stale as written (facial-disc placement broken). Direction above is proposed pending user confirmation. `modeler-notes-v2.md` not yet written. v1 artifacts preserved as historical record (do not build against them).

**Codified lesson:** `_id-library/lessons.md` — "Render the use-state, not just the part." Cycle 0 of `.claude/agents/id-designer.md` extended with a mandatory use-state check.

**Modeler fix list:** pending — see forthcoming `id/modeler-notes-v2.md` once direction is locked.

### 2026-04-25 — round 2 (direction locked, brief spec block updated)

**Trigger:** User confirmed the post-mortem direction. Brief's main spec block updated to v2 values; Form-language prose, anti-brief, decoration_policy, supports_permitted, and unchanged-for-v2 sections kept from round 1 since they remain right.

**Spec-block changes (this brief above):**

- `hero_dimension`: back_panel_height 145 → **205** mm.
- `proportions`: rebuilt around the new face zone (z=143-205). Eye axis 0.62 of face zone (not 0.62 of full panel). Tuft aspect kept 2:1; tuft tilt outward only — forward curl explicitly forbidden; tuft construction = 3 hulled feather profiles per tuft (not a single swept mass).
- `use_state` block added: host_object Brother PT-P750W, host_envelope_mm {78, 152, 143}, host_installed_position, visible_zone_after_install, composition metaphor.
- `hero_views`: two new in-use renders (`cradle-user-front-in-use`, `cradle-user-front-threequarter-in-use`) with `requires_proxy: true` flag. Bare-part renders kept as record. Silhouette test now runs on the use-state render.

**Form-language section additions:**

- Owl face section rewritten: heart-shaped (rounded-shield) disc, recessed eye sockets (NOT proud domes), no pupils, asymmetric hooked beak, larger features.
- Tuft section rewritten: splayed feather clumps (3 hulled profiles per tuft), outward lean only, NO forward curl, round tips.

**Unchanged from round 1 (still right):**

- Motif consolidation (owl on panel, tray as utility).
- Tray scoop lip + integrated finger-grip (Fix 7).
- Printer→shelf concave fillet (Fix 5).
- Feather embosses removed (Fix 6).
- Softened panel vertical edges, base plate corner softening, foot-to-plate blend (Fix 8).
- Convex +Y panel face (less load-bearing now that face is in upper zone, but still part of unified curvature).
- Two-part architecture, stepped body, full-perimeter low base, printer pocket dims, cable notch, tray interior, tray sliding fit, foot count.

**Modeler fix list:** see `id/modeler-notes-v2.md`.
