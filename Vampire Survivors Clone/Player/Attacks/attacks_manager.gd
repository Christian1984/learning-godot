extends Node2D

class_name AttacksManager

var enemies_close: Array[Node2D] = [] # TODO

func get_random_enemy(): 
	if enemies_close.size() > 0:
		var target =  enemies_close.pick_random().global_position
		print_debug(target)
		return target

	return position + Vector2.from_angle(randf() * 2 * PI)

func _on_enemy_detector_body_entered(body):
	print("someone has entered!")
	if not enemies_close.has(body):
		enemies_close.append(body)

func _on_enemy_detector_body_exited(body):
	if enemies_close.has(body):
		enemies_close.erase(body)
