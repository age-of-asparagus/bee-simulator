extends CharacterBody3D

@export var forward_acceleration : float
@export var max_speed : float
@export var drag : float
@export var turn_speed : float
@export var smooth_time : float

var vertical_rotation = 0
var horizontal_rotation = 0

var target_vertical_rotation = 0
var target_horizontal_rotation = 0



func _physics_process(delta):
	
	target_vertical_rotation += get_input_vertical_rotation() * turn_speed * delta
	target_horizontal_rotation += get_input_horizontal_rotation() * turn_speed * delta
	
	vertical_rotation = lerp_angle(vertical_rotation, target_vertical_rotation, smooth_time * delta)
	horizontal_rotation = lerp_angle(horizontal_rotation, target_horizontal_rotation, smooth_time * delta)
	
	rotation = Vector3(vertical_rotation, horizontal_rotation, 0)
	
	
	if Input.is_action_pressed("Boost"):
		velocity += -basis.z * forward_acceleration * delta
		velocity = velocity.limit_length(max_speed)
	else:
		var drag_force = drag * delta
		if velocity.length() > drag_force:
			velocity -= velocity.normalized() * drag_force
		else:
			velocity = Vector3.ZERO
	
	move_and_slide()


func get_input_vertical_rotation():
	var input_vertical_rotation = Input.get_axis("Move_down", "Move_up")
	return input_vertical_rotation

func get_input_horizontal_rotation():
	var input_horizontal_rotation = Input.get_axis("Move_right", "Move_left")
	return input_horizontal_rotation
