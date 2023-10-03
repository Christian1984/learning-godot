extends CharacterBody2D

@export var movementSpeed: float = 80
@export var health: int = 100

# Attack Resources
@export var ice_spear_resource: PackedScene
# @onready var ice_spear_resource = load("res://Player/Attacks/ice_spear_resource.tscn")

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_tree: AnimationTree = $AnimationTree

#Attacks
#Ice Spear
@onready var ice_spear_timer: Timer = %IceSpearTimer
@onready var ice_spear_attack_timer: Timer = %IceSpearAttackTimer

var ice_spear_ammo = 0
var ice_spear_base_ammo = 5
var ice_spear_attack_speed = 1.5
var ice_spear_level = 1
var enemies_close: Array[Node2D] = []

func _ready():
	attack()

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

func attack():
	if ice_spear_level > 0:
		ice_spear_timer.wait_time = ice_spear_attack_speed
		if ice_spear_timer.is_stopped():
			ice_spear_timer.start()

func _on_hurtbox_hurt(damage: int, _knockback: int, _knockback_angle: Vector2):
	print_debug("_on_hitbox_hurt_character")
	health -= damage
	print_debug(health)


func _on_ice_spear_timer_timeout():
	ice_spear_ammo += ice_spear_base_ammo
	if ice_spear_attack_timer.is_stopped():
		ice_spear_attack_timer.start()


func _on_ice_spear_attack_timer_timeout():
	if ice_spear_ammo > 0 and not ice_spear_resource ==  null:
		var ice_spear: IceSpear = ice_spear_resource.instantiate()	
		ice_spear.position = position
		ice_spear.target_pos = get_nearest_enemy()
		ice_spear.level = ice_spear_level

		# get_node("/root/World").add_child(ice_spear)
		# get_parent().add_child(ice_spear)
		add_child(ice_spear)

		ice_spear_ammo -= 1
		pass
	else:
		ice_spear_attack_timer.stop()

func get_nearest_enemy():
	if enemies_close.size() > 0:
		var target =  enemies_close.pick_random().global_position
		print_debug(target)
		return target

	return position + Vector2.from_angle(randf() * 2 * PI)

func _on_enemy_detector_body_entered(body):
	if not enemies_close.has(body):
		enemies_close.append(body)


func _on_enemy_detector_body_exited(body):
	if enemies_close.has(body):
		enemies_close.erase(body)
