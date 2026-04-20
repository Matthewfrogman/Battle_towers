extends Label


func _process(_delta: float) -> void:
	update_wave_label()

func update_wave_label():
	text = "Wave: " + str(get_parent().get_node("EnemySpawner").current_wave)
