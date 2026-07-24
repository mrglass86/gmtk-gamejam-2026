#!/usr/bin/env python3
"""Prepare local family-voice audition candidates without wiring game audio."""

from __future__ import annotations

import argparse
import json
import re
import shutil
import subprocess
import tempfile
from collections import Counter
from pathlib import Path


SILENCE_THRESHOLD_DB = -33.0
MIN_SILENCE_SECONDS = 0.3
MIN_CANDIDATE_SECONDS = 0.25
EDGE_PAD_SECONDS = 0.04
TARGET_PEAK_DB = -3.0

# These are deliberately broad audition hints, not keeper assignments.
SOURCE_GROUP_HINTS = {
    "kid_3": "no_no_no",
    "kid_5": "crying",
    "kid_8": "no_no_no",
}

# Local-only transcription was used only to distinguish obvious nonverbal
# laughter and the isolated "No!" response. The director still names keepers.
SEGMENT_GROUP_OVERRIDES: dict[tuple[str, int], str] = {
    **{
        ("kid_5", segment_index): "laughing"
        for segment_index in [
            4,
            7,
            9,
            12,
            14,
            15,
            16,
            17,
            18,
            19,
            20,
            21,
            24,
            25,
        ]
    },
    **{
        ("kid_6", segment_index): "laughing"
        for segment_index in [1, 15, 16, 17, 20]
    },
    **{
        ("kid_6", segment_index): "crying"
        for segment_index in [8, 21, 27, 28]
    },
    **{
        ("kid_12", segment_index): "crying"
        for segment_index in [3, 4, 5, 6, 9]
    },
    ("kid_6", 5): "no_no_no",
    ("kid_6", 9): "no_no_no",
    ("kid_6", 14): "no_no_no",
    ("kid_10", 4): "no_no_no",
    ("kid_10", 6): "laughing",
    ("kid_10", 7): "laughing",
    ("kid_12", 10): "no_no_no",
}


def run(command: list[str]) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        command,
        check=True,
        text=True,
        capture_output=True,
    )


def natural_key(path: Path) -> list[object]:
    return [
        int(token) if token.isdigit() else token.lower()
        for token in re.split(r"(\d+)", path.name)
    ]


def duration_seconds(path: Path) -> float:
    result = run(
        [
            "ffprobe",
            "-v",
            "error",
            "-show_entries",
            "format=duration",
            "-of",
            "default=noprint_wrappers=1:nokey=1",
            str(path),
        ]
    )
    return float(result.stdout.strip())


def peak_db(path: Path) -> float:
    result = subprocess.run(
        [
            "ffmpeg",
            "-hide_banner",
            "-nostats",
            "-i",
            str(path),
            "-af",
            "volumedetect",
            "-f",
            "null",
            "-",
        ],
        check=True,
        text=True,
        capture_output=True,
    )
    match = re.search(r"max_volume:\s+(-?(?:inf|\d+(?:\.\d+)?)) dB", result.stderr)
    if match is None or match.group(1) == "-inf":
        raise RuntimeError(f"Could not measure a usable peak for {path}")
    return float(match.group(1))


def nonsilent_ranges(path: Path) -> list[tuple[float, float]]:
    source_duration = duration_seconds(path)
    result = subprocess.run(
        [
            "ffmpeg",
            "-hide_banner",
            "-nostats",
            "-i",
            str(path),
            "-af",
            (
                "silencedetect="
                f"noise={SILENCE_THRESHOLD_DB:g}dB:"
                f"d={MIN_SILENCE_SECONDS:g}"
            ),
            "-f",
            "null",
            "-",
        ],
        check=True,
        text=True,
        capture_output=True,
    )
    events = re.findall(
        r"silence_(start|end):\s+(\d+(?:\.\d+)?)",
        result.stderr,
    )
    ranges: list[tuple[float, float]] = []
    candidate_start = 0.0
    for event_name, event_time_text in events:
        event_time = float(event_time_text)
        if event_name == "start":
            if event_time - candidate_start >= MIN_CANDIDATE_SECONDS:
                ranges.append((candidate_start, event_time))
        else:
            candidate_start = event_time
    if source_duration - candidate_start >= MIN_CANDIDATE_SECONDS:
        ranges.append((candidate_start, source_duration))
    return ranges


def encode_candidate(
    source_path: Path,
    start_time: float,
    end_time: float,
    output_path: Path,
    temporary_directory: Path,
) -> tuple[float, float]:
    padded_start = max(0.0, start_time - EDGE_PAD_SECONDS)
    padded_end = min(duration_seconds(source_path), end_time + EDGE_PAD_SECONDS)
    wav_path = temporary_directory / f"{output_path.stem}.wav"
    run(
        [
            "ffmpeg",
            "-hide_banner",
            "-loglevel",
            "error",
            "-y",
            "-i",
            str(source_path),
            "-ss",
            f"{padded_start:.6f}",
            "-t",
            f"{padded_end - padded_start:.6f}",
            "-vn",
            "-af",
            "pan=mono|c0=0.5*c0+0.5*c1,highpass=f=70",
            "-ar",
            "48000",
            "-c:a",
            "pcm_s16le",
            str(wav_path),
        ]
    )
    gain_db = TARGET_PEAK_DB - peak_db(wav_path)
    encoded_path: Path | None = None
    encoded_peak = float("-inf")
    best_encoded_path: Path | None = None
    best_peak_error = float("inf")
    for normalization_pass in range(1, 7):
        normalized_wav_path = temporary_directory / (
            f"{output_path.stem}_normalized_{normalization_pass}.wav"
        )
        encoded_path = temporary_directory / (
            f"{output_path.stem}_pass_{normalization_pass}.ogg"
        )
        run(
            [
                "ffmpeg",
                "-hide_banner",
                "-loglevel",
                "error",
                "-y",
                "-i",
                str(wav_path),
                "-af",
                f"volume={gain_db:.3f}dB",
                "-ar",
                "48000",
                "-ac",
                "1",
                "-c:a",
                "pcm_s16le",
                str(normalized_wav_path),
            ]
        )
        run(
            [
                "oggenc",
                "-Q",
                "-q",
                "5",
                "-o",
                str(encoded_path),
                str(normalized_wav_path),
            ]
        )
        encoded_peak = peak_db(encoded_path)
        peak_error = TARGET_PEAK_DB - encoded_peak
        if abs(peak_error) < best_peak_error:
            best_peak_error = abs(peak_error)
            best_encoded_path = encoded_path
        if abs(peak_error) <= 0.1:
            break
        gain_db += peak_error
    if best_encoded_path is None:
        raise RuntimeError(f"Could not encode {output_path}")
    shutil.copyfile(best_encoded_path, output_path)
    return duration_seconds(output_path), peak_db(output_path)


def write_manifest(
    output_directory: Path,
    rows: list[dict[str, object]],
) -> None:
    counts = Counter(str(row["group"]) for row in rows)
    lines = [
        "# A13 family voice audition manifest",
        "",
        "Original family recordings; no names are retained in candidate metadata.",
        "Grouping is provisional and exists only to shorten the director audition.",
        "",
        "## Processing",
        "",
        (
            f"- Mono OGG Vorbis, 48 kHz, quality 5; high-pass at 70 Hz; "
            f"peak target {TARGET_PEAK_DB:.1f} dBFS."
        ),
        (
            f"- Silence split threshold {SILENCE_THRESHOLD_DB:.0f} dBFS, "
            f"minimum gap {MIN_SILENCE_SECONDS * 1000:.0f} ms, "
            f"minimum candidate {MIN_CANDIDATE_SECONDS * 1000:.0f} ms."
        ),
        (
            "- The requested -35 dBFS threshold did not detect the iPhone room "
            "tone; -33 dBFS was the closest effective threshold."
        ),
        (
            "- Broad source hints were refined with a per-clip local "
            "transcription pass. Transcript text and grouping remain audition "
            "hints, not keeper assignments."
        ),
        "",
        "## Counts",
        "",
    ]
    for group_name in ["laughing", "crying", "no_no_no", "other"]:
        lines.append(f"- `{group_name}`: {counts[group_name]}")
    lines.extend(
        [
            f"- Total: {len(rows)}",
            "",
            "## Candidates",
            "",
            (
                "| Candidate | Guess | Transcript hint | Duration (s) | "
                "Source | Segment | Source range (s) | Peak (dBFS) |"
            ),
            "|---|---:|---|---:|---|---:|---:|---:|",
        ]
    )
    for row in rows:
        lines.append(
            "| {candidate} | {group} | {transcript} | {duration:.3f} | "
            "{source} | {segment} | {start:.3f}–{end:.3f} | "
            "{peak:.1f} |".format(**row)
        )
    manifest_path = output_directory / "MANIFEST.md"
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
        "--transcript-hints",
        type=Path,
        default=Path("assets/voice/transcript_hints.json"),
    )
    args = parser.parse_args()

    required_commands = ["ffmpeg", "ffprobe", "oggenc"]
    missing_commands = [
        command_name
        for command_name in required_commands
        if shutil.which(command_name) is None
    ]
    if missing_commands:
        raise SystemExit(
            "Missing required commands: " + ", ".join(missing_commands)
        )
    source_paths = sorted(args.raw_dir.glob("*.m4a"), key=natural_key)
    if not source_paths:
        raise SystemExit(f"No .m4a files found in {args.raw_dir}")
    if args.output_dir.exists() and any(args.output_dir.iterdir()):
        raise SystemExit(f"Output directory must be empty: {args.output_dir}")
    args.output_dir.mkdir(parents=True, exist_ok=True)
    transcript_hints: dict[str, str] = {}
    if args.transcript_hints.exists():
        transcript_hints = json.loads(
            args.transcript_hints.read_text(encoding="utf-8")
        )

    counters: Counter[str] = Counter()
    rows: list[dict[str, object]] = []
    with tempfile.TemporaryDirectory(prefix="gmtk-family-voice-") as temp_name:
        temp_directory = Path(temp_name)
        for source_index, source_path in enumerate(source_paths, start=1):
            source_id = f"kid_{source_index}"
            public_source_name = f"recording_{source_index:02d}.m4a"
            default_group = SOURCE_GROUP_HINTS.get(source_id, "other")
            for segment_index, (start_time, end_time) in enumerate(
                nonsilent_ranges(source_path),
                start=1,
            ):
                group_name = SEGMENT_GROUP_OVERRIDES.get(
                    (source_id, segment_index),
                    default_group,
                )
                counters[group_name] += 1
                candidate_name = f"{group_name}_{counters[group_name]:02d}.ogg"
                candidate_path = args.output_dir / candidate_name
                candidate_duration, candidate_peak = encode_candidate(
                    source_path,
                    start_time,
                    end_time,
                    candidate_path,
                    temp_directory,
                )
                rows.append(
                    {
                        "candidate": candidate_name,
                        "group": group_name,
                        "transcript": transcript_hints.get(
                            f"{source_id}:{segment_index}",
                            "",
                        )
                        .replace("|", "/")
                        .replace("\n", " ")
                        .strip(),
                        "duration": candidate_duration,
                        "source": public_source_name,
                        "segment": segment_index,
                        "start": start_time,
                        "end": end_time,
                        "peak": candidate_peak,
                    }
                )
    write_manifest(args.output_dir, rows)
    print(
        f"Wrote {len(rows)} candidates and manifest to {args.output_dir}"
    )


if __name__ == "__main__":
    main()
