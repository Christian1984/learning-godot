extends Node2D

@export var spawns: Array[SpawnInfo] = []

@onready var player: Node2D = get_tree().get_first_node_in_group("player")

var time = 0



func _on_spawn_timer_timeout():
	time += 1
	
	for i in spawns:
		if time >= i.time_start and time < i.time_end:
			if i.spawn_delay_counter < i.enemy_spawn_delay:
				i.spawn_delay_counter += 1
			else:
				i.spawn_delay_counter = 0
				# var new_enemy: Resource = load(str(i.enemy.resource_path))
				var new_enemy: Resource = i.enemy
				var counter = 0
				while counter < i.enemy_num:
					var enemy_spawn: Node2D = new_enemy.instantiate()
					# print_debug(enemy_spawn)
					#var spawn_pos = get_random_radial_position()
					var spawn_pos = get_random_viewport_position()
					enemy_spawn.global_position = spawn_pos
					# print_debug("spawning enemy at " + str(spawn_pos))
					add_child(enemy_spawn)
					counter += 1
					
func get_random_radial_position():
	var vpr = get_viewport_rect()
	var player_pos = player.global_position
	var dir = Vector2.from_angle(randf() * 2 * PI)
	var length = vpr.size.length() * 0.5 * 1.1
	
	return player_pos + dir * length

func get_random_viewport_position():
	var vpr = get_viewport_rect()
	var player_pos = player.global_position
	
	var topL = player_pos - 0.5 * vpr.size
	var topR = player_pos + 0.5 * Vector2(vpr.size.x, - vpr.size.y)
	var bottomL = player_pos + 0.5 * Vector2(-vpr.size.x, vpr.size.y)
	var bottomR = player_pos + 0.5 * vpr.size
	
	var p1 = topL
	var p2 = topL
	
	var dir = ["u", "d", "l", "r"].pick_random()
	match dir:
		"u":
			p1 = topL
			p2 = topR
		"r":
			p1 = topR
			p2 = bottomR
		"d":
			p1 = bottomL
			p2 = bottomR
		"l":
			p1 = topL
			p2 = bottomL
	
	var x = randf_range(p1.x, p2.x)
	var y = randf_range(p1.y, p2.y)
	
	return Vector2(x, y) * 1.1
