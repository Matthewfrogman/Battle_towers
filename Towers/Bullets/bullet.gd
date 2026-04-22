class_name Bullet extends Area2D

var path: Array = [0, 0, 0]
var move: Vector2
var damage: int
var pierce: int
var sees_camo: bool
var lifetime: float = 0.0
const MAX_LIFETIME: float = 10.0

func upg_bullet(enemy: Enemy):
	#keep for inheritance overwriting
	print(enemy)

func _process(delta: float) -> void:
	position += Vector2(move[0]*delta, move[1]*delta)
	lifetime += delta
	if lifetime >= MAX_LIFETIME:
		queue_free()
	
func _on_body_entered(body: Node2D) -> void:
	if body is Enemy and (not body.camo or body.camo and sees_camo):
		body.lose_hp(damage)
		if pierce <= 0:
			queue_free()
		else:
			pierce -= 1
