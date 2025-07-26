extends Node3D

@export var orbit_radius := 3.0
@export var orbit_speed := 1.0
@export var bee_scene : PackedScene
@export var bee_count := 10

var bees := []

func _ready():
	for i in range(bee_count):
		var bee = bee_scene.instantiate()
		add_child(bee)
		var angle = i * TAU / bee_count
		bee.position = Vector3(orbit_radius * cos(angle), 0, orbit_radius * sin(angle))
		bees.append({ "node": bee, "angle": angle })

func _process(delta):
	for bee_data in bees:
		bee_data["angle"] += orbit_speed * delta
		var angle = bee_data["angle"]
		var bee = bee_data["node"]
		bee.position = Vector3(orbit_radius * cos(angle), 0, orbit_radius * sin(angle))
		#bee.look_at(global_position)  # optional: face hive
