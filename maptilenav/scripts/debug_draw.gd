extends Node

@onready var draw_debug: MeshInstance3D = $MeshInstance3D

func _physics_process(delta: float):
	if not (draw_debug.mesh is ImmediateMesh):
		return
	
	var mesh = draw_debug.mesh as ImmediateMesh
	mesh.clear_surfaces()

func draw_line(start: Vector3, end: Vector3, color: Color = Color.RED):
	if start.is_equal_approx(end) or not (draw_debug.mesh is ImmediateMesh):
		return
	
	var mesh = draw_debug.mesh as ImmediateMesh
	mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	mesh.surface_set_color(color)
	mesh.surface_add_vertex(start)
	mesh.surface_add_vertex(end)
	mesh.surface_end()

func draw_vector(start: Vector3, direction: Vector3, color: Color = Color.RED):
	draw_line(start, start + direction, color)
