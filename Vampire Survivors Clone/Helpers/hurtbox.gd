extends Area2D

@onready var cshape: CollisionShape2D = $CollisionShape2D
@onready var timer: Timer = $HurtboxDisabledTimer

signal hurt(damage: int, knockback: int, knockback_angle: Vector2)

func _on_area_entered(area: Area2D):
	if not area.is_in_group("attack"):
		pass

	cshape.call_deferred("set", "disabled", true)
	timer.start()
	
	var knockback_angle = area.transform.x as Vector2
	var knockback = area.get("knockback")
	if knockback == null:
		knockback = 1
	
	var damage = area.get("damage")
	if damage == null:
		damage = 0

	emit_signal("hurt", damage, knockback, knockback_angle)
	
	if area.has_method("enemy_hit"):
		area.enemy_hit()

func _on_hurtbox_disabled_timer_timeout():
	cshape.call_deferred("set", "disabled", false)
