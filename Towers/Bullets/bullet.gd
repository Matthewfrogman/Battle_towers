class_name Bullet extends Area2D

var move: Vector2
var damage: int

func _process(delta: float) -> void:
	position += move
	#if it hits an enemy, deal damage and expire
