extends ParallaxBackground

var stars_offset := Vector2.ZERO
var clouds_offset := Vector2.ZERO

@export var stars_speed := Vector2(5, 2)     # slow scroll
@export var clouds_speed := Vector2(15, 0)    # faster clouds

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	stars_offset.x += stars_speed.x * delta
	stars_offset.y += stars_speed.y * delta
	clouds_offset.x += clouds_speed.x * delta
	
	get_child(0).motion_offset = stars_offset
	get_child(2).motion_offset = clouds_offset
	pass
