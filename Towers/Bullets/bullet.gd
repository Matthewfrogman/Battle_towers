class_name Bullet extends Area2D

var move: Vector2
var damage: int

func _ready() -> void:
	#print("test")
	pass

func _process(delta: float) -> void:
	position += Vector2(move[0]*delta, move[1]*delta)
	#if it hits an enemy, deal damage and expire
	
func _on_body_entered(body: Node2D) -> void:
	if body.has_method("lose_hp"):
		body.lose_hp(damage)
		queue_free()
