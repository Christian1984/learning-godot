extends CharacterBody2D

@export var movement_speed = 30

@onready var player: Node2D = get_tree().get_first_node_in_group("player")

func _ready():
	print_debug(player)
	
func _physics_process(delta):
	var direction = global_position.direction_to(player.global_position)
	velocity = movement_speed * direction
	move_and_slide()
