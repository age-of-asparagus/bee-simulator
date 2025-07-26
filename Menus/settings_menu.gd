extends Control



func _on_hexellate_vision_check_buttons_toggled(toggled_on: bool) -> void:

	Global.settings_hex_mosaic = toggled_on
	print("Acute ", Global.settings_hex_acute, "; Hex ", Global.settings_hex_mosaic)


func _on_acute_vision_check_button_toggled(toggled_on: bool) -> void:

	Global.settings_hex_acute = toggled_on
	print("Acute ", Global.settings_hex_acute, "; Hex ", Global.settings_hex_mosaic)
