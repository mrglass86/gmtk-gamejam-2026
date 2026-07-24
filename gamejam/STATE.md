# Current State

Update this at the end of meaningful work. Keep it short: it is a dashboard, not
a journal.

## Now

- Jam: GMTK26 — theme: Countdown
- Direction: Shoulda Eaten Dinner (toddler stealth; the countdown is the
  parent's bedtime routine). Locked brief: `gamejam/brief/shoulda-eaten-dinner-brief.md`
- Current phase: Saturday — original-audio integration, mix walk, and feel
  tuning.
- Next playable checkpoint: director audio/CP5 run — hear the context-sensitive
  catch/carry/deposit sequence, original routine voice and foley, countdown
  tells, and full win/lose loop together.

## Working build

- Godot version: 4.7.1-stable — A0.2 through A12 plus A4.1/A5.1 and the CC0
  audio pass are in `game/` (Compatibility renderer). The approved director
  layout bakes a connected 157-polygon navmesh; input, lighting, noise,
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
  pass.
- Remote: https://github.com/mrglass86/gmtk-gamejam-2026 — pushed and tracking
  (2026-07-23). Repo-local URL carries the `mrglass86@` prefix to bypass the
  machine's work-GHE rewrite; work repos unaffected. Push after every green gate.
- Codex: ChatGPT macOS app, local full-access harness; godot MCP bridge
  (Coding-Solo) + Context7 configured in ~/.codex/config.toml 2026-07-23; jam
  folder pre-trusted. App restart required to load them; 30-min abort stands.

## Current focus

- Noah runs the authoritative audio/CP5 route: red-handed and empty-handed
  catches, carry/deposit VO, routine lines, bathroom and kitchen foley,
  countdown tells, and final mix balance against the full win/lose loop.

## Known blockers or risks

- A12 is functionally and Compatibility-renderer verified but awaits the
  director's contrast verdict; the darkest adult/pantry pockets remain
  intentionally readable.
- Several approved original pools are thin: single takes for dog attention,
  win “mmm,” deposit sniffle, snack-drop voice, fridge hum/pop, sink, and
  toilet; immediate-repeat protection cannot add variety there. Light-switch,
  clock, pet, stings, snack pickup/thud, and other unfilled cues retain CC0.
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
- Godot MCP for lane A: 30-minute hard abort rule (brief 9.2).
- This Claude instance has no shell — validation runs through the web build in
  the browser pane plus Noah's terminal.
