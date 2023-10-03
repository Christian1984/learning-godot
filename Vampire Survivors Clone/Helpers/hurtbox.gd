extends Area2D

@export_enum("Cooldown", "HitOnce") var hurtbox_type = "Cooldown"

@onready var cshape: CollisionShape2D = $CollisionShape2D
@onready var timer: Timer = $HurtboxDisabledTimer

var hit_once_array = []

signal hurt(damage: int, knockback: int, knockback_angle: Vector2)

func _on_area_entered(area: Area2D):
	if not area.is_in_group("attack"):
		return
		
	match hurtbox_type:
		"Cooldown":
			print("Cooldown")
			cshape.call_deferred("set", "disabled", true)
			timer.start()
		"HitOnce":
			# var obj = area as Object
			print("HitOnce")
			if not hit_once_array.has(area):
				hit_once_array.append(area)
				if not area.is_connected("remove_from_list", Callable(self, "remove_from_hit_once_array")):
					area.connect("remove_from_list", Callable(self, "remove_from_hit_once_array"))
			else:
				return
	

	var knockback_angle = area.transform.x as Vector2
	var damage = 0
	var knockback = 0

	if area.has_method("get_knockback"):
		knockback = area.get_knockback()
	
	if area.has_method("get_damage"):
		damage = area.get_damage()

	emit_signal("hurt", damage, knockback, knockback_angle)
	
	if area.has_method("enemy_hit"):
		area.enemy_hit()

func remove_from_hit_once_array(obj: Object):
	print("remove_from_hit_once_array")
	if hit_once_array.has(obj):
		hit_once_array.erase(obj)

func _on_hurtbox_disabled_timer_timeout():
	cshape.call_deferred("set", "disabled", false)
