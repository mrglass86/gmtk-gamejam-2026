extends Node3D
class_name DinnerWorldSwitch

## Instant player light switch. The switch owns its soft positional click;
## gameplay detection of the light change is visual-only.

signal toggled(switch_id: StringName, is_on: bool)

const CLICK_STREAM: AudioStream = preload("res://audio/sfx/light_switch.ogg")

@export var switch_id: StringName
@export var target_light_id: String
@export var target_fixture_path: NodePath
@export var additional_target_light_ids: PackedStringArray = PackedStringArray()
@export var additional_target_fixture_paths: Array[NodePath] = []
@export var starts_on: bool = true
@export var interaction_radius: float = 1.45
@export var click_volume_db: float = -5.0

var is_on: bool = true
var _player: DinnerPlayer
var _target_fixture: Node3D
var _additional_target_fixtures: Array[Node3D] = []
var _click_player: AudioStreamPlayer3D


func _ready() -> void:
	add_to_group("interactable")
	add_to_group("world_switch")
	_player = get_tree().get_first_node_in_group("player") as DinnerPlayer
	_target_fixture = get_node_or_null(target_fixture_path) as Node3D
	for fixture_path: NodePath in additional_target_fixture_paths:
		var additional_fixture: Node3D = (
			get_node_or_null(fixture_path) as Node3D
		)
		if additional_fixture != null:
			_additional_target_fixtures.append(additional_fixture)
	_click_player = AudioStreamPlayer3D.new()
	_click_player.name = "Click"
	_click_player.stream = CLICK_STREAM
	_click_player.volume_db = click_volume_db
	_click_player.max_distance = 10.0
	add_child(_click_player)
	set_state(starts_on, false)


func _exit_tree() -> void:
	stop_click_audio()


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("interact") or event.is_echo():
		return
	if _player == null or _player.input_locked:
		return
	if not _player.is_interaction_target(self):
		return
	set_state(not is_on, true)
	get_viewport().set_input_as_handled()


func set_state(on: bool, play_click: bool = false) -> void:
	is_on = on
	if _target_fixture != null:
		_target_fixture.visible = is_on
	for additional_fixture: Node3D in _additional_target_fixtures:
		additional_fixture.visible = is_on
	var toggle: Node3D = get_node_or_null("Toggle") as Node3D
	if toggle != null:
		toggle.rotation_degrees.x = -18.0 if is_on else 18.0
	if not target_light_id.is_empty() and LightSystem.has_method("set_light_enabled"):
		LightSystem.call("set_light_enabled", target_light_id, is_on)
	for additional_light_id: String in additional_target_light_ids:
		LightSystem.call("set_light_enabled", additional_light_id, is_on)
	if play_click:
		_click_player.pitch_scale = randf_range(0.94, 1.06)
		_click_player.play()
	toggled.emit(switch_id, is_on)


func is_player_in_range() -> bool:
	return (
		_player != null
		and _player.global_position.distance_to(global_position)
		<= interaction_radius
	)


func stop_click_audio() -> void:
	if is_instance_valid(_click_player):
		_click_player.stop()
		_click_player.stream = null


func sync_state_from_target() -> void:
	if _target_fixture != null:
		is_on = _target_fixture.visible
