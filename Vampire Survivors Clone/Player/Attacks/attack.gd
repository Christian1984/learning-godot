extends Area2D

class_name Attack

@export var attack_levels: Array[AttackLevelInfo] = []

@export var level = 1
@export var ttl = 60

var attack_info: AttackLevelInfo
var duration = 0

@onready var player = get_tree().get_first_node_in_group("player")

func _ready():
	print_debug("Attack")
	print_debug(attack_levels)
	if len(attack_levels) == 0:
		printerr("attack levels not provided")
		queue_free()
		return

	if level <= len(attack_levels):
		attack_info = attack_levels[level - 1]
	else:
		attack_info = attack_levels[len(attack_levels) - 1]
	
	print_debug(attack_info)

signal remove_from_list(obj: Object)

func get_damage():
	return attack_info.damage
	
func get_knockback():
	return attack_info.knockback

