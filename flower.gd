extends Node3D
class_name Flower

@onready var sunflower: Node3D = $Sunflower
@onready var sunflower_necter: Node3D = $SunflowerNecter

func used_up():
	sunflower.show()
	sunflower_necter.hide()
