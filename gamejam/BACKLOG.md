# Backlog

Keep this actionable and ordered. Tasks should be small enough to verify.
Owners: Noah (director), lane A / lane B (Codex), Claude (validation).
Acceptance tests live in `gamejam/VALIDATION.md` (S-numbers).

## Must — Thursday (build order 1–6 + export smoke)

- [x] Choose the direction and log it (Shoulda Eaten Dinner) — DECISIONS 2026-07-23.
- [x] Scaffold the Godot 4.7.1 project: project.godot, autoload stubs, input map, Main.tscn — Claude.
- [x] Brief in repo, git init, kickoff commits, first push to personal GitHub — done 2026-07-23.
- [x] MCP verification — closed as moot: lanes verified everything via headless
      runs all day; the wired bridge was never load-bearing, no abort spent.
- [x] A0 greybox level, camera, actor stubs, scaffold verification — lane A (`527dba7`, `aa4fbf4`). Accept: S1 pending CP1 walk.
- [x] A0.1 review fixes — static-collider startup nav bake, lighting wash,
      re-shot layout, BedroomDoor placement, and Player wiring (`aa4fbf4`).
- [x] Directorial pass 1 OUTCOME: relayout approved after the director's
      hallway-rug and locked-front-door rulings.
- [x] A0.2 relayout — director plan, goal moves, hazard re-siting, connected
      155-polygon nav bake, and refreshed labeled capture (`50e550f`, `9d5fd6f`).
- [x] A1 LightSystem — lane A (`8eff7c4`). Accept: S2 on review; runtime spot-check at CP1.
- [x] B1 Player.gd — lane B (`8de9283`). Accept: S3 on review; runtime at CP1.
- [x] B1.1 movement texture — timer-synced Capsule hop, landing squash, and run
      lean without velocity changes — lane B (`af3464a`). Polish; cut anytime.
- [x] CP1+CP2 — closed via the director's two walk sessions plus the A4.1/A5.1
      and B3.1/B3.2 fixpacks; residual runtime verdicts (catch/chase feel, hop
      feel, snack grab) fold into CP4/CP5.
- [x] A2 NoiseSystem + dynamic-light helper — lane A (`e7c1f68`). Accept: S4 core.
- [x] A3 noise indicators + the two teacher hazards — lane A (`04c34a0`). Accept: S4 full, S10 teacher rows.
- [x] B2 Door.gd + Snack.gd — lane B (`98c9d10`). Accept: S9 door/snack rows on
      review. B3 fold-in: gate `_can_open` on `not _player.input_locked` so a
      carried player holding interact cannot crack a door.
- [x] Door + Snack scene wiring — lane A (`50e550f`).
- [x] A4 ambient masking zones — lane A (`18dd081`). Accept: S5 automated check.
- [x] A4.1 first-walk fixpack — seam overlaps, walkable hazard plates, ajar
      bathroom door, live brightness lookup, and world-anchored expiring rings
      (`1ade35d`).
- [x] A5 GameClock, pure phase director, debug keys, and world nightstand clock
      — lane A (`7d301fc`). Accept: S6 automated check.
- [x] A5.1 second-walk fixpack — overlap every floor seam, add the non-nav
      failsafe slab, flip the fridge hinge, and retime Parent travel
      (`003e714`).
- [x] S11 Web export smoke — headless export clean; Safari title verified;
      Claude's Chrome proof: zero console errors, first input starts the game,
      AreaLight glow + shadows render on Compatibility, readout live; the
      director's foreground localhost run confirmed playable. A6.1 follow-ups
      filed (camera KEEP_WIDTH, FirstInputAudio web warning, debug label).
- [x] CP3 gate = Thursday exit criteria — met, with the entire build order
      implemented on day one.

## Must — Friday (actors, full loop, banked build)

- [x] B3 Parent.gd — lane B (`9f04c97`). Accept: S7 on review; runtime at CP4.
- [x] B3.1+B3.2 first-walk parent/door fixpack — FOUND chase, clipped cone,
      movement-only sweep, script-owned blockers, snack reveal position, and
      speed retune — lane B (`946cd11`, `351f268`). Accept: S7/S9 at CP4.
- [x] B5 pulled forward — bathroom trip plus phase-4 dining-band lights-off
      route at 1.388–1.421 m/s implied travel — lane B (`dcd5e1e`).
- [x] B5 scene integration — Parent scene override removed; B5's 15-row script
      table is authoritative (`538d697`, `--verify-a51`).
- [ ] CP4 catch-loop gate — Claude validates, Noah plays the catch and the chase.
- [x] B4 Pet.gd — lane B (`bd77d16`). Accept: S8 at CP5.
- [x] A6 win/lose/title/restart — lane A (`d3a9d5d`, `0223b1b`). First title
      input starts play + clock; crib-with-snack wins immediately or at expiry,
      expiry otherwise loses, and R performs a real scene reload. S9 UI rows
      formally verified; title verified live in Chrome.
- [x] A6.1 Web follow-up — `KEEP_WIDTH` camera at 31 m, placeholder generator
      removed, and brightness debug HUD release-gated (`e26ce9c`).
- [x] A7 presentation fixpack — 1920×1080 expand stretch, visible rate-driven
      fridge spill, subtle TV flicker, rate-driven held-door creak, actual dog
      cues, and snack pickup/drop plus reveal clearance (`3def8f8`,
      `--verify-a7`).
- [ ] Snack round trip wired end to end — lanes A+B. Pickup/drop feedback and
      reveal clearance are verified; accept the complete interaction in S9.
- [ ] CP5 gate: winnable and losable from the title card — Noah plays a full run.
- [ ] Route timing measured from Noah's runs, tuned to 1.4–1.6x — lane A adjusts. Accept: S10.
- [ ] 19:00 freeze: Noah pastes the tag ritual, lane A exports, Claude validates, Noah uploads the itch draft (walkthrough supplied).

## Should — Saturday (feel day)

- [x] Audio pass pulled forward — CC0 countdown tells, surface/player and parent
      footsteps, stings, pet cues, held-door creak, and positional masking beds
      (`d34f4a8`, `--verify-audio`, release Web click clean).
- [ ] Director audio mix walk — verify the three countdown tells read above the
      beds and tune `AudioDirector` export volumes only.
- [ ] One outside playtester, watched silently; fixes prioritized by Claude via playtest-critic lens.
- [ ] Tuning pass from the playtest — Noah verdicts, lanes apply.
- [ ] Submission page: screenshots, GIF of a ring resolving, controls, the
      theme-reading sentence — Claude drafts, Noah posts.

## Could — only if everything above is green by Saturday 15:00

- [ ] Dithering post-process per brief 11 (band edge at brightness 0.35, actors excluded).
- [ ] OR 2D sprite actors (director stretch, competes with dithering — pick one):
      flat-tinted silhouette sprites at the fixed camera angle, capsule kept as
      invisible collider + shadow-caster, tip-toe frames synced to the footstep
      timer, existing hue/brightness language preserved. Rigged 3D GLBs stay
      parked post-jam (brief scope lock).
- [ ] Extra hazard placement and routine rows beyond the minimums — from Noah's play notes.

## Cut / parked — invoke via PLAN.md section 4 trip-wires, in this order

1. Dithering (gated above).
2. The pet entirely.
3. Ambient masking (TV stays as light + sound).
4. The second route (block the dining doorway).
5. The round trip (one-way to the pantry, clock ~180 s).

Never cut: three movement speeds, brightness detection, noise → suspicion, the
clock, lights going out as it drains.
