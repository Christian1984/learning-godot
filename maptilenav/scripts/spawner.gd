extends StaticBody3D

@onready var map: Node3D = $"/root/Map"
var Enemy = preload("res://scenes/enemy.tscn")

func _on_timer_timeout():
	var enemy = Enemy.instantiate() as CharacterBody3D
	map.add_child(enemy)
	var spawn_position = global_position + Vector3.RIGHT * 2
	enemy.position = spawn_position
	print("enemy spawned at ", spawn_position)
