extends Button

@export_file("tscn") var scene_path: String
@onready var audio: AudioStreamPlayer = $AudioStreamPlayer

func _on_button_pressed() -> void:
	audio.play()
	get_tree().change_scene_to_file(scene_path)


func _on_mouse_entered() -> void:
	audio.play()
