extends Node3D

@export var orbit_radius_range := Vector2(0.3, 1.0)
@export var orbit_speed_range := Vector2(1.0, 2.0)
@export var height_range := Vector2(-0.5, 1.0)

var orbit_radius := 1.0
var orbit_speed := 1.0
var orbit_angle := 0.0
var height_offset := 0.0
var angle_offset := 0.0
var orbit_center_node: Node3D

func _ready():
	orbit_center_node = get_parent()
	if not orbit_center_node:
		push_error("BeeOrbit: no parent to orbit around.")
		return

	# Randomize orbit parameters
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	orbit_radius = rng.randf_range(orbit_radius_range.x, orbit_radius_range.y)
	orbit_speed = rng.randf_range(orbit_speed_range.x, orbit_speed_range.y)
	height_offset = rng.randf_range(height_range.x, height_range.y)
	angle_offset = rng.randf_range(0, TAU)

func _process(delta):
	if not orbit_center_node:
		return

	orbit_angle += orbit_speed * delta
	var angle = orbit_angle + angle_offset

	var offset = Vector3(
		orbit_radius * cos(angle),
		height_offset,
		orbit_radius * sin(angle)
	)

	global_position = orbit_center_node.global_position + offset
	#look_at(orbit_center_node.global_position, Vector3.UP)
