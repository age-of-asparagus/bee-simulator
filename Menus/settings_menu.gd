extends Control
@onready var audio: AudioStreamPlayer = $AudioStreamPlayer



func _on_hexellate_vision_check_buttons_toggled(toggled_on: bool) -> void:
	Global.settings_hex_mosaic = toggled_on
	audio.play()

func _on_acute_vision_check_button_toggled(toggled_on: bool) -> void:
	Global.settings_hex_acute = toggled_on
	audio.play()

func _on_bee_spectrums_vision_check_button_toggled(toggled_on: bool) -> void:
	Global.settings_bee_spectrum = toggled_on
	audio.play()
