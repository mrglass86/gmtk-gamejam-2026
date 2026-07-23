# Backlog

Keep this actionable and ordered. Tasks should be small enough to verify.
Owners: Noah (director), lane A / lane B (Codex), Claude (validation).
Acceptance tests live in `gamejam/VALIDATION.md` (S-numbers).

## Must — Thursday (build order 1–6 + export smoke)

- [x] Choose the direction and log it (Shoulda Eaten Dinner) — DECISIONS 2026-07-23.
- [x] Scaffold the Godot 4.7.1 project: project.godot, autoload stubs, input map, Main.tscn — Claude.
- [ ] Copy the brief into `gamejam/brief/`, git init, first commit — Noah pastes (kickoff handoff).
- [ ] MCP setup for lane A, 30-minute hard abort; Context7 into Codex — Noah pastes Claude-supplied lines.
- [ ] A0 greybox level, camera, actor stubs, navmesh, scaffold verification — lane A. Accept: S1.
- [ ] Directorial pass 1: layout screenshot — do the rooms and routes read — Noah.
- [ ] A1 LightSystem — lane A. Accept: S2.
- [ ] B1 Player.gd (movement, footsteps, capsule readout) — lane B. Accept: S3.
- [ ] CP1 gate — Claude validates, Noah walks the greybox.
- [ ] A2 NoiseSystem + dynamic-light helper — lane A. Accept: S4 core.
- [ ] A3 noise indicators + the two teacher hazards — lane A. Accept: S4 full, S10 teacher rows.
- [ ] B2 Door.gd + Snack.gd — lane B. Accept: S9 door/snack rows.
- [ ] CP2 gate — Claude validates, Noah plays every surface; directorial pass 2 on door feel.
- [ ] A4 ambient masking zones — lane A. Accept: S5.
- [ ] A5 GameClock finish, phase director, debug keys, nightstand clock — lane A. Accept: S6.
- [ ] Throwaway web export with one AreaLight3D and one shadow — lane A exports (Claude supplies the template-install command), Claude validates in browser. Accept: S11 smoke.
- [ ] CP3 gate = Thursday exit criteria — Claude validates, Noah scrubs phases with `]`.

## Must — Friday (actors, full loop, banked build)

- [ ] B3 Parent.gd (routine, cone, suspicion, investigate, carry) — lane B. Accept: S7.
- [ ] CP4 catch-loop gate — Claude validates, Noah plays the catch.
- [ ] B4 Pet.gd — lane B. Accept: S8.
- [ ] A6 win/lose/title/restart + export preset — lane A. Accept: S9 UI rows.
- [ ] Snack round trip wired end to end — lanes A+B. Accept: S9 full.
- [ ] CP5 gate: winnable and losable from the title card — Noah plays a full run.
- [ ] B5 routine rows (drink run promoted, bathroom, lights-off walk) — lane B. Accept: S10.
- [ ] Route timing measured from Noah's runs, tuned to 1.4–1.6x — lane A adjusts. Accept: S10.
- [ ] 19:00 freeze: Noah pastes the tag ritual, lane A exports, Claude validates, Noah uploads the itch draft (walkthrough supplied).

## Should — Saturday (feel day)

- [ ] Audio pass, 2-hour cap, CC0 only; the three countdown sounds first (TV
      click-off, light switch, parent footsteps turning) — Claude supplies links, lane A wires.
- [ ] One outside playtester, watched silently; fixes prioritized by Claude via playtest-critic lens.
- [ ] Tuning pass from the playtest — Noah verdicts, lanes apply.
- [ ] Submission page: screenshots, GIF of a ring resolving, controls, the
      theme-reading sentence — Claude drafts, Noah posts.

## Could — only if everything above is green by Saturday 15:00

- [ ] Dithering post-process per brief 11 (band edge at brightness 0.35, actors excluded).
- [ ] Extra hazard placement and routine rows beyond the minimums — from Noah's play notes.

## Cut / parked — invoke via PLAN.md section 4 trip-wires, in this order

1. Dithering (gated above).
2. The pet entirely.
3. Ambient masking (TV stays as light + sound).
4. The second route (block the dining doorway).
5. The round trip (one-way to the pantry, clock ~180 s).

Never cut: three movement speeds, brightness detection, noise → suspicion, the
clock, lights going out as it drains.
