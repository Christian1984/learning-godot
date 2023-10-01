extends Area2D

@onready var cshape: CollisionShape2D = $CollisionShape2D
@onready var timer: Timer = $HurtboxDisabledTimer

signal hurt(damage: int)

func _on_area_entered(area):
	if not area.is_in_group("attack"):
		pass

	cshape.call_deferred("set", "disabled", true)
	timer.start()
	
	var damage = area.get("damage")
	if not damage == null:
		emit_signal("hurt", damage)

func _on_hurtbox_disabled_timer_timeout():
	cshape.call_deferred("set", "disabled", false)
