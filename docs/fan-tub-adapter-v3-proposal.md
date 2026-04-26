# Fan-Tub Adapter v3.0 — Proposal: Shroud Cap + Guided Snap

> **Status: Stalled.** Proposal accepted; design dirs stubbed at `designs/fan-tub-adapter-v3-base/` and `designs/fan-tub-adapter-v3-cap/` (`requirements.md` + `spec.json` only — no SCAD, no STL). Implementation paused indefinitely. The currently-shipped fan-tub-adapter is **[v2.0](fan-tub-adapter-v2.md)**; this doc is a forward proposal kept for reference.

## Problem Statement (v2 Shortcomings)

The v2 clip is a thin ring (2mm thick, 119mm square frame) that sits on the fan top with four 1.5mm-thick cantilever arms dangling down to catch tiny ledges on the base rim. In practice:

1. **Flimsy** — the frame is a narrow ring with almost no depth. It has no structural stiffness perpendicular to the fan face. The whole clip flexes and wobbles.
2. **Weak engagement** — each arm's hook engages a 3mm-deep, 8mm-wide ledge on the rim. The hooks catch with 2.5mm of overhang. The fan can lift off with modest force.
3. **Blind alignment** — nothing guides the arms toward the ledges. The user must visually line up four thin arms (1.5mm thick, 8mm wide) with four small ledges while pressing down. On a humid bin with wet hands, this is frustrating.

## V3 Concept

Two changes, one to each part:

### Change 1: Shroud Cap (replaces thin-ring clip)

The clip becomes a **box cap** that drops over the fan top and wraps down around the fan's sides. Instead of a 2mm-thick ring with stub tabs, the cap has walls that extend downward along all four fan faces.

```
                    v2 clip (ring)                      v3 clip (shroud cap)

              ┌────────────────────┐              ┌────────────────────┐
              │   2mm ring only    │              │   top plate        │
              └─┬──────────────┬───┘              ├────────────────────┤
                │  (tab)       │  (tab)           │                    │
                │              │                  │   walls extend     │
               arm            arm                 │   down fan sides   │
                │              │                  │                    │
               hook           hook                │  arms continue     │
                                                  │  past wall bottom  │
                                                  │                    │
                                                 arm                  arm
                                                  │                    │
                                                 hook                hook
```

**What this fixes:**
- Walls make the cap a rigid box, not a floppy ring
- Walls self-center on the fan (inner face rides against fan frame)
- The cap "hugs" the fan — it feels solid and secure in the hand

### Change 2: Guide Channels (on base, flanking each ledge)

Each of the four ledge positions on the base gets a **U-channel**: two short walls flanking the ledge, creating a slot that the clip arm slides into.

```
    Top-down view (one side, +X):

    v2: bare ledge                     v3: channeled ledge

         ledge                              ┌─wall─┐
    ──────████──────  rim face         ─────┌┤ledge├┐─────  rim face
                                            └─wall─┘
    arm floats freely,                 arm slides into slot,
    user must aim                      constrained in Y
```

```
    Front view (XZ cross-section through one channel):

                     arm slides down
                          │
                  ┌───────▼───────┐    ← channel walls (extend upward from base)
                  │   ┌───────┐   │
                  │   │  arm  │   │    ← arm captured in Y
                  │   │       │   │
                  │   │  hook │   │
                  │   └──┐ ┌──┘   │
                  │      │▓│      │    ← hook catches ledge at channel bottom
                  └──────┴─┴──────┘
                    base plate
```

**What this fixes:**
- User doesn't aim — just set the cap on the fan and press. Arms find channels on the way down.
- XY position is locked before the snap engages, so the snap force goes purely into Z deflection — cleaner engagement.
- Channel walls also reinforce the ledge laterally.

## Installed Cross-Section (Proposed)

```
                        ← center        outside →

    z=31.7  ┌─────────────────────┬─────────────┐  cap top plate
            │   top plate (2mm)   │             │
    z=29.7  ╪═════════════════════╪═════════════╪  fan top
            │                     │  cap wall   │
            │                     │  (extends   │
            │   fan (24.7mm)      │   D mm      │
            │                     │   down fan  │
            │                     │   side)     │
    z=29.7-D╞                     ╞═════════════╡  cap wall bottom / arm start
            ║                     │    arm      │
            ║                     │             │
    z=9.0   ║                     ╠═══╗  ┌──┐   │  ledge top / channel wall top
            ║   rim (4mm tall)    ║   ║  │ch│   │  channel wall flanks arm
    z=7.0   ║                     ╠   ║┌─┤  │   │  hook catches under ledge
            ║                     ║   ╝ │  │   │
    z=5.0   ╩═════════════════════╩═════╧══╧═══╧  inner plate top
```

`D` = shroud wall depth (how far the cap extends down the fan sides). See question 1.

## Decisions (Locked In)

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Shroud wall depth (D) | **12mm** (medium) | Cap wall bottom at z=17.7. Solid grip on fan, ~11mm arm length — firm but not brutal snap |
| Channel wall height | **10mm above inner plate** (top at z=15) | 6–8mm of guided travel before hook reaches ledge. Deliberate feel without visual clutter |
| Snap points | **2** (opposing sides) | Shroud walls on all 4 sides prevent tilt; snaps only need to resist Z lift-off. 2 is enough with good channel alignment, simpler release |
| Base plate | **New base plate** with integral channels | Base is not currently caulked. Clean redesign, no add-on complexity |
| Cap walls | **4 sides** continuous | Matches base rim fit — cap hugs the fan on all sides for rigidity and XY constraint |
| Release | **Pull straight up** | Hooks flex out of engagement on pull. Don't over-engineer this |

### Derived Parameters

**Arm geometry (2 arms, opposing sides):**
- Arm length: z=17.7 (cap wall bottom) to z=7.0 (ledge flat bottom) = **10.7mm**
- Arm thickness: **2.0mm** (thicker than v2's 1.5mm — shorter arm needs more section for good snap, and 2mm is more robust)
- Arm width: **8.0mm** (unchanged)

**Stress check (preliminary):**
```
σ = 3Ehδ / 2L²
  E = 3500 MPa, h = 2.0mm, δ = 2.5mm (hook overhang), L = 10.7mm
σ = 3 × 3500 × 2.0 × 2.5 / (2 × 10.7²) = 52500 / 228.98 ≈ 229 MPa
```
That's way over PLA yield (~65 MPa). **The v2 hook overhang (2.5mm) won't work with 11mm arms.** Options:
- Reduce hook overhang to ~1.0mm: σ ≈ 92 MPa — still high
- Reduce hook overhang to ~0.7mm: σ ≈ 64 MPa — at yield, marginal
- Reduce arm thickness back to 1.5mm: σ = 3×3500×1.5×2.5 / (2×10.7²) ≈ 172 MPa — worse
- **Lengthen arms** by starting them higher (shallower shroud wall or arm starts partway up the wall): 15mm arm + 1.5mm thick + 1.5mm overhang → σ ≈ 35 MPa — comfortable

**Resolution:** The arms don't need to start at the shroud wall bottom. The cap wall goes down 12mm for rigidity, but the arm can start **inside the wall** at a higher Z. This decouples shroud depth from arm length:

```
    Cap wall (12mm deep, all 4 sides)
    ├─────────────────────────────────┤
    │                                 │
    │   arm starts inside wall        │  ← arm root at z=22 (inside wall zone)
    │   at higher Z, runs down        │
    │   through wall bottom           │
    │                                 │
    z=17.7 ╞═════════════════════════╡  wall bottom
           │   arm continues          │
           │   exposed below wall     │
           │                          │
    z=7    │   hook catches ledge     │
           └──────────────────────────┘
```

Arm length = z=22 to z=7 = **15mm**. With 1.5mm thickness and 1.5mm hook overhang:
```
σ = 3 × 3500 × 1.5 × 1.5 / (2 × 15²) = 23625 / 450 ≈ 52.5 MPa
With Kt=1.2 (root fillet): σ_peak ≈ 63 MPa — just under yield. Acceptable.
```

With 1.0mm hook overhang:
```
σ = 3 × 3500 × 1.5 × 1.0 / (2 × 15²) = 15750 / 450 = 35 MPa
σ_peak ≈ 42 MPa — comfortable. Good safety factor.
```

**Updated arm parameters:**
- Arm root: inside cap wall at z=22 (7.7mm above fan top minus 12mm wall = partway up wall)
- Arm length: **15mm** (z=22 to z=7)
- Arm thickness: **1.5mm**
- Hook overhang: **1.0–1.5mm** (reduced from v2's 2.5mm — channels prevent accidental disengagement, so less overhang is fine)
- Hook height: **2.0mm** (reduced from 3.0mm proportionally)

### Channel Dimensions

- Channel inner width: 8.0 + 2×0.35 = **8.7mm** (sliding fit)
- Channel wall thickness: **2.0mm**
- Channel outer width: 8.7 + 2×2.0 = **12.7mm**
- Channel wall height: **10mm** above inner plate (z=5 to z=15)
- Channel depth (radial): extends from rim outer face to past ledge — approximately **5mm** radial depth

## What Stays the Same

- Y-branch geometry (waffle grid engagement) — unchanged
- Base plate outer frame, flange, center opening — unchanged
- Locating rim height and ID — unchanged (fan fit is dialed in)
- Ledge engagement Z-range (z=7–9) — unchanged
- Print orientations — base bottom-down, cap top-plate-down (walls + arms up)
- Shared params file — extended with new v3 parameters

## Printability Notes (Preliminary)

**Shroud cap (printed top-plate on bed, walls/arms up):**
- Top plate on bed — good first layer adhesion, large flat surface
- Walls rise vertically from plate edges — no overhang
- Arms are embedded in walls and continue upward past wall tops — no overhang
- Hooks at arm tips — same 45deg chamfer approach as v2 (smaller overhang = smaller chamfer)
- Inner corners where walls meet top plate: 90deg, fully supported (concave)
- Cap is a much more solid print than v2's spindly ring — easier to remove from bed, less warping risk

**Base with channels (printed bottom-down):**
- Channel walls are vertical ribs rising from the plate — no overhang
- Ledge chamfers unchanged (45deg, self-supporting)
- Channel walls at z=5–15 are thin vertical walls; 2mm thickness = 5 perimeters at 0.4mm line width, solid
- Channel walls only at 2 cardinal positions (matching 2 snap arms), so 2 fewer ledges to print vs v2

## Status

**Proposal accepted.** Decisions locked in above. Implementation on hold — will proceed when directed.
