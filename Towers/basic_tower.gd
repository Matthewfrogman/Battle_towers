extends Tower

func _process(delta: float) -> void:
	super(delta)
	if mode == "placed":
		cannon_scene.rotation = deg_to_rad(angle-90)
