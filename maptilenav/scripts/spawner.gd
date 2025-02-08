extends Node3D

@onready var map: Node3D = $"/root/Map"
@onready var spawn_position: Node3D = $StaticBody3D/SpawnPosition

@export var active = true

const Enemy = preload("res://scenes/enemy.tscn")

func _on_timer_timeout():
	if not active:
		return
		
	var enemy = Enemy.instantiate() as CharacterBody3D
	map.add_child(enemy)
	#var spawn_position = global_position + Vector3.UP * 0.5
	enemy.position = spawn_position.global_position
	print("enemy spawned at ", spawn_position.global_position)
