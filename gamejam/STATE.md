# Current State

Update this at the end of meaningful work. Keep it short: it is a dashboard, not
a journal.

## Now

- Jam: GMTK26 — theme: Countdown
- Direction: Shoulda Eaten Dinner (toddler stealth; the countdown is the
  parent's bedtime routine). Locked brief: `gamejam/brief/shoulda-eaten-dinner-brief.md`
- Current phase: `jam-friday` is banked; freeze-safe A22 post-freeze lighting
  polish is complete after the director's positive full-play verdict.
- Next playable checkpoint: tag the green acceptance head, export Web, validate
  the package, and upload the prepared itch page.

## Working build

- Godot version: 4.7.1-stable — A0.2 through A22 plus actor B6–B20 and the
  original/CC0 audio pass are in `game/` (Compatibility renderer). The approved
  director layout bakes a connected 164-polygon navmesh; input, lighting, noise,
  indicator, route, ambient-mask, countdown, game-flow, audio, and A9
  presentation/tuning checks pass.
- Entry scene: `res://scenes/Main.tscn`
- Run/build status: `538d697` clears the stale Parent scene override so B5's
  15-row route is authoritative. `d34f4a8` adds the CC0 audio pass.
  `3def8f8` adds A7: 1920×1080 expand stretch, visible rate-driven fridge
  spill, TV flicker, rate-driven creak, actual dog cues, and snack pickup/drop
  feedback plus reveal clearance. `acaed9d` adds B6's live-clock actor fixes:
  the parent reaches the kitchen, the dog sleeps 30 s then patrols, and
  point-blank sight accelerates suspicion. `3e2e650` adds B7's reachable-crib
  deposit, 20 s carry failsafe, door-close/hall-watch/peek epilogue, and raw
  dog-bark alarm. `33b7832` through `ed2c253` add A8's 0.6-capped tight
  masks, smaller TV-side player rings, and larger emissive pulsing snack with
  carried display, louder pickup, 0.3 s player pop, and camera-clear pantry
  placement. A5.1/B5, B6/B7, A6/A6.1, audio, A7/A8, clean startup, and release
  Web export pass. `8812b29`/`89187fe` add five cool emissive practical
  fixtures, tighten pools to 5.8 m, and lower ambient energy to 0.08 while
  preserving capsule/HUD brightness tracking. A real Web canvas click starts
  audio with zero console warnings/errors; labeled renderer captures prove
  snack, fridge spill, practical-light hierarchy, and dark-floor readability.
  `29d4a57` adds B8: capture drops and pickup-locks the snack without winning,
  25+ received noise immediately investigates, decay is 5/s, and the parent
  performs the exit/close/hall/reopen/peek/reclose/kitchen epilogue. Its live
  SceneTree gate and the B6/B7/A5.1/A6/A7/A8/audio regressions pass.
  `6436fdd` through `606a627` add A10: a scripted bathroom quiet-zone door,
  composite crib/couch/dog silhouettes, reachable kitchen bowl, collisionless
  outward fridge swing, couch-aimed stronger TV pulse, 0.05 ambient energy,
  debug trial-lamp placement, and a 15 dB carpet/hardwood step gap.
  `a9efbae` adds B9 on top with ring-true hearing, bathroom routine staging,
  cone smoothing, endgame hall patrol, and dog bowl visits. Clean committed-tree
  startup plus A10/B9/A4.1/A7/A8/A9/audio gates pass on the combined head.
  `bb1dc61` adds B10 couch glances, 75-suspicion HUNT with newest-noise
  retargeting, and 1.2 run noise. Clean committed-tree startup and B6–B10 pass.
  `6df8cff`/`6b48552` add A11: High positional shadow filtering, 4.5 m
  room-biased Omni sources decoupled from low emissive fixtures, 2.0 blur/0.8
  opacity, forward-aligned dog silhouette, primitive tables/chairs with one
  nav collider per group, front-door side-table lamp, and subtle three-plank
  creaks. Clean committed-tree A11/A10/A9/A4.1/A7/A8/audio/B9/B10 gates pass.
  A11/B11 author the dog snout along local -Z and retain Pet's smooth root yaw
  for patrol, investigate, and bowl travel. Clean committed-tree startup plus
  A11, B6, and B9 pass on the combined head. `b812cbd` adds A12's renderer-only
  1.8 Omni attenuation, 2.2 base energy, 0.04 ambient, and centered dining
  fixture while preserving the analytic light anchors and 0.35 sight boundary.
  `1fada23` adds B12's suspicion-ramped parent cone and dog hearing-radius ring;
  clean committed-tree startup plus B6/B9/B10/B12 pass. A13/A14 produced 208
  audition candidates; A15 now wires the director's 88 selected original voice
  and foley takes through data-defined no-repeat pools, 5–8% pitch jitter,
  context-sensitive carry protests, ordered sequences, a priority-controlled
  VO channel, and CC0 fallbacks. Focused audio plus A6/A7/B7/B8 regressions
  pass. `5a09b2f` adds B13: live post-deposit perception, crib-safe expected
  occupancy, self-door creak filtering, 1.5 m grabs, and a 2.5 m LOS lunge.
  Clean committed-tree startup plus B6–B13 and A15 audio gates pass.
  `9e6be08`/`1565f02` integrate A16 on top of B13: LivingSouth removed;
  150-polygon nav;
  five instant positional/noisy switches; bathroom and initially-dark kid-hall
  practicals; Sun removed; renderer attenuation 2.0 with a 0.05 ambient
  readability fallback; exact south-face/south-west-hinge fridge; hinge audio;
  positional gameplay SFX; universal E/door-progress affordance; TV notes; and
  primitive toy/dog-bed dressing. `043e990` updates superseded legacy gate
  assumptions. `4e39e71` adds B14's phase-expected switch restoration, TV
  listening suppression and couch restore, punishment hall light, escaped-child
  room check, silent magenta VO icon, and rate-derived door audio controls.
  `ccc1df5` wires parent-authored VO indicators, the parent/kid room-dwell
  sequence, and Door-derived creak pitch/volume. Acceptance head `0bfa05e`
  passes editor startup, game startup, and all 24 verification flags under
  strict script-error and resource-leak checks (26/26 total).
  `5e84967` adds B15's per-door-source 0.4 s hearing cooldown, one-cue burst
  grouping, stationary CURIOUS turn, 8 s two-cue escalation window, immediate
  visual escalation, source trace, and live door/bark gate. Exact committed
  startup plus B6–B10/B12–B15 pass.
  `2d4e142` adds A17: 32.0 renderer-only practical energy at attenuation 2.0,
  8+8 CC0 player carpet/wood steps, hinge-origin door sound, exclusive nearest
  interaction with door tie priority, world-anchored prompt/countdown, 0.8
  switch noise, and the dark-start ceiling-disc bathroom/toilet pass. Editor,
  startup, and all 27 verification flags pass (29/29).
  `b14efb3` closes the last WIRING request: B15 CURIOUS plays the director's
  three-take parent investigate/“hm?” pool and its magenta parent indicator
  without gameplay noise. The exact committed head passes 29/29.
  `34b3e9f` adds B16's randomized free-play giggle scheduler and exact 0.5
  gameplay event. Committed startup, A4/A4.1/A6/audio/B7/B15, and the live B16
  timing/carry/result-screen gate pass.
  `a3d0e01` adds B17's Door-to-Snack `ice_cream`/`chips` identity contract and
  persistent public Snack type. Committed startup plus A6/A7/A8/audio/B7/B8/
  B16/B17 pass.
  `338de63` adds A18: conservative clip-profiled denoise for 69 family takes
  with 19 rejected to CC0 fallback; near-silent sneak-step mix; single pickup
  playback and 2.5 s wrapper-audio cadence without changing 0.6 s noise;
  soft B16 idle-giggle playback; and wall-blocked, room-scale practical light
  at 1.45 renderer attenuation/7.8 m range with analytic lighting unchanged.
  Editor import, clean startup, and all 30 verification flags pass on
  `e8f75d5` (32/32); nav remains 155 polygons. Fresh full-house and
  doorway-spill proof captures are committed.
  `bb881ac` adds A19's full geometry-fit pass: the bathroom/pantry/fridge and
  other door panels fill their authored frames; composite props use one exact
  visual-bounds collider; floating/sunk prop and fixture contacts are grounded;
  five switches mount flush on the correct wall axis; and all existing
  wall/floor seams remain sealed. The accurate footprints rebake to 164 nav
  polygons. Editor, startup, and all 31 verification flags pass on `4010224`
  (33/33) with no script-error or resource-leak markers; a labeled
  Compatibility capture is committed.
  `8f92e36`/`0da7c83` add A20/B17 presentation consumption: a bright pulsing
  pantry packet and camera-clear cone/scoop fridge ice cream, typed
  pantry/fridge pickup and 2.5 s carry skins, and the cleaned kid “mmm”
  fridge-pickup pool. Player remains the sole 0.3 loudness / 0.6 s snack-noise
  authority. Exact committed editor, startup, and all 32 verification flags
  pass on `0da7c83` (34/34); nav remains 164.
  B18 core adds a 30-point received-contribution bypass from CURIOUS to
  INVESTIGATE plus immediate non-parent light-toggle awareness. Same-frame
  phase lighting settles before anomaly comparison, so scheduled transitions
  remain clean. `94c3879` adds A21's 15 audited floor-to-5.2 m wall blockers,
  four upper doorway lintels, stable nearest-switch/light lookup, and labeled
  before/after Compatibility captures. `11886b8` guards B18's deferred light
  comparison across the A6 scene reload. Exact combined editor, startup, and
  all 34 flags pass on `11886b8` (36/36), nav remains 164. B18 searchlight
  routing now makes one nearest-off-switch diversion during dark INVESTIGATE
  or HUNT, turns it on, and resumes the live target without retry oscillation;
  working-tree B18 observes one attempt/completion and 0.51 m resumed motion
  in both states. B19 lowers only Player's exported sneak multiplier to 0.2:
  live hardwood/creaky/toy emissions are 0.2/0.6/0.8, run-hardwood remains
  1.2, and only the plain sneak step stays below the 0.25 indicator gate.
  `cf2f26f` closes B20's caught-snack win exploit. `281cbab` adds A22's two
  switchable overhead corridor fixtures and flush-ceiling dining, kitchen,
  hall, and foyer restyle. Corridor analytic probes read 0.72/0.58/0.72 on
  and 0.05/0.30/0.31 off, so point-blank parent sight crosses the unchanged
  0.35 threshold only while the route is lit. Exact editor, startup, and all
  38 verification flags pass (40/40); nav remains 164 polygons.
  `cebba87` adds A24: wall switches keep their soft positional click but emit
  zero gameplay noise, while the existing visual light-anomaly path remains
  green. All three squeaky-toy hazards widen to one flat 2.6 × 1.4 m overlay
  with spread pill/train/block silhouettes. Exact editor, startup, and all 39
  flags pass (41/41 functional gates); nav remains 164.
- Remote: https://github.com/mrglass86/gmtk-gamejam-2026 — pushed and tracking
  (2026-07-23). Repo-local URL carries the `mrglass86@` prefix to bypass the
  machine's work-GHE rewrite; work repos unaffected. Push after every green gate.
- Codex: ChatGPT macOS app, local full-access harness; godot MCP bridge
  (Coding-Solo) + Context7 configured in ~/.codex/config.toml 2026-07-23; jam
  folder pre-trusted. App restart required to load them; 30-min abort stands.

## Current focus

- Freeze/export/upload. A22 and A24 are implemented; only director in-motion
  presentation verdicts remain before export.

## Known blockers or risks

- A12 is functionally and Compatibility-renderer verified but awaits the
  director's contrast verdict; the darkest adult/pantry pockets remain
  intentionally readable. A16 raised the ambient fallback to 0.05 after its
  Sun-free capture audit.
- Several approved original pools are thin: single takes for dog attention,
  win “mmm,” deposit sniffle, snack-drop voice, fridge hum/pop, sink, and
  toilet; immediate-repeat protection cannot add variety there. Light-switch,
  clock, pet, stings, snack pickup/thud, and other unfilled cues retain CC0.
- Fridge pickup intentionally reuses the single cleaned kid “mmm” take, while
  its scoop/spoon textures are quiet pitched treatments of existing CC0 snack
  SFX; CP5 supplies the final in-motion mix verdict.
- One director pick remains deliberately unassigned (`kid-kitty-cat`); it is
  not copied into the runtime tree.
- The scaffolded input map was hand-serialized — lane A verifies it in A0.
- Route timing remains unmeasured in play; tune furniture/entrances only if the
  quiet route misses the 1.4–1.6× target.
- The dog's exported bed-egress point works in the live verifier; CP5 still
  needs a visual verdict that the rise-off-bed motion reads naturally.
- B8's post-deposit sequence is live-verified but needs a director verdict that
  the immediate close, hall walk, slow crack-open peek, and reclose read clearly
  at gameplay camera scale.
- B10 mechanically defeats the scripted sprint; director run six must judge
  whether HUNT feels threatening rather than predetermined.
- B14 actor and AudioDirector gates are green; the remaining risk is the
  director's live timing/mix verdict.
- B18 searchlight routing is isolated behind one-attempt-per-light bookkeeping;
  export smoke still supplies the final visual verdict on switch detours.
- A18's renderer gate and labeled captures are green; 6.5 practical energy at
  1.45 attenuation/7.8 m range is renderer-only and still needs the director's
  in-motion contrast verdict.
- A22's analytic threshold proof is green, but the director must still judge
  the corridor exposure and overhead-fixture readability in motion.
- A19's 164-polygon nav and actor-route gates are green. Its collider fit is
  intentionally tighter than A18; the director still judges the closed
  bathroom/pantry silhouettes at gameplay scale.
- Godot MCP for lane A: 30-minute hard abort rule (brief 9.2).
- This Claude instance has no shell — validation runs through the web build in
  the browser pane plus Noah's terminal.
