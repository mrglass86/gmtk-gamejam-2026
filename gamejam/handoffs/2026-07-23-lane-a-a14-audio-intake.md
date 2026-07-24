# Lane A A14 audio-intake handoff — 2026-07-23

## Completed

Fingerprint filtering skipped all 13 A13 sources and processed only nine new
M4A recordings. `tools/process_family_voice_batch2.py` uses the A13 pipeline
with adaptive silence thresholds for quiet foley: mono 48 kHz OGG Vorbis,
70 Hz high-pass, trimmed edges, and iterative -3 dBFS peak normalization.

Batch 2 adds 97 candidates: 28 parent voice, 23 door creaks, 26 footsteps,
2 refrigerator sounds, 15 wrapper crinkles, and 3 light-switch clicks.
`MANIFEST.md` appends sanitized source IDs, provisional transcript/audio hints,
durations, ranges, thresholds, and peaks. The source registry stores content
fingerprints, so reruns skip both batches. No new clock or dog source was
present. Credits cover original family voice and household foley. Nothing is
wired; CC0 remains authoritative.

## Next

Director returns exact keeper filenames and event mappings. Accept when every
named file exists in the manifest; then lane A builds no-repeat variation pools
with pitch jitter and CC0 fallback.

Risk: categories/transcripts are audition hints, not keeper assignments.

## Changed

Batch-2 candidates/manifest, source registry, processors, credits, shared memory.
