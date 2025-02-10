extends StaticBody3D

signal health_changed(health: float, max_health: float)
signal core_died()

@export var max_health = 100
var health = max_health

func _ready():
	health_changed.emit(health, max_health)

func die():
	core_died.emit()

func take_damage(damage: float):
	health -= damage
	health_changed.emit(health, max_health)
	print("core takes damage: ", damage, ", health: ", health)
	if health <= 0:
		die()
