extends Node3D
@onready var mesh: Node3D = $Mesh

@export var orbit_radius_range := Vector2(0.3, 0.8)
@export var orbit_speed_range := Vector2(1.0, 2.0)
@export var height_range := Vector2(-0.5, 0.5)

var orbit_radius := 1.0
var orbit_speed := 1.0
var height_offset := 0.0
var angle_offset := 0.0

func _ready():
	# Randomize orbit parameters
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	orbit_radius = rng.randf_range(orbit_radius_range.x, orbit_radius_range.y)
	orbit_speed = rng.randf_range(orbit_speed_range.x, orbit_speed_range.y)
	height_offset = rng.randf_range(height_range.x, height_range.y)
	angle_offset = rng.randf_range(0, TAU)
	
	mesh.position = Vector3(orbit_radius, height_offset, 0)  # Move out away from hive
	rotate_y(angle_offset) # roate so tey aren't all on the z-axis

func _process(delta):
	rotate_y(orbit_speed * delta)
	#if not orbit_center_node:
		#return
#
	#orbit_angle += orbit_speed * delta
	#var angle = orbit_angle + angle_offset
#
	#var offset = Vector3(
		#orbit_radius * cos(angle),
		#height_offset,
		#orbit_radius * sin(angle)
	#)
#
	#global_position = orbit_center_node.global_position + offset
	#
	## Compute forward direction (tangent to the orbit circle)
	#var forward = Vector3(
		#-orbit_radius * sin(angle),
		#0,
		#orbit_radius * cos(angle)
	#).normalized()
	#look_at(global_position + forward, Vector3.UP)
	
func get_direction_of_movement(previous_position: Vector2, current_position: Vector2):
	return (current_position - previous_position).normalized()
