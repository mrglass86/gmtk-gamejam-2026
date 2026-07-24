# Lane A A13 voice-intake handoff — 2026-07-23

## Completed

Installed FFmpeg and Xiph Vorbis tools. `tools/process_family_voice.py` converts
the 13 iPhone M4A takes into mono 48 kHz OGG candidates, high-passes at 70 Hz,
splits at effective -33 dBFS / 300 ms silence, trims boundaries, and iteratively
peak-normalizes to -3 dBFS. The requested -35 dBFS was below the room tone.

`assets/voice/candidates/` contains 124 clips: 13 laughing, 13 crying, 12
no-no-no, and 86 other. `MANIFEST.md` records duration, source, source range,
group guess, and final peak. Raw takes are ignored by Git. Anonymous family
credit is recorded. Nothing is wired; CC0 fallbacks remain authoritative.

## Next

Director returns exact keeper filenames and event mappings. Accept when every
named file exists in the manifest; then lane A wires pools and pitch jitter.

Risk: grouping is local-transcription-assisted and intentionally provisional.

## Changed

Candidate OGGs/manifest, processor, `.gitignore`, `CREDITS.md`, shared memory.
