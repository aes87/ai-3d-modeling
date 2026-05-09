# Test Prints — Modeling Notes

All 3 test prints modeled in Fusion 360 via the direct add-in TCP protocol (same channel as the parent v3.4 part), then exported as STL + F3D and transferred to the container as base64.

| Test print | Volume | STL | F3D | Build features |
|---|---|---|---|---|
| `plug-sleeve-stub/` | 91.3 cm³ | 108 KB | 92 KB | flange (88.5×62.5×8 with r=7 corner fillets) + hollow-shell plug (3 mm walls, 30 mm tall, r=2.5 outer corner fillets) + sleeve (annulus 88.5×62.5 / 78.5×53, 25 mm long) + sleeve −X wall cut + plug-flange shoulder fillet r=5 |
| `fork-plate-sample/` | 61.4 cm³ | 21 KB | 70 KB | base plate (3 mm at Z=−59 to −56) + bottom buttress (r=22 quarter-cylinder) + truncated fork plate (Y=+31.25 to +70, X=±39.25, Z=−34 to −22) + top buttress (r=22) + slot cut at the saddle arc (R=23, truncated at Y=70 → slot opening 22.7 mm at the truncation edge) |
| `buttress-arc-sample/` | 3.7 cm³ | 7 KB | 52 KB | base plate (3 mm at Z=−25 to −22, 20 mm wide × 26.75 mm Y span) + 20 mm-wide X-slice of the top r=22 buttress arc |

## Volume notes

- **plug-sleeve-stub came in at 91 cm³** vs the planner's ~35 cm³ estimate. The flange alone is ~44 cm³ (88.5 × 62.5 × 8 = 44 cm³ before the corner fillets); plug shell + sleeve add another ~45 cm³. Hollowing the plug saves ~68 cm³ vs solid (~87 → ~19 cm³ for the shell), so the planner's "saves ~40 cm³" claim was understated. Net stub is still 36 % of the full v3.4 part — substantial savings.
- **fork-plate-sample came in at 61 cm³** vs the planner's ~25 cm³ estimate. The buttress + base plate added more than the planner anticipated. Still well under the full part's 253 cm³.
- **buttress-arc-sample is 3.7 cm³** — within the planner's 3–8 cm³ range.

## Modeling approach for atomic state safety

The Fusion document had a saved file (`2026-05-08 First viable plug v1`) that auto-restored to the v3.4 holder body between operations, wiping clear+build sequences. Switched to **single atomic `execute_code` calls per test print** that do clear + build + inline `exportManager.execute()` + base64-encode-result-in-one-shot, so Fusion can't revert mid-sequence.

The inline export uses Fusion's `ExportManager` API directly (rather than the separate `export_stl` MCP command) so the export and the just-built body are guaranteed to be in scope at the same time.

## Print orientations (per the test print spec.json files)

| Test print | Orientation | Bed contact face |
|---|---|---|
| plug-sleeve-stub | flange face down | flange bottom (Z=0 in the model) |
| fork-plate-sample | inverted, fork plate bottom toward bed | base plate bottom (Z=−59 in v3.4 coords) |
| buttress-arc-sample | plug-vertical, flange face down | base plate bottom (Z=−25 in v3.4 coords) |

In all three, the bed-contact face is the model's lowest Z. The slicer should auto-orient.

## Files

```
designs/workout-dumbbell-holder/test-prints/
  plug-sleeve-stub/
    requirements.md, spec.json
    output/plug-sleeve-stub.stl, .f3d
  fork-plate-sample/
    requirements.md, spec.json
    output/fork-plate-sample.stl, .f3d
  buttress-arc-sample/
    requirements.md, spec.json
    output/buttress-arc-sample.stl, .f3d
  MODELING-NOTES.md  (this file)
```

## Next step

Print the **plug-sleeve-stub** first. PASS = the full v3.4 part is greenlit for printing. FAIL = adjust `clearance_per_side` in the parent `spec.json` and re-model the parent before reprinting any stub.
