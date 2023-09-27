extends CharacterBody2D

@export var move_speed: float = 100
@export var starting_direction: Vector2 = Vector2(0, 1)

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_state_machine: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")

func _ready():
	#animation_tree.set("parameters/Idle/blend_position", starting_direction)
	animation_tree.active = true
	update_animation(starting_direction)

func _physics_process(_delta):
	var input = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	)
	
	#print(input)
	
	velocity = move_speed * input
	move_and_slide()
	
	update_animation(input)

func update_animation(move_direction: Vector2):
	if (move_direction != Vector2.ZERO):
		animation_tree.set("parameters/Idle/blend_position", move_direction)
		animation_tree.set("parameters/Walk/blend_position", move_direction)
		animation_state_machine.travel("Walk")
	else:
		animation_state_machine.travel("Idle")
