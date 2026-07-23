# Backlog

Keep this actionable and ordered. Tasks should be small enough to verify.
Owners: Noah (director), lane A / lane B (Codex), Claude (validation).
Acceptance tests live in `gamejam/VALIDATION.md` (S-numbers).

## Must — Thursday (build order 1–6 + export smoke)

- [x] Choose the direction and log it (Shoulda Eaten Dinner) — DECISIONS 2026-07-23.
- [x] Scaffold the Godot 4.7.1 project: project.godot, autoload stubs, input map, Main.tscn — Claude.
- [x] Brief in repo, git init, kickoff commits, first push to personal GitHub — done 2026-07-23.
- [ ] MCP verification at first lane A session (bridge + Context7 already wired
      in ~/.codex/config.toml); 30-minute hard abort → file-only fallback.
- [x] A0 greybox level, camera, actor stubs, scaffold verification — lane A (`527dba7`, `aa4fbf4`). Accept: S1 pending CP1 walk.
- [x] A0.1 review fixes — static-collider startup nav bake, lighting wash,
      re-shot layout, BedroomDoor placement, and Player wiring (`aa4fbf4`).
- [ ] Directorial pass 1: layout screenshot — do the rooms and routes read — Noah.
- [x] A1 LightSystem — lane A (`8eff7c4`). Accept: S2 on review; runtime spot-check at CP1.
- [x] B1 Player.gd — lane B (`8de9283`). Accept: S3 on review; runtime at CP1.
- [ ] CP1 gate — after A0.1 fixes 1/2/4: Noah walks the greybox, Claude validates.
- [x] A2 NoiseSystem + dynamic-light helper — lane A (`e7c1f68`). Accept: S4 core.
- [x] A3 noise indicators + the two teacher hazards — lane A (`04c34a0`). Accept: S4 full, S10 teacher rows.
- [ ] B2 Door.gd + Snack.gd — lane B. Accept: S9 door/snack rows.
- [ ] CP2 gate — Claude validates, Noah plays every surface; directorial pass 2 on door feel.
- [ ] A4 ambient masking zones — lane A. Accept: S5.
- [ ] A5 GameClock finish, phase director, debug keys, nightstand clock — lane A. Accept: S6.
- [ ] Throwaway web export with one AreaLight3D and one shadow — lane A exports (Claude supplies the template-install command), Claude validates in browser. Accept: S11 smoke.
- [ ] CP3 gate = Thursday exit criteria — Claude validates, Noah scrubs phases with `]`.

## Must — Friday (actors, full loop, banked build)

- [x] B3 Parent.gd — lane B (`9f04c97`). Accept: S7 on review; runtime at CP4.
- [x] B3.1+B3.2 first-walk parent/door fixpack — FOUND chase, clipped cone,
      movement-only sweep, script-owned blockers, snack reveal position, and
      speed retune — lane B (`946cd11`, `351f268`). Accept: S7/S9 at CP4.
- [x] B5 pulled forward — bathroom trip plus phase-4 dining-band lights-off
      route at 1.388–1.421 m/s implied travel — lane B (`dcd5e1e`).
- [ ] B5 scene integration — lane A removes the Parent routine override so the
      script table is authoritative. Accept: S10 route-contest row.
- [ ] CP4 catch-loop gate — Claude validates, Noah plays the catch and the chase.
- [x] B4 Pet.gd — lane B (`bd77d16`). Accept: S8 at CP5.
- [x] A6 win/lose/title/restart — lane A (`d3a9d5d`). First title input starts
      audio + clock, crib-with-snack wins, expiry otherwise loses, R reloads.
      Accept: S9 UI rows automated; full-run play remains at CP5.
- [ ] Snack round trip wired end to end — lanes A+B. Accept: S9 full.
- [ ] CP5 gate: winnable and losable from the title card — Noah plays a full run.
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
