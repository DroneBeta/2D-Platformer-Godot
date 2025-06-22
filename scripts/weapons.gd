extends Node2D

var rotation_speed := 10.0

func _physics_process(delta: float) -> void:
	var target_pos = get_global_mouse_position()
	var target_angle = (target_pos - global_position).angle()
	
	rotation = lerp_angle(rotation, target_angle, rotation_speed * delta)
	
	rotation_degrees = wrap(rotation_degrees, 0, 360)
	if rotation_degrees > 90 and rotation_degrees < 270:
		scale.y = -1
	else:
		scale.y = 1
	
