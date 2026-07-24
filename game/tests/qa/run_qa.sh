#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "$0")" && pwd)"
game_dir="$(cd "$script_dir/../.." && pwd)"
godot_bin="${GODOT_BIN:-/Applications/Godot.app/Contents/MacOS/Godot}"

for scenario in caught-snack switch-spam crib-margin restart-fuzz snack-placements carry-collisions; do
  "$godot_bin" --headless --path "$game_dir" --scene res://tests/qa/QARunner.tscn -- \
    "--qa-scenario=$scenario" --qa-seed=260724
done

for actor_state in carry found investigate searchlight epilogue-exit epilogue-close epilogue-hall epilogue-reopen epilogue-peek epilogue-reclose epilogue-kitchen epilogue-room-enter epilogue-room-dwell epilogue-room-exit; do
  "$godot_bin" --headless --path "$game_dir" --scene res://tests/qa/QARunner.tscn -- \
    --qa-scenario=expiry "--qa-state=$actor_state" --qa-seed=260724
done

for seed in ${QA_SEEDS:-260724 7331 9001}; do
  "$godot_bin" --headless --path "$game_dir" --scene res://tests/qa/QARunner.tscn -- \
    --qa-scenario=monkey "--qa-seed=$seed"
done
