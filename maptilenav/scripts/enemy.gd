extends CharacterBody3D

@onready var target: Node3D = $"/root/Map/Target"
@onready var player: Node3D = $"/root/Map/Player"

const SPEED = 5.0
const ACCELERATION = 0.2
const JUMP_VELOCITY = 20

@onready var nav = $NavigationAgent3D

var do_nav = true


func _ready():
	if (target):
		print("target found: " + str(target.global_position))
		nav.target_position = target.global_position
		
func _process(delta: float):
	if Input.is_action_just_pressed("pause_nav"):
		do_nav = not do_nav

func _physics_process(delta: float):
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (player.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	
	if Input.is_action_just_released("ui_left") or \
		Input.is_action_just_released("ui_right") or \
		Input.is_action_just_released("ui_up") or \
		Input.is_action_just_released("ui_down"):
		velocity = Vector3.ZERO
		
	var next_location = nav.get_next_path_position()
	DrawDebug.draw_line(global_position, next_location, Color.GREEN)
	
	if not direction:
		if do_nav:
			if nav.is_target_reachable():
				velocity = velocity.move_toward((next_location - global_position).normalized() * SPEED, ACCELERATION)
			else:
				print("Target is NOT reachable!")
				velocity = velocity.move_toward(Vector3.ZERO, ACCELERATION)
		else:
			velocity = Vector3.ZERO
		
		print("velocity: " + str(velocity.length()) + ", index: " + str(nav.get_current_navigation_path_index()))
		


	DrawDebug.draw_vector(global_position, velocity, Color.BLUE)
	move_and_slide()
