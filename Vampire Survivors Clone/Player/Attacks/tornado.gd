extends Attack

class_name Tornado

var min_dir = Vector2.ZERO
var max_dir = Vector2.ZERO

func _ready():
	super()

	var mult = 1
	if randi_range(0, 1) == 1:
		mult = -1

	min_dir = Vector2.from_angle(direction.angle() - mult * 0.25 * PI)
	max_dir = Vector2.from_angle(direction.angle() + mult * 0.25 * PI)
	direction = min_dir

	var scale_tween = create_tween()
	scale_tween.tween_property(self, "scale", attack_info.attack_size * Vector2.ONE, 1).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	scale_tween.play()
	
	var direction_tween = create_tween().set_loops()
	direction_tween.tween_property(self, "direction", max_dir, 2).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	direction_tween.tween_property(self, "direction", min_dir, 2).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	direction_tween.play()
	
func _physics_process(delta):
	super(delta)
	position += attack_info.speed * delta * direction
