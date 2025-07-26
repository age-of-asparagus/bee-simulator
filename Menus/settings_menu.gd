extends Control


func _on_check_box_mosaic_toggled(toggled_on: bool) -> void:
	Global.settings_hex_mosaic = toggled_on
