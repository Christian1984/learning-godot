extends Area2D

class_name Attack

@export var attack_levels: Array[AttackLevelInfo] = []

@export var level = 1
@export var ttl = 15

var attack_info: AttackLevelInfo
var duration = 0

@onready var player = get_tree().get_first_node_in_group("player")

func _ready():
	if len(attack_levels) == 0:
		printerr("attack levels not provided")
		queue_free()
		return

	if level <= len(attack_levels):
		attack_info = attack_levels[level - 1]
	else:
		attack_info = attack_levels[len(attack_levels) - 1]
	
signal remove_from_list(obj: Object)

func _physics_process(delta):
	duration += delta
	
	if duration > ttl:
		emit_signal("remove_from_list", self)
		queue_free()

func enemy_hit(charge = 1):
	if attack_info.hp > 0: # don't remove charges from attacks that start with hp == 0
		attack_info.hp -= charge
		if attack_info.hp<=0:
			emit_signal("remove_from_list", self)
			queue_free()

func get_damage():
	return attack_info.damage
	
func get_knockback():
	return attack_info.knockback

