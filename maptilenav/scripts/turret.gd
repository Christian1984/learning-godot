extends Node3D

@export var range = 5.0
@export var damage = 10.0
@export var block_size = 2.0

@onready var detector: Area3D = $Detector
@onready var detector_collision_shape_3d: CollisionShape3D = $Detector/DetectorCollisionShape3D

var targets_in_range: Array[Node3D]
var current_target: Node3D

func _ready():
	if detector and detector_collision_shape_3d:
		(detector_collision_shape_3d.shape as SphereShape3D).radius = range * block_size

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float):
	if not current_target:
		for target_in_range in targets_in_range:
			if not current_target:
				current_target = target_in_range
			elif global_position.distance_to(target_in_range.global_position) < global_position.distance_to(current_target.global_position):
				current_target = target_in_range
	
	if current_target:
		var rotation_target = Vector3(current_target.global_position.x, global_position.y, current_target.global_position.z)
		look_at(rotation_target)

func _on_detector_body_entered(body: Node3D):
	if "enemies" in body.get_groups():
		print("enemy entered: ", body.name, ", ", body.get_instance_id())
		targets_in_range.append(body)

func _on_detector_body_exited(body: Node3D):
	if "enemies" in body.get_groups():
		print("enemy exited: ", body.name, ", ", body.get_instance_id())
		targets_in_range.erase(body)
		if body == current_target:
			current_target = null

func _on_fire_timer_timeout():
	if current_target and current_target.has_method("take_damage"): # TODO: use raycast to check LOS
		current_target.take_damage(damage)
