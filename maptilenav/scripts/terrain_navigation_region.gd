extends NavigationRegion3D

@onready var timer: Timer = $Timer

func _on_timer_timeout():
	timer.stop()
	bake_navigation_mesh(true)
	
func _on_navigation_mesh_changed() -> void:
	print("navmesh changed")

func sum(accum, number):
	return accum + number

func create_combined_cube_mesh(gridmap: GridMap) -> ArrayMesh:
	print("Create combined cube mesh...")
	var start = Time.get_ticks_msec()
	
	var array_mesh = ArrayMesh.new()
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(2, 2, 2)  # Match GridMap cell size

	var arrays = box_mesh.surface_get_arrays(0)  # Get cube mesh data
	var vertices = arrays[Mesh.ARRAY_VERTEX]  # Cube vertices
	var indices = arrays[Mesh.ARRAY_INDEX]  # Cube indices

	var mesh_data = []
	mesh_data.resize(Mesh.ARRAY_MAX)
	mesh_data[Mesh.ARRAY_VERTEX] = []
	mesh_data[Mesh.ARRAY_INDEX] = []

	var vertex_offset = 0
	var cell_times = []
	
	for cell in gridmap.get_used_cells():
		var cell_start = Time.get_ticks_msec()
		
		var transform = gridmap.map_to_local(cell)
		for v in vertices:
			mesh_data[Mesh.ARRAY_VERTEX].append(v + transform)  # Offset vertices

		for i in indices:
			mesh_data[Mesh.ARRAY_INDEX].append(i + vertex_offset)  # Offset indices

		vertex_offset += vertices.size()
		
		cell_times.append(Time.get_ticks_msec() - cell_start)

	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, mesh_data)
	var res = array_mesh if mesh_data[Mesh.ARRAY_VERTEX].size() > 0 else null
	
	var cell_times_total = cell_times.reduce(sum, 0)
	print("cell_times total: " + str(cell_times_total) + " ms, samples: " + str(len(cell_times)) + ", average: " + str( cell_times_total * 1.0 / len(cell_times)) + " ms")
	print("Creating combined cube mesh done, took " + str(Time.get_ticks_msec() - start) + "ms")
	
	return res

func extract_gridmap_geometry(gridmap: GridMap) -> NavigationMeshSourceGeometryData3D:
	print("Extracting geometry...")
	var start = Time.get_ticks_msec()
	
	var navmesh_data = NavigationMeshSourceGeometryData3D.new()
	#var mesh = create_combined_cube_mesh(gridmap)
	
	#if mesh:
	#	print("mesh not null")
	#	navmesh_data.add_mesh(mesh, Transform3D.IDENTITY)
	
	var mesh_library = gridmap.mesh_library
	if not mesh_library:
		return navmesh_data
	
	var cell_times = []
	for cell in gridmap.get_used_cells():
		
		var item_id = gridmap.get_cell_item(cell)
		if item_id == GridMap.INVALID_CELL_ITEM:
			continue
		var mesh = mesh_library.get_item_mesh(item_id)
		
		if mesh:
			var transform = gridmap.map_to_local(cell)
			var mesh_transform = Transform3D(Basis(), transform)
			navmesh_data.add_mesh(mesh, mesh_transform)

	print("Extracting geometry done, took " + str(Time.get_ticks_msec() - start) + "ms")
	return navmesh_data

func apply_navmesh(navmesh: NavigationMesh):
	navigation_mesh = navmesh

func update_nav_mesh(gridmap: GridMap):
	print("Updating the nav mesh...")
	var start = Time.get_ticks_msec()
	
	var geometry = extract_gridmap_geometry(gridmap)
	navigation_mesh.clear_polygons()
	NavigationServer3D.bake_from_source_geometry_data(navigation_mesh, geometry)
	call_deferred("apply_navmesh", navigation_mesh)
	
	print("Updating nav mesh done, took " + str(Time.get_ticks_msec() - start) + "ms")
	

func terrain_updated(gridmap: GridMap):
	var thread = Thread.new()
	thread.start(update_nav_mesh.bind(gridmap))
	
	#timer.start()
