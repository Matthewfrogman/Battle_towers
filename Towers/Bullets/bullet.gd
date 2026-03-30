class_name Bullet extends Area2D

var move: Vector2
var damage: int

func _ready() -> void:
	#print("test")
	pass

func _process(delta: float) -> void:
	position += Vector2(move[0]*delta, move[1]*delta)
	#if it hits an enemy, deal damage and expire
