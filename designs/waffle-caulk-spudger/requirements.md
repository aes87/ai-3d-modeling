# Waffle Caulk Spudger — Requirements

## Design Intent

A single-part handheld tool for spreading silicone caulk into the waffle-grid channels of an HDPE bin lid. The user presses caulk into the 9.4 mm wide channels before seating a printed adapter (fan-tub adapter, humidity output, etc.). The spudger tip travels along a channel, displacing caulk sideways and leaving a smooth, concave bead that bonds the adapter flange to the channel walls.

The tip geometry is convex (curved outward, away from the user's hand). When pushed into the channel, the convex arc forces caulk outward and down the channel sides, creating a consistently shaped concave bead — the same principle as a caulk finishing tool. The tip is narrower than the channel so it can travel freely without scraping the HDPE walls.

This is a disposable-friendly utility tool. PLA is acceptable. Print flat on the bed with no supports.

## Print Orientation

Flat on the bed. The largest face (XY plane, bottom of handle + tip) sits on the build plate. The tool grows upward in Z. The convex tip curve is oriented so the arc apex faces up (away from bed) — it is the top surface of the tip cross-section. No overhangs exceed 45°. No supports required.

The convex tip cross-section is a partial circular arc: the arc is on the top face, and the flat bottom of the tip sits on the bed. This means the arc profile is printed as a series of stepped layers — not a bridging problem, just normal staircase geometry at 0.2 mm layers.

## Dimensions & Sources

| Dimension | Value | Source |
|---|---|---|
| Waffle channel width | 9.4 mm | Existing designs (external constraint, fixed) |
| Waffle channel depth | 4.6 mm | Existing designs (external constraint, fixed) |
| Waffle square side | 63.7 mm | Existing designs (external constraint, fixed) |
| Waffle corner radius | 4.0 mm | Existing designs (external constraint, fixed) |
| Tip width | 8.8 mm | Derived: channel width − 2 × 0.3 mm clearance; fits within user range 8.5–9.0 mm |
| Tip clearance per side | 0.3 mm | Derived: (9.4 − 8.8) / 2; free travel without scraping |
| Tip convex arc radius | 4.4 mm | Derived: R = w² / (8×sag) + sag/2 = 77.44/33.6 + 2.1 ≈ 4.4 mm |
| Tip sag (convex arc depth) | 4.2 mm | Derived: channel depth 4.6 mm − 0.4 mm bond clearance |
| Tip length | 25.0 mm | User intent: working stroke length |
| Tip base height (flat bottom) | 1.2 mm | Derived: min floor thickness (4 layers at 0.2 mm) + 1 layer margin; keeps tip solid |
| Tip total height at apex | 5.4 mm | Derived: tip base height + sag = 1.2 + 4.2 |
| Handle length | 120.0 mm | User intent: ergonomic, thumb-and-finger grip |
| Handle width | 18.0 mm | User intent: comfortable palm width for a narrow tool |
| Handle height | 10.0 mm | User intent: enough thickness for grip stiffness, not bulky |
| Taper zone length | 15.0 mm | Derived: transition from handle cross-section to tip cross-section |
| Taper start (from tip end) | 25.0 mm | = tip length; taper begins where handle geometry starts |
| Overall tool length | 145.0 mm | Derived: tip 25 mm + taper 15 mm + handle 120 mm − 15 mm overlap = 145 mm |
| Overall tool width | 18.0 mm | = handle width (widest cross-section) |
| Overall tool height | 10.0 mm | = handle height (tallest cross-section at handle) |
| Handle fillet radius (edges) | 3.0 mm | User intent: ergonomic, prevents sharp grip edges |
| Min wall thickness | 1.8 mm | Derived: tip base at 1.2 mm is the minimum (floor); handle walls ≥ 4 mm everywhere |

## Features

### Tip — Convex Spreader
- **Purpose**: Contacts and shapes the caulk bead. Travels along the waffle channel. The convex cross-section displaces excess caulk to the sides and leaves a smooth concave bead in the channel.
- **Critical dimensions**:
  - Width: 8.8 mm ± 0.2 mm
  - Convex arc radius: 4.4 mm (arc spans full 8.8 mm width)
  - Arc sag (depth from chord to apex): 4.2 mm
  - Total tip height at apex: 5.4 mm (base 1.2 mm + sag 4.2 mm)
  - Length: 25.0 mm
  - Bottom face: flat (on bed)
  - Tip end (leading edge): rounded with a 4.4 mm radius hemisphere cap — smooth entry into the channel
- **Mating interfaces**: Waffle channel 9.4 mm wide × 4.6 mm deep. Tip fits inside channel with 0.3 mm clearance per side. The tip apex (highest point of convex curve) reaches 4.2 mm above the channel floor when the tool bottom is flush with the waffle square top surface, leaving 0.4 mm of channel depth below the apex for caulk bonding.
- **Printability note**: The convex arc is the top surface, printed as stepped 0.2 mm layers — normal FDM staircase, no bridging. Bottom face is flat on bed.

### Taper Zone
- **Purpose**: Transitions from the handle cross-section (18 mm wide × 10 mm tall) to the tip cross-section (8.8 mm wide × 5.4 mm tall at apex) over 15 mm of length. Prevents a stress concentration at the handle-to-tip joint.
- **Critical dimensions**:
  - Length: 15.0 mm
  - Width: linear taper 18.0 mm → 8.8 mm
  - Height: linear taper from 10.0 mm handle height down to 5.4 mm tip apex height on the top face; bottom face remains flat throughout
- **Mating interfaces**: None — purely structural transition geometry.
- **Printability note**: The taper underside is flat (bed face). The top tapers. No overhang: all taper surfaces slope ≤ 45° from vertical in the Y direction. Check: (18.0 − 8.8) / 2 = 4.6 mm lateral taper over 15 mm length = 17° — well within 45°.

### Handle
- **Purpose**: Ergonomic grip for hand use. User holds between thumb and fingers, pushing the tip along the caulk channel with moderate force.
- **Critical dimensions**:
  - Length: 120.0 mm
  - Width: 18.0 mm
  - Height: 10.0 mm
  - Edge fillets: 3.0 mm radius on all long edges (top, sides, tail end)
  - Tail end: fully rounded (semicircle, 9.0 mm radius = handle height / 2)
- **Mating interfaces**: None — no mating parts.
- **Printability note**: Solid rectangular bar with fillets. No overhangs. No bridges. All walls ≥ 4 mm. Clean print.

## Material & Tolerances

- Material: PLA (Bambu PLA Basic or equivalent)
- This is a tooling part, not structural — PLA strength is more than adequate for caulk-spreading force
- No fit types required — this part does not mate with any other printed part
- Tip width tolerance: ±0.2 mm acceptable (clearance to channel is 0.3 mm per side; even with +0.2 mm error, 0.1 mm per side clearance remains)
- Default tolerance: ±0.5 mm on non-critical dimensions (handle length, handle height, taper zone)

## Constraints

- Build volume: 145 × 18 × 10.8 mm — comfortably within 256 × 256 × 256 mm
- No supports required
- No overhangs > 45° (verified in each feature above)
- No bridges (flat bottom throughout; convex top is a series of solid layers, not a span)
- Minimum wall thickness: tip base at 1.2 mm meets the 4-layer minimum floor requirement; handle is solid (no thin walls)
- Single part, no assembly

## Printability Pre-Screen

| Feature | Check | Result |
|---|---|---|
| Tip base thickness (1.2 mm) | Min floor ≥ 0.8 mm | PASS — 1.2 mm = 6 layers; solid floor |
| Tip convex arc (top surface) | Bridge check | PASS — this is the top surface of a solid body, not a span; each layer narrows as the arc tapers to apex; no bridging |
| Taper zone side walls | Overhang ≤ 45° | PASS — lateral taper is 17° from vertical; well within limit |
| Taper zone top face | Overhang ≤ 45° | PASS — height drops from 10 mm to 5.4 mm over 15 mm = 24° slope from horizontal; no support needed |
| Handle edge fillets (3 mm) | Overhang at fillet top | PASS — 3 mm fillet at 10 mm height introduces a ~17° overhang from vertical at the fillet apex; within limit |
| Handle walls | Min wall ≥ 1.2 mm | PASS — handle is solid; no thin walls |
| Overall dimensions | Build volume | PASS — 145 × 18 × 10.8 mm fits X1C (256 mm limit) |
