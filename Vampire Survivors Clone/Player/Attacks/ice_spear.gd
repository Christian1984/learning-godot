extends Area2D

class_name IceSpear

@export var hp = 1
@export var speed = 100
@export var level = 1
@export var damage = 5
@export var knockback = 100
@export var attack_size = 1.0
@export var ttl = 10

var target_pos = Vector2.ZERO
var duration = 0

@onready var player = get_tree().get_first_node_in_group("player")

func _ready():
	rotation = global_position.angle_to_point(Vector2.ONE)
	
func _physics_process(delta):
	position += speed * delta * transform.x
	duration += delta
	
	if duration > ttl:
		queue_free()
	
func enemy_hit(charge = 1):
	hp -= charge
	if hp<=0:
		queue_free()