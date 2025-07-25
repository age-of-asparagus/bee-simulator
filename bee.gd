extends CharacterBody3D

@export var boost_acceleration : float
@export var forward_acceleration : float
@export var drag_coefficient : float
@export var turn_speed : float
@export var smooth_time : float

@onready var starting_vertical_rotation = rotation
@onready var starting_horizontal_rotation = rotation

@onready var vertical_rotation = rotation.x
@onready var horizontal_rotation = rotation.y

@onready var target_vertical_rotation = rotation.x
@onready var target_horizontal_rotation = rotation.y



func _physics_process(delta):
	
	apply_rotation(delta)
	
	apply_boost(delta)
	
	apply_air_resistance(delta)
	
	move_and_slide()

func apply_rotation(delta : float):
	target_vertical_rotation += get_input_vertical_rotation() * turn_speed * delta
	target_horizontal_rotation += get_input_horizontal_rotation() * turn_speed * delta
	
	vertical_rotation = lerp_angle(vertical_rotation, target_vertical_rotation, smooth_time * delta)
	horizontal_rotation = lerp_angle(horizontal_rotation, target_horizontal_rotation, smooth_time * delta)
	
	rotation = Vector3(vertical_rotation, horizontal_rotation, 0)

func apply_boost(delta : float):
	if Input.is_action_pressed("Boost"):
		velocity += -basis.z * boost_acceleration * delta
	else:
		velocity += -basis.z * forward_acceleration * delta

func apply_air_resistance(delta : float):
	velocity -= velocity.normalized() * velocity.length_squared() * drag_coefficient * delta

func get_input_vertical_rotation():
	var input_vertical_rotation = Input.get_axis("Move_down", "Move_up")
	return input_vertical_rotation

func get_input_horizontal_rotation():
	var input_horizontal_rotation = Input.get_axis("Move_right", "Move_left")
	return input_horizontal_rotation
