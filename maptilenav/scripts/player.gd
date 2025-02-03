extends CharacterBody3D

@onready var navigation_region_3d: NavigationRegion3D = $"/root/Map/NavigationRegion3D"
@onready var target: Node3D = $"/root/Map/Target"

const SPEED = 10.0
const JUMP_VELOCITY = 9.0
const FPS_MOUSE_SENSITIVITY = 0.005

@onready var cam = $Camera3D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pass
	
func _unhandled_input(event):
	if (event is InputEventMouseMotion):
		rotation.y -= event.relative.x * FPS_MOUSE_SENSITIVITY
		cam.rotation.x = clamp(cam.rotation.x - event.relative.y * FPS_MOUSE_SENSITIVITY, -PI / 2, PI / 2)

func eval_nav():
	if not navigation_region_3d:
		return
	
	var nav_map = navigation_region_3d.get_navigation_map()
	var path = NavigationServer3D.map_get_path(nav_map, global_position, target.global_position, false)
	
	if path.size() > 1:
		print(path[-1])
		print(target.global_position)
		DrawDebug.draw_line(global_position, path[-1], Color.WHITE)
		for i in path.size() - 1:
			DrawDebug.draw_line(path[i], path[i + 1], Color.AQUA)
		if target.global_position.distance_to(path[-1]) < 1:
			print("Path to target is valid!")
		else:
			print("Path to target is NOT valid!")
	else:
		print("NO Path exists!")

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	eval_nav()
