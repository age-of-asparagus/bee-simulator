extends CanvasLayer
@export var necter_progress_bar : TextureProgressBar
@export var hive_progress_bar : TextureProgressBar


func _process(delta: float) -> void:
	necter_progress_bar.value = Global.necter
	hive_progress_bar.value = Global.necter
