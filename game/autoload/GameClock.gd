extends Node
## GameClock autoload — locked interface, brief section 3.
## Planner ruling 2026-07-23 (gamejam/DECISIONS.md): phase is 0..4 — the brief's
## interface said 0..3 while its section 4 table lists four transitions, so
## phase 0 is the run start (everything on) and phases 1..4 fire at
## 240/180/120/60 s remaining, mapping 1:1 to the section 4 table rows.
## The phase director (lane A, package A5) applies world state as a pure
## function of the current phase so debug scrubbing stays consistent.

signal phase_changed(phase: int)
signal time_expired()

@export var run_length: float = 300.0
@export var phase_interval: float = 60.0

var time_remaining: float
var phase: int = 0
var running: bool = false


func _ready() -> void:
	time_remaining = run_length


func start() -> void:
	time_remaining = run_length
	phase = 0
	running = true
	phase_changed.emit(phase)


func _process(delta: float) -> void:
	if not running:
		return
	time_remaining = maxf(time_remaining - delta, 0.0)
	_update_phase()
	if time_remaining <= 0.0:
		running = false
		time_expired.emit()


## Debug scrubbing (keys ] and [, lane A package A5). Positive skips forward.
func scrub(seconds: float) -> void:
	time_remaining = clampf(time_remaining - seconds, 0.0, run_length)
	_update_phase()
	if time_remaining <= 0.0 and running:
		running = false
		time_expired.emit()


func _update_phase() -> void:
	var safe_interval: float = maxf(phase_interval, 0.001)
	var target: int = clampi(int((run_length - time_remaining) / safe_interval), 0, 4)
	if target != phase:
		phase = target
		phase_changed.emit(phase)
