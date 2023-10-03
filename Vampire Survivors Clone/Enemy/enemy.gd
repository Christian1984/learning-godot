extends CharacterBody2D

@export var movement_speed = 30
@export var health = 20
@export var knockback_recovery = 3.5

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_tree: AnimationTree = $AnimationTree

@onready var player: Node2D = get_tree().get_first_node_in_group("player")

var current_knockback = Vector2.ZERO

func _physics_process(_delta):
	var direction = global_position.direction_to(player.global_position)
	current_knockback = current_knockback.move_toward(Vector2.ZERO, knockback_recovery)
		
	velocity = movement_speed * direction + current_knockback
	
	if direction.x > 0:
		sprite.set("flip_h", true)
	elif direction.x < 0:
		sprite.set("flip_h", false)
		
	animation_tree.active = velocity.length_squared() > 0
	
	move_and_slide()


func _on_hurtbox_hurt(damage: int, knockback: int, knockback_angle: Vector2):
	print("_on_hitbox_hurt_kobold")

	print("damage: " + str(damage))
	health -= damage
	print("remaining health: " + str(health))

	print("knockback" + str(knockback) + ", " + str(knockback_angle))
	current_knockback = knockback * knockback_angle
	
	if health <= 0:
		queue_free()
