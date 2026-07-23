# Validation checklist — Shoulda Eaten Dinner

Claude's gate script. A checkpoint passes when every box in its section is
checked against the running build (web export in the browser pane, or Noah at
the editor). Numbers come from the brief; changed numbers are fine if logged as
tuning, changed behaviour is not.

## S1 — Scaffold and grey-box (CP1)

- [ ] Project opens in Godot 4.7.1 with no errors; input actions from the
      naming contract all present (the input map was hand-serialized — verify first open).
- [ ] Half-height walls (~1.2 m) read as room boundaries from the ortho camera
      and cast floor shadows.
- [ ] Navmesh baked; agents cannot path through walls.
- [ ] Floor colliders tagged with the four surface groups; zones match the contract.
- [ ] Node names match PLAN.md section 2 exactly.

## S2 — LightSystem (CP1)

- [ ] `get_brightness_at` ≈ 1.0 under a lamp, 0.0 beyond its radius, linear between.
- [ ] Multiple lights: max contribution wins, not sum.
- [ ] `set_zone_enabled` toggles a zone and emits `lighting_changed`.
- [ ] Purely analytic — no viewport or screen sampling anywhere in the code.

## S3 — Player (CP1)

- [ ] Sneak is default at 1.2 m/s; run only while held at 3.0 m/s; still = 0.
- [ ] Footstep loudness = speed mult (0 / 0.4 / 1.0) × surface mult (0.2 / 1.0 / 3.0 / 4.0), masked by `(1 − get_mask_at)`.
- [ ] Capsule visibly dim/desaturated in shadow, bright saturated blue in light.

## S4 — NoiseSystem and indicators (CP2)

- [ ] Threshold table verbatim: sneak-carpet 0.08 renders nothing; sneak-hardwood
      0.40, run-hardwood 1.0, sneak-creak 1.2, run-toys 4.0 all render.
- [ ] Ring expands to exactly `loudness × 8 m` (cap 20 m) and fades at arrival.
- [ ] Ring is 8 radial spokes, not a solid circle; icon rises ~0.5 m, fades 1.2 s, scale ∝ loudness.
- [ ] Threshold is absolute (0.25 post-mask), never contextual on listener range.
- [ ] Sustained sounds stream many small rings with a jittering icon; rush events pulse one large ring.
- [ ] Standing near the playing TV visibly shrinks the player's own rings.
- [ ] Magenta is `#FF2D95`-adjacent, clearly not red.

## S5 — Masking zones (CP3)

- [ ] TV and speaker each define a mask radius; strongest overlap wins.
- [ ] When the routine turns an ambient source off, its masking vanishes with it.

## S6 — GameClock and phases (CP3)

- [ ] 300 s run; phases 1–4 fire at 240/180/120/60 s remaining (phase 0 = start).
- [ ] Phase table applied: living light off → TV off → kitchen light + speaker off → hall off.
- [ ] Phase state is a pure function of the clock: `]` and `[` scrub ±30 s and the
      world (lights, ambients, masking) is always consistent after a scrub.
- [ ] Debug keys `]` `[` `\` `P` `N` work and are behind `OS.is_debug_build()`.
- [ ] Nightstand clock shows red m:ss numerals readable from the ortho camera; not a HUD element.

## S7 — Parent (CP4)

- [ ] Routine is data rows; parent position interpolates from `get_base_target(t)`.
- [ ] After any interruption the parent resumes where the clock says, not where it left off.
- [ ] Cone: 60°, 7 m, sweeping ±35° on a slow sine; flat translucent triangle on the floor.
- [ ] Detection needs all three: in cone, clear line of sight, brightness > 0.35.
      Explicit test: stand inside the cone in the dark — nothing happens.
- [ ] Suspicion: noise +loudness×10 with linear 8 m falloff; seen +25/s; decay −8/s; no bar anywhere.
- [ ] Investigate at 50: navigate, look ≤4 s, hard 10 s state timeout, 8 s / 2 m repeat cooldown.
- [ ] Caught at 100: carry to crib, input locked, snack drops at catch point,
      suspicion resets, routine resumes at now. The run continues; clock never pauses.
- [ ] Readability: cone tints amber with suspicion; investigate = stop dead, cone
      narrows, sweep stops; found = accelerate, cone snaps wide and locks. Motion
      carries every state colour carries.

## S8 — Pet (CP5)

- [ ] Fixed patrol circuit at 1.5 m/s, time-indexed like the parent.
- [ ] Alert telegraph: full 1.0 s freeze (ears up, chirp) before moving.
- [ ] Investigates noise within 6 m; barks only if player within 2 m on arrival.
- [ ] Bark = `emit_noise(pos, 5.0, self)` — the parent reacting is the real threat; pet has no vision.
- [ ] Same investigate timeout and cooldown rules as the parent.

## S9 — Full loop (CP5)

- [ ] Snack auto-acquired at door openness ≥ 0.6; wrapper emits 0.3 every 0.6 s
      even standing still, from pickup until crib.
- [ ] Door emissions ∝ rate of openness change only; a paused door emits nothing;
      sneak-open ~5 s, rush-open ~1 s via the held run key. No new controls.
- [ ] Fridge = light risk (dynamic light ∝ rate), pantry = noise risk (creak stream).
- [ ] Bedroom door is the same verb with no stakes — the teacher.
- [ ] Caught on return leg drops the snack where caught; it can be re-collected.
- [ ] In crib holding snack → immediate win. Time expired → win only if in crib
      with snack, else lose (including in crib without snack).
- [ ] Title card with controls; restart works; no other menus.

## S10 — Level economy (CP5–CP6)

- [ ] Hallway route 1.4–1.6× dining route at sneak speed, measured with debug keys.
- [ ] Dining = noise risk (creak + toys, shadowed); hallway = light risk (lamp + door strip, carpet-silent).
- [ ] Carpet is a visibly silent highway; the three floor types are visually distinct.
- [ ] First creaky board: hallway, outside parent hearing, carpet strip after it.
- [ ] First toy: ring visible but survivable. Later hazards placed for difficulty.
- [ ] Fridge and pantry on opposite kitchen sides.
- [ ] Late-game parent routine contests the dining route (7.2) so the choice never collapses.

## S11 — Web export (CP3 smoke, CP6 full)

- [ ] Export preset: web, threads off, Compatibility renderer.
- [ ] Loads in Chrome and Safari from the static server; no console errors.
- [ ] AreaLight3D renders on web — or the omni-cluster fallback is invoked and logged.
- [ ] Shadows visible and readable at the ortho angle in the browser.
- [ ] Playable frame rate in-browser on Noah's machine.

## Palette and accessibility (every visual checkpoint)

- [ ] World greyscale; hue only on actors and indicators.
- [ ] Player cool blue; base actors pale purple; investigate yellow; found red; noise magenta.
- [ ] All lamps neutral-to-cool white — nothing warm in the environment.
- [ ] Every state change legible by motion alone with colour off (6.6).
