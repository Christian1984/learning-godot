extends GridMap

@onready var nav: NavigationRegion3D = $".."

func update_navigation():
	if nav.has_method("terrain_updated"):
		nav.call("terrain_updated", self)

func create_block(world_coords: Vector3, type: int):
	var local_coords = to_local(world_coords)
	var grid_coords = local_to_map(world_coords)
	
	if get_cell_item(grid_coords) == INVALID_CELL_ITEM:
		set_cell_item(grid_coords, type)
		update_navigation()

func destroy_block(world_coords: Vector3):
	var local_coords = to_local(world_coords)
	var grid_coords = local_to_map(world_coords)
	
	if get_cell_item(grid_coords) != INVALID_CELL_ITEM:
		set_cell_item(grid_coords, INVALID_CELL_ITEM)
		update_navigation()
