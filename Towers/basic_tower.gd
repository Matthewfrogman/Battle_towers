extends Tower


func _process(delta: float) -> void:
	super(delta)
	if mode == "placed":
		
		cannon_scene.rotation = angle
		#an extra option if needed
		#cannon_scene.look_at(lookingat)
