extends Control
@export_file("txt") var credits_file_path: String
@onready var bb_label: RichTextLabel = $MarginContainer/HBoxContainer/VBoxContainer2/PanelContainer/VBoxContainer/RichTextLabel

#func _ready() -> void:
	## read the credits text file and put it in the thingy
	#var text = FileAccess.open(credits_file_path, FileAccess.READ)
	#bb_label.text = text
	#bb_label.reset_size()
	

func _on_rich_text_label_meta_clicked(meta: Variant) -> void:
	# `meta` is not guaranteed to be a String, so convert it to a String
	# to avoid script errors at runtime.
	OS.shell_open(str(meta))
