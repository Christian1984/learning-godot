extends Node2D

@export_enum("Random Enemy", "Random Direction") var launch_type = "Random Enemy"

@export var attack_resource: PackedScene

@onready var cooldown_timer: Timer = %CooldownTimer
@onready var launch_timer: Timer = %LaunchTimer

@export var base_ammo = 1
@export var attack_speed = 1.5
@export var level = 1

var current_ammo = 0

func _ready():
	if level > 0:
		cooldown_timer.wait_time = attack_speed
		if cooldown_timer.is_stopped():
			cooldown_timer.start()

func _on_launch_timer_timeout():
	if current_ammo > 0 and attack_resource != null:
		var attack: Attack = attack_resource.instantiate()	
		attack.position = global_position
		attack.level = level
		
		match launch_type:
			"Random Enemy":
				var parent = get_parent()
				if parent.has_method("get_random_enemy"):
					# attack.target_pos = get_parent().get_random_enemy()
					attack.direction = get_parent().get_random_enemy() - global_position
			"Random Direction":
				attack.direction = Vector2.from_angle(randf() * 2 * PI)

		# get_node("/root/World").add_child(attack)
		# get_parent().add_child(attack)
		add_child(attack)

		current_ammo -= 1
	else:
		launch_timer.stop()

func _on_cooldown_timer_timeout():
	current_ammo += base_ammo
	if launch_timer.is_stopped():
		launch_timer.start()
