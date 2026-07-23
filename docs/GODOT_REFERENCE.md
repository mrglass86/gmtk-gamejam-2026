# Godot 4.7.1 Reference

## Canonical documentation

- **Online manual:** <https://docs.godotengine.org/en/4.7/>
- **Class reference:** <https://docs.godotengine.org/en/4.7/classes/>
- **Official documentation source:** <https://github.com/godotengine/godot-docs/tree/4.7>
- **Official engine source:** <https://github.com/godotengine/godot/tree/4.7>
- **4.7.1 release notes:** <https://godotengine.org/article/maintenance-release-godot-4-7-1/>

Godot 4.7.1 is a maintenance release on the 4.7 documentation branch. Use the
4.7 links above for all implementation questions; do not use the `latest` docs
or Godot 4.8 development documentation unless deliberately upgrading.

## Agent lookup order

1. Search the official 4.7 manual and class reference.
2. Check the matching `godotengine/godot-docs` source when wording, examples, or
   a documentation issue needs more context.
3. Inspect the current project and engine output before proposing a version-
   specific workaround.

## Project-critical topics

- **Web export:** <https://docs.godotengine.org/en/4.7/tutorials/export/exporting_for_web.html>
- **Renderer limits:** <https://docs.godotengine.org/en/4.7/engine_details/architecture/internal_rendering_architecture.html>
- **Area lights:** <https://docs.godotengine.org/en/4.7/classes/class_arealight3d.html>
- **Navigation meshes:** <https://docs.godotengine.org/en/4.7/tutorials/navigation/navigation_using_navigationmeshes.html>
- **Navigation agents:** <https://docs.godotengine.org/en/4.7/tutorials/navigation/navigation_using_navigationagents.html>
- **Navigation obstacles:** <https://docs.godotengine.org/en/4.7/tutorials/navigation/navigation_using_navigationobstacles.html>
- **Audio buses:** <https://docs.godotengine.org/en/4.7/tutorials/audio/audio_buses.html>

See `docs/BRIEF_RISK_CHECK.md` for the project-specific questions and proof tests
that should be resolved before the corresponding system is built.

## Local copy policy

Do not clone the full documentation repository into this jam workspace by
default. The links are canonical and avoid a stale, bulky duplicate. If offline
work becomes necessary, clone only the `4.7` branch outside the game project and
treat it as read-only.
