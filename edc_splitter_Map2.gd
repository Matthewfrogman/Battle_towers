extends "res://scenes/enemy_direction_collider.gd"

@export var send_direction1 = 1
@export var send_direction2 = 3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("lose_hp"):
		var direction = randi_range(0,1)
		if direction == 0:
			body.direction = send_direction1
		if direction == 1:
			body.direction = send_direction2
