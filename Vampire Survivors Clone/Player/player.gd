extends CharacterBody2D

@export var movementSpeed: float = 80

func _physics_process(_delta):
	movement()
	
func movement():
	var x_mov = Input.get_action_strength("right") - Input.get_action_strength("left")
	var y_mov = Input.get_action_strength("down") - Input.get_action_strength("up")
	velocity = movementSpeed * Vector2(x_mov, y_mov).normalized()
	move_and_slide()
