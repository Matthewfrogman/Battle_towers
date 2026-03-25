class_name Bullet extends Area2D

var hspeed: float
var vspeed: float
var damage: int

func _process(delta: float) -> void:
	position += Vector2(hspeed*delta, vspeed*delta)
	#if it hits an enemy, deal damage and expire
