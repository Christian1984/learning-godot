extends CharacterBody3D

signal item_updated(name: String)

@onready var target: Node3D = $"/root/Map/Target"

const SPEED = 15.0
const JUMP_VELOCITY = 9.0
const FPS_MOUSE_SENSITIVITY = 0.005

@onready var cam = $Camera3D
@onready var ray: RayCast3D = $Camera3D/RayCast3D

@export var flying = false

var current_item_turret = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	toggle_item_selected()
	
func _unhandled_input(event):
	if (event is InputEventMouseMotion):
		rotation.y -= event.relative.x * FPS_MOUSE_SENSITIVITY
		cam.rotation.x = clamp(cam.rotation.x - event.relative.y * FPS_MOUSE_SENSITIVITY, -PI / 2, PI / 2)

func toggle_item_selected():
	current_item_turret = not current_item_turret
	var name = "Turret" if current_item_turret else "Block"
	item_updated.emit(name)

func eval_nav():
	var nav_maps = NavigationServer3D.get_maps()
	for nav_map in nav_maps:
		var path = NavigationServer3D.map_get_path(nav_map, global_position, target.global_position, false)
	
		if path.size() > 1:
			DrawDebug.draw_line(global_position, path[-1], Color.WHITE)
			for i in path.size() - 1:
				DrawDebug.draw_line(path[i], path[i + 1], Color.AQUA)

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("toggle_flight"):
		flying = not flying

	if Input.is_action_just_pressed("item_toggle"):
		toggle_item_selected()
	
	var lmb = Input.is_action_just_pressed("lmb") 
	var rmb = Input.is_action_just_pressed("rmb") 
	if lmb or rmb:
		var collider = ray.get_collider()
		
		if collider:
			var hit = ray.get_collision_point()
			var hit_normal = ray.get_collision_normal()
		
			if lmb and collider.has_method("destroy_block"):
				collider.call("destroy_block", hit - hit_normal)
			elif rmb: 
				if current_item_turret:
					if collider.has_method("create_turret"):
						collider.call("create_turret", hit + hit_normal)
				else:
					if collider.has_method("create_block"):
						collider.call("create_block", hit + hit_normal, 3)

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := Vector3.ZERO
	
	if flying:
		direction = (cam.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		
		if direction:
			velocity = direction * SPEED * 5
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.y = move_toward(velocity.y, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
	else:
		# Add the gravity.
		if not is_on_floor():
			velocity += get_gravity() * delta

		# Handle jump.
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY
			
		direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)

	#print(global_position)
	move_and_slide()
	eval_nav()
