extends Area2D

class_name IceSpear

@export var hp = 2
@export var speed = 100
@export var level = 1
@export var damage = 10
@export var knockback = 100
@export var attack_size = 1.0
@export var ttl = 10

var target_pos = Vector2.ZERO
var duration = 0

@onready var player = get_tree().get_first_node_in_group("player")

signal remove_from_list(obj: Object)

func _ready():
	rotation = global_position.angle_to_point(target_pos)

	var tween = create_tween()
	tween.tween_property(self, "scale", attack_size * Vector2.ONE, 1).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.play()
	
func _physics_process(delta):
	position += speed * delta * transform.x
	duration += delta
	
	if duration > ttl:
		emit_signal("remove_from_list", self)
		queue_free()
	
func enemy_hit(charge = 1):
	hp -= charge
	if hp<=0:
		emit_signal("remove_from_list", self)
		queue_free()