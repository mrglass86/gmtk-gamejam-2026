extends Node3D

## Entry-point helpers owned by lane A. The layout capture is opt-in and is used
## only for director review: pass --capture-layout=/absolute/path/to/file.png.

@export var capture_warmup_frames: int = 3

const REQUIRED_ACTIONS: PackedStringArray = [
	"move_left",
	"move_right",
	"move_forward",
	"move_back",
	"run",
	"interact",
	"restart",
	"debug_skip",
	"debug_rewind",
	"debug_overlay",
	"debug_teleport",
	"debug_spawn_noise",
]


func _ready() -> void:
	_verify_input_map()
	var capture_path: String = _capture_path_from_args()
	if not capture_path.is_empty():
		_capture_layout(capture_path)


func _verify_input_map() -> void:
	for action: String in REQUIRED_ACTIONS:
		if not InputMap.has_action(action):
			push_error("Missing required input action: %s" % action)
			return
	print("A0 input map verified: %d required actions present." % REQUIRED_ACTIONS.size())


func _capture_path_from_args() -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--capture-layout="):
			return argument.trim_prefix("--capture-layout=")
	return ""


func _capture_layout(capture_path: String) -> void:
	for frame: int in range(capture_warmup_frames):
		await get_tree().process_frame
	var image: Image = get_viewport().get_texture().get_image()
	var result: Error = image.save_png(capture_path)
	if result != OK:
		push_error("Could not save layout capture to %s (error %d)." % [capture_path, result])
	else:
		print("A0 layout capture saved: %s" % capture_path)
	get_tree().quit()
