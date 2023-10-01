extends CharacterBody2D

@export var movementSpeed: float = 80
@export var health: int = 80

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_tree: AnimationTree = $AnimationTree

func _physics_process(_delta):
	movement()
	
func movement():
	var x_mov = Input.get_action_strength("right") - Input.get_action_strength("left")
	var y_mov = Input.get_action_strength("down") - Input.get_action_strength("up")
	
	velocity = movementSpeed * Vector2(x_mov, y_mov).normalized()
	
	if x_mov > 0:
		sprite.set("flip_h", true)
	elif x_mov < 0:
		sprite.set("flip_h", false)
	
	animation_tree.active = velocity.length_squared() > 0
	
	move_and_slide()

func _on_hurtbox_hurt(damage):
	print_debug("_on_hitbox_hurt_character")
	health -= damage
	print_debug(health)
