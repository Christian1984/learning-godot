extends GridMap

@onready var nav: NavigationRegion3D = $".."
@onready var player: CharacterBody3D = $"/root/Map/Player"

@export var half_width: int = 32
@export var half_length: int = 32

@export var min_height: int = 32
@export var max_height: int = 48
@export var distance_gain: float = 5.0 / 100000
@export var max_gain: float = 2.0


func _ready():
	var noise = FastNoiseLite.new()
	#TODO: offset from transform coords -> grid coords
	var offset = Vector3(
		global_position.x / cell_size.x,
		global_position.y / cell_size.y,
		global_position.z / cell_size.z
	)
	print(offset)
	
	for x in range(2 * half_width):
		for z in range(2 * half_length):
			var horizontal_position = Vector2(x - half_width + offset.x, z - half_length + offset.z)			
			var noise_val = noise.get_noise_2dv(horizontal_position)
			
			var radius = horizontal_position.length()
			var radius_gain = clamp(radius * radius * distance_gain, 0, max_gain)
			var noise_val_with_gain = noise_val * radius_gain
			
			var height = round(noise_val_with_gain * (max_height - min_height)) + min_height
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
				var block_position = Vector3(x - half_width, y, z - half_width)
				set_cell_item(block_position, item)

func update_navigation():
	if nav.has_method("terrain_updated"):
		nav.call("terrain_updated", self)

func create_block(world_coords: Vector3, type: int):
	var local_coords = to_local(world_coords)
	var grid_coords = local_to_map(local_coords)
	
	if get_cell_item(grid_coords) == INVALID_CELL_ITEM:
		set_cell_item(grid_coords, type)
		update_navigation()

func destroy_block(world_coords: Vector3):
	var local_coords = to_local(world_coords)
	var grid_coords = local_to_map(local_coords)
	
	if get_cell_item(grid_coords) != INVALID_CELL_ITEM:
		set_cell_item(grid_coords, INVALID_CELL_ITEM)
		update_navigation()
