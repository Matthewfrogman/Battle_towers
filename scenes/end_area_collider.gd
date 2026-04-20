extends Area2D


func _on_body_entered(body: Node2D) -> void:
	get_parent().player_hp -= body.dmg_to_player
	body.queue_free()
