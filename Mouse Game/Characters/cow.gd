extends CharacterBody2D

@export var move_speed = 10

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_state_machine: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")
@onready var sprite: Sprite2D = $Sprite2D

var move_direction = Vector2(1, 1).normalized();

func _ready():
	animation_tree.active = true
	
func _physics_process(_delta):
	velocity = move_speed * move_direction
	move_and_slide()
	
	if (randf() < 0.01):
		toggle()
	
	update_animation()

func toggle():
	if (move_direction == Vector2.ZERO):
		move_direction = Vector2(randf() - 0.5, randf() - 0.5).normalized()
	else:
		move_direction = Vector2.ZERO
	

func update_animation():
	if (move_direction == Vector2.ZERO):
		animation_state_machine.travel("Idle")
	else:
		animation_state_machine.travel("Walk")
		sprite.flip_h = move_direction.x < 0

