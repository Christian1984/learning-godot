extends Control

@onready var core: StaticBody3D = $"/root/Map/Target"

@onready var core_health_bar: ProgressBar = $CoreHealthBar
@onready var item_display: Label = $HBoxContainer/ItemDisplay

func _on_core_health_changed(health: float, max_health: float):
	update_core_health_bar(health, max_health)

func _ready():
	core.health_changed.connect(_on_core_health_changed)
	if core.health and core.max_health:
		update_core_health_bar(core.health, core.max_health)

func _draw():
	print(size)
	draw_circle(0.5 * size, 10, Color.WHITE, false, 2, true)

func update_core_health_bar(health: float, max_health: float):
	if core_health_bar:
		core_health_bar.value = clamp(health / max_health, 0, 1) * 100

func _on_player_item_updated(name: String):
	item_display.text = name
	
