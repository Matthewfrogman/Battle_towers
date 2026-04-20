extends Label


func _process(_delta: float) -> void:
	update_hp_label()
	
func update_hp_label():
	text = "❤️Health: " + str(get_parent().player_hp)
