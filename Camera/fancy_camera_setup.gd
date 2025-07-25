extends Node

@export var  attach_camera_to : Node3D
@onready var camera: Camera3D = $SubViewport/Camera3D

func _process(delta: float) -> void:
	if attach_camera_to:
		camera.global_transform = attach_camera_to.global_transform
