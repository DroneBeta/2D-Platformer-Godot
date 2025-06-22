extends CharacterBody2D

@onready var jet_pack_fire: CPUParticles2D = $JetPackFire


# Player's WASD
const SPEED := 280.0
const ACCELERATION := 1500.0
const GROUND_FRICTION := 1500.0
var GROUND_GLIDE := 1.0
const WALL_FRICTION := 3000.0
var WALL_GLIDE := 1.0

# Gravity
const GRAVITY := 1800.0
const FAST_GRAVITY := 2300.0
const FAST_FALLING := 4000.0
const WALL_GRAVITY := 22.0
const JET_PACK_ACCELERATION := 500

# Properties of movement
const JUMP_VELOCITY := -600
const WALL_JUMP_VELOCITY := -400
const WALL_JUMP_PUSHBACK := 400
const DASH_VELOCITY := 800
const DASH_PUSH_DOWN := 200

# Time value
const INPUT_BUFFER_WAIT := 0.1
const COYOTE_JUMP_TIMER_WAIT := 0.1
const DASH_COOLDOWN_WAIT := 0.5
const JET_PACK_TIME := 0.3
var JET_PACK_FUEL := 20

# Timers
var input_buffer : Timer
var coyote_jump_timer : Timer
var coyote_jump_timer_available : bool = true
var dash_cooldown : Timer
var dash_cooldown_available : bool = true
var jet_pack_timer : Timer
var jet_pack_available : bool = false

func _ready():
	# Setup the cooldown
	input_buffer = Timer.new()
	input_buffer.wait_time = INPUT_BUFFER_WAIT
	input_buffer.one_shot = true
	add_child(input_buffer)
	
	coyote_jump_timer = Timer.new()
	coyote_jump_timer.wait_time = COYOTE_JUMP_TIMER_WAIT
	coyote_jump_timer.one_shot = true
	add_child(coyote_jump_timer)
	coyote_jump_timer.timeout.connect(coyote_timeout)
	
	dash_cooldown = Timer.new()
	dash_cooldown.wait_time = DASH_COOLDOWN_WAIT
	dash_cooldown.one_shot = true
	add_child(dash_cooldown)
	dash_cooldown.timeout.connect(dash_timeout)
	

func _physics_process(delta):
	var horizontal_input = Input.get_axis("ui_left", "ui_right")
	var jump_attempted = Input.is_action_just_pressed("action_1")
	var jump_hold = Input.is_action_pressed("action_1")
	var dash_attempted = Input.is_action_just_pressed("action_2")
	
	# Manages jump
	if jump_attempted or input_buffer.time_left > 0:
		if is_on_wall() and horizontal_input != 0:
			velocity.y = WALL_JUMP_VELOCITY
			velocity.x = WALL_JUMP_PUSHBACK * -sign(horizontal_input)
			# Wall jumping reset abilities
			dash_cooldown_available = true
			JET_PACK_FUEL = 20
		elif coyote_jump_timer_available and velocity.y >= 0:
			velocity.y = JUMP_VELOCITY
			coyote_jump_timer_available = false
		elif jump_attempted:
			input_buffer.start()
	elif jump_hold and JET_PACK_FUEL > 0:
		jet_pack_fire.emitting = true
		if velocity.y <= -100:
			velocity.y -= JET_PACK_ACCELERATION * delta
			JET_PACK_FUEL -= 1
			print(JET_PACK_FUEL)
		else:
			velocity.y -= JET_PACK_ACCELERATION * delta
			JET_PACK_FUEL -= 10
			print(JET_PACK_FUEL)
	
	# Jump Height changing based on how long you press
	if Input.is_action_just_released("action_1") and velocity.y < 0:
		velocity.y = JUMP_VELOCITY / 4
	
	# Manages dash
	if dash_attempted and dash_cooldown_available:
		velocity.x = horizontal_input * DASH_VELOCITY
		velocity.y = DASH_PUSH_DOWN
		dash_cooldown_available = false
		dash_cooldown.start()
	
	# Manages y axis + reset jumping
	if is_on_floor():
		coyote_jump_timer_available = true
		JET_PACK_FUEL = 20
	else:
		if coyote_jump_timer_available:
			if coyote_jump_timer.is_stopped():
				coyote_jump_timer.start()
		if Input.is_action_pressed("ui_down"):
			velocity.y += FAST_FALLING * delta
		elif is_on_wall_only() and velocity.y > 0 and horizontal_input != 0:
			velocity.y = move_toward(velocity.y, WALL_GRAVITY, (WALL_FRICTION * delta) * WALL_GLIDE)
		elif velocity.y < 0:
			velocity.y += GRAVITY * delta
		else:
			velocity.y += FAST_GRAVITY * delta
	
	
	# Manages x axis
	if horizontal_input:
		velocity.x = move_toward(velocity.x, horizontal_input * SPEED, ACCELERATION * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, (GROUND_FRICTION * delta) * GROUND_GLIDE)
	
	move_and_slide()




# Timeout conditions
func coyote_timeout():
	coyote_jump_timer_available = false

func dash_timeout():
	dash_cooldown_available = true
