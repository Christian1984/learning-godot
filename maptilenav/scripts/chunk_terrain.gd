extends GridMap

signal terrain_changed(gridmap: GridMap)

@onready var initial_terrain_changed_signal_timer: Timer = $InitialTerrainChangedSignalTimer
@onready var chunk: Chunk = $"../.."
@onready var offset = Vector3(
	global_position.x / cell_size.x,
	global_position.y / cell_size.y,
	global_position.z / cell_size.z
)

@export var half_size: int = 32

@export var sea_level: int = 48
@export var standard_elevation: int = 16
@export var distance_gain: float = 5.0 / 100000
@export var max_gain: float = 2.0

var Spawner = preload("res://scenes/spawner.tscn")
var noise = FastNoiseLite.new()

func emit_terrain_changed():
	terrain_changed.emit(self)
	
func calculate_height(local_horizontal_grid_position: Vector2):
	var global_horizontal_grid_position = local_horizontal_grid_position + Vector2(offset.x, offset.z)
	var noise_val = noise.get_noise_2dv(global_horizontal_grid_position)
	var radius = global_horizontal_grid_position.length()
	var radius_gain = clamp(radius * radius * distance_gain, 0, max_gain)
	
	return round(noise_val * radius_gain * standard_elevation) + sea_level

func create_spawners():
	var spawner_horizontal_grid_positions = PackedVector2Array()
	
	for i in range(chunk.spawners):
		while true:
			var local_horizontal_grid_position_f = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized() * randi_range(0, half_size / 2)
			var local_horizontal_grid_position_i = local_horizontal_grid_position_f.floor()
			
			if local_horizontal_grid_position_i not in spawner_horizontal_grid_positions:
				spawner_horizontal_grid_positions.append(local_horizontal_grid_position_i)
				
				var height = calculate_height(local_horizontal_grid_position_i)
				var grid_position = Vector3(local_horizontal_grid_position_i.x, height, local_horizontal_grid_position_i.y)
				var position = map_to_local(grid_position)
				
				var spawner = Spawner.instantiate() as Node3D
				add_child(spawner)
				spawner.position = position
				print("spawner created at ", position)
				
				break

func _ready():
	#print(get_groups())
	#print(get_tree().get_nodes_in_group("terrain_foo"))
	for x in range(2 * half_size):
		for z in range(2 * half_size):
			var local_horizontal_grid_position = Vector2(x - half_size, z - half_size)
			var height = calculate_height(local_horizontal_grid_position)
			
			for y in range(height):
				var item = 0
				if y == height - 1:
					item = 1
					if x == half_size - 1 or x == half_size or \
						z == half_size - 1 or z == half_size:
						item = 3
					elif x == 0 or x == 2 * half_size - 1 or \
						z == 0 or z == 2 * half_size - 1:
						item = 2
					
					#if x == half_size - 1 and z == half_size - 1:
						#var spawner = Spawner.instantiate() as StaticBody3D
						#add_child(spawner)
						#var spawn_position = map_to_local(Vector3(x - half_size, y, z - half_size)) + Vector3.UP
						#spawner.position = spawn_position
						#print("spawner spawned at ", spawn_position)
						
				var block_position = Vector3(local_horizontal_grid_position.x, y, local_horizontal_grid_position.y)
				set_cell_item(block_position, item)
				
	create_spawners()
	initial_terrain_changed_signal_timer.wait_time = randf() * 2
	initial_terrain_changed_signal_timer.start()

func create_block(world_coords: Vector3, type: int):
	var local_coords = to_local(world_coords)
	var grid_coords = local_to_map(local_coords)
	
	if get_cell_item(grid_coords) == INVALID_CELL_ITEM:
		set_cell_item(grid_coords, type)
		emit_terrain_changed()

func destroy_block(world_coords: Vector3):
	var local_coords = to_local(world_coords)
	var grid_coords = local_to_map(local_coords)
	
	if get_cell_item(grid_coords) != INVALID_CELL_ITEM:
		set_cell_item(grid_coords, INVALID_CELL_ITEM)
		emit_terrain_changed()


func _on_initial_terrain_changed_signal_timer_timeout():
	emit_terrain_changed()
