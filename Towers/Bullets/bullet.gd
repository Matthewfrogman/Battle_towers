class_name Bullet extends Area2D

var move: Vector2
var damage: int
var pierce: int
var sees_camo: bool

func _process(delta: float) -> void:
	position += Vector2(move[0]*delta, move[1]*delta)
	#if it hits an enemy, deal damage and expire
	
func _on_body_entered(body: Node2D) -> void:
	if body is Enemy and (not body.camo or body.camo and sees_camo):
		body.lose_hp(damage)
		if pierce <= 0:
			queue_free()
		else:
			pierce -= 1
