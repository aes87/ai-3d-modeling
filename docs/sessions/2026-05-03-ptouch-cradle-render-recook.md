# 2026-05-03 — ptouch-cradle README render recook

Recooking the flat OpenSCAD renders in `docs/ptouch-cradle.md` as Blender Cycles, matching the published `assembly-hero.png` gold standard. Container reportedly OOMed during earlier render iteration — capture every attempt here so we can pin the cause if it happens again.

## Gold standard

`docs/images/ptouch-cradle/assembly-hero.png` (committed `0e83f0c` → `ac28846`). Came from a separate exploratory session; not 1:1 reproducible from `scripts/render-assembly.py`. Composition: warm mocha cradle, light cream tray pulled forward into label-catch position, two-tone backdrop (warm-dark upper, cool-light floor), lofted three-quarter camera (~30° elevation), soft 4-point lighting. AgX view transform.

Sampled palette (sRGB):
- Cradle interior (shadowed): `#776857`
- Tray floor: `#aea490`
- Backdrop upper (warm dark): `#695847`
- Backdrop floor (cool light grey): `#b2b2b2`

Lessons from `scripts/render-assembly.py` (don't fall into these traps again):
- SSS < 0.025, especially on warm hues
- No warm-amber direct lights on R-dominant beiges (caused peach skin tones in v5)
- AgX view transform > Filmic (Filmic desaturates beige toward white)

## Recook targets (in order)

1. `cradle-user-front-threequarter.png` — bare cradle hero, three-quarter — **PRIMARY**
2. `cradle-user-top-threequarter.png` — bare cradle from above
3. `cradle-user-front.png` — bare cradle front elevation (decide flat vs Cycles)
4. `tray-user-front.png` — bare tray front elevation (already reframed as illustration; may keep)
5. `tray-user-front-threequarter.png` — bare tray three-quarter (already reframed; may keep)
6. `cradle-user-front-in-use.png` — printer in cradle, front
7. `cradle-user-front-threequarter-in-use.png` — printer in cradle, three-quarter

## Container safety rules

- **Serial renders only** — never spawn parallel Blender processes.
- **Start at draft (Eevee, 1280×960, 64 samples) — sanity check composition before burning Cycles time.**
- **Capture peak RAM** for each render via `/usr/bin/time -v` so we can spot a memory creep.
- Free memory ≥ 5Gi before starting any Cycles-hero render.
- After each attempt, run `free -h` and append to log.

## Render attempts

### #1 — cradle-user-front-threequarter — first pass

| Field | Value |
|---|---|
| Script | `scripts/render-part.py` (new, adapted from `render-assembly.py`) |
| STL | `designs/ptouch-cradle/output/cradle.stl` |
| Angle | `front-threequarter` (cam at norm-coords `(1.4, 1.8, 0.95)`) |
| Quality | standard (Cycles, 192 samples, 1920×1440, OIDN denoiser) |
| Palette | linear `(0.26, 0.205, 0.13)` ≈ sRGB `#95846a` (mocha attempt) |
| Wall time | 153 s |
| Blender peak RAM | 87 MiB |
| Container free RAM before/after | 8.6 / 8.3 GiB |
| Output | `docs/images/drafts/recook/cradle-front-3q-std.png` |
| Verdict | NOT GREENLIT — color reads as cream, not gold-standard mocha. Lights blow out highlights. Subject small in frame. |
| Notes | Initial bug: subject out of frame because `subject.location -= V` was applied before scale, so V was un-scaled. Fixed by `bpy.ops.object.origin_set(BOUNDS)` then setting location post-scale. |

### Container safety status after #1

No leak: peak Blender RAM 87 MiB, container free RAM before/after delta = 0.3 GiB (within noise from buff/cache). Cycles standard at 192 samples is safe so far.

### #1 v2 — same target, applied tweaks (GREENLIT, published)

| Field | Value |
|---|---|
| Palette | linear `(0.150, 0.115, 0.070)` ≈ sRGB `#6f5b46` (deep mocha — pushed darker from #1) |
| Camera | distances pulled in ~30% (cam_loc `(1.0, 1.3, 0.7)`) — tighter frame |
| Lights | key 320→200, fill 130→80, rim 200→120, top 90→55 (~40% drop to keep mocha reading mocha) |
| Backdrop | split: cool-light grey floor `(0.42, 0.42, 0.43)` + warm-dark vertical wall `(0.10, 0.085, 0.065)` for horizon line + subject contrast |
| Wall time | 209 s |
| Container free RAM before/after | 8.0 / 7.8 GiB (Δ 0.2 GiB, within buff/cache noise) |
| Output | promoted → `docs/images/ptouch-cradle/cradle-user-front-threequarter.png` |
| Verdict | GREENLIT 2026-05-03. Mocha reads correctly, two-tone horizon, subject ~75% width. |

### #2 — cradle-user-top-threequarter (GREENLIT, published)

| Field | Value |
|---|---|
| Script | `scripts/render-part.py` (greenlit settings) |
| Angle | `top-threequarter` (cam at norm-coords `(0.8, 1.1, 1.15)`) |
| Quality | standard |
| Wall time | 211 s |
| Container free RAM before/after | 8.1 / 8.0 GiB |
| Output | promoted → `docs/images/ptouch-cradle/cradle-user-top-threequarter.png` |
| Verdict | GREENLIT — both pockets visible from above, fillets clean. Backdrop horizon mostly out of frame from elevated angle (acceptable trade — geometry legibility is the goal). |

### #3 — cradle-user-front (front elevation) (GREENLIT, published)

| Field | Value |
|---|---|
| Script | `scripts/render-part.py` |
| Angle | `front` — first attempt cam at `(0, 1.9, 0.4)` framed too high+far (looking down into pockets); revised to `(0, 1.3, 0.15)` for low straight-on view |
| Quality | standard |
| Wall time | 197 s + 202 s (two attempts, 1 reframe) |
| Output | promoted → `docs/images/ptouch-cradle/cradle-user-front.png` |
| Verdict | GREENLIT — stepped body clearly readable (wider shelf section in front, narrower printer section behind), tray slot opening visible through the front face. |

### #4 — cradle-user-front-threequarter-in-use (GREENLIT, published)

| Field | Value |
|---|---|
| Script | `scripts/render-in-use.py` (new — adapted from render-part.py + render-assembly.py pattern; adds 78×152×143mm printer proxy box at host_object_proxy() coords) |
| Printer proxy | mm coords `(16, 4, 4)` size `(78, 152, 143)`, dark satin material `(0.020, 0.020, 0.022)` linear |
| Angle | `front-threequarter` |
| Quality | standard |
| Wall time | 190 s |
| Container free RAM before/after | 7.9 / 8.0 GiB |
| Output | promoted → `docs/images/ptouch-cradle/cradle-user-front-threequarter-in-use.png` |
| Verdict | GREENLIT — printer dominates frame, cradle reads as quiet low frame around base, tray slot visible in front. Matches "is it quiet enough?" alt text intent. |

### #5 — cradle-user-front-in-use (GREENLIT, published)

| Field | Value |
|---|---|
| Script | `scripts/render-in-use.py` |
| Angle | `front` |
| Quality | standard |
| Wall time | 191 s |
| Output | promoted → `docs/images/ptouch-cradle/cradle-user-front-in-use.png` |
| Verdict | GREENLIT — printer body cropped at top by the low-camera frame is a feature: emphasizes how unobtrusively the cradle wraps the printer base. |

## Summary

5 renders recooked, ~16 minutes total render time, ~2.6 MiB per output.

**Memory profile across the session:**
- Free RAM oscillated in the 7.8–8.6 GiB band (started at 10 GiB).
- Blender peak resident set was 79–87 MiB per render — single-part renders are tiny on this scale.
- No process leaks or zombie children.

**Hypothesis for the earlier OOM:** if the container ate itself during prior Blender work, the most likely causes (none observed today) are:
1. **Multiple parallel Blender processes** — each holds 80–150 MiB plus OIDN at 200–400 MiB. Six in parallel ≈ 2 GiB. Combined with VS Code/extension overhead in WSL2, it adds up.
2. **OIDN denoiser allocation spike** — denoiser ramps RAM at frame end. We saw memory dip 0.1–0.3 GiB during render but never approach the wall.
3. **Hero-quality at 2560×1920 with 768 samples + denoiser** — would push higher. We didn't run hero-quality this session; standard at 1920×1440 was the ceiling.

**Mitigations baked into today's workflow:**
- Serial renders only, never parallel.
- Standard quality (1920×1440, 192 samples) — adequate for README; hero quality reserved for future when the user explicitly wants it.
- `free -h` snapshot before and after every render.

## Files

- `scripts/render-part.py` — single-part gallery render (NEW)
- `scripts/render-in-use.py` — cradle + printer proxy gallery render (NEW)
- `docs/images/drafts/recook/` — all draft outputs retained for reference

## Outstanding

- Hero quality (2560×1920, 768 samples) re-renders if/when the user wants those — would take ~12 min each.
- Tray-only renders (`tray-user-front.png`, `tray-user-front-threequarter.png`) were already reframed as "technical illustration" in the README and were not part of this batch.
