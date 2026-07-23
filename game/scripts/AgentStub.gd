extends Node3D

## A0 navigation proof stub. Lane B owns the actor behaviours; this only keeps
## the static-navmesh movement contract alive until those scripts replace it.

@export var navigation_speed: float = 1.5

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D


func _physics_process(delta: float) -> void:
	if navigation_agent.is_navigation_finished():
		return
	var next_position: Vector3 = navigation_agent.get_next_path_position()
	global_position = global_position.move_toward(next_position, navigation_speed * delta)


func set_navigation_target(target: Vector3) -> void:
	navigation_agent.target_position = target
