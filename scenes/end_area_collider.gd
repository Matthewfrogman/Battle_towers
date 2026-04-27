extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if not body is Enemy:
		return
	get_parent().player_hp -= body.dmg_to_player
	body.queue_free()

