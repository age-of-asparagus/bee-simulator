extends Button

@export_file("tscn") var scene_path: String

func _on_button_pressed() -> void:
	print("Loading...", str(scene_path))
	get_tree().change_scene_to_file(scene_path)
