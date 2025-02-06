extends GridMap

signal terrain_changed(gridmap: GridMap)

@onready var initial_terrain_changed_signal_timer: Timer = $InitialTerrainChangedSignalTimer

@export var half_width: int = 32
@export var half_length: int = 32

@export var sea_level: int = 48
@export var standard_elevation: int = 16
@export var distance_gain: float = 5.0 / 100000
@export var max_gain: float = 2.0

var Spawner = preload("res://scenes/spawner.tscn")

func emit_terrain_changed():
	terrain_changed.emit(self)

func _ready():	
	var noise = FastNoiseLite.new()
	var offset = Vector3(
		global_position.x / cell_size.x,
		global_position.y / cell_size.y,
		global_position.z / cell_size.z
	)
	
	for x in range(2 * half_width):
		for z in range(2 * half_length):
			var horizontal_position = Vector2(x - half_width + offset.x, z - half_length + offset.z)
			var noise_val = noise.get_noise_2dv(horizontal_position)
			
			var radius = horizontal_position.length()
			var radius_gain = clamp(radius * radius * distance_gain, 0, max_gain)
			var noise_val_with_gain = noise_val * radius_gain
			
			var height = round(noise_val * radius_gain * standard_elevation) + sea_level
			for y in range(height):
				var item = 0
				if y == height - 1:
					item = 1
					if x == half_width - 1 or x == half_width or \
						z == half_length - 1 or z == half_length:
						item = 3
					elif x == 0 or x == 2 * half_width - 1 or \
						z == 0 or z == 2 * half_length - 1:
						item = 2
					
					if x == half_width - 1 and z == half_length - 1:
						var spawner = Spawner.instantiate() as StaticBody3D
						add_child(spawner)
						var spawn_position = map_to_local(Vector3(x - half_width, y, z - half_width)) + Vector3.UP
						spawner.position = spawn_position
						print("spawner spawned at ", spawn_position)
						
				var block_position = Vector3(x - half_width, y, z - half_width)
				set_cell_item(block_position, item)
				
				
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
