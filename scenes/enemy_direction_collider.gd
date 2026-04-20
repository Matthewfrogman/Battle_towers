extends Area2D

@export var send_direction = 1

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("lose_hp"):
		body.direction = send_direction
