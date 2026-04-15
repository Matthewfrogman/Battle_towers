extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	update_wave_label()

func update_wave_label():
	text = "Wave: " + str(get_parent().get_node("EnemySpawner").wave)
