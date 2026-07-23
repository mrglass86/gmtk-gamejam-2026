# Shoulda Eaten Dinner — Technical Risk Check

This is research support for the locked build brief. It does not reopen its design
decisions. Treat each item as a short proof test with a fallback.

## 1. Web renderer and lighting — resolve first

**Risk.** Web exports use the Compatibility renderer/WebGL 2. `AreaLight3D` is
available in Godot 4.7, but cannot cast shadows in Compatibility and is more expensive
than spot or omni lights. The half-wall shadows are important to the visual read.

**Proof test.** Before system work, export one room containing the orthographic camera,
half-height wall, player capsule, one `AreaLight3D`, and one shadowed `SpotLight3D` or
`OmniLight3D`. Run it in two desktop browsers.

**Pass condition.** The player, wall boundary, and safe/dangerous lighting remain
readable at the planned camera angle without visible performance trouble.

**Fallback.** Keep `LightSystem` analytical as specified. Use `AreaLight3D` only for
shadowless screen/window glow; use one or two shadowed spot/omni lights for the visual
shadow language. Gameplay brightness must never depend on renderer output.

## 2. Static navigation mesh — resolve during blockout

**Risk.** Collision alone does not guarantee that a navmesh avoids a wall. The bake must
include the intended source geometry, or an enabled `NavigationObstacle3D` must carve it.
The agents also need to advance `NavigationAgent3D` with
`get_next_path_position()` every physics frame.

**Proof test.** Bake the apartment once. Command the parent and pet to cross a route,
investigate a point behind each half-wall, and return to their time-indexed base target.

**Pass condition.** Neither actor cuts through walls, gets stuck on a corner, or follows
an obsolete path after an investigation.

**Fallback.** Keep the level static; adjust the mesh source or add explicit
navigation obstacles. Do not introduce runtime navmesh baking or dynamic avoidance
unless a measured collision problem requires it.

## 3. Web audio and export — prove Thursday

**Risk.** Web builds are subject to browser audio and threading restrictions. The default
single-threaded export is broadly compatible, while threaded web builds require
cross-origin isolation headers or the PWA workaround. Audio-bus effects are also not
available with sample playback, which is the web default.

**Proof test.** Export the title card plus one movement sound and one ambient loop. Start
audio from the player's first explicit action, then verify it in two desktop browsers on
the same host intended for the jam build.

**Pass condition.** The build opens, input works, and both sounds start reliably without
custom server headers.

**Fallback.** Stay single-threaded, use direct volume changes rather than audio-bus
effects, and make the first button/key press start the game and audio together.

## 4. Optional dithering remains a true cut

**Risk.** A simple full-screen `CanvasLayer` effect cannot automatically exclude actors
from the 3D pass. The desired environment-only result requires render-layer/cull-mask or
SubViewport composition work.

**Rule.** Do not start this before the tagged playable web build. If the first 30-minute
prototype cannot preserve the colored player and actors, cut it immediately.

## 5. MCP is a convenience, not a dependency

**Risk.** The brief's named MCP options change quickly and any editor bridge can consume
setup time or write to scenes.

**Proof test.** Enforce the brief's 30-minute limit: create and delete `MCPTest`, run
the project, and read the editor output. If that fails, use file-based work plus native
Godot debugging without revisiting the design.

**Preferred current candidate.** Funplay MCP for Godot, configured from its Godot dock
after the project exists, with the default compact tool profile and safety checks left on.
