extends Node3D

@export var camera_position: Vector3 = Vector3(0.0, 30.0, 16.0)
@export var look_target: Vector3 = Vector3(0.0, 0.0, 0.0)


func _ready() -> void:
	global_position = camera_position
	look_at(look_target, Vector3.UP)
