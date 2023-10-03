extends Attack

class_name IceSpear

var target_pos = Vector2.ZERO

func _ready():
	super()
	rotation = global_position.angle_to_point(target_pos)

	var tween = create_tween()
	tween.tween_property(self, "scale", attack_info.attack_size * Vector2.ONE, 1).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.play()
	
func _physics_process(delta):
	super(delta)
	position += attack_info.speed * delta * transform.x
