# Shoulda Eaten Dinner — Build Brief

*Countdown jam entry. The kid is hungry because they didn't eat their dinner.*

**Engine:** Godot 4.7.1 · **Camera:** 3D orthographic · **Deadline:** playable Saturday
**Art:** untextured primitives only. No imported assets, no character animation.

---

## For the planner

This document is the output of the design phase. Your job is scheduling and task
decomposition, not redesign.

**Locked — do not reopen.** The concept, win/lose rules, caught-is-not-a-loss, the two
clock inversions (darker-safer, quieter-riskier), the interfaces in section 3, sneak as
default, the goal-door mechanic, half-height walls, no visibility dimming, the colour
language, the noise indicator design and its threshold, the two-route layout, the
teaching sequence, and the cut order in 12.1. If a locked decision seems to conflict
with the schedule, the resolution is the cut order — not a design change.

**Yours to decide.** Task sequencing within the build order's constraints, how work
splits across the two coding agents beyond the ownership table in 9.3, what lands
Thursday versus Friday, and when to invoke the cut order.

**Open items the design intentionally leaves to playtesting.** Every tuning number
(section 10), apartment dimensions, hazard placement beyond the two teachers, which
sounds map to which events, dog versus cat, and whether dithering (11) or the routine
extensions (5.4) happen at all.

**Hard constraints.** All-day availability Thursday and Friday; done by sometime
Saturday. Friday ends with a tagged, exported, playable web build regardless of state
(12.2). Sunday is submission only. The solo dev works primarily via voice and prefers
delegating execution to agents — plan for review-and-decide loops, not hands-on-keyboard
time, outside the editor tasks reserved to him in 9.3.

---

## 0. Version notes — read this to the agents first

Target is **Godot 4.7.1**, released June 2026. Both agents will have training data older
than this. State the version explicitly in every session and pair it with Context7.

- **`AreaLight3D` is new in 4.7 and you should use it.** It's a rectangular real-time
  light source, added specifically for windows, monitors and TV panels. Before 4.7 you
  faked these with clusters of point lights. Use it for the TV, the under-door strip
  from the parent's room, and the window. An agent that predates 4.7 will not reach for
  it and will hand you an `OmniLight3D` cluster instead.
- **Scene Paint Mode** stamps prefab scenes with a brush — the fast way to scatter the
  toy patch and furniture during blockout.
- **Vertex snapping** (hold `B`) and Path3D snap-to-colliders make modular grey-boxing
  much quicker.
- **Do not enable HDR output.** It's the 4.7 headline feature and irrelevant to a web
  export. It will only cost you time.
- 4.7 is weeks old. If something behaves oddly, suspect the engine before suspecting
  your code, and don't spend a jam debugging an engine regression.

Reject any Godot 3 idiom on sight: `Spatial`, `KinematicBody`, `connect("signal", self,
"_method")`, `yield`. In 4.x it's `Node3D`, `CharacterBody3D`,
`signal_name.connect(callable)`, `await`.

---

## 1. Concept

A toddler is out of the crib. The pantry is across the apartment. The parent is doing
their bedtime routine, and when it finishes they check the bedroom.

**Win:** reach the fridge or pantry, take the snack, and be back in the crib before the
parent opens the bedroom door.
**Lose:** the parent opens the door and you aren't in the crib, or you aren't holding a
snack.

**Caught is not a loss.** The parent carries you back to the crib and the run continues.
The clock never stops or rewinds, so the punishment is the distance you have to cover
again — no arbitrary time penalty needed, and no restart flow to build. A judge who is
bad at this game still sees all of it in one continuous session.

If you're caught on the return leg, you drop the snack and have to go back for it.

The clock is visible as a nightstand clock in the world — red numerals, readable from
the ortho camera. Not a HUD element.

---

## 2. Scope

### In
- Ortho camera over half-height walls, capsule player, three movement states (sneak default, run held)
- Brightness query — is the player lit? — with the player capsule as the exposure readout
- Noise as a continuous value derived from speed × surface, with a visibility threshold
- Ambient noise zones that mask footsteps (TV, speaker) and switch off with the routine
- Magenta noise indicators: reach rings + source icons, sustained-sound streams
- Parent on a time-indexed routine who progressively turns lights off; sweeping vision cone
- Parent suspicion, expressed through the parent's behaviour and cone rather than a bar
- Patrolling pet that investigates noise and barks (noise amplifier, no vision)
- Squeaky bedroom door and fridge/pantry goals — all one hold-to-open verb, rate sets risk
- Two routes trading noise risk against light risk; clock re-prices them
- Round trip: snack, wrapper noise, back to the crib before the parent checks
- Win/lose states, title card, restart

### Out — do not build these
- Any skeletal animation or rigging. Player/parent/pet are primitives with a
  squash-stretch tween on movement.
- **Wall dissolve or fade shaders.** See section 6.1 — the geometry solves this.
- **Visibility-based dimming of rooms the player can't see into.** See section 6.2.
  This actively breaks the core mechanic.
- Stairs, second floor, multiple bedrooms.
- Tripping, stumbling, or knockdown. Toys are a loud floor surface, nothing more.
- Inventory, dialogue, cutscenes, menus beyond title and restart.
- Imported 3D assets, texture generation, PBR materials.
- Save system, settings, audio mixer UI, HDR output.

---

## 3. Interfaces — lock these before writing anything else

Three autoloads. Every other script talks to them through these signatures only.
Agents working in parallel must not change these without a note in the repo.

```gdscript
# LightSystem.gd  (autoload)
func get_brightness_at(pos: Vector3) -> float   # 0.0 dark .. 1.0 fully lit
func set_zone_enabled(zone: String, on: bool) -> void
signal lighting_changed()

# NoiseSystem.gd  (autoload)
func emit_noise(pos: Vector3, loudness: float, source: Node) -> void
func get_mask_at(pos: Vector3) -> float   # 0.0 silent .. 1.0 fully masked
signal noise_emitted(pos: Vector3, loudness: float, source: Node)
# Listeners handle their own distance falloff. The system does no filtering.

# GameClock.gd  (autoload)
var time_remaining: float
var phase: int                                  # 0..3
signal phase_changed(phase: int)
signal time_expired()
```

`get_brightness_at` is computed analytically from registered light positions, radii and
on/off state — **not** sampled from the rendered frame. Keep it independent of the
visual lighting so it stays cheap and testable.

---

## 4. Systems

### LightSystem
- Lights are registered in named zones: `bedroom`, `hall`, `living`, `kitchen`.
- Each light has a position, radius, and on/off flag.
- Brightness at a point is the max contribution of any enabled light, with linear
  falloff to zero at the radius edge.
- Emits `lighting_changed` when any zone toggles so listeners can re-evaluate.

### NoiseSystem
- A pure broadcast bus. No spatial partitioning; the scene is small.
- Anything can emit: player footsteps, the door, the pet's bark.
- **Ambient masking.** Registered ambient sources (TV, kitchen speaker) define a radius
  within which footstep loudness is reduced. `get_mask_at()` returns the strongest
  overlapping mask at a point; the player's emitted loudness is multiplied by
  `(1.0 - mask)`. Near a playing TV you can move at walk speed and get away with it.
- Ambient sources switch off with the routine, so masking disappears as the clock
  drains. Same shape as the lights: the world changes under the player as time runs out.

### GameClock
- Total run length: 300 seconds, counting down. Longer than a one-way run because the
  player has to get back.
- Four phases at 25% intervals. On each `phase_changed` the parent's routine advances
  and the world quiets and darkens:

| Phase | Light off | Ambient off |
|---|---|---|
| 1 | `living` | — |
| 2 | — | TV |
| 3 | `kitchen` | kitchen speaker |
| 4 | `hall` | — |

- **The two inversions are the whole design.** Darker means safer to be seen in, quieter
  means riskier to move in. They arrive on different phases so the player is never
  getting a pure upgrade — each phase makes one thing better and one thing worse.

---

## 5. Actors

### Player
**Sneak is the default state. Running is a held modifier.** Not the other way round —
the countdown already pressures the player to hurry, so hurrying must be an active
choice made against their better judgement. Releasing the key should feel like relief.

| State | Speed | Noise multiplier | Input |
|---|---|---|---|
| Still | 0 | 0 | no movement input |
| Sneak | 1.2 m/s | 0.4 | movement input (default) |
| Run  | 3.0 m/s | 1.0 | movement + hold `Shift` / controller trigger |

Each footstep emits noise: `loudness = speed_mult × surface_mult`.

Surface multipliers, read from the floor collider's group:

| Surface | Multiplier |
|---|---|
| Carpet | 0.2 |
| Hardwood | 1.0 |
| Creaky board | 3.0 |
| Scattered toys | 4.0 |

Being in light does not emit noise — it feeds suspicion directly (see Parent).

**Carrying the snack.** After the pantry, the player emits a low constant noise
(loudness 0.3, every 0.6s) from the wrapper regardless of movement state — including
while standing still. Standing perfectly quiet is no longer available, so the return
leg is a different game with the same level. One flag, one timer.

### Goal interaction — the fridge and the pantry

Two goals, two risk profiles. The player picks which detection channel to gamble on.

| Goal | Risk | Behaviour while opening |
|---|---|---|
| Fridge | **Light.** Spills brightness into the kitchen. | Light spill scales with how far open the door is. |
| Pantry | **Noise.** Creaking hinges. | Emits noise continuously while moving. |

**The opening mechanic reuses the run key. No new controls.**

Hold interact and the door's `openness` fills from 0 to 1. The *rate* is set by whether
the player is also holding run:

- **Sneak-open** — roughly 5 seconds. Light ramps up gradually, creak is quiet and
  spread out. Suspicion accumulates slowly but for a long time. Burns clock.
- **Rush-open** — roughly 1 second. Sudden flash from the fridge, sharp bang from the
  pantry. Suspicion spikes hard but briefly. Cheap in clock.

**Noise and light spill are proportional to the rate of change of `openness`, not to
`openness` itself.** That's what makes both options genuinely viable rather than one
dominating: a long quiet exposure and a short loud one are different bets, not better
and worse.

Releasing interact pauses the door where it is. You can crack the fridge open, wait for
the parent's cone to sweep past, and continue. That falls out of the implementation for
free and it's the best moment in the game.

This is the climax, and it's the one time the game forces the player to be loud and
stationary on purpose — ideally while the parent is in the kitchen on their drink run.

### Shared: navigation

Reversing an earlier call in this brief. Investigate targets are arbitrary points, not
waypoints, so waypoint lerping no longer covers it.

Use `NavigationRegion3D` baked from the floor, with `NavigationAgent3D` on the parent and
the pet. In Godot 4.7 this is mature and it is genuinely less work than hand-rolling a
waypoint graph.

One gotcha: half-height walls must still block navigation. Confirm they have collision
and that the agent height is set below wall height, or the navmesh will happily bake
straight over them.

### Shared: behaviour stack

Both actors run a **base behaviour** with **investigate pushed on top**.

The base behaviour is a pure function of time — `get_base_target(t) -> Vector3` — not a
sequence with an index. When investigate finishes, the actor doesn't resume where it left
off; it resumes where the clock says it should be *now*. The world kept running while
they were distracted.

This is the single most important structural decision in the actor code. It removes an
entire class of resume bugs, and it makes the stretch goals in section 5.4 free.

### Parent

**Routine (base).** Data, not code. An array of `{ time, position, dwell, facing }`
entries that `get_base_target()` interpolates. Adding behaviour to the parent should mean
adding rows to a table, never writing a new state.

**Vision.** A 60° cone, 7 m range, rendered as a flat translucent triangle on the floor
parented to the parent's body.

- The cone **sweeps** — oscillate its yaw ±35° on a slow sine while in routine. No
  animation required, just rotate the node. This creates readable timing windows and is
  the cheapest tension in the build.
- Detection requires all three: inside the cone, clear line of sight, and
  `LightSystem.get_brightness_at(player) > 0.35`. Standing in the dark inside the cone is
  safe, which is the entire promise of the game.
- Tint the cone toward amber as suspicion rises. One line, large readability gain.

**Suspicion**, float 0–100:
- Noise heard: `+loudness × 10 × falloff`, linear over an 8 m radius, after masking.
- Seen (all three conditions above): `+25/second`.
- Decay when neither applies: `-8/second`.
- At 50: push `INVESTIGATE` on the last noise or sighting position.
- At 100: caught.

**Investigate.**
- Navigate to the remembered position, look around for **4 seconds maximum**, then pop
  back to the routine.
- **Hard timeout on the whole state — 10 seconds, no exceptions.** Without it, a parent
  who parks on the pantry while the clock drains is an unwinnable run the player can do
  nothing about.
- 8-second cooldown before the same actor will investigate a position within 2 m of one
  it just checked. Otherwise noisy floors produce an investigate loop.

Suspicion is never drawn as a bar. Express it: the parent pauses, straightens, turns their
head, calls out softly. Between the sweeping cone and its tint, the player has everything
they need.

### Pet

State machine: `BASE → ALERT → INVESTIGATE → BARK → BASE`.

- **Base behaviour is a patrol loop** — a short fixed circuit at 1.5 m/s, same
  time-indexed function as the parent's. This is less code than random wander, not more,
  and a learnable pet is a fair pet.
- On `noise_emitted` within 6 m, enters `ALERT`.
- **`ALERT` holds for 1.0 second before anything happens** — stops moving, ears up, soft
  chirp. This telegraph is not optional. Without it the pet reads as random punishment.
- `INVESTIGATE`: navigates to the noise position. If the player is within 2 m on arrival,
  enters `BARK`. Same timeout and cooldown rules as the parent.
- `BARK` calls `NoiseSystem.emit_noise(pos, 5.0, self)` — the pet is a noise amplifier,
  not an independent threat. The parent hearing the bark is what actually hurts.
- The pet has no vision cone. It is a noise creature only. Two detection models is one
  too many for the player to hold in their head.

### 5.4 Routine entries worth adding once the table exists

Because the routine is data, these cost rows rather than engineering:

- **Drink retrieval.** Parent gets up around phase 2, walks to the kitchen, dwells 15 s,
  returns to the couch. Promote this above "if we have time" — a parent walking into the
  kitchen while you're at the pantry is the best tension the game can produce, and it's
  four rows in a table.
- **Bathroom trip**, phase 3, crossing the hall — puts a body in the corridor you need.
- **Lights-off walk**, phase 4, the parent moving room to room switching lamps off, which
  is already happening in the clock and just needs the parent co-located with it.

---

## 6. Camera, walls, and readability

### 6.1 Walls are half-height. There is no fade shader.

The camera is a fixed orthographic view of the whole apartment. Interior walls are
**waist-height** — roughly 1.2 m. At an ortho angle they read unmistakably as room
boundaries, and they never occlude anything.

This replaces the entire wall-fade problem. No dissolve shader, no camera raycasting, no
per-material alpha, no room-visibility state machine.

It also protects the core mechanic: **a half-height wall still casts a full shadow
across the floor.** Long low-angle shadows are exactly what this game wants, and
furniture — sofa, counter, table, crib — does the meaningful shadow-casting anyway.

If a fade is ever genuinely needed, the next step up is toggling `visible` on a wall
group with an alpha tween, about thirty lines. A dissolve shader is the third option and
it is out of scope: the hard part isn't the dissolve, it's keeping faded walls casting
shadows, which means juggling `cast_shadow = SHADOW_CASTING_SETTING_SHADOWS_ONLY` on top
of the shader and is a day of work on its own.

### 6.2 Do not dim rooms by visibility

Brightness in this game means *safe or unsafe*. If dimness also means *you can't see in
here*, the player has no way to tell the two apart, and the single signal the entire game
is built on becomes ambiguous.

Render the apartment as it is actually lit. The whole floor plan is visible at all times.
Tension comes from the parent's routine and the clock, not from hidden information — and
a stealth game where you can see everything and still can't act is more tense, not less.

### 6.3 Noise indicators

Hot pink — true magenta, high blue content, not a warm pink. See 6.4 for why.

**Two elements per noise event, with two different jobs.** Don't make one thing carry
both.

**The ring carries reach.** A flat expanding ring on the floor at the noise position,
rendered as 8 short radial spokes rather than a solid circle for the retro read. It
expands from zero to **exactly the audibility radius of that event** and fades to nothing
as it arrives there.

This makes the ring a measurement, not decoration. A footstep's ring is small; a bark's
ring is huge. The player learns the entire noise model by watching it, and can judge
before they move whether a sound will reach the parent.

The ring shows **audibility, not consequence** — whether the listener can hear it at all
from there. Whether it actually triggers an investigation also depends on accumulated
suspicion, and that's what the actor's colour already communicates. Two channels, cleanly
divided: pink says *can they hear this*, actor colour says *how close are they to acting*.

**The icon carries identity.** A billboarded `Sprite3D` at the source that rises about
half a metre and fades over 1.2 seconds. Musical note from the speaker, wavy lines from
the TV, a jagged glyph from the dog toy, a small puff from footsteps, a bark mark from
the pet. Scale maps to loudness.

**Sustained sounds emit a stream, not a pulse.** A door creak or a slowly opening pantry
emits many small rings over its duration while its icon jitters in place. The jitter is a
random per-frame offset of a few pixels and reads as grinding, drawn-out sound.

This is what makes the climax legible: **sneak-opening the pantry produces a long trickle
of small rings, rush-opening produces one enormous one.** The player can see the two risk
profiles rather than being told about them.

**Masking becomes visible for free.** The player's ring radius is computed from
*post-masking* loudness, so walking near the playing TV visibly shrinks your own rings.
The mechanic teaches itself.

**Below a threshold, nothing renders.** Only noise that could plausibly matter draws a
ring. Sub-threshold sounds still *play* — the player hears their own quiet footsteps —
they just don't appear.

Make the threshold **absolute, not contextual.** Gate on the event's own post-masking
loudness, not on whether a listener happens to be in range. Contextual gating is more
precise and worse: the same footstep would show pink in the hallway and nothing in the
bedroom, so the player could never build a stable model of their own noise without
also tracking where everyone is. Predictability beats precision for a signal used to make
split-second decisions.

Starting threshold: **loudness 0.25.** With the multipliers in section 5 that separates
cleanly:

| Action | Loudness | Renders |
|---|---|---|
| Sneak on carpet | 0.08 | no |
| Sneak on hardwood | 0.40 | yes |
| Run on hardwood | 1.00 | yes |
| Sneak on a creaky board | 1.20 | yes |
| Run through toys | 4.00 | yes |

Carpet therefore becomes a **visibly silent highway** — a route that produces literally
nothing on screen. That's a strong, quickly-learned reward for good play, and it's worth
laying the carpet out with that in mind.

**Give the floor a readable surface value.** The ring is reactive — it tells you what a
step cost after you took it. In a greyscale world you have value and pattern spare, so
make carpet, hardwood and creaky boards visually distinct from each other. The floor
tells the player before they step; the ring confirms after. Between them the player has
both halves, and neither needs a tutorial.

The division of labour: **audio carries texture, the magenta channel carries threat.**

Roughly forty lines and a handful of primitive icons, and it turns an invisible system
into a learnable one. Build it immediately after `NoiseSystem`, not at the end.

---

### 6.4 Colour language

The world is greyscale — black, white, and greys, desaturated to near zero at night. All
hue is reserved for actors.

**This is not just a style choice, it's mechanically load-bearing.** With hue removed from
the environment, *value* is the only visual variable left in the world — and value is
precisely what the game asks the player to read. Nothing competes with the brightness
signal.

The rule that keeps it clean: **hue belongs to actors, value belongs to the world.**

| Element | Colour |
|---|---|
| World, walls, furniture, floors | Greyscale, low value at night |
| Player | Cool blue |
| Parent and pet, base state | Pale purple |
| Parent and pet, investigating | Yellow |
| Parent and pet, player found | Red |
| Noise indicators | Hot magenta — information, not threat |

**Lamps must be neutral white, not warm.** A warm tungsten lamp puts yellow into the
environment and yellow is spoken for. Keep all light sources neutral or very slightly
cool so the warm end of the spectrum means exactly one thing: escalation. The TV's
`AreaLight3D` can be cool-blue and flickering; that reads as a TV without competing.

**Push the noise pink toward true magenta, away from red.** Something like `#FF2D95`
rather than `#FF4466`. Red means *found you* and it's the one collision in this palette
worth engineering around.

There's a tidier justification than hue distance, though. The rule is cool-is-you,
warm-is-trouble — and magenta is the one hue that isn't on the spectrum at all. Using the
non-spectral hue for the channel that sits outside the threat axis is the right kind of
consistent. Noise isn't danger; it's information about danger.

Motion disambiguates it further: alert red is a large solid actor body, noise magenta is
small particles expanding outward and fading. Different shape, different behaviour,
different place on screen.

**Blue for the player rather than pink.** It gives you a clean spectrum-wide rule — cool
is you, warm is how much trouble you're in — and it keeps the player from competing with
the alert states for attention.

### 6.5 The player capsule is the safety readout

Modulate the player's albedo and emission by `LightSystem.get_brightness_at()`.

- In shadow: dim, desaturated, close to the greyscale world.
- In light: bright, fully saturated blue.

The player's own body becomes the exposure indicator. No HUD, no icon, no meter — you
glance at yourself and know. This is a handful of lines and it's the highest-value single
visual in the build.

### 6.6 Do not let colour be the only channel

Roughly one in twelve men has some colour vision deficiency, and purple-to-red is not a
safe pair. Every state change must be legible a second way:

- **Investigating**: the actor stops dead, then moves deliberately. The vision cone
  narrows and its sweep stops.
- **Found**: the actor accelerates. The cone snaps wide and locks onto the player.

Motion carries the state; colour confirms it. Neither alone.

### 6.7 Audio

The brief has been silent about this and it's the most underestimated item left. A
stealth game with no audio is unshippable, and the countdown is partly *told* through
sound.

**Minimum set — about a dozen clips, all CC0.** Freesound and Kenney's audio packs cover
all of it. Do not record anything.

| Sound | Job |
|---|---|
| Footstep ×3 surfaces (carpet, hardwood, creak) | The player hears their own noise even below the visual threshold |
| Toy squeak | Hazard |
| Door creak (loopable) | Sustained-sound treatment |
| Fridge hum, TV murmur, speaker music | Ambient beds that also *are* the masking zones |
| Pet chirp, pet bark | Telegraph and payoff |
| Parent footsteps | Position tracking |
| Clock tick | Countdown pressure |
| Win / caught stings | Feedback |

**Three sounds are load-bearing for the countdown**, because they're how the player feels
time passing without reading the clock: the **TV clicking off**, a **light switch**, and
the **parent's footsteps changing direction**. Those three carry the phase transitions.
Get them in even if everything else is placeholder.

**Ambient beds double as the masking zones.** Where you hear the TV is where you're
masked. The audio, the magenta rings, and the mechanic all agree, and none of it needs
explaining.

Budget: two hours, Saturday. Sourcing eats more of it than implementation.

### 6.8 Teaching, in the first thirty seconds

There is no tutorial and there shouldn't be. Judges play for five minutes.

**The bedroom door teaches the pantry door.** Same verb, same hold-to-open, same
rate-controls-noise rule — but at the start of the run, with nobody nearby, where getting
it wrong costs nothing. By the time the player reaches the fridge they already know how
doors work and the tension is pure.

**The first creaky board teaches surfaces.** It sits in the hallway directly outside the
bedroom door — before the routes split, so every player meets it and nobody can route
around it. Two placement rules make it a teacher rather than a punishment:

- **Outside the parent's hearing radius.** The lesson is "that's what a creak looks
  like," not "you lost forty seconds." Consequence-free the first time, same logic as the
  door.
- **A strip of carpet immediately after it.** Creak, magenta ring, then a step onto
  carpet and the rings stop dead. The contrast is the lesson — one board teaches the
  hazard, the surface language, and the reward for reading floors in about two seconds,
  with no text. In isolation a creak just reads as bad luck.

This gives the run a clean escalation: the bedroom door teaches hold-to-open with no
stakes, the hallway board teaches surfaces with no stakes, the dining room charges you
for both, and the pantry door charges you for everything at once with the parent in the
next room.

Everything else teaches itself if 6.3 and the floor surfaces are in: the first hardwood
step throws a magenta ring, the first carpet step throws nothing, and the model is built.

Put the controls on the title card and on the submission page. Nowhere else.

---

## 7. Level

One floor. Grey-box with CSG boxes before any scripting.

**The layout is a loop with two routes between the bedroom and the kitchen.** This is the
level design, and everything else is dressing.

```
        ┌───────────────────────────────────┐
        │  HALLWAY — carpet, silent          │   long
        │  hall lamp ○   parent's door ▓     │   lit, passes the parent's door
   ┌────┴─────┐                         ┌────┴─────┐
   │ BEDROOM  │                         │ KITCHEN  │
   │  crib    │                         │ fridge A │
   │  clock   │                         │ pantry B │
   └────┬─────┘                         └────┬─────┘
        │  DINING — creaky hardwood          │   short
        │  toy patch, stays in shadow        │   noisy
        └──────────────┬────────────────────┘
                       │ open to
                 ┌─────┴──────────┐
                 │ LIVING — sofa  │
                 │ TV, lamp       │
                 └────────────────┘
```

### 7.1 The two routes must trade different risks, not just time

The obvious version is long-and-quiet versus short-and-loud. That's one axis and it gets
boring. Make each route dangerous on a *different* channel:

| | Dining route | Hallway route |
|---|---|---|
| Length | Short | Roughly 1.5× |
| Floor | Creaky hardwood, toy patch | Carpet — silent, no rings render |
| Light | Stays in shadow | Passes under the hall lamp and the light strip from the parent's door |
| Risk | **Noise** | **Light** |

Now neither route is safe, and the choice is about which risk you'd rather manage. It
also rhymes with the fridge-versus-pantry decision, which splits on exactly the same two
channels. Four approach combinations out of almost no geometry.

Cost: one lamp placement. This is free.

### 7.2 The clock re-prices the routes continuously

This is what makes the round trip a different game rather than a repeat:

- **Early**: plenty of time, and the hall lamp is on. Take the long carpeted way and eat
  the clock.
- **Late**: the lights are off, so the hallway's light risk has evaporated — but so has
  your time, which argues for the dining room.

**Author the parent's routine so it contests the fast route late.** If the parent is
parked on the sofa all night, the dining room becomes strictly correct by the endgame and
the choice collapses. Put the phase-4 lights-off walk through the dining room, or the
drink run across it, so the short way is cheapest in time and occupied exactly when the
player most wants it.

### 7.3 Other layout rules

- Player starts beside the crib.
- Line of sight for the parent must be breakable — the sofa, the kitchen counter, a
  doorframe.
- Toy patch sits in the dining room, so the fast route has a hazard inside it rather than
  merely a bad floor.
- Fridge and pantry sit on opposite sides of the kitchen so the two goals are a real
  routing decision, not two names for the same spot.
- **Lay the carpet deliberately.** It's a silent highway and the player will find it
  within one run. Where it goes is a design decision, not set dressing.

### 7.4 Balance target

Time both routes once they're walkable. The hallway should take roughly **1.4–1.6×** as
long as the dining room at sneak speed. Below 1.2× nobody takes the risky one; above 2×
nobody takes the safe one. Measure it with the debug clock keys rather than guessing.

### 7.5 Hazards are prefabs, not level geometry

Minimum content: **3 creaky floorboards, 2 noisy toys.** Treat those as a floor, not a
target.

**Placement rule: the first hazard of each type is a teacher; every one after it is a
challenge.** The first creaky board is sited for legibility (see 6.8 — hallway, out of
hearing, carpet after it). The first toy sits where its ring is visible but survivable.
Everything after those two is sited for difficulty.

Both are instances of one `NoiseSurface.tscn` with exported `loudness_multiplier` and
`radius`. A creaky board is that scene with the multiplier at 3.0; a toy is the same
scene at 4.0 with a different icon. Adding a twelfth hazard must mean dragging in a
prefab and typing a number — never editing a script.

Two ways to place them, both required:

- **Godot 4.7's Scene Paint Mode** stamps prefab scenes with a brush. This is the fast
  way to scatter hazards during blockout.
- **A debug key that spawns a `NoiseSurface` at the cursor while the game is running**
  (see 10.1). Placement is a feel problem, not a layout problem — you find the right
  spots by walking the route, not by looking at a top-down view.

---

## 8. Build order

**Step 0 — tonight, thirty minutes, hard abort:** install the MCP servers in 9.1 and run
the sanity test in 9.2. If it fights you past thirty minutes, fall back to file-only
agents and carry on. Nothing below depends on it.

**Before any agent starts:** build the node tree in the Godot editor yourself and
commit it. Grey-box level, camera, three actor stubs with the names the scripts expect.

1. Grey-box level with half-height walls + ortho camera + player movement *(you, in editor)*
2. LightSystem + brightness debug readout
3. NoiseSystem + player footstep emission
4. **Noise indicator sprites** — do this before anything else consumes noise events
5. Ambient masking zones (TV, speaker)
6. GameClock + phased lights-out and ambient-off
7. Parent routine + suspicion + investigate
8. Pet state machine
9. Snack pickup, wrapper noise, return leg, win/lose, title card
10. Squeaky door, audio pass, tuning, export

Steps 2–6 are independent of 7–8 once the interfaces exist. That's the split point.

Step 4 looks like polish and isn't. Until you can see noise, you're tuning three systems
blind and every bug looks like a design problem.

---

## 9. Agent setup and division

### 9.1 MCP servers

**Godot editor control — install one.** All three support Claude Code and Codex.

| Server | Install | Notes |
|---|---|---|
| `hi-godot/godot-ai` | One-click from Godot's AssetLib tab; needs `uv` for the Python server | ~43 tools, 120+ ops. Scenes, nodes, scripts, signal wiring, materials, cameras, environments. Most actively maintained. |
| `mkdevkit/godot-mcp` | Editor plugin + Node.js server over WebSocket:6505 | Has screenshot, input-simulation and runtime bridges. Node edits route through the editor's undo stack, so mistakes are reversible. |
| `Coding-Solo/godot-mcp` | `npx @coding-solo/godot-mcp` | Lightest. Launches the editor, runs projects, captures debug output. Install this one if the others fight you. |

Claude Code, lightest option:
```
claude mcp add godot -- npx @coding-solo/godot-mcp
```
Set `GODOT_PATH` to the Godot executable if it isn't auto-detected.

**Pick by what you actually need.** The high-value capability here is not scene
construction — you're building the layout yourself. It's the feedback loop: run the
project, read the debugger, take a screenshot. For a game whose core mechanic is
whether shadows read correctly at an ortho angle, an agent that can look at the running
game is worth more than one that can build nodes. That argues for `mkdevkit` or
`godot-ai` over the lightweight option, if setup cooperates.

**Documentation — install regardless of the above.**

Context7, at `https://mcp.context7.com/mcp`. Free API key at context7.com/dashboard for
higher rate limits. Godot 3 → 4 renamed enough of the API that agents routinely emit
Godot 3 code that looks plausible and doesn't run. This is the cheapest available fix.
Add `use context7` to prompts, or set a rule to auto-invoke it.

**Skip:** filesystem servers (both agents already have native file access), git servers
(Claude Code has git built in), browser servers (nothing here needs one).

### 9.2 Sanity test and abort condition

Ask the agent to add an empty `Node3D` named `MCPTest` to the level scene, then delete
it. If that round-trips cleanly, the bridge works.

Thirty minutes, hard abort. Known friction: Godot's script auto-reload behaviour, and
GDScript's loose typing causing more failed tool calls than the equivalent Unreal
tooling. This is a nice-to-have on a two-day build, not a dependency.

### 9.3 Division of labour

| Owner | Scope |
|---|---|
| You | Grey-box layout, camera placement, playtesting, every tuning call |
| Agent A — MCP-connected | `LightSystem.gd`, `NoiseSystem.gd`, `GameClock.gd`, autoload registration, running the project and reading errors |
| Agent B — files only | `Player.gd`, `Parent.gd`, `Pet.gd`, `Door.gd` |

**Only one agent gets the MCP connection.** Two agents driving one live editor session
will corrupt scene state. Agent A owns it, because the systems layer benefits most from
being able to run the project and read the debugger output.

Agent B writes scripts against the interfaces in section 3 and never touches scenes. If
Agent B needs a node wired up, it leaves a note for you or Agent A rather than editing
a `.tscn` directly — hand-edited scene files break in ways that cost more time than
they save.

Agent A's work is pure logic and testable headless. Agent B's work depends on the
interfaces in section 3, so those must be committed before Agent B starts.

Layout stays yours whatever the tooling does. It's a design decision, and dragging
boxes is faster than describing them.

---

## 10. Tuning

Every number above is a starting point, not a design decision. Expose them as
`@export` variables and expect to change all of them once it's playable. The two most
likely to be wrong: the suspicion decay rate and the pet's alert radius.

### 10.1 Debug affordances — build these with the clock, not later

Because the routine is a pure function of time, the whole game state is scrubbable. Wire
these in step 6 and they'll pay for themselves within the first hour of tuning:

- **`]` skips the clock forward 30 seconds.** Otherwise every test of phase 3 behaviour
  costs you three real minutes of waiting. This is the single highest-value debug key in
  the build.
- **`[` rewinds 30 seconds**, for re-watching whatever just went wrong.
- **`\` toggles a debug overlay**: current suspicion values, active behaviour state per
  actor, the player's current brightness and mask values, and the last noise loudness.
- **`P` teleports the player to the mouse position** on the navmesh, for jumping straight
  to the room you're testing.
- **`N` spawns a `NoiseSurface` at the cursor**, cycling loudness with the scroll wheel.
  This is how you actually find hazard placement — by walking the route and dropping a
  creaky board where the tension is missing.

All of the above are throwaway code behind an `if OS.is_debug_build()` guard. Do not
spend time making them nice.

### 10.2 Export check — Thursday, not Saturday

Do a throwaway web export on Thursday containing nothing but a capsule that moves.
Godot's web export finds novel ways to break, and finding out on Saturday afternoon is
how people miss jam deadlines. Confirm it loads in a browser, then forget about it until
the end.

---

## 11. Optional polish — dithering (Saturday only, or not at all)

**Do not build this until the game is playable end to end.** It is a post-process on a
`CanvasLayer` and can be deleted at 11pm on Saturday with zero consequences to anything
else. That removability is the only reason it's in scope at all.

### 11.1 Not full 1-bit

Obra Dinn renders 3D in two colours only. That would delete the actor palette in 6.4 and
the player-exposure readout in 6.5 — both load-bearing.

Pope's own solution is the precedent for the split: Obra Dinn dithers the environment
with blue noise and switches to Bayer for people and objects of interest, specifically so
they stand out against it. Same principle here, taken one step further:

- **Environment**: dithered, greyscale.
- **Actors and the player**: excluded from the post-process entirely, drawn as flat
  unshaded colour on top.

Put actors on a separate visual layer and let the dither shader read only the environment
pass.

### 11.2 The camera-movement problem doesn't apply here

Pope's extensive work on Obra Dinn was about keeping the dither pattern stable while the
player moves and rotates a first-person camera through 3D space. That's the hard part,
and it's the reason this technique has a reputation for being difficult.

**Your camera is fixed and orthographic, and your environment geometry is static.** A
screen-space Bayer threshold map over a static camera and static geometry does not swim,
crawl, or shimmer. You get the aesthetic without the problem that made it famous.

### 11.3 Quantize at the gameplay thresholds

This is what makes the shader earn its place instead of being decoration.

Don't dither to 2 levels — dither to about 4, and **put a band edge exactly at the
detection threshold** (`0.35` in section 5). The visible pattern change then marks the
precise line where safe becomes unsafe. The shader becomes UI: the player can *see* where
they can stand.

Ordinary dithering hides thresholds. Aligned dithering reveals the one that matters.

### 11.4 Gotchas that will cost you an hour each

- **Dither in linear space, not sRGB.** Otherwise the result gets bright far too quickly
  and your dark apartment turns to mush.
- **Invert the Bayer matrix.** Standard Bayer biases images *brighter*, which is worst
  in near-black areas — and your game is near-black almost everywhere. Threshold against
  `1.0 - bayer[x][y]` instead.
- **Ordered dithering only.** Floyd-Steinberg, Atkinson and the other error-diffusion
  algorithms are inherently sequential and cannot run as a shader. Bayer or blue noise.
- **Start with a 4×4 Bayer matrix** — sixteen constants in the shader, no texture needed.
  Blue noise looks more organic but needs a generated or downloaded 64×64 tile. Not a
  Saturday-night problem.
- Godot 4.7's real-time shader preview makes iterating this much less painful.

---

## 12. Triage and shipping

### 12.1 The cut order, agreed now

Decide this while rested. At 1am on Friday you will make worse decisions, and having the
list already written turns a crisis into a lookup.

Cut in this order, without renegotiating:

1. **Dithering** (already gated to Saturday)
2. **The pet entirely** — it's a chain-reaction amplifier; the game works without it
3. **Ambient masking** — keep the TV as a light and sound source, drop the mechanic
4. **The second route** — level collapses to one path. Sad, still shippable.
5. **The round trip** — one-way to the pantry. Still on theme.

**Never cut:** movement with three speeds, brightness detection, noise → suspicion, the
clock, and the lights going out as it drains. That last one *is* your theme. Everything
above is negotiable; those five are the game.

### 12.2 Friday night: tag a known-good build

Whatever state it's in when you stop on Friday, commit and tag it, and export a web build
from that tag. People break their game on Saturday night and ship nothing. You want a
playable artifact banked before you touch polish.

### 12.3 Saturday: one outside playtester

Find one person who hasn't seen it and watch them play without saying anything.

You will be blind to your own difficulty curve by Saturday — you'll have played the route
two hundred times and every timing will feel obvious. Twenty minutes of watching someone
else is worth more than three hours of solo tuning, and it's the only way you'll catch
the thing that's unreadable to a fresh player.

Bite your tongue while they play. Every instinct to explain a mechanic is a note about
what the game fails to communicate.

### 12.4 The submission page is a scheduled task

Budget an hour, not the last twenty minutes. It needs: a title card screenshot, two or
three in-game shots, a short GIF of a magenta ring resolving into a caught-or-escaped
moment, the control list, and **an explicit sentence about how it reads the theme.**

That last one matters. Judges score theme, and a sentence saying the countdown is the
parent's bedtime routine — and that the house gets darker and safer as it drains — takes
thirty seconds to write and does real work.

---

## 13. Validation questions

Answer these Saturday night, regardless of how the jam goes — they're what this build is
meant to teach for the longer projects:

1. Does brightness-as-a-resource create real decisions, or does the player just hug
   the dark and never think about it?
2. Does noise → attention produce better tension than a vision cone alone, and do the
   two channels (noise vs. light) stay legible as separate risks?
3. Does a patrolling pet with a telegraph feel dynamic, or unfair?
4. Do the magenta reach rings actually teach the noise model, or do players ignore them?
5. Does the route economy hold — do players switch routes as the clock re-prices them,
   or settle on one?
6. Is 3D ortho with primitives a viable solo pipeline for a longer project?
7. Did the agent workflow (MCP-connected systems agent + file-only actors agent) beat
   working alone?
