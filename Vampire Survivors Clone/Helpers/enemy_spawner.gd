extends Node2D

@export var spawns: Array[SpawnInfo] = []

@onready var player: Node2D = get_tree().get_first_node_in_group("player")

var time = 0



func _on_spawn_timer_timeout():
	time += 1
	var enemy_spawns = spawns
	
	for i in enemy_spawns:
		if time >= i.time_start and time < i.time_end:
			if i.spawn_delay_counter < i.enemy_spawn_delay:
				i.spawn_delay_counter += 1
			else:
				i.spawn_delay_counter = 0
				var new_enemy: Resource = load(str(i.enemy.resource_path))
				var counter = 0
				while counter < i.enemy_num:
					var enemy_spawn: Node2D = new_enemy.instantiate()
					var spawn_pos = get_random_position()
					enemy_spawn.global_position = spawn_pos
					print_debug("spawning enemy at " + str(spawn_pos))
					add_child(enemy_spawn)
					counter += 1
					
func get_random_position():
	var vpr = get_viewport_rect()
	var player_pos = player.global_position
	var dir = Vector2.from_angle(randf() * 2 * PI)
	var len = vpr.size.length() * 0.5 * 1.1
	
	return player_pos + dir * len
