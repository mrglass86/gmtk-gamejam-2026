#!/usr/bin/env python3
"""Append only unprocessed A14 recordings to the A13 audition package."""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import shutil
import subprocess
import tempfile
from collections import Counter
from pathlib import Path

from process_family_voice import (
    encode_candidate,
    nonsilent_ranges,
)


BATCH2_SOURCE_CONFIG: list[dict[str, object]] = [
    {
        "sha256": "3eed6f6bfc96d315bd220d17cb696763538340d5df0231536ab9154d281c70d6",
        "category": "parent_voice",
        "threshold_db": -33.0,
    },
    {
        "sha256": "2ba1241a3f183392f51fd1dcd7c392153ba048aed79cdae66d9c3113e21cc2f5",
        "category": "door_creak",
        "threshold_db": -33.0,
    },
    {
        "sha256": "ff0b0d996d2b020461820d17138447c3650886dcd6e5580c4d488b3b1388aa58",
        "category": "footstep_carpet",
        "threshold_db": -40.0,
    },
    {
        "sha256": "346d564ab4fb09f4375b16d47e653d27847ecf41e88a553d81db553abd1d0610",
        "category": "footstep_carpet",
        "threshold_db": -42.0,
    },
    {
        "sha256": "a47c219c1a205b4b649c1e130232ebcfa9570827d98b51d60c365544f1af1014",
        "category": "footstep_wood",
        "threshold_db": -42.0,
    },
    {
        "sha256": "4b05d83fe19c6ca7ab69ba032a05c1f2e50c6a3a2c38e8354807eddf86a52b3a",
        "category": "footstep_other",
        "threshold_db": -38.0,
    },
    {
        "sha256": "1bac897267368195621971fe2e38086c27eb1fdd01410eab007283c4fce43976",
        "category": "fridge",
        "threshold_db": -45.0,
    },
    {
        "sha256": "f2d4169aa3c585caaa0a808157cb2fe02255355242c7336bf367cd142f81bed1",
        "category": "toilet_flush",
        "threshold_db": -35.0,
    },
    {
        "sha256": "367a844c77b8e28620b896f2211b3c33174562d67d0aa8fb737c56a14454245b",
        "category": "sink_running",
        "threshold_db": -35.0,
        "minimum_candidate_seconds": 0.15,
    },
]

BATCH2_TRANSCRIPT_OVERRIDES = {
    "parent_voice_01.ogg": "(non-speech / unclear)",
    "parent_voice_02.ogg": "(sighs)",
    "parent_voice_03.ogg": "*sigh*",
    "parent_voice_04.ogg": "She awake again.",
    "parent_voice_05.ogg": "I'm back to bed.",
    "parent_voice_06.ogg": "What was that?",
    "parent_voice_07.ogg": "You hear that?",
    "parent_voice_08.ogg": "What was that noise?",
    "parent_voice_09.ogg": "(sighs)",
    "parent_voice_10.ogg": "Well, you should have eaten your dinner.",
    "parent_voice_11.ogg": (
        "Maybe you wouldn't have been so hungry if you ate your dinner."
    ),
    "parent_voice_12.ogg": "Maybe you'll think about that tomorrow.",
    "parent_voice_13.ogg": "at dinner.",
    "parent_voice_14.ogg": "*sigh*",
    "parent_voice_15.ogg": "You need to go back to bed.",
    "parent_voice_16.ogg": "What are you doing up?",
    "parent_voice_17.ogg": "This again?",
    "parent_voice_18.ogg": "Come here.",
    "parent_voice_19.ogg": "You come here right now.",
    "parent_voice_20.ogg": (
        "I'm telling you, I'm not going to do this again."
    ),
    "parent_voice_21.ogg": "Is she in bed already?",
    "parent_voice_22.ogg": "You know what? I should probably check again.",
    "parent_voice_23.ogg": "I think I want something to drink.",
    "parent_voice_24.ogg": "I might go get a snack.",
    "parent_voice_25.ogg": "There's never anything good on, is there?",
    "parent_voice_26.ogg": "Mmm, I've already seen this one.",
    "parent_voice_27.ogg": "Yeah, I wanted to watch this.",
    "parent_voice_28.ogg": "What's he on about?",
}


def file_sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as source_file:
        for block in iter(lambda: source_file.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def duration_seconds(path: Path) -> float:
    result = subprocess.run(
        [
            "ffprobe",
            "-v",
            "error",
            "-show_entries",
            "format=duration",
            "-of",
            "default=noprint_wrappers=1:nokey=1",
            str(path),
        ],
        check=True,
        text=True,
        capture_output=True,
    )
    return float(result.stdout.strip())


def category_for_segment(
    source_category: str,
    segment_index: int,
    start_time: float,
    end_time: float,
) -> str:
    if source_category == "door_creak":
        return (
            "door_creak_slow"
            if end_time - start_time >= 2.0
            else "door_creak_fast"
        )
    if source_category == "fridge":
        return "fridge_pop" if segment_index == 1 else "fridge_hum"
    return source_category


def audio_hint_for_category(category: str) -> str:
    hints = {
        "door_creak_fast": "fast door-creak take",
        "door_creak_slow": "slow door-creak take",
        "footstep_carpet": "carpet/cushion footstep take",
        "footstep_other": "footstep take (surface uncertain)",
        "footstep_wood": "wood footstep take",
        "fridge_hum": "refrigerator hum take",
        "fridge_pop": "refrigerator pop/open take",
        "sink_running": "sink-running take",
        "toilet_flush": "toilet-flush take",
    }
    return hints[category]


def existing_category_counters(output_directory: Path) -> Counter[str]:
    counters: Counter[str] = Counter()
    for path in output_directory.glob("*.ogg"):
        match = re.match(r"(.+)_([0-9]+)$", path.stem)
        if match is None:
            continue
        counters[match.group(1)] = max(
            counters[match.group(1)],
            int(match.group(2)),
        )
    return counters


def transcript_candidates(
    staging_directory: Path,
    whisper_model: Path,
    candidate_names: list[str],
) -> dict[str, str]:
    candidate_paths = [
        staging_directory / candidate_name
        for candidate_name in candidate_names
    ]
    if not candidate_paths:
        return {}
    subprocess.run(
        [
            "whisper-cli",
            "-m",
            str(whisper_model),
            "-l",
            "en",
            "-np",
            "-oj",
            *[path.name for path in candidate_paths],
        ],
        cwd=staging_directory,
        check=True,
        text=True,
        capture_output=True,
    )
    transcripts: dict[str, str] = {}
    for candidate_path in candidate_paths:
        transcript_path = staging_directory / f"{candidate_path.name}.json"
        data = json.loads(transcript_path.read_text(encoding="utf-8"))
        text = " ".join(
            segment.get("text", "").strip()
            for segment in data.get("transcription", [])
        ).strip()
        if not text or text == "[BLANK_AUDIO]":
            text = "(non-speech / unclear)"
        transcripts[candidate_path.name] = (
            text.replace("|", "/").replace("\n", " ").strip()
        )
    return transcripts


def append_manifest(
    manifest_path: Path,
    rows: list[dict[str, object]],
) -> None:
    original_text = manifest_path.read_text(encoding="utf-8").rstrip()
    if "## Batch 2 (A14)" in original_text:
        raise RuntimeError("Manifest already contains an A14 batch-2 section")
    counts = Counter(str(row["category"]) for row in rows)
    lines = [
        original_text,
        "",
        "## Batch 2 (A14)",
        "",
        (
            "Only source fingerprints absent from the A13 registry were "
            "processed. Raw filenames are intentionally omitted."
        ),
        "",
        "Adaptive silence thresholds preserve quiet foley; all other processing "
        "matches A13: mono 48 kHz OGG Vorbis, 70 Hz high-pass, trimmed edges, "
        "and iterative -3 dBFS peak normalization.",
        "",
        "### Counts",
        "",
    ]
    for category in sorted(counts):
        lines.append(f"- `{category}`: {counts[category]}")
    lines.extend(
        [
            f"- Total: {len(rows)}",
            "",
            "### Candidates",
            "",
            (
                "| Candidate | Category guess | Transcript/audio hint | "
                "Duration (s) | Source | Segment | Source range (s) | "
                "Split threshold (dBFS) | Peak (dBFS) |"
            ),
            "|---|---|---|---:|---|---:|---:|---:|---:|",
        ]
    )
    for row in rows:
        lines.append(
            "| {candidate} | {category} | {transcript} | {duration:.3f} | "
            "{source_id} | {segment} | {start:.3f}–{end:.3f} | "
            "{threshold:.0f} | {peak:.1f} |".format(**row)
        )
    manifest_path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--raw-dir",
        type=Path,
        default=Path("assets/voice/raw"),
    )
    parser.add_argument(
        "--output-dir",
        type=Path,
        default=Path("assets/voice/candidates"),
    )
    parser.add_argument(
        "--manifest",
        type=Path,
        default=Path("assets/voice/candidates/MANIFEST.md"),
    )
    parser.add_argument(
        "--registry",
        type=Path,
        default=Path("assets/voice/source_registry.json"),
    )
    parser.add_argument(
        "--whisper-model",
        type=Path,
        default=Path("/tmp/gmtk-whisper-base.en.bin"),
    )
    args = parser.parse_args()

    registry = json.loads(args.registry.read_text(encoding="utf-8"))
    registered_hashes = {
        str(source["sha256"]) for source in registry["sources"]
    }
    raw_by_hash: dict[str, Path] = {}
    for source_path in args.raw_dir.rglob("*.m4a"):
        digest = file_sha256(source_path)
        if digest not in registered_hashes:
            raw_by_hash[digest] = source_path
    if not raw_by_hash:
        print("No unprocessed audio source fingerprints found.")
        return

    configs_by_hash = {
        str(config["sha256"]): config for config in BATCH2_SOURCE_CONFIG
    }
    unknown_hashes = sorted(set(raw_by_hash) - set(configs_by_hash))
    if unknown_hashes:
        raise RuntimeError(
            "Unclassified source fingerprints: " + ", ".join(unknown_hashes)
        )
    ordered_configs = [
        config
        for config in BATCH2_SOURCE_CONFIG
        if str(config["sha256"]) in raw_by_hash
    ]
    next_source_number = max(
        int(str(source["source_id"]).rsplit("_", 1)[1])
        for source in registry["sources"]
    ) + 1
    counters = existing_category_counters(args.output_dir)
    rows: list[dict[str, object]] = []
    new_registry_rows: list[dict[str, object]] = []

    with tempfile.TemporaryDirectory(prefix="gmtk-a14-voice-") as temp_name:
        staging_directory = Path(temp_name)
        for source_offset, config in enumerate(ordered_configs):
            digest = str(config["sha256"])
            source_path = raw_by_hash[digest]
            source_id = f"recording_{next_source_number + source_offset:02d}"
            source_category = str(config["category"])
            threshold_db = float(config["threshold_db"])
            minimum_candidate_seconds = float(
                config.get("minimum_candidate_seconds", 0.25)
            )
            source_ranges = nonsilent_ranges(
                source_path,
                threshold_db,
                minimum_candidate_seconds,
            )
            if not source_ranges:
                raise RuntimeError(
                    f"{source_id} produced no candidates at {threshold_db:g} dBFS"
                )
            for segment_index, (start_time, end_time) in enumerate(
                source_ranges,
                start=1,
            ):
                category = category_for_segment(
                    source_category,
                    segment_index,
                    start_time,
                    end_time,
                )
                counters[category] += 1
                candidate_name = f"{category}_{counters[category]:02d}.ogg"
                candidate_path = staging_directory / candidate_name
                candidate_duration, candidate_peak = encode_candidate(
                    source_path,
                    start_time,
                    end_time,
                    candidate_path,
                    staging_directory,
                )
                rows.append(
                    {
                        "candidate": candidate_name,
                        "category": category,
                        "transcript": "",
                        "duration": candidate_duration,
                        "source_id": source_id,
                        "segment": segment_index,
                        "start": start_time,
                        "end": end_time,
                        "threshold": threshold_db,
                        "peak": candidate_peak,
                    }
                )
            new_registry_rows.append(
                {
                    "source_id": source_id,
                    "batch": 2,
                    "sha256": digest,
                    "duration_seconds": round(duration_seconds(source_path), 6),
                    "category_hint": source_category,
                    "silence_threshold_db": threshold_db,
                }
            )

        transcripts = transcript_candidates(
            staging_directory,
            args.whisper_model,
            [
                str(row["candidate"])
                for row in rows
                if row["category"] == "parent_voice"
            ],
        )
        for row in rows:
            if row["category"] == "parent_voice":
                candidate_name = str(row["candidate"])
                row["transcript"] = BATCH2_TRANSCRIPT_OVERRIDES.get(
                    candidate_name,
                    transcripts[candidate_name],
                )
            else:
                row["transcript"] = audio_hint_for_category(
                    str(row["category"])
                )
        for row in rows:
            candidate_path = staging_directory / str(row["candidate"])
            destination = args.output_dir / candidate_path.name
            if destination.exists():
                raise RuntimeError(f"Candidate already exists: {destination}")
            shutil.copyfile(candidate_path, destination)

    append_manifest(args.manifest, rows)
    registry["sources"].extend(new_registry_rows)
    args.registry.write_text(
        json.dumps(registry, indent=2) + "\n",
        encoding="utf-8",
    )
    print(
        f"Appended {len(rows)} A14 candidates from "
        f"{len(new_registry_rows)} new sources."
    )


if __name__ == "__main__":
    main()
