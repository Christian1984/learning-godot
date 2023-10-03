extends CharacterBody2D

@export var movement_speed = 30
@export var health = 20
@export var knockback_recovery = 3.5

@export var death_explosion_resource: PackedScene

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var hit_sound: AudioStreamPlayer2D = $EnemyHitSound

@onready var player: Node2D = get_tree().get_first_node_in_group("player")

var current_knockback = Vector2.ZERO

signal remove_from_list(obj: Object)

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
		emit_signal("remove_from_list", self)
		
		if death_explosion_resource != null:
			var death_explosion: Node2D = death_explosion_resource.instantiate()
			death_explosion.global_position = global_position
			# get_node("/root/World").add_child(death_explosion)
			get_parent().call_deferred("add_child", death_explosion)
			
		queue_free()
	else:
		hit_sound.play()
