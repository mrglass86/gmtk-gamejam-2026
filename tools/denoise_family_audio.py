#!/usr/bin/env python3
"""Create conservative A18 denoised A/B copies of selected family audio."""

from __future__ import annotations

import argparse
import re
import shutil
import subprocess
import tempfile
from dataclasses import dataclass
from pathlib import Path


PROFILE_SAMPLES = 2205
SAMPLE_RATE = 48000
PROFILE_DURATION = PROFILE_SAMPLES / SAMPLE_RATE
MAX_PROFILE_RMS_DB = -35.0


@dataclass(frozen=True)
class Result:
    source: Path
    output: Path
    duration: float
    profile_time: float
    profile_rms_db: float
    cleaned: bool


def run(command: list[str]) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        command,
        check=True,
        text=True,
        capture_output=True,
    )


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


def quietest_profile(path: Path) -> tuple[float, float]:
    result = subprocess.run(
        [
            "ffmpeg",
            "-hide_banner",
            "-loglevel",
            "info",
            "-i",
            str(path),
            "-af",
            (
                f"asetnsamples=n={PROFILE_SAMPLES}:p=1,"
                "astats=metadata=1:reset=1,"
                "ametadata=print:key=lavfi.astats.Overall.RMS_level"
            ),
            "-f",
            "null",
            "-",
        ],
        check=True,
        text=True,
        capture_output=True,
    )
    current_time = 0.0
    best_time = 0.0
    best_rms = float("inf")
    found = False
    for line in result.stderr.splitlines():
        time_match = re.search(r"pts_time:([0-9.]+)", line)
        if time_match is not None:
            current_time = float(time_match.group(1))
            continue
        rms_match = re.search(
            r"lavfi\.astats\.Overall\.RMS_level=(-inf|-?[0-9.]+)",
            line,
        )
        if rms_match is None:
            continue
        rms = (
            -100.0
            if rms_match.group(1) == "-inf"
            else float(rms_match.group(1))
        )
        if not found or rms < best_rms:
            found = True
            best_rms = rms
            best_time = current_time
    if not found:
        raise RuntimeError(f"No RMS profile frames found in {path}")
    return best_time, best_rms


def denoise(
    source: Path,
    output: Path,
    profile_time: float,
    temporary_directory: Path,
) -> None:
    output.parent.mkdir(parents=True, exist_ok=True)
    wav_path = temporary_directory / f"{output.stem}.wav"
    filter_graph = (
        "[0:a]asplit=2[profile_source][program];"
        f"[profile_source]atrim=start={profile_time:.6f}:"
        f"duration={PROFILE_DURATION:.7f},"
        "asetpts=PTS-STARTPTS[profile];"
        "[program]asetpts=PTS-STARTPTS[program_reset];"
        "[profile][program_reset]concat=n=2:v=0:a=1,"
        f"asendcmd=c='{PROFILE_DURATION:.7f} afftdn sn stop',"
        "afftdn=nr=6:nf=-50:rf=-55:ad=0.7:gs=6:sn=start,"
        f"atrim=start={PROFILE_DURATION:.7f},"
        "asetpts=PTS-STARTPTS[out]"
    )
    run(
        [
            "ffmpeg",
            "-hide_banner",
            "-loglevel",
            "error",
            "-y",
            "-i",
            str(source),
            "-filter_complex",
            filter_graph,
            "-map",
            "[out]",
            "-ar",
            str(SAMPLE_RATE),
            "-ac",
            "1",
            "-c:a",
            "pcm_s16le",
            str(wav_path),
        ]
    )
    run(
        [
            "oggenc",
            "-Q",
            "-q",
            "5",
            "-o",
            str(output),
            str(wav_path),
        ]
    )


def write_manifest(
    manifest_path: Path,
    source_root: Path,
    output_root: Path,
    results: list[Result],
) -> None:
    cleaned_count = sum(result.cleaned for result in results)
    lines = [
        "# A18 conservative spectral-denoise pass",
        "",
        "Original files remain unchanged under `game/audio/original/`; matching",
        "A/B copies are under `game/audio/denoised/`.",
        "",
        (
            "Each clip is scanned in 45.9 ms windows. Its quietest window is "
            "accepted as a clip-local noise profile only at or below -35 dBFS."
        ),
        (
            "Accepted clips use FFmpeg `afftdn` with 6 dB reduction, fixed "
            "profile sampling, 0.7 adaptivity, and 6-band gain smoothing."
        ),
        (
            "Rejected clips are not processed; runtime pools must omit them "
            "and retain their CC0 fallback."
        ),
        "",
        f"- Cleaned: {cleaned_count}",
        f"- Rejected / CC0 fallback: {len(results) - cleaned_count}",
        f"- Total: {len(results)}",
        "",
        "| Original | A/B copy | Profile (s) | RMS (dBFS) | Duration (s) | Status |",
        "|---|---|---:|---:|---:|---|",
    ]
    for result in sorted(results, key=lambda row: str(row.source)):
        workspace_root = source_root.parent.parent.parent
        source_relative = result.source.relative_to(workspace_root)
        if result.cleaned:
            output_relative = result.output.relative_to(workspace_root)
            output_text = f"`{output_relative}`"
            status = "cleaned"
        else:
            output_text = "—"
            status = "CC0 fallback"
        lines.append(
            f"| `{source_relative}` | {output_text} | "
            f"{result.profile_time:.4f} | {result.profile_rms_db:.2f} | "
            f"{result.duration:.3f} | {status} |"
        )
    manifest_path.parent.mkdir(parents=True, exist_ok=True)
    manifest_path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--source",
        type=Path,
        default=Path("game/audio/original"),
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=Path("game/audio/denoised"),
    )
    args = parser.parse_args()
    source_root = args.source.resolve()
    output_root = args.output.resolve()
    for executable in ["ffmpeg", "ffprobe", "oggenc"]:
        if shutil.which(executable) is None:
            raise RuntimeError(f"Missing required executable: {executable}")

    source_paths = sorted(source_root.rglob("*.ogg"))
    if not source_paths:
        raise RuntimeError(f"No OGG files found below {source_root}")
    results: list[Result] = []
    with tempfile.TemporaryDirectory(prefix="a18-denoise-") as temp_name:
        temporary_directory = Path(temp_name)
        for source_path in source_paths:
            relative_path = source_path.relative_to(source_root)
            output_path = output_root / relative_path
            duration = duration_seconds(source_path)
            profile_time, profile_rms = quietest_profile(source_path)
            cleaned = profile_rms <= MAX_PROFILE_RMS_DB
            if cleaned:
                denoise(
                    source_path,
                    output_path,
                    profile_time,
                    temporary_directory,
                )
                output_duration = duration_seconds(output_path)
                if abs(output_duration - duration) > 0.06:
                    raise RuntimeError(
                        f"Duration drift for {output_path}: "
                        f"{duration:.3f} -> {output_duration:.3f}"
                    )
            elif output_path.exists():
                output_path.unlink()
            results.append(
                Result(
                    source=source_path,
                    output=output_path,
                    duration=duration,
                    profile_time=profile_time,
                    profile_rms_db=profile_rms,
                    cleaned=cleaned,
                )
            )
    write_manifest(
        output_root / "MANIFEST.md",
        source_root,
        output_root,
        results,
    )
    cleaned_count = sum(result.cleaned for result in results)
    print(
        f"A18 denoise complete: {cleaned_count} cleaned, "
        f"{len(results) - cleaned_count} rejected, {len(results)} total."
    )


if __name__ == "__main__":
    main()
