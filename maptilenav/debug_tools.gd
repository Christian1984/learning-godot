extends Node

signal set_debug_navigation_active(active: bool)

var debug_nav_active = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("debug_nav_active_toggle"):
		debug_nav_active = not debug_nav_active
		set_debug_navigation_active.emit(debug_nav_active)
