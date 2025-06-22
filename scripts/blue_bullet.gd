extends Node2D

@onready var ray_check: RayCast2D = $RayCheck
@onready var bullet_destroyed_animation: CPUParticles2D = $"../BulletDestroyedAnimation"


const SPEED: int = 600

func _process(delta: float) -> void:
	position += transform.x * SPEED * delta
	bullet_destroyed_animation.position += transform.x * SPEED * delta
	if ray_check.is_colliding():
		bullet_destroyed_animation.emitting = true
		queue_free()


func _on_distance_based_dispawning_screen_exited() -> void:
	queue_free()
