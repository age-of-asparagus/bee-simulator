extends Node

@export var  attach_camera_to : Node3D
@onready var camera: Camera3D = $SubViewport/Camera3D
@onready var sub_viewport: SubViewport = $SubViewport
@onready var texture_rect: TextureRect = $TextureRect

func _ready() -> void:
	#var viewport_texture := ViewportTexture.new()
	#viewport_texture.viewport_path = sub_viewport.get_path()
	#texture_rect.texture = viewport_texture
	texture_rect.texture = sub_viewport.get_texture()
	
func _process(delta: float) -> void:
	if attach_camera_to:
		camera.global_transform = attach_camera_to.global_transform
