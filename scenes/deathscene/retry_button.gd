extends Button


func _on_pressed() -> void:
	#var filename = get_parent().get_parent().name
	#get_tree().change_scene_to_file("res://Maps/" + filename + ".tscn")
	get_tree().reload_current_scene()
