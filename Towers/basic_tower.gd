extends Tower

@onready var cannon_sprite = get_node("Cannon")

func _process(delta: float) -> void:
	super(delta)
	if mode == "placed":
		cannon_sprite.rotation = angle
