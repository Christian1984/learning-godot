extends CharacterBody2D

@export var movement_speed = 30
@export var health: int = 10

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_tree: AnimationTree = $AnimationTree

@onready var player: Node2D = get_tree().get_first_node_in_group("player")

func _physics_process(delta):
	var direction = global_position.direction_to(player.global_position)
		
	velocity = movement_speed * direction
	
	if direction.x > 0:
		sprite.set("flip_h", true)
	elif direction.x < 0:
		sprite.set("flip_h", false)
		
	animation_tree.active = velocity.length_squared() > 0
	
	move_and_slide()
