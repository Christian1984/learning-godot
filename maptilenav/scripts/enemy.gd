extends CharacterBody3D

@export var health: float = 10.0

@onready var target: Node3D = $"/root/Map/Target"
@onready var player: Node3D = $"/root/Map/Player"

@onready var health_bar: ProgressBar = $HealthBarViewport/HealthBar
@onready var health_bar_sprite_3d: Sprite3D = $HealthBarSprite3D

@onready var nav = $NavigationAgent3D
@onready var restart_navigation_timer: Timer = $RestartNavigationTimer

@onready var max_health = health

const SPEED = 5.0
const ACCELERATION = 0.2
const JUMP_VELOCITY = 20

var do_nav = true

func _on_set_debug_navigation_active(active: bool):
	print("nav active: ", active)
	do_nav = active

func _ready():
	print(len(get_tree().get_nodes_in_group("navigation_regions")))
	DebugTools.set_debug_navigation_active.connect(_on_set_debug_navigation_active)
	do_nav = DebugTools.debug_nav_active
	
	if (target):
		print("target found: " + str(target.global_position))
		nav.target_position = target.global_position
		
	update_health_bar()

func _physics_process(delta: float):
	for collision_id in range(get_slide_collision_count()):
		var collision = get_slide_collision(collision_id)
		var other = collision.get_collider()
		if other.has_method("get_groups"):
			if "target" in other.get_groups():
				print("hit target")
				# TODO: send signal, reduce score/health
				queue_free()
				return
		
		if other.has_method("get_name"):
			if other.get_name() == "Terrain":
				print("hit terrain")
				#TODO: check direction, if is colliding with terrain, jump
	
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (player.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED * 10
		velocity.z = direction.z * SPEED * 10
	
	if Input.is_action_just_released("ui_left") or \
		Input.is_action_just_released("ui_right") or \
		Input.is_action_just_released("ui_up") or \
		Input.is_action_just_released("ui_down"):
		velocity = Vector3.ZERO
	
	var next_location = nav.get_next_path_position()

	if nav.is_navigation_finished() and not nav.is_target_reachable():
		next_location = global_position + velocity.move_toward(target.global_position - global_position, 0.1)

	DrawDebug.draw_line(global_position, next_location, Color.GREEN)
	
	if not direction:
		if do_nav:
			velocity = velocity.move_toward((next_location - global_position).normalized() * SPEED, ACCELERATION)
		else:
			velocity = Vector3.ZERO
		
	DrawDebug.draw_vector(global_position, velocity, Color.BLUE)
	move_and_slide()

func _on_restart_navigation_timer_timeout():
	nav.target_position = target.global_position

func _on_navigation_agent_3d_navigation_finished():
	if not nav.is_target_reachable():
		restart_navigation_timer.start()
		
func die():
	queue_free()

func update_health_bar():
	if health_bar:
		var v = clamp(health / max_health, 0, 1) * 100
		print(v)
		health_bar.value = clamp(health / max_health, 0, 1) * 100
		
		if health_bar_sprite_3d:
			health_bar_sprite_3d.visible = health < max_health

func take_damage(damage: float):
	health -= damage
	update_health_bar()
	print("take damage: ", damage, ", health: ", health)
	if health <= 0:
		die()
