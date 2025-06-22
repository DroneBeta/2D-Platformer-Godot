extends Sprite2D

@onready var weapons: Node2D = $".."
@onready var muzzle: Marker2D = $ShotPos

const BULLET = preload("res://scenes/Projectiles.tscn")

const RELOAD_TIME = 0.1

var reload_timer : Timer
var shoot_available : bool = true

func _ready():
	reload_timer = Timer.new()
	reload_timer.wait_time = RELOAD_TIME
	reload_timer.one_shot = true
	add_child(reload_timer)
	reload_timer.timeout.connect(shoot_timeout)


func _process(delta: float) -> void:
	if Input.is_action_pressed("left_click") and shoot_available:
		var bullet_instance = BULLET.instantiate()
		get_tree().root.add_child(bullet_instance)
		bullet_instance.global_position = muzzle.global_position
		bullet_instance.rotation = weapons.rotation
		
		shoot_available = false
		reload_timer.start()

func shoot_timeout():
	shoot_available = true
