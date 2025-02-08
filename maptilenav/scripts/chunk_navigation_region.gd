extends NavigationRegion3D

@onready var timer: Timer = $RegenrateNavMeshTimer
@onready var terrain: GridMap = $Terrain

func _on_timer_timeout():
	timer.stop()
	
	var thread = Thread.new()
	thread.start(update_nav_mesh.bind(terrain))

func _on_terrain_terrain_changed(gridmap: GridMap):
	timer.start()
	var maps = NavigationServer3D.get_maps()
	if maps:
		for map in maps:
			var regions = NavigationServer3D.map_get_regions(map)
			var agents = NavigationServer3D.map_get_agents(map)
			print("regions: ", regions)
			print("agents: ", agents)
			

func _ready():
	navigation_mesh = NavigationMesh.new()
	navigation_mesh.agent_height = 4.0
	navigation_mesh.agent_max_climb = 3
	navigation_mesh.agent_radius = 1

func sum(accum, number):
	return accum + number

func create_combined_cube_mesh(gridmap: GridMap) -> ArrayMesh:
	print("Create combined cube mesh...")
	var start = Time.get_ticks_msec()
	var array_mesh = ArrayMesh.new()
	var box_mesh = BoxMesh.new()
	box_mesh.size = gridmap.cell_size

	var box_arrays = box_mesh.surface_get_arrays(0)
	var box_vertices = box_arrays[Mesh.ARRAY_VERTEX]
	var box_uvs = box_arrays[Mesh.ARRAY_TEX_UV]
	var box_indices = box_arrays[Mesh.ARRAY_INDEX]
	var box_normals = box_arrays[Mesh.ARRAY_NORMAL]
	
	var verts = PackedVector3Array()
	var uvs = PackedVector2Array()
	var normals = PackedVector3Array()
	var indices = PackedInt32Array()

	var vertex_offset = 0
	var cell_times = []
	
	for cell in gridmap.get_used_cells():
		var cell_start = Time.get_ticks_msec()
		
		var transform = gridmap.map_to_local(cell)
		for v in box_vertices:
			verts.append(v + transform)
			
		for uv in box_uvs:
			uvs.append(uv)
			
		for normal in box_normals:
			normals.append(normal)

		for i in box_indices:
			indices.append(i + vertex_offset)

		vertex_offset += box_vertices.size()
		
		cell_times.append(Time.get_ticks_msec() - cell_start)

	var mesh_data = []
	mesh_data.resize(Mesh.ARRAY_MAX)
	mesh_data[Mesh.ARRAY_VERTEX] = verts
	mesh_data[Mesh.ARRAY_TEX_UV] = uvs
	mesh_data[Mesh.ARRAY_INDEX] = indices
	mesh_data[Mesh.ARRAY_NORMAL] = normals

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
	var mesh = create_combined_cube_mesh(gridmap)
	
	if mesh:
		navmesh_data.add_mesh(mesh, Transform3D.IDENTITY)

	print("Extracting geometry done, took " + str(Time.get_ticks_msec() - start) + "ms")
	return navmesh_data

func apply_navmesh(navmesh: NavigationMesh):
	navigation_mesh = navmesh
	print("me: ", name, ", terrain: ", terrain.name,", get_region_rid(): ", get_region_rid(), ", navmesh.get_instance_id(): ", navmesh.get_instance_id(), ", get_navigation_map(): ", get_navigation_map())

func update_nav_mesh(gridmap: GridMap):
	print("Updating the nav mesh...")
	var start = Time.get_ticks_msec()
	
	var geometry = extract_gridmap_geometry(gridmap)
	navigation_mesh.clear_polygons()
	NavigationServer3D.bake_from_source_geometry_data(navigation_mesh, geometry)
	call_deferred("apply_navmesh", navigation_mesh)
	
	print("Updating nav mesh done, took " + str(Time.get_ticks_msec() - start) + "ms")
